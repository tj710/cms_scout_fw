//
// Copyright (c) 2009-2017 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
//

`timescale 1ns / 1ps

`include "PicoDefines.v"

//// each board should use its own hmc_defines.v
//`ifdef ENABLE_HMC
//    `include "hmc_defines.v"
//`endif
//
//// each board should use its own ddr_defines.v
//`ifdef ENABLE_DDR
//    `include "ddr_defines.v"
//`endif



// *********************************************************
// Pico_Toplevel
//
// Macro defs:
//     PICOBUS_WIDTH       : enable pico bus
//     PICO_DDR3_OR_DDR4   : enable ddr memory interface
//     PICO_DDR3           : enable ddr3 memory interface
//     PICO_DDR4           : enable ddr4 memory interface
//     ENABLE_HMC          : enable hmc controller
//     ENABLE_2ND_HMC_LINK : enable 2nd hmc link (controller)
//     ENABLE_3RD_HMC_LINK : enable 3rd hmc link (controller)
//     ENABLE_4TH_HMC_LINK : enable 4th hmc link (controller)
//     USE_512_BIT_HMC_CONTROLLER : use the 1x512+1x128 port hmc controller, else use 5x128
//     LED                 : led?
// *********************************************************

module Pico_Toplevel # (

`ifdef PCIE_GEN3X16
    parameter PL_LINK_CAP_MAX_LINK_WIDTH = 16,  // 1- X1, 2 - X2, 4 - X4, 8 - X8, 16 - X16
`else
    parameter PL_LINK_CAP_MAX_LINK_WIDTH = 8,   // 1- X1, 2 - X2, 4 - X4, 8 - X8, 16 - X16
`endif
`ifdef PCIE_GEN3X8
    parameter PCIE_BUS_WIDTH            = 256,  // PCIe Bus Width (Gen3 x8)
`else // PCIE_GEN2X8
    parameter PCIE_BUS_WIDTH		= 128,	// PCIe Bus Width (Gen2 x8)
`endif // PCIE_GEN2X8
`ifdef PICO_DDR3_OR_DDR4
    ////////////////////////////
    // Shared DDR3 Parameters //
    ////////////////////////////
    parameter nCS_PER_RANK              = 1,
                                        // # of unique CS outputs per Rank for
                                        // phy.
    `ifdef PICO_DDR3
    parameter BANK_WIDTH                = 3,
    `elsif PICO_DDR4
    parameter BANK_WIDTH                = 2,
    `endif // PICO_DDR4
                                        // # of memory Bank Address bits.
    parameter C0_C_S_AXI_ID_WIDTH       = 12,
                                        // Width of all master and slave ID signals.
                                        // # = >= 1.
    `ifdef PICO_MODEL_EX800
    parameter C0_C_S_AXI_ADDR_WIDTH     = 32,
    `elsif PICO_MODEL_M520
    parameter C0_C_S_AXI_ADDR_WIDTH     = 34,
    `elsif PICO_MODEL_AC511
    parameter C0_C_S_AXI_ADDR_WIDTH     = 34,
    `elsif PICO_MODEL_EAGLE5
    parameter C0_C_S_AXI_ADDR_WIDTH     = 34,
    `elsif SB852_16G
    parameter C0_C_S_AXI_ADDR_WIDTH     = 36,
    `elsif SB852_32G
    parameter C0_C_S_AXI_ADDR_WIDTH     = 37,
    `elsif SB852_64G
    parameter C0_C_S_AXI_ADDR_WIDTH     = 38,
    `elsif SB852_128G
    parameter C0_C_S_AXI_ADDR_WIDTH     = 39,
    `else // other PICO_MODEL
    parameter C0_C_S_AXI_ADDR_WIDTH     = 33,
    `endif // other PICO_MODEL
                                        // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                        // M_AXI_ARADDR for all SI/MI slots.
                                        // # = 32.
    `ifdef PICO_DDR3
    parameter RST_ACT_LOW               = 0,
                                        // =1 for active low reset,
                                        // =0 for active high.
    `endif // PICO_DDR3
    parameter COL_WIDTH                 = 10,
                                        // bits of the address used to select a column
    //////////////////////////
    // M505 DDR3 Parameters //
    //////////////////////////
    `ifdef PICO_MODEL_M505
    parameter ROW_WIDTH                 = 16,
                                        // # of memory Row Address bits.
    parameter CK_WIDTH                  = 2,    // -> 2 CBO
                                        // # of CK/CK# outputs to memory.
    parameter CS_WIDTH                  = 2,    // -> 2 CBO
                                        // # of unique CS outputs to memory.
    parameter CKE_WIDTH                 = 2,    // -> 2 CBO
                                        // # of CKE outputs to memory.
    parameter DQ_WIDTH                  = 64,
                                        // # of DQ (data)
    parameter DM_WIDTH                  = 8,
                                        // # of DM (data mask)
    parameter DQS_WIDTH                 = 8,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter RANKS                     = 2,
                                        // number of ranks
    parameter ODT_WIDTH                 = 2,
                                        // # of ODT outputs to memory.

    //***************************************************************************
    // AXI4 Shim parameters
    //***************************************************************************
    parameter C0_C_S_AXI_DATA_WIDTH     = 256,
                                        // Width of WDATA and RDATA on SI slot.
                                        // Must be <= APP_DATA_WIDTH.
                                        // # = 32, 64, 128, 256.
    parameter C_RD_WR_ARB_ALGORITHM     = "RD_PRI_REG",
                                        // Indicates the Arbitration
                                        // Allowed values - "TDM", "ROUND_ROBIN",
                                        // "RD_PRI_REG", "RD_PRI_REG_STARVE_LIMIT"
    `elsif PICO_MODEL_AC511

    // parameter  BANK_WIDTH      =        2 ,
    // parameter  nCS_PER_RANK    =        1 ,

    parameter  ROW_WIDTH       =       17 ,
                                        // # of memory Row Address bits.
    parameter  CKE_WIDTH       =        2 ,
                                        // # of CKE outputs to memory.
    parameter  ODT_WIDTH       =        2 ,
                                        // # of ODT outputs to memory.
    parameter  DQ_WIDTH        =       72 ,
                                        // # of DQ (data)
    parameter  DQS_WIDTH       =        9 ,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter  DBI_WIDTH       =        9 ,

    parameter  CK_WIDTH        =        2 ,
                                        // # of CK/CK# outputs to memory.
    parameter C0_C_S_AXI_DATA_WIDTH     = 256,

    `elsif PICO_MODEL_EAGLE5

    // parameter  BANK_WIDTH      =        2 ,
    // parameter  nCS_PER_RANK    =        1 ,

    parameter  ROW_WIDTH       =       17 ,
                                        // # of memory Row Address bits.
    parameter  CKE_WIDTH       =        2 ,
                                        // # of CKE outputs to memory.
    parameter  ODT_WIDTH       =        2 ,
                                        // # of ODT outputs to memory.
    parameter  DQ_WIDTH        =       72 ,
                                        // # of DQ (data)
    parameter  DQS_WIDTH       =        9 ,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter  DBI_WIDTH       =        9 ,

    parameter  CK_WIDTH        =        2 ,
                                        // # of CK/CK# outputs to memory.
    parameter C0_C_S_AXI_DATA_WIDTH     = 256,

    `elsif PICO_MODEL_SB852
    parameter  ROW_WIDTH             =  17 ,
                                        // # of memory Row Address bits.
    parameter  CKE_WIDTH             =   2 ,
                                        // # of CKE outputs to memory.
    parameter  ODT_WIDTH             =   2 ,
                                        // # of ODT outputs to memory.
    parameter  DQ_WIDTH              =  72 ,
                                        // # of DQ (data)
    `ifdef SB852_16G
    parameter  DQS_WIDTH             =   9 ,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter  DBI_WIDTH             =   9 ,
    `else
    parameter  DQS_WIDTH             =  18 ,
                                        // 32G, 64G, 128G
    `endif
    `ifdef SB852_64G
    parameter  CID_WIDTH             =   1 ,
    `elsif SB852_128G
    parameter  CID_WIDTH             =   2 ,
    `endif
    parameter  CK_WIDTH              =   1 ,
                                        // # of CK/CK# outputs to memory.
    parameter C0_C_S_AXI_DATA_WIDTH  = 256 ,

    `elsif PICO_MODEL_M506
    parameter AVL_ADDR_WIDTH            = 27,
    parameter AVL_DATA_WIDTH            = 512,
    parameter AVL_SIZE_WIDTH            = 9,

    parameter ROW_WIDTH                 = 16,
                                        // # of memory Row Address bits.
    parameter CK_WIDTH                  = 2,    // -> 2 CBO
                                        // # of CK/CK# outputs to memory.
    parameter CS_WIDTH                  = 2,    // -> 2 CBO
                                        // # of unique CS outputs to memory.
    parameter CKE_WIDTH                 = 2,    // -> 2 CBO
                                        // # of CKE outputs to memory.
    parameter DQ_WIDTH                  = 64,
                                        // # of DQ (data)
    parameter DM_WIDTH                  = 8,
                                        // # of DM (data mask)
    parameter DQS_WIDTH                 = 8,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter RANKS                     = 2,
                                        // number of ranks
    parameter ODT_WIDTH                 = 2,
                                        // # of ODT outputs to memory.
    parameter C0_C_S_AXI_DATA_WIDTH     = 256,
    `elsif PICO_MODEL_M520
    // controller interface 16 DDR4 = 2^28 * 512 / 8
    parameter AVL_ADDR_WIDTH            = 28,
    parameter AVL_DATA_WIDTH            = 512,
    parameter AVL_SIZE_WIDTH            = 7,

    // device interface, refer to the DDR4 sodimm
    parameter ROW_WIDTH                 = 17,
                                        // # of memory Row Address bits.
    parameter CK_WIDTH                  = 2,    // -> 2 CBO
                                        // # of CK/CK# outputs to memory.
    parameter CS_WIDTH                  = 2,    // -> 2 CBO
                                        // # of unique CS outputs to memory.
    parameter CKE_WIDTH                 = 2,    // -> 2 CBO
                                        // # of CKE outputs to memory.
    parameter DQ_WIDTH                  = 72,
                                        // # of DQ (data)
    parameter DM_WIDTH                  = 8,
                                        // # of DM (data mask)
    parameter DQS_WIDTH                 = 9,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter RANKS                     = 2,
                                        // number of ranks
    parameter ODT_WIDTH                 = 2,
                                        // # of ODT outputs to memory.
    parameter C0_C_S_AXI_DATA_WIDTH     = 256,
    `elsif PICO_MODEL_EX800
    parameter AVL_ADDR_WIDTH            = 26,
    parameter AVL_DATA_WIDTH            = 512,
    parameter AVL_SIZE_WIDTH            = 9,

    parameter ROW_WIDTH                 = 15,
                                        // # of memory Row Address bits.
    parameter CK_WIDTH                  = 2,    // -> 2 CBO
                                        // # of CK/CK# outputs to memory.
    parameter CS_WIDTH                  = 2,    // -> 2 CBO
                                        // # of unique CS outputs to memory.
    parameter CKE_WIDTH                 = 2,    // -> 2 CBO
                                        // # of CKE outputs to memory.
    parameter DQ_WIDTH                  = 72,
                                        // # of DQ (data)
    parameter DM_WIDTH                  = 9,
                                        // # of DM (data mask)
    parameter DQS_WIDTH                 = 9,
                                        // # of DQS/DQS# bits.
                                        // Number of DQS groups in I/O column #2.
    parameter RANKS                     = 2,
                                        // number of ranks
    parameter ODT_WIDTH                 = 2,
                                        // # of ODT outputs to memory.
    parameter C0_C_S_AXI_DATA_WIDTH     = 256,
    `endif // PICO_MODEL_EX800
`endif // PICO_DDR3_OR_DDR4

`ifdef LED
    `ifdef PICO_MODEL_M510
        parameter LED_NUM                 = 1,
    `endif //PICO_MODEL_M510
    `ifdef PICO_MODEL_M520
        parameter LED_NUM                 = 1,
    `endif //PICO_MODEL_M520
    `ifdef PICO_MODEL_AC511
        parameter LED_NUM                 = 1,
    `endif //PICO_MODEL_M510
`endif // LED

`ifdef ENABLE_HMC
    `ifdef ENABLE_4TH_HMC_LINK
    parameter C_NUM_LINK                = 4 ,
    `elsif ENABLE_3RD_HMC_LINK
    parameter C_NUM_LINK                = 3 ,
    `elsif ENABLE_2ND_HMC_LINK
    parameter C_NUM_LINK                = 2 ,
    `else
    parameter C_NUM_LINK                = 1 ,
    `endif

    `ifdef HALFLINK
    parameter C_LINK_WIDTH              = 8 ,
    `else
    parameter C_LINK_WIDTH              = 16 ,
    `endif

`ifdef PICO_MODEL_M520
    `ifdef ENABLE_4TH_HMC_LINK
    parameter C_NUM_REF_CLK             = 2 ,
    `elsif ENABLE_3RD_HMC_LINK
    parameter C_NUM_REF_CLK             = 2 ,
    `elsif ENABLE_2ND_HMC_LINK
    parameter C_NUM_REF_CLK             = 2 ,
    `else
    parameter C_NUM_REF_CLK             = 1 ,
    `endif
`else
    parameter C_NUM_REF_CLK             = C_NUM_LINK ,
`endif

`endif

    // Do not override parameters below this line
    parameter C_DATA_WIDTH              = PCIE_BUS_WIDTH,
                                        // RX/TX interface data width
    parameter STRB_WIDTH                = C_DATA_WIDTH / 8,
                                        // TSTRB width
    parameter S_PB_RATIO		= 62

)
(

`default_nettype none

`ifdef CONVEY_SIM
   `undef SIMULATION
