`timescale 1ns/1ps

module half_adder(
	input  wire a,
	input  wire b,
	output wire sum,
	output wire cout
);
	assign sum  = a ^ b;
	assign cout = a & b;
endmodule

module full_adder(
	input  wire a,
	input  wire b,
	input  wire cin,
	output wire sum,
	output wire cout
);
	wire s1;
	wire c1;
	wire c2;

	// Build a 1-bit full adder from two half adders.
	half_adder u_ha0 (
		.a   (a),
		.b   (b),
		.sum (s1),
		.cout(c1)
	);

	half_adder u_ha1 (
		.a   (s1),
		.b   (cin),
		.sum (sum),
		.cout(c2)
	);

	assign cout = c1 | c2;
endmodule

