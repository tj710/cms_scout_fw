// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Wed Feb 19 18:59:10 2020
// Host        : daqlab40-skylake16 running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/aligner_fifo/aligner_fifo_stub.v
// Design      : aligner_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu9p-flgb2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2019.2" *)
module aligner_fifo(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty, almost_empty, prog_empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[32:0],wr_en,rd_en,dout[32:0],full,empty,almost_empty,prog_empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [32:0]din;
  input wr_en;
  input rd_en;
  output [32:0]dout;
  output full;
  output empty;
  output almost_empty;
  output prog_empty;
endmodule
