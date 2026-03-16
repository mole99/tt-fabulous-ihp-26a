# SPDX-FileCopyrightText: © 2025 Leo Moser <leomoser99@gmail.com>
# SPDX-License-Identifier: Apache-2.0

import os
import re
import sys
import math
import random
from pathlib import Path
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer, Edge, RisingEdge, FallingEdge
from cocotb.regression import TestFactory
from cocotb_tools.runner import get_runner
from cocotb.types import LogicArray, Logic

proj_path = Path(__file__).resolve().parent
fabric = os.getenv("FABRIC", "tiny_fabric_5x5")
tile_library = os.getenv("TILE_LIBRARY", "tiny")

async def upload_bitstream(dut, bitstream_path):
    
    with open(bitstream_path, 'br') as f:
        # Wait for start of bitstream
        while data := f.read(4):
            word = int.from_bytes(data, "big")
            print(data)
            
            for i in range(32):
                bit = word >> (31-i) & 0x1
                
                # Set the bit, sample 0
                dut.ui_in.value = bit << 1 | 0
                
                await RisingEdge(dut.clk)
                
                # Set the bit, sample 1
                dut.ui_in.value = bit << 1 | 1

                await RisingEdge(dut.clk)

@cocotb.test()
async def test_top_addition(dut):
    """Load bitstream for top_addition"""

    cocotb.start_soon(Clock(dut.clk, 10, 'ns').start())

    # Reset configuration
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # Enable configuration
    dut.rst_n.value = 0

    # Upload the bitstream
    await upload_bitstream(dut, proj_path / f'../user_designs/designs/{tile_library}/top_addition/top_addition.bit')
    await ClockCycles(dut.clk, 10)
    
    # Disable configuration
    dut.rst_n.value = 1

    for i in range(32):
        # Get a random value
        value_a = random.randint(0, 2**len(dut.ui_in.value)-1)
        value_b = random.randint(0, 2**len(dut.uio_in.value)-1)
        
        result = (value_a + value_b) & 0xFF

        dut.ui_in.value = value_a
        dut.uio_in.value = value_b

        await RisingEdge(dut.clk)
        assert dut.uo_out.value == result

@cocotb.test()
async def test_top_counter(dut):
    """Load bitstream for top_counter"""

    cocotb.start_soon(Clock(dut.clk, 10, 'ns').start())

    # Reset configuration
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # Enable configuration
    dut.rst_n.value = 0

    # Upload the bitstream
    await upload_bitstream(dut, proj_path / f'../user_designs/designs/{tile_library}/top_counter/top_counter.bit')
    await ClockCycles(dut.clk, 10)
    
    # Disable configuration
    dut.rst_n.value = 1

    NUM_CYCLES = 123
    await ClockCycles(dut.clk, NUM_CYCLES)
    
    assert dut.uo_out.value == NUM_CYCLES-1

if __name__ == "__main__":

    sim = os.getenv("SIM", "icarus")
    pdk_root = os.getenv("PDK_ROOT", Path("~/.ciel").expanduser())
    pdk = os.getenv("PDK", "ihp-sg13g2")
    scl = os.getenv("SCL", "sg13g2_stdcell")
    gl = os.getenv("GL", None)
    emulation = os.getenv("EMULATION", False)
    tile_library = os.getenv("TILE_LIBRARY", "tiny")
    
    if emulation and gl:
        print("Error: EMULATION and GL can't be set at the same time.")
        sys.exit(1)
    
    hdl_toplevel = "tt_um_fabulous_ihp_26a"
    
    tiles_path = Path(proj_path / ".." / "ip" / "fabulous-tiles")
    primitives_path = Path(tiles_path) / "primitives"
    tile_library_path = Path(tiles_path) / "tiles" / tile_library

    primitives_files = list(primitives_path.glob('**/fabulous/*.v'))
    tile_files = list(tile_library_path.glob(f'**/macro/{pdk}/fabulous/*.v'))

    #print(f"Primitive sources: {primitives_files}")
    #print(f"Tile sources: {tile_files}")
    
    sources = []
    defines = {}
    test_filter = None
    
    sources.extend(primitives_files)
    sources.extend(tile_files)
    
    # gate-level
    if gl:
        # SCL models
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v")
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"sg13g2_udp.v")

        # We use the unpowered netlist
        sources.append(proj_path / f"../macro/nl/{hdl_toplevel}.nl.v")

        defines["USE_POWER_PINS"] = False
    # RTL
    else:
        sources.append(proj_path / f"../src/tt_um_fabulous_ihp_26a.sv")
        sources.append(proj_path / f"../ip/fabric_config/fabric_config.sv")
        sources.append(proj_path / f"../ip/fabric_bitbang/fabric_bitbang.sv")
    
        if emulation:
            sources.append(proj_path / f'../user_designs/designs/{tile_library}/{emulation}/{emulation}.vh')
            defines["EMULATION"] = True
            test_filter = "test_" + emulation
    
    # Add models pack
    sources.append(tiles_path / "models_pack.v")

    # Add custom cells
    sources.append(tiles_path / "custom.v")

    # Add fabric netlist
    sources.append(proj_path / f'../fabrics/{fabric}/macro/{pdk}/fabulous/{fabric}.v')

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        defines=defines,
        always=True,
        clean=True,
        timescale=("1ns", "1ps"),
        waves=True,
    )

    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module="top_tb",
        plusargs=['-fst'],
        waves=True,
        test_filter=test_filter,
    )
