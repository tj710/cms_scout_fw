// xilinx_pcie_3_0_7vx.v
// Copyright 2014 Pico Computing, Inc.

`include "PicoDefines.v"

module xilinx_pcie_3_0_7vx # (
    parameter          C_DATA_WIDTH                        = 128,         // RX/TX interface data width
    parameter          KEEP_WIDTH                          = C_DATA_WIDTH / 32,
    parameter          STRB_WIDTH                          = C_DATA_WIDTH / 8,
    parameter          PL_LINK_CAP_MAX_LINK_WIDTH          = 8,  // 1- X1, 2 - X2, 4 - X4, 8 - X8, 16 - X16
    // USER_CLK2_FREQ = AXI Interface Frequency
    //   0: Disable User Clock
    //   1: 31.25 MHz
    //   2: 62.50 MHz  (default)
    //   3: 125.00 MHz
    //   4: 250.00 MHz
    //   5: 500.00 MHz
    parameter  integer USER_CLK2_FREQ                 = 4,
    parameter          REF_CLK_FREQ                   = 0,           // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
    parameter          AXISTEN_IF_RQ_ALIGNMENT_MODE   = "FALSE",
    parameter          AXISTEN_IF_CC_ALIGNMENT_MODE   = "FALSE",
    parameter          AXISTEN_IF_CQ_ALIGNMENT_MODE   = "FALSE",
    parameter          AXISTEN_IF_RC_ALIGNMENT_MODE   = "FALSE",
    parameter          AXISTEN_IF_ENABLE_CLIENT_TAG   = 0,
    parameter          AXISTEN_IF_RQ_PARITY_CHECK     = 0,
    parameter          AXISTEN_IF_CC_PARITY_CHECK     = 0,
    parameter          AXISTEN_IF_MC_RX_STRADDLE      = 0,
    parameter          AXISTEN_IF_ENABLE_RX_MSG_INTFC = 0,
    parameter   [17:0] AXISTEN_IF_ENABLE_MSG_ROUTE    = 18'h2FFFF
) (
    output wire                                         user_clk,
    output wire                                         user_reset,
    output wire                                         user_lnk_up,

    output wire                                         s_axis_tx_tready,
    input  wire [C_DATA_WIDTH-1:0]                      s_axis_tx_tdata,
    input  wire [STRB_WIDTH-1:0]                        s_axis_tx_tstrb,
    input  wire [3:0]                                   s_axis_tx_tuser,
    input  wire                                         s_axis_tx_tlast,
    input  wire                                         s_axis_tx_tvalid,

    output wire [C_DATA_WIDTH-1:0]                      m_axis_rx_tdata,
    output wire [STRB_WIDTH-1:0]                        m_axis_rx_tstrb,
    output wire                                         m_axis_rx_tlast,
    output wire                                         m_axis_rx_tvalid,
    input  wire                                         m_axis_rx_tready,
    output wire [21:0]                                  m_axis_rx_tuser,

    input  wire                                         cfg_interrupt,
    output wire                                         cfg_interrupt_rdy,

    input  wire [63:0]                                  cfg_dsn,
    output wire [15:0]                                  cfg_completer_id,
    output wire [7:0]                                   cfg_bus_number,
    output wire [4:0]                                   cfg_device_number,
    output wire [2:0]                                   cfg_function_number,
    output wire [15:0]                                  cfg_dcommand,

    output wire [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]	pci_exp_txp,
    output wire [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]	pci_exp_txn,
    input  wire [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]	pci_exp_rxp,
    input  wire [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]	pci_exp_rxn,

    input  wire                                         sys_clk_p,
    input  wire                                         sys_clk_n,
    input  wire                                         sys_reset_n
);

    // Local Parameters derived from user selection
    localparam        TCQ = 1;

    // Wire Declarations

    //----------------------------------------------------------------------------------------------------------------//
    //  AXI Interface                                                                                                 //
    //----------------------------------------------------------------------------------------------------------------//

     wire                                       s_axis_rq_tlast;
     wire                 [C_DATA_WIDTH-1:0]    s_axis_rq_tdata;
     wire                             [61:0]    s_axis_rq_tuser;
     wire                   [KEEP_WIDTH-1:0]    s_axis_rq_tkeep;
     wire                              [3:0]    s_axis_rq_tready;
     wire                                       s_axis_rq_tvalid;

     wire                 [C_DATA_WIDTH-1:0]    m_axis_rc_tdata;
     wire                             [74:0]    m_axis_rc_tuser;
     wire                                       m_axis_rc_tlast;
     wire                   [KEEP_WIDTH-1:0]    m_axis_rc_tkeep;
     wire                                       m_axis_rc_tvalid;
`ifdef XILINX_ULTRASCALE
     wire                                       m_axis_rc_tready;
`else //!XILINX_ULTRASCALE
     wire                             [21:0]    m_axis_rc_tready;
`endif //!XILINX_ULTRASCALE

     wire                 [C_DATA_WIDTH-1:0]    m_axis_cq_tdata;
`ifdef XILINX_ULTRASCALE_PLUS
     wire                             [87:0]    m_axis_cq_tuser;
`else //!XILINX_ULTRASCALE_PLUS
     wire                             [84:0]    m_axis_cq_tuser;
`endif //!XILINX_ULTRASCALE_PLUS
     wire                                       m_axis_cq_tlast;
     wire                   [KEEP_WIDTH-1:0]    m_axis_cq_tkeep;
     wire                                       m_axis_cq_tvalid;
`ifdef XILINX_ULTRASCALE
     wire                                       m_axis_cq_tready;
`else //!XILINX_ULTRASCALE
     wire                             [21:0]    m_axis_cq_tready;
`endif //!XILINX_ULTRASCALE

     wire                 [C_DATA_WIDTH-1:0]    s_axis_cc_tdata;
     wire                             [32:0]    s_axis_cc_tuser;
     wire                                       s_axis_cc_tlast;
     wire                   [KEEP_WIDTH-1:0]    s_axis_cc_tkeep;
     wire                                       s_axis_cc_tvalid;
     wire                              [3:0]    s_axis_cc_tready;

`ifdef PCIE_GEN3X16_STREAM_MAX_256BIT
     wire                                       s_axis_rq_tlast_axi500;
     wire                 [C_DATA_WIDTH-1:0]    s_axis_rq_tdata_axi500;
     wire                             [61:0]    s_axis_rq_tuser_axi500;
     wire                   [KEEP_WIDTH-1:0]    s_axis_rq_tkeep_axi500;
     wire                              [3:0]    s_axis_rq_tready_axi500;
     wire                                       s_axis_rq_tvalid_axi500;

     wire                 [C_DATA_WIDTH-1:0]    m_axis_rc_tdata_axi500;
     wire                             [74:0]    m_axis_rc_tuser_axi500;
     wire                                       m_axis_rc_tlast_axi500;
     wire                   [KEEP_WIDTH-1:0]    m_axis_rc_tkeep_axi500;
     wire                                       m_axis_rc_tvalid_axi500;
     wire                                       m_axis_rc_tready_axi500;

     wire                 [C_DATA_WIDTH-1:0]    m_axis_cq_tdata_axi500;
     wire                             [87:0]    m_axis_cq_tuser_axi500;
     wire                                       m_axis_cq_tlast_axi500;
     wire                   [KEEP_WIDTH-1:0]    m_axis_cq_tkeep_axi500;
     wire                                       m_axis_cq_tvalid_axi500;
     wire                                       m_axis_cq_tready_axi500;

     wire                 [C_DATA_WIDTH-1:0]    s_axis_cc_tdata_axi500;
     wire                             [32:0]    s_axis_cc_tuser_axi500;
     wire                                       s_axis_cc_tlast_axi500;
     wire                   [KEEP_WIDTH-1:0]    s_axis_cc_tkeep_axi500;
     wire                                       s_axis_cc_tvalid_axi500;
     wire                              [3:0]    s_axis_cc_tready_axi500;
`endif //PCIE_GEN3X16_STREAM_MAX_256BIT

    //----------------------------------------------------------------------------------------------------------------//
    //  Configuration (CFG) Interface                                                                                 //
    //----------------------------------------------------------------------------------------------------------------//

