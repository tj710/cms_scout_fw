/*****************************************************************************/
//
// Description     : 2 stage synchronizer with preset, often used to
// 			synchronize async resets
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2016 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
/*****************************************************************************/
/* $Id: sync2r.vpp,v 1.1 2015/01/19 23:17:20 dwalker Exp $ */

`timescale 1 ns / 1 ps

`include "PicoDefines.v"

module sync2r (/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   clk, preset, d
   ) ;
   
   parameter WIDTH = 1;

   /* ----------        port declarations     ---------- */

   input		clk;
   input		preset;
   input  [WIDTH-1:0]	d;

   output [WIDTH-1:0]	q;

   /* ----------         include files        ---------- */
   /* ----------          wires & regs        ---------- */

   // synchronize the source signals
`ifdef ALTERA_FPGA
   (* syn_replicate = 0 *)
   (* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)
   (* syn_preserve = 1 *)
   (* noprune = 1 *)
`else
   (* register_duplication = "no" *)
   (* shreg_extract = "no" *)
   (* equivalent_register_removal = "no" *)
   (* S = "TRUE" *)
   (* KEEP = "TRUE" *)
   (* DONT_TOUCH = "TRUE" *)
`endif
   reg    [WIDTH-1:0]   meta1;
   reg    [WIDTH-1:0]   q;

   /* ----------      combinatorial blocks    ---------- */
   /* ----------      external module calls   ---------- */
   /* ----------            registers         ---------- */

   always @(posedge clk or posedge preset) begin
      if (preset) begin
         meta1 <= {WIDTH{1'b1}};
      end else begin
         meta1 <= d;
      end
   end

   always @(posedge clk or posedge meta1) begin
      if (meta1) begin
         q <= {WIDTH{1'b1}};
      end else begin
         q <= // synopsys translate_off
              // variable latency
              (^$random) ? d :
              // synopsys translate_on
              meta1;
      end
   end

   /* ---------- debug & synopsys off blocks  ---------- */
   
endmodule // sync2r
