# Debugging

If JTFRAME_RELEASE is not defined, the debug features can be used. Also check [the NVRAM saving](doc/sdram.md) procedure as it can be useful for debugging.

## GFX Enable Bus

keys F7-F10 will toggle bits in the gfx_en bus. After reset all bits are high. These bits are meant to be used to enable/disable graphic layers.

## Generic 8-bit Debug bus

If JTFRAME_RELEASE is not defined, keys + and - (in a Spanish keyboard layout) will increase and decrease the 8-bit debug_bus.

By default, debug_bus is increased (decreased) by 1. If SHIFT is pressed with +/-, then the step is 16 instead. This can be used to control different signals with each *debug_bus* nibble. However, the bus is always increased as a byte, so be aware of it. Pressing CTRL with +/- will reset the *debug_bus* to zero. Press shift+1-0 keys (main keyboard, not keypad) to individually togle each bit of the debug bus.

The game must also define an output bus called *debug_view*, which will be shown on screen, binary encoded. This is a quick way to check signal values. Assign it to 8'h0 if you don't need it. For most sophisticated probe needs, it is better to use the [cheat engine](cheat.md) or the FPGA signal tap facilities.

It is recommended to remove the *debug_bus* once the core is stable. When the core is compiled with **JTFRAME_RELEASE** the *debug_bus* has a permanent zero value and there is no on-screen debug values.

## System Info

By pressing SHIFT+CTRL, the core will switch from displaying the regular *debug_view* to *sys_info*. This 8-bit signals carries information from modules inside JTFRAME, aside from core-specific information. This is available as long as **JTFRAME_RELEASE** was not used for compilation. The *debug_bus* selects which information to display. Note that *sys_info* is shown in a **reddish color**, while *debug_view* is shown in white.

st_addr[7:4] |  Read
-------------|--------------------
  00_??      |  SDRAM stats
  01_??      |  Frame count (BCD) set st_addr[0] for upper byte
  10_??      |  Sample rate (BCD)
  11_00      | { core_mod[3:0], dial_x, game_led, dip_flip }
  11_01      | mouse_dx[8:1]
  11_10      | mouse_dy[8:1]
  11_11      | mouse_f

See core_mod description [here](osd.md)

### Frame Count

This is the total number of frames since the last reset. The count gets halted during pause.

st_addr[0]  |  Read
------------|-----------
  0         | lower 8 bits (BCD)
  1         | upper 8 bits (BCD)

### Sample Rate

If the core exercises the *sample* signal, JTFRAME can report the current sample rate.

st_addr     |  Read
------------|-----------
  X         | rate in kHz (BCD)


### SDRAM Information

The number of SDRAM access done in a frame gets displayed. See [jtframe_sdram_stats](../hdl/sdram/jtframe_sdram_stats.v) for details. Note that the access count is divided by 4096, for display convenience. The SDRAM stats are as follow depending on the value of *st_addr* (which is the same as the debug_bus in MiST).

The SDRAM numbers are not in BCD, but in plain binary. Rather than the absolute number, the interesting thing about the SDRAM report is the relative usage. A good design should try to balance access counts among all banks.

st_addr     |  Read
------------|-----------
bit 5 set   | Combined access in all banks
bit 5 clear | bits 1:0 select the bank for which stats are shown
bit 4 clear | Show access count divided by 4096
bit 4 set   | Show access count divided by 256 (may overflow)
bits 3:2=0  | Show frame stats
bits 3:2=1  | Show active region stats
bits 3:2=2  | Show blank region stats

## Target Info

By pressing SHIFT+CTRL again, the core displays an 8-bit signal defined by the JTFRAME target subsystem. This information is shown in blue. The MiSTer target uses this feature to show the status of the [line-frame buffer](../hdl/video/jtframe_lfbuf_ddr_ctrl.v).

## Generic SDRAM Dump

The SDRAM bank0 can be partially shadowed in BRAM and download as NVRAM via the NVRAM interface. This requires the macros JTFRAME_SHADOW and JTFRAME_SHADOW_LEN to be defined. The MRA file should also enable NVRAM with a statement such as:

```
<nvram index="2" size="1024"/>
```

It is not possible to use JTFRAME_SHADOW and JTFRAME_IOCTL_RD at the same time.

## Helper Modules

- jtframe_simwr_68k replaces a M68000 in simulation and writes a sequence of values from a CSV file to the data bus

## Frequency Counter

Sometimes it is useful to measure an internal frequency. The module [jtframe_freqinfo](../hdl/clocking/jtframe_freqinfo.v) provides this information. It needs to know the clock frequency in kHz and it provides the measured frequency in kHz too.

## Using Signal Tap

Compile the core normally using `jtcore` one time. You don't need to wait until the compilation is done. This will create the Quartus project files. After that, you can load the project in Quartus and re-compile with Signal Tap enabled.