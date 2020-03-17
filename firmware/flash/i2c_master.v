////////////////////////////////////////////////////////////////////////
////                                                                ////
////  This module contains synthesizable code to implement an       ////
////  I2C master interface                                          ////  
////                                                                ////
////////////////////////////////////////////////////////////////////////

/*

I2C Write:  St  DA[6:0] Wr Ack RA[15:8] Ack RA[7:0] Ack D[7:0] Ack D[15:8] Ack D[23:16] Ack D[31:24] Ack  Sp
I2C Read :  St  DA[6:0] Wr Ack RA[15:8] Ack RA[7:0] Ack RSt DA[6:0] Rd Ack D[7:0] Nack D[15:8] Nack D[23:16] Nack D[31:24] Nack  Sp

The Register address can be 0 to 4 bytes long and the Data can be 1 to 4 bytes long.

Software sequence:
  Write the I2C_WRDATA_REG with WriteData[31:0]  // Dont care for reads
  Write the I2C_ADDR_REG   with the I2C RegisterAddress[31:0] being accessed 
  Write the I2C_CONFIG_REG[23:0] with {data_byte_count[7:0], adr_byte_count[7:0], I2C_Device_Addr[6:0], R/Wn}
  Poll  the I2C_CONFIG_REG, bit[31] will be 1 while the I2C cycle is in progress, 0 when done
  Read  the I2C_RDDATA_REG for the readdata[31:0] after I2C read cycle

  R/Wn=1 for I2C Read command 
  R/Wn=0 for I2C Write command 

  Notes:The R/Wn bit in the i2_config_reg[16] must be set to 1 for reads and 0 for writes.
        The R/Wn bit actually sent with the first Device Address on read cycles is forced low for the register address. 
        After the Restart sequence the R/wn bit is sent high for the read data. 

        I2C Write data is sent in the order write_data[7:0], write_data[15:8], write_data[23:16], write_data[31:24] 
        I2C Read data may be byte reversed for multiple byte reads, check device.

        Clock stretching is not supported. 
*/