`ifdef XILINX_ULTRASCALE_PLUS
    wire                              [3:0]    pcie_tfc_nph_av;
    wire                              [3:0]    pcie_tfc_npd_av;
    wire                              [5:0]    pcie_rq_seq_num;
    wire                                       pcie_rq_seq_num_vld;
    wire                              [7:0]    pcie_rq_tag;
    wire                                       pcie_rq_tag_vld;
    wire                              [2:0]    cfg_negotiated_width;
    wire                              [1:0]    cfg_current_speed;
    wire                              [1:0]    cfg_max_payload;
`else //!XILINX_ULTRASCALE_PLUS
    wire                              [1:0]    pcie_tfc_nph_av;
    wire                              [1:0]    pcie_tfc_npd_av;
    wire                              [3:0]    pcie_rq_seq_num;
    wire                                       pcie_rq_seq_num_vld;
    wire                              [5:0]    pcie_rq_tag;
    wire                                       pcie_rq_tag_vld;
    wire                              [3:0]    cfg_negotiated_width;
    wire                              [2:0]    cfg_current_speed;
    wire                              [2:0]    cfg_max_payload;
`endif //!XILINX_ULTRASCALE_PLUS

    wire                                       pcie_cq_np_req;
    wire                              [5:0]    pcie_cq_np_req_count;

    wire                                       cfg_phy_link_down;
    wire                              [2:0]    cfg_max_read_req;
`ifdef XILINX_ULTRASCALE
    wire                             [15:0]    cfg_function_status;
    wire                             [11:0]    cfg_function_power_state;
 `ifdef XILINX_ULTRASCALE_PLUS
    wire                             [503:0]   cfg_vf_status;
    wire                             [755:0]   cfg_vf_power_state;
    wire                             [251:0]   cfg_vf_tph_requester_enable;
    wire                             [755:0]   cfg_vf_tph_st_mode;
    wire                             [251:0]   cfg_vf_flr_in_process;
 `else //!XILINX_ULTRASCALE_PLUS
    wire                             [15:0]    cfg_vf_status;
    wire                             [23:0]    cfg_vf_power_state;
    wire                              [7:0]    cfg_vf_tph_requester_enable;
    wire                             [23:0]    cfg_vf_tph_st_mode;
    wire                              [7:0]    cfg_vf_flr_in_process;
 `endif //!XILINX_ULTRASCALE_PLUS
`else //!XILINX_ULTRASCALE
    wire                              [7:0]    cfg_function_status;
    wire                              [5:0]    cfg_function_power_state;
    wire                             [11:0]    cfg_vf_status;
    wire                             [17:0]    cfg_vf_power_state;
    wire                              [5:0]    cfg_vf_tph_requester_enable;
    wire                             [17:0]    cfg_vf_tph_st_mode;
    wire                              [5:0]    cfg_vf_flr_in_process;
`endif //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_link_power_state;

    // Error Reporting Interface
    wire                                       cfg_err_cor_out;
    wire                                       cfg_err_nonfatal_out;
    wire                                       cfg_err_fatal_out;

    wire                              [5:0]    cfg_ltssm_state;
`ifdef XILINX_ULTRASCALE
    wire                              [3:0]    cfg_rcb_status;
`else //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_rcb_status;
`endif //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_obff_enable;
    wire                                       cfg_pl_status_change;

`ifdef XILINX_ULTRASCALE
    wire                              [3:0]    cfg_tph_requester_enable;
    wire                             [11:0]    cfg_tph_st_mode;
`else //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_tph_requester_enable;
    wire                              [5:0]    cfg_tph_st_mode;
`endif //!XILINX_ULTRASCALE
    // Management Interface
    wire                             [18:0]    cfg_mgmt_addr;
    wire                                       cfg_mgmt_write;
    wire                             [31:0]    cfg_mgmt_write_data;
    wire                              [3:0]    cfg_mgmt_byte_enable;
    wire                                       cfg_mgmt_read;
    wire                             [31:0]    cfg_mgmt_read_data;
    wire                                       cfg_mgmt_read_write_done;
    wire                                       cfg_mgmt_type1_cfg_reg_access;
    wire                                       cfg_msg_received;
    wire                              [7:0]    cfg_msg_received_data;
    wire                              [4:0]    cfg_msg_received_type;
    wire                                       cfg_msg_transmit;
    wire                              [2:0]    cfg_msg_transmit_type;
    wire                             [31:0]    cfg_msg_transmit_data;
    wire                                       cfg_msg_transmit_done;
    wire                              [7:0]    cfg_fc_ph;
    wire                             [11:0]    cfg_fc_pd;
    wire                              [7:0]    cfg_fc_nph;
    wire                             [11:0]    cfg_fc_npd;
    wire                              [7:0]    cfg_fc_cplh;
    wire                             [11:0]    cfg_fc_cpld;
    wire                              [2:0]    cfg_fc_sel;
    wire                              [2:0]    cfg_per_func_status_control;
    wire                                       cfg_config_space_enable;
    wire                              [7:0]    cfg_ds_port_number;
    wire                              [7:0]    cfg_ds_bus_number;
    wire                              [4:0]    cfg_ds_device_number;
    wire                              [2:0]    cfg_ds_function_number;
    wire                                       cfg_err_cor_in;
    wire                                       cfg_err_uncor_in;
`ifdef XILINX_ULTRASCALE
    wire                              [3:0]    cfg_flr_in_process;
`else //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_flr_in_process;
`endif //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_flr_done;
    wire                                       cfg_hot_reset_out;
    wire                                       cfg_hot_reset_in;
    wire                                       cfg_link_training_enable;
`ifdef XILINX_ULTRASCALE
    wire                              [3:0]    cfg_per_function_number;
`else //!XILINX_ULTRASCALE
    wire                              [2:0]    cfg_per_function_number;
`endif //!XILINX_ULTRASCALE
    wire                                       cfg_per_function_output_request;
    wire                                       cfg_power_state_change_interrupt;
    wire                                       cfg_req_pm_transition_l23_ready;
    wire                              [5:0]    cfg_vf_flr_done;
    wire                                       cfg_power_state_change_ack;

    wire                             [31:0]    cfg_ext_read_data;
    wire                                       cfg_ext_read_data_valid;
    //----------------------------------------------------------------------------------------------------------------//
    // EP Only                                                                                                        //
    //----------------------------------------------------------------------------------------------------------------//

    // Interrupt Interface Signals
    wire                              [3:0]    cfg_interrupt_int;
    wire                              [1:0]    cfg_interrupt_pending;
    wire                                       cfg_interrupt_sent;
`ifdef XILINX_ULTRASCALE
    wire                              [3:0]    cfg_interrupt_msi_enable;
    wire                             [11:0]    cfg_interrupt_msi_mmenable;
`else //!XILINX_ULTRASCALE
    wire                              [1:0]    cfg_interrupt_msi_enable;
    wire                              [5:0]    cfg_interrupt_msi_mmenable;
`endif //!XILINX_ULTRASCALE
    wire                                       cfg_interrupt_msi_mask_update;
    wire                             [31:0]    cfg_interrupt_msi_data;
    wire                              [3:0]    cfg_interrupt_msi_select;
    wire                             [31:0]    cfg_interrupt_msi_int;
    wire                             [63:0]    cfg_interrupt_msi_pending_status;
    wire                                       cfg_interrupt_msi_sent;
    wire                                       cfg_interrupt_msi_fail;
    wire                              [2:0]    cfg_interrupt_msi_attr;
    wire                                       cfg_interrupt_msi_tph_present;
    wire                              [1:0]    cfg_interrupt_msi_tph_type;
    wire                              [8:0]    cfg_interrupt_msi_tph_st_tag;
    wire                              [2:0]    cfg_interrupt_msi_function_number;

    wire                                       user_clk_var;
    wire                                       user_reset_var;
    wire                                       user_lnk_up_var;
    wire                                       cfg_interrupt_msi_sent_var;
    wire                             [31:0]    cfg_interrupt_msi_int_var;


    // Assign Statements
`ifndef XILINX_ULTRASCALE_PLUS
    assign cfg_bus_number[7:0]          = cfg_ds_bus_number[7:0];
`endif
    assign cfg_device_number[4:0]       = cfg_ds_device_number[4:0];
    assign cfg_function_number[2:0]     = cfg_ds_function_number[2:0];




    //----------------------------------------------------------------------------------------------------------------//
    //    System(SYS) Interface                                                                                       //
    //----------------------------------------------------------------------------------------------------------------//
    wire                                               sys_clk;
    wire                                               sys_clk_gt;
    wire                                               sys_reset_n_c;

    //-----------------------------------------------------------------------------------------------------------------------


    // ref_clk IBUFDS from the edge connector
