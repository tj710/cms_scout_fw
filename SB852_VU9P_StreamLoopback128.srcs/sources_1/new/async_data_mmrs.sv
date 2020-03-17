module async_data_mmrs
  #(parameter
    MR_DWIDTH             = 32,  // Width of data in incoming stream
    MR_AWIDTH             = 5,   // Width of address in incoming stream
    STREAM_AXI4LITE_WIDTH = 128,
    C_S00_AXI_ADDR_WIDTH  = 36,  // AXI address width
    C_S00_AXI_DATA_WIDTH  = 32,   // AXI data width
    RSVD_FOR_IE_CSRS      = 80)  // Contiguous length of address space (0x0 indexed) used by IE
   (
    input                                     clk,
    input                                     rst,

    input                                     s1i_valid,
    output                                    s1i_rdy,
    input      [STREAM_AXI4LITE_WIDTH-1:0]    s1i_data,

    output reg                                s1o_valid,
    input                                     s1o_rdy,
    output reg [STREAM_AXI4LITE_WIDTH-1:0]    s1o_data,

    // Ports of Axi Slave Bus Interface S00_AXI
    input                                     s00_axi_aclk,
    input                                     s00_axi_aresetn,
    input      [C_S00_AXI_ADDR_WIDTH-1:0]     s00_axi_awaddr,
    input      [2:0]                          s00_axi_awprot,
    input                                     s00_axi_awvalid,
    output                                    s00_axi_awready,

    input      [C_S00_AXI_DATA_WIDTH-1:0]     s00_axi_wdata,
    input      [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb,
    input                                     s00_axi_wvalid,
    output                                    s00_axi_wready,

    output     [1:0]                          s00_axi_bresp,
    output                                    s00_axi_bvalid,
    input                                     s00_axi_bready,

    input      [C_S00_AXI_ADDR_WIDTH-1:0]     s00_axi_araddr,
    input      [2:0]                          s00_axi_arprot,
    input                                     s00_axi_arvalid,
    output                                    s00_axi_arready,

    output     [C_S00_AXI_DATA_WIDTH-1:0]     s00_axi_rdata,
    output     [1:0]                          s00_axi_rresp,
    output                                    s00_axi_rvalid,
    input                                     s00_axi_rready
);

    localparam BUF_A_FULL  = RSVD_FOR_IE_CSRS - 1 + 1;
    localparam BUF_B_FULL  = RSVD_FOR_IE_CSRS - 1 + 2;
    localparam BUF_A_START = RSVD_FOR_IE_CSRS - 1 + 3;
    localparam BUF_B_START = RSVD_FOR_IE_CSRS - 1 + 4;
    localparam BUF_LENGTH  = RSVD_FOR_IE_CSRS - 1 + 5;

    reg                             async_buf_a_full,  async_buf_b_full;
    reg  [C_S00_AXI_ADDR_WIDTH-1:0] async_buf_a_start, async_buf_b_start;
    reg  [C_S00_AXI_ADDR_WIDTH-1:0] async_buf_length;

    reg  [MR_DWIDTH-1:0]            st_mr_wr_data;
    reg  [MR_AWIDTH-1:0]            st_mr_wr_addr;
    reg                             st_mr_wr_en;

    wire [MR_DWIDTH-1:0]            st_mr_rd_data;
    reg  [MR_AWIDTH-1:0]            st_mr_rd_addr;
    reg                             st_mr_rd_en;

    wire [MR_DWIDTH-1:0]            axi_mr_wr_data;
    wire [MR_AWIDTH-1:0]            axi_mr_wr_addr;
    wire                            axi_mr_wr_en;

    wire [MR_DWIDTH-1:0]            axi_mr_rd_data;
    wire [MR_AWIDTH-1:0]            axi_mr_rd_addr;

    // Logic to take the data from the protocol interfaces and apply to the
    // MMRs. In the case of a conflict, stream (host) gets priority.
    always @(posedge clk) begin
        if (st_mr_wr_en) begin
            case (st_mr_wr_addr)
                BUF_A_FULL:  async_buf_a_full  <= st_mr_wr_data;
                BUF_B_FULL:  async_buf_b_full  <= st_mr_wr_data;
                BUF_A_START: async_buf_a_start <= st_mr_wr_data;
                BUF_B_START: async_buf_b_start <= st_mr_wr_data;
                BUF_LENGTH:  async_buf_length  <= st_mr_wr_data;
            endcase
            
        end else begin if (axi_mr_wr_en) begin
            case (axi_mr_wr_addr)
                BUF_A_FULL:  async_buf_a_full  <= axi_mr_wr_data;
                BUF_B_FULL:  async_buf_b_full  <= axi_mr_wr_data;
                BUF_A_START: async_buf_a_start <= axi_mr_wr_data;
                BUF_B_START: async_buf_b_start <= axi_mr_wr_data;
                BUF_LENGTH:  async_buf_length  <= axi_mr_wr_data;
            endcase
            end
        end
    end
    

    // Logic to apply data from the MMRs to the stream.
    always @(*) begin
        case (st_mr_rd_addr)
            BUF_A_FULL:  st_mr_rd_data = async_buf_a_full;
            BUF_B_FULL:  st_mr_rd_data = async_buf_b_full;
            BUF_A_START: st_mr_rd_data = async_buf_a_start;
            BUF_B_START: st_mr_rd_data = async_buf_b_start;
            BUF_LENGTH:  st_mr_rd_data = async_buf_length;
        endcase
    end

    // Logic to apply data from the MMRs to AXI
    always @(*) begin
        case (axi_mr_rd_addr)
            BUF_A_FULL:  st_mr_rd_data = async_buf_a_full;
            BUF_B_FULL:  st_mr_rd_data = async_buf_b_full;
            BUF_A_START: st_mr_rd_data = async_buf_a_start;
            BUF_B_START: st_mr_rd_data = async_buf_b_start;
            BUF_LENGTH:  st_mr_rd_data = async_buf_length;
        endcase
    end

    wire axi_mr_addr;
    assign axi_mr_wr_addr = axi_mr_addr;
    assign axi_mr_rd_addr = axi_mr_addr;

    // Convert AXI to MMR interface
    async_data_mmrs_axi_interface # (
        .C_S_AXI_DATA_WIDTH (C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH (C_S00_AXI_ADDR_WIDTH)
    ) axi_slave_interface (
        .clock              (),
        .resetb             (),

        .Addr               (axi_mr_addr),
        .WrData             (axi_mr_wr_data),
        .WrEn               (axi_mr_wr_en),
        .WrStrobe           (),
        .RdData             (axi_mr_rd_en),

        .S_AXI_ACLK         (s00_axi_aclk),
        .S_AXI_ARESETN      (s00_axi_aresetn),
        .S_AXI_AWADDR       (s00_axi_awaddr),
        .S_AXI_AWPROT       (s00_axi_awprot),
        .S_AXI_AWVALID      (s00_axi_awvalid),
        .S_AXI_AWREADY      (s00_axi_awready),
        .S_AXI_WDATA        (s00_axi_wdata),
        .S_AXI_WSTRB        (s00_axi_wstrb),
        .S_AXI_WVALID       (s00_axi_wvalid),
        .S_AXI_WREADY       (s00_axi_wready),
        .S_AXI_BRESP        (s00_axi_bresp),
        .S_AXI_BVALID       (s00_axi_bvalid),
        .S_AXI_BREADY       (s00_axi_bready),
        .S_AXI_ARADDR       (s00_axi_araddr),
        .S_AXI_ARPROT       (s00_axi_arprot),
        .S_AXI_ARVALID      (s00_axi_arvalid),
        .S_AXI_ARREADY      (s00_axi_arready),
        .S_AXI_RDATA        (s00_axi_rdata),
        .S_AXI_RRESP        (s00_axi_rresp),
        .S_AXI_RVALID       (s00_axi_rvalid),
        .S_AXI_RREADY       (s00_axi_rready)
    );

    // Convert stream to MMR interface
    assign s1i_rdy = 1'b1;

    // Since IO interface is stream, we will use some part of the stream input
    // as address, some as rd/wr command and some as data
    // We choose bits 0:MR_DWIDTH as data, MR_DWIDTH:(MR_DWIDTH+MR_AWIDTH) as addr
    // and STREAM_AXI4LITE_WIDTH-1 as command 0/1 == RD/WR
    always @(posedge clk) begin
        if (rst) begin
            st_mr_wr_data <= 'b0;
            st_mr_wr_addr <= 'b0;
            st_mr_wr_en   <= 'b0;

            st_mr_rd_addr <= 'b0;
            st_mr_rd_en   <= 'b0;
        end
        else begin
            st_mr_wr_data <= 'b0;
            st_mr_wr_addr <= 'b0;
            st_mr_wr_en   <= 'b0;

            st_mr_rd_addr <= 'b0;
            st_mr_rd_en   <= 'b0;
            if (s1i_valid) begin
                st_mr_wr_data <= s1i_data[0+:MR_DWIDTH];
                st_mr_wr_addr <= s1i_data[MR_DWIDTH+:MR_AWIDTH];
                st_mr_wr_en   <= s1i_data[STREAM_AXI4LITE_WIDTH-1];

                st_mr_rd_addr <= s1i_data[MR_DWIDTH+:MR_AWIDTH];
                st_mr_rd_en   <= !s1i_data[STREAM_AXI4LITE_WIDTH-1];
            end
        end
    end

    // Read data to stream interface
    always @(posedge clk) begin
        if (rst) begin
            s1o_valid <= 'b0;
            s1o_data  <= 'b0;
        end
        else begin
            if (st_mr_rd_en) begin
                s1o_valid <= 1'b1;
                s1o_data  <= st_mr_rd_data;
            end
            else if (s1o_rdy) begin
                s1o_valid <= 1'b0;
                
            end
        end
    end

