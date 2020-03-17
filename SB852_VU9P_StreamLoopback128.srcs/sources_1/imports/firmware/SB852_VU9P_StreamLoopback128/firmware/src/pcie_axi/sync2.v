/*****************************************************************************/
//
// Description     : 2 stage synchronizer
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2016 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
/*****************************************************************************/
/* $Id: sync2.vpp,v 1.3 2014/05/28 22:25:36 dwalker Exp $ */

`timescale 1 ns / 1 ps

`include "PicoDefines.v"

module sync2 (/*AUTOARG*/
   // Outputs
   q,
   // Inputs
   clk, d
   ) ;
   
   parameter WIDTH = 1;

   /* ----------        port declarations     ---------- */

   input		clk;
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

   always @(posedge clk) begin
      meta1 <= d;
      q <= // synopsys translate_off
           // variable latency
           (^$random) ? d :
           // synopsys translate_on
           meta1;
   end

   /* ---------- debug & synopsys off blocks  ---------- */
   
endmodule // sync2