`endif // CONVEY_SIM

`ifdef ENABLE_HMC

    input                         refclkp  [C_NUM_REF_CLK-1:0] ,
    input  [C_LINK_WIDTH-1:0]     lxrxp    [C_NUM_LINK-1:0] ,
    output [C_LINK_WIDTH-1:0]     lxtxp    [C_NUM_LINK-1:0] ,


    output [C_NUM_LINK-1:0]       lxrxps                    ,
    input  [C_NUM_LINK-1:0]       lxtxps                    ,

    output  [2:0]                 cub                       ,
    `ifndef PICO_MODEL_SB852
    output                        trst_n                    ,
    `endif
    // HMC Error Interrupt
    input                         ferr_n                    ,
    // HMC Global Reset
    output                        p_rst_n                   ,
    // HMC I2C
    inout                         scl                       ,
    inout                         sda                       ,

    `ifndef ALTERA_FPGA
    input                         refclkn  [C_NUM_REF_CLK-1:0] ,
    input  [C_LINK_WIDTH-1:0]     lxrxn    [C_NUM_LINK-1:0] ,
    output [C_LINK_WIDTH-1:0]     lxtxn    [C_NUM_LINK-1:0] ,
    `endif
    // -----------------------------------------------------
    // -----------------------------------------------------
    // System signals
    // -----------------------------------------------------



`endif // ENABLE_HMC

`ifdef SIMULATION
    input                               user_clk,
    input                               user_reset,
    input                               user_lnk_up,

    // Tx
    input  [5:0]                        tx_buf_av,
    input                               tx_cfg_req,
    input                               tx_err_drop,
    output                              tx_cfg_gnt,

    input                               s_axis_tx_tready,
    output  [C_DATA_WIDTH-1:0]          s_axis_tx_tdata,
    output  [STRB_WIDTH-1:0]            s_axis_tx_tstrb,
    output  [3:0]                       s_axis_tx_tuser,
    output                              s_axis_tx_tlast,
    output                              s_axis_tx_tvalid,

    // Rx
    output                              rx_np_ok,
    input  [C_DATA_WIDTH-1:0]           m_axis_rx_tdata,
    input  [STRB_WIDTH-1:0]             m_axis_rx_tstrb,
    input                               m_axis_rx_tlast,
    input                               m_axis_rx_tvalid,
    output                              m_axis_rx_tready,
    input  [21:0]                       m_axis_rx_tuser,

    // Flow Control
    input  [11:0]                       fc_cpld,
    input  [7:0]                        fc_cplh,
    input  [11:0]                       fc_npd,
    input  [7:0]                        fc_nph,
    input  [11:0]                       fc_pd,
    input  [7:0]                        fc_ph,
    output [2:0]                        fc_sel,
`else // !SIMULATION
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_txp,
    `ifndef ALTERA_FPGA
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_txn,
    `endif
    input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_rxp,
    `ifndef ALTERA_FPGA
    input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_rxn,
    `endif
`endif // !SIMULATION

`ifdef PICO_MODEL_M505
    // flash
    input                               flash_busy,
    output                              flash_byte,
    output                              flash_ce,
    output                              flash_oe,
    output                              flash_reset,
    output                              flash_we,
    output [25:0]                       flash_a,
    inout  [15:0]                       flash_d,
`endif // PICO_MODEL_M505

`ifdef PICO_DDR4

    `ifdef ALTERA_FPGA
    output  [CK_WIDTH-1:0]                c0_ddr4_ck,
    output  [CK_WIDTH-1:0]                c0_ddr4_ck_n,
    output  [ROW_WIDTH-1:0]               c0_ddr4_addr,
    output  [0:0]                         c0_ddr4_act_n,
    output  [BANK_WIDTH-1:0]              c0_ddr4_ba,
    output  [BANK_WIDTH-1:0]              c0_ddr4_bg,
    output  [CKE_WIDTH-1:0]               c0_ddr4_cke,
    output  [BANK_WIDTH*nCS_PER_RANK-1:0] c0_ddr4_cs_n,
    output  [ODT_WIDTH-1:0]               c0_ddr4_odt,
    output  [0:0]                         c0_ddr4_par,
    input   [0:0]                         c0_ddr4_alert_n,
    inout   [DQS_WIDTH-1:0]               c0_ddr4_dqs,
    inout   [DQS_WIDTH-1:0]               c0_ddr4_dqs_n,
    inout   [DQ_WIDTH-1:0]                c0_ddr4_dq,
    inout   [DQS_WIDTH-1:0]               c0_ddr4_dbi_n,
    input                                 c0_ddr4_ref_clk,
    output                                c0_ddr4_reset_n,
    input                                 c0_ddr4_oct_rzqin,

    `ifdef SIMULATION
    output                              c0_phy_init_done,
    `endif // !SIMULATION
    `elsif XILINX_FPGA

        `ifdef PICO_MODEL_SB852
            input  wire                                c0_sys_clk_n    ,
            input  wire                                c0_sys_clk_p    ,
            // input  wire                             c0_sys_rst_n    ,
            output wire                                c0_ddr4_act_n   ,
            output wire [ROW_WIDTH-1:0]                c0_ddr4_adr     ,
            output wire [BANK_WIDTH-1:0]               c0_ddr4_ba      ,
            output wire [BANK_WIDTH-1:0]               c0_ddr4_bg      ,
            output wire [CK_WIDTH-1:0]                 c0_ddr4_ck_c    ,
            output wire [CK_WIDTH-1:0]                 c0_ddr4_ck_t    ,
            output wire [CKE_WIDTH-1:0]                c0_ddr4_cke     ,
            output wire [BANK_WIDTH*nCS_PER_RANK-1:0]  c0_ddr4_cs_n    ,
            `ifdef SB852_16G
            inout  wire [DBI_WIDTH-1:0]                c0_ddr4_dm_n    ,
            `endif
            `ifdef SB852_64G
            output wire [CID_WIDTH-1:0]                c0_ddr4_c_id    ,
            `endif
            `ifdef SB852_128G
            output wire [CID_WIDTH-1:0]                c0_ddr4_c_id    ,
            `endif
            inout  wire [DQ_WIDTH-1:0]                 c0_ddr4_dq      ,
            inout  wire [DQS_WIDTH-1:0]                c0_ddr4_dqs_c   ,
            inout  wire [DQS_WIDTH-1:0]                c0_ddr4_dqs_t   ,
            output wire [ODT_WIDTH-1:0]                c0_ddr4_odt     ,
            output wire                                c0_ddr4_par     ,
            output wire                                c0_ddr4_reset_n ,

            input  wire                                c1_sys_clk_n    ,
            input  wire                                c1_sys_clk_p    ,
            // input  wire                             c1_sys_rst_n    ,
            output wire                                c1_ddr4_act_n   ,
            output wire [ROW_WIDTH-1:0]                c1_ddr4_adr     ,
            output wire [BANK_WIDTH-1:0]               c1_ddr4_ba      ,
            output wire [BANK_WIDTH-1:0]               c1_ddr4_bg      ,
            output wire [CK_WIDTH-1:0]                 c1_ddr4_ck_c    ,
            output wire [CK_WIDTH-1:0]                 c1_ddr4_ck_t    ,
            output wire [CKE_WIDTH-1:0]                c1_ddr4_cke     ,
            output wire [BANK_WIDTH*nCS_PER_RANK-1:0]  c1_ddr4_cs_n    ,
            `ifdef SB852_16G
            inout  wire [DBI_WIDTH-1:0]                c1_ddr4_dm_n    ,
            `endif
            `ifdef SB852_64G
            output wire [CID_WIDTH-1:0]                c1_ddr4_c_id    ,
            `endif
            `ifdef SB852_128G
            output wire [CID_WIDTH-1:0]                c1_ddr4_c_id    ,
            `endif
            inout  wire [DQ_WIDTH-1:0]                 c1_ddr4_dq      ,
            inout  wire [DQS_WIDTH-1:0]                c1_ddr4_dqs_c   ,
            inout  wire [DQS_WIDTH-1:0]                c1_ddr4_dqs_t   ,
            output wire [ODT_WIDTH-1:0]                c1_ddr4_odt     ,
            output wire                                c1_ddr4_par     ,
            output wire                                c1_ddr4_reset_n ,

            input  wire                                c2_sys_clk_n    ,
            input  wire                                c2_sys_clk_p    ,
            // input  wire                             c2_sys_rst_n    ,
            output wire                                c2_ddr4_act_n   ,
            output wire [ROW_WIDTH-1:0]                c2_ddr4_adr     ,
            output wire [BANK_WIDTH-1:0]               c2_ddr4_ba      ,
            output wire [BANK_WIDTH-1:0]               c2_ddr4_bg      ,
            output wire [CK_WIDTH-1:0]                 c2_ddr4_ck_c    ,
            output wire [CK_WIDTH-1:0]                 c2_ddr4_ck_t    ,
            output wire [CKE_WIDTH-1:0]                c2_ddr4_cke     ,
            output wire [BANK_WIDTH*nCS_PER_RANK-1:0]  c2_ddr4_cs_n    ,
            `ifdef SB852_16G
            inout  wire [DBI_WIDTH-1:0]                c2_ddr4_dm_n    ,
            `endif
            `ifdef SB852_64G
            output wire [CID_WIDTH-1:0]                c2_ddr4_c_id    ,
            `endif
            `ifdef SB852_128G
            output wire [CID_WIDTH-1:0]                c2_ddr4_c_id    ,
            `endif
            inout  wire [DQ_WIDTH-1:0]                 c2_ddr4_dq      ,
            inout  wire [DQS_WIDTH-1:0]                c2_ddr4_dqs_c   ,
            inout  wire [DQS_WIDTH-1:0]                c2_ddr4_dqs_t   ,
            output wire [ODT_WIDTH-1:0]                c2_ddr4_odt     ,
            output wire                                c2_ddr4_par     ,
            output wire                                c2_ddr4_reset_n ,

            input  wire                                c3_sys_clk_n    ,
            input  wire                                c3_sys_clk_p    ,
            // input  wire                             c3_sys_rst_n    ,
            output wire                                c3_ddr4_act_n   ,
            output wire [ROW_WIDTH-1:0]                c3_ddr4_adr     ,
            output wire [BANK_WIDTH-1:0]               c3_ddr4_ba      ,
            output wire [BANK_WIDTH-1:0]               c3_ddr4_bg      ,
            output wire [CK_WIDTH-1:0]                 c3_ddr4_ck_c    ,
            output wire [CK_WIDTH-1:0]                 c3_ddr4_ck_t    ,
            output wire [CKE_WIDTH-1:0]                c3_ddr4_cke     ,
            output wire [BANK_WIDTH*nCS_PER_RANK-1:0]  c3_ddr4_cs_n    ,
            `ifdef SB852_16G
            inout  wire [DBI_WIDTH-1:0]                c3_ddr4_dm_n    ,
            `endif
            `ifdef SB852_64G
            output wire [CID_WIDTH-1:0]                c3_ddr4_c_id    ,
            `endif
            `ifdef SB852_128G
            output wire [CID_WIDTH-1:0]                c3_ddr4_c_id    ,
            `endif
            inout  wire [DQ_WIDTH-1:0]                 c3_ddr4_dq      ,
            inout  wire [DQS_WIDTH-1:0]                c3_ddr4_dqs_c   ,
            inout  wire [DQS_WIDTH-1:0]                c3_ddr4_dqs_t   ,
            output wire [ODT_WIDTH-1:0]                c3_ddr4_odt     ,
            output wire                                c3_ddr4_par     ,
            output wire                                c3_ddr4_reset_n ,
        `else
                
            output [0:0]                            c0_ddr4_act_n     ,
            output [ROW_WIDTH-1:0]                  c0_ddr4_addr      ,
            output [BANK_WIDTH-1:0]                 c0_ddr4_ba        ,
            output [BANK_WIDTH-1:0]                 c0_ddr4_bg        ,
            output [CKE_WIDTH-1:0]                  c0_ddr4_cke       ,
            output [ODT_WIDTH-1:0]                  c0_ddr4_odt       ,
            output [BANK_WIDTH*nCS_PER_RANK-1:0]    c0_ddr4_cs_n      ,
            output [CK_WIDTH-1:0]                   c0_ddr4_ck_t      ,
            output [CK_WIDTH-1:0]                   c0_ddr4_ck_c      ,
            output                                  c0_ddr4_reset_n   ,
            inout  [DBI_WIDTH-1:0]                  c0_ddr4_dm_dbi_n  ,
            inout  [DQ_WIDTH-1:0]                   c0_ddr4_dq        ,
            inout  [DQS_WIDTH-1:0]                  c0_ddr4_dqs_t     ,
            inout  [DQS_WIDTH-1:0]                  c0_ddr4_dqs_c     ,
            input                                   c0_sys_clk_p      ,
            input                                   c0_sys_clk_n      ,
        `endif
    `endif

`endif // PICO_DDR4

`ifdef PICO_DDR3

    inout  [DQ_WIDTH-1:0]               c0_ddr3_dq,
    output [ROW_WIDTH-1:0]              c0_ddr3_addr,
    output [BANK_WIDTH-1:0]             c0_ddr3_ba,
    output                              c0_ddr3_ras_n,
    output                              c0_ddr3_cas_n,
    output                              c0_ddr3_we_n,
    output                              c0_ddr3_reset_n,
    output [DM_WIDTH-1:0]               c0_ddr3_dm,
    inout  [DQS_WIDTH-1:0]              c0_ddr3_dqs_p,
    inout  [DQS_WIDTH-1:0]              c0_ddr3_dqs_n,
    output [CK_WIDTH-1:0]               c0_ddr3_ck_p,
    output [CK_WIDTH-1:0]               c0_ddr3_ck_n,
    output [CS_WIDTH*nCS_PER_RANK-1:0]  c0_ddr3_cs_n,
    `ifdef PICO_MODEL_M505
    output [ODT_WIDTH-1:0]              c0_ddr3_odt,
    `elsif ALTERA_FPGA
    output [ODT_WIDTH-1:0]              c0_ddr3_odt,
    input                               c0_ddr3_oct_rzqin,
    input                               c0_ddr3_mem_refclk,
    `else // other Xilinx FPGA
    output [CS_WIDTH*nCS_PER_RANK-1:0]  c0_ddr3_odt,
    `endif // other Xilinx FPGA
    output [CKE_WIDTH-1:0]              c0_ddr3_cke,
    `ifdef SIMULATION
    output                              c0_phy_init_done,
    `endif // SIMULATION
`endif // PICO_DDR3

