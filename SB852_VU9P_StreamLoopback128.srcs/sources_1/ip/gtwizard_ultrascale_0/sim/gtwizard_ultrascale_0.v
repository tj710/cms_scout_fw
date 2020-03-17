// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:gtwizard_ultrascale:1.7
// IP Revision: 7

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module gtwizard_ultrascale_0 (
  gtwiz_userclk_tx_active_in,
  gtwiz_userclk_rx_active_in,
  gtwiz_reset_clk_freerun_in,
  gtwiz_reset_all_in,
  gtwiz_reset_tx_pll_and_datapath_in,
  gtwiz_reset_tx_datapath_in,
  gtwiz_reset_rx_pll_and_datapath_in,
  gtwiz_reset_rx_datapath_in,
  gtwiz_reset_rx_cdr_stable_out,
  gtwiz_reset_tx_done_out,
  gtwiz_reset_rx_done_out,
  gtwiz_userdata_tx_in,
  gtwiz_userdata_rx_out,
  gtrefclk00_in,
  qpll0outclk_out,
  qpll0outrefclk_out,
  gtyrxn_in,
  gtyrxp_in,
  rx8b10ben_in,
  rxusrclk_in,
  rxusrclk2_in,
  tx8b10ben_in,
  txctrl0_in,
  txctrl1_in,
  txctrl2_in,
  txusrclk_in,
  txusrclk2_in,
  gtpowergood_out,
  gtytxn_out,
  gtytxp_out,
  rxctrl0_out,
  rxctrl1_out,
  rxctrl2_out,
  rxctrl3_out,
  rxoutclk_out,
  rxpmaresetdone_out,
  txoutclk_out,
  txpmaresetdone_out
);

