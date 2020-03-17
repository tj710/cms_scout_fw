
`timescale 1 ns / 1 ps

// ===================================================================
// axilite_to_picobus module
// convert 32-bit axi lite (slave) protocol to pico bus (master)
//
// assume AW and W channel tied together, AW->W->B
// assign simplex, no simultaneous Write and Read
// ===================================================================

module axilite_to_picobus #
(
    // Users to add parameters here

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_DATA_WIDTH    = 32,
    parameter integer C_ADDR_WIDTH    = 32
)
(
    // Users to add ports here
    // Master picobus 
    pico_bus_if                                  pico_bus     ,
 
    axi_if                                       s00_axi     

);

`default_nettype none
    // Add user logic here

    wire                                 clk           ; 
    wire                                 rst           ;
    // registers
    (* MARK_DEBUG="TRUE" *) logic  [C_ADDR_WIDTH-1 : 0]          pico_addr_reg      ;
    (* MARK_DEBUG="TRUE" *) logic                                new_rd_reg         ;
    (* MARK_DEBUG="TRUE" *) logic                                pico_rd_reg        ;
    (* MARK_DEBUG="TRUE" *) logic  [C_DATA_WIDTH-1 : 0]          pico_rd_data_reg   ;
    (* MARK_DEBUG="TRUE" *) logic                                s00_axi_rvalid_reg ;
    (* MARK_DEBUG="TRUE" *) logic                                s00_axi_bvalid_reg ;

    // 
    assign clk            = s00_axi.clk    ;
    assign rst            = s00_axi.rst    ;
    assign pico_bus.clk   = clk            ;
    assign pico_bus.rst   = rst            ;

    // ---------------------------------------------------------------
    //  B channel, returns bvalid after wvalid
    // ---------------------------------------------------------------
    assign s00_axi.bvalid      = s00_axi_bvalid_reg ;
    always @ (posedge clk) begin
        s00_axi_bvalid_reg     <= s00_axi_bvalid_reg ;
        // if valid write, as we are always ready, return bvalid
        if (s00_axi.wvalid) begin
            s00_axi_bvalid_reg <= 1'b1 ;
        end
        // if bready, de-assert bvalid
        if (s00_axi.bready & s00_axi_bvalid_reg) begin
            s00_axi_bvalid_reg <= 1'b0 ;
        end
    end

    // ---------------------------------------------------------------
    // AR, AW channel, register awaddr or araddr
    // ---------------------------------------------------------------
    assign pico_bus.addr               = pico_addr_reg    ;  //
    assign s00_axi.awready             = 1'b1 ;  // always ready
    assign s00_axi.arready             = 1'b1 ;  // always ready
    always @ (posedge clk) begin
            pico_addr_reg              <= pico_addr_reg  ;

            // if valid aw, reg addr
            if (s00_axi.awvalid) begin
                pico_addr_reg          <= s00_axi.awaddr ;
            end

            // if valid ar, reg addr,
            if (s00_axi.arvalid) begin
                pico_addr_reg          <= s00_axi.araddr ;
            end
    end

    // ---------------------------------------------------------------
    // W channel, straight through, to sync with registered pico_addr_reg
    // ---------------------------------------------------------------
    always @ (posedge clk) begin
        pico_bus.wr                    <= s00_axi.wvalid ;
        pico_bus.wr_data               <= s00_axi.wdata  ;  // 
    end 
    assign s00_axi.wready      = 1'b1             ;  // always ready
        
    // ---------------------------------------------------------------
    // R channel
    // ---------------------------------------------------------------
    assign pico_bus.rd         = pico_rd_reg        ;
    assign s00_axi.rvalid      = s00_axi_rvalid_reg ;
    assign s00_axi.rdata       = (s00_axi_rvalid_reg & s00_axi.rready)? pico_bus.rd_data: pico_rd_data_reg ;  // 
    always @ (posedge clk) begin
        if (rst) begin
            pico_rd_reg                  <= 1'b0               ;
            new_rd_reg                   <= 1'b0               ;
            s00_axi_rvalid_reg           <= 1'b0               ;
            pico_rd_data_reg             <= 0                  ;
        end else begin
            pico_rd_reg                  <= 1'b0               ; // audo de-assert RD
            new_rd_reg                   <= new_rd_reg         ;
            s00_axi_rvalid_reg           <= s00_axi_rvalid_reg ; //
            pico_rd_data_reg             <= pico_rd_data_reg   ;

            // if valid ar, assert read next cycle
            if (s00_axi.arvalid) begin
                pico_rd_reg              <= 1'b1               ; // RD 1 cycle
            end

            // if read, set valid next cycle
            if (pico_rd_reg) begin
                s00_axi_rvalid_reg       <= 1'b1               ; //
                new_rd_reg               <= 1'b1               ;
            end

            // if read data is valid and
            if (s00_axi_rvalid_reg) begin
                if (s00_axi.rready) begin
                    s00_axi_rvalid_reg   <= 1'b0               ; //
                end else if (new_rd_reg) begin
                    pico_rd_data_reg     <= pico_bus.rd_data   ;
                    new_rd_reg           <= 1'b0               ; // no new data
                end
            end
        end
    end

    // User logic ends
`default_nettype wire

endmodule

