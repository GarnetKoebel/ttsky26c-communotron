# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 2.5, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    dut.ui_in.value = 0b00000011 # set SDA and SCL to 1
    #dut.ui_in[1] = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Test project behavior")
    dut.ui_in.value = 0b00000010 # set SDA low
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0b00000000 # set SCL low
    await ClockCycles(dut.clk, 2)
    dut._log.info("Checking Start Detected")

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 0x01

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
