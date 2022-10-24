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
	flag.BoolVarP(&mem_args.Verbose, "verbose","v", false, "verbose")
	flag.BoolVarP(&mem_args.Make_inc, "inc","i", false, "always creates mem_ports.inc")
}
