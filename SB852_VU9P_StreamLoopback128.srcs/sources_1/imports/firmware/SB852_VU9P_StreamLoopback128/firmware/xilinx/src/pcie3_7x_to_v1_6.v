// pcie3_7x_to_v1_6.v
// Copyright 2014 Pico Computing, Inc.

`timescale 1ps / 1ps


module  pcie3_7x_to_v1_6 #(
    parameter C_DATA_WIDTH = 128,            // RX/TX interface data width
    parameter KEEP_WIDTH                                 = C_DATA_WIDTH / 32,
    parameter STRB_WIDTH                                 = C_DATA_WIDTH / 8,
    parameter TCQ = 1
) (
    //----------------------------------------------------------------------------------------------------------------//
    //  AXI Interface                                                                                                 //
    //----------------------------------------------------------------------------------------------------------------//
 
    output wire                                     s_axis_rq_tlast,
    output wire             [C_DATA_WIDTH-1:0]      s_axis_rq_tdata,
    output wire                         [61:0]      s_axis_rq_tuser,
    output wire               [KEEP_WIDTH-1:0]      s_axis_rq_tkeep,
    input  wire                          [3:0]      s_axis_rq_tready,
    output wire                                     s_axis_rq_tvalid,
                                                    
    input  wire             [C_DATA_WIDTH-1:0]      m_axis_rc_tdata,
    input  wire                         [74:0]      m_axis_rc_tuser,
    input  wire                                     m_axis_rc_tlast,
    input  wire               [KEEP_WIDTH-1:0]      m_axis_rc_tkeep,
    input  wire                                     m_axis_rc_tvalid,
`ifdef XILINX_ULTRASCALE
    output wire                          [0:0]      m_axis_rc_tready,
`else
    output wire                         [21:0]      m_axis_rc_tready,
`endif
                                                    
    input  wire             [C_DATA_WIDTH-1:0]      m_axis_cq_tdata,
    input  wire                         [84:0]      m_axis_cq_tuser,
    input  wire                                     m_axis_cq_tlast,
    input  wire               [KEEP_WIDTH-1:0]      m_axis_cq_tkeep,
    input  wire                                     m_axis_cq_tvalid,
`ifdef XILINX_ULTRASCALE
    output wire                          [0:0]      m_axis_cq_tready,
`else
    output wire                         [21:0]      m_axis_cq_tready,
`endif
                                                    
    output wire             [C_DATA_WIDTH-1:0]      s_axis_cc_tdata,
    output wire                         [32:0]      s_axis_cc_tuser,
    output wire                                     s_axis_cc_tlast,
    output wire               [KEEP_WIDTH-1:0]      s_axis_cc_tkeep,
    output wire                                     s_axis_cc_tvalid,
    input  wire                          [3:0]      s_axis_cc_tready,

    output wire                                     s_axis_tx_tready,
    input  wire [C_DATA_WIDTH-1:0]                  s_axis_tx_tdata,
    input  wire [STRB_WIDTH-1:0]                    s_axis_tx_tstrb,
    input  wire [3:0]                               s_axis_tx_tuser,
    input  wire                                     s_axis_tx_tlast,
    input  wire                                     s_axis_tx_tvalid,

    // Rx
    output wire [C_DATA_WIDTH-1:0]                  m_axis_rx_tdata,
    output wire [STRB_WIDTH-1:0]                    m_axis_rx_tstrb,
    output wire                                     m_axis_rx_tlast,
    output wire                                     m_axis_rx_tvalid,
    input  wire                                     m_axis_rx_tready,
    output wire [21:0]                              m_axis_rx_tuser,

    input  wire                                     cfg_interrupt,
    output wire                                     cfg_interrupt_rdy,

    //----------------------------------------------------------------------------------------------------------------//
    //  Configuration (CFG) Interface                                                                                 //
    //----------------------------------------------------------------------------------------------------------------//

    input                            [1:0]     pcie_tfc_nph_av,
    input                            [1:0]     pcie_tfc_npd_av,
    input                            [3:0]     pcie_rq_seq_num,
    input                                      pcie_rq_seq_num_vld,
    input                            [5:0]     pcie_rq_tag,
    input                                      pcie_rq_tag_vld,

    output                                     pcie_cq_np_req,
    input                            [5:0]     pcie_cq_np_req_count,

    input                                      cfg_phy_link_down,
    input                            [2:0]     cfg_negotiated_width,
    input                            [1:0]     cfg_current_speed,
    input                            [1:0]     cfg_max_payload,
    input                            [2:0]     cfg_max_read_req,
    input                           [11:0]     cfg_vf_status,
    input                           [17:0]     cfg_vf_power_state,
`ifdef XILINX_ULTRASCALE
    input                           [15:0]     cfg_function_status,
    input                           [11:0]     cfg_function_power_state,
