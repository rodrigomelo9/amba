import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles
from amba import APBM, AHBM, AXIM

SINGLE = [0x11223344]
MULTIPLE = [0x11111111, 0x22222222, 0x33333333, 0x44444444]

@cocotb.test(timeout_time=100, timeout_unit='ps')
async def test_apb(dut):
    cocotb.start_soon(Clock(dut.xclk, 2).start())
    apbm = APBM(dut, dut.xclk)
    await reset(dut)
    await apbm.write(0x10, SINGLE)
    await RisingEdge(dut.xclk)
    resp = await apbm.read(0x10, len(SINGLE))
    assert resp == SINGLE, 'ERROR'
    await RisingEdge(dut.xclk)
    await apbm.write(0x20, MULTIPLE)
    resp = await apbm.read(0x20, len(MULTIPLE))
    assert resp == MULTIPLE, 'ERROR'
    await RisingEdge(dut.xclk)

@cocotb.test(timeout_time=100, timeout_unit='ps')
async def test_ahb(dut):
    cocotb.start_soon(Clock(dut.xclk, 2).start())
    ahbm = AHBM(dut, dut.xclk)
    await reset(dut)
    await ahbm.write(0x10, SINGLE)
    await RisingEdge(dut.xclk)
    resp = await ahbm.read(0x10, len(SINGLE))
    assert resp == SINGLE, 'ERROR'
    await RisingEdge(dut.xclk)
    await ahbm.write(0x20, MULTIPLE)
    resp = await ahbm.read(0x20, len(MULTIPLE))
    assert resp == MULTIPLE, 'ERROR'
    await RisingEdge(dut.xclk)

@cocotb.test(timeout_time=100, timeout_unit='ps')
async def test_axi(dut):
    cocotb.start_soon(Clock(dut.xclk, 2).start())
    axim = AXIM(dut, dut.xclk)
    await reset(dut)
    await axim.write(0x10, SINGLE)
    await RisingEdge(dut.xclk)
    resp = await axim.read(0x10, len(SINGLE))
    assert resp == SINGLE, 'ERROR'
    await RisingEdge(dut.xclk)
    await axim.write(0x20, MULTIPLE)
    resp = await axim.read(0x20, len(MULTIPLE))
    assert resp == MULTIPLE, 'ERROR'
    await RisingEdge(dut.xclk)

async def reset(dut):
    dut.xresetn.value = 0
    await ClockCycles(dut.xclk, 2)
    dut.xresetn.value = 1
    await RisingEdge(dut.xclk)
