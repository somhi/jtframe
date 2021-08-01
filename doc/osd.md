# OSD Resolution

Platform | Resolution | Buffer | Remarks
---------|------------|--------|------------------
MiST     | 256x64     | 2kB    |
MiSTer   | 256x128    | 4kB    | HD mode +1kB

In both cases, the buffer encodes pixel columns in bytes: each byte contains one 8-pixel row.

# OSD colours

The macro **JTFRAME_OSDCOLOR** should be defined with a 6-bit value encoding an RGB tone. This is used for
the OSD background. The meanins are:

Value | Meaning                 | Colour
------|-------------------------|---------
6'h3f | Mature core             | Gray
6'h1e | Almost done             | Green
6'h3c | Playable with problems  | Yellow
6'h35 | Very early core         | Red

# DIP switches and OSD

To enable support of DIP switches in MRA files define the macro **JTFRAME_MRA_DIP**. The maximum length of DIP switches is 32 bits. To alter the value of DIP switches in simulation use **JTFRAME_SIM_DIPS**.

In MiST, DIP switches are incorporated into the status word. As some bits in the status word are used for other OSD settings, DIP switches are by default located in range 31:16. This is set by the macro **JTFRAME_MIST_DIPBASE**, whose **default value is 16**. Note that the MRA should match this, the **base** attribute can be used in the MRA dip definition to shift the switch bits up.

Macro                | Effect
---------------------|----------------------------
JTFRAME_SIM_DIPS     | 32-bit value of DIPs used in simulation only
JTFRAME_OSD_NOLOAD   | Do not display _load file_
JTFRAME_OSD_NOCREDITS| Do not display _Credits_
JTFRAME_OSD_FLIP     | Display flip option (only for vertical games)
JTFRAME_OSD_NOSND    | Do not display sound options

Status bits in the configuration string are indicated with characters. This is the reference of the position for each character:

```
bit          00000000001111111112222222222233
  number   : 01234567890123456789012345678901
status char: 0123456789abcdefghijklmnopqrstuv
```


## Values used in the status word by JTFRAME

Values above 8 are not available in MiST if **JTFRAME_MRA_DIP** is defined.

bit     |  meaning                | Enabled with macro
--------|-------------------------|-------------------------------------
0       | Reset in MiST           |
1       | Flip screen             | JTFRAME_VERTICAL && JTFRAME_OSD_FLIP
2       | Rotate controls         | JTFRAME_VERTICAL (MiST)
2       | Rotate screen           | JTFRAME_VERTICAL (MiSTer)
3-4     | Scan lines              | Scan-line mode (MiST only)
3-5     | Scandoubler Fx          | Scan line mode and HQ2X enable (MiSTer only)
6-7     | FX Volume               | JTFRAME_OSD_VOL
8       | FX enable/disable       | JTFRAME_OSD_SND_EN
9       | FM enable/disable       | JTFRAME_OSD_SND_EN
10      | Test mode               | JTFRAME_OSD_TEST
11      | Horizontal filter       | MiSTer only
12      | Credits/Pause           | JTFRAME_OSD_NOCREDITS (disables it)
14-15   | Aspect Ratio            | MiSTer only, visibility masked
19      | CRT H scaling enable    | MiSTer only
20-23   | CRT H scaling factor    | MiSTer only, visibility masked
24-27   | CRT H offset            | MiSTer only
28-31   | CRT V offset            | MiSTer only


If **JTFRAME_FLIP_RESET** is defined a change in dip_flip will reset the game.

To add game specific OSD strings, the recommended way is by adding a line to the **.def** file:

```
CORE_OSD="O6,Turbo,Off,On;",
```
Only one CORE_OSD can be defined, but it an contain multiple values separated by colon.

## DIP switch information extraction from MAME

First you need to get the xml with all the information:

```
mame -listxml > mame.xml
```

The file *mamefilter.cc* is an example of how to extract a subset of machine definitions from the file.

The files *mamegame.hpp* and *mamegame.cc* contain some classes and a function to process the MAME XML into easy-to-use C++ objects. An example of this in use can be seen in JTCPS1 core.

## MOD BYTE

Some JTFRAME features are configured via an ARC or MRA file. This is used to share a common RBF file among several games. The mod byte is introduced in the MRA file using this syntax:

```
    <rom index="1"><part> 01 </part></rom>
```

And in the ARC file with

```
MOD=1
```

This is the meaning for each bit. Note that core mod is only 7 bits in MiST.

Bit  |    Meaning            | Default value
-----|-----------------------|--------------
 0   |  1 = vertical screen  |     1
 1   |  1 = 4 way joystick   |     0

 The vertical screen bit is only read if JTFRAME was compiled with the **JTFRAME_VERTICAL** macro. This macro enables support for vertical games in the RBF. Then the same RBF can switch between horizontal and vertical games by using the MOD byte.