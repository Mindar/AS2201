`timescale 1ns/1ps
`include "./hardware/uart.sv"

module uart_tb;


// Change this to set baudrate
int unsigned baudrate = 115200;

int unsigned nanosecondsPerSec = 1000000000;
real delay_time_f = real'(nanosecondsPerSec) / real'(baudrate);
int unsigned delay_time = $ceil(delay_time_f);


int unsigned test_clk_period = 10; // ns/clk
int unsigned bit_duration_ns = delay_time; // ns/bit
int unsigned bit_duration_ctr = bit_duration_ns / test_clk_period; // clk/bit


reg clk, rst;


reg tx_rdy;
reg [7:0] tx_data;

wire loopback;
wire rx_complete, tx_complete;
wire [7:0] rx_data;

uart my_uart(.clk(clk), .rst(rst), .rx(loopback), .tx(loopback), .txe(1'b1), .rxe(1'b1), .baudrate(bit_duration_ctr[15:0]), .tx_data(tx_data), .rx_data(rx_data), .stopbits(2'b01), .tx_complete(tx_complete), .rx_complete(rx_complete), .tx_rdy(tx_rdy));

initial begin
	// Dump uart transmission to file
	$dumpfile("./test/uart3.vcd");
	$dumpvars();

	clk <= 0;
	rst <= 1;
	tx_data <= 8'b11001010;
	tx_rdy <= 0;

	#20

	rst <= 0;

	#10
	tx_rdy <= 1;
	#10

	tx_rdy <= 0;

	#(20ns * bit_duration_ns)

	tx_data <= 8'hA5;

	#10
	tx_rdy <= 1;
	#10

	#(300 * bit_duration_ctr)

	$finish;
end

always #5 clk <= ~clk;

endmodule