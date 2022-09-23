`ifndef JTFRAME_COLORW
`define JTFRAME_COLORW 4
`endif

`ifndef JTFRAME_BUTTONS
`define JTFRAME_BUTTONS 2
`endif

module jt{{.Core}}_game_sdram(
    input           rst,
    input           clk,
`ifdef JTFRAME_CLK24
    input           rst24,
    input           clk24,
`endif
    output          pxl2_cen,   // 12   MHz
    output          pxl_cen,    //  6   MHz
    output   [`JTFRAME_COLORW-1:0]  red,
    output   [`JTFRAME_COLORW-1:0]  green,
    output   [`JTFRAME_COLORW-1:0]  blue,
    output          LHBL,
    output          LVBL,
    output          HS,
    output          VS,
    // cabinet I/O
`ifdef JTFRAME_4PLAYERS
    input    [ 3:0] start_button,
    input    [ 3:0] coin_input,
    input    [`JTFRAME_BUTTONS-1+4:0] joystick1,
    input    [`JTFRAME_BUTTONS-1+4:0] joystick2,
    input    [`JTFRAME_BUTTONS-1+4:0] joystick3,
    input    [`JTFRAME_BUTTONS-1+4:0] joystick4,
`else
    input    [ 1:0] start_button,
    input    [ 1:0] coin_input,
    input    [`JTFRAME_BUTTONS-1+4:0] joystick1,
    input    [`JTFRAME_BUTTONS-1+4:0] joystick2,
`endif
    // SDRAM interface
    input           downloading,
    output          dwnld_busy,

    // Bank 0: allows R/W
    output   [21:0] ba0_addr,
    output   [21:0] ba1_addr,
    output   [21:0] ba2_addr,
    output   [21:0] ba3_addr,
    output   [ 3:0] ba_rd,
    output          ba_wr,
    output   [15:0] ba0_din,
    output   [ 1:0] ba0_din_m,  // write mask
    input    [ 3:0] ba_ack,
    input    [ 3:0] ba_dst,
    input    [ 3:0] ba_dok,
    input    [ 3:0] ba_rdy,

    input    [15:0] data_read,
    // ROM LOAD
    input   [24:0]  ioctl_addr,
    input   [ 7:0]  ioctl_dout,
    input           ioctl_wr,
    output  [21:0]  prog_addr,
    output  [15:0]  prog_data,
    output  [ 1:0]  prog_mask,
    output  [ 1:0]  prog_ba,
    output          prog_we,
    output          prog_rd,
    input           prog_ack,
    input           prog_dok,
    input           prog_dst,
    input           prog_rdy,
    // DIP switches
    input   [31:0]  status,     // only bits 31:16 are looked at
    input   [31:0]  dipsw,
    input           service,
    input           dip_pause,
    inout           dip_flip,
    input           dip_test,
    input   [ 1:0]  dip_fxlevel,
    // Sound output
    output  signed [15:0] snd,
    output          sample,
    output          game_led,
    input           enable_psg,
    input           enable_fm,
    // Debug
    input   [ 3:0]  gfx_en
);

{{- range .SDRAM.Banks}}
{{- range .Buses}}
wire [{{.Addr_width}}-1:0] {{.Name}}_addr;
wire [{{.Data_width}}-1:0] {{.Name}}_data;
wire {{.Name}}_cs, {{.Name}}_ok;
{{end}}
{{- end}}
wire prom_we;

assign ba_wr      = 0;
assign ba0_din    = 0;
assign ba0_din_m  = 3;

jt{{.Core}}_game u_game(
    .rst        ( rst       ),
    .clk        ( clk       ),
`ifdef JTFRAME_CLK24
    .rst24      ( rst24     ),
    .clk24      ( clk24     ),
`endif
    .pxl2_cen   ( pxl2_cen  ),   // 12   MHz
    .pxl_cen    ( pxl_cen   ),    //  6   MHz
    .red        ( red       ),
    .green      ( green     ),
    .blue       ( blue      ),
    .LHBL       ( LHBL      ),
    .LVBL       ( LVBL      ),
    .HS         ( HS        ),
    .VS         ( VS        ),
    // cabinet I/O
    .start_button   ( start_button  ),
    .coin_input     ( coin_input    ),
    .joystick1      ( joystick1     ),
    .joystick2      ( joystick2     ),
    // DIP switches
    .status         ( status        ),     // only bits 31:16 are looked at
    .dipsw          ( dipsw         ),
    .service        ( service       ),
    .dip_pause      ( dip_pause     ),
    .dip_flip       ( dip_flip      ),
    .dip_test       ( dip_test      ),
    .dip_fxlevel    ( dip_fxlevel   ),
    // Sound output
    .snd            ( snd           ),
    .sample         ( sample        ),
    .game_led       ( game_led      ),
    .enable_psg     ( enable_psg    ),
    .enable_fm      ( enable_fm     ),
    // Memory interface
    {{- range .SDRAM.Banks}}
    {{- range .Buses}}
    .{{.Name}}_addr ( {{.Name}}_addr ),
    .{{.Name}}_cs   ( {{.Name}}_cs   ),
    .{{.Name}}_ok   ( {{.Name}}_ok   ),
    .{{.Name}}_data ( {{.Name}}_data ),
    {{end}}
    {{- end}}
    // PROM writting
    {{ with .PROM_en }}
    .prog_addr    ( prog_addr      ),
    .prog_data    ( prog_data      ),
    .prog_we      ( prog_we        ),
    .prom_we      ( prom_we        ),
    {{ end }}
    // Debug  
    .gfx_en         ( gfx_en        )
);

assign dwnld_busy = downloading;

/* verilator lint_off WIDTH */
jtframe_dwnld #(
`ifdef BA1_START
    .BA1_START ( `BA1_START ),
