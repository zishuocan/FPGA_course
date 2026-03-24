module data_ctrl(
    input              clk_50m,
    input              rst_n,
    input      [31:0]  dht_data,
    output reg [7:0]   data_o,
    output reg         data_o_vld
);

// Timing parameters
parameter CNT_1S       = 26'd50_000_000;
parameter CNT_BYTE_GAP = 14'd12_000;
parameter FRAME_LEN    = 6'd22;

reg [25:0] cnt_1s;
reg [13:0] cnt_gap;
reg [5:0]  cnt_byte;
reg        send_flag;

reg [7:0] temp_int_r;
reg [7:0] temp_dec_r;
reg [7:0] hum_int_r;

reg [7:0] tx_byte;

wire end_cnt_1s;
wire end_cnt_gap;
wire end_cnt_byte;

wire [3:0] temp_ten;
wire [3:0] temp_unit;
wire [3:0] temp_dec_1;
wire [3:0] hum_ten;
wire [3:0] hum_unit;

assign end_cnt_1s   = (cnt_1s   == CNT_1S - 1'b1);
assign end_cnt_gap  = (cnt_gap  == CNT_BYTE_GAP - 1'b1);
assign end_cnt_byte = (cnt_byte == FRAME_LEN - 1'b1);

assign temp_ten   = temp_int_r / 8'd10;
assign temp_unit  = temp_int_r % 8'd10;
assign temp_dec_1 = temp_dec_r / 8'd10;
assign hum_ten    = hum_int_r / 8'd10;
assign hum_unit   = hum_int_r % 8'd10;

// counter1: 1-second period
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        cnt_1s <= 26'd0;
    end
    else if(end_cnt_1s) begin
        cnt_1s <= 26'd0;
    end
    else begin
        cnt_1s <= cnt_1s + 1'b1;
    end
end

// Byte map (GBK + ASCII):
// CE C2 B6 C8 : "temp" in Chinese
// CA AA B6 C8 : "humidity" in Chinese
// A1 E6       : degree symbol
always @(*) begin
    case(cnt_byte)
        6'd0  : tx_byte = 8'hCE;
        6'd1  : tx_byte = 8'hC2;
        6'd2  : tx_byte = 8'hB6;
        6'd3  : tx_byte = 8'hC8;
        6'd4  : tx_byte = 8'h3A;
        6'd5  : tx_byte = 8'h30 + temp_ten;
        6'd6  : tx_byte = 8'h30 + temp_unit;
        6'd7  : tx_byte = 8'h2E;
        6'd8  : tx_byte = 8'h30 + temp_dec_1;
        6'd9  : tx_byte = 8'hA1;
        6'd10 : tx_byte = 8'hE6;
        6'd11 : tx_byte = 8'h20;
        6'd12 : tx_byte = 8'hCA;
        6'd13 : tx_byte = 8'hAA;
        6'd14 : tx_byte = 8'hB6;
        6'd15 : tx_byte = 8'hC8;
        6'd16 : tx_byte = 8'h3A;
        6'd17 : tx_byte = 8'h30 + hum_ten;
        6'd18 : tx_byte = 8'h30 + hum_unit;
        6'd19 : tx_byte = 8'h25;
        6'd20 : tx_byte = 8'h0D;
        6'd21 : tx_byte = 8'h0A;
        default: tx_byte = 8'h20;
    endcase
end

// counter2 + transmitter feed control
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        cnt_gap    <= 14'd0;
        cnt_byte   <= 6'd0;
        send_flag  <= 1'b0;
        temp_int_r <= 8'd0;
        temp_dec_r <= 8'd0;
        hum_int_r  <= 8'd0;
        data_o     <= 8'd0;
        data_o_vld <= 1'b0;
    end
    else begin
        data_o_vld <= 1'b0;

        if(end_cnt_1s && !send_flag) begin
            temp_int_r <= dht_data[15:8];
            temp_dec_r <= dht_data[7:0];
            hum_int_r  <= dht_data[31:24];

            send_flag <= 1'b1;
            cnt_byte  <= 6'd0;
            cnt_gap   <= CNT_BYTE_GAP - 1'b1;
        end
        else if(send_flag) begin
            if(end_cnt_gap) begin
                cnt_gap    <= 14'd0;
                data_o     <= tx_byte;
                data_o_vld <= 1'b1;

                if(end_cnt_byte) begin
                    send_flag <= 1'b0;
                    cnt_byte  <= 6'd0;
                end
                else begin
                    cnt_byte <= cnt_byte + 1'b1;
                end
            end
            else begin
                cnt_gap <= cnt_gap + 1'b1;
            end
        end
        else begin
            cnt_gap <= 14'd0;
        end
    end
end

endmodule