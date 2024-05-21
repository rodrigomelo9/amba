//
// Copyright (c) 2024, Rodrigo Alejandro Melo
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// SPDX-License-Identifier: ISC
//

module apb_stub #(
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size
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
  output logic [DWIDTH-1:0] prdata,
  output                    pready,
  output                    pslverr
);

  always @(posedge pclk) begin
    integer i;
    if (psel & penable & pwrite) begin
      for (i=0; i<DBYTES; i++) begin
        if (pstrb[i]) begin
          prdata[i*8+:8] <= pwdata[i*8+:8];
        end
      end
    end
  end

  assign pready  = '1;
  assign pslverr = '0;

endmodule

module ahb_stub #(
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size
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

  logic                  selected;

  always @(posedge hclk) begin
    selected <= hsel & htrans[1] & hwrite;
    if (selected) begin
      hrdata <= hwdata;
    end
  end

  assign hreadyout = '1;
  assign hresp     = '0;

endmodule

module axi_stub #(
  parameter                 IWIDTH = 4,        // ID width (bits)
  parameter                 AWIDTH = 10,       // Address width (bits)
  parameter    [2:0]        DSIZE  = 2,        // Data size (2^DSIZE bytes)
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
  output logic [DWIDTH-1:0] rdata,
  output       [1:0]        rresp,
  output                    rlast,
  output logic              rvalid,
  input                     rready
);

  logic [7:0]            rd_len;

  //-- Write ------------------------------------------------------------------

  always @(posedge aclk, negedge aresetn) begin
    if (!aresetn) begin
      awready <= '1;
      wready  <= '0;
      bvalid  <= '0;
    end else begin
      if (awready) begin
        if (awvalid) begin
          bid      <= awid;
          awready  <= '0;
          wready   <= '1;
        end
      end else begin
        if (!bvalid) begin
          if (wvalid) begin
            rdata <= wdata;
            if (wlast) begin
              wready  <= '0;
              bvalid  <= '1;
            end
          end
        end else begin
          awready <= '1;
          bvalid  <= '0;
        end
      end
    end
  end

  assign bresp = '0;

  //-- Read -------------------------------------------------------------------

  always @(posedge aclk, negedge aresetn) begin
    if (!aresetn) begin
      arready <= '1;
      rvalid  <= '0;
    end else begin
      if (arready) begin
        if (arvalid) begin
          rid      <= arid;
          rd_len   <= arlen;
          arready  <= '0;
          rvalid   <= '1;
        end
      end else begin
        if (rready) begin
          if (rlast) begin
            arready <= '1;
            rvalid  <= '0;
          end else begin
            rd_len  <= rd_len - 1;
          end
        end
      end
    end
  end

  assign rresp = '0;
  assign rlast = (rd_len == '0);

endmodule