`ifdef PICO_MODEL_M505
    input                               clk_400_p,
    input                               clk_400_n,  // 400 MHz differential clock inputs used to
                                                    //  generate the DDR3 interface clocks in the
                                                    //  MIG
`endif // PICO_MODEL_M505

`ifdef LED
    output  [LED_NUM-1:0]               led_r,
    output  [LED_NUM-1:0]               led_g,
    output  [LED_NUM-1:0]               led_b,
`endif

    input                               sys_clk_p,
    // extra clk
    input                               extra_clk_p    ,  // 200 MHz for 510
`ifndef ALTERA_FPGA
    input                               sys_clk_n,
    input                               extra_clk_n    ,  // 200 MHz for 510
`endif
    input                               sys_reset_n

`ifdef PICO_MODEL_SB852
    ,
    inout                               i2c_sda,
    inout                               i2c_scl
`endif

);

    localparam OW_DVLD_W = (C_DATA_WIDTH==256)?'h2:'h1;

    wire                                s_clk;
    wire                                s_rst;

    wire [C_DATA_WIDTH-1:0]		s_in_data;
    wire [OW_DVLD_W-1:0]		s_in_ow_dvld;
    wire [8:0]                          s_in_id;
    wire                                s_in_valid;

    wire [OW_DVLD_W-1:0]                s_out_en;
    wire [8:0]                          s_out_id;
    wire [C_DATA_WIDTH-1:0]		s_out_data;
    wire [OW_DVLD_W-1:0]		s_out_ow_dvld;

    wire [8:0]                          s_poll_id;
    wire [31:0]                         s_poll_seq;
    wire                                s_poll_next_desc_valid;
    wire [127:0]                        s_poll_next_desc;

    wire                                s_next_desc_rd_en;
    wire [8:0]                          s_next_desc_rd_id;

    wire [9:0]                          temp;

    wire				pcie_reset_f;

`ifdef PICOBUS_WIDTH
    wire [7:0]                          UserPBWidth = `PICOBUS_WIDTH;
`else
    wire [7:0]                          UserPBWidth = 0;
`endif // PICOBUS_WIDTH

