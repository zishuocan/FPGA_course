`timescale 1ns/1ps

module tb_add;
	reg  a;
	reg  b;
	reg  cin;
	wire ha_sum;
	wire ha_cout;
	wire fa_sum;
	wire fa_cout;

	integer i;

	half_adder u_half_adder (
		.a   (a),
		.b   (b),
		.sum (ha_sum),
		.cout(ha_cout)
	);

	full_adder u_full_adder (
		.a   (a),
		.b   (b),
		.cin (cin),
		.sum (fa_sum),
		.cout(fa_cout)
	);

	initial begin
		$dumpfile("add.vcd");
		$dumpvars(0, tb_add);

		$display("========================================");
		$display("Half Adder Truth Table");
		$display(" a b | sum cout");
		$display("----------------------------------------");

		cin = 1'b0;
		for (i = 0; i < 4; i = i + 1) begin
			{a, b} = i[1:0];
			#10;
			$display(" %b %b |  %b    %b", a, b, ha_sum, ha_cout);
		end

		$display("========================================");
		$display("Full Adder Truth Table");
		$display(" a b cin | sum cout");
		$display("----------------------------------------");

		for (i = 0; i < 8; i = i + 1) begin
			{a, b, cin} = i[2:0];
			#10;
			$display(" %b %b  %b  |  %b    %b", a, b, cin, fa_sum, fa_cout);
		end

		$display("========================================");
		$finish;
	end
endmodule

