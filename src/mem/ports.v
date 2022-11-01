    // From this line down, do not modify ports manually:
    input   [21:0]  prog_addr,
    input   [ 7:0]  prog_data,
    input           prog_we,
    input      [24:0] ioctl_addr,
`ifdef JTFRAME_PROM_START
    input           prom_we,
`endif
{{- if .Download.Post_addr }}
    output reg [21:0] post_addr,
{{end}}
{{- if .Download.Pre_addr }}
    output reg [24:0] pre_addr,
{{end}}
{{- if .Download.Post_data }}
    output reg [ 7:0] post_data,
{{end}}
`ifdef JTFRAME_HEADER
    input           header,
`endif
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
