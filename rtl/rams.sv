module apb_ram #(
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size
  parameter                 IBIN   = "",       // Initial memory content file (bin format)
  parameter                 IHEX   = "" ,      // Initial memory content file (hex format)
  // hidden parameters
  parameter                 DBYTES = 1<<DSIZE, // Data bytes
  parameter                 DWIDTH = DBYTES*8  // Data width (bits)
) (
  input                     pclk,
  input                     presetn,
  input                     psel,
  input                     penable,
  input        [2:0]        pprot,
  input                     pwrite,
  input        [AWIDTH-1:0] paddr,
  input        [DBYTES-1:0] pstrb,
  input        [DWIDTH-1:0] pwdata,
  output       [DWIDTH-1:0] prdata,
  output                    pready,
  output                    pslverr
);

  localparam MEM_AWIDTH = AWIDTH - DSIZE;
  localparam MEM_DEPTH  = 1 << MEM_AWIDTH;

  (* ram_decomp = "power" *) logic [DWIDTH-1:0] mem [0:MEM_DEPTH-1];

  initial begin
    integer i;
    if (IBIN != "")
      $readmemb(IBIN, mem);
    else if (IHEX != "")
      $readmemh(IHEX, mem);
    else
      for (i=0; i<MEM_DEPTH; i++) mem[i] = 0;
  end

  logic [MEM_AWIDTH-1:0] mem_addr;
  assign mem_addr = paddr >> DSIZE;

  assign prdata  = mem[mem_addr];
  assign pready  = '1;
  assign pslverr = '0;

  always @(posedge pclk) begin
    integer i;
    if (psel & penable & pwrite) begin
      for (i=0; i<DBYTES; i++) begin
        if (pstrb[i]) begin
          mem[mem_addr][i*8+:8] <= pwdata[i*8+:8];
        end
      end
    end
  end

endmodule

module ahb_ram #(
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size
  parameter                 IBIN   = "",       // Initial memory content file (bin format)
  parameter                 IHEX   = "" ,      // Initial memory content file (hex format)
  // hidden parameters
  parameter                 DBYTES = 1<<DSIZE, // Data bytes
  parameter                 DWIDTH = DBYTES*8  // Data width (bits)
) (
  input                     hclk,
  input                     hresetn,
  input                     hsel,
  input                     hready,
  input        [1:0]        htrans,
  input        [3:0]        hprot,
  input        [2:0]        hburst,
  input        [2:0]        hsize,
  input                     hmastlock,
  input                     hwrite,
  input        [AWIDTH-1:0] haddr,
  input        [DWIDTH-1:0] hwdata,
  output logic [DWIDTH-1:0] hrdata,
  output                    hreadyout,
  output                    hresp
);

  localparam MEM_AWIDTH = AWIDTH - DSIZE;
  localparam MEM_DEPTH  = 1 << MEM_AWIDTH;

  (* ram_decomp = "power" *) logic [DWIDTH-1:0] mem [0:MEM_DEPTH-1];

  initial begin
    integer i;
    if (IBIN != "")
      $readmemb(IBIN, mem);
    else if (IHEX != "")
      $readmemh(IHEX, mem);
    else
      for (i=0; i<MEM_DEPTH; i++) mem[i] = 0;
  end

  logic selected;

  logic [MEM_AWIDTH-1:0] mem_addr;
  assign mem_addr = haddr >> DSIZE;

  assign hrdata    = mem[mem_addr];
  assign hreadyout = '1;
  assign hresp     = '0;

  always @(posedge hclk) begin
    selected <= hsel & htrans[1] & hwrite;
    if (selected) begin
      mem[mem_addr] <= hwdata;
    end
  end

endmodule

