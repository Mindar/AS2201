module pwm_controller #(parameter CHANNELS = 3, parameter BITS = 16) (
	input clk, rst,
	input [BITS - 1 : 0] counter,
	input [CHANNELS - 1 : 0] channel_enable,
	input  [BITS - 1 : 0] set_values [CHANNELS - 1 : 0],
	output wire [CHANNELS - 1 : 0] outputs
);

for(genvar i = 0; i < CHANNELS; i = i + 1) begin
	wire out_tmp;

	pwm #(.BITS(BITS)) channel(.counter(counter), .pwm_set(set_values[i]), .out(out_tmp));

	assign outputs[i] = channel_enable[i] ? out_tmp : 1'dz;
end

endmodule