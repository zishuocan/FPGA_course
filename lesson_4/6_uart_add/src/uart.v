module uart(
    input             clk_50m,
    input             rst_n,
    input             rx,
    output            tx
    );

wire        busy;
wire [7:0]  rx_o;
wire        rx_o_vld;
reg  [7:0]  tx_data;
reg         tx_en;

reg  [3:0]  rx_cnt;
reg  [14:0] num_a;
reg  [14:0] num_b;
reg  [14:0] sum_reg;

reg  [3:0]  sum_d4;
reg  [3:0]  sum_d3;
reg  [3:0]  sum_d2;
reg  [3:0]  sum_d1;
reg  [3:0]  sum_d0;

reg  [2:0]  tx_idx;
reg  [2:0]  tx_last;

reg  [2:0]  state;
localparam  ST_RX      = 3'd0,
            ST_PREP    = 3'd1,
            ST_TX_REQ  = 3'd2,
            ST_TX_BUSY = 3'd3,
            ST_TX_DONE = 3'd4;

wire        rx_is_digit = (rx_o >= 8'd48) && (rx_o <= 8'd57);
wire [3:0]  rx_digit    = rx_o - 8'd48;

wire [14:0] num_a_mul10 = (num_a << 3) + (num_a << 1);
wire [14:0] num_b_mul10 = (num_b << 3) + (num_b << 1);
wire [14:0] num_b_next  = num_b_mul10 + rx_digit;
wire [19:0] sum_bcd_w   = bin_to_bcd(sum_reg);

function [3:0] digit_sel;
    input [2:0] idx;
    begin
        case(idx)
            3'd0: digit_sel = sum_d4;
            3'd1: digit_sel = sum_d3;
            3'd2: digit_sel = sum_d2;
            3'd3: digit_sel = sum_d1;
            default: digit_sel = sum_d0;
        endcase
    end
endfunction

function [19:0] bin_to_bcd;
    input [14:0] bin_in;
    integer i;
    reg [34:0] shift;
    begin
        shift = 35'd0;
        shift[14:0] = bin_in;
        for(i = 0; i < 15; i = i + 1) begin
            if(shift[18:15] >= 4'd5) shift[18:15] = shift[18:15] + 4'd3;
            if(shift[22:19] >= 4'd5) shift[22:19] = shift[22:19] + 4'd3;
            if(shift[26:23] >= 4'd5) shift[26:23] = shift[26:23] + 4'd3;
            if(shift[30:27] >= 4'd5) shift[30:27] = shift[30:27] + 4'd3;
            if(shift[34:31] >= 4'd5) shift[34:31] = shift[34:31] + 4'd3;
            shift = shift << 1;
        end
        bin_to_bcd = shift[34:15];
    end
endfunction

uart_rx u1_uart_rx(
    .clk_50m  (clk_50m),
    .rst_n    (rst_n),
    .rx_i     (rx),
    .rx_o     (rx_o),
    .rx_o_vld (rx_o_vld)
    );

uart_tx u2_uart_tx(
    .clk_50m  (clk_50m),
    .rst_n    (rst_n),
    .data_i   (tx_data),
    .tx_en    (tx_en),
    .tx_o     (tx),
    .busy     (busy)
    );

always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        tx_en   <= 1'b0;
        tx_data <= 8'd0;

        rx_cnt  <= 4'd0;
        num_a   <= 15'd0;
        num_b   <= 15'd0;
        sum_reg <= 15'd0;

        sum_d4  <= 4'd0;
        sum_d3  <= 4'd0;
        sum_d2  <= 4'd0;
        sum_d1  <= 4'd0;
        sum_d0  <= 4'd0;

        tx_idx  <= 3'd0;
        tx_last <= 3'd4;

        state   <= ST_RX;
    end
    else begin
        tx_en <= 1'b0;

        case(state)
            ST_RX: begin
                if(rx_o_vld && rx_is_digit) begin
                    if(rx_cnt < 4'd4) begin
                        num_a <= num_a_mul10 + rx_digit;
                    end
                    else begin
                        num_b <= num_b_next;
                    end

                    if(rx_cnt == 4'd7) begin
                        sum_reg <= num_a + num_b_next;
                        state   <= ST_PREP;
                    end

                    rx_cnt <= rx_cnt + 1'b1;
                end
                else if(rx_o_vld) begin
                    rx_cnt  <= 4'd0;
                    num_a   <= 15'd0;
                    num_b   <= 15'd0;
                    sum_reg <= 15'd0;
                end
            end

            ST_PREP: begin
                sum_d4 <= sum_bcd_w[19:16];
                sum_d3 <= sum_bcd_w[15:12];
                sum_d2 <= sum_bcd_w[11:8];
                sum_d1 <= sum_bcd_w[7:4];
                sum_d0 <= sum_bcd_w[3:0];

                if(sum_bcd_w[19:16] != 4'd0) begin
                    tx_idx <= 3'd0;
                end
                else if(sum_bcd_w[15:12] != 4'd0) begin
                    tx_idx <= 3'd1;
                end
                else if(sum_bcd_w[11:8] != 4'd0) begin
                    tx_idx <= 3'd2;
                end
                else if(sum_bcd_w[7:4] != 4'd0) begin
                    tx_idx <= 3'd3;
                end
                else begin
                    tx_idx <= 3'd4;
                end

                tx_last <= 3'd4;
                state   <= ST_TX_REQ;
            end

            ST_TX_REQ: begin
                if(!busy) begin
                    tx_data <= 8'd48 + digit_sel(tx_idx);
                    tx_en   <= 1'b1;
                    state   <= ST_TX_BUSY;
                end
            end

            ST_TX_BUSY: begin
                if(busy) begin
                    state <= ST_TX_DONE;
                end
            end

            ST_TX_DONE: begin
                if(!busy) begin
                    if(tx_idx == tx_last) begin
                        rx_cnt  <= 4'd0;
                        num_a   <= 15'd0;
                        num_b   <= 15'd0;
                        sum_reg <= 15'd0;
                        state   <= ST_RX;
                    end
                    else begin
                        tx_idx <= tx_idx + 1'b1;
                        state  <= ST_TX_REQ;
                    end
                end
            end

            default: begin
                state <= ST_RX;
            end
        endcase
    end
end

endmodule
