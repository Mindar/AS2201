timer:
	iverilog -g2012 -o ./test/timer ./hardware/timer_tb.sv
	vvp ./test/timer

pwm:
	iverilog -g2012 -o ./test/pwm ./hardware/pwm_tb.sv
	vvp ./test/pwm

pwm2:
	iverilog -g2012 -o ./test/pwm2 ./hardware/pwm_controller_tb.sv
	vvp ./test/pwm2

uart_rx_1:
	iverilog -g2012 -o ./test/uart_rx_1 ./hardware/uart_rx_tb.sv
	vvp ./test/uart_rx_1

clean:
	rm -rf ./test/timer
	rm -rf ./test/timer.vcd
	rm -rf ./test/pwm
	rm -rf ./test/pwmtest.vcd
	rm -rf ./test/pwm2
	rm -rf ./test/pwmtest2.vcd
	rm -rf ./test/uart_rx_1
	rm -rf ./test/uart_rx_1.vcd