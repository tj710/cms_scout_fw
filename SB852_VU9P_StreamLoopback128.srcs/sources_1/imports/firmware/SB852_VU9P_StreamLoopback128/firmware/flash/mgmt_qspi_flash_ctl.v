/*****************************************************************************/
//
// Module          : mgmt_qspi_flash_ctl.v
//
//-----------------------------------------------------------------------------
//
// Description  : MGMT Block Quad spi configuration flash controller
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2017 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
/*****************************************************************************/

//
// Flash Ctl Revision -- listed in Dispatch VERSION_INFO CSR
//  0 : initial flash ctl
//  1 : added 256Byte buffered write capability
//  

module mgmt_qspi_flash_ctl (
 //
 // Globals
 //
 input         spi_clk_2x, // spi_clk_2x -- 125mhz
 input 	       reset,

 //
 // mgmt_top MMIO interface
 //
 input 	      qspi_rq_val,
 input 	      rq_rnw,
 input [11:0]  rq_addr,
 input [63:0]  rq_data,

 output        qspi_rs_val,
 output        qspi_rs_timeout,
 output        qspi_rs_busy,
 output [63:0] qspi_rs_data

 // MGMT QSPI flash interface
 // This is all internally connected via the xilinx STARTUPE3 block
 //
);

   //
   // Declarations 
   //
   reg            c_qspi_rs_val;
   reg            r_qspi_rs_val;
   reg            rr_qspi_rs_val;
   reg            c_qspi_rs_busy;
   reg            r_qspi_rs_busy;
   reg            c_qspi_rs_timeout;
   reg            r_qspi_rs_timeout;
   reg  [63:0]    c_qspi_rs_data;
   reg  [63:0]    r_qspi_rs_data;
    
(* mark_debug = "true" *)   reg  [63:0]    r_qspi_rd_data;
   wire  [63:0]    c_qspi_wr_data;
   reg  [63:0]    r_qspi_wr_data;
   reg  [31:0]    c_qspi_addr;
   reg  [31:0]    r_qspi_addr;
                                
   reg  [7:0]     c_qspi_cmd;
   reg  [7:0]     r_qspi_cmd;
   reg            c_qspi_rst_fifo;
   reg            r_qspi_rst_fifo;
   reg  [15:0]    c_qspi_len;
   reg  [15:0]    r_qspi_len;
   wire           c_qspi_xfer_in_prog;
   reg            r_qspi_xfer_in_prog;
   reg            c_qspi_access_done;
   reg            r_qspi_access_done;
   
   reg [3:0]      c_flash_dout;
   reg [7:0]      c_flash_cmd;
   reg [3:0]      c_flash_din;
    
   reg [3:0]      r_flash_dout;
   reg [7:0]      r_flash_cmd;
   reg [3:0]      r_flash_din;
       
   
   reg c_push_wr_buffer;
   reg c_qspi_cmd_val;
   reg r_qspi_cmd_val;
   reg r_qspi_mode;
   reg c_qspi_mode;
  
   wire        cfg_flash_ss_f_b;
   wire        cfg_flash_ss_tri;
   wire [3:0]  cfg_flash_data_out;
   wire        cfg_flash_data_tri;
  
