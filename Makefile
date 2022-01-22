install:
	mkdir -p ./test/

timer:
	iverilog -o ./test/timer ./hardware/timer_tb.sv
	vvp ./test/timer

clean:
	rm -rf ./test/timer
	rm -rf ./test/timer.vcd