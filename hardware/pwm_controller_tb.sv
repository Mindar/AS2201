`include "./hardware/pwm.sv"
`include "./hardware/pwm_controller.sv"
`include "./hardware/timer.sv"
`timescale 1ns/1ps

module pwm_tb;

reg [3:0] pwm_set [1:0];
reg [1:0] channel_enable;
wire [1:0] pwm_out;

parameter timerbits = 4;

reg clk, rst, dir, mode;
reg  [timerbits - 1 : 0] max;
wire [timerbits   - 1 : 0] counter;

timer #(.BITS(timerbits)) tim1 (.rst(rst), .pulse(clk), .count_dir(dir), .count_mode(mode), .reload_value(max), .counter(counter));

pwm_controller #(.BITS(timerbits), .CHANNELS(2)) pwm_controller_1(.clk(clk), .rst(rst), .counter(counter), .channel_enable(channel_enable), .set_values(pwm_set), .outputs(pwm_out));


initial begin
	$display("PWM Testbench");

	$dumpfile("./test/pwmtest2.vcd");
	$dumpvars();


	rst <= 1;
	clk <= 0;
	mode <= 1;
	dir <= 1;
	max <= 4'b0111;
	channel_enable <= 2'b11;
	pwm_set[0] <= 4'b0000;
	pwm_set[1] <= 4'b0000;

	$display("Initialized with ~50%% duty cycle");

	#10
	rst <= 0;
	
	#300
	pwm_set[0] <= 4'b0100;
	pwm_set[1] <= 4'b0010;

	#300
	channel_enable <= 2'b00;

	#150
	channel_enable <= 2'b01;

	#150
	$finish();
end

always #5 clk <= ~clk;

endmodule