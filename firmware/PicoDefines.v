// PicoDefines.v - here we configure the base firmware for our project

// This includes a placeholder "user" module that you will replace with your code.
// To use your own module, just change the name from PicoBus128_counter to your
//   module's name, and then add the file to your ISE project.
`define USER_MODULE_NAME scout_top
`define XILINX_FPGA
`define XILINX_ULTRASCALE
`define XILINX_ULTRASCALE_PLUS
`define PCIE_GEN3X8

`define ENABLE_QSPI_FLASH
`define STREAM1_IN_WIDTH 128
`define STREAM1_OUT_WIDTH 128

// We define the type of FPGA and card we're using.
`define PICO_MODEL_SB852
`define PICO_FPGA_VU9P

`include "BasePicoDefines.v"

