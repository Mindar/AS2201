module uart_rx(
	input clk, rst, rx_enable, rx_line,
	output [7:0] data,
	output data_ready, rx_buf_full
);

reg rx_tmp, rx;

// TODO: sample rx line and apply low pass filter (n consecutive, identical samples are considered a valid state change )

always @ (posedge clk) begin
	
	// Double flopping rx to prevent metastability
	rx_tmp <= rx_line;
	rx <= rx_tmp;

	if (rst | !rx_enable) begin
		data <= 0;
		data_ready <= 0;
	end else begin
		// rx state machine here
		case(cur_state):
			default: cur_state <= STATE_IDLE;
			STATE_RECEIVE_START: begin
				if(rx == 0) begin // TODO: instead of just checking rx== 0, it should be checked if rx was 0 for more than START_BIT_MIN_FILTER cycles
					// start bit received
					// wait until counter reaches START_BIT_PERIOD, then set state to STATE_START
				end
			end
			STATE_START: begin
				// rx was low for long enough to count as uart start bit, now we wait for the START_BIT_LENGTH + half baud length, then go to STATE_RECEIVE_DATA
			end
			STATE_RECEIVE_DATA: begin
				// wait for half a bit period (half baud period), then sample first bit, then wait 1 period, sample second bit, ...
			end
					
	end
end
   
endmodule