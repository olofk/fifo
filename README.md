fifo
====

A FuseSoC-compatible library of FIFO implementations

RTL code
--------

The following RTL components exist in the library

### rtl/verilog/fifo.v

A generic FIFO implementation

### rtl/verilog/fifo_fwft_adapter.v

A module to place on the output of any FIFO to turn it into a FWFT FIFO

### rtl/verilog/fifo_fwft.v

FIFO with FWFT (First word fall-through)

### rtl/verilog/dual_clock_fifo.v

A generic asynchronous FIFO

### rtl/verilog/simple_dpram_sclk.v

A generic Dual Port RAM used as backend in fifo.v

### rtl/verilog/xilinx_fifoe1.v

Wrapper with proper reset handling for the FIFOE1 macros found in some Xilinx
FPGA families such as Virtex-5, Virtex-6 and all 7-series devices.

### data/fifo.sdc

Timing constraints file for Quartus with rules for the dual clock FIFO.
To use the constraints, include the file in your project and call
`dual_clock_fifo_false_paths path/to/fifo/instance` from your main constraints
file for each instance of the dual clock FIFO

Testing
-------

All components have FuseSoC support and can be run with multiple simulators and configurations.

To find all compile/run -time options run `fusesoc sim fifo --help`

To specify which simulator to use, add `--sim=<simulator>` after the `sim` argument, where `<simulator>`
can be any FuseSoC-supported event-based verilog simulator (i.e. icarus, isim, modelsim, rivierapro, xsim).

Add the FIFO library to your FuseSoC library path and run

### dual clock FIFO testbench

`fusesoc sim --testbench=dual_clock_fifo_tb fifo`

### FWFT FIFO

`fusesoc sim --testbench=fwft_fifo_tb fifo`

### FIFO

`fusesoc sim --testbench=fifo_tb fifo`

### Xilinx FIFOE1

`fusesoc sim xilinx_fifoe1`

Note that this testbench requires the `$XILINX_VIVADO` environment variable to be set and only runs on XSim bundled with Vivado
