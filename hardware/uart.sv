`include "./hardware/uart_rx.sv"
`include "./hardware/uart_tx.sv"

module uart(
	input rst, clk,

	input [15:0] baudrate,
	input [1:0] stopbits,
 
	input rx, rxe,
	output [7:0] rx_data,
	output rx_complete,

	input [7:0] tx_data,
	input tx_rdy, txe,
	output tx, tx_complete
);

// RX and TX can be disabled individually (or both through rst signal)
wire rst_tx = rst | ~txe;
wire rst_rx = rst | ~rxe;

uart_tx transmitter(
	.clk(clk),
	.rst(rst_tx),
	.tx(tx),
	.bit_duration(baudrate),
	.stopbits(stopbits),
	.data_ready(tx_rdy),
	.tx_complete(tx_complete),
	.data(tx_data)
);

uart_rx receiver(
	.clk(clk),
	.rst(rst_rx),
	.rx(rx),
	.data(rx_data),
	.bit_duration(baudrate),
	.start_bit_duration(baudrate >> 1),
	.stopbits(stopbits),
	.data_ready(rx_complete)
);

endmodule