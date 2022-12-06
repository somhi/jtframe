// standard game interface for JTFRAME based
// games. The different configurations are
// enabled via macros defined in cfg/macros.def
    input           rst,
    input           clk,        // always matched to the SDRAM clock
`ifdef JTFRAME_CLK6
    input           rst6,  clk6,
`endif
`ifdef JTFRAME_CLK24
    input           rst24, clk24,
`endif
`ifdef JTFRAME_CLK48
    input           rst48, clk48,
`endif
`ifdef JTFRAME_CLK96
    input           rst96, clk96,
`endif
    `ifdef JTFRAME_PXLCLK input `else output `endif pxl2_cen, pxl_cen,
    output   [`JTFRAME_COLORW-1:0]  red, green, blue,
    output          LHBL, LVBL, HS, VS,
    output          game_led,
    // cabinet I/O
`ifdef JTFRAME_4PLAYERS
    input   [ 3:0]  start_button, coin_input,
    input   [`JTFRAME_BUTTONS+3:0] joystick1, joystick2, joystick3, joystick4,
`else
    input   [ 1:0]  start_button, coin_input,
    input   [`JTFRAME_BUTTONS+3:0] joystick1, joystick2,
`endif
`ifdef JTFRAME_PADDLE
    input   [ 7:0]  paddle_0, paddle_1, paddle_2, paddle_3,
`endif
`ifdef JTFRAME_MOUSE
    input   [15:0]  mouse_1p, mouse_2p,
`endif
`ifdef JTFRAME_ANALOG
    input   [15:0]  joyana_l1, joyana_l2,
    `ifdef JTFRAME_ANALOG_DUAL
        input   [15:0]  joyana_r1, joyana_r2,
    `endif
    `ifdef JTFRAME_4PLAYERS
        input   [15:0]  joyana_l3, joyana_l4,
        `ifdef JTFRAME_ANALOG_DUAL
            input   [15:0]  joyana_r3, joyana_r4,
        `endif
    `endif
`endif
    // Sound control
    input           enable_fm, enable_psg,
    // DIP switches
    input   [31:0]  status, dipsw,
    input           dip_pause, dip_test, service,
    inout           dip_flip,
    input   [ 1:0]  dip_fxlevel,
`ifdef JTFRAME_GAME_UART
    output          uart_tx,
    input           uart_rx,
`endif
    // Sound output
`ifndef JTFRAME_STEREO
    output  signed [15:0] snd,
`else
    output  signed [15:0] snd_left, snd_right,
`endif
    output          sample,
    // Debug
`ifdef JTFRAME_STATUS
    input      [7:0] st_addr,
    output reg [7:0] st_dout,
`endif
    input   [3:0]   gfx_en,
`ifdef JTFRAME_DEBUG
    input      [7:0] debug_bus,
    output reg [7:0] debug_view, // the most common case is the register
`endif
    // Line-frame buffer for object drawing, supported only
    // on PocketFPGA and MiSTer. It could be added to NeptUNO too
`ifdef JTFRAME_LF_BUFFER
    output   [ 7:0] game_vrender,
    output   [ 8:0] game_hdump,
    output   [ 8:0] ln_addr,
    output   [15:0] ln_data,
    output          ln_done,
    input           ln_hs,
    input    [15:0] ln_pxl,
    input    [ 7:0] ln_v,
    output          ln_we,
`endif

    // Memory ports
`ifndef JTFRAME_MEMGEN // If the game does not use mem.yaml
    input   [24:0]  ioctl_addr,
    input   [ 7:0]  ioctl_dout,
    input           ioctl_wr,
    `ifdef JTFRAME_IOCTL_RD
        input           ioctl_ram,
        output   [ 7:0] ioctl_din,
    `endif
    input           downloading,
    output          dwnld_busy,
    input   [15:0]  data_read,
    `ifdef JTFRAME_SDRAM_BANKS
        `ifdef JTFRAME_SDRAM_LARGE
            input [22:0]
        `else
            input [21:0]
        `endif
            ba0_addr, ba1_addr, ba2_addr, ba3_addr,
        output [ 3:0] ba_rd, ba_wr,
        input  [ 3:0] ba_dst, ba_dok, ba_rdy, ba_ack,
        output [15:0] ba0_din, ba1_din, ba2_din, ba3_din,
        output [ 1:0] ba0_dsn, ba1_dsn, ba2_dsn, ba3_dsn,
        output [15:0]  prog_data,
        input          prog_rdy, prog_ack, prog_dst,
        output [ 1:0]  prog_ba,
    `else
        output        sdram_req,
        output [21:0] sdram_addr,
        input         data_dst,
        input         data_rdy,
        input         sdram_ack,
        output [ 7:0] prog_data,
    `endif
    output          prog_we,
    output          prog_rd,
    output  [ 1:0]  prog_mask,
    `ifdef JTFRAME_SDRAM_LARGE
        output [22:0] `else output [21:0]
    `endif
                    prog_addr   // no comma here, end of port list
`else
    `include "mem_ports.inc"
`endif