`endif
`ifdef BA2_START
    .BA2_START ( `BA2_START ),
`endif
`ifdef BA3_START
    .BA3_START ( `BA3_START ),
`endif
    .SWAB      ( 1         )
) u_dwnld(
/* verilator lint_on WIDTH */
    .clk          ( clk            ),
    .downloading  ( downloading    ),
    .ioctl_addr   ( ioctl_addr     ),
    .ioctl_dout   ( ioctl_dout     ),
    .ioctl_wr     ( ioctl_wr       ),
    .prog_addr    ( prog_addr      ),
    .prog_data    ( prog_data      ),
    .prog_mask    ( prog_mask      ), // active low
    .prog_we      ( prog_we        ),
    .prog_rd      ( prog_rd        ),
    .prog_ba      ( prog_ba        ),
    .prom_we      ( prom_we        ),
    .header       (                ),
    .sdram_ack    ( prog_ack       )
);

{{ range $bank, $each:=.SDRAM.Banks }}
{{- if gt (len .Buses) 0 }}
/* verilator tracing_off */
jtframe_rom_{{len .Buses}}slot{{with lt 1 (len .Buses)}}s{{end}} #(
{{- $first := true}}
{{- range $index, $each:=.Buses}}
    {{- if $first}}{{$first = false}}{{else}}, {{end}}
    .SLOT{{$index}}_DW({{.Data_width}}),
    .SLOT{{$index}}_AW({{.Addr_width}})
{{- end}}
) u_bank{{$bank}}(
    .rst         ( rst        ),
    .clk         ( clk        ),
    {{ range $index2, $each:=.Buses }}
    .slot{{$index2}}_addr  ( {{.Name}}_addr  ),
    .slot{{$index2}}_dout  ( {{.Name}}_data  ),
    .slot{{$index2}}_cs    ( {{.Name}}_cs    ),
    .slot{{$index2}}_ok    ( {{.Name}}_ok    ),
    {{end}}
    // SDRAM controller interface
    .sdram_ack   ( ba_ack[{{$bank}}]  ),
    .sdram_req   ( ba_rd[{{$bank}}]   ),
    .sdram_addr  ( ba{{$bank}}_addr   ),
    .data_dst    ( ba_dst[{{$bank}}]  ),
    .data_rdy    ( ba_rdy[{{$bank}}]  ),
    .data_read   ( data_read  )
);
{{- end }}
{{end}}

{{ range $index, $each:=.Unused }}
{{- with . -}}
assign ba{{$index}}_addr = 0;
assign ba_rd[{{$index}}] = 0;
{{- end -}}
{{ end }}

endmodule