input wire [0 : 0] gtwiz_userclk_tx_active_in;
input wire [0 : 0] gtwiz_userclk_rx_active_in;
input wire [0 : 0] gtwiz_reset_clk_freerun_in;
input wire [0 : 0] gtwiz_reset_all_in;
input wire [0 : 0] gtwiz_reset_tx_pll_and_datapath_in;
input wire [0 : 0] gtwiz_reset_tx_datapath_in;
input wire [0 : 0] gtwiz_reset_rx_pll_and_datapath_in;
input wire [0 : 0] gtwiz_reset_rx_datapath_in;
output wire [0 : 0] gtwiz_reset_rx_cdr_stable_out;
output wire [0 : 0] gtwiz_reset_tx_done_out;
output wire [0 : 0] gtwiz_reset_rx_done_out;
input wire [255 : 0] gtwiz_userdata_tx_in;
output wire [255 : 0] gtwiz_userdata_rx_out;
input wire [1 : 0] gtrefclk00_in;
output wire [1 : 0] qpll0outclk_out;
output wire [1 : 0] qpll0outrefclk_out;
input wire [7 : 0] gtyrxn_in;
input wire [7 : 0] gtyrxp_in;
input wire [7 : 0] rx8b10ben_in;
input wire [7 : 0] rxusrclk_in;
input wire [7 : 0] rxusrclk2_in;
input wire [7 : 0] tx8b10ben_in;
input wire [127 : 0] txctrl0_in;
input wire [127 : 0] txctrl1_in;
input wire [63 : 0] txctrl2_in;
input wire [7 : 0] txusrclk_in;
input wire [7 : 0] txusrclk2_in;
output wire [7 : 0] gtpowergood_out;
output wire [7 : 0] gtytxn_out;
output wire [7 : 0] gtytxp_out;
output wire [127 : 0] rxctrl0_out;
output wire [127 : 0] rxctrl1_out;
output wire [63 : 0] rxctrl2_out;
output wire [63 : 0] rxctrl3_out;
output wire [7 : 0] rxoutclk_out;
output wire [7 : 0] rxpmaresetdone_out;
output wire [7 : 0] txoutclk_out;
output wire [7 : 0] txpmaresetdone_out;

  gtwizard_ultrascale_0_gtwizard_top #(
    .C_CHANNEL_ENABLE(192'B000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000111100000000),
    .C_PCIE_ENABLE(0),
    .C_PCIE_CORECLK_FREQ(250),
    .C_COMMON_SCALING_FACTOR(2),
    .C_CPLL_VCO_FREQUENCY(2578.125),
    .C_FORCE_COMMONS(0),
    .C_FREERUN_FREQUENCY(250),
    .C_GT_TYPE(3),
    .C_GT_REV(67),
    .C_INCLUDE_CPLL_CAL(2),
    .C_ENABLE_COMMON_USRCLK(0),
    .C_USER_GTPOWERGOOD_DELAY_EN(1),
    .C_SIM_CPLL_CAL_BYPASS(1),
    .C_LOCATE_COMMON(0),
    .C_LOCATE_RESET_CONTROLLER(0),
    .C_LOCATE_USER_DATA_WIDTH_SIZING(0),
    .C_LOCATE_RX_BUFFER_BYPASS_CONTROLLER(0),
    .C_LOCATE_IN_SYSTEM_IBERT_CORE(2),
    .C_LOCATE_RX_USER_CLOCKING(1),
    .C_LOCATE_TX_BUFFER_BYPASS_CONTROLLER(0),
    .C_LOCATE_TX_USER_CLOCKING(1),
    .C_RESET_CONTROLLER_INSTANCE_CTRL(0),
    .C_RX_BUFFBYPASS_MODE(0),
    .C_RX_BUFFER_BYPASS_INSTANCE_CTRL(0),
    .C_RX_BUFFER_MODE(1),
    .C_RX_CB_DISP(8'B00000000),
    .C_RX_CB_K(8'B00000000),
    .C_RX_CB_MAX_LEVEL(4),
    .C_RX_CB_LEN_SEQ(1),
    .C_RX_CB_NUM_SEQ(0),
    .C_RX_CB_VAL(80'B00000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .C_RX_CC_DISP(8'B00000000),
    .C_RX_CC_ENABLE(0),
    .C_RESET_SEQUENCE_INTERVAL(0),
    .C_RX_CC_K(8'B00000000),
    .C_RX_CC_LEN_SEQ(1),
    .C_RX_CC_NUM_SEQ(0),
    .C_RX_CC_PERIODICITY(5000),
    .C_RX_CC_VAL(80'B00000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .C_RX_COMMA_M_ENABLE(0),
    .C_RX_COMMA_M_VAL(10'B1010000011),
    .C_RX_COMMA_P_ENABLE(0),
    .C_RX_COMMA_P_VAL(10'B0101111100),
    .C_RX_DATA_DECODING(1),
    .C_RX_ENABLE(1),
    .C_RX_INT_DATA_WIDTH(40),
    .C_RX_LINE_RATE(10.3125),
    .C_RX_MASTER_CHANNEL_IDX(19),
    .C_RX_OUTCLK_BUFG_GT_DIV(1),
    .C_RX_OUTCLK_FREQUENCY(257.8125000),
    .C_RX_OUTCLK_SOURCE(1),
    .C_RX_PLL_TYPE(0),
    .C_RX_RECCLK_OUTPUT(192'H000000000000000000000000000000000000000000000000),
    .C_RX_REFCLK_FREQUENCY(64.453125),
    .C_RX_SLIDE_MODE(0),
    .C_RX_USER_CLOCKING_CONTENTS(0),
    .C_RX_USER_CLOCKING_INSTANCE_CTRL(0),
    .C_RX_USER_CLOCKING_RATIO_FSRC_FUSRCLK(1),
    .C_RX_USER_CLOCKING_RATIO_FUSRCLK_FUSRCLK2(1),
    .C_RX_USER_CLOCKING_SOURCE(0),
    .C_RX_USER_DATA_WIDTH(32),
    .C_RX_USRCLK_FREQUENCY(257.8125000),
    .C_RX_USRCLK2_FREQUENCY(257.8125000),
    .C_SECONDARY_QPLL_ENABLE(0),
    .C_SECONDARY_QPLL_REFCLK_FREQUENCY(257.8125),
    .C_TOTAL_NUM_CHANNELS(8),
    .C_TOTAL_NUM_COMMONS(2),
    .C_TOTAL_NUM_COMMONS_EXAMPLE(0),
    .C_TXPROGDIV_FREQ_ENABLE(0),
    .C_TXPROGDIV_FREQ_SOURCE(0),
    .C_TXPROGDIV_FREQ_VAL(257.8125),
    .C_TX_BUFFBYPASS_MODE(0),
    .C_TX_BUFFER_BYPASS_INSTANCE_CTRL(0),
    .C_TX_BUFFER_MODE(1),
    .C_TX_DATA_ENCODING(1),
    .C_TX_ENABLE(1),
    .C_TX_INT_DATA_WIDTH(40),
    .C_TX_LINE_RATE(10.3125),
    .C_TX_MASTER_CHANNEL_IDX(19),
    .C_TX_OUTCLK_BUFG_GT_DIV(1),
    .C_TX_OUTCLK_FREQUENCY(257.8125000),
    .C_TX_OUTCLK_SOURCE(1),
    .C_TX_PLL_TYPE(0),
    .C_TX_REFCLK_FREQUENCY(64.453125),
    .C_TX_USER_CLOCKING_CONTENTS(0),
    .C_TX_USER_CLOCKING_INSTANCE_CTRL(0),
    .C_TX_USER_CLOCKING_RATIO_FSRC_FUSRCLK(1),
    .C_TX_USER_CLOCKING_RATIO_FUSRCLK_FUSRCLK2(1),
    .C_TX_USER_CLOCKING_SOURCE(0),
    .C_TX_USER_DATA_WIDTH(32),
    .C_TX_USRCLK_FREQUENCY(257.8125000),
    .C_TX_USRCLK2_FREQUENCY(257.8125000)
  ) inst (
    .gtwiz_userclk_tx_reset_in(1'B0),
    .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in),
    .gtwiz_userclk_tx_srcclk_out(),
    .gtwiz_userclk_tx_usrclk_out(),
    .gtwiz_userclk_tx_usrclk2_out(),
    .gtwiz_userclk_tx_active_out(),
    .gtwiz_userclk_rx_reset_in(1'B0),
    .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),
    .gtwiz_userclk_rx_srcclk_out(),
    .gtwiz_userclk_rx_usrclk_out(),
    .gtwiz_userclk_rx_usrclk2_out(),
    .gtwiz_userclk_rx_active_out(),
    .gtwiz_buffbypass_tx_reset_in(1'B0),
    .gtwiz_buffbypass_tx_start_user_in(1'B0),
    .gtwiz_buffbypass_tx_done_out(),
    .gtwiz_buffbypass_tx_error_out(),
    .gtwiz_buffbypass_rx_reset_in(1'B0),
    .gtwiz_buffbypass_rx_start_user_in(1'B0),
    .gtwiz_buffbypass_rx_done_out(),
    .gtwiz_buffbypass_rx_error_out(),
    .gtwiz_reset_clk_freerun_in(gtwiz_reset_clk_freerun_in),
    .gtwiz_reset_all_in(gtwiz_reset_all_in),
    .gtwiz_reset_tx_pll_and_datapath_in(gtwiz_reset_tx_pll_and_datapath_in),
    .gtwiz_reset_tx_datapath_in(gtwiz_reset_tx_datapath_in),
    .gtwiz_reset_rx_pll_and_datapath_in(gtwiz_reset_rx_pll_and_datapath_in),
    .gtwiz_reset_rx_datapath_in(gtwiz_reset_rx_datapath_in),
    .gtwiz_reset_tx_done_in(1'B0),
    .gtwiz_reset_rx_done_in(1'B0),
    .gtwiz_reset_qpll0lock_in(2'B0),
    .gtwiz_reset_qpll1lock_in(2'B0),
    .gtwiz_reset_rx_cdr_stable_out(gtwiz_reset_rx_cdr_stable_out),
    .gtwiz_reset_tx_done_out(gtwiz_reset_tx_done_out),
    .gtwiz_reset_rx_done_out(gtwiz_reset_rx_done_out),
    .gtwiz_reset_qpll0reset_out(),
    .gtwiz_reset_qpll1reset_out(),
    .gtwiz_gthe3_cpll_cal_txoutclk_period_in(144'B0),
    .gtwiz_gthe3_cpll_cal_cnt_tol_in(144'B0),
    .gtwiz_gthe3_cpll_cal_bufg_ce_in(8'B0),
    .gtwiz_gthe4_cpll_cal_txoutclk_period_in(144'B0),
    .gtwiz_gthe4_cpll_cal_cnt_tol_in(144'B0),
    .gtwiz_gthe4_cpll_cal_bufg_ce_in(8'B0),
    .gtwiz_gtye4_cpll_cal_txoutclk_period_in(144'B0),
    .gtwiz_gtye4_cpll_cal_cnt_tol_in(144'B0),
    .gtwiz_gtye4_cpll_cal_bufg_ce_in(8'B0),
    .gtwiz_userdata_tx_in(gtwiz_userdata_tx_in),
    .gtwiz_userdata_rx_out(gtwiz_userdata_rx_out),
    .bgbypassb_in(2'H3),
    .bgmonitorenb_in(2'H3),
    .bgpdb_in(2'H3),
    .bgrcalovrd_in(10'H210),
    .bgrcalovrdenb_in(2'H3),
    .drpaddr_common_in(32'H00000000),
    .drpclk_common_in(2'H0),
    .drpdi_common_in(32'H00000000),
    .drpen_common_in(2'H0),
    .drpwe_common_in(2'H0),
    .gtgrefclk0_in(2'H0),
    .gtgrefclk1_in(2'H0),
    .gtnorthrefclk00_in(2'H0),
    .gtnorthrefclk01_in(2'H0),
    .gtnorthrefclk10_in(2'H0),
    .gtnorthrefclk11_in(2'H0),
    .gtrefclk00_in(gtrefclk00_in),
    .gtrefclk01_in(2'H0),
    .gtrefclk10_in(2'H0),
    .gtrefclk11_in(2'H0),
    .gtsouthrefclk00_in(2'H0),
    .gtsouthrefclk01_in(2'H0),
    .gtsouthrefclk10_in(2'H0),
    .gtsouthrefclk11_in(2'H0),
    .pcierateqpll0_in(6'H00),
    .pcierateqpll1_in(6'H00),
    .pmarsvd0_in(16'H0000),
    .pmarsvd1_in(16'H0000),
    .qpll0clkrsvd0_in(2'H0),
    .qpll0clkrsvd1_in(2'H0),
    .qpll0fbdiv_in(16'H0000),
    .qpll0lockdetclk_in(2'H0),
    .qpll0locken_in(2'H3),
    .qpll0pd_in(2'H0),
    .qpll0refclksel_in(6'H09),
    .qpll0reset_in(2'H0),
    .qpll1clkrsvd0_in(2'H0),
    .qpll1clkrsvd1_in(2'H0),
    .qpll1fbdiv_in(16'H0000),
    .qpll1lockdetclk_in(2'H0),
    .qpll1locken_in(2'H0),
    .qpll1pd_in(2'H3),
    .qpll1refclksel_in(6'H09),
    .qpll1reset_in(2'H3),
    .qpllrsvd1_in(16'H0000),
    .qpllrsvd2_in(10'H000),
    .qpllrsvd3_in(10'H000),
    .qpllrsvd4_in(16'H0000),
    .rcalenb_in(2'H3),
    .sdm0data_in(50'H0000000000000),
    .sdm0reset_in(2'H0),
    .sdm0toggle_in(2'H0),
    .sdm0width_in(4'H0),
    .sdm1data_in(50'H0000000000000),
    .sdm1reset_in(2'H0),
    .sdm1toggle_in(2'H0),
    .sdm1width_in(4'H0),
    .tcongpi_in(1'B0),
    .tconpowerup_in(1'B0),
    .tconreset_in(1'B0),
    .tconrsvdin1_in(1'B0),
    .ubcfgstreamen_in(2'H0),
    .ubdo_in(32'H00000000),
    .ubdrdy_in(2'H0),
    .ubenable_in(2'H0),
    .ubgpi_in(4'H0),
    .ubintr_in(4'H0),
    .ubiolmbrst_in(2'H0),
    .ubmbrst_in(2'H0),
    .ubmdmcapture_in(2'H0),
    .ubmdmdbgrst_in(2'H0),
    .ubmdmdbgupdate_in(2'H0),
    .ubmdmregen_in(8'H00),
    .ubmdmshift_in(2'H0),
    .ubmdmsysrst_in(2'H0),
    .ubmdmtck_in(2'H0),
    .ubmdmtdi_in(2'H0),
    .drpdo_common_out(),
    .drprdy_common_out(),
    .pmarsvdout0_out(),
    .pmarsvdout1_out(),
    .qpll0fbclklost_out(),
    .qpll0lock_out(),
    .qpll0outclk_out(qpll0outclk_out),
    .qpll0outrefclk_out(qpll0outrefclk_out),
    .qpll0refclklost_out(),
    .qpll1fbclklost_out(),
    .qpll1lock_out(),
    .qpll1outclk_out(),
    .qpll1outrefclk_out(),
    .qpll1refclklost_out(),
    .qplldmonitor0_out(),
    .qplldmonitor1_out(),
    .refclkoutmonitor0_out(),
    .refclkoutmonitor1_out(),
    .rxrecclk0_sel_out(),
    .rxrecclk1_sel_out(),
    .rxrecclk0sel_out(),
    .rxrecclk1sel_out(),
    .sdm0finalout_out(),
    .sdm0testdata_out(),
    .sdm1finalout_out(),
    .sdm1testdata_out(),
    .tcongpo_out(),
    .tconrsvdout0_out(),
    .ubdaddr_out(),
    .ubden_out(),
    .ubdi_out(),
    .ubdwe_out(),
    .ubmdmtdo_out(),
    .ubrsvdout_out(),
    .ubtxuart_out(),
    .cdrstepdir_in(8'H00),
    .cdrstepsq_in(8'H00),
    .cdrstepsx_in(8'H00),
    .cfgreset_in(8'H00),
    .clkrsvd0_in(8'H00),
    .clkrsvd1_in(8'H00),
    .cpllfreqlock_in(8'H00),
    .cplllockdetclk_in(8'H00),
    .cplllocken_in(8'H00),
    .cpllpd_in(8'HFF),
    .cpllrefclksel_in(24'H249249),
    .cpllreset_in(8'HFF),
    .dmonfiforeset_in(8'H00),
    .dmonitorclk_in(8'H00),
    .drpaddr_in(80'H00000000000000000000),
    .drpclk_in(8'H00),
    .drpdi_in(128'H00000000000000000000000000000000),
    .drpen_in(8'H00),
    .drprst_in(8'H00),
    .drpwe_in(8'H00),
    .elpcaldvorwren_in(1'B0),
    .elpcalpaorwren_in(1'B0),
    .evoddphicaldone_in(1'B0),
    .evoddphicalstart_in(1'B0),
    .evoddphidrden_in(1'B0),
    .evoddphidwren_in(1'B0),
    .evoddphixrden_in(1'B0),
    .evoddphixwren_in(1'B0),
    .eyescanmode_in(1'B0),
    .eyescanreset_in(8'H00),
    .eyescantrigger_in(8'H00),
    .freqos_in(8'H00),
    .gtgrefclk_in(8'H00),
    .gthrxn_in(1'B0),
    .gthrxp_in(1'B0),
    .gtnorthrefclk0_in(8'H00),
    .gtnorthrefclk1_in(8'H00),
    .gtrefclk0_in(8'H00),
    .gtrefclk1_in(8'H00),
    .gtresetsel_in(1'B0),
    .gtrsvd_in(128'H00000000000000000000000000000000),
    .gtrxreset_in(8'H00),
    .gtrxresetsel_in(8'H00),
    .gtsouthrefclk0_in(8'H00),
    .gtsouthrefclk1_in(8'H00),
    .gttxreset_in(8'H00),
    .gttxresetsel_in(8'H00),
    .incpctrl_in(8'H00),
    .gtyrxn_in(gtyrxn_in),
    .gtyrxp_in(gtyrxp_in),
    .loopback_in(24'H000000),
    .looprsvd_in(1'B0),
    .lpbkrxtxseren_in(1'B0),
    .lpbktxrxseren_in(1'B0),
    .pcieeqrxeqadaptdone_in(8'H00),
    .pcierstidle_in(8'H00),
    .pciersttxsyncstart_in(8'H00),
    .pcieuserratedone_in(8'H00),
    .pcsrsvdin_in(128'H00000000000000000000000000000000),
    .pcsrsvdin2_in(1'B0),
    .pmarsvdin_in(1'B0),
    .qpll0clk_in(8'H00),
    .qpll0freqlock_in(8'H00),
    .qpll0refclk_in(8'H00),
    .qpll1clk_in(8'H00),
    .qpll1freqlock_in(8'H00),
    .qpll1refclk_in(8'H00),
    .resetovrd_in(8'H00),
    .rstclkentx_in(1'B0),
    .rx8b10ben_in(rx8b10ben_in),
    .rxafecfoken_in(8'HFF),
    .rxbufreset_in(8'H00),
    .rxcdrfreqreset_in(8'H00),
    .rxcdrhold_in(8'H00),
    .rxcdrovrden_in(8'H00),
    .rxcdrreset_in(8'H00),
    .rxcdrresetrsv_in(1'B0),
    .rxchbonden_in(8'H00),
    .rxchbondi_in(40'H0000000000),
    .rxchbondlevel_in(24'H000000),
    .rxchbondmaster_in(8'H00),
    .rxchbondslave_in(8'H00),
    .rxckcalreset_in(8'H00),
    .rxckcalstart_in(56'H00000000000000),
    .rxcommadeten_in(8'H00),
    .rxdfeagcctrl_in(1'B0),
    .rxdccforcestart_in(1'B0),
    .rxdfeagchold_in(8'H00),
    .rxdfeagcovrden_in(8'H00),
    .rxdfecfokfcnum_in(32'HDDDDDDDD),
    .rxdfecfokfen_in(8'H00),
    .rxdfecfokfpulse_in(8'H00),
    .rxdfecfokhold_in(8'H00),
    .rxdfecfokovren_in(8'H00),
    .rxdfekhhold_in(8'H00),
    .rxdfekhovrden_in(8'H00),
    .rxdfelfhold_in(8'H00),
    .rxdfelfovrden_in(8'H00),
    .rxdfelpmreset_in(8'H00),
    .rxdfetap10hold_in(8'H00),
    .rxdfetap10ovrden_in(8'H00),
    .rxdfetap11hold_in(8'H00),
    .rxdfetap11ovrden_in(8'H00),
    .rxdfetap12hold_in(8'H00),
    .rxdfetap12ovrden_in(8'H00),
    .rxdfetap13hold_in(8'H00),
    .rxdfetap13ovrden_in(8'H00),
    .rxdfetap14hold_in(8'H00),
    .rxdfetap14ovrden_in(8'H00),
    .rxdfetap15hold_in(8'H00),
    .rxdfetap15ovrden_in(8'H00),
    .rxdfetap2hold_in(8'H00),
    .rxdfetap2ovrden_in(8'H00),
    .rxdfetap3hold_in(8'H00),
    .rxdfetap3ovrden_in(8'H00),
    .rxdfetap4hold_in(8'H00),
    .rxdfetap4ovrden_in(8'H00),
    .rxdfetap5hold_in(8'H00),
    .rxdfetap5ovrden_in(8'H00),
    .rxdfetap6hold_in(8'H00),
    .rxdfetap6ovrden_in(8'H00),
    .rxdfetap7hold_in(8'H00),
    .rxdfetap7ovrden_in(8'H00),
    .rxdfetap8hold_in(8'H00),
    .rxdfetap8ovrden_in(8'H00),
    .rxdfetap9hold_in(8'H00),
    .rxdfetap9ovrden_in(8'H00),
    .rxdfeuthold_in(8'H00),
    .rxdfeutovrden_in(8'H00),
    .rxdfevphold_in(8'H00),
    .rxdfevpovrden_in(8'H00),
    .rxdfevsen_in(1'B0),
    .rxdfexyden_in(8'HFF),
    .rxdlybypass_in(8'HFF),
    .rxdlyen_in(8'H00),
    .rxdlyovrden_in(8'H00),
    .rxdlysreset_in(8'H00),
    .rxelecidlemode_in(16'HFFFF),
    .rxeqtraining_in(8'H00),
    .rxgearboxslip_in(8'H00),
    .rxlatclk_in(8'H00),
    .rxlpmen_in(8'H00),
    .rxlpmgchold_in(8'H00),
    .rxlpmgcovrden_in(8'H00),
    .rxlpmhfhold_in(8'H00),
    .rxlpmhfovrden_in(8'H00),
    .rxlpmlfhold_in(8'H00),
    .rxlpmlfklovrden_in(8'H00),
    .rxlpmoshold_in(8'H00),
    .rxlpmosovrden_in(8'H00),
    .rxmcommaalignen_in(8'H00),
    .rxmonitorsel_in(16'H0000),
    .rxoobreset_in(8'H00),
    .rxoscalreset_in(8'H00),
    .rxoshold_in(8'H00),
    .rxosintcfg_in(1'B0),
    .rxosinten_in(1'B0),
    .rxosinthold_in(1'B0),
    .rxosintovrden_in(1'B0),
    .rxosintstrobe_in(1'B0),
    .rxosinttestovrden_in(1'B0),
    .rxosovrden_in(8'H00),
    .rxoutclksel_in(24'H492492),
    .rxpcommaalignen_in(8'H00),
    .rxpcsreset_in(8'H00),
    .rxpd_in(16'H0000),
    .rxphalign_in(8'H00),
    .rxphalignen_in(8'H00),
    .rxphdlypd_in(8'HFF),
    .rxphdlyreset_in(8'H00),
    .rxphovrden_in(1'B0),
    .rxpllclksel_in(16'HFFFF),
    .rxpmareset_in(8'H00),
    .rxpolarity_in(8'H00),
    .rxprbscntreset_in(8'H00),
    .rxprbssel_in(32'H00000000),
    .rxprogdivreset_in(8'H00),
    .rxqpien_in(1'B0),
    .rxrate_in(24'H000000),
    .rxratemode_in(8'H00),
    .rxslide_in(8'H00),
    .rxslipoutclk_in(8'H00),
    .rxslippma_in(8'H00),
    .rxsyncallin_in(8'H00),
    .rxsyncin_in(8'H00),
    .rxsyncmode_in(8'H00),
    .rxsysclksel_in(16'HAAAA),
    .rxtermination_in(8'H00),
    .rxuserrdy_in(8'HFF),
    .rxusrclk_in(rxusrclk_in),
    .rxusrclk2_in(rxusrclk2_in),
    .sigvalidclk_in(8'H00),
    .tstin_in(160'H0000000000000000000000000000000000000000),
    .tx8b10bbypass_in(64'H0000000000000000),
    .tx8b10ben_in(tx8b10ben_in),
    .txbufdiffctrl_in(1'B0),
    .txcominit_in(8'H00),
    .txcomsas_in(8'H00),
    .txcomwake_in(8'H00),
    .txctrl0_in(txctrl0_in),
    .txctrl1_in(txctrl1_in),
    .txctrl2_in(txctrl2_in),
    .txdata_in(1024'H0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000),
    .txdataextendrsvd_in(64'H0000000000000000),
    .txdccforcestart_in(8'H00),
    .txdccreset_in(8'H00),
    .txdeemph_in(16'H00),
    .txdetectrx_in(8'H00),
    .txdiffctrl_in(40'HC6318C6318),
    .txdiffpd_in(1'B0),
    .txdlybypass_in(8'HFF),
    .txdlyen_in(8'H00),
    .txdlyhold_in(8'H00),
    .txdlyovrden_in(8'H00),
    .txdlysreset_in(8'H00),
    .txdlyupdown_in(8'H00),
    .txelecidle_in(8'H00),
    .txelforcestart_in(1'B0),
    .txheader_in(48'H000000000000),
    .txinhibit_in(8'H00),
    .txlatclk_in(8'H00),
    .txlfpstreset_in(8'H00),
    .txlfpsu2lpexit_in(8'H00),
    .txlfpsu3wake_in(8'H00),
    .txmaincursor_in(56'HA142850A142850),
    .txmargin_in(24'H000000),
    .txmuxdcdexhold_in(8'H00),
    .txmuxdcdorwren_in(8'H00),
    .txoneszeros_in(8'H00),
    .txoutclksel_in(24'H492492),
    .txpcsreset_in(8'H00),
    .txpd_in(16'H0000),
    .txpdelecidlemode_in(8'H00),
    .txphalign_in(8'H00),
    .txphalignen_in(8'H00),
    .txphdlypd_in(8'HFF),
    .txphdlyreset_in(8'H00),
    .txphdlytstclk_in(8'H00),
    .txphinit_in(8'H00),
    .txphovrden_in(8'H00),
    .txpippmen_in(8'H00),
    .txpippmovrden_in(8'H00),
    .txpippmpd_in(8'H00),
    .txpippmsel_in(8'HFF),
    .txpippmstepsize_in(40'H0000000000),
    .txpisopd_in(8'H00),
    .txpllclksel_in(16'HFFFF),
    .txpmareset_in(8'H00),
    .txpolarity_in(8'H00),
    .txpostcursor_in(40'H0000000000),
    .txpostcursorinv_in(1'B0),
    .txprbsforceerr_in(8'H00),
    .txprbssel_in(32'H00000000),
    .txprecursor_in(40'H0000000000),
    .txprecursorinv_in(1'B0),
    .txprogdivreset_in(8'H00),
    .txqpibiasen_in(1'B0),
    .txqpistrongpdown_in(1'B0),
    .txqpiweakpup_in(1'B0),
    .txrate_in(24'H000000),
    .txratemode_in(8'H00),
    .txsequence_in(56'H00000000000000),
    .txswing_in(8'H00),
    .txsyncallin_in(8'H00),
    .txsyncin_in(8'H00),
    .txsyncmode_in(8'H00),
    .txsysclksel_in(16'HAAAA),
    .txuserrdy_in(8'HFF),
    .txusrclk_in(txusrclk_in),
    .txusrclk2_in(txusrclk2_in),
    .bufgtce_out(),
    .bufgtcemask_out(),
    .bufgtdiv_out(),
    .bufgtreset_out(),
    .bufgtrstmask_out(),
    .cpllfbclklost_out(),
    .cplllock_out(),
    .cpllrefclklost_out(),
    .dmonitorout_out(),
    .dmonitoroutclk_out(),
    .drpdo_out(),
    .drprdy_out(),
    .eyescandataerror_out(),
    .gthtxn_out(),
    .gthtxp_out(),
    .gtpowergood_out(gtpowergood_out),
    .gtrefclkmonitor_out(),
    .gtytxn_out(gtytxn_out),
    .gtytxp_out(gtytxp_out),
    .pcierategen3_out(),
    .pcierateidle_out(),
    .pcierateqpllpd_out(),
    .pcierateqpllreset_out(),
    .pciesynctxsyncdone_out(),
    .pcieusergen3rdy_out(),
    .pcieuserphystatusrst_out(),
    .pcieuserratestart_out(),
    .pcsrsvdout_out(),
    .phystatus_out(),
    .pinrsrvdas_out(),
    .powerpresent_out(),
    .resetexception_out(),
    .rxbufstatus_out(),
    .rxbyteisaligned_out(),
    .rxbyterealign_out(),
    .rxcdrlock_out(),
    .rxcdrphdone_out(),
    .rxchanbondseq_out(),
    .rxchanisaligned_out(),
    .rxchanrealign_out(),
    .rxchbondo_out(),
    .rxckcaldone_out(),
    .rxclkcorcnt_out(),
    .rxcominitdet_out(),
    .rxcommadet_out(),
    .rxcomsasdet_out(),
    .rxcomwakedet_out(),
    .rxctrl0_out(rxctrl0_out),
    .rxctrl1_out(rxctrl1_out),
    .rxctrl2_out(rxctrl2_out),
    .rxctrl3_out(rxctrl3_out),
    .rxdata_out(),
    .rxdataextendrsvd_out(),
    .rxdatavalid_out(),
    .rxdlysresetdone_out(),
    .rxelecidle_out(),
    .rxheader_out(),
    .rxheadervalid_out(),
    .rxlfpstresetdet_out(),
    .rxlfpsu2lpexitdet_out(),
    .rxlfpsu3wakedet_out(),
    .rxmonitorout_out(),
    .rxosintdone_out(),
    .rxosintstarted_out(),
    .rxosintstrobedone_out(),
    .rxosintstrobestarted_out(),
    .rxoutclk_out(rxoutclk_out),
    .rxoutclkfabric_out(),
    .rxoutclkpcs_out(),
    .rxphaligndone_out(),
    .rxphalignerr_out(),
    .rxpmaresetdone_out(rxpmaresetdone_out),
    .rxprbserr_out(),
    .rxprbslocked_out(),
    .rxprgdivresetdone_out(),
    .rxqpisenn_out(),
    .rxqpisenp_out(),
    .rxratedone_out(),
    .rxrecclkout_out(),
    .rxresetdone_out(),
    .rxsliderdy_out(),
    .rxslipdone_out(),
    .rxslipoutclkrdy_out(),
    .rxslippmardy_out(),
    .rxstartofseq_out(),
    .rxstatus_out(),
    .rxsyncdone_out(),
    .rxsyncout_out(),
    .rxvalid_out(),
    .txbufstatus_out(),
    .txcomfinish_out(),
    .txdccdone_out(),
    .txdlysresetdone_out(),
    .txoutclk_out(txoutclk_out),
    .txoutclkfabric_out(),
    .txoutclkpcs_out(),
    .txphaligndone_out(),
    .txphinitdone_out(),
    .txpmaresetdone_out(txpmaresetdone_out),
    .txprgdivresetdone_out(),
    .txqpisenn_out(),
    .txqpisenp_out(),
    .txratedone_out(),
    .txresetdone_out(),
    .txsyncdone_out(),
    .txsyncout_out()
  );
endmodule