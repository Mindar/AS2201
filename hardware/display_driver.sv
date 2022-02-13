`include "./hardware/pwm.sv"
`include "./hardware/timer.sv"

module display_driver(
	input rst, clk,
	input [31:0] display_data,
	input [1:0] brightness,
	input [15:0] pwm_period,
	output reg [6:0] segment_pins,
	output reg [3:0] digit_pins
);

wire [15:0] timer_value;
wire [15:0] duty_cycle = pwm_period >> (3 - brightness);

timer #(.BITS(16)) pwmtimer(
	.rst(rst),
	.pulse(clk),
	.count_dir(1'b1),
	.count_mode(1'b1),
	.reload_value(pwm_period),
	.counter(timer_value)
);

pwm #(.BITS(16)) pwm_comp(
	.counter(timer_value),
	.pwm_set(duty_cycle + 16'b1),
	.out(enable_digit)
);

wire digit_enable_zero_fix = enable_digit && (brightness != 2'b00);

reg [1:0] active_digit;

wire [6:0] segments1 = display_data[30:24];
wire [6:0] segments2 = display_data[22:16];
wire [6:0] segments3 = display_data[14:8];
wire [6:0] segments4 = display_data[6:0];

always @ (posedge clk) begin
	if(rst) begin
		digit_pins <= 0;
		segment_pins <= 0;
		active_digit <= 0;
	end else begin

		// Output correct data depending on which digit is active
		if(active_digit == 2'b00)
			segment_pins <= segments1;
		else if(active_digit == 2'b01)
			segment_pins <= segments2;
		else if(active_digit == 2'b10)
			segment_pins <= segments3;
		else
			segment_pins <= segments4;


		// Digit pins are PWM modulated
		digit_pins <= digit_enable_zero_fix ? 4'b0000 | (1'b1 << active_digit) : 0;

		// move on to next digit if timer hits max
		if(timer_value == pwm_period) begin
			active_digit <= active_digit + 1;
		end
	end
end
endmodule