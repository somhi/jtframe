# Joysticks

By default JTFRAME supports two joysticks only and will try to connect to game modules based on this assumption. For games that need four joysticks, define the macro **JTFRAME_4PLAYERS**.
Note that the registers containing the coin and start button inputs are always passed as 4 bits, but the game can just ignore the 2 MSB if it only supports two players.

Analog controllers are not connected to the game module by default. In order to get them connected, define the macro **JTFRAME_ANALOG** and then these input ports:

```
input   [15:0]  joyana1,
input   [15:0]  joyana2,
```

Analogue sticks uses 2-complement bytes to signal information: right and bottom are possitive (127 is the maximum). Left and top are negative (FFh minimum, 80h maximum)

Support for 4-way joysticks (instead of 8-way joysticks) is enabled by setting high bit 1 of core_mod. See MOD BYTE.

## DB15 Support

The DB15 hardware from Antonio Villena can be enabled in the OSD. It will replace USB input to the game for players 1P and 2P. Controlling the OSD with the DB15 input is possible and uses the command byte *0xF*. If future MiSTer versions used that value, the file *hps_io.v* will need to be edited to support it. Declaring the macro **JTFRAME_NO_DB15_OSD** will disable OSD control.

The macro **JTFRAME_NO_DB15** disables DB15 support.

## Autofire

It is not encouraged to provide a generic autofire option as it alters the gameplay. But, for some games that used a spinner (like Heavy Barrel), it helps controlling the character. By defining **JTFRAME_AUTOFIRE0** an option will appear on the OSD to enable autofire only for the first button (joystick bit 4). The autofire is triggered every 8 frames.

# Trackball

The popular upd4701 is modelled in [jt4701](../hdl/keyboard/jt4701.v). The main module **jt4701** represents the original chip and should work correctly when connected to a trackball. There are two helper modules: jt4701_dialemu and jt4701_dialemu_2axis.

The trackball only measures differences in position from a reset event. Games often reset the count and because of that, the trackball cannot be easily replaced by an absolute value.

## jt4701_dialemu

Use to emulate trackball inputs with buttons. One button is used to increase the axis, and the other to decrease it. A rather slow clock is used at the *pulse* input to set the update rate. This emulator is meant to be hooked to the **jt4701** when no real trackball is present.

## jt4701_dialemu_2axis

A more comprehensive trackball emulator that already instantiates internally the **jt4701** and can be easily interface with the CPU.




