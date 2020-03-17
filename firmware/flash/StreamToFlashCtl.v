// StreamToFlashCtl.sv
// Copyright 2018 Pico Computing, Inc.

// This module implements a 64-bit PicoBus running at 125MHz and connects it to the 
// mgmt_qspi_flash_ctl module and the I2C master module using two 128-bit streams:
//   an input stream that carries commands and write data, and
//   an output stream that carries read data.
// Stream Command Format:
//   [65]       reset bit valid
//   [64]       read flag. 1=read, 0=write. or reset bit when reset bit valid is asserted
//   [63:32]    addr in bytes. for 64-bit PicoBus the bottom 3-bits are forced to zero
//   [31:0]     size in bytes
//   [127:0]    write data of size/16 words following command word. Typically bits [63:0] are 
//              used for a single 64-bit PicoBus write cycle but burst cycles are supported.

// Variable-latency reads are supported by watching the PicoDataOutValid signal for read data rather than PicoRd_q.

// Memory Map
// 0000h - Flash Controller Base address
// 1000h - Status Register address
// 2000h - I2C Controller Base address
// 3000h - SB-851 PROGRAM_B Register
// 4000h - ICAP interface

module StreamToFlashCtl #(
    parameter                   WIDTH      = 64,        // PicoBus width
    parameter                   S_PB_RATIO = 2,         // 250MHz stream clock, 125MHz PicoClk 
    parameter  [31:0]           QSPI_BASE  = 32'h0000,
    parameter  [31:0]           STATUS_REG = 32'h1000,
    parameter  [31:0]           I2C_BASE   = 32'h2000,
    parameter  [31:0]           SB851_PROGRAM_B_REG = 32'h3000,
    parameter  [31:0]           ICAP_ADDR  = 32'h4000 
    ) (
    input                       s_clk,
    input                       s_rst,
    
    output                      si_ready,
    input                       si_valid,
    input   [127:0]             si_data,
    
    input                       so_ready,
    output                      so_valid,
    output  [127:0]             so_data,

    inout                       scl,
    inout                       sda


    );
    
    wire                        PicoClk;
    wire                        PicoRst;
    reg    [WIDTH-1:0]          PicoDataIn;
    reg                         PicoWr;
    wire   [WIDTH-1:0]          PicoDataOut;
    reg    [31:0]               PicoAddr;
    reg                         PicoRd;
    wire                        PicoDataOutValid;

    reg                         soft_rst = 0;

    // PicoClk, generate using a counter based clk source, the output frequency is 125MHz
    CounterClkGen #(.RATIO(S_PB_RATIO)
                   ) clk_gen (
                     .refclk         (s_clk),
                     .rst            (s_rst),
                     .clk_o          (PicoClk)
                   );

    // Reset, handle carefully about crossing reset signal from fast clock domain
    // to slow clock domain. use a two way hand shake
    reg                         rst_q;
    wire                        pico_int_reset_synced;
    wire                        pico_int_reset;

    sync2r sync_pico_int_reset (.clk(s_clk), .preset(pico_int_reset), .d(pico_int_reset), .q(pico_int_reset_synced));

    always @(posedge s_clk) begin
        if (s_rst) begin
            rst_q <= 1'b1;
        end else begin
            // deasert rst_q when capture assertion of pico_int_reset in PicoClk domain
            if (pico_int_reset_synced) 
                rst_q <=0;
        end
    end

    sync2r sync_s_rst (.clk(PicoClk), .preset(rst_q), .d(rst_q), .q(pico_int_reset));

    assign   PicoRst  = pico_int_reset | soft_rst;

    // async fifos for crossing between stream clk domain and PicoClk domain
    wire                        i_valid;
    wire                        i_rdy;
    wire     [127:0]            i_data;
    wire                        o_valid;
    wire                        o_rdy;
    wire     [127:0]            o_data;

    wire                        so_full;
    wire                        so_empty;
    wire                        so_push = o_valid & o_rdy;
    wire                        so_pop = so_ready & so_valid;
    wire                        _so_fifo_nc0_;
    wire    [6:0]               _so_fifo_nc1_, _so_fifo_nc2_;

    // Stream output fifo
    generic_fifo #(
       .WIDTH(128),
       .DEPTH(64),
       .PIPE(1),
       .RAM_STYLE("block"),
       .AFULLCNT(48),
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
       .reset({pico_int_reset_synced, pico_int_reset}),  // oreset, ireset
       .push(so_push),
       .din(o_data), 
       .oclk(s_clk),
       .pop(so_pop)
    );
    assign so_valid = ~so_empty;
    assign o_rdy = ~so_full;

    wire                        si_full;
    wire                        si_empty;
    wire                        si_push = si_valid & si_ready;
    wire                        si_pop = i_rdy & i_valid;
    wire                        _si_fifo_nc0_;
    wire    [6:0]               _si_fifo_nc1_, _si_fifo_nc2_;

    // Stream input fifo
    generic_fifo #(
       .WIDTH(128),
       .DEPTH(64),
       .PIPE(1),
       .RAM_STYLE("block"),
       .AFULLCNT(48),
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
       .reset({pico_int_reset, s_rst}),  // oreset, ireset
       .push(si_push),
       .din(si_data), 
       .oclk(PicoClk),
       .pop(si_pop)
    );
    assign si_ready = ~si_full;
    assign i_valid = ~si_empty;


    // Command Interface
    reg                         start_wr, rd_active, wr_active;
    reg     [31:0]              rd_len, wr_len;
    reg                         PicoRd_q;

    reg     [65:0]              cmd;
    reg                         cmd_valid;
    
    always @(posedge PicoClk) begin
        if (pico_int_reset) begin
            cmd_valid   <= 0;
        end else begin
            cmd_valid       <= 0;
            if (i_valid && ~rd_active && ~wr_active && ~cmd_valid) begin
                cmd_valid   <= 1;
                cmd         <= i_data[65:0];
            end
        end
    end
    
    reg                         rd_byte=0;
    reg                         wr_byte=0;
    reg                         o_valid_reg;
    reg     [127:0]             o_data_reg=0;
        
    assign i_rdy   = ~pico_int_reset && ((~rd_active && ~wr_active && ~cmd_valid) || (wr_active && ((wr_byte == 1) || (wr_len == 32'h8))));
    assign o_valid = o_valid_reg;
    assign o_data  = o_data_reg;
        
    always @(posedge PicoClk) begin
        if (PicoRst) begin
            rd_active   <= 0;
            wr_active   <= 0;
            PicoRd_q    <= 0;   
        end

        if (pico_int_reset) begin
            soft_rst    <= 0;
        end

        PicoRd   <= 0;
        PicoWr   <= 0;
        start_wr <= 0;

        if (PicoRd)             
            PicoRd_q <= 1'b1;   // set high on PicoRd
        else if (PicoDataOutValid)
            PicoRd_q <= 1'b0;   // set low on PicoDataOutValid

        if (cmd_valid) begin
            if (cmd[65]) begin
                soft_rst <= cmd[64];
            end else begin
                o_data_reg  <= 0;   // clear the output register when valid data is returned to streaming interface (for the case where rd_len is less than 8)
                PicoAddr    <= {cmd[63:32+3], 3'h0};
                if (cmd[64]) begin
                    rd_len      <= cmd[31:0];
                    rd_byte     <= 0;
                    rd_active   <= 1;
                end else begin
                    wr_len      <= cmd[31:0];
                    wr_byte     <= 0;
                    start_wr    <= 1;
                    wr_active   <= 1;
                end
            end
        end
            
        if (wr_active && i_valid) begin
            wr_len      <= wr_len - 8;
            if      (wr_byte == 0)   PicoDataIn <= i_data[63:0];
            else if (wr_byte == 1)   PicoDataIn <= i_data[127:64];
            wr_byte       <= wr_byte + 1;
            PicoWr        <= 1;
            if (~start_wr)
                PicoAddr  <= PicoAddr + 8;
            start_wr      <= 0;
            if (wr_len == 32'h8)
                wr_active  <= 0;
        end
            
        // we'll fire a read every 3 clock cycles when the output is ready.
        // we could fire one every cycle if we had our own fifo with an almost-full flag, but this is good enough.
        if (o_rdy && rd_active) begin
            if (~PicoRd && ~PicoRd_q)
                PicoRd         <= 1;
            if (PicoDataOutValid) begin
                rd_len         <= rd_len - 8;
                PicoAddr       <= PicoAddr + 8;
                if (rd_len == 32'h8)
                    rd_active  <= 0;
            end
        end
            
        // assemble the PicoDataOut into the 128b register for stream output.
        // (this should be able to handle any number of 64b words, not just multiples of 2. so we may send out partial 128b words.)
        o_valid_reg <= PicoDataOutValid && ((rd_byte == 1) || (rd_len == 32'h8));
        if (PicoDataOutValid) begin
            rd_byte <= rd_byte + 1;
            if      (rd_byte == 0)   o_data_reg[63:0]    <= PicoDataOut;
            else if (rd_byte == 1)   o_data_reg[127:64]  <= PicoDataOut;
        end

    end

    // /////////////////////////////////////////
    // Instantiate the QSPI flash controller
    // /////////////////////////////////////////
    wire                        qspi_rq_val;

    // Memory Map of mgmt_qspi_flash_ctl 
    // 0000 - 0FFFh selects the mgmt_qspi_flash_ctl registers
    //              000h - spi_cfg_cmd register
    //              008h - spi_cfg_addr register
    //              010h - spi_cfg_status register
    //              018h - spi_cfg_rd_data register
    //              020h - spi_cfg_wr_data register
    //
    // 1000h - selects status register for qspi_rs_timeout and qspi_rs_busy
    // 2000h - selects the I2C master
    // 3000h - selects the SB-851 PROGRAM_B register
    // 4000h - ICAP interface

    assign qspi_rq_val = (PicoRd | PicoWr) & (PicoAddr[31:12] == QSPI_BASE[31:12]);

    wire qspi_rs_timeout;
    wire qspi_rs_busy;
    wire qspi_rs_val;
    wire [63:0] qspi_rs_data;
    mgmt_qspi_flash_ctl mgmt_qspi_flash_ctl (.spi_clk_2x      (PicoClk),          // 125mhz
                                             .reset           (PicoRst),          // reset
                                             .qspi_rq_val     (qspi_rq_val),      // request valid
                                             .rq_rnw          (PicoRd),           // 1-read, 0-write
                                             .rq_addr         (PicoAddr[11:0]),   // 12-bits
                                             .rq_data         (PicoDataIn),       // 64-bits
                                             .qspi_rs_val     (qspi_rs_val),      // response valid
                                             .qspi_rs_timeout (qspi_rs_timeout),  // mgmt register access timeout
                                             .qspi_rs_busy    (qspi_rs_busy),     // mgmt register access busy
                                             .qspi_rs_data    (qspi_rs_data)      // 64-bits
                                            );

    // Status register for qspi_rs_timeout and qspi_rs_busy
    reg  [1:0] status_reg;
    reg        status_reg_valid;
    always @(posedge PicoClk) begin
        if (PicoRst) begin
            status_reg       <= 0;
            status_reg_valid <= 0;
        end else if (PicoRd && (PicoAddr[31:12] == STATUS_REG[31:12])) begin
            status_reg <= {qspi_rs_timeout, qspi_rs_busy};
            status_reg_valid <= 1'b1;
        end else begin
            status_reg_valid <= 1'b0;
        end
    end
            
    // /////////////////////////////////////////
    // Instantiate the I2C master controller
    // /////////////////////////////////////////

    // Memory Map of the I2C master 
    // 2000 - 2FFFh selects the I2C controller registers
    //              2000h - I2C_CONFIG_REG  
    //              2008h - I2C_ADDR_REG    
    //              2010h - I2C_WRDATA_REG  
    //              2018h - I2C_RDDATA_REG  

    wire            i2c_read;
    wire            i2c_write;
    wire [31:0]     i2c_read_data;
    reg             i2c_read_data_valid;

    // Decode the base address to assert read or write
    assign          i2c_read  = PicoRd && (PicoAddr[31:12] == I2C_BASE[31:12]);
    assign          i2c_write = PicoWr && (PicoAddr[31:12] == I2C_BASE[31:12]);

    // Return valid one clock after read
    always @(posedge PicoClk) 
        if (PicoRst) 
            i2c_read_data_valid  <= 0;
        else 
            i2c_read_data_valid  <= i2c_read;

    i2c_master i2c_master (.clk        (PicoClk),          // 125 Mhz
                           .reset      (PicoRst),          // reset
                           .address    (PicoAddr[31:0]),   
                           .write      (i2c_write),
                           .write_data (PicoDataIn[31:0]),
                           .read       (i2c_read), 
                           .read_data  (i2c_read_data),      
                           .scl        (scl), 
                           .sda        (sda)
                          );                  
/*  // *** EXTERNAL PROGRAM_B SOLUTION IS NOT USED ***
    // SB-851 PROGRAM_B register for asserting PROGRAM_B to cause the FPGA to configure from flash
    // tPROGRAM = 250ns min for VU9P
    reg         sb851_program_b_reg = 1;     // default is 1 so PROGRAM_B is not assserted low
    reg [5:0]   sb851_program_b_cnt = 6'h0;  // counter to generate 250ns low pulse
    reg         sb851_program_b_reg_valid;

    // Pulse PROGRAM_B low for 250ns on PicoBus write to 3000h
    always @(posedge PicoClk) begin
        if (PicoRst) begin
            sb851_program_b_reg     <= 1'b1;  // default is 1 so PROGRAM_B is not assserted low
            sb851_program_b_cnt     <= 6'h0;
        end else if (PicoWr && (PicoAddr[31:12] == SB851_PROGRAM_B_REG[31:12])) begin
            sb851_program_b_reg     <= 1'b0; // set low on write
            sb851_program_b_cnt     <= 6'h0;
        end else if (sb851_program_b_reg == 1'b0) begin
            sb851_program_b_cnt     <= sb851_program_b_cnt + 6'h1;
            if (sb851_program_b_cnt >= 6'h20) begin 
                sb851_program_b_reg <= 1'b1; // set high after cnt=32 or 33*8=264ns
            end
       end
    end

    // drive the output pin with the register bit
    assign program_b = sb851_program_b_reg;
            
    // read data valid signal. PROGRAM_B will likely always read as high since
    // it is only pulsed low for 250ns.
    always @(posedge PicoClk) begin
        if (PicoRst) begin
            sb851_program_b_reg_valid <= 0;
        end else if (PicoRd && (PicoAddr[31:12] == SB851_PROGRAM_B_REG[31:12])) begin
            sb851_program_b_reg_valid <= 1'b1;
        end else begin
            sb851_program_b_reg_valid <= 1'b0;
        end
    end
  
    // Combine the data and valid from the mgmt_qspi_flash_ctl, status register, I2C controller and sb851 program_b register
    assign PicoDataOutValid =  status_reg_valid | qspi_rs_val | i2c_read_data_valid | sb851_program_b_reg_valid;
    assign PicoDataOut      =  status_reg_valid ? {62'h0, status_reg} : 
                               (i2c_read_data_valid ? {32'h0, i2c_read_data} : 
                               (sb851_program_b_reg_valid ? {63'h0, sb851_program_b_reg} : qspi_rs_data));
*/

    // Combine the data and valid from the mgmt_qspi_flash_ctl, status register
    // and I2C controller
    assign PicoDataOutValid =  status_reg_valid | qspi_rs_val | i2c_read_data_valid ;
    assign PicoDataOut      =  status_reg_valid ? {62'h0, status_reg} : 
                               (i2c_read_data_valid ? {32'h0, i2c_read_data} : qspi_rs_data);


    // ICAP interface, allows issuing an IPROG command or internal PROGRAM_B command from the host software
    wire            ICAP_CSIB;
    reg   [31:0]    idata;
    wire  [31:0]    swapped_idata;
    wire  [31:0]    icap_output;
    wire            icap_avail;
    wire            icap_prdone;
    wire            icap_prerror;
    reg   [31:0]    wb_start_addr;
    reg   [3:0]     iprog_cnt=0;
    reg   [31:0]    iprog_cmd_data;

    // Warm Boot Address Register, written at 4000h
    always @(posedge PicoClk) begin
        if (PicoRst) begin
            wb_start_addr <= 32'h0;  // default address=0 to start loading from flash when IPROG is issued
            iprog_cnt     <= 4'h0;
        end else if (PicoWr && (PicoAddr == ICAP_ADDR)) begin
            wb_start_addr <= PicoDataIn[31:0];  // address to start loading from flash when IPROG is issued
            iprog_cnt     <= 4'h1;  
        end else if ((iprog_cnt > 4'h0) && (iprog_cnt < 4'h8)) begin
            iprog_cnt     <= iprog_cnt + 4'h1;  
        end else begin
            iprog_cnt     <= 4'h0;  
        end
    end

    // ICAP chip select, active low when iprog_cnt is non-zero
    assign ICAP_CSIB = ~(|iprog_cnt);  

    // Issue the icap data sequence for the IPROG command
    always @(*) begin
        case (iprog_cnt)
            4'h0    : idata <= 32'h0; 
            4'h1    : idata <= 32'hFFFFFFFF;  // Dummy word
            4'h2    : idata <= 32'hAA995566;  // Sync word
            4'h3    : idata <= 32'h20000000;  // Type 1 NOOP
            4'h4    : idata <= 32'h30020001;  // Type 1 Write 1 word to WBSTAR
            4'h5    : idata <= wb_start_addr; // Warm boot start address in flash
            4'h6    : idata <= 32'h30008001;  // Type 1 Write 1 words to CMD
            4'h7    : idata <= 32'h0000000F;  // IPROG command
            4'h8    : idata <= 32'h20000000;  // Type 1 NOOP
            default : idata <= 32'h0;           
        endcase
    end

    // Need to swap the bit order as per UG570
    genvar  k;
    generate
    for(k = 0; k < 8; k = k + 1)
    begin
        assign swapped_idata[   k] = idata[   7-k];
        assign swapped_idata[ 8+k] = idata[ 8+7-k];
        assign swapped_idata[16+k] = idata[16+7-k];
        assign swapped_idata[24+k] = idata[24+7-k];
    end endgenerate

    ICAPE3       #(.ICAP_AUTO_SWITCH("DISABLE"))
        ICAPE3    (.CLK       (PicoClk      ),
                   .O         (icap_output  ),
                   .CSIB      (ICAP_CSIB    ),
                   .RDWRB     (1'b0         ),
                   .AVAIL     (icap_avail   ),
                   .PRDONE    (icap_prdone  ),
                   .PRERROR   (icap_prerror ),
                   .I         (swapped_idata)
                  );

endmodule
