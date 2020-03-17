/*****************************************************************************/
//
// Module          : count_updater.v
//
//-----------------------------------------------------------------------------
//
// Description     : takes incoming count index (ID) & increment value and 
//                   updates that index's running total count and 
//                   returns that total count and index as output.
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2016 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
/*****************************************************************************/

`include "PicoDefines.v"

module count_updater (/*AUTOARG*/
   // Outputs
   o_valid, o_count, o_index,
   // Inputs
   clk, rst, i_valid, i_count, i_index
   ) ;
   
   parameter DEPTH = 512;
   parameter WIDTH = 32;
   localparam ABIT = f_enc_bits(DEPTH);

   /* ----------        port declarations     ---------- */

   input		clk;
   input		rst;
   input		i_valid;
   input  [WIDTH-1:0]	i_count;
   input  [ABIT-1:0]	i_index;

   output		o_valid;
   output [WIDTH-1:0]   o_count;
   output [ABIT-1:0]    o_index;

   /* ----------         include files        ---------- */

   `include "functions.vh"

   /* ----------          wires & regs        ---------- */

   reg			rstq;
   wire   [WIDTH-1:0]	_nc0_;
   reg			r1_valid;
   reg    [ABIT-1:0]	r1_index;
   reg    [WIDTH-1:0]	r1_count;
   reg			r1_stale_d_use_r3;
   reg			r1_stale_d_use_r4;
   reg			r1_stale_d_use_r5;
   reg    [1:0]		c1_valid_data_sel;
   reg			r2_valid;
   reg    [ABIT-1:0]	r2_index;
   reg    [WIDTH-1:0]	r2_count;
   reg    [1:0]		r2_valid_data_sel;
   wire   [WIDTH-1:0]	r2_prev_count;
   reg    [WIDTH-1:0]	c2_prev_count;
   reg			r3_valid;
   reg    [ABIT-1:0]	r3_index;
   reg    [WIDTH-1:0]	r3_count;
   reg    [WIDTH-1:0]	r4_count;
   reg    [WIDTH-1:0]	r5_count;

   /* ----------      combinatorial blocks    ---------- */
   /* ----------      external module calls   ---------- */

   dpram #(
      .DEPTH	(DEPTH),
      .WIDTH	(WIDTH),
      .PIPE	(1)
   ) counter_ram (
      // Outputs
      .dout0          (r2_prev_count),
      .dout1          (_nc0_),
      // Inputs
      .clk            (clk),
      .oreg_rst0      (rst),
      .adr0           (i_index),
      .din0           ({WIDTH{1'b0}}),
      .we0            (1'b0),
      .ce0            (1'b1),
      .oreg_ce0       (1'b1),
      .oreg_rst1      (rst),
      .adr1           (r3_index),
      .din1           (r3_count),
      .we1            (r3_valid),
      .ce1            (1'b1),
      .oreg_ce1       (1'b1)
   );

   /* ----------            registers         ---------- */

   always @ (*) begin
      // detect stale ram data (a previous write is in progress
      // but hasn't updated the ram contents) and select which
      // valid data to use (most recent write to ram).
      casex({r1_stale_d_use_r5, r1_stale_d_use_r4, r1_stale_d_use_r3})
	3'b??1: c1_valid_data_sel = 2'd1;
	3'b?10: c1_valid_data_sel = 2'd2;
	3'b100: c1_valid_data_sel = 2'd3;
        default: c1_valid_data_sel = 2'd0;
      endcase
   end

   always @ (*) begin
      casex(r2_valid_data_sel)
	2'd1: c2_prev_count = r3_count;
	2'd2: c2_prev_count = r4_count;
	2'd3: c2_prev_count = r5_count;
        default: c2_prev_count = r2_prev_count;
      endcase
   end

   always @ (posedge clk) begin
      rstq <= rst;
      r1_valid <= i_valid;
      r1_index <= i_index;
      r1_count <= i_count;
      // detect update of the same index before ram contents have been updated
      r1_stale_d_use_r3 <= (i_index == r1_index) & r1_valid;
      r1_stale_d_use_r4 <= (i_index == r2_index) & r2_valid;
      r1_stale_d_use_r5 <= (i_index == r3_index) & r3_valid;
      r2_valid <= r1_valid;
      r2_index <= r1_index;
      r2_count <= r1_count;
      r2_valid_data_sel <= c1_valid_data_sel;
      if (rst) begin
	 // clear ram contents during reset
         r3_valid <= 1'b1;
	 r3_count <= {WIDTH{1'b0}};
      end else begin
         r3_valid <= r2_valid;
	 r3_count <= {c2_prev_count + r2_count};
      end
      // rising edge reset case
      if (rst && !rstq) begin
         r3_index <= {ABIT{1'b0}};
      end else if (rst) begin
	 // clear ram contents during reset
         r3_index <= {r3_index + {{ABIT-1{1'b0}}, {1'b1}}};
      end else begin
         r3_index <= r2_index;
      end
      r4_count <= r3_count;
      r5_count <= r4_count;
   end

   /* ------------------ IO assignments ---------------- */

   assign o_valid = r3_valid;
   assign o_count = r3_count;
   assign o_index = r3_index;

   /* ---------- debug & synopsys off blocks  ---------- */
   
endmodule // count_updater
