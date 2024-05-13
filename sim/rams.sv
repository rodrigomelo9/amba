module rams #(
  parameter                 IWIDTH = 4,        // ID width (bits)
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size (2^DSIZE bytes)
  // hidden parameters
  parameter                 DBYTES = 1<<DSIZE, // Data bytes
  parameter                 DWIDTH = DBYTES*8  // Data width (bits)
) (
  input                     xclk,
  input                     xresetn,
  input                     psel,
  input                     penable,
  input        [2:0]        pprot,
  input                     pwrite,
  input        [AWIDTH-1:0] paddr,
  input        [DBYTES-1:0] pstrb,
  input        [DWIDTH-1:0] pwdata,
  output       [DWIDTH-1:0] prdata,
  output                    pready,
  output                    pslverr,
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
  output       [DWIDTH-1:0] hrdata,
  output                    hreadyout,
  output                    hresp,
  input        [IWIDTH-1:0] awid,
  input        [AWIDTH-1:0] awaddr,
  input        [7:0]        awlen,
  input        [2:0]        awsize,
  input        [1:0]        awburst,
  input                     awlock,
  input        [3:0]        awcache,
  input        [2:0]        awprot,
  input                     awvalid,
  output                    awready,
  input        [DWIDTH-1:0] wdata,
  input        [DBYTES-1:0] wstrb,
  input                     wlast,
  input                     wvalid,
  output                    wready,
  output       [IWIDTH-1:0] bid,
  output       [1:0]        bresp,
  output                    bvalid,
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
  output                    arready,
  output       [IWIDTH-1:0] rid,
  output       [DWIDTH-1:0] rdata,
  output       [1:0]        rresp,
  output                    rlast,
  output                    rvalid,
  input                     rready
);

  apb_ram #(
    .AWIDTH    ( AWIDTH    ),
    .DSIZE     ( DSIZE     )
  ) apb_ram (
    .pclk      ( xclk      ),
    .presetn   ( xresetn   ),
    .psel      ( psel      ),
    .penable   ( penable   ),
    .pprot     ( pprot     ),
    .pwrite    ( pwrite    ),
    .paddr     ( paddr     ),
    .pstrb     ( pstrb     ),
    .pwdata    ( pwdata    ),
    .prdata    ( prdata    ),
    .pready    ( pready    ),
    .pslverr   ( pslverr   )
  );

  ahb_ram #(
    .AWIDTH    ( AWIDTH    ),
    .DSIZE     ( DSIZE     )
  ) ahb_ram (
    .hclk      ( xclk      ),
    .hresetn   ( xresetn   ),
    .hsel      ( hsel      ),
    .hready    ( hready    ),
    .htrans    ( htrans    ),
    .hprot     ( hprot     ),
    .hburst    ( hburst    ),
    .hsize     ( hsize     ),
    .hmastlock ( hmastlock ),
    .hwrite    ( hwrite    ),
    .haddr     ( haddr     ),
    .hwdata    ( hwdata    ),
    .hrdata    ( hrdata    ),
    .hreadyout ( hreadyout ),
    .hresp     ( hresp     )
  );

  axi_ram #(
    .IWIDTH    ( IWIDTH    ),
    .AWIDTH    ( AWIDTH    ),
    .DSIZE     ( DSIZE     )
  ) axi_ram (
    .aclk      ( xclk      ),
    .aresetn   ( xresetn   ),
    .awid      ( awid      ),
    .awaddr    ( awaddr    ),
    .awlen     ( awlen     ),
    .awsize    ( awsize    ),
    .awburst   ( awburst   ),
    .awlock    ( awlock    ),
    .awcache   ( awcache   ),
    .awprot    ( awprot    ),
    .awvalid   ( awvalid   ),
    .awready   ( awready   ),
    .wdata     ( wdata     ),
    .wstrb     ( wstrb     ),
    .wlast     ( wlast     ),
    .wvalid    ( wvalid    ),
    .wready    ( wready    ),
    .bid       ( bid       ),
    .bresp     ( bresp     ),
    .bvalid    ( bvalid    ),
    .bready    ( bready    ),
    .arid      ( arid      ),
    .araddr    ( araddr    ),
    .arlen     ( arlen     ),
    .arsize    ( arsize    ),
    .arburst   ( arburst   ),
    .arlock    ( arlock    ),
    .arcache   ( arcache   ),
    .arprot    ( arprot    ),
    .arvalid   ( arvalid   ),
    .arready   ( arready   ),
    .rid       ( rid       ),
    .rdata     ( rdata     ),
    .rresp     ( rresp     ),
    .rlast     ( rlast     ),
    .rvalid    ( rvalid    ),
    .rready    ( rready    )
  );

endmodule