`ifdef XILINX_ULTRASCALE_PLUS
    IBUFDS_GTE4 refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
    assign sys_reset_n_c = sys_reset_n;	// Don't tie to IBUF, need to send pcie_reset_f to other logic
`elsif XILINX_ULTRASCALE    
    IBUFDS_GTE3 refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
    assign sys_reset_n_c = sys_reset_n;    // Don't tie to IBUF, need to send pcie_reset_f to other logic    
`else
    IBUFDS_GTE3 refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
    IBUF   sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));
`endif


`ifdef XILINX_ULTRASCALE_PLUS
`else //!XILINX_ULTRASCALE_PLUS
  //wire [15:0]  cfg_vend_id        = 16'h19DE;
  wire [15:0]  cfg_subsys_vend_id = 16'h19DE;
  //wire [15:0]  cfg_dev_id         = 16'h0850;
  //wire [15:0]  cfg_subsys_id      = 16'h2095;
  //wire [7:0]   cfg_rev_id         = 8'h05;
`endif //!XILINX_ULTRASCALE_PLUS

`ifdef CONVEY_SIM
 `ifndef XILINX_ULTRASCALE_PLUS
   wire [16:0]		common_commands_out_ep;
   wire [69:0]		pipe_tx_0_sigs_ep;
   wire [69:0]		pipe_tx_1_sigs_ep;
   wire [69:0]		pipe_tx_2_sigs_ep;
   wire [69:0]		pipe_tx_3_sigs_ep;
   wire [69:0]		pipe_tx_4_sigs_ep;
   wire [69:0]		pipe_tx_5_sigs_ep;
   wire [69:0]		pipe_tx_6_sigs_ep;
   wire [69:0]		pipe_tx_7_sigs_ep;
 `endif //!XILINX_ULTRASCALE_PLUS
   wire [25:0]		common_commands_in_ep;
   wire [83:0]		pipe_rx_0_sigs_ep;
   wire [83:0]		pipe_rx_1_sigs_ep;
   wire [83:0]		pipe_rx_2_sigs_ep;
   wire [83:0]		pipe_rx_3_sigs_ep;
   wire [83:0]		pipe_rx_4_sigs_ep;
   wire [83:0]		pipe_rx_5_sigs_ep;
   wire [83:0]		pipe_rx_6_sigs_ep;
   wire [83:0]		pipe_rx_7_sigs_ep;
 `ifdef XILINX_ULTRASCALE_PLUS
   wire [25:0]		common_commands_out_ep;
   wire [83:0]		pipe_tx_0_sigs_ep;
   wire [83:0]		pipe_tx_1_sigs_ep;
   wire [83:0]		pipe_tx_2_sigs_ep;
   wire [83:0]		pipe_tx_3_sigs_ep;
   wire [83:0]		pipe_tx_4_sigs_ep;
   wire [83:0]		pipe_tx_5_sigs_ep;
   wire [83:0]		pipe_tx_6_sigs_ep;
   wire [83:0]		pipe_tx_7_sigs_ep;
   wire [83:0]		pipe_tx_8_sigs_ep;
   wire [83:0]		pipe_tx_9_sigs_ep;
   wire [83:0]		pipe_tx_10_sigs_ep;
   wire [83:0]		pipe_tx_11_sigs_ep;
   wire [83:0]		pipe_tx_12_sigs_ep;
   wire [83:0]		pipe_tx_13_sigs_ep;
   wire [83:0]		pipe_tx_14_sigs_ep;
   wire [83:0]		pipe_tx_15_sigs_ep;

   wire [83:0]		pipe_rx_8_sigs_ep;
   wire [83:0]		pipe_rx_9_sigs_ep;
   wire [83:0]		pipe_rx_10_sigs_ep;
   wire [83:0]		pipe_rx_11_sigs_ep;
   wire [83:0]		pipe_rx_12_sigs_ep;
   wire [83:0]		pipe_rx_13_sigs_ep;
   wire [83:0]		pipe_rx_14_sigs_ep;
   wire [83:0]		pipe_rx_15_sigs_ep;
 `endif //XILINX_ULTRASCALE_PLUS
