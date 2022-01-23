module pwm
#(parameter BITS = 4)
(
	input [BITS - 1 : 0] counter,
	input [BITS - 1 : 0] pwm_set,
	output wire out
);

assign out = counter < pwm_set;


endmodule