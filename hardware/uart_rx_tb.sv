`timescale 1ns/1ps

module uart_rx_tb;

// Change this to set baudrate
int unsigned baudrate = 115200;


reg [7 : 0] cmdchar;
int testfile, c;

reg uart_tx_test;

int unsigned nanosecondsPerSec = 1000000000;
real delay_time_f = real'(nanosecondsPerSec) / real'(baudrate);
int unsigned delay_time = $ceil(delay_time_f);

initial begin
	// Dump uart transmission to file
	$dumpfile("./test/uart1.vcd");
	$dumpvars();

	// Load test data from file
	$display("Loading file");
	testfile = $fopenr("uart_rx.txt");


	$display("nsPs %d", nanosecondsPerSec);
	$display("delay_time_f %f", delay_time_f);
	$display("delay_time %d", delay_time);

	if (testfile == 0) begin
		$display("Error when loading file.");
		$finish;
	end

	$display();


	// Default value for uart tx is X
	uart_tx_test <= 1'dx;
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
			uart_tx_test <= 1'dx;
			#(3ns * delay_time);

			$display("uart data sent");
		end
	end

	$fclose(testfile);
end

endmodule