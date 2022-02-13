module uart_rx(
	input clk, rst, rx,
	input [15:0] bit_duration, start_bit_duration,
	input [1:0] stopbits,
	output reg [7:0] data,
	output reg data_ready
);

reg [3:0] rx_shift_reg;
reg [16:0] ctr; // larger than bit_duration to prevent overflows during internal calculations
reg [4:0] bit_ctr;
reg [1:0] cur_state;




// States for uart statemachine
parameter STATE_IDLE = 2'b00;
parameter STATE_RECEIVE_START = 2'b01;
parameter STATE_READ_DATA = 2'b10;
parameter STATE_STOPBITS = 2'b11;

always @ (posedge clk) begin

	if(rst) begin
		// set internal registers to 0
		ctr <= 0;
		rx_shift_reg <= 0;
		bit_ctr <= 0;

		// set outputs to 0
		data <= 0;
		data_ready <= 0;
		cur_state <= STATE_IDLE;
	end else begin
		
		// Shift register of past rx values for filtering etc
		rx_shift_reg <= {rx, rx_shift_reg[3:1]};
		ctr <= ctr + 1;
	
		// rx state machine here
		case(cur_state)
			default: cur_state <= STATE_IDLE;
			STATE_IDLE: begin
				// check for falling edge with some basic filtering
				if((rx_shift_reg == 4'b0001) || (rx_shift_reg == 4'b0010)) begin
					cur_state <= STATE_RECEIVE_START;
				end

				ctr <= 4;
				data_ready <= 0;
				bit_ctr <= 0;
				data <= 0;
			end
			STATE_RECEIVE_START: begin
				if(rx != 0 && ctr < start_bit_duration) begin 
					// rx went back high again, this wasn't a valid stop bit.
					// reset to idle state
					cur_state <= STATE_IDLE;
					ctr <= 0;
				end

				// Check if start bit is over, if yes, move to next state
				if(ctr == bit_duration) begin
					ctr <= 0;
					cur_state <= STATE_READ_DATA;
				end
			end
			STATE_READ_DATA: begin
				if(ctr == bit_duration >> 1) begin
					// we're in the middle of the bit, this is the point where we want to read the bit

					// increment the bit counter
					bit_ctr <= bit_ctr + 1;

					// shift in the bit that was read
					data <= {rx, data[7:1]}; 
				end

				if(ctr == bit_duration) begin
					// at this point the current bit was read, we can either read the next data bit or the stop bit(s)
					// either way, the counter needs to reset to 0
					ctr <= 0;

					// we have read all 8 databits, read stop bit next
					if(bit_ctr == 8) begin
						cur_state <= STATE_STOPBITS;
					end
				end
			end
			STATE_STOPBITS: begin
				// Count to stop bit duration, then reset state to idle
				if((stopbits == 2'b00) && (ctr == bit_duration >> 1)) begin // 0.5 stop bits
					data_ready <= 1;
					cur_state <= STATE_IDLE;
				end else if ((stopbits == 2'b01) && (ctr == bit_duration)) begin // 1 stop bit
					data_ready <= 1;
					cur_state <= STATE_IDLE;
				end else if ((stopbits == 2'b10) && (ctr == {1'b0,bit_duration[15:0]} + bit_duration >> 1)) begin
					// this condition adds half of bit_duration to bit_duration in a 17-bit wide register to get 1.5x bit_duration
					data_ready <= 1;
					cur_state <= STATE_IDLE;
				end else if(ctr[15:1] == bit_duration) begin // functionally equivalent to left shift of bit_duration
					data_ready <= 1;
					cur_state <= STATE_IDLE;
				end
			end
		endcase
	end
end
   
endmodule