module axi_ram #(
  parameter                 IWIDTH = 4,        // ID width (bits)
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size (2^DSIZE bytes)
  parameter                 IBIN   = "",       // Initial memory content file (bin format)
  parameter                 IHEX   = "" ,      // Initial memory content file (hex format)
  // hidden parameters
  parameter                 DBYTES = 1<<DSIZE, // Data bytes
  parameter                 DWIDTH = DBYTES*8  // Data width (bits)
) (
  input                     aclk,
  input                     aresetn,
  input        [IWIDTH-1:0] awid,
  input        [AWIDTH-1:0] awaddr,
  input        [7:0]        awlen,
  input        [2:0]        awsize,
  input        [1:0]        awburst,
  input                     awlock,
  input        [3:0]        awcache,
  input        [2:0]        awprot,
  input                     awvalid,
  output logic              awready,
  input        [DWIDTH-1:0] wdata,
  input        [DBYTES-1:0] wstrb,
  input                     wlast,
  input                     wvalid,
  output logic              wready,
  output logic [IWIDTH-1:0] bid,
  output       [1:0]        bresp,
  output logic              bvalid,
  input                     bready,
  input        [IWIDTH-1:0] arid,
  input        [AWIDTH-1:0] araddr,
  input        [7:0]        arlen,
  input        [2:0]        arsize,
  input        [1:0]        arburst,
  input                     arlock,
  input        [3:0]        arcache,
  input        [2:0]        arprot,
  input                     arvalid,
  output logic              arready,
  output logic [IWIDTH-1:0] rid,
  output       [DWIDTH-1:0] rdata,
  output       [1:0]        rresp,
  output                    rlast,
  output logic              rvalid,
  input                     rready
);

  localparam MEM_AWIDTH = AWIDTH - DSIZE;
  localparam MEM_DEPTH  = 1 << MEM_AWIDTH;

  (* ram_decomp = "power" *) logic [DWIDTH-1:0] mem [0:MEM_DEPTH-1];

  initial begin
    integer i;
    if (IBIN != "")
      $readmemb(IBIN, mem);
    else if (IHEX != "")
      $readmemh(IHEX, mem);
    else
      for (i=0; i<MEM_DEPTH; i++) mem[i] = 0;
  end

  //-- Write ------------------------------------------------------------------

  logic [AWIDTH-1:0]     wr_addr;
  logic [7:0]            wr_len;
  logic [2:0]            wr_size;
  logic [1:0]            wr_burst;

  logic [MEM_AWIDTH-1:0] mem_wr_addr;
  assign mem_wr_addr = wr_addr >> DSIZE;

  assign bresp = '0;

  always @(posedge aclk, negedge aresetn) begin
    integer i;
    if (!aresetn) begin
      awready <= '1;
      wready  <= '0;
      bvalid  <= '0;
    end else begin
      if (awready) begin
        if (awvalid) begin
          bid      <= awid;
          wr_addr  <= awaddr;
          wr_len   <= awlen;
          wr_size  <= awsize;
          wr_burst <= awburst;
          awready  <= '0;
          wready   <= '1;
        end
      end else begin
        if (!bvalid) begin
          if (wvalid) begin
            for (i=0; i<DBYTES; i++) begin
              if (wstrb[i]) begin
                mem[mem_wr_addr][8*i+:8] <= wdata[8*i+:8];
              end
            end
            if (wlast) begin
              wready  <= '0;
              bvalid  <= '1;
            end else begin
              wr_addr <= (wr_burst != 2'b00) ? wr_addr + (1 << wr_size) : wr_addr;
              wr_len <= wr_len - 1;
            end
          end
        end else begin
          awready <= '1;
          bvalid  <= '0;
        end
      end
    end
  end

  // bvalid = bvalid && !bready;

  //-- Read -------------------------------------------------------------------

  logic [AWIDTH-1:0]     rd_addr;
  logic [7:0]            rd_len;
  logic [2:0]            rd_size;
  logic [1:0]            rd_burst;

  logic [MEM_AWIDTH-1:0] mem_rd_addr;
  assign mem_rd_addr = rd_addr >> DSIZE;

  assign rresp = '0;
  assign rdata = mem[mem_rd_addr];
  assign rlast = (rd_len == '0);

  always @(posedge aclk, negedge aresetn) begin
    if (!aresetn) begin
      arready <= '1;
      rvalid  <= '0;
    end else begin
      if (arready) begin
        if (arvalid) begin
          rid      <= arid;
          rd_addr  <= araddr;
          rd_len   <= arlen;
          rd_size  <= arsize;
          rd_burst <= arburst;
          arready  <= '0;
          rvalid   <= '1;
        end
      end else begin
        if (rready) begin
          if (rlast) begin
            arready <= '1;
            rvalid  <= '0;
          end else begin
            rd_addr <= (rd_burst != 2'b00) ? rd_addr + (1 << rd_size) : rd_addr;
            rd_len <= rd_len - 1;
          end
        end
      end
    end
  end

endmodule
