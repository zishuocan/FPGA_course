`timescale 1ns/1ps

module tb_water_led;

	reg         clk_50m;
	reg         rst_n;
	reg         sw_key;
	wire [7:0]  led;

	// Instantiate DUT and override parameter for fast simulation.
	water_led #(
		.CNT_MAX(25'd10)
	) u_water_led (
		.clk_50m(clk_50m),
		.rst_n  (rst_n),
		.sw_key (sw_key),
		.led    (led)
	);

	// 50 MHz clock: period = 20 ns
	initial clk_50m = 1'b0;
	always #10 clk_50m = ~clk_50m;

	initial begin
		// Dump waveform for GTKWave
		$dumpfile("wave.vcd");
		$dumpvars(0, tb_water_led);

		// Initial values
		rst_n  = 1'b0;
		sw_key = 1'b0;

		// Release reset
		#100;
		rst_n = 1'b1;

		// Disable then enable switch to observe LED output gating
		#100;
		sw_key = 1'b1;

		// Run enough time to observe several shifts
		#3000;

		// Turn off switch and finish
		sw_key = 1'b0;
		#200;

		$finish;
	end

endmodule
