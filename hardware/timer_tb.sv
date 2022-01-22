`include "./hardware/timer.sv"
`timescale 1ns/1ps

module timer_tb;

parameter timerbits = 4;

reg clk, rst, dir, mode;
reg  [timerbits - 1 : 0] max;
wire [timerbits   - 1 : 0] counter;

timer #(.BITS(timerbits)) mytimer (.rst(rst), .pulse(clk), .count_dir(dir), .count_mode(mode), .reload_value(max), .counter(counter));

initial begin
	$display("Timer Testbench");

	$dumpfile("./test/timer.vcd");
	$dumpvars();

	rst <= 1;
	clk <= 0;
	dir <= 0;
	mode <= 0;
	max <= 4'b0000;

	#5
	max <= 4'b0101;

	#10
	rst <= 0;
	

	#200
	rst <= 1;

	#20
	rst <= 0;
	mode <= 1;

	#100
	dir <= 1;

	#150
	$finish;
end

always #5 clk <= ~clk;


endmodule