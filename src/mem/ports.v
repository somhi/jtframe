    // From this line down, do not modify ports manually:
`ifdef JTFRAME_PROM_START
    input   [21:0]  prog_addr,
    input   [ 7:0]  prog_data,
    input           prog_we,
    input           prom_we,
`endif
`ifdef JTFRAME_HEADER
    input           header,
`endif
{{- if .SDRAM.Preaddr }}
    input      [24:0] ioctl_addr,
    input      [21:0] pre_addr,
    output reg [21:0] post_addr,
{{end}}
`ifdef JTFRAME_IOCTL_RD
    input           ioctl_ram,
    output   [ 7:0] ioctl_din,
`endif
{{ $first := true}}
{{- range .Ports.Outputs}}    output          {{.}},{{end -}}
{{ range .SDRAM.Banks}}
{{- range .Buses}}
    {{- if $first}}{{$first = false}}{{else}},{{end}}

    output   {{ addr_range . }} {{.Name}}_addr,
    input    {{ data_range . }} {{.Name}}_data,{{if not .Cs}}
{{- if .Rw }}
    output          {{.Name}}_we,
    output   {{ data_range . }} {{.Name}}_din,
    output   [ 1:0] {{.Name}}_dsn,{{end}}
    output          {{.Name}}_cs,{{end}}
    input           {{.Name}}_ok{{end}}
{{- end}}
