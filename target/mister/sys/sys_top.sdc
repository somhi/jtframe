# Specify root clocks
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]
create_clock -period "100.0 MHz" [get_pins -compatibility_mode *|h2f_user0_clk]
create_clock -period "100.0 MHz" [get_pins -compatibility_mode spi|sclk_out] -name spi_sck
create_clock -period "10.0 MHz"  [get_pins -compatibility_mode hdmi_i2c|out_clk] -name hdmi_sck

derive_pll_clocks
derive_clock_uncertainty

# Decouple different clock groups (to simplify routing)
set_clock_groups -exclusive \
   -group [get_clocks { *|pll|pll_inst|altera_pll_i|*[*].*|divclk}] \
   -group [get_clocks { pll_hdmi|pll_hdmi_inst|altera_pll_i|*[0].*|divclk}] \
   -group [get_clocks { pll_audio|pll_audio_inst|altera_pll_i|*[0].*|divclk}] \
   -group [get_clocks { spi_sck}] \
   -group [get_clocks { hdmi_sck}] \
   -group [get_clocks { *|h2f_user0_clk}] \
   -group [get_clocks { FPGA_CLK1_50 }] \
   -group [get_clocks { FPGA_CLK2_50 }] \
   -group [get_clocks { FPGA_CLK3_50 }]

set_false_path -from [get_ports {KEY*}]
set_false_path -from [get_ports {BTN_*}]
set_false_path -to [get_ports {LED_*}]
set_false_path -to [get_ports {VGA_*}]
set_false_path -to [get_ports {AUDIO_SPDIF}]
set_false_path -to [get_ports {AUDIO_L}]
set_false_path -to [get_ports {AUDIO_R}]
set_false_path -from {get_ports {SW[*]}}
set_false_path -to {cfg[*]}
set_false_path -from {cfg[*]}
set_false_path -from {VSET[*]}
set_false_path -to {wcalc[*] hcalc[*]}
set_false_path -to {hdmi_width[*] hdmi_height[*]}
set_false_path -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|dout*}]
# Video calc signals
set_false_path -from [get_keepers {scanlines:VGA_scanlines|hs_out}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|old_hs}]
set_false_path -from [get_keepers {hdmi_out_vs}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|old_vs}]
set_false_path -from [get_keepers {scanlines:VGA_scanlines|de_out}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|old_de}]


set_multicycle_path -to {*_osd|osd_vcnt*} -setup 2
set_multicycle_path -to {*_osd|osd_vcnt*} -hold 1

set_false_path -to {*_osd|v_cnt*}
set_false_path -to {*_osd|v_osd_start*}
set_false_path -to {*_osd|v_info_start*}
set_false_path -to {*_osd|h_osd_start*}
set_false_path -from {*_osd|v_osd_start*}
set_false_path -from {*_osd|v_info_start*}
set_false_path -from {*_osd|h_osd_start*}
set_false_path -from {*_osd|rot*}
set_false_path -from {*_osd|dsp_width*}
set_false_path -to {*_osd|half}

set_false_path -to   {WIDTH[*] HFP[*] HS[*] HBP[*] HEIGHT[*] VFP[*] VS[*] VBP[*]}
set_false_path -from {WIDTH[*] HFP[*] HS[*] HBP[*] HEIGHT[*] VFP[*] VS[*] VBP[*]}
set_false_path -to   {FB_BASE[*] FB_BASE[*] FB_WIDTH[*] FB_HEIGHT[*] LFB_HMIN[*] LFB_HMAX[*] LFB_VMIN[*] LFB_VMAX[*]}
set_false_path -from {FB_BASE[*] FB_BASE[*] FB_WIDTH[*] FB_HEIGHT[*] LFB_HMIN[*] LFB_HMAX[*] LFB_VMIN[*] LFB_VMAX[*]}
set_false_path -to   {vol_att[*] scaler_flt[*] led_overtake[*] led_state[*]}
set_false_path -from {vol_att[*] scaler_flt[*] led_overtake[*] led_state[*]}
set_false_path -from {aflt_* acx* acy* areset* arc*}
set_false_path -from {arx* ary*}
set_false_path -from {vs_line*}

set_false_path -from {ascal|o_ihsize*}
set_false_path -from {ascal|o_ivsize*}
set_false_path -from {ascal|o_format*}
set_false_path -from {ascal|o_hdown}
set_false_path -from {ascal|o_vdown}
set_false_path -from {ascal|o_hmin* ascal|o_hmax* ascal|o_vmin* ascal|o_vmax* ascal|o_vrrmax* ascal|o_vrr}
set_false_path -from {ascal|o_hdisp* ascal|o_vdisp*}
set_false_path -from {ascal|o_htotal* ascal|o_vtotal*}
set_false_path -from {ascal|o_hsstart* ascal|o_vsstart* ascal|o_hsend* ascal|o_vsend*}
set_false_path -from {ascal|o_hsize* ascal|o_vsize*}

