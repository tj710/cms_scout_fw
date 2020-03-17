-makelib ies_lib/xpm -sv \
  "/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/home/opt/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0_vio_0/sim/gtwizard_ultrascale_0_vio_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

