set_global_assignment -entity "jtframe_pllgame" -library "lib_jtframe_pllgame" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "jtframe_pllgame" -library "lib_jtframe_pllgame" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "jtframe_pllgame" -library "lib_jtframe_pllgame" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_jtframe_pllgame" -name SPD_FILE [file join $::quartus(sip_path) "jtframe_pllgame.spd"]

set_global_assignment -library "lib_jtframe_pllgame" -name MISC_FILE [file join $::quartus(sip_path) "jtframe_pllgame_sim/jtframe_pllgame.vo"]
