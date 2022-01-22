module timer #(parameter BITS = 4)(
	input rst, pulse,
	input count_dir,
	input count_mode,
	input [BITS - 1 : 0] reload_value,
	output reg [BITS - 1 : 0] counter
);

reg updown_dir;

// count mode = 1 means up counting OR down counting mode (depending on externally supplied direction)
// count mode = 0 means up AND down counting mode
wire dir = count_mode ? count_dir : updown_dir;

always @(posedge pulse) begin
	if(rst) begin
		counter <= 0;
		updown_dir <= 1;
	end else begin
		// Check if either end of count was reached
		if (dir && counter == reload_value) begin
			// we reached the maximum counter value, we don't want to count up any further

			// check if we should reset to max or flip direction
			if(count_mode) begin
				counter <= 0;
			end else begin
				counter = counter - 1;
				updown_dir <= ~updown_dir;
			end
		end else if (!dir && counter == 0) begin
			// we reached the minimum counter value, we don't want to count down any further

			// check if we should reset to max or flip direction
			if(count_mode) begin
				counter <= reload_value;
			end else begin
				counter = counter + 1;
				updown_dir <= ~updown_dir;
			end
		end else begin
			// we're not at either end yet, so just keep on counting
			if(dir)
				counter <= counter + 1;
			else
				counter <= counter - 1;
		end
	end
end

endmodule