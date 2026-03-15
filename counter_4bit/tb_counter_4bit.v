`timescale 1ns/1ps

module tb_counter_4bit;
	reg        clk;
	reg        rst_n;
	reg        enable;
	wire [3:0] count;

	counter_4bit dut (
		.clk    (clk),
		.rst_n  (rst_n),
		.enable (enable),
		.count  (count)
	);

	initial begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end

	initial begin
		$dumpfile("counter_4bit.vcd");
		$dumpvars(0, tb_counter_4bit);

		rst_n = 1'b0;
		enable = 1'b0;

		#12;
		rst_n = 1'b1;

		#8;
		enable = 1'b1;

		#100;
		enable = 1'b0;

		#20;
		rst_n = 1'b0;

		#7;
		rst_n = 1'b1;

		#10;
		enable = 1'b1;

		#60;
		$finish;
	end
endmodule

