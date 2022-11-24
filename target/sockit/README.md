# JTFRAME target for [SoCkit (MiSTer) Platform](https://github.com/sockitfpga/MiSTer_SoCkit) 

Sockit target by @somhi

### Target information

SoCkit board has many similarities with the DE10-nano board (includes the same FPGA) and therefore it is compatible with the MiSTer platform. The same applies to the DE10-Standard and DE1-SoC boards all from Terasic.

The SoCkit target leverages all built-in hardware capabilities of the board:

- VGA 24 bit analog video output
- Audio CODEC with line-in, line-out, and mic input

Main difference with the DE10-nano is that it does not include an HDMI video output and that it is required to buy an additional HSMC-GPIO adapter to attach an external SDRAM [compatible MiSTer module](http://modernhackers.com/128mb-sdram-board-on-de10-standard-de1-soc-and-arrow-sockit-fpga-sdram-riser/). 

More information about how to use the SoCkit board as a MiSTer compatible platform can be found at https://github.com/sockitfpga/MiSTer_SoCkit.

### Resources

* [GitHub organization](https://github.com/sockitfpga)  
* [SoCkit MiSTer compatible platform](https://github.com/sockitfpga/MiSTer_SoCkit)

* [Telegram group](https://t.me/Sockit_FPGA)
* [Discord channel](https://discord.gg/YDdmtwh)

### Others

* Read carefully the [compilation instructions](../../doc/compilation.md).  
* Main changed files from MiSTer target are:

![changed_files](sockit_files.png)





