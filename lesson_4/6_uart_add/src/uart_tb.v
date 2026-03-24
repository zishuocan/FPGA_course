`timescale 1ns/1ns
module uart_tb();

reg  clk_50m;
reg  rst_n;
reg  rx;
wire tx;

uart u_dut(
    .clk_50m (clk_50m),
    .rst_n   (rst_n),
    .rx      (rx),
    .tx      (tx)
    );

initial begin
    clk_50m = 1'b0;
    rst_n   = 1'b1;
    #20;
    rst_n   = 1'b0;
    #40;
    rst_n   = 1'b1;
end
always #10 clk_50m = ~clk_50m;

initial begin
    rx = 1'b1;
    #600;

    // '7' (ASCII 0x37), even parity = 1
    rx = 1'b0; #400;
    rx = 1'b1; #400;
    rx = 1'b1; #400;
    rx = 1'b1; #400;
    rx = 1'b0; #400;
    rx = 1'b1; #400;
    rx = 1'b1; #400;
    rx = 1'b0; #400;
    rx = 1'b0; #400;
    rx = 1'b1; #400;
    rx = 1'b1; #400;

    // '5' (ASCII 0x35), even parity = 0
    rx = 1'b0; #400;
    rx = 1'b1; #400;
    rx = 1'b0; #400;
    rx = 1'b1; #400;
    rx = 1'b0; #400;
    rx = 1'b1; #400;
    rx = 1'b1; #400;
    rx = 1'b0; #400;
    rx = 1'b0; #400;
    rx = 1'b0; #400;
    rx = 1'b1; #400;

    #10000;
    $stop;
end

endmodule