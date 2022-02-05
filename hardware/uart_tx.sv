module uart_tx(
	input clk, rst, data_ready,
	input [15:0] bit_duration,
	input [7:0] data,
	input [1:0] stopbits,
	output reg tx, tx_complete
);

parameter STATE_IDLE = 2'b00;
parameter STATE_STARTBIT = 2'b01;
parameter STATE_DATABITS = 2'b10;
parameter STATE_STOPBITS = 2'b11;

reg [7:0] txdata;
reg stopbit_state;
reg [3:0] bit_ctr;
reg [1:0] cur_state;
reg [15:0] ctr;

wire dbg_tx = (ctr == bit_duration);

always @ (posedge clk)
	if(rst) begin
		tx <= 1;
		ctr <= 0;
		stopbit_state <= 0;
		tx_complete <= 0;
		cur_state <= STATE_IDLE;
		txdata <= 0;
		bit_ctr <= 0;
	end else begin
		ctr <= ctr + 1;
		case(cur_state)
			STATE_IDLE: begin
				tx <= 1;
				tx_complete <= 0;
				ctr <= 0;
				bit_ctr <= 0;
				stopbit_state <= 0;
				if(data_ready) begin
					txdata <= data;
					cur_state <= STATE_STARTBIT;
				end
			end
			STATE_STARTBIT: begin
				tx <= 0;
				if(ctr == bit_duration) begin
					ctr <= 0;
					cur_state <= STATE_DATABITS;
				end
			end
			STATE_DATABITS: begin

				// write current payload bit to output
				tx <= txdata[bit_ctr];


				if(ctr == bit_duration) begin
					ctr <= 0;

					if(bit_ctr == 7) begin
						bit_ctr <= 0;
						cur_state <= STATE_STOPBITS;
					end else begin
						bit_ctr <= bit_ctr + 1;
					end
				end
			end
			STATE_STOPBITS: begin
				case (stopbits)
					2'b00: begin
						if(ctr == bit_duration >> 1) begin
							tx_complete <= 1;
							ctr <= 0;
							cur_state <= STATE_IDLE;
						end
					end
					2'b01: begin
						if(ctr == bit_duration) begin
							tx_complete <= 1;
							ctr <= 0;
							cur_state <= STATE_IDLE;
						end
					end
					2'b10: begin
						if((ctr == bit_duration >> 1) && (~stopbit_state)) begin // first 0.5 of 1.5 stopbits is done
							stopbit_state <= 1;
							ctr <= 0;
						end

						// This will only be reached on second attempt
						if(ctr == bit_duration) begin
							tx_complete <= 1;
							ctr <= 0;
							cur_state <= STATE_IDLE;
							stopbit_state <= 0;
						end
					end
					2'b11: begin
						if(ctr == bit_duration) begin // first 0.5 of 1.5 stopbits is done
							stopbit_state <= 1;
							ctr <= 0;
						end

						// This will only be reached on second attempt
						if(ctr == bit_duration && stopbit_state) begin
							tx_complete <= 1;
							ctr <= 0;
							cur_state <= STATE_IDLE;
							stopbit_state <= 0;
						end
					end
				endcase
			end
		endcase
	end
endmodule