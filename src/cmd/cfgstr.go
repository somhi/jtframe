/*
Copyright © 2022 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"github.com/jotego/jtframe/jtcfgstr"
	"github.com/jotego/jtframe/jtdef"
	"github.com/spf13/cobra"
)

var cfg jtdef.Config

// cfgstrCmd represents the cfgstr command
var cfgstrCmd = &cobra.Command{
	Use:   "cfgstr <core-name>",
	Short: "Parse core variables",
	Long: `Parses the jtcore-name.def file in the hdl folder and
creates input files for simulation or synthesis`,
	Run: func(cmd *cobra.Command, args []string) {
		cfg.Core = args[0]
		jtcfgstr.Run(cfg, args)
	},
	Args: cobra.MinimumNArgs(1),
}

func init() {
	rootCmd.AddCommand(cfgstrCmd)
	flag := cfgstrCmd.Flags()

	flag.StringVarP(&cfg.Target, "target", "t", "mist", "Target platform (mist, mister, sidi, neptuno, mc2, mcp, pocket)")
	flag.StringVar(&cfg.Deffile, "parse", "", "Path to .def file")
	flag.StringVar(&cfg.Template, "tpl", "", "Path to template file")
	flag.StringVar(&cfg.Commit, "commit", "nocommit", "Commit ID")
	flag.String("def", "", "Defines macro")
	flag.String("undef", "", "Undefines macro")
	flag.StringVar(&cfg.Output, "output", "cfgstr",
		"Type of output: \n\tcfgstr -> config string\n\tbash -> bash script\n\tquartus -> quartus tcl\n\tsimulator name as specified in jtsim")
	flag.BoolVarP(&cfg.Verbose, "verbose","v", false, "verbose")
}
