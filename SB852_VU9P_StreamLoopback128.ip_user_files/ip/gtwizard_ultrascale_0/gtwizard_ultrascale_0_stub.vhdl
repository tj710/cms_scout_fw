-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
-- Date        : Fri Feb 14 17:56:56 2020
-- Host        : daqlab40-skylake16 running 64-bit CentOS Linux release 7.6.1810 (Core)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/tjames/StreamLoopback128/firmware/SB852_VU9P_StreamLoopback128/SB852_VU9P_StreamLoopback128.srcs/sources_1/ip/gtwizard_ultrascale_0/gtwizard_ultrascale_0_stub.vhdl
-- Design      : gtwizard_ultrascale_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu9p-flgb2104-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gtwizard_ultrascale_0 is
  Port ( 
    gtwiz_userclk_tx_active_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_userclk_rx_active_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_clk_freerun_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_all_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_pll_and_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_pll_and_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_cdr_stable_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_done_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_done_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_userdata_tx_in : in STD_LOGIC_VECTOR ( 255 downto 0 );
    gtwiz_userdata_rx_out : out STD_LOGIC_VECTOR ( 255 downto 0 );
    gtrefclk00_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    qpll0outclk_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    qpll0outrefclk_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gtyrxn_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gtyrxp_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    rx8b10ben_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    rxusrclk_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    rxusrclk2_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    tx8b10ben_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    txctrl0_in : in STD_LOGIC_VECTOR ( 127 downto 0 );
    txctrl1_in : in STD_LOGIC_VECTOR ( 127 downto 0 );
    txctrl2_in : in STD_LOGIC_VECTOR ( 63 downto 0 );
    txusrclk_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    txusrclk2_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gtpowergood_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gtytxn_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gtytxp_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    rxctrl0_out : out STD_LOGIC_VECTOR ( 127 downto 0 );
    rxctrl1_out : out STD_LOGIC_VECTOR ( 127 downto 0 );
    rxctrl2_out : out STD_LOGIC_VECTOR ( 63 downto 0 );
    rxctrl3_out : out STD_LOGIC_VECTOR ( 63 downto 0 );
    rxoutclk_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    rxpmaresetdone_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    txoutclk_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    txpmaresetdone_out : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end gtwizard_ultrascale_0;

architecture stub of gtwizard_ultrascale_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "gtwiz_userclk_tx_active_in[0:0],gtwiz_userclk_rx_active_in[0:0],gtwiz_reset_clk_freerun_in[0:0],gtwiz_reset_all_in[0:0],gtwiz_reset_tx_pll_and_datapath_in[0:0],gtwiz_reset_tx_datapath_in[0:0],gtwiz_reset_rx_pll_and_datapath_in[0:0],gtwiz_reset_rx_datapath_in[0:0],gtwiz_reset_rx_cdr_stable_out[0:0],gtwiz_reset_tx_done_out[0:0],gtwiz_reset_rx_done_out[0:0],gtwiz_userdata_tx_in[255:0],gtwiz_userdata_rx_out[255:0],gtrefclk00_in[1:0],qpll0outclk_out[1:0],qpll0outrefclk_out[1:0],gtyrxn_in[7:0],gtyrxp_in[7:0],rx8b10ben_in[7:0],rxusrclk_in[7:0],rxusrclk2_in[7:0],tx8b10ben_in[7:0],txctrl0_in[127:0],txctrl1_in[127:0],txctrl2_in[63:0],txusrclk_in[7:0],txusrclk2_in[7:0],gtpowergood_out[7:0],gtytxn_out[7:0],gtytxp_out[7:0],rxctrl0_out[127:0],rxctrl1_out[127:0],rxctrl2_out[63:0],rxctrl3_out[63:0],rxoutclk_out[7:0],rxpmaresetdone_out[7:0],txoutclk_out[7:0],txpmaresetdone_out[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "gtwizard_ultrascale_0_gtwizard_top,Vivado 2019.2";
begin
end;
