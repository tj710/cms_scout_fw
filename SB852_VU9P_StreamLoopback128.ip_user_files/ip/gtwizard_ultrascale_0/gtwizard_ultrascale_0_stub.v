// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Fri Feb 14 17:56:56 2020
// Host        : daqlab40-skylake16 running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0/gtwizard_ultrascale_0_stub.v
// Design      : gtwizard_ultrascale_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu9p-flgb2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "gtwizard_ultrascale_0_gtwizard_top,Vivado 2019.2" *)
module gtwizard_ultrascale_0(gtwiz_userclk_tx_active_in, 
  gtwiz_userclk_rx_active_in, gtwiz_reset_clk_freerun_in, gtwiz_reset_all_in, 
  gtwiz_reset_tx_pll_and_datapath_in, gtwiz_reset_tx_datapath_in, 
  gtwiz_reset_rx_pll_and_datapath_in, gtwiz_reset_rx_datapath_in, 
  gtwiz_reset_rx_cdr_stable_out, gtwiz_reset_tx_done_out, gtwiz_reset_rx_done_out, 
  gtwiz_userdata_tx_in, gtwiz_userdata_rx_out, gtrefclk00_in, qpll0outclk_out, 
  qpll0outrefclk_out, gtyrxn_in, gtyrxp_in, rx8b10ben_in, rxusrclk_in, rxusrclk2_in, 
  tx8b10ben_in, txctrl0_in, txctrl1_in, txctrl2_in, txusrclk_in, txusrclk2_in, gtpowergood_out, 
  gtytxn_out, gtytxp_out, rxctrl0_out, rxctrl1_out, rxctrl2_out, rxctrl3_out, rxoutclk_out, 
  rxpmaresetdone_out, txoutclk_out, txpmaresetdone_out)
/* synthesis syn_black_box black_box_pad_pin="gtwiz_userclk_tx_active_in[0:0],gtwiz_userclk_rx_active_in[0:0],gtwiz_reset_clk_freerun_in[0:0],gtwiz_reset_all_in[0:0],gtwiz_reset_tx_pll_and_datapath_in[0:0],gtwiz_reset_tx_datapath_in[0:0],gtwiz_reset_rx_pll_and_datapath_in[0:0],gtwiz_reset_rx_datapath_in[0:0],gtwiz_reset_rx_cdr_stable_out[0:0],gtwiz_reset_tx_done_out[0:0],gtwiz_reset_rx_done_out[0:0],gtwiz_userdata_tx_in[255:0],gtwiz_userdata_rx_out[255:0],gtrefclk00_in[1:0],qpll0outclk_out[1:0],qpll0outrefclk_out[1:0],gtyrxn_in[7:0],gtyrxp_in[7:0],rx8b10ben_in[7:0],rxusrclk_in[7:0],rxusrclk2_in[7:0],tx8b10ben_in[7:0],txctrl0_in[127:0],txctrl1_in[127:0],txctrl2_in[63:0],txusrclk_in[7:0],txusrclk2_in[7:0],gtpowergood_out[7:0],gtytxn_out[7:0],gtytxp_out[7:0],rxctrl0_out[127:0],rxctrl1_out[127:0],rxctrl2_out[63:0],rxctrl3_out[63:0],rxoutclk_out[7:0],rxpmaresetdone_out[7:0],txoutclk_out[7:0],txpmaresetdone_out[7:0]" */;
  input [0:0]gtwiz_userclk_tx_active_in;
  input [0:0]gtwiz_userclk_rx_active_in;
  input [0:0]gtwiz_reset_clk_freerun_in;
  input [0:0]gtwiz_reset_all_in;
  input [0:0]gtwiz_reset_tx_pll_and_datapath_in;
  input [0:0]gtwiz_reset_tx_datapath_in;
  input [0:0]gtwiz_reset_rx_pll_and_datapath_in;
  input [0:0]gtwiz_reset_rx_datapath_in;
  output [0:0]gtwiz_reset_rx_cdr_stable_out;
  output [0:0]gtwiz_reset_tx_done_out;
  output [0:0]gtwiz_reset_rx_done_out;
  input [255:0]gtwiz_userdata_tx_in;
  output [255:0]gtwiz_userdata_rx_out;
  input [1:0]gtrefclk00_in;
  output [1:0]qpll0outclk_out;
  output [1:0]qpll0outrefclk_out;
  input [7:0]gtyrxn_in;
  input [7:0]gtyrxp_in;
  input [7:0]rx8b10ben_in;
  input [7:0]rxusrclk_in;
  input [7:0]rxusrclk2_in;
  input [7:0]tx8b10ben_in;
  input [127:0]txctrl0_in;
  input [127:0]txctrl1_in;
  input [63:0]txctrl2_in;
  input [7:0]txusrclk_in;
  input [7:0]txusrclk2_in;
  output [7:0]gtpowergood_out;
  output [7:0]gtytxn_out;
  output [7:0]gtytxp_out;
  output [127:0]rxctrl0_out;
  output [127:0]rxctrl1_out;
  output [63:0]rxctrl2_out;
  output [63:0]rxctrl3_out;
  output [7:0]rxoutclk_out;
  output [7:0]rxpmaresetdone_out;
  output [7:0]txoutclk_out;
  output [7:0]txpmaresetdone_out;
endmodule
