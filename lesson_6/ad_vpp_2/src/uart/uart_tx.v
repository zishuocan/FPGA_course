/*****************************************************************
*****************************FPGA实验************************
**软    件:GOwin云源软件
**项    目:UART发送模块
**时    钟:100MHz
**板卡型号:GW1N-UV9EQ144C6I5
*****************************************************************/
module uart_tx #(
    parameter integer CLKS_PER_BIT = 868
)(
    input              i_clk,
    input              i_rst_n,
    input              i_tx_dv,
    input      [7:0]   i_tx_byte,
    output reg         o_tx_active,
    output reg         o_tx_serial,
    output reg         o_tx_done
);

localparam [2:0] S_IDLE  = 3'd0;
localparam [2:0] S_START = 3'd1;
localparam [2:0] S_DATA  = 3'd2;
localparam [2:0] S_STOP  = 3'd3;
localparam [2:0] S_CLEAN = 3'd4;

reg [2:0]  state;
reg [31:0] clk_cnt;
reg [2:0]  bit_idx;
reg [7:0]  tx_data;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state        <= S_IDLE;
        o_tx_active  <= 1'b0;
        o_tx_serial  <= 1'b1;
        o_tx_done    <= 1'b0;
        clk_cnt      <= 32'd0;
        bit_idx      <= 3'd0;
        tx_data      <= 8'd0;
    end
    else begin
        o_tx_done <= 1'b0;
        case(state)
            S_IDLE: begin
                o_tx_serial <= 1'b1;
                o_tx_active <= 1'b0;
                clk_cnt     <= 32'd0;
                bit_idx     <= 3'd0;
                if(i_tx_dv) begin
                    tx_data     <= i_tx_byte;
                    o_tx_active <= 1'b1;
                    state       <= S_START;
                end
            end

            S_START: begin
                o_tx_serial <= 1'b0;
                if(clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                else begin
                    clk_cnt <= 32'd0;
                    state   <= S_DATA;
                end
            end

            S_DATA: begin
                o_tx_serial <= tx_data[bit_idx];
                if(clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                else begin
                    clk_cnt <= 32'd0;
                    if(bit_idx < 3'd7) begin
                        bit_idx <= bit_idx + 1'b1;
                    end
                    else begin
                        bit_idx <= 3'd0;
                        state   <= S_STOP;
                    end
                end
            end

            S_STOP: begin
                o_tx_serial <= 1'b1;
                if(clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                else begin
                    clk_cnt     <= 32'd0;
                    o_tx_done   <= 1'b1;
                    o_tx_active <= 1'b0;
                    state       <= S_CLEAN;
                end
            end

            S_CLEAN: begin
                state <= S_IDLE;
            end

            default: begin
                state <= S_IDLE;
            end
        endcase
    end
end

endmodule
