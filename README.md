![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)

# Tiny FABulous FPGA - IHP26a

- [Read the documentation for the project](docs/info.md)
- [View the layout in your browser](https://gds-viewer.tinytapeout.com/?model=https://raw.githubusercontent.com/mole99/tt-fabulous-ihp-26a/refs/heads/main/gds/tt_um_fabulous_ihp_26a.gds&pdk=ihp-sg13g2)

## Requirements

> [!NOTE]
> Make sure to clone the repository with submodules!
>
>```console
>git clone --recurse-submodules <url>.git
>```
> or initialize the submodules after cloning:
>
>```console
> git submodule update --init --recursive
>```

For information on installing Nix with the FOSSi Foundation cache, please refer to the LibreLane documentation: https://librelane.readthedocs.io/en/stable/installation/nix_installation/index.html

## Stitch the Fabric

Before proceeding, ensure that the tiles for the tile library that you are using have been implemented in `ip/fabulous-tiles`.
If that is the case, you can proceed by enabling a Nix shell with LibreLane in this repository:

```
nix-shell
```

To implement the fabric, run:

```
make tiny_fabric_5x5
```

After the fabric has been implemented you can view it either in OpenROAD or KLayout by appending `-openroad` or `-klayout` to the fabric name.
For example, to view `tiny_fabric_5x5` in OpenROAD, run: `make tiny_fabric_5x5-openroad`.

## Implement User Designs

Please see the README in `user_designs/` on how to implement a user design for the fabric.

## Simulate the Fabric

After you have generated the bitstreams for the user designs you can simulate the fabric.
You will again need the Nix shell from the root of this repository.

```
nix-shell
```

Again, use `FABRIC` and `TILE_LIBRARY` to select both accordingly.

If you've changed the fabric, make sure to run:

```
copy-fabric
```

There are two ways to simulate the fabric:

#### RTL "Emulation"

In this case, "emulation" means that we simulate the fabric, however, without uploading the bitstream.
The configuration bits of the fabric are already initialized with the user design bitstream.
This has the benefit that simulation is much faster: no need to upload the bitstream and the Verilog simulator can prune dead branches. However, the disadvantage is that only a single user design can be run per simulation.

To emulate a user design, simply set EMULATION to its name:

```
export EMULATION=counter
```

Then, run the simulation using cocotb:

```
cd tb; python3 fabric_tb.py
```

#### RTL Simulation

To start the RTL simulation, simply run cocotb:

```
cd tb; python3 fabric_tb.py
```

And it will run all available test cases for the selected fabric and tile library.

## Build Tiny FABulous FPGA

Enable a Nix shell:

```
nix-shell
```

Implement the design:

```
make tt-fabulous
```

Open the design in OpenROAD:

```
tt-fabulous-openroad
```

Open the design in KLayout:

```
tt-fabulous-klayout
```

After implementing the fabric, copy the files for submission:

```
copy-tt
```

## Simulate Tiny FABulous FPGA

#### RTL "Emulation"

```
export EMULATION=top_counter
```

Then, run the simulation using cocotb:

```
cd tb; python3 top_tb.py
```

#### RTL Simulation

To start the RTL simulation, simply run cocotb:

```
cd tb; python3 top_tb.py
```

And it will run all available test cases for the selected fabric and tile library.

#### RTL/GL Simulation

Before running the RTLG/GL simulation, enable a PDK version using ciel:

```
ciel enable --pdk-family ihp-sg13g2 d335549443691aa7b6095c4186961c5806e0bcff
```

To start the RTL simulation, simply run cocotb:

```
cd tb; GL=1 python3 top_tb.py
```

And it will run all available test cases for the selected fabric and tile library.
