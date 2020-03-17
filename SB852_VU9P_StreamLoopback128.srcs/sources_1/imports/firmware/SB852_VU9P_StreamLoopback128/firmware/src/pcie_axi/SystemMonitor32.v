// SystemMonitor32.v
// Exposes the raw system monitor values for internal voltage, auxiliary voltage, and temperature.
// Calculate the "real" values from the raw values as follows:
//     Voltage = (RAW_VALUE / 1024) * 3
//     Degrees Celsius = RAW_VALUE * 503.975 / 1024 - 273.15

// The system monitor is placed in auto-sequence mode so it continuously samples all the sensors we want.
// We just need to watch the end-of-channel (eoc) flag to know when to grab data. When that goes high, we send the
// channel number to the address port. A few cycles later, the data shows up and drdy goes high, at which point we latch it.

`include "PicoDefines.v"

module SystemMonitor32 (
    input              s_clk, // Stream Clock - nominally 250Mhz
    input              s_rst, // Stream Clock synchronous reset
    /* PicoBus ports */
    input              PicoRst,
    input              PicoClk,
    input      [31:0]  PicoAddr,
    input      [31:0] PicoDataIn,
    output reg [31:0] PicoDataOut,
    input              PicoRd,
    input              PicoWr,
    output     [9:0]   temp
);

    parameter S_PB_RATIO = 62;

    assign temp = r_temp;

reg [9:0] vccint, vccaux, vp, r_temp;

always @(posedge PicoClk) begin
    if (PicoRd & (PicoAddr[31:0] == (`SYSTEM_MONITOR_ADDR+4))) begin
        PicoDataOut[31:0] <= {6'h0, vp[9:0],
                              6'h0, vccaux[9:0]};
    end else if (PicoRd & (PicoAddr[31:0] == (`SYSTEM_MONITOR_ADDR))) begin
        PicoDataOut[31:0] <= {6'h0, vccint[9:0],
                              6'h0, r_temp[9:0]};
    end else begin
        PicoDataOut[31:0] <= 32'h0;
    end
end

`ifdef ALTERA_FPGA
    wire [9:0]  a10_ts_data                                   ;
    wire [11:0] a10_vs_data                                   ; // [11:6] 6 bit is useful
    wire [9:0]  a10_vs_data_shift                             ;
    assign      a10_vs_data_shift = {4'b0, a10_vs_data[11:6]} ;

    always @(posedge PicoClk) begin
       r_temp <= a10_ts_data;
       vccint <= a10_vs_data_shift;
       vp <= 9'h0;
       vccaux <= 9'h0;
    end
`else //!ALTERA_FPGA
    wire [15:0] dobus;
    wire [5:0] channel;
    wire eoc, drdy;
    wire pb_drdy;
    wire [5:0] pb_channel;
    wire [15:6] pb_dobus;

    always @(posedge PicoClk) begin
        // captue channel data
        if (pb_drdy) begin
            if (pb_channel[5:0] == 6'h0) r_temp <= pb_dobus[15:6];
            if (pb_channel[5:0] == 6'h1) vccint <= pb_dobus[15:6];
            if (pb_channel[5:0] == 6'h2) vccaux <= pb_dobus[15:6];
            if (pb_channel[5:0] == 6'h3) vp <= pb_dobus[15:6];
        end
    end

    // Synchronize the drdy signal to pico clock domain
    wire [7:1] _nc0_;
    fsync #(.RATIO(S_PB_RATIO+2)) drdy_sync (.clk(s_clk), .flg(drdy), .oclk(PicoClk), .oflg({_nc0_[7:1], pb_drdy}));

    sync1 #(.WIDTH(6)) channel_sync (.clk(PicoClk), .d(channel), .q(pb_channel));
    sync1 #(.WIDTH(10)) dobus_sync (.clk(PicoClk), .d(dobus[15:6]), .q(pb_dobus[15:6]));
`endif //!ALTERA_FPGA

// TODO: fix ifdef 08/11/2017
`ifdef ALTERA_FPGA  // AC520 only for now

//    wire        a10_vs_eoc   ;
//    wire        a10_vs_eos   ;
//    wire        a10_ts_eoc   ;

    reg  [7:0]  conf_count                                    ;
    reg         confin                                        ;
    reg         coreconfig                                    ;
    wire [7:0]  MD11                                          ;
    assign      MD11 = 8'h03                                  ;

    localparam  START_CONF   = 8'h64 ; // 100 cycles
    localparam  STOP_CONF    = START_CONF + 8 ;

    // twentynm_tsdblock in quartus/eda/sim_lib/twentynm_components
    twentynm_tsdblock sd1 (
        .corectl    ( 1'b1   ) ,
        .eoc        (        ) ,
        .reset      ( 1'b0   ) ,
        .tempout    ( a10_ts_data )
    ) ;

    always @ (posedge PicoClk) 
    begin
        if (PicoRst) begin
            conf_count  <= 8'h0       ; 
            confin      <= 1'b0       ;
            coreconfig  <= 1'b0       ;
        end else begin
            coreconfig  <= 1'b0       ;
            // from clk 100 to clk 107, config
            if ((conf_count >= START_CONF) && (conf_count < STOP_CONF)) begin   
                conf_count     <= conf_count + 1 ; // 
                coreconfig     <= 1'b1    ;        // start config in next cycle
                confin         <= MD11[conf_count - START_CONF] ; // from LSB
            end else begin
                conf_count     <= conf_count + 1 ;  // keep counting
                if (conf_count >= STOP_CONF) begin     // stop after clk 108
                    conf_count <= conf_count ;
                end
            end    
        end
    end

    // a10 handbook voltage sensor
    twentynm_vsblock  ac520_voltage_sensor_u0 (
        .clk        ( PicoClk     ) , // slow pico clock
        .reset      ( PicoRst     ) ,
        .corectl    ( 1'b1        ) ,
        .coreconfig ( coreconfig  ) ,
        .confin     ( confin      ) ,
        .chsel      ( 4'b10       ) , // ch2 is VCCint
        .eoc        (             ) , 
        .eos        (             ) ,
        .dataout    ( a10_vs_data )
    ) ;




`elsif XILINX_ULTRASCALE

`ifdef XILINX_ULTRASCALE_PLUS
SYSMONE4 #(
    .INIT_40(16'h3000), // Configuration register 0 (0x3000 means average 256 samples)
    .INIT_41(16'h2FDE), // Configuration register 1 (low bit disable overtemp shutdown)
    .INIT_42(16'h4000), // Configuration register 2 // ADC clock - DCLK/2
    .INIT_43(16'h0), // Test register 0
    .INIT_44(16'h0), // Test register 1
    .INIT_45(16'h0), // Test register 2
    .INIT_46(16'h0), // Test register 3
    .INIT_47(16'h0), // Test register 4
    .INIT_48(16'h7F01), // Sequence register 0
    .INIT_49(16'h0), // Sequence register 1
    .INIT_4A(16'h4F00), // ADC Channel Averaging Enables
    .INIT_4B(16'h0), // Sequence register 3
    .INIT_4C(16'h0), // Sequence register 4
    .INIT_4D(16'h0), // Sequence register 5
    .INIT_4E(16'h0), // Sequence register 6
    .INIT_4F(16'h0), // Sequence register 7
    .INIT_50(16'h0), // Alarm limit register 0
    .INIT_51(16'h0), // Alarm limit register 1
    .INIT_52(16'h0), // Alarm limit register 2
    .INIT_53(16'hC363), // Alarm limit register 3 0xC36X = 110 Celcius
    .INIT_54(16'h0), // Alarm limit register 4
    .INIT_55(16'h0), // Alarm limit register 5
    .INIT_56(16'h0), // Alarm limit register 6
    .INIT_57(16'h0)  // Alarm limit register 7
) my_sysmon (
    .BUSY(busy), // 1-bit output ADC busy signal
    .CHANNEL(channel[5:0]), // 6-bit output channel selection
    .DO(dobus[15:0]), // 16-bit output data bus for dynamic reconfig port
    .EOC(eoc),
    .DRDY(drdy),
    .DADDR({2'b0, channel[5:0]}),// 8-bit input address bus for dynamic reconfig
    .DCLK(s_clk), // 1-bit input clock for dynamic reconfig port
    .DEN(eoc), // 1-bit input enable for dynamic reconfig port
    .DWE(1'b0), // 1-bit input write enable for dynamic reconfig port
    .RESET(s_rst) // 1-bit input active high reset
);

`else  // !XILINX_ULTRASCALE_PLUS

// AC-505 Kintex 7 & AC-510 Kintex UltraScale dclk can be 8-250MHz. 
// The internal ADC clk can be 1-5.2MHz for Kintex UltraScale and 
// 1-26Mhz for Kintex 7.
// Bits 8-15 of INIT_42 specify the divisor. 
// We'll use the 250Mhz stream clk (s_clk) for dclk and 
// we'll adjust the ADC divisor to 64 give us a valid ~3.9Mhz internal ADC clk.

// instantiation based on example from the V5 user guide.
SYSMONE1 #(
    .INIT_40(16'h3000), // Configuration register 0 (0x3000 means average 256 samples)
    .INIT_41(16'h2FDE), // Configuration register 1 (low bit disable overtemp shutdown)
    .INIT_42(16'h4000), // Configuration register 2 // ADC clock - DCLK/2
    .INIT_43(16'h0), // Test register 0
    .INIT_44(16'h0), // Test register 1
    .INIT_45(16'h0), // Test register 2
    .INIT_46(16'h0), // Test register 3
    .INIT_47(16'h0), // Test register 4
    .INIT_48(16'h7F01), // Sequence register 0
    .INIT_49(16'h0), // Sequence register 1
    .INIT_4A(16'h4F00), // ADC Channel Averaging Enables
    .INIT_4B(16'h0), // Sequence register 3
    .INIT_4C(16'h0), // Sequence register 4
    .INIT_4D(16'h0), // Sequence register 5
    .INIT_4E(16'h0), // Sequence register 6
    .INIT_4F(16'h0), // Sequence register 7
    .INIT_50(16'h0), // Alarm limit register 0
    .INIT_51(16'h0), // Alarm limit register 1
    .INIT_52(16'h0), // Alarm limit register 2
`ifdef XILINX_ULTRASCALE_PLUS // AC-511 (-2LE extended temp range VU7P 110C limit)
    .INIT_53(16'hC363), // Alarm limit register 3 0xC36X = 110 Celcius
`else //!XILINX_ULTRASCALE_PLUS - AC-510 (extended temp range KU060 100C limit)
    .INIT_53(16'hBE43), // Alarm limit register 3 0xBE4X = 100 Celcius
`endif //!XILINX_ULTRASCALE_PLUS - AC-510 (extended temp range KU060 100C limit)
    .INIT_54(16'h0), // Alarm limit register 4
    .INIT_55(16'h0), // Alarm limit register 5
    .INIT_56(16'h0), // Alarm limit register 6
    .INIT_57(16'h0)  // Alarm limit register 7
) my_sysmon (
    .BUSY(busy), // 1-bit output ADC busy signal
    .CHANNEL(channel[5:0]), // 6-bit output channel selection
    .DO(dobus[15:0]), // 16-bit output data bus for dynamic reconfig port
    .EOC(eoc),
    .DRDY(drdy),
    .DADDR({2'b0, channel[5:0]}),// 8-bit input address bus for dynamic reconfig
    .DCLK(s_clk), // 1-bit input clock for dynamic reconfig port
    .DEN(eoc), // 1-bit input enable for dynamic reconfig port
    .DWE(1'b0), // 1-bit input write enable for dynamic reconfig port
    .RESET(s_rst) // 1-bit input active high reset
);
`endif  // !XILINX_ULTRASCALE_PLUS
`else   // !XILINX_ULTRASCALE && !ALTERA_FPGA

assign channel[5] = 1'b0;

// AC-505 Kintex 7 & AC-510 Kintex UltraScale dclk can be 8-250MHz. 
// The internal ADC clk can be 1-5.2MHz for Kintex UltraScale and 
// 1-26Mhz for Kintex 7.
// Bits 8-15 of INIT_42 specify the divisor. 
// We'll use the 250Mhz stream clk (s_clk) for dclk and 
// we'll adjust the ADC divisor to 64 give us a valid ~3.9Mhz internal ADC clk.

// instantiation based on example from the V5 user guide.
SYSMON #(
    .INIT_40(16'h3000), // Configuration register 0 (0x3000 means average 256 samples)
    .INIT_41(16'h20FE), // Configuration register 1 (low bit disable overtemp shutdown)
    .INIT_42(16'h4000), // Configuration register 2
    .INIT_43(16'h0), // Test register 0
    .INIT_44(16'h0), // Test register 1
    .INIT_45(16'h0), // Test register 2
    .INIT_46(16'h0), // Test register 3
    .INIT_47(16'h0), // Test register 4
    .INIT_48(16'h0F01), // Sequence register 0
    .INIT_49(16'h0), // Sequence register 1
    .INIT_4A(16'h0), // Sequence register 2
    .INIT_4B(16'h0), // Sequence register 3
    .INIT_4C(16'h0), // Sequence register 4
    .INIT_4D(16'h0), // Sequence register 5
    .INIT_4E(16'h0), // Sequence register 6
    .INIT_4F(16'h0), // Sequence register 7
    .INIT_50(16'h0), // Alarm limit register 0
    .INIT_51(16'h0), // Alarm limit register 1
    .INIT_52(16'h0), // Alarm limit register 2
    .INIT_53(16'hB883), // Alarm limit register 3 0xB88X = 90 Celcius
    .INIT_54(16'h0), // Alarm limit register 4
    .INIT_55(16'h0), // Alarm limit register 5
    .INIT_56(16'h0), // Alarm limit register 6
    .INIT_57(16'h0)  // Alarm limit register 7
) my_sysmon (
    .BUSY(busy), // 1-bit output ADC busy signal
    .CHANNEL(channel[4:0]), // 5-bit output channel selection
    .DO(dobus[15:0]), // 16-bit output data bus for dynamic reconfig port
    .EOC(eoc),
    .DRDY(drdy),
    .DADDR({1'b0, channel[5:0]}),// 7-bit input address bus for dynamic reconfig
    .DCLK(s_clk), // 1-bit input clock for dynamic reconfig port
    .DEN(eoc), // 1-bit input enable for dynamic reconfig port
    .DWE(1'b0), // 1-bit input write enable for dynamic reconfig port
    .RESET(s_rst) // 1-bit input active high reset
);

`endif  // !XILINX_ULTRASCALE && !ALTERA_FPGA

endmodule