`ifdef ENABLE_HMC
    `ifdef PICO_MODEL_SB852
    wire                                trst_n;
    `endif
    wire                                PicoClk;
    wire                                PicoRst;
    wire [31:0]                         PicoAddr;
    wire [127:0]                        PicoDataIn;
    wire                                PicoRd;
    wire                                PicoWr;

    wire [127:0]                        hmc0_PicoDataOut;
    wire [31:0]                         hmc0_PicoAddr;
    wire                                hmc0_PicoRd;
    wire                                hmc0_PicoWr;
    wire                                hmc0_tx_clk;
    wire                                hmc0_rx_clk;
    wire                                hmc0_rst;
    wire                                hmc0_trained;

    wire [127:0]                        hmc1_PicoDataOut;
    wire                                hmc1_rst;
    wire                                hmc1_trained;
    `ifdef ENABLE_2ND_HMC_LINK
    wire [31:0]                         hmc1_PicoAddr;
    wire                                hmc1_PicoRd;
    wire                                hmc1_PicoWr;
    wire                                hmc1_tx_clk;
    wire                                hmc1_rx_clk;
    `endif // ENABLE_2ND_HMC_LINK

    wire [127:0]                        hmc2_PicoDataOut;
    wire                                hmc2_rst;
    wire                                hmc2_trained;
    `ifdef ENABLE_3RD_HMC_LINK
    wire [31:0]                         hmc2_PicoAddr;
    wire                                hmc2_PicoRd;
    wire                                hmc2_PicoWr;
    wire                                hmc2_tx_clk;
    wire                                hmc2_rx_clk;
    `endif // ENABLE_3RD_HMC_LINK

    wire [127:0]                        hmc3_PicoDataOut;
    wire                                hmc3_rst;
    wire                                hmc3_trained;
    `ifdef ENABLE_4TH_HMC_LINK
    wire [31:0]                         hmc3_PicoAddr;
    wire                                hmc3_PicoRd;
    wire                                hmc3_PicoWr;
    wire                                hmc3_tx_clk;
    wire                                hmc3_rx_clk;
    `endif // ENABLE_4TH_HMC_LINK

    wire            hmc_cmd_valid_p0;
    wire            hmc_wr_data_valid_p0;
    wire   [3:0]    hmc_cmd_p0;
    wire            hmc_rd_data_valid_p0;
    wire            hmc_clk_p0;
    wire  [33:0]    hmc_addr_p0;
    wire   [3:0]    hmc_size_p0;
    wire [127:0]    hmc_wr_data_p0;
    wire [127:0]    hmc_rd_data_p0;
    wire            hmc_wr_data_ready_p0, hmc_cmd_ready_p0;
    wire   [5:0]    hmc_tag_p0, hmc_rd_data_tag_p0;
    wire   [6:0]    hmc_errstat_p0;
    wire            hmc_dinv_p0;

    `ifdef USE_512_BIT_HMC_CONTROLLER
    wire                          hmc_clk_p1;
    wire   [7:0]                  axi_stride_num_p1;
    wire   [33:0]                 axi_stride_p1;
    wire                          axi_awready_p1;
    wire                          axi_awvalid_p1;
    wire   [7:0]                  axi_awid_p1;
    wire   [33:0]                 axi_awaddr_p1;
    wire   [7:0]                  axi_awlen_p1;
    wire   [2:0]                  axi_awsize_p1;
    wire   [1:0]                  axi_awburst_p1;
    wire                          axi_awlock_p1;
    wire   [3:0]                  axi_awcache_p1;
    wire   [2:0]                  axi_awprot_p1;
    wire   [3:0]                  axi_awqos_p1;

    wire   [511:0]                axi_wdata_p1;
    wire   [512/8-1:0]            axi_wstrb_p1;
    wire   [7:0]                  axi_wid_p1;
    wire                          axi_wready_p1;
    wire                          axi_wvalid_p1;
    wire                          axi_wlast_p1;

    wire   [7:0]                  axi_bid_p1;
    wire   [1:0]                  axi_bresp_p1;
    wire                          axi_bvalid_p1;
    wire                          axi_bready_p1;

    wire                          axi_arready_p1;
    wire                          axi_arvalid_p1;
    wire   [7:0]                  axi_arid_p1;
    wire   [33:0]                 axi_araddr_p1;
    wire   [7:0]                  axi_arlen_p1;
    wire   [2:0]                  axi_arsize_p1;
    wire   [1:0]                  axi_arburst_p1;
    wire                          axi_arlock_p1;
    wire   [3:0]                  axi_arcache_p1;
    wire   [2:0]                  axi_arprot_p1;
    wire   [3:0]                  axi_arqos_p1;

    wire   [7:0]                  axi_rid_p1;
    wire   [1:0]                  axi_rresp_p1;
    wire   [511:0]                axi_rdata_p1;
    wire                          axi_rlast_p1;
    wire                          axi_rvalid_p1;
    wire                          axi_rready_p1;

    wire                          tags_almostempty_p1;

    `ifdef ENABLE_2ND_HMC_LINK
    wire                          hmc_cmd_valid_p2;
    wire                          hmc_wr_data_valid_p2;
    wire   [3:0]                  hmc_cmd_p2;
    wire                          hmc_rd_data_valid_p2;
    wire                          hmc_clk_p2;
    wire   [33:0]                 hmc_addr_p2;
    wire   [3:0]                  hmc_size_p2;
    wire   [127:0]                hmc_wr_data_p2;
    wire   [127:0]                hmc_rd_data_p2;
    wire                          hmc_wr_data_ready_p2, hmc_cmd_ready_p2;
    wire   [5:0]                  hmc_tag_p2, hmc_rd_data_tag_p2;
    wire   [6:0]                  hmc_errstat_p2;
    wire                          hmc_dinv_p2;

    wire                          hmc_clk_p3;
    wire   [7:0]                  axi_stride_num_p3;
    wire   [33:0]                 axi_stride_p3;
    wire                          axi_awready_p3;
    wire                          axi_awvalid_p3;
    wire   [7:0]                  axi_awid_p3;
    wire   [33:0]                 axi_awaddr_p3;
    wire   [7:0]                  axi_awlen_p3;
    wire   [2:0]                  axi_awsize_p3;
    wire   [1:0]                  axi_awburst_p3;
    wire                          axi_awlock_p3;
    wire   [3:0]                  axi_awcache_p3;
    wire   [2:0]                  axi_awprot_p3;
    wire   [3:0]                  axi_awqos_p3;

    wire   [511:0]                axi_wdata_p3;
    wire   [512/8-1:0]            axi_wstrb_p3;
    wire   [7:0]                  axi_wid_p3;
    wire                          axi_wready_p3;
    wire                          axi_wvalid_p3;
    wire                          axi_wlast_p3;

    wire   [7:0]                  axi_bid_p3;
    wire   [1:0]                  axi_bresp_p3;
    wire                          axi_bvalid_p3;
    wire                          axi_bready_p3;

    wire                          axi_arready_p3;
    wire                          axi_arvalid_p3;
    wire   [7:0]                  axi_arid_p3;
    wire   [33:0]                 axi_araddr_p3;
    wire   [7:0]                  axi_arlen_p3;
    wire   [2:0]                  axi_arsize_p3;
    wire   [1:0]                  axi_arburst_p3;
    wire                          axi_arlock_p3;
    wire   [3:0]                  axi_arcache_p3;
    wire   [2:0]                  axi_arprot_p3;
    wire   [3:0]                  axi_arqos_p3;

    wire   [7:0]                  axi_rid_p3;
    wire   [1:0]                  axi_rresp_p3;
    wire   [511:0]                axi_rdata_p3;
    wire                          axi_rlast_p3;
    wire                          axi_rvalid_p3;
    wire                          axi_rready_p3;

    wire                          tags_almostempty_p3;
    `endif //ENABLE_2ND_HMC_LINK

    `ifdef ENABLE_3RD_HMC_LINK
    wire                          hmc_cmd_valid_p4;
    wire                          hmc_wr_data_valid_p4;
    wire   [3:0]                  hmc_cmd_p4;
    wire                          hmc_rd_data_valid_p4;
    wire                          hmc_clk_p4;
    wire   [33:0]                 hmc_addr_p4;
    wire   [3:0]                  hmc_size_p4;
    wire   [127:0]                hmc_wr_data_p4;
    wire   [127:0]                hmc_rd_data_p4;
    wire                          hmc_wr_data_ready_p4, hmc_cmd_ready_p4;
    wire   [5:0]                  hmc_tag_p4, hmc_rd_data_tag_p4;
    wire   [6:0]                  hmc_errstat_p4;
    wire                          hmc_dinv_p4;

    wire                          hmc_clk_p5;
    wire   [7:0]                  axi_stride_num_p5;
    wire   [33:0]                 axi_stride_p5;
    wire                          axi_awready_p5;
    wire                          axi_awvalid_p5;
    wire   [7:0]                  axi_awid_p5;
    wire   [33:0]                 axi_awaddr_p5;
    wire   [7:0]                  axi_awlen_p5;
    wire   [2:0]                  axi_awsize_p5;
    wire   [1:0]                  axi_awburst_p5;
    wire                          axi_awlock_p5;
    wire   [3:0]                  axi_awcache_p5;
    wire   [2:0]                  axi_awprot_p5;
    wire   [3:0]                  axi_awqos_p5;

    wire   [511:0]                axi_wdata_p5;
    wire   [512/8-1:0]            axi_wstrb_p5;
    wire   [7:0]                  axi_wid_p5;
    wire                          axi_wready_p5;
    wire                          axi_wvalid_p5;
    wire                          axi_wlast_p5;

    wire   [7:0]                  axi_bid_p5;
    wire   [1:0]                  axi_bresp_p5;
    wire                          axi_bvalid_p5;
    wire                          axi_bready_p5;

    wire                          axi_arready_p5;
    wire                          axi_arvalid_p5;
    wire   [7:0]                  axi_arid_p5;
    wire   [33:0]                 axi_araddr_p5;
    wire   [7:0]                  axi_arlen_p5;
    wire   [2:0]                  axi_arsize_p5;
    wire   [1:0]                  axi_arburst_p5;
    wire                          axi_arlock_p5;
    wire   [3:0]                  axi_arcache_p5;
    wire   [2:0]                  axi_arprot_p5;
    wire   [3:0]                  axi_arqos_p5;

    wire   [7:0]                  axi_rid_p5;
    wire   [1:0]                  axi_rresp_p5;
    wire   [511:0]                axi_rdata_p5;
    wire                          axi_rlast_p5;
    wire                          axi_rvalid_p5;
    wire                          axi_rready_p5;

    wire                          tags_almostempty_p5;
    `endif //ENABLE_3RD_HMC_LINK

    `ifdef ENABLE_4TH_HMC_LINK
    wire                          hmc_cmd_valid_p6;
    wire                          hmc_wr_data_valid_p6;
    wire   [3:0]                  hmc_cmd_p6;
    wire                          hmc_rd_data_valid_p6;
    wire                          hmc_clk_p6;
    wire   [33:0]                 hmc_addr_p6;
    wire   [3:0]                  hmc_size_p6;
    wire   [127:0]                hmc_wr_data_p6;
    wire   [127:0]                hmc_rd_data_p6;
    wire                          hmc_wr_data_ready_p6, hmc_cmd_ready_p6;
    wire   [5:0]                  hmc_tag_p6, hmc_rd_data_tag_p6;
    wire   [6:0]                  hmc_errstat_p6;
    wire                          hmc_dinv_p6;

    wire                          hmc_clk_p7;
    wire   [7:0]                  axi_stride_num_p7;
    wire   [33:0]                 axi_stride_p7;
    wire                          axi_awready_p7;
    wire                          axi_awvalid_p7;
    wire   [7:0]                  axi_awid_p7;
    wire   [33:0]                 axi_awaddr_p7;
    wire   [7:0]                  axi_awlen_p7;
    wire   [2:0]                  axi_awsize_p7;
    wire   [1:0]                  axi_awburst_p7;
    wire                          axi_awlock_p7;
    wire   [3:0]                  axi_awcache_p7;
    wire   [2:0]                  axi_awprot_p7;
    wire   [3:0]                  axi_awqos_p7;

    wire   [511:0]                axi_wdata_p7;
    wire   [512/8-1:0]            axi_wstrb_p7;
    wire   [7:0]                  axi_wid_p7;
    wire                          axi_wready_p7;
    wire                          axi_wvalid_p7;
    wire                          axi_wlast_p7;

    wire   [7:0]                  axi_bid_p7;
    wire   [1:0]                  axi_bresp_p7;
    wire                          axi_bvalid_p7;
    wire                          axi_bready_p7;

    wire                          axi_arready_p7;
    wire                          axi_arvalid_p7;
    wire   [7:0]                  axi_arid_p7;
    wire   [33:0]                 axi_araddr_p7;
    wire   [7:0]                  axi_arlen_p7;
    wire   [2:0]                  axi_arsize_p7;
    wire   [1:0]                  axi_arburst_p7;
    wire                          axi_arlock_p7;
    wire   [3:0]                  axi_arcache_p7;
    wire   [2:0]                  axi_arprot_p7;
    wire   [3:0]                  axi_arqos_p7;

    wire   [7:0]                  axi_rid_p7;
    wire   [1:0]                  axi_rresp_p7;
    wire   [511:0]                axi_rdata_p7;
    wire                          axi_rlast_p7;
    wire                          axi_rvalid_p7;
    wire                          axi_rready_p7;

    wire                          tags_almostempty_p7;
    `endif //ENABLE_4TH_HMC_LINK

    `else //!USE_512_BIT_HMC_CONTROLLER
    wire            hmc_cmd_valid_p1;
    wire            hmc_wr_data_valid_p1;
    wire   [3:0]    hmc_cmd_p1;
    wire            hmc_rd_data_valid_p1;
    wire            hmc_clk_p1;
    wire  [33:0]    hmc_addr_p1;
    wire   [3:0]    hmc_size_p1;
    wire [127:0]    hmc_wr_data_p1;
    wire [127:0]    hmc_rd_data_p1;
    wire            hmc_wr_data_ready_p1, hmc_cmd_ready_p1;
    wire   [5:0]    hmc_tag_p1, hmc_rd_data_tag_p1;
    wire   [6:0]    hmc_errstat_p1;
    wire            hmc_dinv_p1;

    wire            hmc_cmd_valid_p2;
    wire            hmc_wr_data_valid_p2;
    wire   [3:0]    hmc_cmd_p2;
    wire            hmc_rd_data_valid_p2;
    wire            hmc_clk_p2;
    wire  [33:0]    hmc_addr_p2;
    wire   [3:0]    hmc_size_p2;
    wire [127:0]    hmc_wr_data_p2;
    wire [127:0]    hmc_rd_data_p2;
    wire            hmc_wr_data_ready_p2, hmc_cmd_ready_p2;
    wire   [5:0]    hmc_tag_p2, hmc_rd_data_tag_p2;
    wire   [6:0]    hmc_errstat_p2;
    wire            hmc_dinv_p2;

    wire            hmc_cmd_valid_p3;
    wire            hmc_wr_data_valid_p3;
    wire   [3:0]    hmc_cmd_p3;
    wire            hmc_rd_data_valid_p3;
    wire            hmc_clk_p3;
    wire  [33:0]    hmc_addr_p3;
    wire   [3:0]    hmc_size_p3;
    wire [127:0]    hmc_wr_data_p3;
    wire [127:0]    hmc_rd_data_p3;
    wire            hmc_wr_data_ready_p3, hmc_cmd_ready_p3;
    wire   [5:0]    hmc_tag_p3, hmc_rd_data_tag_p3;
    wire   [6:0]    hmc_errstat_p3;
    wire            hmc_dinv_p3;

    wire            hmc_cmd_valid_p4;
    wire            hmc_wr_data_valid_p4;
    wire   [3:0]    hmc_cmd_p4;
    wire            hmc_rd_data_valid_p4;
    wire            hmc_clk_p4;
    wire  [33:0]    hmc_addr_p4;
    wire   [3:0]    hmc_size_p4;
    wire [127:0]    hmc_wr_data_p4;
    wire [127:0]    hmc_rd_data_p4;
    wire            hmc_wr_data_ready_p4, hmc_cmd_ready_p4;
    wire   [5:0]    hmc_tag_p4, hmc_rd_data_tag_p4;
    wire   [6:0]    hmc_errstat_p4;
    wire            hmc_dinv_p4;

    `ifdef ENABLE_2ND_HMC_LINK
    wire            hmc_cmd_valid_p5;
    wire            hmc_wr_data_valid_p5;
    wire   [3:0]    hmc_cmd_p5;
    wire            hmc_rd_data_valid_p5;
    wire            hmc_clk_p5;
    wire  [33:0]    hmc_addr_p5;
    wire   [3:0]    hmc_size_p5;
    wire [127:0]    hmc_wr_data_p5;
    wire [127:0]    hmc_rd_data_p5;
    wire            hmc_wr_data_ready_p5, hmc_cmd_ready_p5;
    wire   [5:0]    hmc_tag_p5, hmc_rd_data_tag_p5;
    wire   [6:0]    hmc_errstat_p5;
    wire            hmc_dinv_p5;
    wire            hmc_cmd_valid_p6;
    wire            hmc_wr_data_valid_p6;
    wire   [3:0]    hmc_cmd_p6;
    wire            hmc_rd_data_valid_p6;
    wire            hmc_clk_p6;
    wire  [33:0]    hmc_addr_p6;
    wire   [3:0]    hmc_size_p6;
    wire [127:0]    hmc_wr_data_p6;
    wire [127:0]    hmc_rd_data_p6;
    wire            hmc_wr_data_ready_p6, hmc_cmd_ready_p6;
    wire   [5:0]    hmc_tag_p6, hmc_rd_data_tag_p6;
    wire   [6:0]    hmc_errstat_p6;
    wire            hmc_dinv_p6;
    wire            hmc_cmd_valid_p7;
    wire            hmc_wr_data_valid_p7;
    wire   [3:0]    hmc_cmd_p7;
    wire            hmc_rd_data_valid_p7;
    wire            hmc_clk_p7;
    wire  [33:0]    hmc_addr_p7;
    wire   [3:0]    hmc_size_p7;
    wire [127:0]    hmc_wr_data_p7;
    wire [127:0]    hmc_rd_data_p7;
    wire            hmc_wr_data_ready_p7, hmc_cmd_ready_p7;
    wire   [5:0]    hmc_tag_p7, hmc_rd_data_tag_p7;
    wire   [6:0]    hmc_errstat_p7;
    wire            hmc_dinv_p7;
    wire            hmc_cmd_valid_p8;
    wire            hmc_wr_data_valid_p8;
    wire   [3:0]    hmc_cmd_p8;
    wire            hmc_rd_data_valid_p8;
    wire            hmc_clk_p8;
    wire  [33:0]    hmc_addr_p8;
    wire   [3:0]    hmc_size_p8;
    wire [127:0]    hmc_wr_data_p8;
    wire [127:0]    hmc_rd_data_p8;
    wire            hmc_wr_data_ready_p8, hmc_cmd_ready_p8;
    wire   [5:0]    hmc_tag_p8, hmc_rd_data_tag_p8;
    wire   [6:0]    hmc_errstat_p8;
    wire            hmc_dinv_p8;
    wire            hmc_cmd_valid_p9;
    wire            hmc_wr_data_valid_p9;
    wire   [3:0]    hmc_cmd_p9;
    wire            hmc_rd_data_valid_p9;
    wire            hmc_clk_p9;
    wire  [33:0]    hmc_addr_p9;
    wire   [3:0]    hmc_size_p9;
    wire [127:0]    hmc_wr_data_p9;
    wire [127:0]    hmc_rd_data_p9;
    wire            hmc_wr_data_ready_p9, hmc_cmd_ready_p9;
    wire   [5:0]    hmc_tag_p9, hmc_rd_data_tag_p9;
    wire   [6:0]    hmc_errstat_p9;
    wire            hmc_dinv_p9;
    `endif // ENABLE_2ND_HMC_LINK
    `ifdef ENABLE_3RD_HMC_LINK
    wire            hmc_cmd_valid_p10;
    wire            hmc_wr_data_valid_p10;
    wire   [3:0]    hmc_cmd_p10;
    wire            hmc_rd_data_valid_p10;
    wire            hmc_clk_p10;
    wire  [33:0]    hmc_addr_p10;
    wire   [3:0]    hmc_size_p10;
    wire [127:0]    hmc_wr_data_p10;
    wire [127:0]    hmc_rd_data_p10;
    wire            hmc_wr_data_ready_p10, hmc_cmd_ready_p10;
    wire   [5:0]    hmc_tag_p10, hmc_rd_data_tag_p10;
    wire   [6:0]    hmc_errstat_p10;
    wire            hmc_dinv_p10;
    wire            hmc_cmd_valid_p11;
    wire            hmc_wr_data_valid_p11;
    wire   [3:0]    hmc_cmd_p11;
    wire            hmc_rd_data_valid_p11;
    wire            hmc_clk_p11;
    wire  [33:0]    hmc_addr_p11;
    wire   [3:0]    hmc_size_p11;
    wire [127:0]    hmc_wr_data_p11;
    wire [127:0]    hmc_rd_data_p11;
    wire            hmc_wr_data_ready_p11, hmc_cmd_ready_p11;
    wire   [5:0]    hmc_tag_p11, hmc_rd_data_tag_p11;
    wire   [6:0]    hmc_errstat_p11;
    wire            hmc_dinv_p11;
    wire            hmc_cmd_valid_p12;
    wire            hmc_wr_data_valid_p12;
    wire   [3:0]    hmc_cmd_p12;
    wire            hmc_rd_data_valid_p12;
    wire            hmc_clk_p12;
    wire  [33:0]    hmc_addr_p12;
    wire   [3:0]    hmc_size_p12;
    wire [127:0]    hmc_wr_data_p12;
    wire [127:0]    hmc_rd_data_p12;
    wire            hmc_wr_data_ready_p12, hmc_cmd_ready_p12;
    wire   [5:0]    hmc_tag_p12, hmc_rd_data_tag_p12;
    wire   [6:0]    hmc_errstat_p12;
    wire            hmc_dinv_p12;
    wire            hmc_cmd_valid_p13;
    wire            hmc_wr_data_valid_p13;
    wire   [3:0]    hmc_cmd_p13;
    wire            hmc_rd_data_valid_p13;
    wire            hmc_clk_p13;
    wire  [33:0]    hmc_addr_p13;
    wire   [3:0]    hmc_size_p13;
    wire [127:0]    hmc_wr_data_p13;
    wire [127:0]    hmc_rd_data_p13;
    wire            hmc_wr_data_ready_p13, hmc_cmd_ready_p13;
    wire   [5:0]    hmc_tag_p13, hmc_rd_data_tag_p13;
    wire   [6:0]    hmc_errstat_p13;
    wire            hmc_dinv_p13;
    wire            hmc_cmd_valid_p14;
    wire            hmc_wr_data_valid_p14;
    wire   [3:0]    hmc_cmd_p14;
    wire            hmc_rd_data_valid_p14;
    wire            hmc_clk_p14;
    wire  [33:0]    hmc_addr_p14;
    wire   [3:0]    hmc_size_p14;
    wire [127:0]    hmc_wr_data_p14;
    wire [127:0]    hmc_rd_data_p14;
    wire            hmc_wr_data_ready_p14, hmc_cmd_ready_p14;
    wire   [5:0]    hmc_tag_p14, hmc_rd_data_tag_p14;
    wire   [6:0]    hmc_errstat_p14;
    wire            hmc_dinv_p14;
    `endif // ENABLE_3RD_HMC_LINK
    `ifdef ENABLE_4TH_HMC_LINK
    wire            hmc_cmd_valid_p15;
    wire            hmc_wr_data_valid_p15;
    wire   [3:0]    hmc_cmd_p15;
    wire            hmc_rd_data_valid_p15;
    wire            hmc_clk_p15;
    wire  [33:0]    hmc_addr_p15;
    wire   [3:0]    hmc_size_p15;
    wire [127:0]    hmc_wr_data_p15;
    wire [127:0]    hmc_rd_data_p15;
    wire            hmc_wr_data_ready_p15, hmc_cmd_ready_p15;
    wire   [5:0]    hmc_tag_p15, hmc_rd_data_tag_p15;
    wire   [6:0]    hmc_errstat_p15;
    wire            hmc_dinv_p15;
    wire            hmc_cmd_valid_p16;
    wire            hmc_wr_data_valid_p16;
    wire   [3:0]    hmc_cmd_p16;
    wire            hmc_rd_data_valid_p16;
    wire            hmc_clk_p16;
    wire  [33:0]    hmc_addr_p16;
    wire   [3:0]    hmc_size_p16;
    wire [127:0]    hmc_wr_data_p16;
    wire [127:0]    hmc_rd_data_p16;
    wire            hmc_wr_data_ready_p16, hmc_cmd_ready_p16;
    wire   [5:0]    hmc_tag_p16, hmc_rd_data_tag_p16;
    wire   [6:0]    hmc_errstat_p16;
    wire            hmc_dinv_p16;
    wire            hmc_cmd_valid_p17;
    wire            hmc_wr_data_valid_p17;
    wire   [3:0]    hmc_cmd_p17;
    wire            hmc_rd_data_valid_p17;
    wire            hmc_clk_p17;
    wire  [33:0]    hmc_addr_p17;
    wire   [3:0]    hmc_size_p17;
    wire [127:0]    hmc_wr_data_p17;
    wire [127:0]    hmc_rd_data_p17;
    wire            hmc_wr_data_ready_p17, hmc_cmd_ready_p17;
    wire   [5:0]    hmc_tag_p17, hmc_rd_data_tag_p17;
    wire   [6:0]    hmc_errstat_p17;
    wire            hmc_dinv_p17;
    wire            hmc_cmd_valid_p18;
    wire            hmc_wr_data_valid_p18;
    wire   [3:0]    hmc_cmd_p18;
    wire            hmc_rd_data_valid_p18;
    wire            hmc_clk_p18;
    wire  [33:0]    hmc_addr_p18;
    wire   [3:0]    hmc_size_p18;
    wire [127:0]    hmc_wr_data_p18;
    wire [127:0]    hmc_rd_data_p18;
    wire            hmc_wr_data_ready_p18, hmc_cmd_ready_p18;
    wire   [5:0]    hmc_tag_p18, hmc_rd_data_tag_p18;
    wire   [6:0]    hmc_errstat_p18;
    wire            hmc_dinv_p18;
    wire            hmc_cmd_valid_p19;
    wire            hmc_wr_data_valid_p19;
    wire   [3:0]    hmc_cmd_p19;
    wire            hmc_rd_data_valid_p19;
    wire            hmc_clk_p19;
    wire  [33:0]    hmc_addr_p19;
    wire   [3:0]    hmc_size_p19;
    wire [127:0]    hmc_wr_data_p19;
    wire [127:0]    hmc_rd_data_p19;
    wire            hmc_wr_data_ready_p19, hmc_cmd_ready_p19;
    wire   [5:0]    hmc_tag_p19, hmc_rd_data_tag_p19;
    wire   [6:0]    hmc_errstat_p19;
    wire            hmc_dinv_p19;
    `endif // ENABLE_4TH_HMC_LINK
    `endif //!USE_512_BIT_HMC_CONTROLLER