`else
    input                            [7:0]     cfg_function_status,
    input                            [5:0]     cfg_function_power_state,
`endif
    input                            [1:0]     cfg_link_power_state,

    // Error Reporting Interface
    input                                      cfg_err_cor_out,
    input                                      cfg_err_nonfatal_out,
    input                                      cfg_err_fatal_out,

    input                            [5:0]     cfg_ltssm_state,
`ifdef XILINX_ULTRASCALE
    input                            [3:0]     cfg_rcb_status,
`else
    input                            [1:0]     cfg_rcb_status,
`endif
    input                            [1:0]     cfg_obff_enable,
    input                                      cfg_pl_status_change,

`ifdef XILINX_ULTRASCALE
    input                            [3:0]     cfg_tph_requester_enable,
    input                           [11:0]     cfg_tph_st_mode,
`else
    input                            [1:0]     cfg_tph_requester_enable,
    input                            [5:0]     cfg_tph_st_mode,
`endif
    input                            [5:0]     cfg_vf_tph_requester_enable,
    input                           [17:0]     cfg_vf_tph_st_mode,
    // Management Interface
    output wire                     [18:0]     cfg_mgmt_addr,
    output wire                                cfg_mgmt_write,
    output wire                     [31:0]     cfg_mgmt_write_data,
    output wire                      [3:0]     cfg_mgmt_byte_enable,
    output wire                                cfg_mgmt_read,
    input                           [31:0]     cfg_mgmt_read_data,
    input                                      cfg_mgmt_read_write_done,
    output wire                                cfg_mgmt_type1_cfg_reg_access,
    input                                      cfg_msg_received,
    input                            [7:0]     cfg_msg_received_data,
    input                            [4:0]     cfg_msg_received_type,
    output                                     cfg_msg_transmit,
    output                           [2:0]     cfg_msg_transmit_type,
    output                          [31:0]     cfg_msg_transmit_data,
    input                                      cfg_msg_transmit_done,
    input                            [7:0]     cfg_fc_ph,
    input                           [11:0]     cfg_fc_pd,
    input                            [7:0]     cfg_fc_nph,
    input                           [11:0]     cfg_fc_npd,
    input                            [7:0]     cfg_fc_cplh,
    input                           [11:0]     cfg_fc_cpld,
    output                           [2:0]     cfg_fc_sel,
    output  wire                     [2:0]     cfg_per_func_status_control,
    output wire                                cfg_config_space_enable,
    output wire                      [7:0]     cfg_ds_port_number,
    output wire                      [7:0]     cfg_ds_bus_number,
    output wire                      [4:0]     cfg_ds_device_number,
    output wire                      [2:0]     cfg_ds_function_number,
    output wire                                cfg_err_cor_in,
    output wire                                cfg_err_uncor_in,
`ifdef XILINX_ULTRASCALE
    input                            [3:0]     cfg_flr_in_process,
`else
    input                            [1:0]     cfg_flr_in_process,
`endif
    output wire                      [1:0]     cfg_flr_done,
    output wire                                cfg_hot_reset_in,
    input                                      cfg_hot_reset_out,
    output wire                                cfg_link_training_enable,
`ifdef XILINX_ULTRASCALE
    output  wire                     [3:0]     cfg_per_function_number,
`else
    output  wire                     [2:0]     cfg_per_function_number,
`endif
    output  wire                               cfg_per_function_output_request,
    output                                     cfg_power_state_change_ack,
    input                                      cfg_power_state_change_interrupt,
    output wire                                cfg_req_pm_transition_l23_ready,
    input                            [5:0]     cfg_vf_flr_in_process,
    output wire                      [5:0]     cfg_vf_flr_done,
    output wire                     [31:0]     cfg_ext_read_data,
    output wire                                cfg_ext_read_data_valid,

    //----------------------------------------------------------------------------------------------------------------//
    // EP Only                                                                                                        //
    //----------------------------------------------------------------------------------------------------------------//

    // Interrupt Interface Signals
    output                           [3:0]     cfg_interrupt_int,
    output wire                      [1:0]     cfg_interrupt_pending,
    input                                      cfg_interrupt_sent,
`ifdef XILINX_ULTRASCALE
    input                            [3:0]     cfg_interrupt_msi_enable,
    input                           [11:0]     cfg_interrupt_msi_mmenable,
`else
    input                            [1:0]     cfg_interrupt_msi_enable,
    input                            [5:0]     cfg_interrupt_msi_mmenable,
