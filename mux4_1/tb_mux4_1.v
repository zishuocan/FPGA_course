`timescale 1ns/1ps

module tb_mux4_1;

reg  [3:0] in;
reg  [1:0] sel;
wire       out;

integer in_val;
integer sel_val;
integer error_count;
reg expected;

mux4_1 dut (
	.in(in),
	.sel(sel),
	.out(out)
);

initial begin
	$dumpfile("tb_mux4_1.vcd");
	$dumpvars(0, tb_mux4_1);

	error_count = 0;

	for (in_val = 0; in_val < 16; in_val = in_val + 1) begin
		in = in_val[3:0];

		for (sel_val = 0; sel_val < 4; sel_val = sel_val + 1) begin
			sel = sel_val[1:0];
			#1;

			expected = in[sel];
			if (out !== expected) begin
				error_count = error_count + 1;
				$display("ERROR: in=%b sel=%b out=%b expected=%b", in, sel, out, expected);
			end
		end
	end

	if (error_count == 0)
		$display("PASS: all test cases passed.");
	else
		$display("FAIL: %0d test case(s) failed.", error_count);

	$finish;
end

endmodule