`endif // ENABLE_HMC

`ifdef USER_DIRECT_PCI
    // user-direct writes
    wire [PCIE_BUS_WIDTH-1:0]           user_pci_wr_q_data;
    wire                                user_pci_wr_q_valid, user_pci_wr_q_en;
    wire [PCIE_BUS_WIDTH-1:0]           user_pci_wr_data_q_data;
    wire                                user_pci_wr_data_q_valid, user_pci_wr_data_q_en;
    wire                                direct_rx_valid;
`endif // USER_DIRECT_PCI

    wire                                extra_clk;

`ifdef PICO_DDR3_OR_DDR4
  `ifdef ALTERA_FPGA
    wire                                ddr3_sys_rst;
    wire                                afi_reset_n;
    `ifdef PICO_DDR3
    wire                                c0_local_init_done, c0_local_cal_success;
    `elsif PICO_DDR4
    wire                                c0_local_cal_success;
    wire                                c0_local_cal_fail;
    wire                                c0_ecc_interrupt;
    `endif // PICO_DDR

    wire                                c0_rst;
    wire                                c0_clk;
    wire                                c0_phy_init_done;

    wire                                avl_ready;
    wire    [AVL_ADDR_WIDTH-1:0]        avl_addr;
    wire                                avl_rdata_valid;
    wire    [AVL_DATA_WIDTH-1:0]        avl_rdata;
    wire    [AVL_DATA_WIDTH-1:0]        avl_wdata;
    wire    [AVL_DATA_WIDTH/8-1:0]      avl_be;
    wire                                avl_read_req;
    wire                                avl_write_req;
    wire    [AVL_SIZE_WIDTH-1:0]        avl_size;
  `else // !ALTERA_FPGA
    wire                                ddr3_sys_rst;
    wire                                c0_ddr4_reset_n_int;
    reg                                 c0_aresetn;

    // Master Interface to MIG 0
    wire                                c0_rst;
    wire                                c0_clk;
    // Master Interface Write Address Ports
    wire    [C0_C_S_AXI_ID_WIDTH-1:0]   c0_s_axi_awid;
    wire    [C0_C_S_AXI_ADDR_WIDTH-1:0] c0_s_axi_awaddr;
    wire    [7:0]                       c0_s_axi_awlen;
    wire    [2:0]                       c0_s_axi_awsize;
    wire    [1:0]                       c0_s_axi_awburst;
    wire    [0:0]                       c0_s_axi_awlock;
    wire    [3:0]                       c0_s_axi_awcache;
    wire    [2:0]                       c0_s_axi_awprot;
    wire    [3:0]                       c0_s_axi_awqos;
    wire                                c0_s_axi_awvalid;
    wire                                c0_s_axi_awready;
    // Master Interface Write Data Ports
    wire    [C0_C_S_AXI_DATA_WIDTH-1:0] c0_s_axi_wdata;
    wire    [C0_C_S_AXI_DATA_WIDTH/8-1:0] c0_s_axi_wstrb;
    wire                                c0_s_axi_wlast;
    wire                                c0_s_axi_wvalid;
    wire                                c0_s_axi_wready;
    // Master Interface Write Response Ports
    wire    [C0_C_S_AXI_ID_WIDTH-1:0]   c0_s_axi_bid;
    wire    [1:0]                       c0_s_axi_bresp;
    wire                                c0_s_axi_bvalid;
    wire                                c0_s_axi_bready;
    // Master Interface Read Address Ports
    wire    [C0_C_S_AXI_ID_WIDTH-1:0]   c0_s_axi_arid;
    wire    [C0_C_S_AXI_ADDR_WIDTH-1:0] c0_s_axi_araddr;
    wire    [7:0]                       c0_s_axi_arlen;
    wire    [2:0]                       c0_s_axi_arsize;
    wire    [1:0]                       c0_s_axi_arburst;
    wire    [0:0]                       c0_s_axi_arlock;
    wire    [3:0]                       c0_s_axi_arcache;
    wire    [2:0]                       c0_s_axi_arprot;
    wire    [3:0]                       c0_s_axi_arqos;
    wire                                c0_s_axi_arvalid;
    wire                                c0_s_axi_arready;
    // Master Interface Read Data Ports
    wire    [C0_C_S_AXI_ID_WIDTH-1:0]   c0_s_axi_rid;
    wire    [C0_C_S_AXI_DATA_WIDTH-1:0] c0_s_axi_rdata;
    wire    [1:0]                       c0_s_axi_rresp;
    wire                                c0_s_axi_rlast;
    wire                                c0_s_axi_rvalid;
    wire                                c0_s_axi_rready;
    `ifndef SIMULATION
    wire                                c0_phy_init_done;
    `endif //!SIMULATION
  `endif // !ALTERA_FPGA
`endif // PICO_DDR3_OR_DDR4

`ifdef XILINX_ULTRASCALE_PLUS
    IBUF sys_reset_n_ibuf (.O(pcie_reset_f), .I(sys_reset_n));
`elsif XILINX_ULTRASCALE
    IBUF sys_reset_n_ibuf (.O(pcie_reset_f), .I(sys_reset_n));
`else  // !XILINX_ULTRASCALE_PLUS
    assign pcie_reset_f = sys_reset_n;