`endif
    input                                      cfg_interrupt_msi_mask_update,
    input                           [31:0]     cfg_interrupt_msi_data,
    output wire                      [3:0]     cfg_interrupt_msi_select,
    output                          [31:0]     cfg_interrupt_msi_int,
    output wire                     [63:0]     cfg_interrupt_msi_pending_status,
    input                                      cfg_interrupt_msi_sent,
    input                                      cfg_interrupt_msi_fail,
    output wire                      [2:0]     cfg_interrupt_msi_attr,
    output wire                                cfg_interrupt_msi_tph_present,
    output wire                      [1:0]     cfg_interrupt_msi_tph_type,
    output wire                      [8:0]     cfg_interrupt_msi_tph_st_tag,
    output wire                      [2:0]     cfg_interrupt_msi_function_number,


    input                                      user_clk,
    input                                      user_reset,
    input                                      user_lnk_up
);

    assign cfg_interrupt_msi_int    = {31'h0, cfg_interrupt};
    assign cfg_interrupt_rdy        = cfg_interrupt_msi_sent;
    assign cfg_interrupt_msi_function_number = 0;

    assign pcie_cq_np_req           = 1;

    wire clk                        = user_clk;
    wire rst                        = user_reset;

    integer i;

    localparam MEM_RD32_FMT_TYPE    = 7'b00_00000;
    localparam MEM_RD64_FMT_TYPE    = 7'b01_00000;
    localparam MEM_WR32_FMT_TYPE    = 7'b10_00000;
    localparam MEM_WR64_FMT_TYPE    = 7'b11_00000;
    localparam CPLD_FMT_TYPE        = 7'b10_01010;
    localparam CPL_FMT_TYPE         = 7'b00_01010;

    localparam ARB_GRANT_RC	= 1'h0;
    localparam ARB_GRANT_CQ	= 1'h1;

    function [95:0] tlp_hdr_to_cc_desc;
        input [95:0] hdr;
        begin
            tlp_hdr_to_cc_desc = {
                1'b0,                           // [95] Force ECRC
                hdr[13:12],                     // [94:92] Attributes
                hdr[20+:3],                     // [91:89] Transaction Class
                1'b0,                           // [88] Completer ID Enable
                //hdr[48+:16],                    // [87:72] Completer ID
                16'h0,                          // [87:72] Completer ID. let the integrated block fill this field for us
                hdr[72+:8],                     // [71:64] Tag
                hdr[80+:16],                    // [63:48] Requester ID
                1'b0,                           // [47] Reserved
                1'b0,                           // [46] Poisoned Completion
                hdr[45+:3],                     // [45:43] Completion Status
                {1'b0, hdr[0+:10]},             // [42:32] Dword Count
                2'b0,                           // [31:30] Reserved
                1'b0,                           // [29] Locked Read Completion
                {1'b0, hdr[32+:12]},            // [28:16] Byte Count
                6'b0,                           // [15:10] Reserved
                2'b0,                           // [9:8] Address Type
                1'b0,                           // [7] Reserved
                hdr[64+:7]                      // [6:0] Lower Address
            };
        end
    endfunction

    function [127:0] tlp_hdr_to_rq_desc;
        input [127:0] hdr;
        input wr;
        begin
            tlp_hdr_to_rq_desc = {
                1'b0,                           // [127] Force ECRC
                3'b0,                           // [126:124] Attributes
                3'b0,                           // [123:121] Transaction Class
                1'b0,                           // [120] Requester ID Enable
                16'h0,                          // [119:104] Completer ID (N/A)
                hdr[40+:8],                     // [103:96] Tag
                //hdr[48+:16],                    // [95:80] Requester ID
                16'h0,                          // [95:80] Requester ID. let the integrated block fill this field for us
                1'b0,                           // [79] Poisoned Request
                wr ? 4'b0001 : 4'b0000,         // [78:75] Request Type
                {1'b0, hdr[0+:10]},             // [74:64] Dword Count
                {hdr[64+:32],hdr[98+:30]},      // [63:2] Address
                2'b0                            // [1:0] Address Type
            };
        end
    endfunction

    function [95:0] rc_desc_to_tlp_hdr;
        input [95:0] desc;
        begin
            rc_desc_to_tlp_hdr = {
                desc[48+:16],                   // [95:80] Requester ID
                desc[64+:8],                    // [79:72] Tag
                {1'b0},                         // [71] Reserved
                desc[6:0],                      // [70:64] Lower Address
                desc[72+:16],                   // [63:48] Completer ID
                desc[45:43],                    // [47:45] Completion Status
                1'b0,                           // [44] B
                desc[27:16],                    // [43:32] Byte Count
                1'b0,                           // [31] Reserved
                CPLD_FMT_TYPE,                  // [30:24] Format Type
                1'b0,                           // [23] Reserved
                desc[91:89],                    // [22:20] Transaction Class
                4'b0,                           // [19:16] Reserved
                1'b0,                           // [15] TD
                desc[46],                       // [14] EP
                desc[93:92],                    // [13:12] Attributes
                2'b0,                           // [11:10] Reserved
                desc[41:32]                     // [9:0] Dword Count
            };
        end
    endfunction

    function [127:0] cq_desc_to_tlp_hdr;
        input [127:0] desc;
        input [7:0] be;
        begin
            cq_desc_to_tlp_hdr = {
                desc[63:32],                    // [95:64] Upper Address  (the order of address is wrong here according to pcie spec, but we are using this particular order in the PIO)
                {desc[31:2], 2'b00},            // [127:96] Lower Address 
                desc[80+:16],                   // [63:48] Requester ID
                desc[103:96],                   // [47:40] Tag
                be[7:4],                        // [39:36] Last Byte Enables
                be[3:0],                        // [35:32] First Byte Enables
                1'b0,                           // [31] Reserved
                desc[75] ? MEM_WR64_FMT_TYPE :  // We shouldn't receive any request types other than memory read and write
                           MEM_RD64_FMT_TYPE,   // [30:24] Format Type
                1'b0,                           // [23] Reserved
                desc[123:121],                  // [22:20] Traffic Class (TC)
                4'b0,                           // [19:16] Reserved
                1'b0,                           // [15] TLP digest present (TD)
                1'b0,                           // [14] Poisoned (EP)
                desc[125:124],                  // [13:12] Attributes
                2'b0,                           // [11:10] Reserved
                desc[73:64]                     // [9:0] Dword Count
            };
        end
    endfunction

    //////////////////////////////////
    // TX SPLITTING AND TRANSLATION //
    //////////////////////////////////
    // s_axis_rq_tuser:
    // [3:0]:   first_be
    // [7:4]:   last_be
    // [10:8]:  addr_offset
    // [11]:    discontinue
    // [12]:    tph_present
    // [14:13]: tph_type
    // [15]:    tph_indirect_tag_en
    // [23:16]: tph_st_tag
    // [27:24]: seq_num
    // [59:28]: parity
    //
    // s_axis_cc_tuser:
    // [0]:     discontinue
    // [32:1]:  parity

    // we need to infer sop from tlast
    reg tx_tfirst = 1;
    always @ (posedge clk) begin
        if (rst) begin
            tx_tfirst <= 1;
        end else begin
            if (s_axis_tx_tvalid && s_axis_tx_tready) begin
                tx_tfirst <= s_axis_tx_tlast;
            end
        end
    end

    reg [C_DATA_WIDTH-1:0] tx_tdata_q, tx_tdata_qq, tx_tdata_q3;
    reg [KEEP_WIDTH-1:0] tx_tkeep_q, tx_tkeep_qq, tx_tkeep_q3;
    reg tx_tlast_q, tx_tlast_qq, tx_tlast_q3;
    reg tx_valid_q = 0, tx_valid_qq = 0, tx_valid_q3 = 0;
    reg tx_is_cc_qq, tx_is_cc_q3;
    reg [7:0] tx_tuser_qq, tx_tuser_q3;
    reg tx_sof_q;
    reg tx_is_wr, tx_is_cpld;
    wire [C_DATA_WIDTH-1:0] c_tlp_hdr_to_rq_desc;
    
    generate if (C_DATA_WIDTH == 256) begin : g_gen3x8_rq
       assign c_tlp_hdr_to_rq_desc = {tx_tdata_q[C_DATA_WIDTH-1:128], tlp_hdr_to_rq_desc(tx_tdata_q[127:0], tx_is_wr)};
    end else begin : g_gen2x8_rq
       assign c_tlp_hdr_to_rq_desc = tlp_hdr_to_rq_desc(tx_tdata_q[127:0], tx_is_wr);
    end endgenerate

    always @ (posedge clk) begin
        if (rst) begin
            tx_valid_q <= 0;
            tx_valid_qq <= 0;
            tx_valid_q3 <= 0;
            tx_sof_q <= 0;
        end else begin
            tx_tdata_q <= s_axis_tx_tdata;
            tx_valid_q <= s_axis_tx_tvalid & s_axis_tx_tready;
            tx_sof_q <= tx_tfirst & s_axis_tx_tvalid & s_axis_tx_tready;
            tx_is_wr <= s_axis_tx_tdata[30];
            tx_is_cpld <= s_axis_tx_tdata[28:24] == 5'b01010;
            tx_tlast_q <= s_axis_tx_tlast;
            for (i=0; i<KEEP_WIDTH;i=i+1) begin
                tx_tkeep_q[i] <= s_axis_tx_tstrb[i*4];
            end
            
            tx_tdata_qq <= tx_sof_q ? tx_is_cpld ? {tx_tdata_q[C_DATA_WIDTH-1:96], tlp_hdr_to_cc_desc(tx_tdata_q[95:0])} : c_tlp_hdr_to_rq_desc : tx_tdata_q;
            tx_is_cc_qq <= tx_sof_q ? tx_is_cpld : tx_is_cc_qq;
            tx_tuser_qq <= (tx_sof_q && !tx_is_cpld) ? tx_tdata_q[32+:8] : 0;
            tx_valid_qq <= tx_valid_q;
            tx_tlast_qq <= tx_tlast_q;
            tx_tkeep_qq <= tx_tkeep_q;

            tx_tdata_q3 <= tx_tdata_qq;
            tx_is_cc_q3 <= tx_is_cc_qq;
            tx_tuser_q3 <= tx_tuser_qq;
            tx_valid_q3 <= tx_valid_qq;
            tx_tlast_q3 <= tx_tlast_qq;
            tx_tkeep_q3 <= tx_tkeep_qq;
        end
    end

    wire tx_fifo_rden;
    wire tx_fifo_empty, tx_fifo_almostfull;
    wire tx_is_cc_q4;
    wire [7:0] tx_tuser_q4;
    wire tx_tlast_q4;
    wire [C_DATA_WIDTH-1:0] tx_tdata_q4;
    wire [KEEP_WIDTH-1:0] tx_tkeep_q4;

    wire tx_fifo_full;
    wire [9:0] _tx_fifo_nc0_, _tx_fifo_nc1_;
    generic_fifo #(
       .WIDTH(C_DATA_WIDTH+KEEP_WIDTH+8+1+1),
       .DEPTH(512),
       .RAM_STYLE("block"),
       .AFULLCNT(256),
       .SYNCHRONOUS(1)
    ) tx_fifo (
       // Outputs
       .afull(tx_fifo_almostfull),
       .full(tx_fifo_full),
       .cnt(_tx_fifo_nc0_),
       .dout({tx_is_cc_q4,tx_tuser_q4,tx_tkeep_q4,tx_tlast_q4,tx_tdata_q4}),
       .empty(tx_fifo_empty),
       .rcnt(_tx_fifo_nc1_),
       // Inputs
       .clk(clk),
       .reset(rst),
       .push(tx_valid_q3),
       .din({tx_is_cc_q3,tx_tuser_q3,tx_tkeep_q3,tx_tlast_q3,tx_tdata_q3}), 
       .oclk(clk),
       .pop(tx_fifo_rden)
    );

    /* DEBUG assert logic */
    `ifdef DEBUG_ENABLE
    `ifdef ALTERA_FPGA
    (* noprune = 1 *)
    (* syn_preserve = 1 *)
    `else
    (* MARK_DEBUG *)
    `endif
    reg tx_fifo_overflow;

    always @ (posedge clk) begin
       tx_fifo_overflow <= tx_valid_q3 & tx_fifo_full;
    end
    `endif

    reg tx_fifo_ready = 0;
    reg tx_tready = 0;
    assign s_axis_tx_tready = tx_tready;
    always @ (posedge clk) begin
        if (rst) begin
            tx_fifo_ready <= 0;
        end else begin
            tx_fifo_ready <= ~tx_fifo_almostfull;
            // make sure we don't deassert ready signal in the middle of a packet
            if (s_axis_tx_tready) begin
                if (s_axis_tx_tvalid && s_axis_tx_tlast) tx_tready <= tx_fifo_ready;
            end else begin
                tx_tready <= tx_fifo_ready;
            end
        end
    end

    assign s_axis_rq_tlast      = tx_tlast_q4;
    assign s_axis_rq_tdata      = tx_tdata_q4;
    assign s_axis_rq_tuser      = {54'h0, tx_tuser_q4};
    assign s_axis_rq_tkeep      = tx_tkeep_q4;
    assign s_axis_rq_tvalid     = ~tx_is_cc_q4 & ~tx_fifo_empty;

    assign s_axis_cc_tlast      = tx_tlast_q4;
    assign s_axis_cc_tdata      = tx_tdata_q4;
    assign s_axis_cc_tuser      = 0;
    assign s_axis_cc_tkeep      = tx_tkeep_q4;
    assign s_axis_cc_tvalid     = tx_is_cc_q4 & ~tx_fifo_empty;

    assign tx_fifo_rden         = (tx_is_cc_q4 ? s_axis_cc_tready[0] : s_axis_rq_tready[0]) && !tx_fifo_empty;

    ////////////////////////////////
    // RX MERGING AND TRANSLATION //
    ////////////////////////////////
    // m_axis_cq_tuser:
    // [3:0]:   first_be
    // [7:4]:   last_be
    // [39:8]:  byte_en
    // [40]:    sop
    // [41]:    discontinue
    // [42]:    tph_present
    // [44:43]: tph_type
    // [52:45]: tph_st_tag
    // [84:53]: parity
    //
    // m_axis_rc_tuser:
    // [31:0]:  byte_en
    // [32]:    is_sof_0
    // [33]:    is_sof_1
    // [37:34]: is_eof_0[3:0]
    // [41:38]: is_eof_1[3:0]
    // [42]:    discontinue
    // [74:43]: parity

    reg [C_DATA_WIDTH-1:0] rx_tdata_q;
    reg [C_DATA_WIDTH-1:0] rx_tdata_qq, rx_tdata_q3;
    reg [KEEP_WIDTH-1:0] rx_tkeep_q;
    reg [KEEP_WIDTH-1:0] rx_tkeep_qq, rx_tkeep_q3;
    reg [7:0] rx_tuser;
    reg [21:0] rx_tuser_q3 = 0;
    reg rx_is_rc, rx_sof_q = 0;
    reg rx_sof_qq = 0;
    reg [7:0] rx_bar_q, rx_bar_qq;
    reg rx_tlast_q = 0;
    reg rx_tlast_qq = 0, rx_tlast_q3 = 0;
    reg rx_valid_q = 0;
    reg rx_valid_qq = 0, rx_valid_q3 = 0;
    wire [C_DATA_WIDTH-1:0] c_cq_desc_to_tlp_hdr;
    wire [C_DATA_WIDTH-1:0] cq_tdata;
    wire [KEEP_WIDTH-1:0] cq_tkeep;
    wire [7:0] cq_tuser_be;
    wire cq_tuser_sof;
    wire cq_tlast;
    reg  cq_tvalid;
    wire [C_DATA_WIDTH-1:0] rc_tdata;
    wire [KEEP_WIDTH-1:0] rc_tkeep;
    wire rc_tuser_sof;
    wire rc_tlast;
    reg  rc_tvalid;
    reg [0:0] rx_arb_state;
    wire rx_stall;

    generate if (C_DATA_WIDTH == 256) begin : g_gen3x8_cq
       assign c_cq_desc_to_tlp_hdr = {rx_tdata_q[C_DATA_WIDTH-1:128], cq_desc_to_tlp_hdr(rx_tdata_q[127:0], rx_tuser[7:0])};
    end else begin : g_gen2x8_cq
       assign c_cq_desc_to_tlp_hdr = cq_desc_to_tlp_hdr(rx_tdata_q[127:0], rx_tuser[7:0]);
    end endgenerate

    wire cq_fifo_full, cq_fifo_push, cq_fifo_almostfull;
    wire [5:0] _cq_fifo_nc0_, _cq_fifo_nc1_;
    generic_fifo #(
       .WIDTH(1+1+8+KEEP_WIDTH+C_DATA_WIDTH),
       .DEPTH(32),
       .AFULLCNT(24),
       .SYNCHRONOUS(1)
    ) cq_fifo (
       // Outputs
       .afull(cq_fifo_almostfull),
       .full(cq_fifo_full),
       .cnt(_cq_fifo_nc0_),
       .dout({cq_tlast, cq_tuser_sof, cq_tuser_be, cq_tkeep, cq_tdata}),
       .empty(cq_fifo_empty),
       .rcnt(_cq_fifo_nc1_),
       // Inputs
       .clk(clk),
       .reset(rst),
       .push(cq_fifo_push),
       .din({m_axis_cq_tlast, m_axis_cq_tuser[40], m_axis_cq_tuser[7:0], m_axis_cq_tkeep, m_axis_cq_tdata}), 
       .oclk(clk),
       .pop(cq_tvalid)
    );
