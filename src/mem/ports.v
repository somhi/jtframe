    // From this line down, do not modify ports manually:
    input   [21:0]  prog_addr,
    input   [ 7:0]  prog_data,
    input           prog_we,
    input   [ 1:0]  prog_ba,
    input   [24:0]  ioctl_addr,
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
    // Explicit ports
{{- range .Ports}}
    {{if .Input}}input{{else}}output{{end}}   {{if .MSB}}[{{.MSB}}:{{.LSB}}]{{end}} {{.Name}},{{end }}
    // Buses to BRAM
{{- range .BRAM }}
    {{if not .Addr}}output   {{ addr_range . }} {{.Name}}_addr,{{end}}{{ if .Rw }}
    {{if not .Din}}output   {{ data_range . }} {{.Name}}_din,{{end}}{{end}}
    input    {{ data_range . }} {{.Name}}_dout,
    {{- if .Dual_port.Name }}
    {{ if not .Dual_port.Cs }}input    {{.Dual_port.Name}}_cs, // Dual port for {{.Dual_port.Name}}
    {{end}}{{end}}
{{- end}}
{{- $first := true -}}
{{- range .SDRAM.Banks}}
{{- range .Buses}}
    {{- if $first}}
    // Buses to SDRAM{{$first = false}}{{else}},
{{end}}
    input    {{ data_range . }} {{.Name}}_data,{{if not .Cs}}
    output          {{.Name}}_cs,{{end}}{{if not .Addr }}
    output   {{ addr_range . }} {{.Name}}_addr,{{end}}
{{- if .Rw }}
    output          {{.Name}}_we,{{ if not .Din}}
    output   {{ data_range . }} {{.Name}}_din,{{end }}{{if not .Dsn}}
    output   [ 1:0] {{.Name}}_dsn,{{end}}{{end }}
    input           {{.Name}}_ok{{end}}
{{- end}}