`endif // !XILINX_ULTRASCALE_PLUS

`ifdef ENABLE_HMC
//    `ifdef PICO_MODEL_M510_OR_M520
//    // for now, we just tie off the cub and trst_n signals
//    // in the future, we could potentially drive this from an HMC controller
//    assign  cub                     = 3'b0;
//    assign  trst_n                  = 1'b0;
//    `endif // PICO_MODEL_M510_OR_M520
//
//    `ifdef PICO_MODEL_M510
//    // need to create a single-ended reference clock for the HMC transceivers
//    wire                                hmc0_refclk;
//    IBUFDS_GTE3 #(
//        .REFCLK_EN_TX_PATH              (1'b0),
//        .REFCLK_HROW_CK_SEL             (2'b00),
//        .REFCLK_ICNTL_RX                (2'b00)
//    ) IBUFDS_GTE3_MGTREFCLK0_X0Y1_INST (
//        .I                              (hmc_refclkp),
//        .IB                             (hmc_refclkn),
//        .CEB                            (1'b0),
//        .O                              (hmc0_refclk),
//        .ODIV2                          ()
//    );
//
//    // reference clock for the 2nd HMC link = L3
//    // need to create a single-ended reference clock for the HMC transceivers
//    `ifdef ENABLE_2ND_HMC_LINK
//    wire                                hmc1_refclk;
//    IBUFDS_GTE3 #(
//        .REFCLK_EN_TX_PATH              (1'b0),
//        .REFCLK_HROW_CK_SEL             (2'b00),
//        .REFCLK_ICNTL_RX                (2'b00)
//    ) IBUFDS_GTE3_HMC1_REFCLK (
//        .I                              (hmc1_refclkp),
//        .IB                             (hmc1_refclkn),
//        .CEB                            (1'b0),
//        .O                              (hmc1_refclk),
//        .ODIV2                          ()
//    );
//    `endif // ENABLE_2ND_HMC_LINK
//    `endif // PICO_MODEL_M510
`endif // ENABLE_HMC

`ifdef PICO_MODEL_M505 // PICO_MODEL_M505
    `ifdef PICO_FPGA_LX325T
    PicoFrameworkM505_LX325T1
    `elsif PICO_FPGA_LX160T
    PicoFrameworkM505_LX160T1
    `elsif PICO_FPGA_LX410T
    PicoFrameworkM505_LX410T1
    `endif

    #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
        .S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (

        .flash_busy                     ( flash_busy ),
        .flash_byte                     ( flash_byte ),
        .flash_ce                       ( flash_ce ),
        .flash_oe                       ( flash_oe ),
        .flash_reset                    ( flash_reset ),
        .flash_we                       ( flash_we ),
        .flash_a                        ( flash_a ),
        .flash_d                        ( flash_d ),
`elsif PICO_MODEL_M506
    PicoFrameworkM506_A3 #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
    	.S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_M510
    PicoFrameworkM510_KU060 #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
	.S_PB_RATIO			( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_EAGLE5
    PicoFrameworkEAGLE5_KU115 #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
	.S_PB_RATIO			( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_M520
    PicoFrameworkM520_AX115 #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
    	.S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_EX800
    `ifdef PICO_FPGA_A9
    PicoFrameworkEX800_A9
    `elsif PICO_FPGA_A7
    PicoFrameworkEX800_A7
    `endif
    #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
        .S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_AC511
    PicoFrameworkAC511_VU7P #(
        .PCIE_BUS_WIDTH         ( PCIE_BUS_WIDTH ),
        .PL_LINK_CAP_MAX_LINK_WIDTH ( PL_LINK_CAP_MAX_LINK_WIDTH ),
        .S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_SB851
    PicoFrameworkSB851_VU9P #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
    	.S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (
`elsif PICO_MODEL_SB852
    PicoFrameworkSB852_VU9P #(
        .PCIE_BUS_WIDTH			( PCIE_BUS_WIDTH ),
	.PL_LINK_CAP_MAX_LINK_WIDTH	( PL_LINK_CAP_MAX_LINK_WIDTH ),
    	.S_PB_RATIO                     ( S_PB_RATIO )
    ) PicoFramework (
`else
    UNKNOWN_PICO_MODEL_DEFINE!!
`endif

        // stream signals we're taking to the toplevel for the user
        .s_clk                          ( s_clk ),
        .s_rst                          ( s_rst ),

        .s_out_en                       ( s_out_en ),
        .s_out_id                       ( s_out_id ),
        .s_out_data                     ( s_out_data ),
	.s_out_ow_dvld			( s_out_ow_dvld ),

        .s_in_valid                     ( s_in_valid ),
        .s_in_id                        ( s_in_id[8:0] ),
        .s_in_data                      ( s_in_data ),
	.s_in_ow_dvld			( s_in_ow_dvld ),

        .s_poll_id                      ( s_poll_id[8:0] ),
        .s_poll_seq                     ( s_poll_seq[31:0] ),
        .s_poll_next_desc               ( s_poll_next_desc[127:0] ),
        .s_poll_next_desc_valid         ( s_poll_next_desc_valid ),

        .s_next_desc_rd_en              ( s_next_desc_rd_en ),
        .s_next_desc_rd_id              ( s_next_desc_rd_id[8:0] ),

        .UserPBWidth                    ( UserPBWidth ),

`ifdef USER_DIRECT_PCI
        // user-direct writes
        .user_pci_wr_q_data             ( user_pci_wr_q_data ),
        .user_pci_wr_q_valid            ( user_pci_wr_q_valid ),
        .user_pci_wr_q_en               ( user_pci_wr_q_en ),

        .user_pci_wr_data_q_data        ( user_pci_wr_data_q_data ),
        .user_pci_wr_data_q_valid       ( user_pci_wr_data_q_valid ),
        .user_pci_wr_data_q_en          ( user_pci_wr_data_q_en ),
        .direct_rx_valid                ( direct_rx_valid ),
`endif // USER_DIRECT_PCI

`ifdef SIMULATION
        // Common
        .user_clk                       ( user_clk ),
        .user_reset                     ( user_reset ),
        .user_lnk_up                    ( user_lnk_up ),

        // Tx
        .tx_buf_av                      ( tx_buf_av ),
        //.tx_cfg_req                     ( tx_cfg_req ),
        .tx_err_drop                    ( tx_err_drop ),
        .s_axis_tx_tready               ( s_axis_tx_tready ),
        .s_axis_tx_tdata                ( s_axis_tx_tdata ),
        .s_axis_tx_tstrb                ( s_axis_tx_tstrb ),
        .s_axis_tx_tuser                ( s_axis_tx_tuser ),
        .s_axis_tx_tlast                ( s_axis_tx_tlast ),
        .s_axis_tx_tvalid               ( s_axis_tx_tvalid ),
        //.tx_cfg_gnt                     ( tx_cfg_gnt ),

        // Rx
        .m_axis_rx_tdata                ( m_axis_rx_tdata ),
        .m_axis_rx_tstrb                ( m_axis_rx_tstrb ),
        .m_axis_rx_tlast                ( m_axis_rx_tlast ),
        .m_axis_rx_tvalid               ( m_axis_rx_tvalid ),
        .m_axis_rx_tready               ( m_axis_rx_tready ),
        .m_axis_rx_tuser                ( m_axis_rx_tuser ),
        .rx_np_ok                       ( rx_np_ok ),

        // Flow Control
        .fc_cpld                        ( fc_cpld ),
        .fc_cplh                        ( fc_cplh ),
        .fc_npd                         ( fc_npd ),
        .fc_nph                         ( fc_nph ),
        .fc_pd                          ( fc_pd ),
        .fc_ph                          ( fc_ph ),
        .fc_sel                         ( fc_sel ),
`else //!SIMULATION
        .pci_exp_txp                    ( pci_exp_txp ),
`ifndef ALTERA_FPGA
        .pci_exp_txn                    ( pci_exp_txn ),
`endif //!ALTERA_FPGA
        .pci_exp_rxp                    ( pci_exp_rxp ),
`ifndef ALTERA_FPGA
        .pci_exp_rxn                    ( pci_exp_rxn ),
`endif //!ALTERA_FPGA
`endif //!SIMULATION

        .temp                           ( temp ),

        .extra_clk_p                    ( extra_clk_p ),
`ifndef ALTERA_FPGA
        .extra_clk_n                    ( extra_clk_n ),
`endif
        .extra_clk                      ( extra_clk ),

        .sys_clk_p                      ( sys_clk_p ),
`ifndef ALTERA_FPGA
        .sys_clk_n                      ( sys_clk_n ),
`endif
        .sys_reset_n                    ( pcie_reset_f )
    );


`ifdef ENABLE_HMC
    // ui clk == link0 clk
    (* MARK_DEBUG="TRUE" *) logic            hmc_ui_tx_clk   ;
    (* MARK_DEBUG="TRUE" *) logic            hmc_ui_rx_clk   ;
    (* MARK_DEBUG="TRUE" *) logic            hmc_all_trained ;
    (* MARK_DEBUG="TRUE" *) logic            hmc_any_rst     ;
//    (* MARK_DEBUG="TRUE" *) logic [127:0]    hmc_subsystem_dout ;


    (* MARK_DEBUG="TRUE" *)
    hmc_user_if     hmc_port [19:0]  () ;
    (* MARK_DEBUG="TRUE" *)
    hmc_axi_if      hmc_axi_port [4-1:0]  () ;
`endif //ENABLE_HMC

    UserWrapper
    #(
`ifdef ENABLE_HMC
        .C_NUM_LINK                     (C_NUM_LINK) ,
`endif
`ifdef PICO_DDR3_OR_DDR4

    `ifdef ALTERA_FPGA
        .AVL_ADDR_WIDTH (AVL_ADDR_WIDTH),
        .AVL_DATA_WIDTH (AVL_DATA_WIDTH),
        .AVL_SIZE_WIDTH (AVL_SIZE_WIDTH),
    `endif // ALTERA_FPGA
	`ifdef PICO_AXI_MASTERS
        .C0_C_S_AXI_MASTERS             ( `PICO_AXI_MASTERS ),
	`endif // PICO_AXI_MASTERS
        .C0_C_S_AXI_ID_WIDTH            ( C0_C_S_AXI_ID_WIDTH ),
        .C0_C_S_AXI_ADDR_WIDTH          ( C0_C_S_AXI_ADDR_WIDTH ),
        .C0_C_S_AXI_DATA_WIDTH          ( C0_C_S_AXI_DATA_WIDTH ),
`endif // PICO_DDR3_OR_DDR4
        .C_DATA_WIDTH			(C_DATA_WIDTH),
	.S_PB_RATIO			(S_PB_RATIO)
    )
    UserWrapper
    (
`ifdef ENABLE_HMC
        .hmc_tx_clk                     (hmc_ui_tx_clk),
        .hmc_rx_clk                     (hmc_ui_rx_clk),
        .hmc_rst                        (hmc_any_rst),
        .hmc_trained                    (hmc_all_trained),




    `ifdef USE_512_BIT_HMC_CONTROLLER
        .hmc_port                       ( hmc_port[C_NUM_LINK-1:0] ) , // 4x128bit
        .hmc_axi_port                   ( hmc_axi_port[C_NUM_LINK-1:0] ) ,
    `else //!USE_512_BIT_HMC_CONTROLLER
        .hmc_port                       ( hmc_port ) ,
    `endif //!USE_512_BIT_HMC_CONTROLLER
        .PicoClk                        (PicoClk),
        .PicoRst                        (PicoRst),
        .PicoAddr                       (PicoAddr),
        .PicoDataIn                     (PicoDataIn),
        .PicoRd                         (PicoRd),
        .PicoWr                         (PicoWr),
        .PicoDataOut                    (0),
`endif // ENABLE_HMC
`ifdef PICO_DDR3_OR_DDR4

    `ifdef PICO_MODEL_SB852
        .c0_sys_clk_n                   ( c0_sys_clk_n       ),
        .c0_sys_clk_p                   ( c0_sys_clk_p       ),
        .c0_sys_rst_n                   ( pcie_reset_f       ),
        .c0_ddr4_act_n                  ( c0_ddr4_act_n      ),
        .c0_ddr4_adr                    ( c0_ddr4_adr        ),
        .c0_ddr4_ba                     ( c0_ddr4_ba         ),
        .c0_ddr4_bg                     ( c0_ddr4_bg         ),
        .c0_ddr4_ck_c                   ( c0_ddr4_ck_c       ),
        .c0_ddr4_ck_t                   ( c0_ddr4_ck_t       ),
        .c0_ddr4_cke                    ( c0_ddr4_cke        ),
        .c0_ddr4_cs_n                   ( c0_ddr4_cs_n       ),
        .c0_ddr4_dq                     ( c0_ddr4_dq         ),
        .c0_ddr4_dqs_c                  ( c0_ddr4_dqs_c      ),
        .c0_ddr4_dqs_t                  ( c0_ddr4_dqs_t      ),
        .c0_ddr4_odt                    ( c0_ddr4_odt        ),
        .c0_ddr4_par                    ( c0_ddr4_par        ),
        .c0_ddr4_reset_n                ( c0_ddr4_reset_n    ),
        `ifdef SB852_16G
        .c0_ddr4_dm_n                   ( c0_ddr4_dm_n       ),
        `endif
        `ifdef SB852_64G
        .c0_ddr4_c_id                   ( c0_ddr4_c_id       ),
        `endif
        `ifdef SB852_128G
        .c0_ddr4_c_id                   ( c0_ddr4_c_id       ),
        `endif
        
        .c1_sys_clk_n                   ( c1_sys_clk_n       ),
        .c1_sys_clk_p                   ( c1_sys_clk_p       ),
        .c1_sys_rst_n                   ( pcie_reset_f       ),
        .c1_ddr4_act_n                  ( c1_ddr4_act_n      ),
        .c1_ddr4_adr                    ( c1_ddr4_adr        ),
        .c1_ddr4_ba                     ( c1_ddr4_ba         ),
        .c1_ddr4_bg                     ( c1_ddr4_bg         ),
        .c1_ddr4_ck_c                   ( c1_ddr4_ck_c       ),
        .c1_ddr4_ck_t                   ( c1_ddr4_ck_t       ),
        .c1_ddr4_cke                    ( c1_ddr4_cke        ),
        .c1_ddr4_cs_n                   ( c1_ddr4_cs_n       ),
        .c1_ddr4_dq                     ( c1_ddr4_dq         ),
        .c1_ddr4_dqs_c                  ( c1_ddr4_dqs_c      ),
        .c1_ddr4_dqs_t                  ( c1_ddr4_dqs_t      ),
        .c1_ddr4_odt                    ( c1_ddr4_odt        ),
        .c1_ddr4_par                    ( c1_ddr4_par        ),
        .c1_ddr4_reset_n                ( c1_ddr4_reset_n    ),
        `ifdef SB852_16G
        .c1_ddr4_dm_n                   ( c1_ddr4_dm_n       ),
        `endif
        `ifdef SB852_64G
        .c1_ddr4_c_id                   ( c1_ddr4_c_id       ),
        `endif
        `ifdef SB852_128G
        .c1_ddr4_c_id                   ( c1_ddr4_c_id       ),
        `endif
                
        .c2_sys_clk_n                   ( c2_sys_clk_n       ),
        .c2_sys_clk_p                   ( c2_sys_clk_p       ),
        .c2_sys_rst_n                   ( pcie_reset_f       ),
        .c2_ddr4_act_n                  ( c2_ddr4_act_n      ),
        .c2_ddr4_adr                    ( c2_ddr4_adr        ),
        .c2_ddr4_ba                     ( c2_ddr4_ba         ),
        .c2_ddr4_bg                     ( c2_ddr4_bg         ),
        .c2_ddr4_ck_c                   ( c2_ddr4_ck_c       ),
        .c2_ddr4_ck_t                   ( c2_ddr4_ck_t       ),
        .c2_ddr4_cke                    ( c2_ddr4_cke        ),
        .c2_ddr4_cs_n                   ( c2_ddr4_cs_n       ),
        .c2_ddr4_dq                     ( c2_ddr4_dq         ),
        .c2_ddr4_dqs_c                  ( c2_ddr4_dqs_c      ),
        .c2_ddr4_dqs_t                  ( c2_ddr4_dqs_t      ),
        .c2_ddr4_odt                    ( c2_ddr4_odt        ),
        .c2_ddr4_par                    ( c2_ddr4_par        ),
        .c2_ddr4_reset_n                ( c2_ddr4_reset_n    ),
        `ifdef SB852_16G
        .c2_ddr4_dm_n                   ( c2_ddr4_dm_n       ),
        `endif
        `ifdef SB852_64G
        .c2_ddr4_c_id                   ( c2_ddr4_c_id       ),
        `endif
        `ifdef SB852_128G
        .c2_ddr4_c_id                   ( c2_ddr4_c_id       ),
        `endif
                
        .c3_sys_clk_n                   ( c3_sys_clk_n       ),
        .c3_sys_clk_p                   ( c3_sys_clk_p       ),
        .c3_sys_rst_n                   ( pcie_reset_f       ),
        .c3_ddr4_act_n                  ( c3_ddr4_act_n      ),
        .c3_ddr4_adr                    ( c3_ddr4_adr        ),
        .c3_ddr4_ba                     ( c3_ddr4_ba         ),
        .c3_ddr4_bg                     ( c3_ddr4_bg         ),
        .c3_ddr4_ck_c                   ( c3_ddr4_ck_c       ),
        .c3_ddr4_ck_t                   ( c3_ddr4_ck_t       ),
        .c3_ddr4_cke                    ( c3_ddr4_cke        ),
        .c3_ddr4_cs_n                   ( c3_ddr4_cs_n       ),
        .c3_ddr4_dq                     ( c3_ddr4_dq         ),
        .c3_ddr4_dqs_c                  ( c3_ddr4_dqs_c      ),
        .c3_ddr4_dqs_t                  ( c3_ddr4_dqs_t      ),
        .c3_ddr4_odt                    ( c3_ddr4_odt        ),
        .c3_ddr4_par                    ( c3_ddr4_par        ),
        .c3_ddr4_reset_n                ( c3_ddr4_reset_n    ),
        `ifdef SB852_16G
        .c3_ddr4_dm_n                   ( c3_ddr4_dm_n       ),
        `endif
        `ifdef SB852_64G
        .c3_ddr4_c_id                   ( c3_ddr4_c_id       ),
        `endif
         `ifdef SB852_128G
        .c3_ddr4_c_id                   ( c3_ddr4_c_id       ),
        `endif
    `else
        .ddr3_sys_rst                   ( ddr3_sys_rst       ),// System reset
        .c0_phy_init_done               ( c0_phy_init_done   ),
    `endif //SB852 DDR

    `ifdef ALTERA_FPGA
        //avalon interface
        .avl_ready                      (avl_ready),
        .avl_addr                       (avl_addr),
        .avl_rdata_valid                (avl_rdata_valid),
        .avl_rdata                      (avl_rdata),
        .avl_wdata                      (avl_wdata),
        .avl_be                         (avl_be),
        .avl_read_req                   (avl_read_req),
        .avl_write_req                  (avl_write_req),
        .avl_size                       (avl_size),
    `else //!ALTERA_FPGA
        // Slave Interface Write Address Ports
        .c0_s_axi_awid                  ( c0_s_axi_awid ),
        .c0_s_axi_awaddr                ( c0_s_axi_awaddr ),
        .c0_s_axi_awlen                 ( c0_s_axi_awlen ),
        .c0_s_axi_awsize                ( c0_s_axi_awsize ),
        .c0_s_axi_awburst               ( c0_s_axi_awburst ),
        .c0_s_axi_awlock                ( c0_s_axi_awlock ),
        .c0_s_axi_awcache               ( c0_s_axi_awcache ),
        .c0_s_axi_awprot                ( c0_s_axi_awprot ),
        .c0_s_axi_awqos                 ( c0_s_axi_awqos ),
        .c0_s_axi_awvalid               ( c0_s_axi_awvalid ),
        .c0_s_axi_awready               ( c0_s_axi_awready ),
        // Slave Interface Write Data Ports
        .c0_s_axi_wdata                 ( c0_s_axi_wdata ),
        .c0_s_axi_wstrb                 ( c0_s_axi_wstrb ),
        .c0_s_axi_wlast                 ( c0_s_axi_wlast ),
        .c0_s_axi_wvalid                ( c0_s_axi_wvalid ),
        .c0_s_axi_wready                ( c0_s_axi_wready ),
        // Slave Interface Write Response Ports
        .c0_s_axi_bid                   ( c0_s_axi_bid ),
        .c0_s_axi_bresp                 ( c0_s_axi_bresp ),
        .c0_s_axi_bvalid                ( c0_s_axi_bvalid ),
        .c0_s_axi_bready                ( c0_s_axi_bready ),
        // Slave Interface Read Address Ports
        .c0_s_axi_arid                  ( c0_s_axi_arid ),
        .c0_s_axi_araddr                ( c0_s_axi_araddr ),
        .c0_s_axi_arlen                 ( c0_s_axi_arlen ),
        .c0_s_axi_arsize                ( c0_s_axi_arsize ),
        .c0_s_axi_arburst               ( c0_s_axi_arburst ),
        .c0_s_axi_arlock                ( c0_s_axi_arlock ),
        .c0_s_axi_arcache               ( c0_s_axi_arcache ),
        .c0_s_axi_arprot                ( c0_s_axi_arprot ),
        .c0_s_axi_arqos                 ( c0_s_axi_arqos ),
        .c0_s_axi_arvalid               ( c0_s_axi_arvalid ),
        .c0_s_axi_arready               ( c0_s_axi_arready ),
        // Slave Interface Read Data Ports
        .c0_s_axi_rid                   ( c0_s_axi_rid ),
        .c0_s_axi_rdata                 ( c0_s_axi_rdata ),
        .c0_s_axi_rresp                 ( c0_s_axi_rresp ),
        .c0_s_axi_rlast                 ( c0_s_axi_rlast ),
        .c0_s_axi_rvalid                ( c0_s_axi_rvalid ),
        .c0_s_axi_rready                ( c0_s_axi_rready ),
    `endif //!ALTERA_FPGA
        // Common ports
        .c0_tb_rst                      ( c0_rst ),
        .c0_tb_clk                      ( c0_clk ),

`endif // PICO_DDR3_OR_DDR4

        `ifdef PICO_MODEL_SB852
        `ifdef ENABLE_HMC
        .extra_clk                      ( s_clk     ),
        `else // not define HMC in SB852
        .extra_clk                      ( extra_clk ),
        `endif // ENABLE_HMC
        `else // not define HMC
        .extra_clk                      ( extra_clk ),
        `endif // PICO_MODEL_SB852
        .clk                            ( s_clk ),
        .rst                            ( s_rst ),

`ifdef USER_DIRECT_PCI
        // user-direct writes
        .direct_rx_valid                ( direct_rx_valid ),
        .user_pci_wr_q_data             ( user_pci_wr_q_data ),
        .user_pci_wr_q_valid            ( user_pci_wr_q_valid ),
        .user_pci_wr_q_en               ( user_pci_wr_q_en ),

        .user_pci_wr_data_q_data        ( user_pci_wr_data_q_data ),
        .user_pci_wr_data_q_valid       ( user_pci_wr_data_q_valid ),
        .user_pci_wr_data_q_en          ( user_pci_wr_data_q_en ),
`endif // USER_DIRECT_PCI

        .s_out_en                       ( s_out_en ),
        .s_out_id                       ( s_out_id ),
        .s_out_data                     ( s_out_data ),
	.s_out_ow_dvld			( s_out_ow_dvld ),

        .s_in_valid                     ( s_in_valid ),
        .s_in_id                        ( s_in_id[8:0] ),
        .s_in_data                      ( s_in_data ),
	.s_in_ow_dvld			( s_in_ow_dvld ),

        .s_poll_id                      ( s_poll_id[8:0] ),
        .s_poll_seq                     ( s_poll_seq[31:0] ),
        .s_poll_next_desc               ( s_poll_next_desc[127:0] ),
        .s_poll_next_desc_valid         ( s_poll_next_desc_valid ),

        .s_next_desc_rd_en              ( s_next_desc_rd_en ),
        .s_next_desc_rd_id              ( s_next_desc_rd_id[8:0] )

`ifdef PICO_MODEL_SB852
        ,
        .sda                            (i2c_sda),
        .scl                            (i2c_scl)
`endif

    );

    //------------------------------------------------------
    // DDR4 MIG
    //------------------------------------------------------
`ifdef PICO_DDR4
    `ifdef ALTERA_FPGA
    // timing fix
    reg [3:0] phy_init_done_q = 0;
    always @ (posedge c0_clk) begin
        phy_init_done_q[0] <= c0_local_cal_success;
        phy_init_done_q[3:1] <= phy_init_done_q[2:0];
    end

    assign c0_phy_init_done     = phy_init_done_q[3];    // to UL or SIM
    assign c0_rst               = ~afi_reset_n;

    // register user reset
    wire ddr4_usr_reset_n       = ~ddr3_sys_rst & pcie_reset_f ;

    ddr4_a10_v16_0_16GB
    mem_if (
        .pll_ref_clk                (c0_ddr4_ref_clk ),  // ddr4 pll ref clk
        .global_reset_n             (ddr4_usr_reset_n ) ,       // pcie reset | usr rst
        .emif_usr_clk               (c0_clk),            // avalon usr clk
        .emif_usr_reset_n           (afi_reset_n),       // avalon usr rst
//      .aresetn                    (aresetn_q), //TODO add this to the core
        // IO pins
        .mem_a                      ( c0_ddr4_addr      ) ,
        .mem_ba                     ( c0_ddr4_ba        ) ,
        .mem_ck                     ( c0_ddr4_ck        ) ,
        .mem_ck_n                   ( c0_ddr4_ck_n      ) ,
        .mem_cke                    ( c0_ddr4_cke       ) ,
        .mem_cs_n                   ( c0_ddr4_cs_n      ) ,
        .mem_reset_n                ( c0_ddr4_reset_n   ) ,
        .mem_dq                     ( c0_ddr4_dq        ) ,
        .mem_dqs                    ( c0_ddr4_dqs       ) ,
        .mem_dqs_n                  ( c0_ddr4_dqs_n     ) ,
        .mem_odt                    ( c0_ddr4_odt       ) ,

        .mem_act_n                  ( c0_ddr4_act_n     ) ,
        .mem_bg                     ( c0_ddr4_bg        ) ,
        .mem_par                    ( c0_ddr4_par       ) ,
        .mem_alert_n                ( c0_ddr4_alert_n   ) ,
        .mem_dbi_n                  ( c0_ddr4_dbi_n     ) ,
        .oct_rzqin                  ( c0_ddr4_oct_rzqin ) ,

        //avalon interface        a
        .amm_ready_0                ( avl_ready       ) ,
        .amm_address_0              ( avl_addr        ) ,
        .amm_readdatavalid_0        ( avl_rdata_valid ) ,
        .amm_readdata_0             ( avl_rdata       ) ,
        .amm_writedata_0            ( avl_wdata       ) ,
        .amm_byteenable_0           ( avl_be          ) ,
        .amm_read_0                 ( avl_read_req    ) ,
        .amm_write_0                ( avl_write_req   ) ,
        .amm_burstcount_0           ( avl_size        ) ,

        .local_cal_success          (c0_local_cal_success),
        .local_cal_fail             (c0_local_cal_fail ),
        .ctrl_ecc_user_interrupt_0  (c0_ecc_interrupt )
        );
    `elsif XILINX_FPGA // XILINX_FPGA
    `ifndef PICO_MODEL_SB852
        //------------------------------------------------------
        // Xilinx DDR4 MIG
        //------------------------------------------------------
        assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;

        always @(posedge c0_clk) begin
          c0_aresetn <= ~c0_rst;
        end

        // register user reset
        (* MARK_DEBUG *) wire ddr4_usr_reset       = ddr3_sys_rst & ~pcie_reset_f ;

        ddr4_0
        mem_if(
        .sys_rst                             (ddr4_usr_reset      ), // pcie reset | usr rst

        .c0_sys_clk_p                        (c0_sys_clk_p        ),
        .c0_sys_clk_n                        (c0_sys_clk_n        ),
        .c0_init_calib_complete              (c0_phy_init_done    ),

        .c0_ddr4_act_n                       (c0_ddr4_act_n       ),
        .c0_ddr4_adr                         (c0_ddr4_addr        ),
        .c0_ddr4_ba                          (c0_ddr4_ba          ),
        .c0_ddr4_bg                          (c0_ddr4_bg          ),
        .c0_ddr4_cke                         (c0_ddr4_cke         ),
        .c0_ddr4_odt                         (c0_ddr4_odt         ),
        .c0_ddr4_cs_n                        (c0_ddr4_cs_n        ),
        .c0_ddr4_ck_t                        (c0_ddr4_ck_t        ),
        .c0_ddr4_ck_c                        (c0_ddr4_ck_c        ),
        .c0_ddr4_reset_n                     (c0_ddr4_reset_n_int ),

        .c0_ddr4_dm_dbi_n                    (c0_ddr4_dm_dbi_n    ),
        .c0_ddr4_dq                          (c0_ddr4_dq          ),
        .c0_ddr4_dqs_c                       (c0_ddr4_dqs_c       ),
        .c0_ddr4_dqs_t                       (c0_ddr4_dqs_t       ),

        .c0_ddr4_ui_clk                      (c0_clk              ),
        .c0_ddr4_ui_clk_sync_rst             (c0_rst              ),
        .dbg_clk                             (),
        // AXI CTRL port
        .c0_ddr4_s_axi_ctrl_awvalid          (1'b0),
        .c0_ddr4_s_axi_ctrl_awready          (),
        .c0_ddr4_s_axi_ctrl_awaddr           (32'b0),
        // Slave Interface Write Data Ports
        .c0_ddr4_s_axi_ctrl_wvalid           (1'b0),
        .c0_ddr4_s_axi_ctrl_wready           (),
        .c0_ddr4_s_axi_ctrl_wdata            (32'b0),
        // Slave Interface Write Response Ports
        .c0_ddr4_s_axi_ctrl_bvalid           (),
        .c0_ddr4_s_axi_ctrl_bready           (1'b1),
        .c0_ddr4_s_axi_ctrl_bresp            (),
        // Slave Interface Read Address Ports
        .c0_ddr4_s_axi_ctrl_arvalid          (1'b0),
        .c0_ddr4_s_axi_ctrl_arready          (),
        .c0_ddr4_s_axi_ctrl_araddr           (32'b0),
        // Slave Interface Read Data Ports
        .c0_ddr4_s_axi_ctrl_rvalid           (),
        .c0_ddr4_s_axi_ctrl_rready           (1'b1),
        .c0_ddr4_s_axi_ctrl_rdata            (),
        .c0_ddr4_s_axi_ctrl_rresp            (),
        // Interrupt output
        .c0_ddr4_interrupt                   (),
        // Slave Interface Write Address Ports
        .c0_ddr4_aresetn                     (c0_aresetn        ),
        .c0_ddr4_s_axi_awid                  (c0_s_axi_awid     ),
        .c0_ddr4_s_axi_awaddr                (c0_s_axi_awaddr   ),
        .c0_ddr4_s_axi_awlen                 (c0_s_axi_awlen    ),
        .c0_ddr4_s_axi_awsize                (c0_s_axi_awsize   ),
        .c0_ddr4_s_axi_awburst               (c0_s_axi_awburst  ),
        .c0_ddr4_s_axi_awlock                (1'b0              ),
        .c0_ddr4_s_axi_awcache               (c0_s_axi_awcache  ),
        .c0_ddr4_s_axi_awprot                (c0_s_axi_awprot   ),
        .c0_ddr4_s_axi_awqos                 (4'b0              ),
        .c0_ddr4_s_axi_awvalid               (c0_s_axi_awvalid  ),
        .c0_ddr4_s_axi_awready               (c0_s_axi_awready  ),
        // Slave Interface Write Data Ports
        .c0_ddr4_s_axi_wdata                 (c0_s_axi_wdata    ),
        .c0_ddr4_s_axi_wstrb                 (c0_s_axi_wstrb    ),
        .c0_ddr4_s_axi_wlast                 (c0_s_axi_wlast    ),
        .c0_ddr4_s_axi_wvalid                (c0_s_axi_wvalid   ),
        .c0_ddr4_s_axi_wready                (c0_s_axi_wready   ),
        // Slave Interface Write Response Ports
        .c0_ddr4_s_axi_bid                   (c0_s_axi_bid      ),
        .c0_ddr4_s_axi_bresp                 (c0_s_axi_bresp    ),
        .c0_ddr4_s_axi_bvalid                (c0_s_axi_bvalid   ),
        .c0_ddr4_s_axi_bready                (c0_s_axi_bready   ),
        // Slave Interface Read Address Ports
        .c0_ddr4_s_axi_arid                  (c0_s_axi_arid     ),
        .c0_ddr4_s_axi_araddr                (c0_s_axi_araddr   ),
        .c0_ddr4_s_axi_arlen                 (c0_s_axi_arlen    ),
        .c0_ddr4_s_axi_arsize                (c0_s_axi_arsize   ),
        .c0_ddr4_s_axi_arburst               (c0_s_axi_arburst  ),
        .c0_ddr4_s_axi_arlock                (1'b0              ),
        .c0_ddr4_s_axi_arcache               (c0_s_axi_arcache  ),
        .c0_ddr4_s_axi_arprot                (3'b0              ),
        .c0_ddr4_s_axi_arqos                 (4'b0              ),
        .c0_ddr4_s_axi_arvalid               (c0_s_axi_arvalid  ),
        .c0_ddr4_s_axi_arready               (c0_s_axi_arready  ),
        // Slave Interface Read Data Ports
        .c0_ddr4_s_axi_rid                   (c0_s_axi_rid      ),
        .c0_ddr4_s_axi_rdata                 (c0_s_axi_rdata    ),
        .c0_ddr4_s_axi_rresp                 (c0_s_axi_rresp    ),
        .c0_ddr4_s_axi_rlast                 (c0_s_axi_rlast    ),
        .c0_ddr4_s_axi_rvalid                (c0_s_axi_rvalid   ),
        .c0_ddr4_s_axi_rready                (c0_s_axi_rready   ),

        // Debug Port
        .dbg_bus                             ()
    );
    `endif
    `endif // XILINX_FPGA
`endif //PICO_DDR4

    //------------------------------------------------------
    // DDR3 MIG
    //------------------------------------------------------
`ifdef PICO_DDR3
    `ifdef ALTERA_FPGA
    // timing fix
    reg [3:0] phy_init_done_q = 0;
    always @ (posedge c0_clk) begin
        phy_init_done_q[0] <= c0_local_init_done & c0_local_cal_success;
        phy_init_done_q[3:1] <= phy_init_done_q[2:0];
    end

    assign c0_phy_init_done     = phy_init_done_q[3];
    assign c0_rst               = ~afi_reset_n;
    `ifdef PICO_MODEL_M506
    ddr3_s5_v13_0
    `endif
    mem_if (

        .pll_ref_clk                (c0_ddr3_mem_refclk),
        .global_reset_n             (pcie_reset_f),
        .soft_reset_n               (~ddr3_sys_rst),
        .afi_clk                    (c0_clk),
        .afi_half_clk               (),
        .afi_reset_n                (afi_reset_n),
        .afi_reset_export_n         (), // this is a copy of afi_reset_n

//    .aresetn                    (aresetn_q), //TODO add this to the core
        .mem_a                      (c0_ddr3_addr),
        .mem_ba                     (c0_ddr3_ba),
        .mem_ck                     (c0_ddr3_ck_p),
        .mem_ck_n                   (c0_ddr3_ck_n),
        .mem_cke                    (c0_ddr3_cke),
        .mem_cs_n                   (c0_ddr3_cs_n),
        .mem_dm                     (c0_ddr3_dm),
        .mem_ras_n                  (c0_ddr3_ras_n),
        .mem_cas_n                  (c0_ddr3_cas_n),
        .mem_we_n                   (c0_ddr3_we_n),
        .mem_reset_n                (c0_ddr3_reset_n),
        .mem_dq                     (c0_ddr3_dq),
        .mem_dqs                    (c0_ddr3_dqs_p),
        .mem_dqs_n                  (c0_ddr3_dqs_n),
        .mem_odt                    (c0_ddr3_odt),


        //avalon interface
        .avl_ready                  (avl_ready),
        .avl_addr                   (avl_addr),
        .avl_rdata_valid            (avl_rdata_valid),
        .avl_rdata                  (avl_rdata),
        .avl_wdata                  (avl_wdata),
        .avl_be                     (avl_be),
        .avl_read_req               (avl_read_req),
        .avl_write_req              (avl_write_req),
        .avl_size                   (avl_size),

        .local_init_done            (c0_local_init_done),
        .local_cal_success          (c0_local_cal_success),
        .local_cal_fail             (),
        .local_rdata_error          (),
        .ecc_interrupt              (),
        .oct_rzqin                  (c0_ddr3_oct_rzqin),

        // pll_sharing interface. this interface is enabled only when
        // you set pll sharing mode to master or slave.
        .pll_mem_clk                (),
        .pll_write_clk              (),
        .pll_write_clk_pre_phy_clk  (),
        .pll_addr_cmd_clk           (),
        .pll_locked                 (),
        .pll_avl_clk                (),
        .pll_config_clk             (),
        .pll_hr_clk                 (),
        .pll_p2c_read_clk           (),
        .pll_c2p_write_clk          ()
    );

    `else // !ALTERA_FPGA

    // axi reset
    reg c0_aresetn;
    always @ (posedge c0_clk ) c0_aresetn <= ~c0_rst;

    // Memory Interface Generator 0
    `PICO_MIG_MODULE #(
        .RANKS                          ( RANKS                 ),
        .ROW_WIDTH                      ( ROW_WIDTH             ),
        .COL_WIDTH                      ( COL_WIDTH             ),

    `ifdef PICO_MODEL_M505
        .ODT_WIDTH                      ( ODT_WIDTH             ),
    `endif

        .IODELAY_GRP                    ( "IODELAY_MIG_DDR3_0"  ),

        .nCS_PER_RANK                   (nCS_PER_RANK           ),
        .BANK_WIDTH                     ( BANK_WIDTH            ),

        .DQ_WIDTH                       ( DQ_WIDTH              ),
        .DQS_WIDTH                      ( DQS_WIDTH             ),
        .DM_WIDTH                       ( DM_WIDTH              ),

        .CK_WIDTH                       ( CK_WIDTH              ),
        .CKE_WIDTH                      ( CKE_WIDTH             ),
        .CS_WIDTH                       ( CS_WIDTH              ),

        .C_S_AXI_ID_WIDTH               ( C0_C_S_AXI_ID_WIDTH   ),
        .C_S_AXI_ADDR_WIDTH             ( C0_C_S_AXI_ADDR_WIDTH ),
        .C_S_AXI_DATA_WIDTH             ( C0_C_S_AXI_DATA_WIDTH ),

        .RST_ACT_LOW                    ( RST_ACT_LOW           )
    ) mig_DDR3_0 (

    // Signals Unique to an M-Series Module
    `ifdef PICO_MODEL_M505
        .sys_rst                        ( ddr3_sys_rst ),
        .init_calib_complete            ( c0_phy_init_done ),

        // Application interface ports
        .app_sr_req                     ( 1'b0 ),                   // reserved input
        .app_sr_active                  ( ),          // output reserved
        .app_ref_req                    ( 1'b0 ),                   // active-high input to request
                                                                    //  refresh command be sent to
                                                                    //  DRAM
        .app_ref_ack                    ( ),            // output reserved
        .app_zq_req                     ( 1'b0 ),                   // active-high input to request
                                                                    //  that a ZA calibration
                                                                    //  command be sent to DRAM
        .app_zq_ack                     ( ),             // active-high output indicates
                                                                    //  the memory controller has
                                                                    //  sent the requested ZQ
                                                                    //  calibration command to the
                                                                    //  PHY interface
        // System Clock Ports
        .sys_clk_p                      ( clk_400_p ),
        .sys_clk_n                      ( clk_400_n ),

        // Reference clock for the iodelay_ctrl
        .extra_clk                      ( extra_clk ),

        // temperature from the System Monitor is used by the MIG to compensate
        // for temperature changes (requires 12 bits)
        .device_temp_i                  ( {temp, 2'b0} ),
    `endif // PICO_MODEL_M505

    // Signals Common to all M-Series Modules
        // DDR3 Physical Pins
        .ddr3_ck_p                      ( c0_ddr3_ck_p ),
        .ddr3_ck_n                      ( c0_ddr3_ck_n ),
        .ddr3_addr                      ( c0_ddr3_addr ),
        .ddr3_ba                        ( c0_ddr3_ba ),
        .ddr3_ras_n                     ( c0_ddr3_ras_n ),
        .ddr3_cas_n                     ( c0_ddr3_cas_n ),
        .ddr3_we_n                      ( c0_ddr3_we_n ),
        .ddr3_cs_n                      ( c0_ddr3_cs_n ),
        .ddr3_cke                       ( c0_ddr3_cke ),
        .ddr3_odt                       ( c0_ddr3_odt ),
        .ddr3_reset_n                   ( c0_ddr3_reset_n ),
        .ddr3_dm                        ( c0_ddr3_dm ),
        .ddr3_dq                        ( c0_ddr3_dq ),
        .ddr3_dqs_p                     ( c0_ddr3_dqs_p ),
        .ddr3_dqs_n                     ( c0_ddr3_dqs_n ),

        // Slave Interface Write Address Ports
        .s_axi_awid                     ( c0_s_axi_awid ),
        .s_axi_awaddr                   ( c0_s_axi_awaddr ),
        .s_axi_awlen                    ( c0_s_axi_awlen ),
        .s_axi_awsize                   ( c0_s_axi_awsize ),
        .s_axi_awburst                  ( c0_s_axi_awburst ),
        .s_axi_awlock                   ( c0_s_axi_awlock ),
        .s_axi_awcache                  ( c0_s_axi_awcache ),
        .s_axi_awprot                   ( c0_s_axi_awprot ),
        .s_axi_awqos                    ( c0_s_axi_awqos ),
        .s_axi_awvalid                  ( c0_s_axi_awvalid ),
        .s_axi_awready                  ( c0_s_axi_awready ),
        // Slave Interface Write Data Ports
        .s_axi_wdata                    ( c0_s_axi_wdata ),
        .s_axi_wstrb                    ( c0_s_axi_wstrb ),
        .s_axi_wlast                    ( c0_s_axi_wlast ),
        .s_axi_wvalid                   ( c0_s_axi_wvalid ),
        .s_axi_wready                   ( c0_s_axi_wready ),
        // Slave Interface Write Response Ports
        .s_axi_bid                      ( c0_s_axi_bid ),
        .s_axi_bresp                    ( c0_s_axi_bresp ),
        .s_axi_bvalid                   ( c0_s_axi_bvalid ),
        .s_axi_bready                   ( c0_s_axi_bready ),
        // Slave Interface Read Address Ports
        .s_axi_arid                     ( c0_s_axi_arid ),
        .s_axi_araddr                   ( c0_s_axi_araddr ),
        .s_axi_arlen                    ( c0_s_axi_arlen ),
        .s_axi_arburst                  ( c0_s_axi_arburst ),
        .s_axi_arsize                   ( c0_s_axi_arsize ),
        .s_axi_arlock                   ( c0_s_axi_arlock ),
        .s_axi_arcache                  ( c0_s_axi_arcache ),
        .s_axi_arprot                   ( c0_s_axi_arprot ),
        .s_axi_arqos                    ( c0_s_axi_arqos ),
        .s_axi_arvalid                  ( c0_s_axi_arvalid ),
        .s_axi_arready                  ( c0_s_axi_arready ),
        // Slave Interface Read Data Ports
        .s_axi_rid                      ( c0_s_axi_rid ),
        .s_axi_rdata                    ( c0_s_axi_rdata ),
        .s_axi_rresp                    ( c0_s_axi_rresp ),
        .s_axi_rlast                    ( c0_s_axi_rlast ),
        .s_axi_rvalid                   ( c0_s_axi_rvalid ),
        .s_axi_rready                   ( c0_s_axi_rready ),
        .ui_clk_sync_rst                ( c0_rst ),
        .ui_clk                         ( c0_clk ),
        .aresetn                        ( c0_aresetn )
    );
`endif // !ALTERA_FPGA
`endif // PICO_DDR3

`ifdef ENABLE_HMC
    // we use bits 30:28 to differentiate between HMC controllers
    assign hmc0_PicoAddr                = PicoAddr & 32'h8FFFFFFF;
    assign hmc0_PicoRd                  = PicoRd & (PicoAddr[30:28] == 3'b000);
    assign hmc0_PicoWr                  = PicoWr & (PicoAddr[30:28] == 3'b000);
    `ifdef ENABLE_2ND_HMC_LINK
    assign hmc1_PicoAddr                = PicoAddr & 32'h8FFFFFFF;
    assign hmc1_PicoRd                  = PicoRd & (PicoAddr[30:28] == 3'b001);
    assign hmc1_PicoWr                  = PicoWr & (PicoAddr[30:28] == 3'b001);
    `endif
    `ifdef ENABLE_3RD_HMC_LINK
    assign hmc2_PicoAddr                = PicoAddr & 32'h8FFFFFFF;
    assign hmc2_PicoRd                  = PicoRd & (PicoAddr[30:28] == 3'b010);
    assign hmc2_PicoWr                  = PicoWr & (PicoAddr[30:28] == 3'b010);
    `endif

    `ifdef ENABLE_4TH_HMC_LINK
    assign hmc3_PicoAddr                = PicoAddr & 32'h8FFFFFFF;
    assign hmc3_PicoRd                  = PicoRd & (PicoAddr[30:28] == 3'b011);
    assign hmc3_PicoWr                  = PicoWr & (PicoAddr[30:28] == 3'b011);
    `endif

    // For Alter FPGA only. To reduce critical warning
    `ifdef ALTERA_FPGA
    logic                         refclkn  [C_NUM_REF_CLK-1:0] ;
    logic  [C_LINK_WIDTH-1:0]     lxrxn    [C_NUM_LINK-1:0]    ;
    logic  [C_LINK_WIDTH-1:0]     lxtxn    [C_NUM_LINK-1:0]    ;
    `endif

    hmc_subsystem # (

        .C_NUM_LINK                  (C_NUM_LINK) ,
        .C_NUM_REF_CLK               (C_NUM_REF_CLK) ,
        .C_LINK_WIDTH                (C_LINK_WIDTH) ,

        .EXTRA_CLK_GEN               (0)  // 1 will instantiate IBUFDS
    ) hmc_subsystem_inst (
        // -----------------------------------------------------
        // HMC IO signals
        // -----------------------------------------------------
        .refclkp               ( refclkp ) ,
        .refclkn               ( refclkn ) ,
        .lxrxp                 ( lxrxp   ) ,
        .lxrxn                 ( lxrxn   ) ,
        .lxtxp                 ( lxtxp   ) ,
        .lxtxn                 ( lxtxn   ) ,

        .lxrxps                ( lxrxps  ) ,
        .lxtxps                ( lxtxps  ) ,

        .bringup_en            (         ) , // replace old fpga_id

        .cub                   ( cub     ) ,
        .trst_n                ( trst_n  ) ,
        // HMC Error Interrupt
        .ferr_n                ( ferr_n  ) ,
        // HMC Global Reset
        .p_rst_n               ( p_rst_n ) ,
        // HMC I2C
        .scl                   ( scl     ) ,
        .sda                   ( sda     ) ,
        // -----------------------------------------------------
        // -----------------------------------------------------
        // System signals
        // -----------------------------------------------------

        .s_rst                 ( s_rst   ),
        // extra clk
        .extra_clk_p           ( ) ,  // 200 MHz for 510
        .extra_clk_n           ( ) ,  // 200 MHz for 510
        // AFTER IBUFGDS
        .extra_clk             ( extra_clk ) ,
        // HMC USER INTERFACE
        // -----------------------------------------------------
        .hmc_port              ( hmc_port ) ,
        .hmc_axi_port          ( hmc_axi_port ) ,
        // -----------------------------------------------------

        .hmc_ui_tx_clk         ( hmc_ui_tx_clk ) ,
        .hmc_ui_rx_clk         ( hmc_ui_rx_clk ) ,
        .hmc_any_rst           ( hmc_any_rst ) ,
        .hmc_all_trained       ( hmc_all_trained )
    );


    //------------------------------------------------------
    // LED
    //  - same logic we use on the EX700 for causing color
    //    change.
    //------------------------------------------------------
    `ifndef PICO_MODEL_SB852
    assign led_r = 0 ; // hmc_all_trained ;
    assign led_g = hmc_all_trained ;
    assign led_b = 0 ; // hmc_all_trained ;
    `endif

`else

`ifdef LED
    RGBBlink # (
        .LED_NUM    (LED_NUM)
    ) RGBBlink (
        .extra_clk  (extra_clk),
        .led_r      (led_r    ),
        .led_g      (led_g    ),
        .led_b      (led_b    )
    );

`endif // LED

`endif // ENABLE_HMC


`ifdef CONVEY_SIM
   `define SIMULATION
`endif

`default_nettype wire

endmodule