`ifdef XILINX_ULTRASCALE
    assign m_axis_cq_tready = !cq_fifo_almostfull;
`else
    assign m_axis_cq_tready = {22{!cq_fifo_almostfull}};
`endif
    assign cq_fifo_push = m_axis_cq_tvalid & m_axis_cq_tready[0];

    /* DEBUG assert logic */
    `ifdef DEBUG_ENABLE
    `ifdef ALTERA_FPGA
    (* noprune = 1 *)
    (* syn_preserve = 1 *)
    `else
    (* MARK_DEBUG *)
    `endif
    reg cq_fifo_overflow;

    always @ (posedge clk) begin
       cq_fifo_overflow <= cq_fifo_push & cq_fifo_full;
    end
    `endif

    wire rc_fifo_full, rc_fifo_push, rc_fifo_almostfull;
    wire [5:0] _rc_fifo_nc0_, _rc_fifo_nc1_;
    generic_fifo #(
       .WIDTH(1+1+KEEP_WIDTH+C_DATA_WIDTH),
       .DEPTH(32),
       .AFULLCNT(24),
       .SYNCHRONOUS(1)
    ) rc_fifo (
       // Outputs
       .afull(rc_fifo_almostfull),
       .full(rc_fifo_full),
       .cnt(_rc_fifo_nc0_),
       .dout({rc_tlast, rc_tuser_sof, rc_tkeep, rc_tdata}),
       .empty(rc_fifo_empty),
       .rcnt(_rc_fifo_nc1_),
       // Inputs
       .clk(clk),
       .reset(rst),
       .push(rc_fifo_push),
       .din({m_axis_rc_tlast, m_axis_rc_tuser[32], m_axis_rc_tkeep, m_axis_rc_tdata}), 
       .oclk(clk),
       .pop(rc_tvalid)
    );
