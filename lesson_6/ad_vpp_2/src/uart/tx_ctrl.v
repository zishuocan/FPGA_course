/*****************************************************************
*****************************FPGA实验************************
**软    件:GOwin云源软件
**项    目:UART发送控制模块
**时    钟:100MHz
**板卡型号:GW1N-UV9EQ144C6I5
*****************************************************************/
module tx_ctrl #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer BAUD_RATE   = 115200
)(
    input               clk_100m,
    input               rst_n,
    input               send_en,
    input      [15:0]   data_bcd,
    output              tx
);

localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
localparam [3:0]   TOTAL_BYTES  = 4'd10;

reg        sending;
reg [3:0]  byte_idx;
reg [15:0] data_latched;
reg        tx_dv;
reg [7:0]  tx_byte;

wire tx_active;
wire tx_done;

function [7:0] nibble_to_ascii;
    input [3:0] din;
    begin
        if(din <= 4'd9) begin
            nibble_to_ascii = 8'h30 + din;
        end
        else begin
            nibble_to_ascii = 8'h30;
        end
    end
endfunction

function [7:0] frame_byte;
    input [3:0]  index;
    input [15:0] bcd_data;
    begin
        case(index)
            4'd0: frame_byte = 8'h52; //R
            4'd1: frame_byte = 8'h4D; //M
            4'd2: frame_byte = 8'h53; //S
            4'd3: frame_byte = 8'h3A; //:
            4'd4: frame_byte = nibble_to_ascii(bcd_data[15:12]);
            4'd5: frame_byte = nibble_to_ascii(bcd_data[11:8]);
            4'd6: frame_byte = nibble_to_ascii(bcd_data[7:4]);
            4'd7: frame_byte = nibble_to_ascii(bcd_data[3:0]);
            4'd8: frame_byte = 8'h0D;
            4'd9: frame_byte = 8'h0A;
            default: frame_byte = 8'h20;
        endcase
    end
endfunction

always @(posedge clk_100m or negedge rst_n) begin
    if(!rst_n) begin
        sending       <= 1'b0;
        byte_idx      <= 4'd0;
        data_latched  <= 16'd0;
        tx_dv         <= 1'b0;
        tx_byte       <= 8'd0;
    end
    else begin
        tx_dv <= 1'b0;
        if(!sending) begin
            if(send_en) begin
                sending      <= 1'b1;
                byte_idx     <= 4'd0;
                data_latched <= data_bcd;
                tx_byte      <= frame_byte(4'd0, data_bcd);
                tx_dv        <= 1'b1;
            end
        end
        else if(tx_done) begin
            if(byte_idx == TOTAL_BYTES - 1'b1) begin
                sending  <= 1'b0;
                byte_idx <= 4'd0;
            end
            else begin
                byte_idx <= byte_idx + 1'b1;
                tx_byte  <= frame_byte(byte_idx + 1'b1, data_latched);
                tx_dv    <= 1'b1;
            end
        end
    end
end

uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) u_uart_tx (
    .i_clk      (clk_100m ),
    .i_rst_n    (rst_n    ),
    .i_tx_dv    (tx_dv    ),
    .i_tx_byte  (tx_byte  ),
    .o_tx_active(tx_active),
    .o_tx_serial(tx       ),
    .o_tx_done  (tx_done  )
);

endmodule
