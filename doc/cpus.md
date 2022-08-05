# CPUs

Some CPUs are included in JTFRAME. Some of them can be found in other repositories in Github but the versions in JTFRAME include clock enable inputs and other improvements.

CPUs should have their respective license file in the folder, or directly embedded in the files. Note that they don't use GPL3 but more permissive licenses.

Many CPUs have convenient wrappers that add cycle recovery functionality, or
that allow the selection between different modules for the same CPU.

CPU selection is done via verilog [macros](macros.md).

Resource utilization based on MiST

Processor   | Logic Cells  |  BRAM |  Remarks
------------|--------------|-------|-----------------
M68000      |  5171        |    6  |  fx68k
i8751       |  4019        |    5  |  jtframe_8751mcu
M6809       |  2992        |    0  |  mc6809i
Z80         |  2476        |    2  |  jtframe_sysz80 (T80s)
6502        |   832        |    0  |  T65 (VHDL)
6502        |   937        |    0  |  chip_6502 (Andrew Holme)
PicoBlaze   |   950        |    0  |  PauloBlaze

## Z80

The two basic modules to instantiate are:

- jtframe_sysz80_nvram
- jtframe_sysz80

These two modules offer a Z80 CPU plus:

- A connected RAM (or NVRAM)
- Automatic interrupt clear if CLR_INT parameter is set
- Automatic wait cycles inserted on M1 falling edge if M1_WAIT is set larger than zero

## 6502

The recommended CPU core is the netlist to verilog conversion by [Andrew Holme](http://www.aholme.co.uk/6502/Main.htm). This version requires a clock at least 16x faster than the target 6502 speed, and a 50% duty cycle for a PHI signal that represents the actual 6502 clock. The output has glitches similar to the original ones (not necessarily at the same time). Because of this, the connection is not straight forward. The wrapper [jtframe_mos6502](../hdl/cpu/jtframe_mos6502.v) takes care of these things.