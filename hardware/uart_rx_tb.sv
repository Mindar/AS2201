`timescale 1ns/1ps
`include "./hardware/uart_rx.sv"

module uart_rx_tb;

// Change this to set baudrate
int unsigned baudrate = 115200;


reg [7 : 0] cmdchar;
int testfile, c;

reg uart_tx_test;

int unsigned nanosecondsPerSec = 1000000000;
real delay_time_f = real'(nanosecondsPerSec) / real'(baudrate);
int unsigned delay_time = $ceil(delay_time_f);


int unsigned test_clk_period = 10; // ns/clk
int unsigned bit_duration_ns = delay_time; // ns/bit
int unsigned bit_duration_ctr = bit_duration_ns / test_clk_period; // clk/bit

reg clk, rst;
wire data_ready;
wire [15:0] bit_duration;
wire [1:0] stopbits;
wire [7:0] data;


uart_rx my_uart(.clk(clk), .rst(rst), .rx(uart_tx_test), .data_ready(data_ready), .bit_duration(bit_duration_ctr[15:0]), .start_bit_duration(bit_duration_ctr[15:0]), .stopbits(stopbits), .data(data));

initial begin
	// Dump uart transmission to file
	$dumpfile("./test/uart1.vcd");
	$dumpvars();

	// Load test data from file
	$display("Loading file");
	testfile = $fopenr("./testdata/uart_rx.txt");


	$display("nsPs %d", nanosecondsPerSec);
	$display("delay_time_f %f", delay_time_f);
	$display("delay_time %d", delay_time);
	$display("clocks per bit %d", bit_duration_ctr);

	if (testfile == 0) begin
		$display("Error when loading file.");
		$finish;
	end

	$display();


	// Default value for uart tx is X
	//uart_tx_test <= 1'dx;
	uart_tx_test <= 1'd1;
	#(2ns * delay_time);

	// Send each command
	while (!$feof(testfile)) begin
		c = $fgets(cmdchar, testfile);

		if(cmdchar == "\n") begin
			$display("END OF COMMAND");
		end else begin
			$display("cmd output: '%c'", cmdchar);
			
			// send start bit
			uart_tx_test <= 0;
			#(1ns * delay_time);

			// send data bits
			for(int i = 0; i < 8; i = i + 1) begin
				uart_tx_test <= cmdchar[i];
				#(1ns * delay_time);
			end

			// send stop bit
			uart_tx_test <= 1;
			#(2ns * delay_time);

			// set tx to X to make uart frame bounds easily visible in gtkwave
			//uart_tx_test <= 1'dx;
			uart_tx_test <= 1'd1;
			#(3ns * delay_time);

			$display("uart data sent");
		end
	end

	$fclose(testfile);

	#(10ns * delay_time);

	$finish;
end


initial begin
	clk <= 0;
end

initial begin
	rst <= 1;

	#10ns
	rst <= 0;
end

always #5 clk <= ~clk;

endmodule