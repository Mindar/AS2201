module bcd_encoder (
	input i_clk, i_rst,
	input i_begin_conv,
	input [15:0] i_binary,
	output reg o_conv_done,
	output reg [15:0] o_bcd
);

reg [4:0] conv_ctr;
reg [15:0] i_convreg;

// hexed_values always contains the correct bits for the next left shift
// Notably, any time a BCD digit should overflow in the next shift (i.e. whenever
// any bcd digit is > 4), +3 will be added. This ensures correct overflow
// into the next bcd digit, while maintaining the correct value for the
// overflowing digit.
wire [16:0] hexed_values;

// the first digit of hexed_values is always the MSB of the input
// the remaining 16 digits contain the correctly modified output data but still without the shifting
assign hexed_values[0]     = i_convreg[15];
assign hexed_values[4:1]   = (o_bcd[3:0] > 4)   ? {o_bcd[3:0] + 4'd3}   :  {o_bcd[3:0]};
assign hexed_values[8:5]   = (o_bcd[7:4] > 4)   ? {o_bcd[7:4] + 4'd3}   :  {o_bcd[7:4]};
assign hexed_values[12:9]  = (o_bcd[11:8] > 4)  ? {o_bcd[11:8] + 4'd3}  :  {o_bcd[11:8]};
assign hexed_values[16:13] = (o_bcd[15:12] > 4) ? {o_bcd[15:12] + 4'd3} :  {o_bcd[15:12]};


always_ff @(posedge i_clk) begin
	if(i_rst) begin
		o_conv_done <= 1;
		o_bcd <= 16'b0;
		i_convreg <= 16'b0;
		conv_ctr <= 0;
	end else begin
		if(conv_ctr == 0 && i_begin_conv && o_conv_done) begin
			// start of conversion
			// store i_binary in internal register and begin converting it
			i_convreg <= i_binary;
			o_conv_done <= 0;
			o_bcd <= 16'b0;
		end else if (!o_conv_done && conv_ctr < 16) begin
			// conversion has started, but isn't completed, increment bit counter
			conv_ctr <= conv_ctr + 1;

			// values are shifted from i_convreg to output in o_bcd_digits
			i_convreg[15:0] = {i_convreg[14:0], 1'b0};

			// o_bcd always contains current state of conversion
			// here the shift is introduced
			o_bcd[15:0] <= hexed_values[15:0];

			if(conv_ctr == 15) begin
				o_conv_done <= 1;
			end
		end
	end
end

endmodule