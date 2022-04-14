set_global_assignment -entity "jtframe_pll6000" -library "lib_jtframe_pll6000" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "jtframe_pll6000" -library "lib_jtframe_pll6000" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "jtframe_pll6000" -library "lib_jtframe_pll6000" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_jtframe_pll6000" -name SPD_FILE [file join $::quartus(sip_path) "jtframe_pll6000.spd"]

set_global_assignment -library "lib_jtframe_pll6000" -name MISC_FILE [file join $::quartus(sip_path) "jtframe_pll6000_sim/jtframe_pll6000.vo"]
