#
# Copyright (c) 2024, Rodrigo Alejandro Melo
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# SPDX-License-Identifier: ISC
#

from cocotb.triggers import RisingEdge

#
# APB
#

class APBM():

    def __init__(self, dut, clk):
        self.dut = dut
        self.clk = clk
        self.idle()

    def idle(self):
        self.dut.psel.value = 0
        self.dut.penable.value = 0
        self.dut.paddr.value = 0
        self.dut.pprot.value = 0
        self.dut.pwrite.value = 0
        self.dut.pstrb.value = 0
        self.dut.pwdata.value = 0

    async def write(self, addr, data):
        self.dut.psel.value = 1
        self.dut.paddr.value = addr
        self.dut.pwrite.value = 1
        self.dut.pstrb.value = 0xF
        for i in range(len(data)):
            self.dut.pwdata.value = data[i]
            await RisingEdge(self.clk)
            self.dut.penable.value = 1
            await RisingEdge(self.clk)
            while not self.dut.pready.value:
                await RisingEdge(self.clk)
            if i < len(data)-1:
                self.dut.paddr.value = self.dut.paddr.value+4
                self.dut.penable.value = 0
        self.idle()

    async def read(self, addr, length):
        resp = []
        self.dut.psel.value = 1
        self.dut.paddr.value = addr
        for i in range(length):
            await RisingEdge(self.clk)
            self.dut.penable.value = 1
            await RisingEdge(self.clk)
            while not self.dut.pready.value:
                await RisingEdge(self.clk)
            resp.append(self.dut.prdata.value)
            if i < length-1:
                self.dut.paddr.value = self.dut.paddr.value+4
                self.dut.penable.value = 0
        self.idle()
        return resp

#
# APB
#

class AHBM():

    def __init__(self, dut, clk):
        self.dut = dut
        self.clk = clk
        self.idle()

    def idle(self):
        self.dut.hsel.value = 0
        self.dut.hready.value = 1
        self.dut.haddr.value = 0
        self.dut.htrans.value = 0
        self.dut.hprot.value = 0
        self.dut.hburst.value = 0
        self.dut.hsize.value = 2
        self.dut.hmastlock.value = 0
        self.dut.hwrite.value = 0
        self.dut.hwdata.value = 0

    async def write(self, addr, data):
        self.dut.hsel.value = 1
        self.dut.haddr.value = addr
        self.dut.htrans.value = 2
        self.dut.hwrite.value = 1
        for i in range(len(data)):
            await RisingEdge(self.clk)
            while not self.dut.hreadyout.value:
                await RisingEdge(self.clk)
            if i < len(data)-1:
                self.dut.haddr.value = self.dut.haddr.value+4
                self.dut.htrans.value = 3
            else:
                self.idle()
            self.dut.hwdata.value = data[i]
        await RisingEdge(self.clk)
        while not self.dut.hreadyout.value:
            await RisingEdge(self.clk)
        self.idle()

    async def read(self, addr, length):
        resp = []
        self.dut.hsel.value = 1
        self.dut.haddr.value = addr
        self.dut.htrans.value = 2
        for i in range(length):
            await RisingEdge(self.clk)
            while not self.dut.hreadyout.value:
                await RisingEdge(self.clk)
            if i < length-1:
                self.dut.haddr.value = self.dut.haddr.value+4
                self.dut.htrans.value = 3
            else:
                self.idle()
            if i > 0:
                resp.append(self.dut.hrdata.value)
        await RisingEdge(self.clk)
        while not self.dut.hreadyout.value:
            await RisingEdge(self.clk)
        resp.append(self.dut.hrdata.value)
        self.idle()
        return resp

#
# AXI
#

class AXIM():

    def __init__(self, dut, clk):
        self.dut = dut
        self.clk = clk
        self.idle()

    def idle(self):
        self.dut.awid.value    = 0
        self.dut.awaddr.value  = 0
        self.dut.awlen.value   = 0
        self.dut.awsize.value  = 2
        self.dut.awburst.value = 1
        self.dut.awlock.value  = 0
        self.dut.awcache.value = 0
        self.dut.awprot.value  = 0
        self.dut.awvalid.value = 0
        self.dut.wdata.value   = 0
        self.dut.wstrb.value   = 0
        self.dut.wlast.value   = 0
        self.dut.wvalid.value  = 0
        self.dut.bready.value  = 0
        self.dut.arid.value    = 0
        self.dut.araddr.value  = 0
        self.dut.arlen.value   = 0
        self.dut.arsize.value  = 2
        self.dut.arburst.value = 1
        self.dut.arlock.value  = 0
        self.dut.arcache.value = 0
        self.dut.arprot.value  = 0
        self.dut.arvalid.value = 0
        self.dut.rready.value  = 0

    async def write(self, addr, data):
        self.dut.awvalid.value = 1
        self.dut.wvalid.value = 1
        self.dut.bready.value = 1
        self.dut.awaddr.value = addr
        self.dut.awlen.value = len(data)-1
        for i in range(len(data)):
            self.dut.wstrb.value = 0xF
            self.dut.wdata.value = data[i]
            self.dut.wlast.value = (i == (len(data)-1))
            await RisingEdge(self.clk)
            while not self.dut.wready.value:
               await RisingEdge(self.clk)
        while not self.dut.bvalid.value:
            await RisingEdge(self.clk)
        self.idle()

    async def read(self, addr, length):
        resp = []
        self.dut.arvalid.value = 1
        self.dut.rready.value = 1
        self.dut.araddr.value = addr
        self.dut.arlen.value = length-1
        for i in range(length):
            await RisingEdge(self.clk)
            while not self.dut.rvalid.value:
               await RisingEdge(self.clk)
            resp.append(self.dut.rdata.value)
        self.idle()
        return resp
