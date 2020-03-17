/*****************************************************************************/
//
// Module          : dpram.vpp
//
//-----------------------------------------------------------------------------
//
// Description     : inferred dual port ram 
//			in Xilinx mode reads on same ports as writes return old
//			ram data.
//			*** WARNING *** in Altera mode write data is returned
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

module dpram (/*AUTOARG*/
   // Outputs
   dout0, dout1,
   // Inputs
   clk, adr0, ce0, din0, oreg_ce0, oreg_rst0, we0, adr1, ce1, din1,
   oreg_ce1, oreg_rst1, we1
   ) ;
   parameter DEPTH = 512;
   parameter WIDTH = 72;
   localparam DBIT = f_enc_bits(DEPTH);
   parameter PIPE = 1;
   parameter RAM_STYLE = "block";
`ifdef ALTERA_FPGA
   localparam ALTRAM_STYLE = ((RAM_STYLE == "block") || (RAM_STYLE == "m20k")) ? "m20k" : "mlab";
   /* ***WARNING*** ALTERA mode is not functionally equivalent to Xilinx inference! */
   // Altera == 1, doesn't use ram ce input, reads on same ports as writes return write data
   // Altera == 0, uses ram ce input, reads on same ports as writes return read data
   parameter ALTERA = 1; 
   /* ***WARNING*** ALTERA mode is not functionally equivalent to Xilinx inference! */
`else
   /* ***WARNING*** ALTERA mode is not functionally equivalent to Xilinx inference! */
   // Altera == 1, doesn't use ram ce input, reads on same ports as writes return write data
   // Altera == 0, uses ram ce input, reads on same ports as writes return read data
   parameter ALTERA = 0; 
   /* ***WARNING*** ALTERA mode is not functionally equivalent to Xilinx inference! */
`endif
   
   /* ----------        port declarations     ---------- */

   input		clk;
   input  [DBIT-1:0]	adr0;
   input		ce0;
   input  [WIDTH-1:0]	din0;
   input		oreg_ce0;
   input		oreg_rst0;
   input		we0;
   input  [DBIT-1:0]	adr1;
   input		ce1;
   input  [WIDTH-1:0]	din1;
   input		oreg_ce1;
   input		oreg_rst1;
   input		we1;

   output [WIDTH-1:0]	dout0;
   output [WIDTH-1:0]	dout1;

   /* ----------         include files        ---------- */
   /* ----------          wires & regs        ---------- */

`ifdef ALTERA_FPGA
   (* ramstyle = ALTRAM_STYLE *)
`else
   (* ram_style = RAM_STYLE *)
`endif
   reg    [WIDTH-1:0]	mem[DEPTH-1:0];
   reg    [WIDTH-1:0]	ram_dout0;
   reg    [WIDTH-1:0]	ram_dout1;

   /* ----------      combinatorial blocks    ---------- */
   
   
   /* ----------      external module calls   ---------- */
   /* ----------            registers         ---------- */

   //
   // Ram storage
   //
   generate if (ALTERA>0) begin : infer_alt
      always @ (posedge clk) begin
         if (we0) begin
            mem[adr0] <= din0;
	    ram_dout0 <= din0;
	 end else begin
            ram_dout0 <= mem[adr0];
	 end
      end
   
      always @ (posedge clk) begin
         if (we1) begin
            mem[adr1] <= din1;
	    ram_dout1 <= din1;
	 end else begin
            ram_dout1 <= mem[adr1];
	 end
      end
   end else begin : infer_x
      always @ (posedge clk) begin
         if (ce0) begin
            if (we0)
               mem[adr0] <= din0;
            ram_dout0 <= mem[adr0];
         end
      end
   
      always @ (posedge clk) begin
         if (ce1) begin
            if (we1)
               mem[adr1] <= din1;
            ram_dout1 <= mem[adr1];
         end
      end
   end endgenerate

   //
   // Output pipe stage
   //
   generate if (PIPE>0) begin : pipe_t
      reg [WIDTH-1:0] r_dout0;
      reg [WIDTH-1:0] r_dout1;

      always @(posedge clk) begin
         if (oreg_rst0)
	    r_dout0 <= 'h0;
	 else if (oreg_ce0)
	    r_dout0 <= ram_dout0;

         if (oreg_rst1)
	    r_dout1 <= 'h0;
	 else if (oreg_ce1)
	    r_dout1 <= ram_dout1;
      end
      assign dout0 = r_dout0;
      assign dout1 = r_dout1;
   end else begin : pipe_f	// (PIPE==0)
      assign dout0 = ram_dout0;
      assign dout1 = ram_dout1;
   end endgenerate

   /* ---------- debug & synopsys off blocks  ---------- */
   
   `include "functions.vh"

endmodule // dpram
