/*  This file is part of JT_FRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Date: 28-8-20122 */

package cmd

import (
	"github.com/jotego/jtframe/mem"

	"github.com/spf13/cobra"
)

var mem_args mem.Args

// memCmd represents the mem command
var memCmd = &cobra.Command{
	Use:   "mem <core-name>",
	Short: "Parses the core's YAML file to generate RTL files",
	Long: `Parses the core's YAML file to generate RTL files.
The YAML file name must be mem.yaml and be stored in cores/hdl/corename`,
	Run: func(cmd *cobra.Command, args []string) {
		mem_args.Core = args[0]
		mem_args.CfgFile = args[0] + ".yaml"

		mem.Run(mem_args)
	},
	Args: cobra.ExactArgs(1),
}

func init() {
	rootCmd.AddCommand(memCmd)
	flag := memCmd.Flags()

	// mem_args.Def_cfg.Target = "mist"
	// flag.StringVar(&mem_args.Def_cfg.Commit, "commit", "", "result of running 'git rev-parse --short HEAD'")
	// flag.StringVar(&mem_args.Xml_path, "xml", "mame.xml", "Path to MAME XML file")
	// flag.StringVar(&mem_args.Pocketdir, "Pocketdir", "pocket", "Output folder for Analogue Pocket files")
	// flag.StringVar(&mem_args.Outdir, "Outdir", "mem", "Output folder")
	// flag.StringVar(&mem_args.Altdir, "Altdir", "", "Output folder for alternatives")
	// flag.StringVar(&mem_args.Year, "year", "", "Year string for mem file comment")
	flag.BoolVarP(&mem_args.Verbose, "verbose","v", false, "verbose")
	// flag.BoolVarP(&mem_args.Skipmem, "skipmem","s", false, "Do not generate mem files")
	// flag.BoolVarP(&mem_args.Show_platform, "show_platform","p", false, "Show platform name and quit")
	// flag.StringVar(&mem_args.Buttons, "buttons", "", "Buttons used by the game -upto six-")
}
