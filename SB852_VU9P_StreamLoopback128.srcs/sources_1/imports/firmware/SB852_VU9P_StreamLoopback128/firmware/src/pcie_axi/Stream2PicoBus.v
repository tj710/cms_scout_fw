// Stream2PicoBus.v
// Copyright 2011 Pico Computing, Inc.

// This module implements a PicoBus on two streams:
//   an input stream that carries commands and write data, and
//   an output stream that carries read data.
// Command format:
//   [64]       read flag. 1=read, 0=write.
//   [63:32]    addr in bytes. for 128b PicoBus, bottom four bits are forced to zero.
//   [31:0]     size in bytes

// The read feature is only using 1/3 potential bus throughput, for want of a fifo. That's probably fine.

//TODO it would be really easy to add variable-latency reads. just add a PicoRdAck or PicoDataOutValid signal, and watch it
//  rather than PicoRd_q.

module Stream2PicoBus #(
    parameter           STREAM_ID=1,
    parameter           W=128,
    parameter           C_DATA_WIDTH=128,
    parameter		OW_DVLD_W=(C_DATA_WIDTH==256)?'h2:'h1,
    parameter		S_PB_RATIO=62
    ) (
                               input                      s_clk                 ,
                               input                      s_rst                 ,

    input  [OW_DVLD_W-1:0]     s_out_en              ,
    input  [8:0]               s_out_id              ,
    output [C_DATA_WIDTH-1:0]  s_out_data            ,
    output [OW_DVLD_W-1:0]     s_out_ow_dvld         ,

    input                      s_in_valid            ,
    input  [8:0]               s_in_id               ,
    input  [C_DATA_WIDTH-1:0]  s_in_data             ,
    input  [OW_DVLD_W-1:0]     s_in_ow_dvld          ,

    input   [8:0]              s_poll_id             ,
    output  [31:0]             s_poll_seq            ,
    output  [127:0]            s_poll_next_desc      ,
    output                     s_poll_next_desc_valid,

    input   [8:0]              s_next_desc_rd_id     ,
    input                      s_next_desc_rd_en     ,

    output                     PicoClk               ,
    output                     PicoRst               ,

    output  [W-1:0]            PicoDataIn            ,
    output                     PicoWr                ,
    input   [W-1:0]            PicoDataOut           ,
    output  [31:0]             PicoAddr              ,
    output                     PicoRd
    );

    wire [31:0]     s126o_desc_poll_seq;
    wire            s126o_desc_poll_next_desc_valid;
    wire [127:0]    s126o_desc_poll_next_desc;

    wire pb_o_valid;
    wire pb_o_rdy;
    wire [127:0] pb_o_data;
    wire so_valid;
    wire so_rdy;
    wire [C_DATA_WIDTH-1:0] so_data;
    wire [OW_DVLD_W-1:0] so_ow_dvld;

    PicoStreamOut #(
        .ID(STREAM_ID),
	.C_DATA_WIDTH(C_DATA_WIDTH)
    ) s126o_stream (
        .clk(s_clk),
        .rst(s_rst),

        .s_rdy(so_rdy),
        .s_valid(so_valid),
        .s_data(so_data[C_DATA_WIDTH-1:0]),
	.s_ow_dvld(so_ow_dvld[OW_DVLD_W-1:0]),

        .s_out_en(s_out_en),
        .s_out_id(s_out_id[8:0]),
        .s_out_data(s_out_data[C_DATA_WIDTH-1:0]),
	.s_out_ow_dvld(s_out_ow_dvld[OW_DVLD_W-1:0]),

        .s_in_valid(s_in_valid),
        .s_in_id(s_in_id[8:0]),
        .s_in_data(s_in_data[C_DATA_WIDTH-1:0]),
	.s_in_ow_dvld(s_in_ow_dvld[OW_DVLD_W-1:0]),

        .s_poll_id(s_poll_id[8:0]),
        .s_poll_seq(s126o_desc_poll_seq[31:0]),
        .s_poll_next_desc(s126o_desc_poll_next_desc[127:0]),
        .s_poll_next_desc_valid(s126o_desc_poll_next_desc_valid),

        .s_next_desc_rd_en(s_next_desc_rd_en),
        .s_next_desc_rd_id(s_next_desc_rd_id[8:0])
    );

    OutStreamWidthConversion #(
       .W(128),
       .C_DATA_WIDTH(C_DATA_WIDTH)
    ) s2pb_sowc (
       .clk(s_clk),
       .rst(s_rst),

       .so_valid(so_valid),
       .so_data(so_data[C_DATA_WIDTH-1:0]),
       .so_ow_dvld(so_ow_dvld[OW_DVLD_W-1:0]),
       .so_rdy(so_rdy),

       .si_valid(pb_o_valid),
       .si_data(pb_o_data[127:0]),
       .si_ow_dvld(1'b1),	// unused - tie to logic 1
       .si_rdy(pb_o_rdy)
    );

    wire [31:0]     s126i_desc_poll_seq;
    wire            s126i_desc_poll_next_desc_valid;
    wire [127:0]    s126i_desc_poll_next_desc;

    wire pb_i_valid;
    wire pb_i_rdy;
    wire [127:0] pb_i_data;
    wire si_valid;
    wire si_rdy;
    wire [C_DATA_WIDTH-1:0] si_data;
    wire [OW_DVLD_W-1:0] si_ow_dvld;

    PicoStreamIn #(
        .ID(STREAM_ID),
	.C_DATA_WIDTH(C_DATA_WIDTH)
    ) s126i_stream (
        .clk(s_clk),
        .rst(s_rst),

        .s_rdy(si_valid),
        .s_en(si_rdy),
        .s_data(si_data[C_DATA_WIDTH-1:0]),
	.s_ow_dvld(si_ow_dvld[OW_DVLD_W-1:0]),

        .s_in_valid(s_in_valid),
        .s_in_id(s_in_id[8:0]),
        .s_in_data(s_in_data[C_DATA_WIDTH-1:0]),
	.s_in_ow_dvld(s_in_ow_dvld[OW_DVLD_W-1:0]),

        .s_poll_id(s_poll_id[8:0]),
        .s_poll_seq(s126i_desc_poll_seq[31:0]),
        .s_poll_next_desc(s126i_desc_poll_next_desc[127:0]),
        .s_poll_next_desc_valid(s126i_desc_poll_next_desc_valid),

        .s_next_desc_rd_en(s_next_desc_rd_en),
        .s_next_desc_rd_id(s_next_desc_rd_id[8:0])
    );

    assign s_poll_seq               = s126i_desc_poll_seq | s126o_desc_poll_seq;
    assign s_poll_next_desc         = s126i_desc_poll_next_desc | s126o_desc_poll_next_desc;
    assign s_poll_next_desc_valid   = s126i_desc_poll_next_desc_valid | s126o_desc_poll_next_desc_valid;

    InStreamWidthConversion #(
       .W(128),
       .C_DATA_WIDTH(C_DATA_WIDTH)
    ) s2pb_siwc (
       .clk(s_clk),
       .rst(s_rst),

       .si_valid(si_valid),
       .si_data(si_data[C_DATA_WIDTH-1:0]),
       .si_ow_dvld(si_ow_dvld[OW_DVLD_W-1:0]),
       .si_rdy(si_rdy),

       .so_valid(pb_i_valid),
       .so_data(pb_i_data[127:0]),
       .so_ow_dvld(),	// unused - no connect
       .so_rdy(pb_i_rdy)
    );

    StreamToPicoBus #(
        .WIDTH(W),
	.S_PB_RATIO(S_PB_RATIO)
    ) s2pb (
        .s_clk              (s_clk),
        .s_rst              (s_rst),

        .si_ready           (pb_i_rdy),
        .si_valid           (pb_i_valid),
        .si_data            (pb_i_data[127:0]),

        .so_ready           (pb_o_rdy),
        .so_valid           (pb_o_valid),
        .so_data            (pb_o_data[127:0]),

        .PicoClk            (PicoClk),
        .PicoRst            (PicoRst),
        .PicoWr             (PicoWr),
        .PicoRd             (PicoRd),
        .PicoAddr           (PicoAddr),
        .PicoDataIn         (PicoDataIn),
        .PicoDataOut        (PicoDataOut)
    );
endmodule

