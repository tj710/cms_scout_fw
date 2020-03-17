//------------------------------------------------------------------------------
//  (c) Copyright 2013-2018 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------


`timescale 1ps/1ps

// =====================================================================================================================
// This example design top module instantiates the example design wrapper; slices vectored ports for per-channel
// assignment; and instantiates example resources such as buffers, pattern generators, and pattern checkers for core
// demonstration purposes
// =====================================================================================================================

module gtwizard_ultrascale_0_example_top (

  // Differential reference clock inputs
  input  wire mgtrefclk0_x0y2_p,
  input  wire mgtrefclk0_x0y2_n,
  input  wire mgtrefclk0_x0y4_p,
  input  wire mgtrefclk0_x0y4_n,

  // Serial data ports for transceiver channel 0
  input  wire ch0_gtyrxn_in,
  input  wire ch0_gtyrxp_in,
  output wire ch0_gtytxn_out,
  output wire ch0_gtytxp_out,

  // Serial data ports for transceiver channel 1
  input  wire ch1_gtyrxn_in,
  input  wire ch1_gtyrxp_in,
  output wire ch1_gtytxn_out,
  output wire ch1_gtytxp_out,

  // Serial data ports for transceiver channel 2
  input  wire ch2_gtyrxn_in,
  input  wire ch2_gtyrxp_in,
  output wire ch2_gtytxn_out,
  output wire ch2_gtytxp_out,

  // Serial data ports for transceiver channel 3
  input  wire ch3_gtyrxn_in,
  input  wire ch3_gtyrxp_in,
  output wire ch3_gtytxn_out,
  output wire ch3_gtytxp_out,

  // Serial data ports for transceiver channel 4
  input  wire ch4_gtyrxn_in,
  input  wire ch4_gtyrxp_in,
  output wire ch4_gtytxn_out,
  output wire ch4_gtytxp_out,

  // Serial data ports for transceiver channel 5
  input  wire ch5_gtyrxn_in,
  input  wire ch5_gtyrxp_in,
  output wire ch5_gtytxn_out,
  output wire ch5_gtytxp_out,

  // Serial data ports for transceiver channel 6
  input  wire ch6_gtyrxn_in,
  input  wire ch6_gtyrxp_in,
  output wire ch6_gtytxn_out,
  output wire ch6_gtytxp_out,

  // Serial data ports for transceiver channel 7
  input  wire ch7_gtyrxn_in,
  input  wire ch7_gtyrxp_in,
  output wire ch7_gtytxn_out,
  output wire ch7_gtytxp_out,

  // User-provided ports for reset helper block(s)
  input  wire hb_gtwiz_reset_clk_freerun_in,
  input  wire hb_gtwiz_reset_all_in,

  // PRBS-based link status ports
  input  wire link_down_latched_reset_in,
  output wire link_status_out,
  output reg  link_down_latched_out = 1'b1

);


  // ===================================================================================================================
  // PER-CHANNEL SIGNAL ASSIGNMENTS
  // ===================================================================================================================

  // The core and example design wrapper vectorize ports across all enabled transceiver channel and common instances for
  // simplicity and compactness. This example design top module assigns slices of each vector to individual, per-channel
  // signal vectors for use if desired. Signals which connect to helper blocks are prefixed "hb#", signals which connect
  // to transceiver common primitives are prefixed "cm#", and signals which connect to transceiver channel primitives
  // are prefixed "ch#", where "#" is the sequential resource number.

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] gtyrxn_int;
  assign gtyrxn_int[0:0] = ch0_gtyrxn_in;
  assign gtyrxn_int[1:1] = ch1_gtyrxn_in;
  assign gtyrxn_int[2:2] = ch2_gtyrxn_in;
  assign gtyrxn_int[3:3] = ch3_gtyrxn_in;
  assign gtyrxn_int[4:4] = ch4_gtyrxn_in;
  assign gtyrxn_int[5:5] = ch5_gtyrxn_in;
  assign gtyrxn_int[6:6] = ch6_gtyrxn_in;
  assign gtyrxn_int[7:7] = ch7_gtyrxn_in;

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] gtyrxp_int;
  assign gtyrxp_int[0:0] = ch0_gtyrxp_in;
  assign gtyrxp_int[1:1] = ch1_gtyrxp_in;
  assign gtyrxp_int[2:2] = ch2_gtyrxp_in;
  assign gtyrxp_int[3:3] = ch3_gtyrxp_in;
  assign gtyrxp_int[4:4] = ch4_gtyrxp_in;
  assign gtyrxp_int[5:5] = ch5_gtyrxp_in;
  assign gtyrxp_int[6:6] = ch6_gtyrxp_in;
  assign gtyrxp_int[7:7] = ch7_gtyrxp_in;

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] gtytxn_int;
  assign ch0_gtytxn_out = gtytxn_int[0:0];
  assign ch1_gtytxn_out = gtytxn_int[1:1];
  assign ch2_gtytxn_out = gtytxn_int[2:2];
  assign ch3_gtytxn_out = gtytxn_int[3:3];
  assign ch4_gtytxn_out = gtytxn_int[4:4];
  assign ch5_gtytxn_out = gtytxn_int[5:5];
  assign ch6_gtytxn_out = gtytxn_int[6:6];
  assign ch7_gtytxn_out = gtytxn_int[7:7];

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] gtytxp_int;
  assign ch0_gtytxp_out = gtytxp_int[0:0];
  assign ch1_gtytxp_out = gtytxp_int[1:1];
  assign ch2_gtytxp_out = gtytxp_int[2:2];
  assign ch3_gtytxp_out = gtytxp_int[3:3];
  assign ch4_gtytxp_out = gtytxp_int[4:4];
  assign ch5_gtytxp_out = gtytxp_int[5:5];
  assign ch6_gtytxp_out = gtytxp_int[6:6];
  assign ch7_gtytxp_out = gtytxp_int[7:7];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_tx_reset_int;
  wire [0:0] hb0_gtwiz_userclk_tx_reset_int;
  assign gtwiz_userclk_tx_reset_int[0:0] = hb0_gtwiz_userclk_tx_reset_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_tx_srcclk_int;
  wire [0:0] hb0_gtwiz_userclk_tx_srcclk_int;
  assign hb0_gtwiz_userclk_tx_srcclk_int = gtwiz_userclk_tx_srcclk_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_tx_usrclk_int;
  wire [0:0] hb0_gtwiz_userclk_tx_usrclk_int;
  assign hb0_gtwiz_userclk_tx_usrclk_int = gtwiz_userclk_tx_usrclk_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_tx_usrclk2_int;
  wire [0:0] hb0_gtwiz_userclk_tx_usrclk2_int;
  assign hb0_gtwiz_userclk_tx_usrclk2_int = gtwiz_userclk_tx_usrclk2_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_tx_active_int;
  wire [0:0] hb0_gtwiz_userclk_tx_active_int;
  assign hb0_gtwiz_userclk_tx_active_int = gtwiz_userclk_tx_active_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_rx_reset_int;
  wire [0:0] hb0_gtwiz_userclk_rx_reset_int;
  assign gtwiz_userclk_rx_reset_int[0:0] = hb0_gtwiz_userclk_rx_reset_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_rx_srcclk_int;
  wire [0:0] hb0_gtwiz_userclk_rx_srcclk_int;
  assign hb0_gtwiz_userclk_rx_srcclk_int = gtwiz_userclk_rx_srcclk_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_rx_usrclk_int;
  wire [0:0] hb0_gtwiz_userclk_rx_usrclk_int;
  assign hb0_gtwiz_userclk_rx_usrclk_int = gtwiz_userclk_rx_usrclk_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_rx_usrclk2_int;
  wire [0:0] hb0_gtwiz_userclk_rx_usrclk2_int;
  assign hb0_gtwiz_userclk_rx_usrclk2_int = gtwiz_userclk_rx_usrclk2_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_userclk_rx_active_int;
  wire [0:0] hb0_gtwiz_userclk_rx_active_int;
  assign hb0_gtwiz_userclk_rx_active_int = gtwiz_userclk_rx_active_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_clk_freerun_int;
  wire [0:0] hb0_gtwiz_reset_clk_freerun_int = 1'b0;
  assign gtwiz_reset_clk_freerun_int[0:0] = hb0_gtwiz_reset_clk_freerun_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_all_int;
  wire [0:0] hb0_gtwiz_reset_all_int = 1'b0;
  assign gtwiz_reset_all_int[0:0] = hb0_gtwiz_reset_all_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_tx_pll_and_datapath_int;
  wire [0:0] hb0_gtwiz_reset_tx_pll_and_datapath_int;
  assign gtwiz_reset_tx_pll_and_datapath_int[0:0] = hb0_gtwiz_reset_tx_pll_and_datapath_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_tx_datapath_int;
  wire [0:0] hb0_gtwiz_reset_tx_datapath_int;
  assign gtwiz_reset_tx_datapath_int[0:0] = hb0_gtwiz_reset_tx_datapath_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_rx_pll_and_datapath_int;
  wire [0:0] hb0_gtwiz_reset_rx_pll_and_datapath_int = 1'b0;
  assign gtwiz_reset_rx_pll_and_datapath_int[0:0] = hb0_gtwiz_reset_rx_pll_and_datapath_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_rx_datapath_int;
  wire [0:0] hb0_gtwiz_reset_rx_datapath_int = 1'b0;
  assign gtwiz_reset_rx_datapath_int[0:0] = hb0_gtwiz_reset_rx_datapath_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_rx_cdr_stable_int;
  wire [0:0] hb0_gtwiz_reset_rx_cdr_stable_int;
  assign hb0_gtwiz_reset_rx_cdr_stable_int = gtwiz_reset_rx_cdr_stable_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_tx_done_int;
  wire [0:0] hb0_gtwiz_reset_tx_done_int;
  assign hb0_gtwiz_reset_tx_done_int = gtwiz_reset_tx_done_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [0:0] gtwiz_reset_rx_done_int;
  wire [0:0] hb0_gtwiz_reset_rx_done_int;
  assign hb0_gtwiz_reset_rx_done_int = gtwiz_reset_rx_done_int[0:0];

  //--------------------------------------------------------------------------------------------------------------------
  wire [255:0] gtwiz_userdata_tx_int;
  wire [31:0] hb0_gtwiz_userdata_tx_int;
  wire [31:0] hb1_gtwiz_userdata_tx_int;
  wire [31:0] hb2_gtwiz_userdata_tx_int;
  wire [31:0] hb3_gtwiz_userdata_tx_int;
  wire [31:0] hb4_gtwiz_userdata_tx_int;
  wire [31:0] hb5_gtwiz_userdata_tx_int;
  wire [31:0] hb6_gtwiz_userdata_tx_int;
  wire [31:0] hb7_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[31:0] = hb0_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[63:32] = hb1_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[95:64] = hb2_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[127:96] = hb3_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[159:128] = hb4_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[191:160] = hb5_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[223:192] = hb6_gtwiz_userdata_tx_int;
  assign gtwiz_userdata_tx_int[255:224] = hb7_gtwiz_userdata_tx_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [255:0] gtwiz_userdata_rx_int;
  wire [31:0] hb0_gtwiz_userdata_rx_int;
  wire [31:0] hb1_gtwiz_userdata_rx_int;
  wire [31:0] hb2_gtwiz_userdata_rx_int;
  wire [31:0] hb3_gtwiz_userdata_rx_int;
  wire [31:0] hb4_gtwiz_userdata_rx_int;
  wire [31:0] hb5_gtwiz_userdata_rx_int;
  wire [31:0] hb6_gtwiz_userdata_rx_int;
  wire [31:0] hb7_gtwiz_userdata_rx_int;
  assign hb0_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[31:0];
  assign hb1_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[63:32];
  assign hb2_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[95:64];
  assign hb3_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[127:96];
  assign hb4_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[159:128];
  assign hb5_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[191:160];
  assign hb6_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[223:192];
  assign hb7_gtwiz_userdata_rx_int = gtwiz_userdata_rx_int[255:224];

  //--------------------------------------------------------------------------------------------------------------------
  wire [1:0] gtrefclk00_int;
  wire [0:0] cm0_gtrefclk00_int;
  wire [0:0] cm1_gtrefclk00_int;
  assign gtrefclk00_int[0:0] = cm0_gtrefclk00_int;
  assign gtrefclk00_int[1:1] = cm1_gtrefclk00_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [1:0] qpll0outclk_int;
  wire [0:0] cm0_qpll0outclk_int;
  wire [0:0] cm1_qpll0outclk_int;
  assign cm0_qpll0outclk_int = qpll0outclk_int[0:0];
  assign cm1_qpll0outclk_int = qpll0outclk_int[1:1];

  //--------------------------------------------------------------------------------------------------------------------
  wire [1:0] qpll0outrefclk_int;
  wire [0:0] cm0_qpll0outrefclk_int;
  wire [0:0] cm1_qpll0outrefclk_int;
  assign cm0_qpll0outrefclk_int = qpll0outrefclk_int[0:0];
  assign cm1_qpll0outrefclk_int = qpll0outrefclk_int[1:1];

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] rx8b10ben_int;
  wire [0:0] ch0_rx8b10ben_int = 1'b1;
  wire [0:0] ch1_rx8b10ben_int = 1'b1;
  wire [0:0] ch2_rx8b10ben_int = 1'b1;
  wire [0:0] ch3_rx8b10ben_int = 1'b1;
  wire [0:0] ch4_rx8b10ben_int = 1'b1;
  wire [0:0] ch5_rx8b10ben_int = 1'b1;
  wire [0:0] ch6_rx8b10ben_int = 1'b1;
  wire [0:0] ch7_rx8b10ben_int = 1'b1;
  assign rx8b10ben_int[0:0] = ch0_rx8b10ben_int;
  assign rx8b10ben_int[1:1] = ch1_rx8b10ben_int;
  assign rx8b10ben_int[2:2] = ch2_rx8b10ben_int;
  assign rx8b10ben_int[3:3] = ch3_rx8b10ben_int;
  assign rx8b10ben_int[4:4] = ch4_rx8b10ben_int;
  assign rx8b10ben_int[5:5] = ch5_rx8b10ben_int;
  assign rx8b10ben_int[6:6] = ch6_rx8b10ben_int;
  assign rx8b10ben_int[7:7] = ch7_rx8b10ben_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] tx8b10ben_int;
  wire [0:0] ch0_tx8b10ben_int = 1'b1;
  wire [0:0] ch1_tx8b10ben_int = 1'b1;
  wire [0:0] ch2_tx8b10ben_int = 1'b1;
  wire [0:0] ch3_tx8b10ben_int = 1'b1;
  wire [0:0] ch4_tx8b10ben_int = 1'b1;
  wire [0:0] ch5_tx8b10ben_int = 1'b1;
  wire [0:0] ch6_tx8b10ben_int = 1'b1;
  wire [0:0] ch7_tx8b10ben_int = 1'b1;
  assign tx8b10ben_int[0:0] = ch0_tx8b10ben_int;
  assign tx8b10ben_int[1:1] = ch1_tx8b10ben_int;
  assign tx8b10ben_int[2:2] = ch2_tx8b10ben_int;
  assign tx8b10ben_int[3:3] = ch3_tx8b10ben_int;
  assign tx8b10ben_int[4:4] = ch4_tx8b10ben_int;
  assign tx8b10ben_int[5:5] = ch5_tx8b10ben_int;
  assign tx8b10ben_int[6:6] = ch6_tx8b10ben_int;
  assign tx8b10ben_int[7:7] = ch7_tx8b10ben_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [127:0] txctrl0_int;
  wire [15:0] ch0_txctrl0_int;
  wire [15:0] ch1_txctrl0_int;
  wire [15:0] ch2_txctrl0_int;
  wire [15:0] ch3_txctrl0_int;
  wire [15:0] ch4_txctrl0_int;
  wire [15:0] ch5_txctrl0_int;
  wire [15:0] ch6_txctrl0_int;
  wire [15:0] ch7_txctrl0_int;
  assign txctrl0_int[15:0] = ch0_txctrl0_int;
  assign txctrl0_int[31:16] = ch1_txctrl0_int;
  assign txctrl0_int[47:32] = ch2_txctrl0_int;
  assign txctrl0_int[63:48] = ch3_txctrl0_int;
  assign txctrl0_int[79:64] = ch4_txctrl0_int;
  assign txctrl0_int[95:80] = ch5_txctrl0_int;
  assign txctrl0_int[111:96] = ch6_txctrl0_int;
  assign txctrl0_int[127:112] = ch7_txctrl0_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [127:0] txctrl1_int;
  wire [15:0] ch0_txctrl1_int;
  wire [15:0] ch1_txctrl1_int;
  wire [15:0] ch2_txctrl1_int;
  wire [15:0] ch3_txctrl1_int;
  wire [15:0] ch4_txctrl1_int;
  wire [15:0] ch5_txctrl1_int;
  wire [15:0] ch6_txctrl1_int;
  wire [15:0] ch7_txctrl1_int;
  assign txctrl1_int[15:0] = ch0_txctrl1_int;
  assign txctrl1_int[31:16] = ch1_txctrl1_int;
  assign txctrl1_int[47:32] = ch2_txctrl1_int;
  assign txctrl1_int[63:48] = ch3_txctrl1_int;
  assign txctrl1_int[79:64] = ch4_txctrl1_int;
  assign txctrl1_int[95:80] = ch5_txctrl1_int;
  assign txctrl1_int[111:96] = ch6_txctrl1_int;
  assign txctrl1_int[127:112] = ch7_txctrl1_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [63:0] txctrl2_int;
  wire [7:0] ch0_txctrl2_int;
  wire [7:0] ch1_txctrl2_int;
  wire [7:0] ch2_txctrl2_int;
  wire [7:0] ch3_txctrl2_int;
  wire [7:0] ch4_txctrl2_int;
  wire [7:0] ch5_txctrl2_int;
  wire [7:0] ch6_txctrl2_int;
  wire [7:0] ch7_txctrl2_int;
  assign txctrl2_int[7:0] = ch0_txctrl2_int;
  assign txctrl2_int[15:8] = ch1_txctrl2_int;
  assign txctrl2_int[23:16] = ch2_txctrl2_int;
  assign txctrl2_int[31:24] = ch3_txctrl2_int;
  assign txctrl2_int[39:32] = ch4_txctrl2_int;
  assign txctrl2_int[47:40] = ch5_txctrl2_int;
  assign txctrl2_int[55:48] = ch6_txctrl2_int;
  assign txctrl2_int[63:56] = ch7_txctrl2_int;

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] gtpowergood_int;
  wire [0:0] ch0_gtpowergood_int;
  wire [0:0] ch1_gtpowergood_int;
  wire [0:0] ch2_gtpowergood_int;
  wire [0:0] ch3_gtpowergood_int;
  wire [0:0] ch4_gtpowergood_int;
  wire [0:0] ch5_gtpowergood_int;
  wire [0:0] ch6_gtpowergood_int;
  wire [0:0] ch7_gtpowergood_int;
  assign ch0_gtpowergood_int = gtpowergood_int[0:0];
  assign ch1_gtpowergood_int = gtpowergood_int[1:1];
  assign ch2_gtpowergood_int = gtpowergood_int[2:2];
  assign ch3_gtpowergood_int = gtpowergood_int[3:3];
  assign ch4_gtpowergood_int = gtpowergood_int[4:4];
  assign ch5_gtpowergood_int = gtpowergood_int[5:5];
  assign ch6_gtpowergood_int = gtpowergood_int[6:6];
  assign ch7_gtpowergood_int = gtpowergood_int[7:7];

  //--------------------------------------------------------------------------------------------------------------------
  wire [127:0] rxctrl0_int;
  wire [15:0] ch0_rxctrl0_int;
  wire [15:0] ch1_rxctrl0_int;
  wire [15:0] ch2_rxctrl0_int;
  wire [15:0] ch3_rxctrl0_int;
  wire [15:0] ch4_rxctrl0_int;
  wire [15:0] ch5_rxctrl0_int;
  wire [15:0] ch6_rxctrl0_int;
  wire [15:0] ch7_rxctrl0_int;
  assign ch0_rxctrl0_int = rxctrl0_int[15:0];
  assign ch1_rxctrl0_int = rxctrl0_int[31:16];
  assign ch2_rxctrl0_int = rxctrl0_int[47:32];
  assign ch3_rxctrl0_int = rxctrl0_int[63:48];
  assign ch4_rxctrl0_int = rxctrl0_int[79:64];
  assign ch5_rxctrl0_int = rxctrl0_int[95:80];
  assign ch6_rxctrl0_int = rxctrl0_int[111:96];
  assign ch7_rxctrl0_int = rxctrl0_int[127:112];

  //--------------------------------------------------------------------------------------------------------------------
  wire [127:0] rxctrl1_int;
  wire [15:0] ch0_rxctrl1_int;
  wire [15:0] ch1_rxctrl1_int;
  wire [15:0] ch2_rxctrl1_int;
  wire [15:0] ch3_rxctrl1_int;
  wire [15:0] ch4_rxctrl1_int;
  wire [15:0] ch5_rxctrl1_int;
  wire [15:0] ch6_rxctrl1_int;
  wire [15:0] ch7_rxctrl1_int;
  assign ch0_rxctrl1_int = rxctrl1_int[15:0];
  assign ch1_rxctrl1_int = rxctrl1_int[31:16];
  assign ch2_rxctrl1_int = rxctrl1_int[47:32];
  assign ch3_rxctrl1_int = rxctrl1_int[63:48];
  assign ch4_rxctrl1_int = rxctrl1_int[79:64];
  assign ch5_rxctrl1_int = rxctrl1_int[95:80];
  assign ch6_rxctrl1_int = rxctrl1_int[111:96];
  assign ch7_rxctrl1_int = rxctrl1_int[127:112];

  //--------------------------------------------------------------------------------------------------------------------
  wire [63:0] rxctrl2_int;
  wire [7:0] ch0_rxctrl2_int;
  wire [7:0] ch1_rxctrl2_int;
  wire [7:0] ch2_rxctrl2_int;
  wire [7:0] ch3_rxctrl2_int;
  wire [7:0] ch4_rxctrl2_int;
  wire [7:0] ch5_rxctrl2_int;
  wire [7:0] ch6_rxctrl2_int;
  wire [7:0] ch7_rxctrl2_int;
  assign ch0_rxctrl2_int = rxctrl2_int[7:0];
  assign ch1_rxctrl2_int = rxctrl2_int[15:8];
  assign ch2_rxctrl2_int = rxctrl2_int[23:16];
  assign ch3_rxctrl2_int = rxctrl2_int[31:24];
  assign ch4_rxctrl2_int = rxctrl2_int[39:32];
  assign ch5_rxctrl2_int = rxctrl2_int[47:40];
  assign ch6_rxctrl2_int = rxctrl2_int[55:48];
  assign ch7_rxctrl2_int = rxctrl2_int[63:56];

  //--------------------------------------------------------------------------------------------------------------------
  wire [63:0] rxctrl3_int;
  wire [7:0] ch0_rxctrl3_int;
  wire [7:0] ch1_rxctrl3_int;
  wire [7:0] ch2_rxctrl3_int;
  wire [7:0] ch3_rxctrl3_int;
  wire [7:0] ch4_rxctrl3_int;
  wire [7:0] ch5_rxctrl3_int;
  wire [7:0] ch6_rxctrl3_int;
  wire [7:0] ch7_rxctrl3_int;
  assign ch0_rxctrl3_int = rxctrl3_int[7:0];
  assign ch1_rxctrl3_int = rxctrl3_int[15:8];
  assign ch2_rxctrl3_int = rxctrl3_int[23:16];
  assign ch3_rxctrl3_int = rxctrl3_int[31:24];
  assign ch4_rxctrl3_int = rxctrl3_int[39:32];
  assign ch5_rxctrl3_int = rxctrl3_int[47:40];
  assign ch6_rxctrl3_int = rxctrl3_int[55:48];
  assign ch7_rxctrl3_int = rxctrl3_int[63:56];

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] rxpmaresetdone_int;
  wire [0:0] ch0_rxpmaresetdone_int;
  wire [0:0] ch1_rxpmaresetdone_int;
  wire [0:0] ch2_rxpmaresetdone_int;
  wire [0:0] ch3_rxpmaresetdone_int;
  wire [0:0] ch4_rxpmaresetdone_int;
  wire [0:0] ch5_rxpmaresetdone_int;
  wire [0:0] ch6_rxpmaresetdone_int;
  wire [0:0] ch7_rxpmaresetdone_int;
  assign ch0_rxpmaresetdone_int = rxpmaresetdone_int[0:0];
  assign ch1_rxpmaresetdone_int = rxpmaresetdone_int[1:1];
  assign ch2_rxpmaresetdone_int = rxpmaresetdone_int[2:2];
  assign ch3_rxpmaresetdone_int = rxpmaresetdone_int[3:3];
  assign ch4_rxpmaresetdone_int = rxpmaresetdone_int[4:4];
  assign ch5_rxpmaresetdone_int = rxpmaresetdone_int[5:5];
  assign ch6_rxpmaresetdone_int = rxpmaresetdone_int[6:6];
  assign ch7_rxpmaresetdone_int = rxpmaresetdone_int[7:7];

  //--------------------------------------------------------------------------------------------------------------------
  wire [7:0] txpmaresetdone_int;
  wire [0:0] ch0_txpmaresetdone_int;
  wire [0:0] ch1_txpmaresetdone_int;
  wire [0:0] ch2_txpmaresetdone_int;
  wire [0:0] ch3_txpmaresetdone_int;
  wire [0:0] ch4_txpmaresetdone_int;
  wire [0:0] ch5_txpmaresetdone_int;
  wire [0:0] ch6_txpmaresetdone_int;
  wire [0:0] ch7_txpmaresetdone_int;
  assign ch0_txpmaresetdone_int = txpmaresetdone_int[0:0];
  assign ch1_txpmaresetdone_int = txpmaresetdone_int[1:1];
  assign ch2_txpmaresetdone_int = txpmaresetdone_int[2:2];
  assign ch3_txpmaresetdone_int = txpmaresetdone_int[3:3];
  assign ch4_txpmaresetdone_int = txpmaresetdone_int[4:4];
  assign ch5_txpmaresetdone_int = txpmaresetdone_int[5:5];
  assign ch6_txpmaresetdone_int = txpmaresetdone_int[6:6];
  assign ch7_txpmaresetdone_int = txpmaresetdone_int[7:7];


  // ===================================================================================================================
  // BUFFERS
  // ===================================================================================================================

  // Buffer the hb_gtwiz_reset_all_in input and logically combine it with the internal signal from the example
  // initialization block as well as the VIO-sourced reset
  wire hb_gtwiz_reset_all_vio_int;
  wire hb_gtwiz_reset_all_buf_int;
  wire hb_gtwiz_reset_all_init_int;
  wire hb_gtwiz_reset_all_int;

  IBUF ibuf_hb_gtwiz_reset_all_inst (
    .I (hb_gtwiz_reset_all_in),
    .O (hb_gtwiz_reset_all_buf_int)
  );

  assign hb_gtwiz_reset_all_int = hb_gtwiz_reset_all_buf_int || hb_gtwiz_reset_all_init_int || hb_gtwiz_reset_all_vio_int;

  // Globally buffer the free-running input clock
  wire hb_gtwiz_reset_clk_freerun_buf_int;

  BUFG bufg_clk_freerun_inst (
    .I (hb_gtwiz_reset_clk_freerun_in),
    .O (hb_gtwiz_reset_clk_freerun_buf_int)
  );

  // Instantiate a differential reference clock buffer for each reference clock differential pair in this configuration,
  // and assign the single-ended output of each differential reference clock buffer to the appropriate PLL input signal

  // Differential reference clock buffer for MGTREFCLK0_X0Y2
  wire mgtrefclk0_x0y2_int;

  IBUFDS_GTE4 #(
    .REFCLK_EN_TX_PATH  (1'b0),
    .REFCLK_HROW_CK_SEL (2'b00),
    .REFCLK_ICNTL_RX    (2'b00)
  ) IBUFDS_GTE4_MGTREFCLK0_X0Y2_INST (
    .I     (mgtrefclk0_x0y2_p),
    .IB    (mgtrefclk0_x0y2_n),
    .CEB   (1'b0),
    .O     (mgtrefclk0_x0y2_int),
    .ODIV2 ()
  );

  // Differential reference clock buffer for MGTREFCLK0_X0Y4
  wire mgtrefclk0_x0y4_int;

  IBUFDS_GTE4 #(
    .REFCLK_EN_TX_PATH  (1'b0),
    .REFCLK_HROW_CK_SEL (2'b00),
    .REFCLK_ICNTL_RX    (2'b00)
  ) IBUFDS_GTE4_MGTREFCLK0_X0Y4_INST (
    .I     (mgtrefclk0_x0y4_p),
    .IB    (mgtrefclk0_x0y4_n),
    .CEB   (1'b0),
    .O     (mgtrefclk0_x0y4_int),
    .ODIV2 ()
  );

  assign cm0_gtrefclk00_int = mgtrefclk0_x0y2_int;
  assign cm1_gtrefclk00_int = mgtrefclk0_x0y4_int;


  // ===================================================================================================================
  // USER CLOCKING RESETS
  // ===================================================================================================================

  // The TX user clocking helper block should be held in reset until the clock source of that block is known to be
  // stable. The following assignment is an example of how that stability can be determined, based on the selected TX
  // user clock source. Replace the assignment with the appropriate signal or logic to achieve that behavior as needed.
  assign hb0_gtwiz_userclk_tx_reset_int = ~(&txpmaresetdone_int);

  // The RX user clocking helper block should be held in reset until the clock source of that block is known to be
  // stable. The following assignment is an example of how that stability can be determined, based on the selected RX
  // user clock source. Replace the assignment with the appropriate signal or logic to achieve that behavior as needed.
  assign hb0_gtwiz_userclk_rx_reset_int = ~(&rxpmaresetdone_int);


  // ===================================================================================================================
  // PRBS STIMULUS, CHECKING, AND LINK MANAGEMENT
  // ===================================================================================================================

  // PRBS stimulus
  // -------------------------------------------------------------------------------------------------------------------

  // PRBS-based data stimulus module for transceiver channel 0
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst0 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch0_txctrl0_int),
    .txctrl1_out                 (ch0_txctrl1_int),
    .txctrl2_out                 (ch0_txctrl2_int),
    .txdata_out                  (hb0_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 1
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst1 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch1_txctrl0_int),
    .txctrl1_out                 (ch1_txctrl1_int),
    .txctrl2_out                 (ch1_txctrl2_int),
    .txdata_out                  (hb1_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 2
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst2 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch2_txctrl0_int),
    .txctrl1_out                 (ch2_txctrl1_int),
    .txctrl2_out                 (ch2_txctrl2_int),
    .txdata_out                  (hb2_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 3
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst3 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch3_txctrl0_int),
    .txctrl1_out                 (ch3_txctrl1_int),
    .txctrl2_out                 (ch3_txctrl2_int),
    .txdata_out                  (hb3_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 4
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst4 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch4_txctrl0_int),
    .txctrl1_out                 (ch4_txctrl1_int),
    .txctrl2_out                 (ch4_txctrl2_int),
    .txdata_out                  (hb4_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 5
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst5 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch5_txctrl0_int),
    .txctrl1_out                 (ch5_txctrl1_int),
    .txctrl2_out                 (ch5_txctrl2_int),
    .txdata_out                  (hb5_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 6
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst6 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch6_txctrl0_int),
    .txctrl1_out                 (ch6_txctrl1_int),
    .txctrl2_out                 (ch6_txctrl2_int),
    .txdata_out                  (hb6_gtwiz_userdata_tx_int)
  );

  // PRBS-based data stimulus module for transceiver channel 7
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_stimulus_8b10b example_stimulus_inst7 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_tx_usrclk2_in (hb0_gtwiz_userclk_tx_usrclk2_int),
    .gtwiz_userclk_tx_active_in  (hb0_gtwiz_userclk_tx_active_int),
    .txctrl0_out                 (ch7_txctrl0_int),
    .txctrl1_out                 (ch7_txctrl1_int),
    .txctrl2_out                 (ch7_txctrl2_int),
    .txdata_out                  (hb7_gtwiz_userdata_tx_int)
  );

  // PRBS checking
  // -------------------------------------------------------------------------------------------------------------------

  // Declare a signal vector of PRBS match indicators, with one indicator bit per transceiver channel
  wire [7:0] prbs_match_int;

  // PRBS-based data checking module for transceiver channel 0
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst0 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch0_rxctrl0_int),
    .rxctrl1_in                  (ch0_rxctrl1_int),
    .rxctrl2_in                  (ch0_rxctrl2_int),
    .rxctrl3_in                  (ch0_rxctrl3_int),
    .rxdata_in                   (hb0_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[0])
  );

  // PRBS-based data checking module for transceiver channel 1
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst1 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch1_rxctrl0_int),
    .rxctrl1_in                  (ch1_rxctrl1_int),
    .rxctrl2_in                  (ch1_rxctrl2_int),
    .rxctrl3_in                  (ch1_rxctrl3_int),
    .rxdata_in                   (hb1_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[1])
  );

  // PRBS-based data checking module for transceiver channel 2
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst2 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch2_rxctrl0_int),
    .rxctrl1_in                  (ch2_rxctrl1_int),
    .rxctrl2_in                  (ch2_rxctrl2_int),
    .rxctrl3_in                  (ch2_rxctrl3_int),
    .rxdata_in                   (hb2_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[2])
  );

  // PRBS-based data checking module for transceiver channel 3
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst3 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch3_rxctrl0_int),
    .rxctrl1_in                  (ch3_rxctrl1_int),
    .rxctrl2_in                  (ch3_rxctrl2_int),
    .rxctrl3_in                  (ch3_rxctrl3_int),
    .rxdata_in                   (hb3_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[3])
  );

  // PRBS-based data checking module for transceiver channel 4
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst4 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch4_rxctrl0_int),
    .rxctrl1_in                  (ch4_rxctrl1_int),
    .rxctrl2_in                  (ch4_rxctrl2_int),
    .rxctrl3_in                  (ch4_rxctrl3_int),
    .rxdata_in                   (hb4_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[4])
  );

  // PRBS-based data checking module for transceiver channel 5
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst5 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch5_rxctrl0_int),
    .rxctrl1_in                  (ch5_rxctrl1_int),
    .rxctrl2_in                  (ch5_rxctrl2_int),
    .rxctrl3_in                  (ch5_rxctrl3_int),
    .rxdata_in                   (hb5_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[5])
  );

  // PRBS-based data checking module for transceiver channel 6
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst6 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch6_rxctrl0_int),
    .rxctrl1_in                  (ch6_rxctrl1_int),
    .rxctrl2_in                  (ch6_rxctrl2_int),
    .rxctrl3_in                  (ch6_rxctrl3_int),
    .rxdata_in                   (hb6_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[6])
  );

  // PRBS-based data checking module for transceiver channel 7
  gtwizard_ultrascale_0_example_checking_8b10b example_checking_inst7 (
    .gtwiz_reset_all_in          (hb_gtwiz_reset_all_int || ~hb0_gtwiz_reset_rx_done_int ),
    .gtwiz_userclk_rx_usrclk2_in (hb0_gtwiz_userclk_rx_usrclk2_int),
    .gtwiz_userclk_rx_active_in  (hb0_gtwiz_userclk_rx_active_int),
    .rxctrl0_in                  (ch7_rxctrl0_int),
    .rxctrl1_in                  (ch7_rxctrl1_int),
    .rxctrl2_in                  (ch7_rxctrl2_int),
    .rxctrl3_in                  (ch7_rxctrl3_int),
    .rxdata_in                   (hb7_gtwiz_userdata_rx_int),
    .prbs_match_out              (prbs_match_int[7])
  );

  // PRBS match and related link management
  // -------------------------------------------------------------------------------------------------------------------

  // Perform a bitwise NAND of all PRBS match indicators, creating a combinatorial indication of any PRBS mismatch
  // across all transceiver channels
  wire prbs_error_any_async = ~(&prbs_match_int);
  wire prbs_error_any_sync;

  // Synchronize the PRBS mismatch indicator the free-running clock domain, using a reset synchronizer with asynchronous
  // reset and synchronous removal
  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_reset_synchronizer reset_synchronizer_prbs_match_all_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .rst_in (prbs_error_any_async),
    .rst_out(prbs_error_any_sync)
  );

  // Implement an example link status state machine using a simple leaky bucket mechanism. The link status indicates
  // the continual PRBS match status to both the top-level observer and the initialization state machine, while being
  // tolerant of occasional bit errors. This is an example and can be modified as necessary.
  localparam ST_LINK_DOWN = 1'b0;
  localparam ST_LINK_UP   = 1'b1;
  reg        sm_link      = ST_LINK_DOWN;
  reg [6:0]  link_ctr     = 7'd0;

  always @(posedge hb_gtwiz_reset_clk_freerun_buf_int) begin
    case (sm_link)
      // The link is considered to be down when the link counter initially has a value less than 67. When the link is
      // down, the counter is incremented on each cycle where all PRBS bits match, but reset whenever any PRBS mismatch
      // occurs. When the link counter reaches 67, transition to the link up state.
      ST_LINK_DOWN: begin
        if (prbs_error_any_sync !== 1'b0) begin
          link_ctr <= 7'd0;
        end
        else begin
          if (link_ctr < 7'd67)
            link_ctr <= link_ctr + 7'd1;
          else
            sm_link <= ST_LINK_UP;
        end
      end

      // When the link is up, the link counter is decreased by 34 whenever any PRBS mismatch occurs, but is increased by
      // only 1 on each cycle where all PRBS bits match, up to its saturation point of 67. If the link counter reaches
      // 0 (including rollover protection), transition to the link down state.
      ST_LINK_UP: begin
        if (prbs_error_any_sync !== 1'b0) begin
          if (link_ctr > 7'd33) begin
            link_ctr <= link_ctr - 7'd34;
            if (link_ctr == 7'd34)
              sm_link  <= ST_LINK_DOWN;
          end
          else begin
            link_ctr <= 7'd0;
            sm_link  <= ST_LINK_DOWN;
          end
        end
        else begin
          if (link_ctr < 7'd67)
            link_ctr <= link_ctr + 7'd1;
        end
      end
    endcase
  end

  // Synchronize the latched link down reset input and the VIO-driven signal into the free-running clock domain
  wire link_down_latched_reset_vio_int;
  wire link_down_latched_reset_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_link_down_latched_reset_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (link_down_latched_reset_in || link_down_latched_reset_vio_int),
    .o_out  (link_down_latched_reset_sync)
  );

  // Reset the latched link down indicator when the synchronized latched link down reset signal is high. Otherwise, set
  // the latched link down indicator upon losing link. This indicator is available for user reference.
  always @(posedge hb_gtwiz_reset_clk_freerun_buf_int) begin
    if (link_down_latched_reset_sync)
      link_down_latched_out <= 1'b0;
    else if (!sm_link)
      link_down_latched_out <= 1'b1;
  end

  // Assign the link status indicator to the top-level two-state output for user reference
  assign link_status_out = sm_link;


  // ===================================================================================================================
  // INITIALIZATION
  // ===================================================================================================================

  // Declare the receiver reset signals that interface to the reset controller helper block. For this configuration,
  // which uses the same PLL type for transmitter and receiver, the "reset RX PLL and datapath" feature is not used.
  wire hb_gtwiz_reset_rx_pll_and_datapath_int = 1'b0;
  wire hb_gtwiz_reset_rx_datapath_int;

  // Declare signals which connect the VIO instance to the initialization module for debug purposes
  wire       init_done_int;
  wire [3:0] init_retry_ctr_int;

  // Combine the receiver reset signals form the initialization module and the VIO to drive the appropriate reset
  // controller helper block reset input
  wire hb_gtwiz_reset_rx_pll_and_datapath_vio_int;
  wire hb_gtwiz_reset_rx_datapath_vio_int;
  wire hb_gtwiz_reset_rx_datapath_init_int;

  assign hb_gtwiz_reset_rx_datapath_int = hb_gtwiz_reset_rx_datapath_init_int || hb_gtwiz_reset_rx_datapath_vio_int;

  // The example initialization module interacts with the reset controller helper block and other example design logic
  // to retry failed reset attempts in order to mitigate bring-up issues such as initially-unavilable reference clocks
  // or data connections. It also resets the receiver in the event of link loss in an attempt to regain link, so please
  // note the possibility that this behavior can have the effect of overriding or disturbing user-provided inputs that
  // destabilize the data stream. It is a demonstration only and can be modified to suit your system needs.
  gtwizard_ultrascale_0_example_init example_init_inst (
    .clk_freerun_in  (hb_gtwiz_reset_clk_freerun_buf_int),
    .reset_all_in    (hb_gtwiz_reset_all_int),
    .tx_init_done_in (gtwiz_reset_tx_done_int),
    .rx_init_done_in (gtwiz_reset_rx_done_int),
    .rx_data_good_in (sm_link),
    .reset_all_out   (hb_gtwiz_reset_all_init_int),
    .reset_rx_out    (hb_gtwiz_reset_rx_datapath_init_int),
    .init_done_out   (init_done_int),
    .retry_ctr_out   (init_retry_ctr_int)
  );


  // ===================================================================================================================
  // VIO FOR HARDWARE BRING-UP AND DEBUG
  // ===================================================================================================================

  // Synchronize gtpowergood into the free-running clock domain for VIO usage
  wire [7:0] gtpowergood_vio_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_0_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[0]),
    .o_out  (gtpowergood_vio_sync[0])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_1_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[1]),
    .o_out  (gtpowergood_vio_sync[1])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_2_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[2]),
    .o_out  (gtpowergood_vio_sync[2])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_3_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[3]),
    .o_out  (gtpowergood_vio_sync[3])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_4_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[4]),
    .o_out  (gtpowergood_vio_sync[4])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_5_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[5]),
    .o_out  (gtpowergood_vio_sync[5])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_6_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[6]),
    .o_out  (gtpowergood_vio_sync[6])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtpowergood_7_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtpowergood_int[7]),
    .o_out  (gtpowergood_vio_sync[7])
  );

  // Synchronize txpmaresetdone into the free-running clock domain for VIO usage
  wire [7:0] txpmaresetdone_vio_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_0_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[0]),
    .o_out  (txpmaresetdone_vio_sync[0])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_1_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[1]),
    .o_out  (txpmaresetdone_vio_sync[1])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_2_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[2]),
    .o_out  (txpmaresetdone_vio_sync[2])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_3_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[3]),
    .o_out  (txpmaresetdone_vio_sync[3])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_4_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[4]),
    .o_out  (txpmaresetdone_vio_sync[4])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_5_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[5]),
    .o_out  (txpmaresetdone_vio_sync[5])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_6_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[6]),
    .o_out  (txpmaresetdone_vio_sync[6])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_txpmaresetdone_7_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (txpmaresetdone_int[7]),
    .o_out  (txpmaresetdone_vio_sync[7])
  );

  // Synchronize rxpmaresetdone into the free-running clock domain for VIO usage
  wire [7:0] rxpmaresetdone_vio_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_0_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[0]),
    .o_out  (rxpmaresetdone_vio_sync[0])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_1_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[1]),
    .o_out  (rxpmaresetdone_vio_sync[1])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_2_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[2]),
    .o_out  (rxpmaresetdone_vio_sync[2])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_3_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[3]),
    .o_out  (rxpmaresetdone_vio_sync[3])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_4_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[4]),
    .o_out  (rxpmaresetdone_vio_sync[4])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_5_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[5]),
    .o_out  (rxpmaresetdone_vio_sync[5])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_6_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[6]),
    .o_out  (rxpmaresetdone_vio_sync[6])
  );

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_rxpmaresetdone_7_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (rxpmaresetdone_int[7]),
    .o_out  (rxpmaresetdone_vio_sync[7])
  );

  // Synchronize gtwiz_reset_tx_done into the free-running clock domain for VIO usage
  wire [0:0] gtwiz_reset_tx_done_vio_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtwiz_reset_tx_done_0_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtwiz_reset_tx_done_int[0]),
    .o_out  (gtwiz_reset_tx_done_vio_sync[0])
  );

  // Synchronize gtwiz_reset_rx_done into the free-running clock domain for VIO usage
  wire [0:0] gtwiz_reset_rx_done_vio_sync;

  (* DONT_TOUCH = "TRUE" *)
  gtwizard_ultrascale_0_example_bit_synchronizer bit_synchronizer_vio_gtwiz_reset_rx_done_0_inst (
    .clk_in (hb_gtwiz_reset_clk_freerun_buf_int),
    .i_in   (gtwiz_reset_rx_done_int[0]),
    .o_out  (gtwiz_reset_rx_done_vio_sync[0])
  );


  // Instantiate the VIO IP core for hardware bring-up and debug purposes, connecting relevant debug and analysis
  // signals which have been enabled during Wizard IP customization. This initial set of connected signals is
  // provided as a convenience and example, but more or fewer ports can be used as needed; simply re-customize and
  // re-generate the VIO instance, then connect any exposed signals that are needed. Signals which are synchronous to
  // clocks other than the free-running clock will require synchronization. For usage, refer to Vivado Design Suite
  // User Guide: Programming and Debugging (UG908)
  gtwizard_ultrascale_0_vio_0 gtwizard_ultrascale_0_vio_0_inst (
    .clk (hb_gtwiz_reset_clk_freerun_buf_int)
    ,.probe_in0 (link_status_out)
    ,.probe_in1 (link_down_latched_out)
    ,.probe_in2 (init_done_int)
    ,.probe_in3 (init_retry_ctr_int)
    ,.probe_in4 (gtpowergood_vio_sync)
    ,.probe_in5 (txpmaresetdone_vio_sync)
    ,.probe_in6 (rxpmaresetdone_vio_sync)
    ,.probe_in7 (gtwiz_reset_tx_done_vio_sync)
    ,.probe_in8 (gtwiz_reset_rx_done_vio_sync)
    ,.probe_out0 (hb_gtwiz_reset_all_vio_int)
    ,.probe_out1 (hb0_gtwiz_reset_tx_pll_and_datapath_int)
    ,.probe_out2 (hb0_gtwiz_reset_tx_datapath_int)
    ,.probe_out3 (hb_gtwiz_reset_rx_pll_and_datapath_vio_int)
    ,.probe_out4 (hb_gtwiz_reset_rx_datapath_vio_int)
    ,.probe_out5 (link_down_latched_reset_vio_int)
  );


  // ===================================================================================================================
  // EXAMPLE WRAPPER INSTANCE
  // ===================================================================================================================

  // Instantiate the example design wrapper, mapping its enabled ports to per-channel internal signals and example
  // resources as appropriate
  gtwizard_ultrascale_0_example_wrapper example_wrapper_inst (
    .gtyrxn_in                               (gtyrxn_int)
   ,.gtyrxp_in                               (gtyrxp_int)
   ,.gtytxn_out                              (gtytxn_int)
   ,.gtytxp_out                              (gtytxp_int)
   ,.gtwiz_userclk_tx_reset_in               (gtwiz_userclk_tx_reset_int)
   ,.gtwiz_userclk_tx_srcclk_out             (gtwiz_userclk_tx_srcclk_int)
   ,.gtwiz_userclk_tx_usrclk_out             (gtwiz_userclk_tx_usrclk_int)
   ,.gtwiz_userclk_tx_usrclk2_out            (gtwiz_userclk_tx_usrclk2_int)
   ,.gtwiz_userclk_tx_active_out             (gtwiz_userclk_tx_active_int)
   ,.gtwiz_userclk_rx_reset_in               (gtwiz_userclk_rx_reset_int)
   ,.gtwiz_userclk_rx_srcclk_out             (gtwiz_userclk_rx_srcclk_int)
   ,.gtwiz_userclk_rx_usrclk_out             (gtwiz_userclk_rx_usrclk_int)
   ,.gtwiz_userclk_rx_usrclk2_out            (gtwiz_userclk_rx_usrclk2_int)
   ,.gtwiz_userclk_rx_active_out             (gtwiz_userclk_rx_active_int)
   ,.gtwiz_reset_clk_freerun_in              ({1{hb_gtwiz_reset_clk_freerun_buf_int}})
   ,.gtwiz_reset_all_in                      ({1{hb_gtwiz_reset_all_int}})
   ,.gtwiz_reset_tx_pll_and_datapath_in      (gtwiz_reset_tx_pll_and_datapath_int)
   ,.gtwiz_reset_tx_datapath_in              (gtwiz_reset_tx_datapath_int)
   ,.gtwiz_reset_rx_pll_and_datapath_in      ({1{hb_gtwiz_reset_rx_pll_and_datapath_int}})
   ,.gtwiz_reset_rx_datapath_in              ({1{hb_gtwiz_reset_rx_datapath_int}})
   ,.gtwiz_reset_rx_cdr_stable_out           (gtwiz_reset_rx_cdr_stable_int)
   ,.gtwiz_reset_tx_done_out                 (gtwiz_reset_tx_done_int)
   ,.gtwiz_reset_rx_done_out                 (gtwiz_reset_rx_done_int)
   ,.gtwiz_userdata_tx_in                    (gtwiz_userdata_tx_int)
   ,.gtwiz_userdata_rx_out                   (gtwiz_userdata_rx_int)
   ,.gtrefclk00_in                           (gtrefclk00_int)
   ,.qpll0outclk_out                         (qpll0outclk_int)
   ,.qpll0outrefclk_out                      (qpll0outrefclk_int)
   ,.rx8b10ben_in                            (rx8b10ben_int)
   ,.tx8b10ben_in                            (tx8b10ben_int)
   ,.txctrl0_in                              (txctrl0_int)
   ,.txctrl1_in                              (txctrl1_int)
   ,.txctrl2_in                              (txctrl2_int)
   ,.gtpowergood_out                         (gtpowergood_int)
   ,.rxctrl0_out                             (rxctrl0_int)
   ,.rxctrl1_out                             (rxctrl1_int)
   ,.rxctrl2_out                             (rxctrl2_int)
   ,.rxctrl3_out                             (rxctrl3_int)
   ,.rxpmaresetdone_out                      (rxpmaresetdone_int)
   ,.txpmaresetdone_out                      (txpmaresetdone_int)
);


endmodule
