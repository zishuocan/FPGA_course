module uart_tx(
    input             clk_50m,
    input             rst_n,
    input      [7:0]  data_i,
    input             tx_en,
    output reg        tx_o,
    output reg        busy
    );

parameter   CNT_50M  = 'd50_000_000;
parameter   CNT_BPS3 = CNT_50M/9600,
            CNT_BPS2 = CNT_50M/57600,
            CNT_BPS1 = CNT_50M/19200;

reg  [10:0] data_r;
reg  [24:0] cnt_bps;
wire        add_cnt_bps;
wire        end_cnt_bps;
reg  [3:0]  cnt_bit;
wire        add_cnt_bit;
wire        end_cnt_bit;

always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        busy <= 1'b0;
    end
    else if(end_cnt_bit) begin
        busy <= 1'b0;
    end
    else if(tx_en && (!busy)) begin
        busy <= 1'b1;
    end
end

always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        data_r <= 11'b111_1111_1111;
    end
    else if(tx_en && (!busy)) begin
        data_r[0]   <= 1'b0;    // start
        data_r[8:1] <= data_i;  // data[7:0], LSB first
        data_r[9]   <= ^data_i; // even parity
        data_r[10]  <= 1'b1;    // stop
    end
end

always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        cnt_bps <= 25'd0;
    end
    else if(add_cnt_bps) begin
        if(end_cnt_bps) begin
            cnt_bps <= 25'd0;
        end
        else begin
            cnt_bps <= cnt_bps + 1'b1;
        end
    end
    else begin
        cnt_bps <= 25'd0;
    end
end
assign add_cnt_bps = busy;
assign end_cnt_bps = add_cnt_bps && (cnt_bps == CNT_BPS2 - 1'b1);

always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        cnt_bit <= 4'd0;
    end
    else if(end_cnt_bit) begin
        cnt_bit <= 4'd0;
    end
    else if(add_cnt_bit) begin
        cnt_bit <= cnt_bit + 1'b1;
    end
end
assign add_cnt_bit = end_cnt_bps;
assign end_cnt_bit = add_cnt_bit && (cnt_bit == 4'd10);

always @(*) begin
    if(!busy) begin
        tx_o = 1'b1;
    end
    else begin
        tx_o = data_r[cnt_bit];
    end
end

endmodule