module i2c_master   (clk,      
                     reset,
                     address,      
                     write,
                     write_data,
                     read,
                     read_data,      
                     scl, 
                     sda  
                    );                  

  input              clk;
  input              reset;
  input   [31:0]     address;      
  input              write;
  input   [31:0]     write_data;
  input              read;
  output  [31:0]     read_data;
  inout              scl;                      // open drain bidir
  inout              sda;                      // open drain bidir

  reg     [31:0]     read_data;
  reg     [23:0]     i2c_config_reg;
  reg     [31:0]     i2c_wrdata_reg;
  reg     [31:0]     i2c_addr_reg;

  reg     [71:0]     i2c_shift_out;
  reg     [31:0]     i2c_shift_in;
  reg      [7:0]     clk_divisor;
  reg                in_progress_status;
  reg                error_status;
  wire               clk_enable;
  wire               sda, scl;

  reg     [10:0]     state;
  reg     [7:0]      data_byte_count;
  reg     [7:0]      adr_byte_count;
  wire               sda_enable;   
  wire               sda_value;    
  wire               scl_value;    
  wire               enable_shift; 
  wire               read_cycle;
  
  // Memory map of registers
  parameter  [31:0]  I2C_CONFIG_REG  = 32'h2000;
  parameter  [31:0]  I2C_ADDR_REG    = 32'h2008;
  parameter  [31:0]  I2C_WRDATA_REG  = 32'h2010;
  parameter  [31:0]  I2C_RDDATA_REG  = 32'h2018;

  parameter   CLOCK_DIVISOR  =  105;      // Number of  125MHz clock cycles for a .84us clock high time, 1.68us clock low time, 397Khz I2C bus. 
  
  // I2C Config Register
  always @(posedge clk)
    if (reset)
      i2c_config_reg <= 0;
    else if (write && (address == I2C_CONFIG_REG)) 
      i2c_config_reg  <= write_data[23:0];

  // I2C Write Data Register
  always @(posedge clk)
    if (reset)
      i2c_wrdata_reg <= 0;
    else if (write && (address == I2C_WRDATA_REG))
      i2c_wrdata_reg <= write_data[31:0]; 

  // I2C Address Register
  always @(posedge clk)
    if (reset)
      i2c_addr_reg <= 0;
    else if (write && (address == I2C_ADDR_REG))
      i2c_addr_reg <= write_data[31:0];

  // read-back multiplexing
  always @(posedge clk)
    if (reset)
      read_data <= 32'h0;       
    else if (read) begin
      case (address)
        I2C_CONFIG_REG         : read_data <= {in_progress_status, error_status, 6'h0, i2c_config_reg[23:0]};
        I2C_WRDATA_REG         : read_data <= i2c_wrdata_reg[31:0];
        I2C_ADDR_REG           : read_data <= i2c_addr_reg[31:0];
        I2C_RDDATA_REG         : read_data <= i2c_shift_in[31:0];
        default                : read_data <= 32'h0 ;           
      endcase
    end else begin
      read_data <= 32'h0;           
    end

  // clock divisor, divide clock by CLOCK_DIVISOR for clk_enable 
  always @(posedge clk)
    if (reset)
      clk_divisor <= 0;
    else if (clk_divisor < CLOCK_DIVISOR)                 // count clk cycles, then assert clk_enable
      clk_divisor <= clk_divisor + 8'b1;
    else
      clk_divisor <= 0;

  assign clk_enable = (clk_divisor == CLOCK_DIVISOR);     // state machine advances each clk_enable

  // I2C cycle transfer state machine
  assign  scl_value    = state[0];        // value for driving directly on scl
  assign  sda_value    = state[1];        // value for driving directly on sda
  assign  sda_enable   = state[2];        // enable for driving shift register data value onto sda
  assign  read_cycle   = state[6];        // high for read, low for write to qualify shift
  assign  enable_shift = state[7];        // enable clocking the shift register

  // define the state machine bits
  //           [10:8] cnt, [7] shift enable, [6:3] state, [2] sda_enable, [1] sda_value, [0] scl_value
  parameter ST0   = 11'b000_0_0000_011,   // reset or idle
            ST1   = 11'b000_0_0001_011,   // start, check for sda high and scl high else error on bus 
            ST2   = 11'b000_0_0001_001,   // start, sda low 
            ST3   = 11'b000_0_0001_000,   // start, sda low, scl low 

            DA7a  = 11'b000_0_0010_110,   // device address bit 7, sda from shift reg, scl low
            DA7b  = 11'b000_0_0010_111,   // device address bit 7, sda from shift reg, scl high
            DA7c  = 11'b000_1_0010_110,   // device address bit 7, sda from shift reg, scl low, enable shift reg

            DA6a  = 11'b001_0_0010_110,   // device address bit 6, sda from shift reg, scl low
            DA6b  = 11'b001_0_0010_111,   // device address bit 6, sda from shift reg, scl high
            DA6c  = 11'b001_1_0010_110,   // device address bit 6, sda from shift reg, scl low, enable shift reg

            DA5a  = 11'b010_0_0010_110,   // device address bit 5, sda from shift reg, scl low
            DA5b  = 11'b010_0_0010_111,   // device address bit 5, sda from shift reg, scl high
            DA5c  = 11'b010_1_0010_110,   // device address bit 5, sda from shift reg, scl low, enable shift reg

            DA4a  = 11'b011_0_0010_110,   // device address bit 4, sda from shift reg, scl low
            DA4b  = 11'b011_0_0010_111,   // device address bit 4, sda from shift reg, scl high
            DA4c  = 11'b011_1_0010_110,   // device address bit 4, sda from shift reg, scl low, enable shift reg
      
            DA3a  = 11'b100_0_0010_110,   // device address bit 3, sda from shift reg, scl low
            DA3b  = 11'b100_0_0010_111,   // device address bit 3, sda from shift reg, scl high
            DA3c  = 11'b100_1_0010_110,   // device address bit 3, sda from shift reg, scl low, enable shift reg

            DA2a  = 11'b101_0_0010_110,   // device address bit 2, sda from shift reg, scl low
            DA2b  = 11'b101_0_0010_111,   // device address bit 2, sda from shift reg, scl high
            DA2c  = 11'b101_1_0010_110,   // device address bit 2, sda from shift reg, scl low, enable shift reg

            DA1a  = 11'b110_0_0010_110,   // device address bit 1, sda from shift reg, scl low
            DA1b  = 11'b110_0_0010_111,   // device address bit 1, sda from shift reg, scl high
            DA1c  = 11'b110_1_0010_110,   // device address bit 1, sda from shift reg, scl low, enable shift reg

            DA0a  = 11'b111_0_0010_110,   // device address bit 0, sda from shift reg, scl low
            DA0b  = 11'b111_0_0010_111,   // device address bit 0, sda from shift reg, scl high
            DA0c  = 11'b111_1_0010_110,   // device address bit 0, sda from shift reg, scl low, enable shift reg

            A1a   = 11'b000_0_0010_010,   // ack, sda high, scl low
            A1b   = 11'b000_0_0010_011,   // ack, sda high, scl high, check for ACK with sda low from slave, else error
            A1c   = 11'b000_0_0011_010,   // ack, sda high, scl low

            RA7a  = 11'b000_0_0011_110,   // reg address bit 7, sda from shift reg, scl low
            RA7b  = 11'b000_0_0011_111,   // reg address bit 7, sda from shift reg, scl high
            RA7c  = 11'b000_1_0011_110,   // reg address bit 7, sda from shift reg, scl low, enable shift reg

            RA6a  = 11'b001_0_0011_110,   // reg address bit 6, sda from shift reg, scl low
            RA6b  = 11'b001_0_0011_111,   // reg address bit 6, sda from shift reg, scl high
            RA6c  = 11'b001_1_0011_110,   // reg address bit 6, sda from shift reg, scl low, enable shift reg

            RA5a  = 11'b010_0_0011_110,   // reg address bit 5, sda from shift reg, scl low
            RA5b  = 11'b010_0_0011_111,   // reg address bit 5, sda from shift reg, scl high
            RA5c  = 11'b010_1_0011_110,   // reg address bit 5, sda from shift reg, scl low, enable shift reg

            RA4a  = 11'b011_0_0011_110,   // reg address bit 4, sda from shift reg, scl low
            RA4b  = 11'b011_0_0011_111,   // reg address bit 4, sda from shift reg, scl high
            RA4c  = 11'b011_1_0011_110,   // reg address bit 4, sda from shift reg, scl low, enable shift reg
      
            RA3a  = 11'b100_0_0011_110,   // reg address bit 3, sda from shift reg, scl low
            RA3b  = 11'b100_0_0011_111,   // reg address bit 3, sda from shift reg, scl high
            RA3c  = 11'b100_1_0011_110,   // reg address bit 3, sda from shift reg, scl low, enable shift reg

            RA2a  = 11'b101_0_0011_110,   // reg address bit 2, sda from shift reg, scl low
            RA2b  = 11'b101_0_0011_111,   // reg address bit 2, sda from shift reg, scl high
            RA2c  = 11'b101_1_0011_110,   // reg address bit 2, sda from shift reg, scl low, enable shift reg

            RA1a  = 11'b110_0_0011_110,   // reg address bit 1, sda from shift reg, scl low
            RA1b  = 11'b110_0_0011_111,   // reg address bit 1, sda from shift reg, scl high
            RA1c  = 11'b110_1_0011_110,   // reg address bit 1, sda from shift reg, scl low, enable shift reg

            RA0a  = 11'b111_0_0011_110,   // reg address bit 0, sda from shift reg, scl low
            RA0b  = 11'b111_0_0011_111,   // reg address bit 0, sda from shift reg, scl high
            RA0c  = 11'b111_1_0011_110,   // reg address bit 0, sda from shift reg, scl low, enable shift reg

            A2a   = 11'b111_0_0011_010,   // ack, sda high, scl low
            A2b   = 11'b000_0_0011_011,   // ack, sda high, scl high, check for ACK with sda low from slave, else error
            A2c   = 11'b000_0_0100_010,   // ack, sda high, scl low

            RS1a  = 11'b000_0_0111_010,   // Restart, sda high, scl low
            RS1b  = 11'b000_0_0111_011,   // Restart, sda high, scl high
            RS1c  = 11'b000_0_0111_001,   // Restart, sda low , scl high
            RS1d  = 11'b000_0_0111_000,   // Restart, sda low , scl low

                                          // Write cycle, data
            WD7a  = 11'b000_0_0100_110,   // data bit 7, sda from shift reg, scl low
            WD7b  = 11'b000_0_0100_111,   // data bit 7, sda from shift reg, scl high
            WD7c  = 11'b000_1_0100_110,   // data bit 7, sda from shift reg, scl low, enable shift reg

            WD6a  = 11'b001_0_0100_110,   // data bit 6, sda from shift reg, scl low
            WD6b  = 11'b001_0_0100_111,   // data bit 6, sda from shift reg, scl high
            WD6c  = 11'b001_1_0100_110,   // data bit 6, sda from shift reg, scl low, enable shift reg

            WD5a  = 11'b010_0_0100_110,   // data bit 5, sda from shift reg, scl low
            WD5b  = 11'b010_0_0100_111,   // data bit 5, sda from shift reg, scl high
            WD5c  = 11'b010_1_0100_110,   // data bit 5, sda from shift reg, scl low, enable shift reg

            WD4a  = 11'b011_0_0100_110,   // data bit 4, sda from shift reg, scl low
            WD4b  = 11'b011_0_0100_111,   // data bit 4, sda from shift reg, scl high
            WD4c  = 11'b011_1_0100_110,   // data bit 4, sda from shift reg, scl low, enable shift reg
      
            WD3a  = 11'b100_0_0100_110,   // data bit 3, sda from shift reg, scl low
            WD3b  = 11'b100_0_0100_111,   // data bit 3, sda from shift reg, scl high
            WD3c  = 11'b100_1_0100_110,   // data bit 3, sda from shift reg, scl low, enable shift reg

            WD2a  = 11'b101_0_0100_110,   // data bit 2, sda from shift reg, scl low
            WD2b  = 11'b101_0_0100_111,   // data bit 2, sda from shift reg, scl high
            WD2c  = 11'b101_1_0100_110,   // data bit 2, sda from shift reg, scl low, enable shift reg

            WD1a  = 11'b110_0_0100_110,   // data bit 1, sda from shift reg, scl low
            WD1b  = 11'b110_0_0100_111,   // data bit 1, sda from shift reg, scl high
            WD1c  = 11'b110_1_0100_110,   // data bit 1, sda from shift reg, scl low, enable shift reg

            WD0a  = 11'b111_0_0100_110,   // data bit 0, sda from shift reg, scl low
            WD0b  = 11'b111_0_0100_111,   // data bit 0, sda from shift reg, scl high
            WD0c  = 11'b111_1_0100_110,   // data bit 0, sda from shift reg, scl low, enable shift reg

            A4a   = 11'b111_0_0100_010,   // ack, sda high, scl low
            A4b   = 11'b000_0_0101_011,   // ack, sda high, scl high, check for ACK with sda low from slave, else error
            A4c   = 11'b000_0_0101_010,   // ack, sda high, scl low

            SPa   = 11'b000_0_0101_000,   // stop, sda low, scl low
            SPb   = 11'b000_0_0101_001,   // stop, sda low, scl high
            SPc   = 11'b000_0_0110_011,   // stop, sda high, scl high

                                          // Read cycle, data byte
            RD7a  = 11'b000_0_1100_010,   // data bit 7, sda high, data from slave, scl low
            RD7b  = 11'b000_1_1100_011,   // data bit 7, sda high, data from slave, scl high, enable sample read data
            RD7c  = 11'b000_0_1101_010,   // data bit 7, sda high, data from slave, scl low

            RD6a  = 11'b001_0_1100_010,   // data bit 6, sda high, data from slave, scl low
            RD6b  = 11'b001_1_1100_011,   // data bit 6, sda high, data from slave, scl high, enable sample read data
            RD6c  = 11'b001_0_1101_010,   // data bit 6, sda high, data from slave, scl low

            RD5a  = 11'b010_0_1100_010,   // data bit 5, sda high, data from slave, scl low
            RD5b  = 11'b010_1_1100_011,   // data bit 5, sda high, data from slave, scl high, enable sample read data
            RD5c  = 11'b010_0_1101_010,   // data bit 5, sda high, data from slave, scl low

            RD4a  = 11'b011_0_1100_010,   // data bit 4, sda high, data from slave, scl low
            RD4b  = 11'b011_1_1100_011,   // data bit 4, sda high, data from slave, scl high, enable sample read data
            RD4c  = 11'b011_0_1101_010,   // data bit 4, sda high, data from slave, scl low
      
            RD3a  = 11'b100_0_1100_010,   // data bit 3, sda high, data from slave, scl low
            RD3b  = 11'b100_1_1100_011,   // data bit 3, sda high, data from slave, scl high, enable sample read data
            RD3c  = 11'b100_0_1101_010,   // data bit 3, sda high, data from slave, scl low

            RD2a  = 11'b101_0_1100_010,   // data bit 2, sda high, data from slave, scl low
            RD2b  = 11'b101_1_1100_011,   // data bit 2, sda high, data from slave, scl high, enable sample read data
            RD2c  = 11'b101_0_1101_010,   // data bit 2, sda high, data from slave, scl low

            RD1a  = 11'b110_0_1100_010,   // data bit 1, sda high, data from slave, scl low
            RD1b  = 11'b110_1_1100_011,   // data bit 1, sda high, data from slave, scl high, enable sample read data
            RD1c  = 11'b110_0_1101_010,   // data bit 1, sda high, data from slave, scl low

            RD0a  = 11'b111_0_1100_010,   // data bit 0, sda high, data from slave, scl low
            RD0b  = 11'b111_1_1100_011,   // data bit 0, sda high, data from slave, scl high, enable sample read data
            RD0c  = 11'b111_0_1101_010,   // data bit 0, sda high, data from slave, scl low

            A3a   = 11'b111_0_0100_000,   // send ack, sda low, scl low
            A3b   = 11'b111_0_0100_001,   // send ack, sda low, scl high, send ACK to slave
            A3c   = 11'b111_0_0101_000,   // send ack, sda low, scl low

            A5a   = 11'b000_0_0110_010,   // nack, sda high, scl low
            A5b   = 11'b001_0_0110_011,   // nack, sda high, scl high, send NACK to slave
            A5c   = 11'b001_0_0111_010,   // nack, sda high, scl low

            ERROR = 11'b111_0_0111_010;   // error observed on the I2C bus or no ack received, scl low to complete clock cycle

  // I2C Cycle State machine
  always @(posedge clk) 
    if (reset)
      state <= ST0;
    else if (clk_enable)
      case (state)
      ST0   :  if (in_progress_status) state <= ST1; 
      ST1   :  if (sda && scl) state         <= ST2; else state <= ERROR;   // error if sda and scl are not floating high
      ST2   :      state <= ST3;       // send start condition
      ST3   :      state <= DA7a;

      DA7a  :      state <= DA7b;      // send device address and register address
      DA7b  :      state <= DA7c;
      DA7c  :      state <= DA6a;
      DA6a  :      state <= DA6b;
      DA6b  :      state <= DA6c;
      DA6c  :      state <= DA5a;
      DA5a  :      state <= DA5b;
      DA5b  :      state <= DA5c;
      DA5c  :      state <= DA4a;
      DA4a  :      state <= DA4b;
      DA4b  :      state <= DA4c;
      DA4c  :      state <= DA3a;
      DA3a  :      state <= DA3b;
      DA3b  :      state <= DA3c;
      DA3c  :      state <= DA2a;
      DA2a  :      state <= DA2b;
      DA2b  :      state <= DA2c;
      DA2c  :      state <= DA1a;
      DA1a  :      state <= DA1b;
      DA1b  :      state <= DA1c;
      DA1c  :      state <= DA0a;
      DA0a  :      state <= DA0b;
      DA0b  :      state <= DA0c;
      DA0c  :      state <= A1a;      
      
      A1a   :      state <= A1b;      
      A1b   :      state <= (sda == 1'b1) ? ERROR : A1c;               // error if slave doesn't ack
      A1c   :      state <= (adr_byte_count == 3'b000) ? (i2c_config_reg[0] ? RS1a : WD7a) : DA7a;   // stop or send more bytes, check R/Wn bit 

      RS1a  :      state <= RS1b;      // Issue Restart sequence on read cycles
      RS1b  :      state <= RS1c;
      RS1c  :      state <= RS1d;
      RS1d  :      state <= RA7a;
      
      RA7a  :      state <= RA7b;      // Resend device address after restart on read cycles
      RA7b  :      state <= RA7c; 
      RA7c  :      state <= RA6a; 
      RA6a  :      state <= RA6b; 
      RA6b  :      state <= RA6c; 
      RA6c  :      state <= RA5a; 
      RA5a  :      state <= RA5b; 
      RA5b  :      state <= RA5c; 
      RA5c  :      state <= RA4a; 
      RA4a  :      state <= RA4b; 
      RA4b  :      state <= RA4c; 
      RA4c  :      state <= RA3a; 
      RA3a  :      state <= RA3b; 
      RA3b  :      state <= RA3c; 
      RA3c  :      state <= RA2a; 
      RA2a  :      state <= RA2b; 
      RA2b  :      state <= RA2c; 
      RA2c  :      state <= RA1a; 
      RA1a  :      state <= RA1b; 
      RA1b  :      state <= RA1c; 
      RA1c  :      state <= RA0a; 
      RA0a  :      state <= RA0b; 
      RA0b  :      state <= RA0c; 
      RA0c  :      state <= A2a;  

      A2a   :      state <= A2b;  
      A2b   :      state <= A2c;  
      A2c   :      state <= RD7a; 

      WD7a  :      state <= WD7b;      // send write data bytes
      WD7b  :      state <= WD7c;
      WD7c  :      state <= WD6a;
      WD6a  :      state <= WD6b;
      WD6b  :      state <= WD6c;
      WD6c  :      state <= WD5a;
      WD5a  :      state <= WD5b;
      WD5b  :      state <= WD5c;
      WD5c  :      state <= WD4a;
      WD4a  :      state <= WD4b;
      WD4b  :      state <= WD4c;
      WD4c  :      state <= WD3a;
      WD3a  :      state <= WD3b;
      WD3b  :      state <= WD3c;
      WD3c  :      state <= WD2a;
      WD2a  :      state <= WD2b;
      WD2b  :      state <= WD2c;
      WD2c  :      state <= WD1a;
      WD1a  :      state <= WD1b;
      WD1b  :      state <= WD1c;
      WD1c  :      state <= WD0a;
      WD0a  :      state <= WD0b;
      WD0b  :      state <= WD0c;
      WD0c  :      state <= A4a;
      
      A4a   :      state <= A4b;
      A4b   :      state <= (sda == 1'b1) ? ERROR : A4c;               // error if slave doesn't ack
      A4c   :      state <= (data_byte_count == 3'b000) ? SPa : WD7a;  // stop or send more bytes

      SPa   :      state <= SPb;      // send stop condition
      SPb   :      state <= SPc;
      SPc   :      state <= ST0;      // return to idle state
      
      RD7a  :      state <= RD7b;     // read data bytes
      RD7b  :      state <= RD7c;
      RD7c  :      state <= RD6a;
      RD6a  :      state <= RD6b;
      RD6b  :      state <= RD6c;
      RD6c  :      state <= RD5a;
      RD5a  :      state <= RD5b;
      RD5b  :      state <= RD5c;
      RD5c  :      state <= RD4a;
      RD4a  :      state <= RD4b;
      RD4b  :      state <= RD4c;
      RD4c  :      state <= RD3a;
      RD3a  :      state <= RD3b;
      RD3b  :      state <= RD3c;
      RD3c  :      state <= RD2a;
      RD2a  :      state <= RD2b;
      RD2b  :      state <= RD2c;
      RD2c  :      state <= RD1a;
      RD1a  :      state <= RD1b;
      RD1b  :      state <= RD1c;
      RD1c  :      state <= RD0a;
      RD0a  :      state <= RD0b;
      RD0b  :      state <= RD0c;
      RD0c  :      state <= (data_byte_count == 3'b000) ? A5a : A3a;  // stop or send more bytes
      
      A3a   :      state <= A3b;      // send ack
      A3b   :      if (sda == 1'b1) state <= ERROR; else state <= A3c;  // error if we don't send ack
      A3c   :      state <= RD7a; 

      A5a   :      state <= A5b;      // send nack on last read data byte
      A5b   :      state <= A5c;
      A5c   :      state <= SPa;      // go to stop condition state

      ERROR :      state <= SPa;      // scl low to complete clock cycle, then issue stop condition

      default :    state <= ST0;
    endcase 

  // adr_byte_count - Set to i2c_config_reg[15:8] on start of I2C write and read cycles plus 1 for the 1-byte Device Address 
  always @(posedge clk)
    if (reset)
      adr_byte_count <= 0;
    else if (clk_enable)
      if (state == ST2)                 // load count on start of I2C cycle
        adr_byte_count <= i2c_config_reg[15:8] + 8'd1;  
      else if (state == DA7a)           // decrement when each byte is sent 
        adr_byte_count  <= adr_byte_count - 8'd1;

  // data_byte_count - Set to i2c_config_reg[23:16] on start of I2C write and read cycles 
  // Counts down to zero, decremented after each byte is sent on writes or received on reads.
  always @(posedge clk)
    if (reset)
      data_byte_count <= 0;
    else if (clk_enable)
      if (state == ST2)                                         // load count on start of I2C cycle
        data_byte_count  <= i2c_config_reg[23:16];
      else if ((state == WD7a) || (state == RD7a))              // decrement when each byte is sent or rcvd 
        data_byte_count  <= data_byte_count - 8'd1;

  // in_progress_status status bit
  always @(posedge clk)
    if (reset)
      in_progress_status <= 0;
    else if (write && (address == I2C_CONFIG_REG))
      in_progress_status <= 1'b1;                    // set when config register is written
    else if (clk_enable)
      if (in_progress_status && (state != SPc))      // assert til Stop state 
        in_progress_status <= 1'b1;
      else 
        in_progress_status <= 1'b0;                  // clear when Stop state is reached

  // Latch error status bit. Clear error status bit on config register write.
  always @(posedge clk)
    if (reset)
      error_status <= 0;
    else if (write && (address == I2C_CONFIG_REG))
      error_status <= 0;
    else if (state == ERROR)
      error_status <= 1'b1;

  // I2C shift out register
  always @(posedge clk) begin
      if (reset)
          i2c_shift_out <= 0;
      else if ((state == ST2) && clk_enable) begin             // load shift register on start 
          if (i2c_config_reg[0]) begin                         // check R/Wn bit 
              case (i2c_config_reg[15:8])                      // Read. check number of address bytes, force R/Wn bit low on first Device Address byte 
                  8'd0     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:1], 1'b0, i2c_config_reg[7:0], 56'h0};                       // Read, 0 address bytes
                             end
                  8'd1     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:1], 1'b0, i2c_addr_reg[7:0], i2c_config_reg[7:0], 48'h0};    // Read, 1 address bytes 
                             end
                  8'd2     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:1], 1'b0, i2c_addr_reg[15:0], i2c_config_reg[7:0], 40'h0};   // Read, 2 address bytes 
                             end
                  8'd3     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:1], 1'b0, i2c_addr_reg[23:0], i2c_config_reg[7:0], 32'h0};   // Read, 3 address bytes 
                             end
                  default :  begin                                   
                                 i2c_shift_out <= {i2c_config_reg[7:1], 1'b0, i2c_addr_reg[31:0], i2c_config_reg[7:0], 24'h0};   // Read, 4 address bytes 
                             end
              endcase
          end else begin
              case (i2c_config_reg[15:8])                      // Write, check number of address bytes
                  8'd0     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:0], i2c_wrdata_reg[7:0], i2c_wrdata_reg[15:8], i2c_wrdata_reg[23:16], i2c_wrdata_reg[31:24], 32'h0};       
                             end
                  8'd1     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:0], i2c_addr_reg[7:0], i2c_wrdata_reg[7:0], i2c_wrdata_reg[15:8], i2c_wrdata_reg[23:16], i2c_wrdata_reg[31:24], 24'h0}; 
                             end
                  8'd2     : begin
                                 i2c_shift_out <= {i2c_config_reg[7:0], i2c_addr_reg[15:0], i2c_wrdata_reg[7:0], i2c_wrdata_reg[15:8], i2c_wrdata_reg[23:16], i2c_wrdata_reg[31:24], 16'h0}; 
                             end
                  8'd3     : begin
                               i2c_shift_out <= {i2c_config_reg[7:0], i2c_addr_reg[23:0], i2c_wrdata_reg[7:0], i2c_wrdata_reg[15:8], i2c_wrdata_reg[23:16], i2c_wrdata_reg[31:24], 8'h0}; 
                             end
                  default  : begin
                               i2c_shift_out <= {i2c_config_reg[7:0], i2c_addr_reg[31:0], i2c_wrdata_reg[7:0], i2c_wrdata_reg[15:8], i2c_wrdata_reg[23:16], i2c_wrdata_reg[31:24]}; 
                             end
              endcase
          end
      end else if (clk_enable && enable_shift)                 // shift data left
          i2c_shift_out <= (i2c_shift_out<<1);      
    end

  // Read data shift register
  always @(posedge clk)
    if (reset)
      i2c_shift_in <= 0;
    else if ((state == ST2) && clk_enable)                   // clear shift register on start 
      i2c_shift_in <= 0;
    else if (clk_enable && enable_shift && read_cycle)            
      i2c_shift_in <= { i2c_shift_in[30:0], sda };           // shift data left from bit 0

  // I2C SDA interface pin, open drain, drive sda low if sda_value is low or if MSB is low and sda_enable is high
  assign sda  = (~sda_value | (sda_enable & ~i2c_shift_out[71])) ? 1'b0 : 1'bz;

  // I2C SCL interface pin:  open drain, drive low or float high
  assign scl  = scl_value ? 1'bz : 1'b0;

endmodule
