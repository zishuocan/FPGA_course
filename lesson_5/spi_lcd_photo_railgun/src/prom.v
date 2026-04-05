module prom(
    input clk,
    input rst,
    input wire [10:0] addr_i,
    output reg [15:0] data_o
);

reg prom_cs;
reg [9:0] prom1_addr;
reg [9:0] prom2_addr;
wire [15:0] prom1_data;
wire [15:0] prom2_data;

// Gowin_pROM_1 prom1_inst(
//     .dout(prom1_data), //output [15:0] dout
//     .clk(clk), //input clk
//     .oce(1'b1), //input oce
//     .ce(prom_cs), //input ce
//     .reset( !rst ), //input reset
//     .ad(prom1_addr) //input [9:0] ad
// );

// Gowin_pROM_2 prom2_inst(
//     .dout(prom2_data), //output [15:0] dout
//     .clk(clk), //input clk
//     .oce(1'b1), //input oce
//     .ce( !prom_cs ), //input ce
//     .reset( !rst), //input reset
//     .ad(prom2_addr) //input [9:0] ad
// );

Gowin_pROM u_Gowin_pROM(
    .dout (dout_o ), //output [15:0] dout
    .clk  (clk_i  ), //input clk
    .oce  (oce_i  ), //input oce
    .ce   (ce_i   ), //input ce
    .reset(!rst), //input reset
    .ad   (ad_i   ) //input [14:0] ad
);

always @(*) begin
    if( addr_i < 1012 ) begin
        prom_cs = 1'b1;
        prom1_addr = addr_i[9:0];
        data_o = prom1_data;
    end else begin
        prom_cs = 1'b0;
        prom2_addr = addr_i[9:0];
        data_o = prom2_data;
    end
end


endmodule



