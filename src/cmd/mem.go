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
The YAML file name must be mem.yaml and be stored in cores/corename/cfg
The output files are stored in cores/corename/target where target is
one of the names in the $JTFRAME/target folder (mist, mister, etc.).

mem.yaml syntax

# Include other .yaml files
include: [ "file0", "file1",... ]
# Parameters to be used in the sdram section
params: [ {name:SCR_OFFSET value:"32'h10000"}, ... ]
# Past additional ports to the game module
download: { pre_addr: true, post_addr: true, post_data: true, noswab: true }
# Connect addtional output ports from the game module
ports: [ "port0", "port1",... ]
# Instantiates a differente game module
game: othergame
# Details about the SDRAM usage
sdram:
  banks:
    - buses: # connections to bank 0
        - name:
          addr_width:
          data_width: # 8, 16 or 32. It will affect the LSB start of addr_width
          # Optional switches:
          rw: true # normally false
          cs: myown_cs # use a cs signal not based on the bus name
          addr: myown_addr # use a cs signal not based on the bus name
        - name: another bus...
    - buses: # same for bank 1
        - name: another bus...
    - buses: # same for bank 2
        - name: another bus...
    - buses: # same for bank 3
        - name: another bus...
`,
	Run: func(cmd *cobra.Command, args []string) {
		mem_args.Core = args[0]

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
	flag.StringVarP(&mem_args.Target, "target", "t", "mist", "Target platform: mist, mister, pocket, etc.")
	flag.BoolVarP(&mem_args.Make_inc, "inc","i", false, "always creates mem_ports.inc")
}
