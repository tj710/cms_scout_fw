vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -sv "+incdir+../../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/hdl/verilog" "+incdir+../../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/hdl" \
"/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/hdl/verilog" "+incdir+../../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/hdl" \
"../../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/sim/gtwizard_ultrascale_0_vio_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

