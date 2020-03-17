// StreamToPicoBus.v
// Copyright 2015 Pico Computing, Inc.

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

`default_nettype none

module StreamToPicoBus #(
    parameter                   WIDTH=128,
    parameter			S_PB_RATIO=62
) (
    input  wire                 s_clk,
    input  wire                 s_rst,
    
    output wire                 si_ready,
    input  wire                 si_valid,
    input  wire [127:0]         si_data,
    
    input  wire                 so_ready,
    output wire                 so_valid,
    output wire [127:0]         so_data,

    output wire                 PicoClk,
    output wire                 PicoRst,
    output reg  [WIDTH-1:0]     PicoDataIn,
    output reg                  PicoWr,
    input  wire [WIDTH-1:0]     PicoDataOut,
    output reg  [31:0]          PicoAddr,
    output reg                  PicoRd
);
    
    // generate PicoClk using a counter based clk source.
    // the output frequency is roughly 4MHz
    CounterClkGen #(
        .REF_CLK_FREQ(250),
        .OUT_CLK_FREQ(4),
	.RATIO(S_PB_RATIO)
    ) clk_gen (
        .refclk         (s_clk),
        .rst            (s_rst),
        .clk_o          (PicoClk)
    );

    wire                            i_valid;
    wire                            i_rdy;
    wire        [127:0]             i_data;
    wire                            o_valid;
    wire                            o_rdy;
    wire        [127:0]             o_data;

    // async fifos for crossing between stream clk domain and PicoClk domain
    wire so_full;
    wire so_empty;
    wire so_push = o_valid & o_rdy;
    wire so_pop = so_ready & so_valid;
    wire _so_fifo_nc0_;
    wire [9:0] _so_fifo_nc1_, _so_fifo_nc2_;
    generic_fifo #(
       .WIDTH(128),
       .DEPTH(512),
       .RAM_STYLE("block"),
       .AFULLCNT(512-256),
       .SYNCHRONOUS(0),
       .RATIO(S_PB_RATIO),
       .OSYNC_RESET(1)
    ) so_fifo (
       // Outputs
       .afull(_so_fifo_nc0_),
       .full(so_full),
       .cnt(_so_fifo_nc1_),
       .dout(so_data),
       .empty(so_empty),
       .rcnt(_so_fifo_nc2_),
       // Inputs
       .clk(PicoClk),
       .reset({s_rst, PicoRst}),  // oreset, ireset
       .push(so_push),
       .din(o_data), 
       .oclk(s_clk),
       .pop(so_pop)
    );
    assign so_valid = ~so_empty;
    assign o_rdy = ~so_full;

    wire si_full;
    wire si_empty;
    wire si_push = si_valid & si_ready;
    wire si_pop = i_rdy & i_valid;
    wire _si_fifo_nc0_;
    wire [9:0] _si_fifo_nc1_, _si_fifo_nc2_;
    generic_fifo #(
       .WIDTH(128),
       .DEPTH(512),
       .RAM_STYLE("block"),
       .AFULLCNT(512-256),
       .SYNCHRONOUS(0),
       .RATIO(S_PB_RATIO),
       .OSYNC_RESET(1)
    ) si_fifo (
       // Outputs
       .afull(_si_fifo_nc0_),
       .full(si_full),
       .cnt(_si_fifo_nc1_),
       .dout(i_data),
       .empty(si_empty),
       .rcnt(_si_fifo_nc2_),
       // Inputs
       .clk(s_clk),
       .reset({PicoRst, s_rst}),  // oreset, ireset
       .push(si_push),
       .din(si_data), 
       .oclk(PicoClk),
       .pop(si_pop)
    );
    assign si_ready = ~si_full;
    assign i_valid = ~si_empty;
    
    reg         start_wr, rd_active, wr_active;
    reg [31:0]  rd_len, wr_len;
    reg         PicoRd_q;
    reg         rst_q;
    
    reg [64:0]  cmd;
    reg         cmd_valid;
    
    // handle carefully about crossing reset signal from fast clock domain
    // to slow clock domain. use a two way hand shake
    wire PicoRst_synced;
    sync2r sync_PicoRst (.clk(s_clk), .preset(PicoRst), .d(PicoRst), .q(PicoRst_synced));
    always @(posedge s_clk) begin
        if (s_rst) begin
            rst_q <= 1'b1;
        end else begin
            // deasert rst_q when capture assertion of PicoRst in PicoClk 
            // domain
            if (PicoRst_synced) rst_q <=0;
        end
    end

    sync2r sync_s_rst (.clk(PicoClk), .preset(rst_q), .d(rst_q), .q(PicoRst));

    always @(posedge PicoClk) begin
        if (PicoRst) begin
            cmd_valid   <= 0;
        end else begin
            cmd_valid       <= 0;
            if (i_valid && ~rd_active && ~wr_active && ~cmd_valid) begin
                cmd_valid   <= 1;
                cmd         <= i_data[64:0];
            end
        end
    end
    
    generate if (WIDTH == 128) begin:W128
        
        assign i_rdy = ~rd_active && ~cmd_valid;
        assign o_valid = PicoRd_q;
        assign o_data = PicoDataOut[127:0];
        
        always @(posedge PicoClk) begin
            if (PicoRst) begin
                rd_active   <= 0;
                wr_active   <= 0;
            end
            
            PicoRd  <= 0;
            PicoWr  <= 0;
            PicoRd_q<= PicoRd;
            
            if (cmd_valid /*&& ~rd_active && ~wr_active*/) begin
                if (cmd[64]) begin
                    rd_len      <= cmd[31:0];
                    PicoAddr  <= {cmd[63:32+4], 4'h0};
                    rd_active   <= 1;
                end else begin
                    wr_len      <= cmd[31:0];
                    PicoAddr  <= {cmd[63:32+4], 4'h0};
                    start_wr    <= 1;
                    wr_active   <= 1;
                end
            end
            
            if (i_valid) begin
                
                if (wr_active) begin
                    wr_len      <= wr_len - 16;
                    PicoDataIn  <= i_data[127:0];
                    PicoWr      <= 1;
                    if (~start_wr)
                        PicoAddr  <= PicoAddr + 16;
                    start_wr    <= 0;
                    if (wr_len == 32'h10)
                        wr_active   <= 0;
                end
            end
            
            // we'll fire a read every 3 clock cycles when the output is ready.
            // we could fire one every cycle if we had our own fifo with an almost-full flag, but this is good enough.
            if (o_rdy && rd_active) begin
                if (~PicoRd && ~PicoRd_q)
                    PicoRd      <= 1;
                if (PicoRd_q) begin
                    rd_len      <= rd_len - 16;
                    PicoAddr  <= PicoAddr + 16;
                    if (rd_len == 32'h10)
                        rd_active   <= 0;
                end
            end
        end
        
    end else if (WIDTH == 32) begin:W32
    
        reg [1:0]   wr_byte, rd_byte;
        reg         o_valid_reg;
        reg [127:0] o_data_reg;
        
        assign i_rdy = (~rd_active && ~wr_active && ~cmd_valid) || (wr_active && ((wr_byte == 2'h3) || (wr_len == 32'h4)));
        assign o_valid = o_valid_reg;
        assign o_data = o_data_reg;
        
        always @(posedge PicoClk) begin
            if (PicoRst) begin
                rd_active   <= 0;
                wr_active   <= 0;
            end
            
            //if (PicoRd)     $display("%0t: PicoRd @ 0x%x", $time, PicoAddr);
            //if (PicoRd_q)   $display("%0t: PicoRd data 0x%x", $time, PicoDataOut[31:0]);
            //if (PicoWr)     $display("%0t: PicoWr @ 0x%x. data: 0x%x", $time, PicoAddr, PicoDataIn[31:0]);
            
            PicoRd  <= 0;
            PicoWr  <= 0;
            PicoRd_q<= PicoRd;
            
            if (cmd_valid /*&& ~rd_active && ~wr_active*/) begin
                PicoAddr  <= {cmd[63:32+2], 2'h0};
	        o_data_reg <= 0;	// clear the output register when valid data is returned to streaming interface (for the case where rd_len is less than 16)
                if (cmd[64]) begin
                    rd_len      <= cmd[31:0];
                    rd_byte     <= 2'h0;
                    rd_active   <= 1;
                end else begin
                    wr_len      <= cmd[31:0];
                    wr_byte     <= 2'h0;
                    start_wr    <= 1;
                    wr_active   <= 1;
                end
            end
            
            if (wr_active && (~i_rdy || i_valid  || (wr_len == 32'h4))) begin
                wr_len      <= wr_len - 4;
                if      (wr_byte == 2'h0)   PicoDataIn <= i_data[31:0];
                else if (wr_byte == 2'h1)   PicoDataIn <= i_data[63:32];
                else if (wr_byte == 2'h2)   PicoDataIn <= i_data[95:64];
                else if (wr_byte == 2'h3)   PicoDataIn <= i_data[127:96];
                wr_byte     <= wr_byte + 1;
                PicoWr      <= 1;
                if (~start_wr)
                    PicoAddr  <= PicoAddr + 4;
                start_wr    <= 0;
                if (wr_len == 32'h4)
                    wr_active   <= 0;
            end
            
            // we'll fire a read every 3 clock cycles when the output is ready.
            // we could fire one every cycle if we had our own fifo with an almost-full flag, but this is good enough.
            if (o_rdy && rd_active) begin
                if (~PicoRd && ~PicoRd_q)
                    PicoRd      <= 1;
                if (PicoRd_q) begin
                    rd_len      <= rd_len - 4;
                    PicoAddr  <= PicoAddr + 4;
                    if (rd_len == 32'h4)
                        rd_active   <= 0;
                end
            end
            
            // assemble the PicoDataOut into the 128b register for stream output.
            // (this should be able to handle any number of 32b words, not just multiples of 4. so we may send out partial 128b words.)
            o_valid_reg <= PicoRd_q && ((rd_byte == 2'h3) || (rd_len == 32'h4));
            if (PicoRd_q) begin
                rd_byte <= rd_byte + 1;
                if      (rd_byte == 2'h0)   o_data_reg[31:0]    <= PicoDataOut;
                else if (rd_byte == 2'h1)   o_data_reg[63:32]   <= PicoDataOut;
                else if (rd_byte == 2'h2)   o_data_reg[95:64]   <= PicoDataOut;
                else if (rd_byte == 2'h3)   o_data_reg[127:96]  <= PicoDataOut;
            end
        end
    
    end endgenerate
    
endmodule

`default_nettype wire