(* mark_debug = "true" *)   wire [3:0]  cfg_flash_data_in;
   reg  c_flash_ss_f;
   reg  r_flash_ss_f;
   reg  c_flash_ss_tri;
   reg  r_flash_ss_tri;
    
   reg  r_flash_data_tri;
   reg  c_flash_data_tri;
   
   reg   [3:0]    c_flash_dq;
   reg   [3:0]    r_flash_dq;
   reg   [2:0]    c_bit_cnt;
   reg   [2:0]    r_bit_cnt;
   reg   [2:0]    c_byte_num;
   reg   [2:0]    r_byte_num;
   reg   [10:0]   c_shift_cnt;
   reg   [10:0]   r_shift_cnt;
   wire  [5:0]    c_adj_shft_cnt;
   reg   [5:0]    r_adj_shft_cnt;
   reg   [4:0]    c_word_num;
   reg   [4:0]    r_word_num;
   reg   [1:0]    c_idle_count;
   reg   [1:0]    r_idle_count;
   reg   [3:0]    r_qspi_state;
   reg   [3:0]    c_qspi_state;
   reg   [4:0]    r_flash_state;
   reg   [4:0]    c_flash_state;
   reg   [1:0]    c_cmd_fmt,r_cmd_fmt;
   reg   [1:0]    c_cmd_type,r_cmd_type;
   reg   [3:0]    c_cmd_dummy_clks,r_cmd_dummy_clks;
   reg   [3:0]    c_pgmd_dummy_clks,r_pgmd_dummy_clks; 
   reg   [55:0]   c_spi_word,r_spi_word;
   reg            c_spi_clk, spi_clk;
   reg            c_spi_cmd_crack_state,r_spi_cmd_crack_state;

   //FIXME: change these to CSR controlled values
   localparam STR_DUMMY_CLK = 4'd14,
              DTR_DUMMY_CLK = 4'd14;

   // READ/WRITE from MMIO states
   localparam RQ_RCV_IDLE      = 4'd0,
              RQ_RCV_READ      = 4'd1,
              RQ_RCV_READ2     = 4'd2,
              RQ_RCV_FINISH    = 4'd3,
              RQ_RCV_FINISH2   = 4'd4,
              RQ_RCV_RDERR     = 4'd5,
              RQ_RCV_ERROR     = 4'd6,
              RQ_RCV_CHECK_FLASH_DONE = 4'd7,
              RQ_RCV_CHECK_FLASH_WAIT  = 4'd8;
   
   // MMIO CSR names
   localparam QSPI_CMD         = 9'd0,
              QSPI_ADDR        = 9'd1,
              QSPI_STATUS      = 9'd2,
              QSPI_RD_DATA     = 9'd3,
              QSPI_WR_DATA     = 9'd4;
 
   // FLASH controller states - r_flash_state
   localparam  FLASH_IDLE                 =  3'd0,
               FLASH_IDLE2                =  3'd1,
               FLASH_CMD_DONE             =  3'd2, // Raise SS#
               FLASH_BUILD_SPI_WORD       =  3'd3, // combine spi_cmd,addr,dummyClks,dataClks
               FLASH_SHIFT_SPI_WORD       =  3'd4,
               FLASH_DATA_SHIFT           =  3'd5,
               FLASH_RD_DUMMY_CLKS        =  3'd6,
               FLASH_SPI_ERROR            =  3'd7;

   // FLASH controller CMD codes supported
   localparam  RESET_ENABLE                        = 8'h66,
               RESET_MEMORY                        = 8'h99,
               MULTI_IO_READ_ID                    = 8'hAF,
               BYTE4_FAST_RD                       = 8'h0C,
               PAGE_PROGRAM                        = 8'h02,
               BYTE4_PAGE_PROGRAM                  = 8'h12,
               BYTE4_QUAD_IO_FAST_RD               = 8'hEC,
               BYTE4_DTR_QUAD_IO_FAST_RD           = 8'hEE,
               QUAD_INPUT_FAST_PROGRAM             = 8'h32,
               BYTE4_QUAD_INPUT_EXT_FAST_PROGRAM   = 8'h3E,
               WRITE_ENABLE                        = 8'h06,
               READ_NONVOLATILE_CFG_REG            = 8'hB5,
               READ_VOLATILE_CFG_REG               = 8'h85,
               READ_ENHANCED_VOLATILE_CFG_REG      = 8'h65,
               READ_GENERAL_PURPOSE_RD_REG         = 8'h96,
               WRITE_NONVOLATILE_CFG_REG           = 8'hB1,
               WRITE_VOLATILE_CFG_REG              = 8'h81,
               WRITE_ENHANCED_VOLATILE_CFG_REG     = 8'h61,
               CLEAR_FLAG_STATUS_REG               = 8'h50,
               DIE_ERASE                           = 8'hC4,
               BYTE4_SECTOR_ERASE                  = 8'hDC,
               BYTE4_SECTOR_ERASE2                 = 8'hD8,  //DAA added for N25Q256
               BYTE4_4KB_SUBSECTOR_ERASE           = 8'h21,
               BYTE4_32KB_SUBSECTOR_ERASE          = 8'h5C,
               READ_SERIAL_FLASH_DISC_PARAM        = 8'h5A,
               READ_FLAG_STATUS_REGISTER           = 8'h70,
               READ_STATUS_REGISTER                = 8'h05;
                 
   localparam  CMD_IDLE    = 1'd0,
               CMD_DECODE  = 1'd1;

   // cmd format
   localparam  CMD_ONLY       = 2'd0,
               CMD_DATA_ONLY  = 2'd1,
               CMD_FULL       = 2'd2;

   // cmd type
   localparam  CMD_RD         = 2'd0,
               CMD_WR         = 2'd1,
               CMD_ERASE      = 2'd2,
               CMD_CMD        = 2'd3;

  //
  // local register access/response state machine
  //
  always @(*) begin
      if (reset) begin
         c_qspi_rs_val = 1'b0;
         c_qspi_rs_busy = 1'b0;
         c_qspi_rs_timeout = 1'b0;
         c_qspi_rs_data = 64'b0;
         c_qspi_state = RQ_RCV_IDLE;
         c_qspi_addr = 32'd0;
         c_qspi_cmd_val = 1'b0;
         c_qspi_cmd = 8'd0; 
         c_qspi_rst_fifo = 1'd0;
         c_qspi_len = 16'd0;
         c_qspi_access_done = 1'd0;
         c_qspi_mode = 1'b0;
         c_pgmd_dummy_clks = 4'd0; 
         c_push_wr_buffer = 1'b0;
      end else begin
         c_qspi_rs_val = r_qspi_rs_val; 
         c_qspi_rs_busy = r_qspi_rs_busy;
         c_qspi_rs_timeout = r_qspi_rs_timeout;
         c_qspi_rs_data = r_qspi_rs_data;
         c_qspi_state = r_qspi_state;
         c_qspi_addr = r_qspi_addr;
         c_qspi_cmd_val = r_qspi_cmd_val;
         c_qspi_cmd = r_qspi_cmd; 
         c_qspi_rst_fifo = r_qspi_rst_fifo;
         c_qspi_len = r_qspi_len;
         c_qspi_access_done = r_qspi_access_done;
         c_qspi_mode = r_qspi_mode;
         c_pgmd_dummy_clks = r_pgmd_dummy_clks; 
         c_push_wr_buffer = 1'b0;

          case (r_qspi_state)
              RQ_RCV_IDLE:  begin
                  if (qspi_rq_val) begin
                      c_qspi_rs_busy = 1'b1;
                      if (rq_rnw) begin // read register case
                        case (rq_addr[11:3])
                            QSPI_CMD: begin
                                c_qspi_rs_data = {r_qspi_len,16'd0,r_pgmd_dummy_clks,3'd0,r_qspi_rst_fifo,r_qspi_cmd};
                                c_qspi_state = RQ_RCV_READ;
                            end
                            QSPI_ADDR: begin
                                c_qspi_rs_data = {32'd0,r_qspi_addr};
                                c_qspi_state = RQ_RCV_READ;
                            end
                            QSPI_STATUS: begin
                                c_qspi_rs_data = {55'd0,r_qspi_mode,6'd0,r_qspi_xfer_in_prog, r_qspi_access_done};
                                c_qspi_state = RQ_RCV_READ;
                            end
                            QSPI_RD_DATA: begin
                                c_qspi_rs_data = r_qspi_rd_data; 
                                c_qspi_state = RQ_RCV_READ; 
                            end
                            QSPI_WR_DATA: begin
                                // Write ONLY 
                                c_qspi_state = RQ_RCV_READ;
                            end
                            default: begin
                                c_qspi_state = RQ_RCV_RDERR; 
                                c_qspi_rs_data = 64'hffff_ffff_ffff_ffff;
                                c_qspi_rs_timeout = 1'b1;
                            end
                        endcase         // rq_addr
                      end else begin   
                        // write case 
                        case (rq_addr[11:3])
                            QSPI_CMD: begin
                                c_qspi_cmd = rq_data[7:0]; 
                                c_qspi_rst_fifo = rq_data[8];
                                c_pgmd_dummy_clks = rq_data[15:12];
                                c_qspi_len = rq_data[47:32];
                                c_qspi_state = RQ_RCV_CHECK_FLASH_WAIT;
                                c_qspi_cmd_val = 1'b1;
                            end
                            QSPI_ADDR: begin
                                c_qspi_addr = rq_data[31:0]; 
                                c_qspi_state = RQ_RCV_FINISH;
                            end
                            QSPI_STATUS: begin 
                                 // READ ONLY , except for
                                c_qspi_mode = rq_data[8];
                                c_qspi_state = RQ_RCV_FINISH;
                            end
                            QSPI_RD_DATA: begin // READ ONLY register
                                c_qspi_state = RQ_RCV_FINISH; 
                            end
                            QSPI_WR_DATA: begin
                                c_push_wr_buffer = 1'b1;
                                c_qspi_state = RQ_RCV_FINISH;
                            end
                            default: begin
                                c_qspi_state = RQ_RCV_ERROR;
                                c_qspi_rs_timeout = 1'b1;
                            end
                        endcase // rq_addr
                      end
                  end
              end // RQ_RCV_IDLE
              RQ_RCV_READ: begin
                  c_qspi_rs_val = 1'b1;
                  c_qspi_state = RQ_RCV_READ2;
              end
              RQ_RCV_READ2: begin
                  c_qspi_rs_val = 1'b0;
                  c_qspi_state = RQ_RCV_FINISH;
              end
              RQ_RCV_CHECK_FLASH_WAIT: begin
                  if (r_qspi_xfer_in_prog) begin
                     c_qspi_state = RQ_RCV_CHECK_FLASH_DONE;
                  end else begin
                    c_qspi_state = RQ_RCV_CHECK_FLASH_WAIT;
                  end
               end
              RQ_RCV_CHECK_FLASH_DONE: begin
                  if (!r_qspi_xfer_in_prog) begin
                     // only for a RD_TYPE will we issue a RS_VAL back to
                     // PCIE, all other types, CMD-only, CMD-WR, etc we just
                     // finish the txn w/o issuing a PCIE rs.
                     //c_qspi_state = (r_cmd_type==CMD_RD) ? RQ_WAIT_READ : RQ_RCV_FINISH;
                     //
                     // For ALL SPI txns we will respond w/o a rs_val as they
                     // were orginated by CSR-WRITES which don't get rs_val.
                     c_qspi_state = RQ_RCV_FINISH;
                     c_qspi_cmd_val = 1'b0;
                  end else begin
                    c_qspi_state = RQ_RCV_CHECK_FLASH_DONE;
                  end
               end
              RQ_RCV_FINISH: begin
                  c_qspi_rs_busy = 1'b0;
                  c_qspi_state = RQ_RCV_FINISH2;
              end
              RQ_RCV_FINISH2: begin
                  c_qspi_rs_busy = 1'b0;
                  c_qspi_state = RQ_RCV_IDLE;
              end
              RQ_RCV_RDERR: begin
                  c_qspi_rs_val = 1'b1;
                  c_qspi_rs_timeout = 1'b1;
                  c_qspi_state = RQ_RCV_ERROR;
              end
              RQ_RCV_ERROR: begin
                  c_qspi_rs_busy = 1'b0;
                  c_qspi_rs_val = 1'b0;
                  c_qspi_rs_timeout = 1'b0;
                  c_qspi_state = RQ_RCV_IDLE;
              end
              default: begin
                  c_qspi_rs_val = 1'b0;
                  c_qspi_rs_busy = 1'b0;
                  c_qspi_rs_timeout = 1'b0;
                  c_qspi_state = RQ_RCV_IDLE;
              end
          endcase        
      end
  end


   wire [63:0] r_wbuff_dout;   
   reg  [4:0]  r_wbuff_wadr,r_wbuff_radr;
   wire [4:0]  c_wbuff_wadr,c_wbuff_radr;
   // 
   // Simple Dual Port RAM for storing data bits
   // to be sent during a WRITE ACCESS.
   //
   // This is not a smart WR-BUFFER, it will always start
   // at wadr==0, and increment for every wr to QSPI_WR_DATA
   // until a write to QSPI_CMD occurs launching a txn. 
   //
   // Upon a SPI_TXN completion, the wadr returns to 0.
   //
   sdpram #(.WIDTH(64),.DEPTH(32)) wr_buffer ( 
      .clk        (spi_clk_2x),
      .wadr       (r_wbuff_wadr),
      .din        (rq_data[63:0]),
      .we         (c_push_wr_buffer),
      .radr       (r_wbuff_radr),
      .ce         (1'b1),
      .oreg_ce    (1'b1),
      .oreg_rst   (1'b0),
      .dout       (r_wbuff_dout)
   );

   wire flash_cmd_done = (r_flash_state==FLASH_CMD_DONE);

   assign c_wbuff_wadr = c_push_wr_buffer ? (r_wbuff_wadr + 5'h1) : r_wbuff_wadr;
   
   assign c_wbuff_radr = flash_cmd_done ? 5'h0 :
                           (r_qspi_mode ? (((r_flash_state==FLASH_DATA_SHIFT)&&(r_byte_num==3'd0)&&(r_bit_cnt==3'd4)) ? 
                              (r_wbuff_radr + 5'h1) : r_wbuff_radr) : 
                           ((r_flash_state==FLASH_DATA_SHIFT)&&(r_byte_num==3'd0)&&(r_bit_cnt==3'd5) ? 
                              (r_wbuff_radr + 5'h1) : r_wbuff_radr));

   assign c_qspi_wr_data = r_wbuff_dout;
  

   //
   // Xilinx Startupe3 block to access config pins
   // This block has ALL the necessary SPI config output pins, 
   // so we dont need to wire anything up external to this block, 
   // aside from our PCIE RQ/RS bus.
   //
  STARTUPE3 cfg_if (
     // Outputs
     .CFGCLK	(_nc0_),
     .CFGMCLK	(_nc1_),
     .EOS	   (_nc2_),
     .PREQ	   (_nc3_),
     .DI	      (cfg_flash_data_in[3:0]),    // flash data in
     // Inputs
     .DO	      (cfg_flash_data_out[3:0]),     // flash data out
     .DTS	   ({4{cfg_flash_data_tri}}), // flash data out tristate enable
     .FCSBO	   (cfg_flash_ss_f_b),        // flash chip enable/select 
     .FCSBTS   (cfg_flash_ss_tri),        // flash chip enable/select tristate 
     .GSR	   (1'b0),
     .GTS	   (1'b0),
     .KEYCLEARB(1'b1),
     .PACK	   (1'b1),
     .USRCCLKO	(spi_clk),                // Free-Running SCK phase shifted so CMD inputs will be latched on rising edge
     .USRCCLKTS(1'b0),                    // tristate enable, always drive SCK
     .USRDONEO	(1'b1),
     .USRDONETS(1'b0)
  );

  //
  // QSPI Flash controller logic 
  //

  // 64 bit data word OR {8bit CMD, 32bit addr, 15dummycycles}=55 bits, so 64
  // bit vector is large enough to store either
  wire [63:0] data_out = ((r_shift_cnt==11'd0) && (r_cmd_type==CMD_WR)) ? r_qspi_wr_data : {8'd0,r_spi_word};
  
  wire [11:0] sel_shift_cnt = ((r_shift_cnt==11'd0) && (r_cmd_type==CMD_WR) && (r_qspi_len==16'd256)) ? c_adj_shft_cnt : c_shift_cnt;


   // Currently runs at spi_clk_2x which is 125Mhz when in hix 250mhz mode,
   // 100MHz when in hix 400Mhz mode             
  always @(*) begin
      if (reset) begin
         c_flash_ss_f = 1'b1;
         c_flash_ss_tri = 1'b0; // driving
         c_flash_data_tri = 1'b0;  // 0 to drive the data pins
         c_shift_cnt = 11'h0;
         c_word_num = 5'd31;
         c_byte_num = 3'h7;
         c_bit_cnt = 3'd0;
         c_idle_count = 2'd1;
         c_flash_state = FLASH_IDLE;
         c_flash_dq = 4'h1;
         c_flash_din = 4'd0;
         c_spi_word = 56'd0;
	      c_spi_clk = 1'b0;
      end else begin
         c_flash_din = 4'd0;
         c_flash_ss_f = r_flash_ss_f;
         c_flash_ss_tri = r_flash_ss_tri;
         c_flash_data_tri = r_flash_data_tri;
         c_shift_cnt = r_shift_cnt; 
         c_word_num = r_word_num;
         c_bit_cnt = r_bit_cnt;
         c_byte_num = r_byte_num;
         c_idle_count = r_idle_count; 
         c_flash_state = r_flash_state;
         c_flash_dq = r_flash_dq; 
         c_spi_word = r_spi_word;
	      c_spi_clk = ~spi_clk;
          
         case (r_flash_state)
            FLASH_IDLE:  begin   // Ensures we wait a few clocks between flash transactions         
               c_flash_state = (r_idle_count > 2'd0) ? FLASH_IDLE : FLASH_IDLE2;
               c_idle_count = (r_idle_count > 2'd0) ? r_idle_count - 2'd1 : 2'd1;
               c_flash_ss_f = 1'b1;
               c_flash_ss_tri = 1'b0;
               c_flash_dq = 4'hf;
               c_flash_data_tri = 1'b1; // dont drive, let the pullups pull hold pins high 
               c_byte_num = 3'd7;
               c_bit_cnt = 3'd0;
            end
            FLASH_IDLE2:  begin  // Wait here until we see a write to the SPI_CMD register (sets qspi_cmd_val)
               c_flash_state = (r_qspi_cmd_val & !r_qspi_xfer_in_prog) ? FLASH_BUILD_SPI_WORD : FLASH_IDLE2; 
               c_flash_ss_f = 1'b1;
               c_flash_ss_tri = 1'b0;
               c_flash_dq = 4'hf;
               c_flash_data_tri = 1'b1; // dont drive, let the pullups pull hold pins high 
            end
            FLASH_CMD_DONE: begin       
               c_flash_state = FLASH_IDLE;
               c_flash_ss_f = 1'b1; // RAISE the slave select line, ending the txn
               c_flash_ss_tri = 1'b0;
               c_flash_dq = 4'hf;
               c_flash_data_tri = 1'b1; // dont drive, let the pullups pull hold pins high 
            end
            FLASH_BUILD_SPI_WORD: begin // combine spi_cmd,addr,dummyClks,dataClks
               c_flash_state = FLASH_SHIFT_SPI_WORD;
               c_spi_word =   (r_cmd_fmt==CMD_ONLY) ?       {r_qspi_cmd} : // CMD_ONLY
                              ((r_cmd_fmt==CMD_DATA_ONLY) ? {r_qspi_cmd} : // CMD_DATA_ONLY
                                                            {r_qspi_cmd,r_qspi_addr});
               c_shift_cnt =  r_qspi_mode ? 
                                 ((r_cmd_fmt==CMD_ONLY) ?     11'd8 : // 8 clks
                                 ((r_cmd_fmt==CMD_DATA_ONLY) ? 11'd8 : 11'd40)) :
                                 (
                                 (r_cmd_fmt==CMD_ONLY) ?     11'd8 : // 8 clks
                                 ((r_cmd_fmt==CMD_DATA_ONLY) ? 11'd8 : 11'd40)); 
            end
            FLASH_SHIFT_SPI_WORD: begin      // Drop SS and shift 
               c_flash_state = ((r_shift_cnt==11'd0)&&((r_cmd_fmt==CMD_ONLY)||(r_cmd_type==CMD_ERASE))) ? FLASH_CMD_DONE : 
                               ((r_shift_cnt==11'd0)&&(r_cmd_type==CMD_RD)&&(r_cmd_fmt==CMD_FULL)) ? FLASH_RD_DUMMY_CLKS :
                               (r_shift_cnt==11'd0) ? FLASH_DATA_SHIFT : FLASH_SHIFT_SPI_WORD;
               // drop SS as we start the txn, but raise it as we transition
               // to the IDLE state
               c_flash_ss_f = ((r_shift_cnt==11'd0)&&((r_cmd_fmt==CMD_ONLY)||(r_cmd_type==CMD_ERASE))) ? 1'b1 :1'b0; 
               c_flash_ss_tri = 1'b0;
               c_shift_cnt = (r_shift_cnt > 11'd0) ? 
                              (r_qspi_mode ? (r_shift_cnt - 11'd4) : (r_shift_cnt - 11'd1)) : 
                             ((r_shift_cnt == 11'd0)&&(r_cmd_type==CMD_RD)&&(r_cmd_fmt==CMD_FULL)) ? 
                              (r_qspi_mode ? (r_pgmd_dummy_clks-32'd1) : (r_pgmd_dummy_clks-32'd1)) :
                             (r_shift_cnt == 11'd0) ? 
                              (r_qspi_mode ? (r_qspi_len*16'd8-16'd4) : (r_qspi_len*16'd8-16'd1)) :
                              r_shift_cnt ;

               // we only support 256 or 8 byte WRs
               c_word_num = ((r_cmd_type==CMD_WR)&&(r_qspi_len==16'd256)) ? 5'd31 : 5'd0;
               // need the adjusted_shift count for the transition on a 256B WR
               c_flash_dq[3] = r_qspi_mode ? (data_out >> (sel_shift_cnt+11'd3)) & 11'h01   : 1'b1; // get MSB
               c_flash_dq[2] = r_qspi_mode ? (data_out >> (sel_shift_cnt+11'd2)) & 11'h01   : 1'b1; 
               c_flash_dq[1] = r_qspi_mode ? (data_out >> (sel_shift_cnt+11'd1)) & 11'h01   : 1'b1; 
               c_flash_dq[0] = r_qspi_mode ? (data_out >> (sel_shift_cnt)) & 11'h01   : 
                                             (data_out >> (sel_shift_cnt)) & 11'h01;               // get LSB
               c_flash_data_tri = (r_shift_cnt>11'd0) ? 1'b0 : // drive the spi_cmd_word
                                  (((r_shift_cnt==11'd0)&&(r_cmd_type==CMD_WR)) ? 1'b0 : 1'b1); // drive the dqs
            end
            FLASH_RD_DUMMY_CLKS: begin
               c_flash_state = (r_shift_cnt==11'd0) ? FLASH_DATA_SHIFT : FLASH_RD_DUMMY_CLKS;
               // Keep SS low during dummy cycles 
               c_flash_ss_f = 1'b0; 
               c_flash_ss_tri = 1'b0;
               c_shift_cnt = (r_shift_cnt > 11'd0) ? 
                              (r_shift_cnt - 11'd1) : 
                              //(r_qspi_mode ? (r_shift_cnt - 8'd4) : (r_shift_cnt - 8'd1)) : 
                             ((r_shift_cnt == 11'd0) ? // set up the shift cnt for DATA shift state 
                              (r_qspi_mode ? (r_qspi_len*16'd8-32'd4) : (r_qspi_len*16'd8-16'd1)) :
                              r_shift_cnt) ; 
            end
            FLASH_DATA_SHIFT: begin      // Drop SS and shift 
               // In this state, shift count represents total # of cycles to
               // get all data shifted, the byte_num counter will track bytes
               // so we know when to bump the radr of the WR_BUFFER
               c_flash_state = (r_shift_cnt> 11'd0) ?  FLASH_DATA_SHIFT : FLASH_CMD_DONE;
               c_shift_cnt = (r_shift_cnt > 11'd0) ? 
                              (r_qspi_mode ? (r_shift_cnt - 11'd4) : (r_shift_cnt - 11'd1)) : 11'd0;

               // Need to use adjusted shift count for the data shifting, to
               // stay within a 0-63 range.. this is for when we are writing
               // using our WR_BUFFER and our total shift cnt (shift_cnt > 64)
               // which happens with a 256 byte WR.. ie we need to re-adjust
               // our shifter to be withing the 0-63 range to shift our data
               // appropriately.
               //  
               //  needs to be initialized to 60. or 
               //  Total words in 256 bytes (word == an 8byte chunk) == 32 
               //  LSB : word0 starts at offset 0
               //  MSB : word31 starts at offset 31*8byte = 31*64 = 1984bits
               //
               c_word_num = (c_adj_shft_cnt==6'd0) ? (r_word_num - 5'd1) : r_word_num;
               
               c_flash_dq[3] = r_qspi_mode ? (r_qspi_wr_data >> c_adj_shft_cnt+6'd3) & 8'h01 : 1'b1; // get MSB
               c_flash_dq[2] = r_qspi_mode ? (r_qspi_wr_data >> c_adj_shft_cnt+6'd2) & 8'h01 : 1'b1; 
               c_flash_dq[1] = r_qspi_mode ? (r_qspi_wr_data >> c_adj_shft_cnt+6'd1) & 8'h01 : 1'b1; 
               c_flash_dq[0] = r_qspi_mode ? ((r_qspi_wr_data >> c_adj_shft_cnt) & 8'h01) : 
                                             ((r_qspi_wr_data >> c_adj_shft_cnt) & 8'h01); // get LSB

               // Counters to track bit and byte postion necessary to bump
               // wbuffer_radr at correct time when doing 256Byte WR ops
               c_bit_cnt = r_qspi_mode ? (r_bit_cnt + 3'd4) : (r_bit_cnt + 3'd1);
               c_byte_num = r_qspi_mode ? ((r_bit_cnt == 3'd0) ? (r_byte_num - 8'd1) : r_byte_num) :
                                          ((r_bit_cnt == 3'd7) ? (r_byte_num - 8'd1) : r_byte_num);

               c_flash_data_tri = (r_shift_cnt==11'd0) ? 1'b1 : // raise tri_state as trans to IDLE
                                    ((r_cmd_type==CMD_WR) ? 1'b0 : 1'b1); // drive dqs on WR, dont drive on RD
               c_flash_ss_f = (r_shift_cnt==11'd0) ? 1'b1 : 1'b0; // raise SS as we transition to IDLE state
               c_flash_ss_tri = 1'b0;
            end
            FLASH_SPI_ERROR: begin
               c_flash_state = FLASH_CMD_DONE; 
               c_flash_ss_f = 1'b1;
               c_flash_ss_tri = 1'b0;
               c_flash_dq = 4'h0;
               c_flash_data_tri = 1'b1; 
            end
            default: begin
               c_flash_state = FLASH_CMD_DONE; 
               c_flash_ss_f = 1'b1;
               c_flash_ss_tri = 1'b0;
               c_flash_dq = 4'h0;
               c_flash_data_tri = 1'b1; 
            end
          endcase   
        end
  end        


   assign c_adj_shft_cnt = (r_shift_cnt > 11'd0) ? 
                                 (r_qspi_mode) ? // subtract within current word 
                                    (r_adj_shft_cnt-6'd4) : 
                                    (r_adj_shft_cnt-6'd1) 
                           : (r_shift_cnt == 11'd0) ? 
                                    (r_qspi_mode) ? // reset for next word
                                       (c_shift_cnt - (r_word_num*7'd64)) : 
                                       (c_shift_cnt - (r_word_num*7'd64)) 
                           : r_adj_shft_cnt;
   
  assign c_qspi_xfer_in_prog = !((r_flash_state == FLASH_IDLE) || (r_flash_state == FLASH_IDLE2));

   // SPI CMD crack
   // Decode and figure out how many Bytes of address/data or dummy cycles 
   // each different command requires
   //
   // Currently runs at spi_clk_2x which is 125Mhz
   //
   always @(*) begin
      if (reset) begin
         c_spi_cmd_crack_state = CMD_IDLE;
         c_cmd_fmt = 2'b0; 
         c_cmd_type = 2'b0; 
         c_cmd_dummy_clks = 4'b0; 

        end else begin
          c_spi_cmd_crack_state = r_spi_cmd_crack_state;
          c_cmd_fmt        = r_cmd_fmt;
          c_cmd_type       = r_cmd_type;
          c_cmd_dummy_clks = r_cmd_dummy_clks;

          case (r_spi_cmd_crack_state)
            CMD_IDLE:  begin     
               c_spi_cmd_crack_state = r_qspi_cmd_val ? CMD_DECODE : CMD_IDLE;
            end
            CMD_DECODE: begin
               c_spi_cmd_crack_state = CMD_IDLE; 
               case (r_qspi_cmd)
                  CLEAR_FLAG_STATUS_REG,
                  WRITE_ENABLE,
                  RESET_ENABLE,
                  RESET_MEMORY: begin // 4-0-0
                     c_cmd_fmt  = CMD_ONLY; 
                     c_cmd_type = CMD_CMD;
                     c_cmd_dummy_clks = 4'd0;
                  end
                  READ_STATUS_REGISTER,
                  READ_FLAG_STATUS_REGISTER,
                  MULTI_IO_READ_ID: begin // 4-0-4
                     c_cmd_fmt  = CMD_DATA_ONLY;
                     c_cmd_type = CMD_RD;
                     c_cmd_dummy_clks = 4'd0;
                  end
                  PAGE_PROGRAM,
                  BYTE4_PAGE_PROGRAM: begin // 1-1-1 , dummy clk 8 
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_WR;
                     c_cmd_dummy_clks = 0;
                  end
                  BYTE4_FAST_RD: begin // 1-1-1 , dummy clk 8 
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_RD;
                     c_cmd_dummy_clks = r_pgmd_dummy_clks; 
                  end
                  BYTE4_QUAD_IO_FAST_RD: begin // 4-4-4 dummy clk10
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_RD;
                     c_cmd_dummy_clks = r_pgmd_dummy_clks; 
                  end
                  READ_SERIAL_FLASH_DISC_PARAM: begin // 4-4-4 dummy clk 8 -- ENFORCED 8 clks, and 3byte ADDRESSING
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_RD;
                     c_cmd_dummy_clks = r_pgmd_dummy_clks;
                  end
                  BYTE4_DTR_QUAD_IO_FAST_RD: begin // 4-4-4 dummy clk8
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_RD;
                     c_cmd_dummy_clks = r_pgmd_dummy_clks;
                  end
                  QUAD_INPUT_FAST_PROGRAM,
                  BYTE4_QUAD_INPUT_EXT_FAST_PROGRAM: begin // 4-4-4, 4 address, 0 dummy, 1-256 wr bytes
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_WR;
                     c_cmd_dummy_clks = 4'd0;
                  end
                  READ_NONVOLATILE_CFG_REG,
                  READ_VOLATILE_CFG_REG,
                  READ_ENHANCED_VOLATILE_CFG_REG: begin // 4-0-4, no address, no dummy clks, varying data
                     c_cmd_fmt   = CMD_DATA_ONLY;
                     c_cmd_type  = CMD_RD;
                     c_cmd_dummy_clks = 4'd0;
                  end
                  WRITE_NONVOLATILE_CFG_REG,
                  WRITE_VOLATILE_CFG_REG,
                  WRITE_ENHANCED_VOLATILE_CFG_REG: begin // 4-0-4, no address, no dummy cycles, varying data
                     c_cmd_fmt   = CMD_DATA_ONLY;
                     c_cmd_type  = CMD_WR;
                     c_cmd_dummy_clks = 4'd0;
                  end
                  READ_GENERAL_PURPOSE_RD_REG: begin
                     c_cmd_fmt   = CMD_DATA_ONLY;
                     c_cmd_type  = CMD_RD;
                     c_cmd_dummy_clks = 4'd8;
                  end
                  DIE_ERASE,
                  BYTE4_SECTOR_ERASE2,
                  BYTE4_SECTOR_ERASE,
                  BYTE4_4KB_SUBSECTOR_ERASE,
                  BYTE4_32KB_SUBSECTOR_ERASE: begin // 4-4-0, 4 address bytes, no dummy,no data
                     c_cmd_fmt   = CMD_FULL;
                     c_cmd_type  = CMD_ERASE; 
                     c_cmd_dummy_clks = 4'd0;
                  end 
                  default: begin
                     c_cmd_type = CMD_ONLY; 
                  end
               endcase
            end
            default: begin
               c_spi_cmd_crack_state = CMD_IDLE;
            end
         endcase
      end
   end

  //
  // module port signal assignments
  //   
  assign qspi_rs_data = r_qspi_rs_data;
  assign qspi_rs_val = r_qspi_rs_val;
  assign qspi_rs_busy = r_qspi_rs_busy;
  assign qspi_rs_error = 1'b0;
  assign qspi_rs_timeout = r_qspi_rs_timeout;

  // Assign module output signals
  assign cfg_flash_ss_f_b = r_flash_ss_f;
  assign cfg_flash_ss_tri = r_flash_ss_tri;
  assign cfg_flash_data_out = r_flash_dq;
  assign cfg_flash_data_tri = r_flash_data_tri;
    
(* mark_debug = "true" *)       wire  din_capture = (r_flash_state == FLASH_DATA_SHIFT) && (r_cmd_type == CMD_RD);

   // should I leave this data persistant, and only clear it when I start the
   // next read operation?
   wire clr_rd_data = r_qspi_cmd_val & (r_cmd_type==CMD_RD) & (r_flash_state==FLASH_BUILD_SPI_WORD);

   // Registers - MMIO INTFC/REGISTERS run at spi_clk_2x
   always @(posedge spi_clk_2x) begin
      r_qspi_addr          <= c_qspi_addr; 
      r_qspi_rs_val        <= c_qspi_rs_val;
      rr_qspi_rs_val       <= reset ? 1'b0 : r_qspi_rs_val;  
      r_qspi_rs_busy       <= c_qspi_rs_busy;
      r_qspi_rs_timeout    <= c_qspi_rs_timeout;
      r_qspi_rs_data       <= c_qspi_rs_data;
      r_qspi_state         <= c_qspi_state;
      r_qspi_cmd           <= c_qspi_cmd;
      r_qspi_rst_fifo      <= c_qspi_rst_fifo;
      r_qspi_len           <= c_qspi_len;
      r_qspi_mode          <= reset ? 1'b0 : c_qspi_mode;
      r_qspi_xfer_in_prog  <= c_qspi_xfer_in_prog;
      r_qspi_access_done   <= c_qspi_access_done;
      r_qspi_cmd_val       <= c_qspi_cmd_val;
      r_spi_cmd_crack_state<= c_spi_cmd_crack_state;
      r_cmd_fmt            <= c_cmd_fmt;
      r_cmd_type           <= c_cmd_type;
      r_cmd_dummy_clks     <= c_cmd_dummy_clks;
      r_pgmd_dummy_clks    <= c_pgmd_dummy_clks; 
      r_wbuff_wadr         <= (reset | flash_cmd_done) ? 5'h0 : c_wbuff_wadr;
   end
  
   // Registers -- FLASH_STATE MACHINE -- 
   always @(posedge spi_clk_2x) begin
      r_flash_state        <= (reset | spi_clk) ? c_flash_state : r_flash_state;
      r_flash_data_tri     <= (reset | spi_clk) ? c_flash_data_tri : r_flash_data_tri;
      r_shift_cnt          <= (reset | spi_clk) ? c_shift_cnt : r_shift_cnt;
      r_adj_shft_cnt       <= (reset | spi_clk) ? c_adj_shft_cnt : r_adj_shft_cnt;
      r_word_num           <= (reset | spi_clk) ? c_word_num : r_word_num;
      r_bit_cnt            <= (reset | spi_clk) ? c_bit_cnt : r_bit_cnt;
      r_byte_num           <= (reset | spi_clk) ? c_byte_num : r_byte_num;
      r_idle_count         <= (reset | spi_clk) ? c_idle_count : r_idle_count;
      r_flash_ss_f         <= (reset | spi_clk) ? c_flash_ss_f : r_flash_ss_f;
      r_flash_ss_tri       <= (reset | spi_clk) ? c_flash_ss_tri : r_flash_ss_tri;
      r_flash_dq           <= (reset | spi_clk) ? c_flash_dq : r_flash_dq;  
      r_spi_word           <= (reset | spi_clk) ? c_spi_word : r_spi_word;
      r_qspi_wr_data       <= (reset | spi_clk) ? c_qspi_wr_data : r_qspi_wr_data; 
      r_wbuff_radr         <= (reset | spi_clk) ? c_wbuff_radr : r_wbuff_radr;
      spi_clk              <= c_spi_clk;
   end
   always @(posedge spi_clk_2x) begin
      r_qspi_rd_data       <= (reset|clr_rd_data) ? 64'b0 : // reset to 0
                               din_capture & spi_clk ?  // if in capture state (only capture a single spi_clk phase of spi_clk_2x)
                                 r_qspi_mode ? (cfg_flash_data_in[3:0]  | (r_qspi_rd_data << 4)) :// grab data and shift 
                                               (cfg_flash_data_in[1]    | (r_qspi_rd_data << 1)) 
                                              : r_qspi_rd_data; // hold
   end

endmodule 
