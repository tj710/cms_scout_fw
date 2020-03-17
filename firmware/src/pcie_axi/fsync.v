/*****************************************************************************/
//
// Module	   : fsync.v
//
//-----------------------------------------------------------------------------
//
// Description: This module synchronizes a flag signal supporting
//		a destination clock rate upto RATIO times slower/faster.
//		To accomplish this, the module utilizes parallel
//		synchronization channels that toggle to identify flags.
//		Since parallel channels are utilized, each destination
//		cycle may receive multiple flags hence the width of oflg
//		which is a count of flags transitioned.
//
//		Usage notes:
//
//		RATIO = MIN(MAX(1, CEIL(SrcFreq/DstFreq)), 64/*f_pop128*/);
//
//		-RATIO implies a synchronous ratio (clock division). Using
//		a -RATIO removes the variable latency which is overly
//		pessimistic for a synchronous (clock division) interface.
//		Variable latency is desirable for asynchronous ratios, to
//		mimic the non-deterministic latency of the asynchronous
//		interface in simulation.
//
//		RATIO = 0 indicates synchronous mode so that flag
//		is passed directly to the output. This is useful
//		for parametrized code.
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2016 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
//
/*****************************************************************************/

`include "PicoDefines.v"
    
`ifdef ALTERA_FPGA
(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)
`else
(* shreg_extract = "no" *)
`endif
module fsync #(parameter
    RATIO = 2,
    ISOLATE = 0,	// isolate asnyc path with buffer
    FAST_OFLG = 0,	// don't register oflg combinatorial cone
    SYNCHRONOUS = 0	// clk and oclk are the same clk or integer multiples that are phase synchronous (1)
)(clk, flg, oclk, oflg);
localparam ARAT = RATIO < 0 ? -RATIO : RATIO;	// abs(RATIO)
localparam SN = ARAT*2;				// # parallel sync lanes
localparam SB = ARAT < 1 ? 0 : f_enc_bits(SN);	// # bits for flags per oclk
localparam NEG_RATIO_OR_SYNC = SYNCHRONOUS + ((RATIO < 0) ? 1 : 0);
localparam C_RATIO = (NEG_RATIO_OR_SYNC > 0) ? -ARAT : ARAT;

input		clk;
input		flg;
input		oclk;
output [SB:0]	oflg;

    genvar i;
    generate if (RATIO == 0) begin
	assign oflg = flg;
    end else begin

	// ring counter to identify current lane
`ifdef ALTERA_FPGA
        (* syn_preserve = 1 *)
`else
        (* equivalent_register_removal = "no" *)
`endif
	reg [SB-1:0] r_cnt;
	always @(posedge clk) begin
	    r_cnt <= // synthesis translate_off
		     (^r_cnt === 1'bx) ? $random :
		     // synthesis translate_on
		     (r_cnt >= (SN-1)) ? 'd0 : r_cnt + 'b1;
	end

	// toggle source register for current lane
	wire [SN-1:0] c_tog = flg << r_cnt;
`ifdef ALTERA_FPGA
        (* syn_preserve = 1 *)
`else
        (* equivalent_register_removal = "no" *)
`endif
	reg  [SN-1:0] r_src;
	always @(posedge clk) begin
	    r_src <= // synthesis translate_off
		     (^r_src === 1'bx) ? $random :
		     // synthesis translate_on
		     r_src ^ c_tog;
	end

	reg [SN-1:0] r_dst1, r_dst2;
	if (NEG_RATIO_OR_SYNC) begin
	    // clocks are synchronous just re-register the source signals
	    // for latency
	    reg [SN-1:0] r_dst0;
	    always @(posedge oclk) begin
	        r_dst0 <= r_src;
	        r_dst1 <= r_dst0;
	        r_dst2 <= r_dst1;
	    end
	end else begin
	    // isolate TIG signal
`ifdef ALTERA_FPGA
            (* syn_keep = 1 *)
`else
            (* KEEP = "true" *) 
`endif
	    wire [SN-1:0] _AsYnC_r_src;

	    if (ISOLATE && C_RATIO > 0) begin
	        for (i=0; i<SN; i=i+1) begin : g0
`ifdef ALTERA_FPGA
	            assign _AsYnC_r_src[i] = r_src[i];
`else
		    (* S = "true" *)
		    BUF bf (.O(_AsYnC_r_src[i]), .I(r_src[i]));
`endif
	        end
	    end else begin
	        assign _AsYnC_r_src = r_src;
	    end

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
	    reg [SN-1:0] meta1;
	    always @(posedge oclk) begin
	        meta1 <= (C_RATIO > 0) ? _AsYnC_r_src : r_src;
	        r_dst1 <= // synthesis translate_off
		          // variable latency
		          (C_RATIO > 0 && ^$random) ? _AsYnC_r_src :
		          // synthesis translate_on
		      meta1;
	        r_dst2 <= r_dst1;
	    end
	end

	// sum the number of flags
	wire [SB:0] c_oflg;
	if (SN <= 32) begin
	   assign c_oflg = f_pop32(r_dst1 ^ r_dst2);
	end else if (SN <= 64) begin
	      wire [11:0] c_1st_stg;
	      reg  [11:0] r_1st_stg;
	      assign c_1st_stg = {f_pop32(r_dst1[SN-1:32] ^ r_dst2[SN-1:32]), f_pop32(r_dst1[31:0] ^ r_dst2[31:0])};
	      always @(posedge oclk) r_1st_stg <= c_1st_stg;
	      assign c_oflg = r_1st_stg[11:6] + r_1st_stg[5:0];
	end else if (SN <= 128) begin
	      wire [23:0] c_1st_stg;
	      reg  [23:0] r_1st_stg;
	      assign c_1st_stg = {f_pop32(r_dst1[SN-1:96] ^ r_dst2[SN-1:96]), f_pop32(r_dst1[95:64] ^ r_dst2[95:64]), 
	                          f_pop32(r_dst1[63:32] ^ r_dst2[63:32]), f_pop32(r_dst1[31:0] ^ r_dst2[31:0])};
	      always @(posedge oclk) r_1st_stg <= c_1st_stg;
	      assign c_oflg = r_1st_stg[23:18] + r_1st_stg[17:12] + r_1st_stg[11:6] + r_1st_stg[5:0];
	end else begin
	      assign c_oflg = 'd0;
	      // synthesis translate_off
	      always @ (posedge oclk) begin
	         $display("ERROR: %m Unsupported Async Clock Ratio %d:1, max is 64:1 @ time %t\n", RATIO, $time);
	      end
	      // synthesis translate_on
	end

	if (FAST_OFLG) begin
	    assign oflg = c_oflg;
	end else begin
	    reg [SB:0] r_oflg;
	    always @(posedge oclk) r_oflg <= c_oflg;
	    assign oflg = r_oflg;
	end
    end endgenerate

    `include "functions.vh"

endmodule