set_false_path -from {mcp23009|sd_cd}

# JTFRAME
set_false_path -from {*u_dip|enable_psg*}
set_false_path -from {*u_dip|enable_fm*}
set_false_path -to [get_keepers {audio_out:audio_out|cl1[*]}]
set_false_path -to [get_keepers {audio_out:audio_out|cr1[*]}]

# Reset synchronization signal
set_false_path -from [get_keepers {emu:emu|jtframe_mister:u_frame|jtframe_board:u_board|jtframe_reset:u_reset|rst_rom[0]}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|jtframe_board:u_board|jtframe_reset:u_reset|rst_rom_sync}]
set_false_path -to emu:emu|sRESET[0]
set_false_path -to emu:emu|jtframe_mister:u_frame|jtframe_board:u_board|jtframe_reset:u_reset|rst_req_sync[0]
# static signals
set_false_path -from FB_EN
set_false_path -to deb_osd[0]
set_false_path -from emu:emu|jtframe_mister:u_frame|jtframe_board:u_board|jtframe_led:u_led|led

set_false_path  -from  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {FPGA_CLK1_50}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]
set_false_path  -from  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {FPGA_CLK1_50}]
set_false_path  -from  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]
set_false_path  -from  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  -to  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {FPGA_CLK2_50}]  -to  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]  -to  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {FPGA_CLK1_50}]  -to  [get_clocks {emu|pll|game_pll|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]

# set false path between Game clock <--> HDMI clock
set_false_path  -from  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]
set_false_path  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -from [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]

set_false_path  -to  [get_keepers {*jtframe_sync*}]

# video_calc
set_false_path -from [get_keepers {scanlines:VGA_scanlines|de_out}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|de_100[0]}]
set_false_path -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|hs_100[0]}]
set_false_path -to [get_keepers {emu:emu|jtframe_mister:u_frame|hps_io:u_hps_io|video_calc:video_calc|vs_100[0]}]

# DDR
set_false_path -from [get_keepers *fpga_interfaces\|f2sdram*] -to [get_keepers {emu:emu|jtframe_mister:u_frame|jtframe_lfbuf_ddr:u_lf_buf|jtframe_lfbuf_ddr_ctrl:u_ctrl|*}]
set_false_path -from [get_keepers *fpga_interfaces\|f2sdram*] -to [get_keepers {emu:emu|jtframe_mister:u_frame|jtframe_mister_dwnld:u_dwnld|*}]

# Ignore problems coming from the 100MHz clock
set_false_path  -from  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]

# Ignore problems coming from the audio PLL clock
set_false_path  -from  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]

# Ascal:
set_false_path -from [get_keepers {reset_req}] -to [get_keepers {ascal:ascal|i_reset_na}]

# Related to DDR:
set_false_path -from [get_keepers {*fpga_interfaces|f2sdram*}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|jtframe_lfbuf_ddr:u_lf_buf|jtframe_lfbuf_ddr_ctrl:u_ctrl|*}]
set_false_path -from [get_keepers {*fpga_interfaces|f2sdram*}] -to [get_keepers {emu:emu|jtframe_mister:u_frame|jtframe_mister_dwnld:u_dwnld|*}]
set_false_path -from [get_keepers {*f2sdram~FF*}] -to [get_keepers {ddr_svc|*}]
set_false_path -from [get_keepers {LFB_BASE[*]}] -to [get_keepers {pal_addr[*]}]
set_false_path -from [get_keepers {FB_FMT[*]}] -to [get_keepers {pal_req}]
set_false_path -to [get_keepers {*f2sdram~FF*865}]
set_false_path -from [get_keepers {sysmem_lite:sysmem|sysmem_HPS_fpga_interfaces:fpga_interfaces|f2sdram~FF_3775}] -to [get_keepers {sysmem_lite:sysmem|f2sdram_safe_terminator:f2sdram_safe_terminator_ram2|read_terminating}]

# SEGA PLL
set_false_path  -from  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {pll_audio|pll_audio_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {FPGA_CLK1_50}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path  -from  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]
set_false_path  -from  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {pll_hdmi|pll_hdmi_inst|altera_pll_i|cyclonev_pll|counter[0].output_counter|divclk}]
set_false_path  -from  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {FPGA_CLK1_50}]
set_false_path  -from  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]  -to  [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]
set_false_path  -from  [get_clocks {FPGA_CLK2_50}]  -to  [get_clocks {emu|pll|jtframe_pll6293_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]