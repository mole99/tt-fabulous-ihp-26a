# User Designs

User designs are Verilog designs that run on the FPGA fabric.

## Requirements

Currently, forks of Yosys and nextpnr are required in order to implement the user designs. The changes to these forks are being upstreamed.

Enable a Nix shell with the forks of Yosys and nextpnr:

```
nix-shell
```

**Note:** To generate the bitstreams you need to `pip3 install fasm`.

## Implement the Designs

To build all user designs, run:

```
make all
```

To build individual user designs, use their name:

```
make counter
```

The following Make targets are available:

```
make counter-clean
make counter-synth
make counter-pnr
make counter-bit
make counter-hex
```

You can also enter the individual design directories and run make from there:

```
Commands:
 synth           ... Synthesize the user design
 pnr             ... Run Place and Route
 bitstream       ... Generate the bitstream
 clean           ... Delete all generated files
 help            ... Show this help message
```

## Hints

- You can use the `BEL` attribute to constrain the position of Bels. You can constrain IOs, LCs, GBUFs etc. this way.
  For example: `(* keep, BEL="X0Y4.A" *)`
- `FABULOUS_LC` has a synchronous, active-high reset. For best utilization, make sure to use a GBUF for rst_n and set `INVERT=1` to get rst for your design.
- Fast carry chains can be as high as 8*3-1 = 23 bit addition
