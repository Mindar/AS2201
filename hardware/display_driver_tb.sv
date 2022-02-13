`timescale 1ns/1ps
`include "./hardware/display_driver.sv"

module display_tb;

reg [31:0] display_data;
reg [6:0] sp;
reg [3:0] dp;
reg [15:0] pwm_period;
reg [1:0] brightness;
reg [1:0] display_mode;


display_driver disp(
	.clk(clk),
	.rst(rst),
	.display_data(display_data),
	.segment_pins(sp),
	.digit_pins(dp),
	.pwm_period(pwm_period),
	.display_mode(display_mode),
	.brightness(brightness)
);

initial begin
	display_data <= 32'h6F3A4C0F;

	pwm_period <= 16'b100000;

	brightness <= 2'b11;
	display_mode <= 2'b11; // segment display mode

	#50;
	rst <= 0;

	#1000
	brightness <= 2'b01;

	#1000
	brightness <= 2'b10;

	#1000
	brightness <= 2'b00;

	#1000
	brightness <= 2'b11;

	// This program should terminate eventually
	#100000;
	$finish;
end

reg clk;
reg rst;

initial begin
	$dumpfile("./test/display1.vcd");
	$dumpvars();

	clk <= 0;
	rst <= 1;
end

always #5 clk <= ~clk;

endmodule