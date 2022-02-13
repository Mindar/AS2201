`include "./hardware/bcd_encoder.sv"

module bcd_encoder_tb;

reg clk, rst, beg, done;

reg[15:0] bin_in;
wire [15:0] bcd_out;

bcd_encoder enc(
	.i_rst(rst),
	.i_clk(clk),
	.i_begin_conv(beg),
	.i_binary(bin_in),
	.o_conv_done(done),
	.o_bcd(bcd_out)
);

initial begin
	bin_in <= 16'd218;
	beg <= 0;

	#30
	beg <= 1;
	rst <= 0;

	#1000
	$finish;
end


initial begin
	$dumpfile("./test/bcd.vcd");
	$dumpvars();
	clk <= 0;
	rst <= 1;
end

always #5 clk <= ~clk;


endmodule