# Debug Check List

If a core synthesizes correctly but shows odd behaviour, these are some of the items that may have gone wrong

## Total Failure
* Is the CPU memory size correct? The game may boot with a smaller RAM but fail later on
* Are the clock enable signals applied to the right clock domain? Check the CPU clk/clk_en pair
* Is the port direction correct in all modules? Quartus will fail to drive signals that are defined in all modules as inputs
* Are level interrupts held long enough?
* Strobe signals from one clock domain to another, or one cen-domain to another must use jtframe strobe synchronizers
* Is the frame interrupt getting to the CPU?

## Video Artefacts
* The shifted screen counter should keep the right sequence around LVBL transitions

## Wrong Colours
* Is JTFRAME_COLORW correct?
* Is the bit plane order correct?
* If a color PROM is used, the bit plane order must be set right at the input
* Is the right part of the palette selected?

## Sound Problems
* Are interrupts coming correctly to the CPU?
* If unsigned and signed output modules are used for sound, the unsigned ones must be converted to signed using *jtframe_dcrm*
