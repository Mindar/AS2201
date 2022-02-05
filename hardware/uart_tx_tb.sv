`timescale 1ns/1ps
`include "./hardware/uart_tx.sv"

module uart_tx_tb;

reg rst, clk, data_ready;
reg [ 15 : 0 ] bit_duration;
reg [ 7 : 0 ] data;
reg [ 1 : 0 ] stopbits;

wire tx, tx_complete;


int unsigned baudrate = 115200;
int unsigned nanosecondsPerSec = 1000000000;
real delay_time_f = real'(nanosecondsPerSec) / real'(baudrate);
int unsigned delay_time = $ceil(delay_time_f);


int unsigned test_clk_period = 10; // ns/clk
int unsigned bit_duration_ns = delay_time; // ns/bit
int unsigned bit_duration_ctr = bit_duration_ns / test_clk_period; // clk/bit

uart_tx mytx(
	.rst(rst),
	.clk(clk),
	.data_ready(data_ready),
	.bit_duration(bit_duration),
	.data(data),
	.stopbits(stopbits),
	.tx(tx),
	.tx_complete(tx_complete)
);


always #5ns clk <= ~ clk;

initial begin

	$dumpfile("./test/uart2.vcd");
	$dumpvars();

	clk <= 0;
	rst <= 1;
	data_ready <= 0;
	bit_duration <= bit_duration_ctr;
	stopbits <= 2'b01; // configuring 1 stopbit
	data <= 8'b01110010;

	#(1ns * bit_duration_ns)
	rst <= 0;

	#100ns
	data_ready <= 1;

	#(20ns)
	data_ready <= 0;

	#(1ns * bit_duration_ns * 20)
	$finish;
end

endmodule