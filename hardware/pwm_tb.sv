`include "./hardware/pwm.sv"
`include "./hardware/timer.sv"
`timescale 1ns/1ps

module pwm_tb;

reg [3:0] pwm_set;
wire pwm_out;

parameter timerbits = 4;

reg clk, rst, dir, mode;
reg  [timerbits - 1 : 0] max;
wire [timerbits   - 1 : 0] counter;

timer #(.BITS(timerbits)) tim1 (.rst(rst), .pulse(clk), .count_dir(dir), .count_mode(mode), .reload_value(max), .counter(counter));

pwm #(.BITS(timerbits), .CHANNELS(1)) my_pwm(.counter(counter), .pwm_set(pwm_set), .out(pwm_out));


initial begin
	$display("PWM Testbench");

	$dumpfile("./test/pwmtest.vcd");
	$dumpvars();


	rst <= 1;
	clk <= 0;
	mode <= 1;
	dir <= 1;
	max <= 4'b0111;
	pwm_set <= 4'b0100;




	$display("Initialized with ~50%% duty cycle");

	#10
	rst <= 0;



	#300
	pwm_set <= 4'b0111;

	#300
	pwm_set <= 4'b1000;

	#300
	pwm_set <= 4'b0000;

	#300
	$finish();
end

always #5 clk <= ~clk;

endmodule