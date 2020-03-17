/*****************************************************************************/
//
// Module          : sdpram.vpp
//
//-----------------------------------------------------------------------------
//
// Original Author : Dean Walker
// Created On      : Thu Jan 12 15:04:20 2012
//
//-----------------------------------------------------------------------------
//
// Description     : inferred simple dual port ram
//
//			infers block ram if DEPTH > 256
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2012 : created by Convey Computer Corp. This model is the
// confidential and proprietary property of Convey Computer Corp.
//
/*****************************************************************************/

`timescale 1 ns / 1 ps

`ifdef ALTERA_FPGA
(* syn_allow_retiming = 1 *)
`else
(* register_balancing = "yes" *)
`endif
module sdpram (/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   clk, wadr, din, we, radr, ce, oreg_ce, oreg_rst
   ) ;
   parameter DEPTH = 512;
   parameter WIDTH = 64;
   localparam DBIT = f_enc_bits(DEPTH);
   parameter USE_BRAM = (DEPTH > 256) ? 1 : 0;
   parameter PIPE = USE_BRAM;
`ifdef ALTERA_FPGA
   localparam RAM_STYLE = USE_BRAM ? "m20k" : "mlab";
`else
   localparam RAM_STYLE = USE_BRAM ? "block" : "distributed";
`endif
   parameter NOCE = 0;	// do not use ram ce input
   
   /* ----------        port declarations     ---------- */

   input		clk;
   input  [DBIT-1:0]	wadr;
   input  [WIDTH-1:0]	din;
   input		we;
   input  [DBIT-1:0]	radr;
   input		ce;
   input		oreg_ce;
   input		oreg_rst;

   output [WIDTH-1:0]	dout;

   /* ----------         include files        ---------- */

   localparam RAM64C = (((WIDTH / 3) * 3) == WIDTH) ? (WIDTH / 3) : ((WIDTH / 3) + 1);
   localparam RAM32C = (((WIDTH / 6) * 6) == WIDTH) ? (WIDTH / 6) : ((WIDTH / 6) + 1);

   /* ----------          wires & regs        ---------- */

   reg    [WIDTH-1:0]	ram_dout;

   /* ----------      combinatorial blocks    ---------- */

`ifdef ALTERA_FPGA
`else
   genvar i;
   generate if (DEPTH == 64) begin : ram64

      wire [(RAM64C*3)-1:0] l_ram_dout;
      reg  [(RAM64C*3)-1:0] l_din;
      wire [RAM64C-1:0] _nc0_;

      always @ (*) begin
         l_din = 'h0;
         l_din[WIDTH-1:0] = din;
      end
      

      for (i=0; i<RAM64C; i=i+1) begin : ram
         RAM64M ram (
            // Outputs
            .DOA        (l_ram_dout[i*3]),
            .DOB        (l_ram_dout[(i*3)+1]),
            .DOC        (l_ram_dout[(i*3)+2]),
            .DOD        (_nc0_[i]),
            // Inputs
            .ADDRA      (radr),
            .ADDRB      (radr),
            .ADDRC      (radr),
            .ADDRD      (wadr),
            .DIA        (l_din[i*3]),
            .DIB        (l_din[(i*3)+1]),
            .DIC        (l_din[(i*3)+2]),
            .DID        (1'b0),
            .WCLK       (clk),
            .WE         (we)
         );
      end

      for (i=0; i<WIDTH; i=i+1) begin : ff
	 if (NOCE>0) begin : noce
            always @ (posedge clk) begin
               ram_dout[i] <= l_ram_dout[i];
            end
	 end else begin : wce
            always @ (posedge clk) begin
               if (ce)
                  ram_dout[i] <= l_ram_dout[i];
            end
	 end
      end

   end else if (DEPTH == 32) begin : ram32

      wire [(RAM32C*6)-1:0] l_ram_dout;
      reg  [(RAM32C*6)-1:0] l_din;
      wire [RAM32C*2-1:0] _nc0_;

      always @ (*) begin
         l_din = 'h0;
         l_din[WIDTH-1:0] = din;
      end

      for (i=0; i<RAM32C; i=i+1) begin : ram
         RAM32M ram (
            // Outputs
            .DOA        (l_ram_dout[i*6 +: 2]),
            .DOB        (l_ram_dout[i*6+2 +: 2]),
            .DOC        (l_ram_dout[i*6+4 +: 2]),
            .DOD        (_nc0_[i*2 +: 2]),
            // Inputs
            .ADDRA      (radr),
            .ADDRB      (radr),
            .ADDRC      (radr),
            .ADDRD      (wadr),
            .DIA        (l_din[i*6 +: 2]),
            .DIB        (l_din[i*6+2 +: 2]),
            .DIC        (l_din[i*6+4 +: 2]),
            .DID        (2'b0),
            .WCLK       (clk),
            .WE         (we)
         );
      end

      for (i=0; i<WIDTH; i=i+1) begin : ff
	 if (NOCE>0) begin : noce
            always @ (posedge clk) begin
               ram_dout[i] <= l_ram_dout[i];
            end
	 end else begin : wce
            always @ (posedge clk) begin
               if (ce)
                  ram_dout[i] <= l_ram_dout[i];
            end
	 end
      end

   end else begin : infer // (DEPTH != 64 && DEPTH != 32)
`endif

      /* ----------          wires & regs        ---------- */

`ifdef ALTERA_FPGA
      (* ramstyle = RAM_STYLE *)
`else
      (* ram_style = RAM_STYLE *)
`endif
      reg    [WIDTH-1:0]	mem[DEPTH-1:0];

      /* ----------      combinatorial blocks    ---------- */
      /* ----------      external module calls   ---------- */
      /* ----------            registers         ---------- */

`ifdef ALTERA_FPGA
   generate if (NOCE>0) begin : infer_noce
`else
   if (NOCE>0) begin : infer_noce
`endif
      //
      // Ram storage
      //
      always @ (posedge clk) begin
            ram_dout <= mem[radr];
      end

      always @ (posedge clk) begin
         if (we)
            mem[wadr] <= din;
      end
   end else begin : infer_ce
      //
      // Ram storage
      //
      always @ (posedge clk) begin
         if (ce)
            ram_dout <= mem[radr];
      end

      always @ (posedge clk) begin
         if (we)
            mem[wadr] <= din;
      end
`ifdef ALTERA_FPGA
`else
   end
`endif

   end endgenerate

   //
   // Output pipe stage
   //
   generate if (PIPE>0) begin : pipe_t
      reg [WIDTH-1:0] r_dout;

      always @(posedge clk) begin
         if (oreg_rst)
	    r_dout <= 'h0;
	 else if (oreg_ce)
	    r_dout <= ram_dout;
      end
      assign dout = r_dout;
   end else begin : pipe_f	// (PIPE==0)
      assign dout = ram_dout;
   end endgenerate

   /* ---------- debug & synopsys off blocks  ---------- */
   
   `include "functions.vh"

endmodule // sdpram