`ifdef XILINX_ULTRASCALE
    assign m_axis_rc_tready = !rc_fifo_almostfull;
`else
    assign m_axis_rc_tready = {22{!rc_fifo_almostfull}};
`endif
    assign rc_fifo_push = m_axis_rc_tvalid & m_axis_rc_tready[0];

    /* DEBUG assert logic */
    `ifdef DEBUG_ENABLE
    `ifdef ALTERA_FPGA
    (* noprune = 1 *)
    (* syn_preserve = 1 *)
    `else
    (* MARK_DEBUG *)
    `endif
    reg rc_fifo_overflow;

    always @ (posedge clk) begin
       rc_fifo_overflow <= rc_fifo_push & rc_fifo_full;
    end
    `endif

    always @ (*) begin
       cq_tvalid = 1'b0;
       rc_tvalid = 1'b0;
       case(rx_arb_state)
	  ARB_GRANT_CQ: begin
	     cq_tvalid = !cq_fifo_empty & (!cq_tuser_sof | rc_fifo_empty) & !rx_stall;
	     rc_tvalid = (cq_fifo_empty | cq_tuser_sof) & !rc_fifo_empty & !rx_stall;
	  end
          default: begin
	     cq_tvalid = rc_fifo_empty & !cq_fifo_empty & !rx_stall;
	     rc_tvalid = !rc_fifo_empty & !rx_stall;
	  end
       endcase
    end

    always @ (posedge clk) begin
        if (rst) begin
	    rx_arb_state <= ARB_GRANT_RC;
            rx_valid_q <= 0;
            rx_valid_qq <= 0;
            rx_valid_q3 <= 0;
            rx_is_rc <= 0;
            rx_sof_q <= 0;
            rx_sof_qq <= 0;
            rx_tuser_q3 <= 0;
        end else begin
	    case (rx_arb_state)
	       ARB_GRANT_CQ: rx_arb_state <= (!cq_fifo_empty & (!cq_tuser_sof | rc_fifo_empty)) ? ARB_GRANT_CQ : ARB_GRANT_RC;
	       default: rx_arb_state <= (!cq_fifo_empty & rc_fifo_empty) ? ARB_GRANT_CQ : ARB_GRANT_RC;
	    endcase
	    if (!rx_stall) begin
               rx_tdata_q <= rc_tvalid ? rc_tdata : cq_tdata;
               rx_valid_q <= rc_tvalid | cq_tvalid;
               rx_is_rc <= rc_tvalid;
               rx_sof_q <= rc_tvalid ? rc_tuser_sof : cq_tuser_sof;
               rx_tuser <= cq_tuser_be;
               rx_tlast_q <= rc_tvalid ? rc_tlast : cq_tlast;
               rx_tkeep_q <= rc_tvalid ? rc_tkeep : cq_tkeep;

               for (i=0;i<=6;i=i+1) begin
                   rx_bar_q[i] <= cq_tdata[114:112] == i[2:0];
               end

               rx_tdata_qq <= !rx_sof_q ? rx_tdata_q : 
	                                  (rx_is_rc ? {rx_tdata_q[C_DATA_WIDTH-1:96], rc_desc_to_tlp_hdr(rx_tdata_q[95:0])} : 
                                                      c_cq_desc_to_tlp_hdr);
               rx_sof_qq <= rx_sof_q;
               rx_bar_qq <= (rx_sof_q && !rx_is_rc) ? rx_bar_q : rx_bar_qq;
               rx_valid_qq <= rx_valid_q;
               rx_tlast_qq <= rx_tlast_q;
               rx_tkeep_qq <= rx_tkeep_q;

               rx_tdata_q3 <= rx_tdata_qq;
               rx_tuser_q3 <= {7'b0, rx_sof_qq, 4'b0, rx_bar_qq, 2'b0};
               rx_valid_q3 <= rx_valid_qq;
               rx_tlast_q3 <= rx_tlast_qq;
               rx_tkeep_q3 <= rx_tkeep_qq;
	    end
        end
    end

    assign rx_stall = !m_axis_rx_tready & m_axis_rx_tvalid;
    assign m_axis_rx_tdata      = rx_tdata_q3;
    genvar tk;
    generate for (tk=0; tk<KEEP_WIDTH ; tk=tk+1) begin : g_rx_tkeep
       assign m_axis_rx_tstrb[tk*4 +: 4] = {4{rx_tkeep_q3[tk]}};
    end endgenerate
    assign m_axis_rx_tlast      = rx_tlast_q3;
    assign m_axis_rx_tvalid     = rx_valid_q3;
    assign m_axis_rx_tuser      = rx_tuser_q3;
 
    /////////////////////////////
    // CFG FROM EXAMPLE DESIGN //
    /////////////////////////////

  //----------------------------------------------------------------------------------------------------------------//
  // PCIe Block EP Tieoffs - Example PIO doesn't support the following outputs                                      //
  //----------------------------------------------------------------------------------------------------------------//
  assign cfg_mgmt_addr                       = 19'h0;                // Zero out CFG MGMT 19-bit address port
  assign cfg_mgmt_write                      = 1'b0;                 // Do not write CFG space
  assign cfg_mgmt_write_data                 = 32'h0;                // Zero out CFG MGMT input data bus
  assign cfg_mgmt_byte_enable                = 4'h0;                 // Zero out CFG MGMT byte enables
  assign cfg_mgmt_read                       = 1'b0;                 // Do not read CFG space
  assign cfg_mgmt_type1_cfg_reg_access       = 1'b0;
  assign cfg_per_func_status_control         = 3'h0;                 // Do not request per function status
  assign cfg_per_function_number             = 4'h0;                 // Zero out function num for status req
  assign cfg_per_function_output_request     = 1'b0;                 // Do not request configuration status update

  assign cfg_err_cor_in                      = 1'b0;                 // Never report Correctable Error
  assign cfg_err_uncor_in                    = 1'b0;                 // Never report UnCorrectable Error

  //assign cfg_flr_done                        = 1'b0;                 // FIXME : how to drive this?
  //assign cfg_vf_flr_done                     = 1'b0;                 // FIXME : how to drive this?

  assign cfg_link_training_enable            = 1'b1;                 // Always enable LTSSM to bring up the Link

  assign cfg_config_space_enable             = 1'b1;
  assign cfg_req_pm_transition_l23_ready     = 1'b0;

  assign cfg_hot_reset_out                   = 1'b0;
  assign cfg_ds_port_number                  = 8'h0;
  assign cfg_ds_bus_number                   = 8'h0;
  assign cfg_ds_device_number                = 5'h0;
  assign cfg_ds_function_number              = 3'h0;
  assign cfg_ext_read_data                   = 32'h0;                // Do not provide cfg data externally
  assign cfg_ext_read_data_valid             = 1'b0;                 // Disable external implemented reg cfg read
  assign cfg_interrupt_pending               = 2'h0;
  assign cfg_interrupt_msi_select            = 4'h0;
  assign cfg_interrupt_msi_pending_status    = 64'h0;

  assign cfg_interrupt_msi_attr              = 3'h0;
  assign cfg_interrupt_msi_tph_present       = 1'b0;
  assign cfg_interrupt_msi_tph_type          = 2'h0;
  assign cfg_interrupt_msi_tph_st_tag        = 9'h0;
  assign cfg_interrupt_msi_function_number   = 3'h0;

reg                       [1:0]     cfg_flr_done_reg0;
reg                       [5:0]     cfg_vf_flr_done_reg0;
reg                       [1:0]     cfg_flr_done_reg1;
reg                       [5:0]     cfg_vf_flr_done_reg1;


always @(posedge user_clk)
  begin
   if (user_reset) begin
      cfg_flr_done_reg0       <= 2'b0;
      cfg_vf_flr_done_reg0    <= 6'b0;
      cfg_flr_done_reg1       <= 2'b0;
      cfg_vf_flr_done_reg1    <= 6'b0;
    end
   else begin
      cfg_flr_done_reg0       <= cfg_flr_in_process[1:0];
      cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process[5:0];
      cfg_flr_done_reg1       <= cfg_flr_done_reg0;
      cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;
    end
  end


assign cfg_flr_done[0] = ~cfg_flr_done_reg1[0] && cfg_flr_done_reg0[0]; assign cfg_flr_done[1] = ~cfg_flr_done_reg1[1] && cfg_flr_done_reg0[1];

assign cfg_vf_flr_done[0] = ~cfg_vf_flr_done_reg1[0] && cfg_vf_flr_done_reg0[0]; assign cfg_vf_flr_done[1] = ~cfg_vf_flr_done_reg1[1] && cfg_vf_flr_done_reg0[1]; assign cfg_vf_flr_done[2] = ~cfg_vf_flr_done_reg1[2] && cfg_vf_flr_done_reg0[2]; assign cfg_vf_flr_done[3] = ~cfg_vf_flr_done_reg1[3] && cfg_vf_flr_done_reg0[3]; assign cfg_vf_flr_done[4] = ~cfg_vf_flr_done_reg1[4] && cfg_vf_flr_done_reg0[4]; assign cfg_vf_flr_done[5] = ~cfg_vf_flr_done_reg1[5] && cfg_vf_flr_done_reg0[5];


endmodule