`endif //CONVEY_SIM

    // Support Level Wrapper
`ifdef CONVEY_SIM
    `ifdef XILINX_ULTRASCALE_PLUS
	`ifdef PCIE_GEN3X16
           pcie3_uscale_plus_v1_2_x16 pcie_core (
	`else //!PCIE_GEN3X16
           pcie3_uscale_plus_v1_2_x8 pcie_core (
	`endif //!PCIE_GEN3X16
    `else // !XILINX_ULTRASCALE_PLUS
        pcie3_ultrascale_v4_1_x8 pcie_core (
    `endif // !XILINX_ULTRASCALE_PLUS
`elsif XILINX_ULTRASCALE_PLUS
    `ifdef PCIE_GEN3X16
        pcie4_uscale_plus_0 pcie4_uscale_plus_0 (
    `else //!PCIE_GEN3X16
        pcie3_uscale_plus_x8 pcie3_uscale_plus_x8 (
    `endif //!PCIE_GEN3X16
`elsif PCIE_GEN3X8
    pcie_gen3x8_ultrascale_0_1 pcie3_ultrascale_0_i (
`else  // PCIE_GEN2X8
    pcie3_ultrascale_0 pcie3_ultrascale_0_i (
`endif // PCIE_GEN2X8

    //---------------------------------------------------------------------------------------//
    //  PCI Express (pci_exp) Interface                                                      //
    //---------------------------------------------------------------------------------------//

    // Tx
    .pci_exp_txn                                    ( pci_exp_txn ),
    .pci_exp_txp                                    ( pci_exp_txp ),

    // Rx
    .pci_exp_rxn                                    ( pci_exp_rxn ),
    .pci_exp_rxp                                    ( pci_exp_rxp ),

    //---------------------------------------------------------------------------------------//
    //  AXI Interface                                                                        //
    //---------------------------------------------------------------------------------------//

    .user_clk                                       ( user_clk_var ),    // output user_clk;
    .user_reset                                     ( user_reset_var ),  // output user_reset;
    .user_lnk_up                                    ( user_lnk_up_var ), // output user_lnk_up;
`ifdef PCIE_GEN3X16_STREAM_MAX_256BIT
    .user_clk2                                      ( user_clk2 ),   // output user_clk2;          // 500Mhz core clock
    .s_axis_rq_tlast                                ( s_axis_rq_tlast_axi500 ),
    .s_axis_rq_tdata                                ( s_axis_rq_tdata_axi500 ),
    .s_axis_rq_tuser                                ( s_axis_rq_tuser_axi500 ),
    .s_axis_rq_tkeep                                ( s_axis_rq_tkeep_axi500 ),
    .s_axis_rq_tready                               ( s_axis_rq_tready_axi500 ),
    .s_axis_rq_tvalid                               ( s_axis_rq_tvalid_axi500 ),

    .m_axis_rc_tdata                                ( m_axis_rc_tdata_axi500 ),
    .m_axis_rc_tuser                                ( m_axis_rc_tuser_axi500 ),
    .m_axis_rc_tlast                                ( m_axis_rc_tlast_axi500 ),
    .m_axis_rc_tkeep                                ( m_axis_rc_tkeep_axi500 ),
    .m_axis_rc_tvalid                               ( m_axis_rc_tvalid_axi500 ),
    .m_axis_rc_tready                               ( m_axis_rc_tready_axi500 ),

    .m_axis_cq_tdata                                ( m_axis_cq_tdata_axi500 ),
    .m_axis_cq_tuser                                ( m_axis_cq_tuser_axi500 ),
    .m_axis_cq_tlast                                ( m_axis_cq_tlast_axi500 ),
    .m_axis_cq_tkeep                                ( m_axis_cq_tkeep_axi500 ),
    .m_axis_cq_tvalid                               ( m_axis_cq_tvalid_axi500 ),
    .m_axis_cq_tready                               ( m_axis_cq_tready_axi500 ),

    .s_axis_cc_tdata                                ( s_axis_cc_tdata_axi500 ),
    .s_axis_cc_tuser                                ( s_axis_cc_tuser_axi500 ),
    .s_axis_cc_tlast                                ( s_axis_cc_tlast_axi500 ),
    .s_axis_cc_tkeep                                ( s_axis_cc_tkeep_axi500 ),
    .s_axis_cc_tvalid                               ( s_axis_cc_tvalid_axi500 ),
    .s_axis_cc_tready                               ( s_axis_cc_tready_axi500 ),
`else //!PCIE_GEN3X16_STREAM_MAX_256BIT
    .s_axis_rq_tlast                                ( s_axis_rq_tlast ),
    .s_axis_rq_tdata                                ( s_axis_rq_tdata ),
 `ifdef XILINX_ULTRASCALE_PLUS
    .s_axis_rq_tuser                                ( s_axis_rq_tuser ),
 `else //!XILINX_ULTRASCALE_PLUS
    .s_axis_rq_tuser                                ( s_axis_rq_tuser[59:0] ),
 `endif //!XILINX_ULTRASCALE_PLUS
    .s_axis_rq_tkeep                                ( s_axis_rq_tkeep ),
    .s_axis_rq_tready                               ( s_axis_rq_tready ),
    .s_axis_rq_tvalid                               ( s_axis_rq_tvalid ),

    .m_axis_rc_tdata                                ( m_axis_rc_tdata ),
    .m_axis_rc_tuser                                ( m_axis_rc_tuser ),
    .m_axis_rc_tlast                                ( m_axis_rc_tlast ),
    .m_axis_rc_tkeep                                ( m_axis_rc_tkeep ),
    .m_axis_rc_tvalid                               ( m_axis_rc_tvalid ),
    .m_axis_rc_tready                               ( m_axis_rc_tready ),

    .m_axis_cq_tdata                                ( m_axis_cq_tdata ),
    .m_axis_cq_tuser                                ( m_axis_cq_tuser ),
    .m_axis_cq_tlast                                ( m_axis_cq_tlast ),
    .m_axis_cq_tkeep                                ( m_axis_cq_tkeep ),
    .m_axis_cq_tvalid                               ( m_axis_cq_tvalid ),
    .m_axis_cq_tready                               ( m_axis_cq_tready ),

    .s_axis_cc_tdata                                ( s_axis_cc_tdata ),
    .s_axis_cc_tuser                                ( s_axis_cc_tuser ),
    .s_axis_cc_tlast                                ( s_axis_cc_tlast ),
    .s_axis_cc_tkeep                                ( s_axis_cc_tkeep ),
    .s_axis_cc_tvalid                               ( s_axis_cc_tvalid ),
    .s_axis_cc_tready                               ( s_axis_cc_tready ),
`endif //!PCIE_GEN3X16_STREAM_MAX_256BIT

    //---------------------------------------------------------------------------------------//
    //  Configuration (CFG) Interface                                                        //
    //---------------------------------------------------------------------------------------//

`ifdef XILINX_ULTRASCALE_PLUS
    .pcie_rq_seq_num0                               ( pcie_rq_seq_num ),
    .pcie_rq_seq_num_vld0                           ( pcie_rq_seq_num_vld ),
    .pcie_rq_tag0                                   ( pcie_rq_tag ),
    .pcie_rq_tag_vld0                               ( pcie_rq_tag_vld ),
    .pcie_rq_seq_num1                               ( ),
    .pcie_rq_seq_num_vld1                           ( ),
    .pcie_rq_tag1                                   ( ),
    .pcie_rq_tag_vld1                               ( ),
    .pcie_cq_np_req                                 ( {2{pcie_cq_np_req}} ),
`else //!XILINX_ULTRASCALE_PLUS
    .pcie_rq_seq_num                                ( pcie_rq_seq_num ),
    .pcie_rq_seq_num_vld                            ( pcie_rq_seq_num_vld ),
    .pcie_rq_tag                                    ( pcie_rq_tag ),
    .pcie_rq_tag_vld                                ( pcie_rq_tag_vld ),
    .pcie_cq_np_req                                 ( pcie_cq_np_req ),
`endif //!XILINX_ULTRASCALE_PLUS
    .pcie_rq_tag_av                                 ( ),
    .pcie_cq_np_req_count                           ( pcie_cq_np_req_count ),
    .cfg_phy_link_down                              ( cfg_phy_link_down ),
    .cfg_phy_link_status                            ( ),
    .cfg_negotiated_width                           ( cfg_negotiated_width ),
    .cfg_current_speed                              ( cfg_current_speed ),
    .cfg_max_payload                                ( cfg_max_payload ),
    .cfg_max_read_req                               ( cfg_max_read_req ),
`ifdef XILINX_ULTRASCALE_PLUS
    .cfg_local_error_valid                          ( ),
    .cfg_local_error_out                            ( ),
    .cfg_rx_pm_state                                ( ),
    .cfg_tx_pm_state                                ( ),
`else //!XILINX_ULTRASCALE_PLUS
    .cfg_local_error                                ( ),
    .cfg_ltr_enable                                 ( ),
    .cfg_dpa_substate_change                        ( ),
`endif //!XILINX_ULTRASCALE_PLUS
    .cfg_function_status                            ( cfg_function_status ),
    .cfg_function_power_state                       ( cfg_function_power_state ),
    .cfg_vf_status                                  ( cfg_vf_status ),
    .cfg_vf_power_state                             ( cfg_vf_power_state ),
    .cfg_link_power_state                           ( cfg_link_power_state ),
    // Error Reporting Interface
    .cfg_err_cor_out                                ( cfg_err_cor_out ),
    .cfg_err_nonfatal_out                           ( cfg_err_nonfatal_out ),
    .cfg_err_fatal_out                              ( cfg_err_fatal_out ),

    .cfg_ltssm_state                                ( cfg_ltssm_state ),
    .cfg_rcb_status                                 ( cfg_rcb_status ),
    .cfg_obff_enable                                ( cfg_obff_enable ),
    .cfg_pl_status_change                           ( cfg_pl_status_change ),

    .cfg_tph_requester_enable                       ( cfg_tph_requester_enable ),
    .cfg_tph_st_mode                                ( cfg_tph_st_mode ),
    .cfg_vf_tph_requester_enable                    ( cfg_vf_tph_requester_enable ),
    .cfg_vf_tph_st_mode                             ( cfg_vf_tph_st_mode ),
    // Management Interface
`ifdef XILINX_ULTRASCALE_PLUS
    .cfg_mgmt_addr                                  ( cfg_mgmt_addr[9:0] ),
    .cfg_mgmt_function_number                       ( 8'h0 ),
    .cfg_mgmt_debug_access                          ( cfg_mgmt_type1_cfg_reg_access ),
`else //!XILINX_ULTRASCALE_PLUS
    .cfg_mgmt_addr                                  ( cfg_mgmt_addr ),
    .cfg_mgmt_type1_cfg_reg_access                  ( cfg_mgmt_type1_cfg_reg_access ),
`endif //!XILINX_ULTRASCALE_PLUS
    .cfg_mgmt_write                                 ( cfg_mgmt_write ),
    .cfg_mgmt_write_data                            ( cfg_mgmt_write_data ),
    .cfg_mgmt_byte_enable                           ( cfg_mgmt_byte_enable ),
    .cfg_mgmt_read                                  ( cfg_mgmt_read ),
    .cfg_mgmt_read_data                             ( cfg_mgmt_read_data ),
    .cfg_mgmt_read_write_done                       ( cfg_mgmt_read_write_done ),
    .pcie_tfc_nph_av                                ( pcie_tfc_nph_av ),
    .pcie_tfc_npd_av                                ( pcie_tfc_npd_av ),
    .cfg_msg_received                               ( cfg_msg_received ),
    .cfg_msg_received_data                          ( cfg_msg_received_data ),
    .cfg_msg_received_type                          ( cfg_msg_received_type ),

    .cfg_msg_transmit                               ( cfg_msg_transmit ),
    .cfg_msg_transmit_type                          ( cfg_msg_transmit_type ),
    .cfg_msg_transmit_data                          ( cfg_msg_transmit_data ),
    .cfg_msg_transmit_done                          ( cfg_msg_transmit_done ),

    .cfg_fc_ph                                      ( cfg_fc_ph ),
    .cfg_fc_pd                                      ( cfg_fc_pd ),
    .cfg_fc_nph                                     ( cfg_fc_nph ),
    .cfg_fc_npd                                     ( cfg_fc_npd ),
    .cfg_fc_cplh                                    ( cfg_fc_cplh ),
    .cfg_fc_cpld                                    ( cfg_fc_cpld ),
    .cfg_fc_sel                                     ( cfg_fc_sel ),

    //-------------------------------------------------------------------------------//
    // EP and RP                                                                     //
    //-------------------------------------------------------------------------------//
`ifdef XILINX_ULTRASCALE_PLUS
    .cfg_bus_number                                 ( cfg_bus_number ),
`else //!XILINX_ULTRASCALE_PLUS
    .cfg_subsys_vend_id                             ( cfg_subsys_vend_id ),
    .cfg_per_func_status_control                    ( cfg_per_func_status_control ),
    .cfg_per_func_status_data                       ( ),
    .cfg_per_function_number                        ( cfg_per_function_number ),
    .cfg_per_function_output_request                ( cfg_per_function_output_request ),
    .cfg_per_function_update_done                   ( ),
`endif //!XILINX_ULTRASCALE_PLUS

    .cfg_dsn                                        ( cfg_dsn ),
    .cfg_power_state_change_ack                     ( cfg_power_state_change_ack ),
    .cfg_power_state_change_interrupt               ( cfg_power_state_change_interrupt ),
    .cfg_err_cor_in                                 ( cfg_err_cor_in ),
    .cfg_err_uncor_in                               ( cfg_err_uncor_in ),

    .cfg_flr_in_process                             ( cfg_flr_in_process ),
    .cfg_flr_done                                   ( {2'b0,cfg_flr_done} ),
    .cfg_vf_flr_in_process                          ( cfg_vf_flr_in_process ),
`ifdef XILINX_ULTRASCALE_PLUS
    .cfg_vf_flr_func_num                            ( 8'h0 ),
    .cfg_vf_flr_done                                ( cfg_vf_flr_done[0] ),
`else //!XILINX_ULTRASCALE_PLUS
    .cfg_vf_flr_done                                ( {2'b0,cfg_vf_flr_done} ),
`endif //!XILINX_ULTRASCALE_PLUS

    .cfg_link_training_enable                       ( cfg_link_training_enable ),
  // EP only
    .cfg_hot_reset_out                              ( cfg_hot_reset_out ),
    .cfg_config_space_enable                        ( cfg_config_space_enable ),
    .cfg_req_pm_transition_l23_ready                ( cfg_req_pm_transition_l23_ready ),

  // RP only
    .cfg_hot_reset_in                               ( cfg_hot_reset_in ),

    .cfg_ds_bus_number                              ( cfg_ds_bus_number ),
    .cfg_ds_device_number                           ( cfg_ds_device_number ),
`ifdef XILINX_ULTRASCALE_PLUS
`else //!XILINX_ULTRASCALE_PLUS
  `ifdef CONVEY_SIM
    .cfg_ext_write_received                         ( ),
    .cfg_ext_read_received                          ( ),
    .cfg_ext_register_number                        ( ),
    .cfg_ext_function_number                        ( ),
    .cfg_ext_write_data                             ( ),
    .cfg_ext_write_byte_enable                      ( ),
    .cfg_ext_read_data                              ( cfg_ext_read_data ),
    .cfg_ext_read_data_valid                        ( cfg_ext_read_data_valid ),
  `endif //CONVEY_SIM
    .cfg_ds_function_number                         ( cfg_ds_function_number ),
`endif //!XILINX_ULTRASCALE_PLUS
    .cfg_ds_port_number                             ( cfg_ds_port_number ),
    //-------------------------------------------------------------------------------//
    // EP Only                                                                       //
    //-------------------------------------------------------------------------------//

    // Interrupt Interface Signals
    .cfg_interrupt_int                              ( cfg_interrupt_int ),
    .cfg_interrupt_pending                          ( {2'b0,cfg_interrupt_pending} ),
    .cfg_interrupt_sent                             ( cfg_interrupt_sent ),

    .cfg_interrupt_msi_enable                       ( cfg_interrupt_msi_enable ),
    .cfg_interrupt_msi_mmenable                     ( cfg_interrupt_msi_mmenable ),
    .cfg_interrupt_msi_mask_update                  ( cfg_interrupt_msi_mask_update ),
    .cfg_interrupt_msi_data                         ( cfg_interrupt_msi_data ),
`ifdef XILINX_ULTRASCALE_PLUS
    .cfg_interrupt_msi_select                       ( cfg_interrupt_msi_select[1:0] ),
    .cfg_interrupt_msi_pending_status_function_num  ( 2'h0),
    .cfg_interrupt_msi_tph_st_tag                   ( cfg_interrupt_msi_tph_st_tag[7:0] ),
    .cfg_interrupt_msi_function_number              ( {5'h0,cfg_interrupt_msi_function_number} ),
    .cfg_pm_aspm_l1_entry_reject                    ( 1'b0 ),
    .cfg_pm_aspm_tx_l0s_entry_disable               ( 1'b0 ),
`else //!XILINX_ULTRASCALE_PLUS
    .cfg_interrupt_msi_select                       ( cfg_interrupt_msi_select ),
    .cfg_interrupt_msi_pending_status_function_num  ( 4'h0),
    .cfg_interrupt_msi_tph_st_tag                   ( cfg_interrupt_msi_tph_st_tag ),
    .cfg_interrupt_msi_function_number              ( {1'b0,cfg_interrupt_msi_function_number} ),
    .cfg_interrupt_msi_vf_enable                    ( ),
`endif //!XILINX_ULTRASCALE_PLUS
    .cfg_interrupt_msi_int                          ( cfg_interrupt_msi_int_var ),    // input  [31:0] cfg_interrupt_msi_int;
    .cfg_interrupt_msi_pending_status               ( cfg_interrupt_msi_pending_status [31:0]),
    .cfg_interrupt_msi_sent                         ( cfg_interrupt_msi_sent_var ),   // output        cfg_interrupt_msi_sent;
    .cfg_interrupt_msi_fail                         ( cfg_interrupt_msi_fail ),
    .cfg_interrupt_msi_attr                         ( cfg_interrupt_msi_attr ),
    .cfg_interrupt_msi_tph_present                  ( cfg_interrupt_msi_tph_present ),
    .cfg_interrupt_msi_tph_type                     ( cfg_interrupt_msi_tph_type ),
    .cfg_interrupt_msi_pending_status_data_enable   ( 1'b0),
    //--------------------------------------------------------------------------------------//
    // Reset Pass Through Signals
    //  - Only used for PCIe_X0Y0
    //--------------------------------------------------------------------------------------//
`ifdef XILINX_ULTRASCALE_PLUS
    .int_qpll0lock_out			(),
    .int_qpll0outrefclk_out		(),
    .int_qpll0outclk_out		(),
`endif //XILINX_ULTRASCALE_PLUS

`ifdef XILINX_ULTRASCALE
    .int_qpll1lock_out			(),
    .int_qpll1outrefclk_out		(),
    .int_qpll1outclk_out		(),
`endif //XILINX_ULTRASCALE

`ifdef CONVEY_SIM
    // PIPE Mode Interface
      .common_commands_out              (common_commands_out_ep),
      .pipe_tx_0_sigs                   (pipe_tx_0_sigs_ep),
      .pipe_tx_1_sigs                   (pipe_tx_1_sigs_ep),
      .pipe_tx_2_sigs                   (pipe_tx_2_sigs_ep),
      .pipe_tx_3_sigs                   (pipe_tx_3_sigs_ep),
      .pipe_tx_4_sigs                   (pipe_tx_4_sigs_ep),
      .pipe_tx_5_sigs                   (pipe_tx_5_sigs_ep),
      .pipe_tx_6_sigs                   (pipe_tx_6_sigs_ep),
      .pipe_tx_7_sigs                   (pipe_tx_7_sigs_ep),
   `ifdef XILINX_ULTRASCALE_PLUS
      .pipe_tx_8_sigs                   (pipe_tx_8_sigs_ep),
      .pipe_tx_9_sigs                   (pipe_tx_9_sigs_ep),
      .pipe_tx_10_sigs                  (pipe_tx_10_sigs_ep),
      .pipe_tx_11_sigs                  (pipe_tx_11_sigs_ep),
      .pipe_tx_12_sigs                  (pipe_tx_12_sigs_ep),
      .pipe_tx_13_sigs                  (pipe_tx_13_sigs_ep),
      .pipe_tx_14_sigs                  (pipe_tx_14_sigs_ep),
      .pipe_tx_15_sigs                  (pipe_tx_15_sigs_ep),
   `endif //XILINX_ULTRASCALE_PLUS
      .common_commands_in               (common_commands_in_ep),
      .pipe_rx_0_sigs                   (pipe_rx_0_sigs_ep),
      .pipe_rx_1_sigs                   (pipe_rx_1_sigs_ep),
      .pipe_rx_2_sigs                   (pipe_rx_2_sigs_ep),
      .pipe_rx_3_sigs                   (pipe_rx_3_sigs_ep),
      .pipe_rx_4_sigs                   (pipe_rx_4_sigs_ep),
      .pipe_rx_5_sigs                   (pipe_rx_5_sigs_ep),
      .pipe_rx_6_sigs                   (pipe_rx_6_sigs_ep),
      .pipe_rx_7_sigs                   (pipe_rx_7_sigs_ep),
   `ifdef XILINX_ULTRASCALE_PLUS
      .pipe_rx_8_sigs			(pipe_rx_8_sigs_ep),
      .pipe_rx_9_sigs			(pipe_rx_9_sigs_ep),
      .pipe_rx_10_sigs			(pipe_rx_10_sigs_ep),
      .pipe_rx_11_sigs			(pipe_rx_11_sigs_ep),
      .pipe_rx_12_sigs			(pipe_rx_12_sigs_ep),
      .pipe_rx_13_sigs			(pipe_rx_13_sigs_ep),
      .pipe_rx_14_sigs			(pipe_rx_14_sigs_ep),
      .pipe_rx_15_sigs			(pipe_rx_15_sigs_ep),
      .phy_rdy_out			(),
   `endif // XILINX_ULTRASCALE_PLUS
`endif //CONVEY_SIM

    //--------------------------------------------------------------------------------------//
    //  System(SYS) Interface                                                               //
    //--------------------------------------------------------------------------------------//

    .sys_clk                                        ( sys_clk ),
    .sys_clk_gt                                     ( sys_clk_gt ),
    .sys_reset                                      ( sys_reset_n_c )
    );


    //------------------------------------------------------------------------------------------------------------------//
    //       PIO Example Design Top Level                                                                               //
    //------------------------------------------------------------------------------------------------------------------//
    pcie3_7x_to_v1_6 #(
        .TCQ                                    ( TCQ                           ),
        .C_DATA_WIDTH                           ( C_DATA_WIDTH                   )
    ) pcie3_7x_to_v1_6 (

        //-------------------------------------------------------------------------------------//
        //  AXI Interface                                                                      //
        //-------------------------------------------------------------------------------------//

        .s_axis_rq_tlast                                ( s_axis_rq_tlast ),
        .s_axis_rq_tdata                                ( s_axis_rq_tdata ),
        .s_axis_rq_tuser                                ( s_axis_rq_tuser ),
        .s_axis_rq_tkeep                                ( s_axis_rq_tkeep ),
        .s_axis_rq_tready                               ( s_axis_rq_tready ),
        .s_axis_rq_tvalid                               ( s_axis_rq_tvalid ),

        .m_axis_rc_tdata                                ( m_axis_rc_tdata ),
        .m_axis_rc_tuser                                ( m_axis_rc_tuser ),
        .m_axis_rc_tlast                                ( m_axis_rc_tlast ),
        .m_axis_rc_tkeep                                ( m_axis_rc_tkeep ),
        .m_axis_rc_tvalid                               ( m_axis_rc_tvalid ),
        .m_axis_rc_tready                               ( m_axis_rc_tready ),

        .m_axis_cq_tdata                                ( m_axis_cq_tdata ),
        .m_axis_cq_tuser                                ( m_axis_cq_tuser[84:0] ),
        .m_axis_cq_tlast                                ( m_axis_cq_tlast ),
        .m_axis_cq_tkeep                                ( m_axis_cq_tkeep ),
        .m_axis_cq_tvalid                               ( m_axis_cq_tvalid ),
        .m_axis_cq_tready                               ( m_axis_cq_tready ),

        .s_axis_cc_tdata                                ( s_axis_cc_tdata ),
        .s_axis_cc_tuser                                ( s_axis_cc_tuser ),
        .s_axis_cc_tlast                                ( s_axis_cc_tlast ),
        .s_axis_cc_tkeep                                ( s_axis_cc_tkeep ),
        .s_axis_cc_tvalid                               ( s_axis_cc_tvalid ),
        .s_axis_cc_tready                               ( s_axis_cc_tready ),

        .s_axis_tx_tready                               ( s_axis_tx_tready  ),
        .s_axis_tx_tdata                                ( s_axis_tx_tdata   ),
        .s_axis_tx_tstrb                                ( s_axis_tx_tstrb   ),
        .s_axis_tx_tuser                                ( s_axis_tx_tuser   ),
        .s_axis_tx_tlast                                ( s_axis_tx_tlast   ),
        .s_axis_tx_tvalid                               ( s_axis_tx_tvalid  ),

        .m_axis_rx_tdata                                ( m_axis_rx_tdata   ),
        .m_axis_rx_tstrb                                ( m_axis_rx_tstrb   ),
        .m_axis_rx_tlast                                ( m_axis_rx_tlast   ),
        .m_axis_rx_tvalid                               ( m_axis_rx_tvalid  ),
        .m_axis_rx_tready                               ( m_axis_rx_tready  ),
        .m_axis_rx_tuser                                ( m_axis_rx_tuser   ),

        .cfg_interrupt                                  ( cfg_interrupt ),
        .cfg_interrupt_rdy                              ( cfg_interrupt_rdy ),

        //--------------------------------------------------------------------------------//
        //  Configuration (CFG) Interface                                                 //
        //--------------------------------------------------------------------------------//

        .pcie_tfc_nph_av                                ( pcie_tfc_nph_av[1:0] ),
        .pcie_tfc_npd_av                                ( pcie_tfc_npd_av[1:0] ),

        .pcie_rq_seq_num                                ( pcie_rq_seq_num[3:0] ),
        .pcie_rq_seq_num_vld                            ( pcie_rq_seq_num_vld ),
        .pcie_rq_tag                                    ( pcie_rq_tag[5:0] ),
        .pcie_rq_tag_vld                                ( pcie_rq_tag_vld ),

        .pcie_cq_np_req                                 ( pcie_cq_np_req ),
        .pcie_cq_np_req_count                           ( pcie_cq_np_req_count ),

        .cfg_phy_link_down                              ( cfg_phy_link_down ),
        .cfg_negotiated_width                           ( cfg_negotiated_width[2:0] ),
        .cfg_current_speed                              ( cfg_current_speed[1:0] ),
        .cfg_max_payload                                ( cfg_max_payload[1:0] ),
        .cfg_max_read_req                               ( cfg_max_read_req ),
        .cfg_function_status                            ( cfg_function_status ),
        .cfg_function_power_state                       ( cfg_function_power_state ),
        .cfg_vf_status                                  ( cfg_vf_status[11:0] ),
        .cfg_vf_power_state                             ( cfg_vf_power_state[17:0] ),
        .cfg_link_power_state                           ( cfg_link_power_state ),

        // Error Reporting Interface
        .cfg_err_cor_out                                ( cfg_err_cor_out ),
        .cfg_err_nonfatal_out                           ( cfg_err_nonfatal_out ),
        .cfg_err_fatal_out                              ( cfg_err_fatal_out ),

        .cfg_ltssm_state                                ( cfg_ltssm_state ),
        .cfg_rcb_status                                 ( cfg_rcb_status ),
        .cfg_obff_enable                                ( cfg_obff_enable ),
        .cfg_pl_status_change                           ( cfg_pl_status_change ),

        .cfg_tph_requester_enable                       ( cfg_tph_requester_enable ),
        .cfg_tph_st_mode                                ( cfg_tph_st_mode ),
        .cfg_vf_tph_requester_enable                    ( cfg_vf_tph_requester_enable[5:0] ),
        .cfg_vf_tph_st_mode                             ( cfg_vf_tph_st_mode[17:0] ),
        // Management Interface
        .cfg_mgmt_addr                                  ( cfg_mgmt_addr ),
        .cfg_mgmt_write                                 ( cfg_mgmt_write ),
        .cfg_mgmt_write_data                            ( cfg_mgmt_write_data ),
        .cfg_mgmt_byte_enable                           ( cfg_mgmt_byte_enable ),
        .cfg_mgmt_read                                  ( cfg_mgmt_read ),
        .cfg_mgmt_read_data                             ( cfg_mgmt_read_data ),
        .cfg_mgmt_read_write_done                       ( cfg_mgmt_read_write_done ),
        .cfg_mgmt_type1_cfg_reg_access                  ( cfg_mgmt_type1_cfg_reg_access ),
        .cfg_msg_received                               ( cfg_msg_received ),
        .cfg_msg_received_data                          ( cfg_msg_received_data ),
        .cfg_msg_received_type                          ( cfg_msg_received_type ),
        .cfg_msg_transmit                               ( cfg_msg_transmit ),
        .cfg_msg_transmit_type                          ( cfg_msg_transmit_type ),
        .cfg_msg_transmit_data                          ( cfg_msg_transmit_data ),
        .cfg_msg_transmit_done                          ( cfg_msg_transmit_done ),
        .cfg_fc_ph                                      ( cfg_fc_ph ),
        .cfg_fc_pd                                      ( cfg_fc_pd ),
        .cfg_fc_nph                                     ( cfg_fc_nph ),
        .cfg_fc_npd                                     ( cfg_fc_npd ),
        .cfg_fc_cplh                                    ( cfg_fc_cplh ),
        .cfg_fc_cpld                                    ( cfg_fc_cpld ),
        .cfg_fc_sel                                     ( cfg_fc_sel ),
        .cfg_per_func_status_control                    ( cfg_per_func_status_control ),
        .cfg_config_space_enable                        ( cfg_config_space_enable ),
        .cfg_ds_bus_number                              ( cfg_ds_bus_number ),
        .cfg_ds_device_number                           ( cfg_ds_device_number ),
        .cfg_ds_function_number                         ( cfg_ds_function_number ),
        .cfg_ds_port_number                             ( cfg_ds_port_number ),
        .cfg_err_cor_in                                 ( cfg_err_cor_in ),
        .cfg_err_uncor_in                               ( cfg_err_uncor_in ),
        .cfg_flr_in_process                             ( cfg_flr_in_process ),
        .cfg_flr_done                                   ( cfg_flr_done ),
        .cfg_hot_reset_in                               ( cfg_hot_reset_in ),
        .cfg_hot_reset_out                              ( cfg_hot_reset_out ),
        .cfg_link_training_enable                       ( cfg_link_training_enable ),
        .cfg_per_function_number                        ( cfg_per_function_number ),
        .cfg_per_function_output_request                ( cfg_per_function_output_request ),
        .cfg_power_state_change_interrupt               ( cfg_power_state_change_interrupt ),
        .cfg_req_pm_transition_l23_ready                ( cfg_req_pm_transition_l23_ready ),
        .cfg_vf_flr_in_process                          ( cfg_vf_flr_in_process[5:0] ),
        .cfg_vf_flr_done                                ( cfg_vf_flr_done ),
        .cfg_power_state_change_ack                     ( cfg_power_state_change_ack ),
        .cfg_ext_read_data                              ( cfg_ext_read_data ),
        .cfg_ext_read_data_valid                        ( cfg_ext_read_data_valid ),


        //-------------------------------------------------------------------------------------//
        // EP Only                                                                             //
        //-------------------------------------------------------------------------------------//

        // Interrupt Interface Signals
        .cfg_interrupt_int                              ( cfg_interrupt_int ),
        .cfg_interrupt_pending                          ( cfg_interrupt_pending ),
        .cfg_interrupt_sent                             ( cfg_interrupt_sent ),
        .cfg_interrupt_msi_enable                       ( cfg_interrupt_msi_enable ),
        .cfg_interrupt_msi_mmenable                     ( cfg_interrupt_msi_mmenable ),
        .cfg_interrupt_msi_mask_update                  ( cfg_interrupt_msi_mask_update ),
        .cfg_interrupt_msi_data                         ( cfg_interrupt_msi_data ),
        .cfg_interrupt_msi_select                       ( cfg_interrupt_msi_select ),
        .cfg_interrupt_msi_int                          ( cfg_interrupt_msi_int ),            // output [31:0] cfg_interrupt_msi_int;
        .cfg_interrupt_msi_pending_status               ( cfg_interrupt_msi_pending_status ),
        .cfg_interrupt_msi_sent                         ( cfg_interrupt_msi_sent ),           // input         cfg_interrupt_msi_sent;
        .cfg_interrupt_msi_fail                         ( cfg_interrupt_msi_fail ),
        .cfg_interrupt_msi_attr                         ( cfg_interrupt_msi_attr ),
        .cfg_interrupt_msi_tph_present                  ( cfg_interrupt_msi_tph_present ),
        .cfg_interrupt_msi_tph_type                     ( cfg_interrupt_msi_tph_type ),
        .cfg_interrupt_msi_tph_st_tag                   ( cfg_interrupt_msi_tph_st_tag ),
        .cfg_interrupt_msi_function_number              ( cfg_interrupt_msi_function_number ),


        .user_clk                                       ( user_clk ),    // input user_clk;
        .user_reset                                     ( user_reset ),  // input user_reset;
        .user_lnk_up                                    ( user_lnk_up )  // input user_lnk_up;

    );


`ifdef PCIE_GEN3X16_STREAM_MAX_256BIT
    //------------------------------------------------------------------------------------------------------------------//
    //       Shim x16 to x8 interface                                                                                   //
    //------------------------------------------------------------------------------------------------------------------//
    pif_x16_gasket pif_x16_gasket (

        //-------------------------------------------------------------------------------------//
        // Xilinx Gen3 x16 PCIe core facing AXI Interface                                      //
        //-------------------------------------------------------------------------------------//

	.core_clk					( user_clk2 ),     // input core_clk;

        .s_axis_rq_tvalid_axi500			( s_axis_rq_tvalid_axi500 ),
        .s_axis_rq_tdata_axi500				( s_axis_rq_tdata_axi500 ),
        .s_axis_rq_tkeep_axi500				( s_axis_rq_tkeep_axi500 ),
        .s_axis_rq_tlast_axi500				( s_axis_rq_tlast_axi500 ),
        .s_axis_rq_tuser_axi500				( s_axis_rq_tuser_axi500 ),
        .s_axis_rq_tready_axi500			( s_axis_rq_tready_axi500 ),

        .m_axis_rc_tvalid_axi500			( m_axis_rc_tvalid_axi500 ),
        .m_axis_rc_tdata_axi500				( m_axis_rc_tdata_axi500 ),
        .m_axis_rc_tkeep_axi500				( m_axis_rc_tkeep_axi500 ),
        .m_axis_rc_tlast_axi500				( m_axis_rc_tlast_axi500 ),
        .m_axis_rc_tuser_axi500				( m_axis_rc_tuser_axi500 ),
        .m_axis_rc_tready_axi500			( m_axis_rc_tready_axi500 ),

        .m_axis_cq_tvalid_axi500			( m_axis_cq_tvalid_axi500 ),
        .m_axis_cq_tdata_axi500				( m_axis_cq_tdata_axi500 ),
        .m_axis_cq_tkeep_axi500				( m_axis_cq_tkeep_axi500 ),
        .m_axis_cq_tlast_axi500				( m_axis_cq_tlast_axi500 ),
        .m_axis_cq_tuser_axi500				( m_axis_cq_tuser_axi500 ),
        .m_axis_cq_tready_axi500			( m_axis_cq_tready_axi500 ),

        .s_axis_cc_tvalid_axi500			( s_axis_cc_tvalid_axi500 ),
        .s_axis_cc_tdata_axi500				( s_axis_cc_tdata_axi500 ),
        .s_axis_cc_tkeep_axi500				( s_axis_cc_tkeep_axi500 ),
        .s_axis_cc_tlast_axi500				( s_axis_cc_tlast_axi500 ),
        .s_axis_cc_tuser_axi500				( s_axis_cc_tuser_axi500 ),
        .s_axis_cc_tready_axi500			( s_axis_cc_tready_axi500 ),

        //-------------------------------------------------------------------------------------//
        //  Framework's Gen3 x8 PCIe facing AXI Interface                                      //
        //-------------------------------------------------------------------------------------//

        .clk						( user_clk ),      // input clk;
        .reset						( user_reset ),    // input reset;

        .s_axis_rq_tvalid				( s_axis_rq_tvalid ),
        .s_axis_rq_tdata				( s_axis_rq_tdata ),
        .s_axis_rq_tkeep				( s_axis_rq_tkeep ),
        .s_axis_rq_tlast				( s_axis_rq_tlast ),
        .s_axis_rq_tuser				( s_axis_rq_tuser ),
        .s_axis_rq_tready				( s_axis_rq_tready ),

        .m_axis_rc_tvalid				( m_axis_rc_tvalid ),
        .m_axis_rc_tdata				( m_axis_rc_tdata ),
        .m_axis_rc_tkeep				( m_axis_rc_tkeep ),
        .m_axis_rc_tlast				( m_axis_rc_tlast ),
        .m_axis_rc_tuser				( m_axis_rc_tuser ),
        .m_axis_rc_tready				( m_axis_rc_tready ),

        .m_axis_cq_tvalid				( m_axis_cq_tvalid ),
        .m_axis_cq_tdata				( m_axis_cq_tdata ),
        .m_axis_cq_tkeep				( m_axis_cq_tkeep ),
        .m_axis_cq_tlast				( m_axis_cq_tlast ),
        .m_axis_cq_tuser				( m_axis_cq_tuser ),
        .m_axis_cq_tready				( m_axis_cq_tready ),

        .s_axis_cc_tvalid				( s_axis_cc_tvalid ),
        .s_axis_cc_tdata				( s_axis_cc_tdata ),
        .s_axis_cc_tkeep				( s_axis_cc_tkeep ),
        .s_axis_cc_tlast				( s_axis_cc_tlast ),
        .s_axis_cc_tuser				( s_axis_cc_tuser ),
        .s_axis_cc_tready				( s_axis_cc_tready )
    );
`endif //PCIE_GEN3X16_STREAM_MAX_256BIT

`ifdef PCIE_GEN3X16_USER_CLOCK

    //
    //
    //

    wire                                       mmcm0_CLKFBIN;
    wire                                       mmcm0_CLKFBOUT;
    wire                                       mmcm0_LOCKED;
    wire                                       mmcm0_CLKOUT0;  // 400 MHz = 250 * ( 4.8 / 1 ) / 3.0

    wire                                       user_lnk_up_x0;
    wire                                       user_reset_x0;

    (* ASYNC_REG = "TRUE" *) reg [1:0]         user_reset_xx;
    (* ASYNC_REG = "TRUE" *) reg [1:0]         user_lnk_up_xx;

    wire   [2:0]                               cfg_interrupt_msi_sent_r;
    wire   [2:0]                               cfg_interrupt_msi_int_r;

    //
    //
    //

    MMCME3_BASE #(
        .BANDWIDTH          ("OPTIMIZED"),
        .CLKFBOUT_MULT_F    (4.800),
        .CLKFBOUT_PHASE     (0.0),
        .CLKIN1_PERIOD      (4.000),
        .CLKOUT0_DIVIDE_F   (3.000),
        .CLKOUT0_DUTY_CYCLE (0.5),
        .CLKOUT1_DUTY_CYCLE (0.5),
        .CLKOUT2_DUTY_CYCLE (0.5),
        .CLKOUT3_DUTY_CYCLE (0.5),
        .CLKOUT4_DUTY_CYCLE (0.5),
        .CLKOUT5_DUTY_CYCLE (0.5),
        .CLKOUT6_DUTY_CYCLE (0.5),
        .CLKOUT0_PHASE      (0.0),
        .CLKOUT1_PHASE      (0.0),
        .CLKOUT2_PHASE      (0.0),
        .CLKOUT3_PHASE      (0.0),
        .CLKOUT4_PHASE      (0.0),
        .CLKOUT5_PHASE      (0.0),
        .CLKOUT6_PHASE      (0.0),
        .CLKOUT1_DIVIDE     (1),
        .CLKOUT2_DIVIDE     (1),
        .CLKOUT3_DIVIDE     (1),
        .CLKOUT4_DIVIDE     (1),
        .CLKOUT5_DIVIDE     (1),
        .CLKOUT6_DIVIDE     (1),
        .CLKOUT4_CASCADE    ("FALSE"),
        .DIVCLK_DIVIDE      (1),
        .IS_CLKFBIN_INVERTED(1'b0),
        .IS_CLKIN1_INVERTED (1'b0),
        .IS_PWRDWN_INVERTED (1'b0),
        .IS_RST_INVERTED    (1'b0),
        .REF_JITTER1        (0.0),
        .STARTUP_WAIT       ("FALSE")
    ) MMCME3_BASE_inst(
        .CLKOUT0            (mmcm0_CLKOUT0),
        .CLKOUT0B           (),
        .CLKOUT1            (),
        .CLKOUT1B           (),
        .CLKOUT2            (),
        .CLKOUT2B           (),
        .CLKOUT3            (),
        .CLKOUT3B           (),
        .CLKOUT4            (),
        .CLKOUT5            (),
        .CLKOUT6            (),
        .CLKFBOUT           (mmcm0_CLKFBOUT),
        .CLKFBOUTB          (),
        .LOCKED             (mmcm0_LOCKED),
        .CLKIN1             (user_clk_var),
        .PWRDWN             (1'b0),
        .RST                (user_reset_var),
        .CLKFBIN            (mmcm0_CLKFBIN)
    );

    BUFG BUFG_mmcm0_CLKFB (
        .O (mmcm0_CLKFBIN),
        .I (mmcm0_CLKFBOUT)
    );

    BUFG BUFG_mmcm0_CLKOUT0 (
        .O (user_clk),
        .I (mmcm0_CLKOUT0)
    );

    //
    //
    //

    // Sync user_reset

    assign user_reset_x0   = user_reset_var | ~mmcm0_LOCKED;  // user_reset in
    assign user_reset      = user_reset_xx[1];                // user_reset out

    always @(posedge user_clk or posedge user_reset_x0) begin
        if ( user_reset_x0 )
            user_reset_xx[1:0]  <= 2'b11;
        else
            user_reset_xx[1:0]  <= {user_reset_xx[0], user_reset_x0};
    end

    // Sync user_lnk_up

    assign user_lnk_up_x0 = user_lnk_up_var;   // user_lnk_up in
    assign user_lnk_up    = user_lnk_up_xx[1]; // user_lnk_up out

    always @(posedge user_clk or posedge user_reset) begin
        if ( user_reset )
            user_lnk_up_xx[1:0] <= 2'b00;
        else
            user_lnk_up_xx[1:0] <= {user_lnk_up_xx[0], user_lnk_up_x0};
    end

    // Sync cfg_interrupt_msi_sent

    assign cfg_interrupt_msi_sent          = cfg_interrupt_msi_sent_r[0];

    fsync #(
        .RATIO      (2),
        .ISOLATE    (0)
    ) fsync_msi_sent (
        .clk        (user_clk_var),                    // input          clk;
        .flg        (cfg_interrupt_msi_sent_var),      // input          flg;
        .oclk       (user_clk),                        // input          oclk;
        .oflg       (cfg_interrupt_msi_sent_r)         // output [SB:0]  oflg;
    );

    // Sync cfg_interrupt_msi_int

    assign cfg_interrupt_msi_int_var[31:0] = {29'b0, cfg_interrupt_msi_int_r[2:0]};

    fsync #(
        .RATIO      (2),
        .ISOLATE    (0)
    ) fsync_msi_int (
        .clk        (user_clk),                        // input          clk;
        .flg        (cfg_interrupt_msi_int[0]),        // input          flg;
        .oclk       (user_clk_var),                    // input          oclk;
        .oflg       (cfg_interrupt_msi_int_r)          // output [SB:0]  oflg;
    );

`else

    assign user_clk     = user_clk_var;
    assign user_reset   = user_reset_var;
    assign user_lnk_up  = user_lnk_up_var;

    assign cfg_interrupt_msi_sent    = cfg_interrupt_msi_sent_var;
    assign cfg_interrupt_msi_int_var = cfg_interrupt_msi_int;

`endif


endmodule  // xilinx_pcie_3_0_7vx
