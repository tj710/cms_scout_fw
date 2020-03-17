// StreamWidthConversion.v
// Copyright 2011 Pico Computing, Inc.

// This module allows for conversion of streams from the base C_DATA_WIDTH.

// This module converts an input stream from C_DATA_WIDTH to W 
// (currently only supports C_DATA_WIDTH==256 && W==(256 || 128 || 32) or 
//                          C_DATA_WIDTH==128 && W==(128 || 32)
module InStreamWidthConversion #(
        parameter           W=128,
	parameter	    C_DATA_WIDTH=128,
	parameter	    SI_OW_DVLD_W=(C_DATA_WIDTH==256)?'d2:'d1,
	parameter	    SO_OW_DVLD_W=(W==256)?'d2:'d1

    ) (
        // core stream signals
        input               clk,
        input               rst,
        
        // "wide" input stream signals that will be converted to a "narrow" stream
        input              si_valid,
        input      [C_DATA_WIDTH-1:0] si_data,
	input      [SI_OW_DVLD_W-1:0] si_ow_dvld,	// 16 byte (Octa) word valid flags
        output reg         si_rdy,
        
        // converted "narrow" input stream signals
        output reg           so_valid,  
	output reg [SO_OW_DVLD_W-1:0] so_ow_dvld,	// Only useful for 256 bit passthru case
        input                so_rdy,    
        output reg [W-1:0]   so_data
    );
    
    // state machine to control the loading of the data
    localparam  IDLE    = 4'b0001,	// 0
		LD_D0   = 4'b0000,	// 0
                D0      = 4'b1001,	// 9
                D1      = 4'b1010,	// 10
                D2      = 4'b1011,	// 11,
                D3      = 4'b1100,	// 12,
                D4      = 4'b1101,	// 13,
                D5      = 4'b1110,	// 14,
                D6      = 4'b1111,	// 15,
                D7      = 4'b1000;	// 8
   
    generate if (W == C_DATA_WIDTH) begin : g_passthru
       // No conversion necessary, just pass the data and controls through
       always @ (*) begin
          si_rdy = so_rdy;
          so_valid = si_valid;
	  so_ow_dvld = si_ow_dvld;
          so_data = si_data;
       end

    end else begin : g_streamwidthconvert

       wire            p_si_width256 = (C_DATA_WIDTH == 256);
       wire            p_si_width128 = (C_DATA_WIDTH == 128);
       wire            p_conv_width128 = (W == 128);
       wire            p_conv_width32 = (W == 32);

       reg             c_si_rdy;
       reg             c_so_valid;

       reg     [C_DATA_WIDTH-1:0] si_data_hold;
       reg     [SI_OW_DVLD_W-1:0] si_ow_dvld_hold;
      
       reg             c_load_so_data;
       reg             c_nxt_si_data_vld;
       reg             r_nxt_si_data_vld;
       
       reg     [3:0]   r_state;
       reg     [3:0]   c_state;

       wire    [7:0]   c_ow_dvld;

       // load data into a C_DATA_WIDTH bit wide local register
       always @ (posedge clk) begin
           if (c_si_rdy) begin
               si_data_hold <= si_data;
	       si_ow_dvld_hold <= si_ow_dvld;
           end
       end

       // If si width is 256 bit, then the si_ow_dvld field will indicate the
       // validity of the two 16 byte (Octa) words. 
       // In the 256 bit case we'll use si_ow_dvld to determine the validity
       // of so_data, i.e. so_valid based on the conversion width
       // In cases other than 256 bit, the c_ow_dvld field is unnecessary and
       // all 16 byte input words are considered valid
       if (C_DATA_WIDTH == 256) begin : g_ow_dvld
          assign c_ow_dvld = p_conv_width128 ? {6'h0, si_ow_dvld_hold[1:0]} : 
                                               {{4{si_ow_dvld_hold[1]}}, {4{si_ow_dvld_hold[0]}}};
       end else begin : g_no_ow_dvld
          assign c_ow_dvld = 8'hff;
       end
   
       if ((C_DATA_WIDTH == 256) && (W == 128)) begin : g_strconv256to128
          // load data from 256-bit register into the 128-bit output register
          always @ (posedge clk) begin
              if (c_load_so_data) begin
                  case(r_state[0]) 
                      1'b0: so_data <= si_data_hold[127:0];
                      1'b1: so_data <= si_data_hold[255:128];
                  endcase
              end
          end
       end else if ((C_DATA_WIDTH == 128) && (W == 32)) begin : g_strconv128to32
          // load data from 128-bit register into the 32-bit output register
          always @ (posedge clk) begin
              if (c_load_so_data) begin
                  case(r_state[1:0]) 
                      2'h0: so_data <= si_data_hold[31:0];
                      2'h1: so_data <= si_data_hold[63:32];
                      2'h2: so_data <= si_data_hold[95:64];
                      2'h3: so_data <= si_data_hold[127:96];
                  endcase
              end
          end
       end else if ((C_DATA_WIDTH == 256) && (W == 32)) begin : g_strconv256to32
          // load data from 256-bit register into the 32-bit output register
          always @ (posedge clk) begin
              if (c_load_so_data) begin
                  case(r_state[2:0]) 
                      3'h0: so_data <= si_data_hold[31:0];
                      3'h1: so_data <= si_data_hold[63:32];
                      3'h2: so_data <= si_data_hold[95:64];
                      3'h3: so_data <= si_data_hold[127:96];
                      3'h4: so_data <= si_data_hold[159:128];
                      3'h5: so_data <= si_data_hold[191:160];
                      3'h6: so_data <= si_data_hold[223:192];
                      3'h7: so_data <= si_data_hold[255:224];
                  endcase
              end
          end
       end else begin : g_invalid_strconv
          // Unsupported conversion
          always @ (posedge clk) begin
	     so_data <= 'hdeadbeef;
	     // synthesis translate_off
	     $display("ERROR: %m Unsupported Stream Width Conversion Parameters W = %d, C_DATA_WIDTH = %d @ time %t\n", W, C_DATA_WIDTH, $time);
	     // synthesis translate_on
          end
       end

       // FSM
       always @ (posedge clk) begin
           if (rst) begin
	       si_rdy <= 1'b0;
	       so_valid <= 1'b0;
               r_state <= IDLE;
	       r_nxt_si_data_vld <= 1'b0;
           end else begin
	       si_rdy <= c_si_rdy;
	       so_valid <= c_so_valid;
               r_state <= c_state;
	       r_nxt_si_data_vld <= c_nxt_si_data_vld;
           end
       end
   
       // next state logic
       always @ (*) begin
           so_ow_dvld = {SO_OW_DVLD_W{1'b1}};	// W should never be 256 bits in this case
   
           c_si_rdy = 1'b0;
           c_so_valid = so_valid;
           c_load_so_data = 1'b0;
           c_state = r_state;
	   c_nxt_si_data_vld = r_nxt_si_data_vld;
   
           case (r_state)
              
	       // When stream is valid load input holding register, then assert
	       // si_rdy on next cycle and transition to the load first output 
	       // data state
               IDLE: begin
		   c_nxt_si_data_vld = 1'b0;
		   c_so_valid = 1'b0;
                   if (si_valid) begin
                      c_state = LD_D0;
		      c_si_rdy = 1'b1;
                   end
               end

	       // load the so_data register with cycle 0 data and transition
	       // to Data 0 state
               LD_D0: begin
	           c_state = D0;
		   c_load_so_data = 1'b1;
		   c_so_valid = c_ow_dvld[0];
	       end

	       // assert so_valid and when the bus is rdy then load the so_data
	       // register with cycle 1 data and transition to Data 1 state.
	       // If we're doing a 256 bit to 128 bit stream conversion then
	       // check if the input stream is valid, if so latch the data and
	       // assert si_rdy on the next cycle. Also hold status that we've
	       // latched the next input data
	       D0: begin
		   if (so_rdy || !so_valid) begin
		      c_state = D1;
		      c_load_so_data = 1'b1;
		      c_so_valid = c_ow_dvld[1];
	              if (p_si_width256 && p_conv_width128 && si_valid) begin
		         c_si_rdy = 1'b1;
			 c_nxt_si_data_vld = 1'b1;
		      end
		   end
	       end

	       // assert so_valid and when the bus is rdy then load the so_data
	       // register with cycle 2 data and transition to Data 2 state.
	       // Except when we're doing a 256b -> 128b conversion. In that
	       // case when the bus is rdy do 1 of 3 things. If we've already
	       // loaded the next input data then load the so_data register
	       // with cycle 0 data and transition to Data 0 state.
	       // Else check if the input stream is valid, if so latch the
	       // data and assert si_rdy on the next cycle and transiton to the
	       // load first data state. 
	       // Else just go back to the IDLE state and wait for a valid input
	       D1: begin
		   if (so_rdy || !so_valid) begin
	              if (p_si_width256 && p_conv_width128) begin
		         if (r_nxt_si_data_vld) begin
		            c_state = D0;
		            c_load_so_data = 1'b1;
		            c_so_valid = c_ow_dvld[0];
			    c_nxt_si_data_vld = 1'b0;
			 end else if (si_valid) begin
		            c_state = LD_D0;
		            c_si_rdy = 1'b1;
		            c_so_valid = 1'b0;
		         end else begin
		            c_state = IDLE;
		            c_so_valid = 1'b0;
		         end
		      end else begin
		         c_state = D2;
		         c_load_so_data = 1'b1;
		         c_so_valid = c_ow_dvld[2];
		      end
		   end
	       end

	       // assert so_valid and when the bus is rdy then load the so_data
	       // register with cycle 3 data and transition to Data 3 state.
	       // If we're doing a 128 bit to 32 bit stream conversion then
	       // check if the input stream is valid, if so latch the data and
	       // assert si_rdy on the next cycle. Also hold status that we've
	       // latched the next input data
	       D2: begin
		   if (so_rdy || !so_valid) begin
		      c_state = D3;
		      c_load_so_data = 1'b1;
		      c_so_valid = c_ow_dvld[3];
	              if (p_si_width128 && p_conv_width32 && si_valid) begin
		         c_si_rdy = 1'b1;
			 c_nxt_si_data_vld = 1'b1;
		      end 
		   end
	       end

	       // assert so_valid and when the bus is rdy then load the so_data
	       // register with cycle 4 data and transition to Data 4 state.
	       // Except when we're doing a 128b -> 32b conversion. In that
	       // case when the bus is rdy do 1 of 3 things. If we've already
	       // loaded the next input data then load the so_data register
	       // with cycle 0 data and transition to Data 0 state.
	       // Else check if the input stream is valid, if so latch the
	       // data and assert si_rdy on the next cycle and transiton to the
	       // load first data state. 
	       // Else just go back to the IDLE state and wait for a valid input
	       D3: begin
		   if (so_rdy || !so_valid) begin
	              if (p_si_width128 && p_conv_width32) begin
		         if (r_nxt_si_data_vld) begin
		            c_state = D0;
		            c_load_so_data = 1'b1;
			    c_nxt_si_data_vld = 1'b0;
			 end else if (si_valid) begin
		            c_state = LD_D0;
		            c_si_rdy = 1'b1;
		            c_so_valid = 1'b0;
		         end else begin
		            c_state = IDLE;
		            c_so_valid = 1'b0;
		         end
		      end else begin
		         c_state = D4;
		         c_load_so_data = 1'b1;
		         c_so_valid = c_ow_dvld[4];
		      end
		   end
	       end

	       // We must be in the 256b -> 32b stream conversion. If so, we
	       // do nothing in the D4 & D5 states except to load the so_data
	       // register and transition to the next state when the bus is
	       // rdy.
               D4: begin
		   if (so_rdy || !so_valid) begin
	              c_state = D5;
		      c_load_so_data = 1'b1;
		      c_so_valid = c_ow_dvld[5];
		   end
	       end

               D5: begin
		   if (so_rdy || !so_valid) begin
	              c_state = D6;
		      c_load_so_data = 1'b1;
		      c_so_valid = c_ow_dvld[6];
		   end
	       end

	       // assert so_valid and when the bus is rdy then load the so_data
	       // register with cycle 7 data and transition to Data 7 state.
	       // Then check if the input stream is valid, if so latch the data
	       // and assert si_rdy on the next cycle. Also hold status that 
	       // we've latched the next input data
	       D6: begin
		   if (so_rdy || !so_valid) begin
		      c_state = D7;
		      c_load_so_data = 1'b1;
		      c_so_valid = c_ow_dvld[7];
	              if (si_valid) begin
		         c_si_rdy = 1'b1;
			 c_nxt_si_data_vld = 1'b1;
		      end 
		   end
	       end

	       // assert so_valid and when the bus is rdy then do 1 of 3 things.
	       // If we've already loaded the next input data then load the 
	       // so_data register with cycle 0 data and transition to Data 0 
	       // state.
	       // Else check if the input stream is valid, if so latch the
	       // data and assert si_rdy on the next cycle and transiton to the
	       // load first data state. 
	       // Else just go back to the IDLE state and wait for a valid input
	       D7: begin
		   if (so_rdy || !so_valid) begin
		      if (r_nxt_si_data_vld) begin
		         c_state = D0;
		         c_load_so_data = 1'b1;
		         c_so_valid = c_ow_dvld[0];
		         c_nxt_si_data_vld = 1'b0;
		      end else if (si_valid) begin
		         c_state = LD_D0;
		         c_si_rdy = 1'b1;
		         c_so_valid = 1'b0;
		      end else begin
		         c_state = IDLE;
		         c_so_valid = 1'b0;
		      end
		   end
	       end

               // should never enter this state
               default: begin
                   c_state = IDLE;
               end
           endcase
       end
    end endgenerate
      
endmodule 

// This module converts an out stream from W to C_DATA_WIDTH
// (currently only written for C_DATA_WIDTH = 256 or 128 AND W=128 or 32)
module OutStreamWidthConversion #(
        parameter           W=128,
	parameter	    C_DATA_WIDTH=128,
	parameter	    SO_OW_DVLD_W=(C_DATA_WIDTH==256)?'d2:'d1,
	parameter	    SI_OW_DVLD_W=(W==256)?'d2:'d1
    ) (
        // core stream signals
        input               clk,
        input               rst,
        
        // converted "wide" output stream signals
        output reg          so_valid,
        output reg  [C_DATA_WIDTH-1:0] so_data,
	output reg  [SO_OW_DVLD_W-1:0] so_ow_dvld,		// 16 byte (Octa) word valid flags
        input               so_rdy,
        
        // "narrow" output stream signals that will be converted to a "wide" stream
        input               si_valid,  
	input       [SI_OW_DVLD_W-1:0] si_ow_dvld,		// Only useful for 256 bit passthru case
        output reg          si_rdy,    
        input       [W-1:0] si_data
    );
    
    // state machine to control the loading of the data
    localparam  IDLE    = 4'b0001,	// 0
		LD_D0   = 4'b0000,	// 0
                D0      = 4'b1001,	// 9
                D1      = 4'b1010,	// 10
                D2      = 4'b1011,	// 11,
                D3      = 4'b1100,	// 12,
                D4      = 4'b1101,	// 13,
                D5      = 4'b1110,	// 14,
                D6      = 4'b1111,	// 15,
                D7      = 4'b1000;	// 8

    // parameter to indicate the upper msb ow_dvld bit
    localparam UPPER_OW_DVLD_B = SO_OW_DVLD_W-1;

    generate if (W == C_DATA_WIDTH) begin : g_passthru
       // No conversion necessary, just pass the data and controls through
       always @ (*) begin
          so_valid = si_valid;
          so_data = si_data;
	  so_ow_dvld = si_ow_dvld;
          si_rdy = so_rdy;
       end

    end else begin : g_streamwidthconvert

       wire            p_so_width256 = (C_DATA_WIDTH == 256);
       wire            p_so_width128 = (C_DATA_WIDTH == 128);
       wire            p_conv_width128 = (W == 128);
       wire            p_conv_width32 = (W == 32);

       reg             c_so_valid;
       reg     [SO_OW_DVLD_W-1:0] c_so_ow_dvld;
       reg     [W-1:0] si_data_hold;

       reg             c_load_so_data;
       reg             c_si_data_hold_vld;
       reg             r_si_data_hold_vld;

       reg     [3:0]   r_state;
       reg     [3:0]   c_state;

       reg             c_frc_so_data_sel;
       reg     [2:0]   c_so_data_sel;
   
       // load data into a C_DATA_WIDTH bit wide local register
       always @ (posedge clk) begin
           if (si_rdy) begin
               si_data_hold <= si_data;
           end
       end

       if ((C_DATA_WIDTH == 256) && (W == 128)) begin : g_strconv128to256
          // load data from 128-bit register into the 256-bit output register
          `ifdef ALTERA_FPGA
          (* noprune = 1 *)
          (* syn_preserve = 1 *)
          (* syn_keep = 1 *)
          `endif
	  reg l_so_data_sel;
	  always @ (*) begin
	      l_so_data_sel = c_frc_so_data_sel ? c_so_data_sel[0] : r_state[0];
	  end
          always @ (posedge clk) begin
              if (c_load_so_data) begin
                  case(l_so_data_sel) 
                      1'b0: so_data[127:0] <= si_data_hold;
                      1'b1: so_data[255:128] <= si_data_hold;
                  endcase
              end
          end
       end else if ((C_DATA_WIDTH == 128) && (W == 32)) begin : g_strconv32to128
          // load data from 32-bit register into the 128-bit output register
          always @ (posedge clk) begin
              if (c_load_so_data) begin
                  case(r_state[1:0]) 
                      2'h0: so_data[31:0] <= si_data_hold;
                      2'h1: so_data[63:32] <= si_data_hold;
                      2'h2: so_data[95:64] <= si_data_hold;
                      2'h3: so_data[127:96] <= si_data_hold;
                  endcase
              end
          end
       end else if ((C_DATA_WIDTH == 256) && (W == 32)) begin : g_strconv32to256
          // load data from 32-bit register into the 256-bit output register
          `ifdef ALTERA_FPGA
          (* noprune = 1 *)
          (* syn_preserve = 1 *)
          (* syn_keep = 1 *)
          `endif
	  reg [2:0] l_so_data_sel;
	  always @ (*) begin
	      l_so_data_sel = c_frc_so_data_sel ? c_so_data_sel[2:0] : r_state[2:0];
	  end
          always @ (posedge clk) begin
              if (c_load_so_data) begin
                  case(l_so_data_sel) 
                      3'h0: so_data[31:0] <= si_data_hold;
                      3'h1: so_data[63:32] <= si_data_hold;
                      3'h2: so_data[95:64] <= si_data_hold;
                      3'h3: so_data[127:96] <= si_data_hold;
                      3'h4: so_data[159:128] <= si_data_hold;
                      3'h5: so_data[191:160] <= si_data_hold;
                      3'h6: so_data[223:192] <= si_data_hold;
                      3'h7: so_data[255:224] <= si_data_hold;
                  endcase
              end
          end
       end else begin : g_invalid_strconv
          // Unsupported conversion
          always @ (posedge clk) begin
	     so_data <= 'hdeadbeef;
	     // synthesis translate_off
	     $display("ERROR: %m Unsupported Stream Width Conversion Parameters W = %d, C_DATA_WIDTH = %d @ time %t\n", W, C_DATA_WIDTH, $time);
	     // synthesis translate_on
          end
       end

       // FSM
       always @ (posedge clk) begin
           if (rst) begin
	       so_valid <= 1'b0;
	       so_ow_dvld <= {SO_OW_DVLD_W{1'b0}};
               r_state <= IDLE;
	       r_si_data_hold_vld <= 1'b0;
           end else begin
	       so_valid <= c_so_valid;
	       so_ow_dvld <= c_so_ow_dvld;
               r_state <= c_state;
	       r_si_data_hold_vld <= c_si_data_hold_vld;
           end
       end
   
       // next state logic
       always @ (*) begin
   
	   c_frc_so_data_sel = 1'b0;
	   c_so_data_sel = 'h0;
           si_rdy = 1'b0;
           c_so_valid = so_valid;
	   c_so_ow_dvld = so_ow_dvld;
           c_load_so_data = 1'b0;
           c_state = r_state;
	   c_si_data_hold_vld = r_si_data_hold_vld;
   
           case (r_state)
              
	       // Wait for D0 data's si_valid and then mark si_data_hold 
	       // register as valid
               IDLE: begin
		   si_rdy = 1'b1;
		   c_so_valid = 1'b0;
		   c_so_ow_dvld = {SO_OW_DVLD_W{1'b0}};
		   c_si_data_hold_vld = 1'b0;
                   if (si_valid) begin
                      c_state = LD_D0;
		      c_si_data_hold_vld = 1'b1;
                   end
               end

	       // Load D0 data into so_data register and wait for D1 data's
	       // si_valid and then mark si_data_hold register as valid
               LD_D0: begin
		   si_rdy = 1'b1;
		   c_load_so_data = r_si_data_hold_vld;
		   c_si_data_hold_vld = 1'b0;
		   // In 128 -> 256 case, we can't be assured any more data
		   // will be forthcoming. Therefore proceed to state D0
		   // regardless if si_valid is asserted. For other cases wait
		   // for si_valid
		   if (p_so_width256 && p_conv_width128) begin
		      c_state = D0; 
		      if (si_valid) begin
		         c_si_data_hold_vld = 1'b1;
		      end
		   end else if (si_valid) begin
                      c_state = D0;
		      c_si_data_hold_vld = 1'b1;
                   end
               end

	       // Load D1 data into so_data register and either
	       // We immediately set so_valid and transition to D1, if we're 
	       // doing 128b -> 256b, since we'll have both D0 & D1 loaded into 
	       // the so_data register. We also record if we have the next 
	       // D0 data held.
	       // Or we wait for D2 data's si_valid and then mark si_data_hold 
	       // register as valid
               D0: begin
		   si_rdy = 1'b1;
		   c_load_so_data = r_si_data_hold_vld;
		   c_si_data_hold_vld = 1'b0;
		   if (p_so_width256 && p_conv_width128) begin
                      c_state = D1;
		      c_so_valid = 1'b1;
		      c_so_ow_dvld[UPPER_OW_DVLD_B] = r_si_data_hold_vld;
		      c_so_ow_dvld[0] = 1'b1;
		      if (si_valid) begin
			 c_si_data_hold_vld = 1'b1;
		      end
		   end else if (si_valid) begin
                      c_state = D1;
		      c_si_data_hold_vld = 1'b1;
                   end
               end

               D1: begin
		   if (p_so_width256 && p_conv_width128) begin
		      if (so_rdy) begin
			 // We'll transition to D0, LD_D0, or IDLE based on
			 // whether we have the next D0 latched and if
			 // si_valid is currently asserted
			 c_state = r_si_data_hold_vld ? (si_valid ? D0 : LD_D0) : (si_valid ? LD_D0 : IDLE);
		         c_so_valid = 1'b0;
			 c_so_ow_dvld = {SO_OW_DVLD_W{1'b0}};
		         si_rdy = 1'b1;
			 // Load next D0 data into so_data register if si_data_hold
			 // register is valid
		         c_load_so_data = r_si_data_hold_vld;
			 c_si_data_hold_vld = 1'b0;
			 // Mark the si_data_hold register as valid if si_valid is
			 // asserted
			 if (si_valid) begin
			    c_si_data_hold_vld = 1'b1;
			 end
		      end else begin
			 // Only allow si_rdy if the next D0 isn't latched OR
			 // if we don't have the 2nd octa-word valid flag set, if
			 // we get an si_valid in either case mark si_data_hold 
			 // register as valid
			 if (!r_si_data_hold_vld || !so_ow_dvld[UPPER_OW_DVLD_B]) begin
			    // If we load_so_data we must force the mux select
			    c_frc_so_data_sel = 1'b1;
			    c_so_data_sel[0] = 1'b1;
			    // clear data_hold_vld if we're just loading ow_dvld[1]
			    c_si_data_hold_vld = 1'b0;
		            si_rdy = 1'b1;
			    if (si_valid) begin
			       c_si_data_hold_vld = 1'b1;
			    end
			    if (r_si_data_hold_vld) begin
			       c_load_so_data = 1'b1;
			       c_so_ow_dvld[UPPER_OW_DVLD_B] = 1'b1;
			    end
			 end
		      end
	           // The generic case, load D2 data into so_data register 
		   // and wait for D3 data's si_valid and then mark
		   // si_data_hold register as valid
		   end else begin
		      si_rdy = 1'b1;
		      c_load_so_data = r_si_data_hold_vld;
		      c_si_data_hold_vld = 1'b0;
		      if (si_valid) begin
                         c_state = D2;
		         c_si_data_hold_vld = 1'b1;
                      end
		   end
               end

	       // Load D3 data into so_data register and either
	       // We immediately set so_valid and transition to D3, if we're 
	       // doing 32b -> 128b, since we'll have D0, D1, D2 & D3 loaded into 
	       // the so_data register. We also record if we have the next 
	       // D0 data held.
	       // Else we're in the 32b -> 256 case. In which case we can't
	       // know if we'll ever get another si_valid. Therefore we
	       // transition through the following states with
	       // so_ow_dvld[1]==0 not waiting on si_valid. That is unless we 
	       // ever get a si_valid. In which case we can assume we'll get a 
	       // total of 4 more si_valids.
               D2: begin
		   si_rdy = 1'b1;
		   c_load_so_data = r_si_data_hold_vld;
		   c_si_data_hold_vld = 1'b0;
		   if (p_so_width128 && p_conv_width32) begin
                      c_state = D3;
		      c_so_valid = 1'b1;
		      if (si_valid) begin
			 c_si_data_hold_vld = 1'b1;
		      end
		   end else begin
                      c_state = D3;
		      if (si_valid) begin
		         c_si_data_hold_vld = 1'b1;
		      end
                   end
               end

               D3: begin
		   if (p_so_width128 && p_conv_width32) begin
		      if (so_rdy) begin
			 // We'll transition to D0, LD_D0, or IDLE based on
			 // whether we have the next D0 latched and if
			 // si_valid is currently asserted
			 c_state = r_si_data_hold_vld ? (si_valid ? D0 : LD_D0) : (si_valid ? LD_D0 : IDLE);
		         c_so_valid = 1'b0;
		         si_rdy = 1'b1;
			 // Load next D0 data into so_data register if si_data_hold
			 // register is valid
		         c_load_so_data = r_si_data_hold_vld;
			 c_si_data_hold_vld = 1'b0;
			 // Mark the si_data_hold register as valid if si_valid is
			 // asserted
			 if (si_valid) begin
			    c_si_data_hold_vld = 1'b1;
			 end
		      end else begin
			 // Only allow si_rdy if the next D0 isn't latched, if
			 // we get an si_valid in this case mark si_data_hold 
			 // register as valid
			 if (!r_si_data_hold_vld) begin
		            si_rdy = 1'b1;
			    if (si_valid) begin
			       c_si_data_hold_vld = 1'b1;
			    end
			 end
		      end
	           // The 32b -> 256b case
		   end else begin
		      c_so_ow_dvld[0] = 1'b1;
		      si_rdy = 1'b1;
	              // load D4 data (if held) into so_data register 
		      c_load_so_data = r_si_data_hold_vld;
		      c_si_data_hold_vld = 1'b0;
                      // If so_ow_dvld[1] is set we know we need to wait for
                      // all 4 pieces of the 2nd octa-word
		      if (so_ow_dvld[UPPER_OW_DVLD_B]) begin
		         // must wait for remaining si_valids
			 if (si_valid) begin
			    c_state = D4;
			    c_si_data_hold_vld = 1'b1;
			 end
		      // Else check if si_valid is asserted, if so that means
		      // we will get 4 more pieces of 32b data. 
		      end else if (si_valid) begin
			 c_so_ow_dvld[UPPER_OW_DVLD_B] = 1'b1;
			 c_si_data_hold_vld = 1'b1;
			 // If r_si_data_hold_vld is not set we need to
			 // re-enter D3 state with r_si_data_hold_vld set.
			 if (!r_si_data_hold_vld) begin
			    c_state = D3; // re-enter state D3 with ow_dvld[1] set
			 // Otherwise we just wrote D4 data and should proceed
			 // on with the ow_dvld[1] set.
			 end else begin
			    c_state = D4; // continue on, we've just loaded D4
			 end
		      // Else check if r_si_data_hold_vld is asserted, if so
		      // that still means we will get 4 more pieces of data.
		      // In that case just re-enter state D3 with
		      // r_si_data_hold_vld clear and ow_dvld[1] set and wait
		      // for the next si_valid. 
		      // Otherwise just keep transitioning states.
		      end else begin	// !si_valid
		         if (r_si_data_hold_vld) begin
			    c_state = D3; // re-enter state D3 with ow_dvld[1] set and wait for si_valid
			    c_so_ow_dvld[UPPER_OW_DVLD_B] = 1'b1;
			 end else begin
			    c_state = D4; // continue on, we may not get another si_valid
			 end
		      end
		   end
               end

	       // We must be in the 32b -> 256b stream conversion.
	       D4: begin
		  si_rdy = 1'b1;
		  c_load_so_data = r_si_data_hold_vld;
		  c_si_data_hold_vld = 1'b0;
                  // If so_ow_dvld[1] is set we know we need to wait for
                  // all 4 pieces of the 2nd octa-word
		  if (so_ow_dvld[UPPER_OW_DVLD_B]) begin
		      // must wait for remaining si_valids
		      if (si_valid) begin
			  c_state = D5;
			  c_si_data_hold_vld = 1'b1;
		      end
		  // Else check if si_valid is asserted, if so that means
		  // we will get 4 more pieces of 32b data. Just re-enter
		  // state 3 with r_si_data_hold_vld & ow_dvld[1] set.
		  // Otherwise just keep transitioning states.
		  end else if (si_valid) begin
		      c_so_ow_dvld[UPPER_OW_DVLD_B] = 1'b1;
		      c_si_data_hold_vld = 1'b1;
		      c_state = D3; // re-enter state D3 with r_si_data_hold_vld & ow_dvld[1] set
		  end else begin	// !si_valid
		      c_state = D5; // continue on, we may not get another si_valid
		  end
	       end

	       // We must be in the 32b -> 256b stream conversion.
	       // Load D6 data into so_data register and wait for D7 data's
	       // si_valid
	       D5: begin
		  si_rdy = 1'b1;
		  c_load_so_data = r_si_data_hold_vld;
		  c_si_data_hold_vld = 1'b0;
                  // If so_ow_dvld[1] is set we know we need to wait for
                  // all 4 pieces of the 2nd octa-word
		  if (so_ow_dvld[UPPER_OW_DVLD_B]) begin
		      // must wait for remaining si_valids
		      if (si_valid) begin
			  c_state = D6;
			  c_si_data_hold_vld = 1'b1;
		      end
		  // Else check if si_valid is asserted, if so that means
		  // we will get 4 more pieces of 32b data. Just re-enter
		  // state 3 with r_si_data_hold_vld & ow_dvld[1] set.
		  // Otherwise just keep transitioning states.
		  end else if (si_valid) begin
		      c_so_ow_dvld[UPPER_OW_DVLD_B] = 1'b1;
		      c_si_data_hold_vld = 1'b1;
		      c_state = D3; // re-enter state D3 with r_si_data_hold_vld & ow_dvld[1] set
		  end else begin	// !si_valid
		      c_state = D6; // continue on, we may not get another si_valid
		  end
	       end

	       // We must be in the 32b -> 256b stream conversion.
	       // Load D7 data into so_data register and immediately 
	       // set so_valid and transition to D7 since we'll have 
	       // D0-D7 loaded into the so_data register. We also record 
	       // if we have the next D0 data held.
               D6: begin
		  si_rdy = 1'b1;
		  c_load_so_data = r_si_data_hold_vld;
		  c_si_data_hold_vld = 1'b0;
                  // If so_ow_dvld[1] is set we know we need to wait for
                  // all 4 pieces of the 2nd octa-word
		  if (so_ow_dvld[UPPER_OW_DVLD_B]) begin
		      c_state = D7;
		      c_so_valid = 1'b1;
		      if (si_valid) begin
			  c_si_data_hold_vld = 1'b1;
		      end
		  // Else check if si_valid is asserted, if so that means
		  // we will get 4 more pieces of 32b data. Just re-enter
		  // state 3 with r_si_data_hold_vld & ow_dvld[1] set.
		  // Otherwise just keep transitioning states.
		  end else if (si_valid) begin
		      c_so_ow_dvld[UPPER_OW_DVLD_B] = 1'b1;
		      c_si_data_hold_vld = 1'b1;
		      c_state = D3; // re-enter state D3 with r_si_data_hold_vld & ow_dvld[1] set
		  end else begin	// !si_valid
		      c_state = D7; // continue on, we may not get another si_valid
		      c_so_valid = 1'b1;
		  end
               end

               D7: begin
		   if (so_rdy) begin
		      // We'll transition to D0, LD_D0, or IDLE based on
		      // whether we have the next D0 latched and if
		      // si_valid is currently asserted
		      c_state = r_si_data_hold_vld ? (si_valid ? D0 : LD_D0) : (si_valid ? LD_D0 : IDLE);
		      c_so_valid = 1'b0;
		      c_so_ow_dvld = {SO_OW_DVLD_W{1'b0}};
		      si_rdy = 1'b1;
		      // Load next D0 data into so_data register if si_data_hold
		      // register is valid
		      c_load_so_data = r_si_data_hold_vld;
		      c_si_data_hold_vld = 1'b0;
		      // Mark the si_data_hold register as valid if si_valid is
		      // asserted
		      if (si_valid) begin
			 c_si_data_hold_vld = 1'b1;
		      end
		   end else begin
                      // Only allow si_rdy if the next D0 isn't latched, if
                      // we get an si_valid in this case mark si_data_hold 
                      // register as valid. 
                      // Note we can't just back to earlier states here to
                      // collect the 2nd octa-word because we've already set
                      // so_valid.
                      if (!r_si_data_hold_vld) begin
                         si_rdy = 1'b1;
                         if (si_valid) begin
                            c_si_data_hold_vld = 1'b1;
                         end
                      end
                   end
               end

               // should never enter this state
               default: begin
                   c_state = IDLE;
               end
           endcase
       end
    end endgenerate
    
endmodule 
