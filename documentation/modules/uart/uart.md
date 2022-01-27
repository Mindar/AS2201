# UART
The UART consists of 2 important modules, the RX (receiver) and TX (transmitter) module. Either of these can be used independent of the other, allowing to implement RX-only, TX-only as well as RX+TX-UARTs.

## RX Testbench
The receiver testbench reads data from a file, then sends out the corresponding bit-sequence at the correct timing for the specified baudrate.
