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
	goflag "flag"
	"github.com/jotego/jtframe/update"

	"github.com/spf13/cobra"
)

var up_cfg update.Config
var up_targets []string
var up_all bool

// memCmd represents the mem command
var updateCmd = &cobra.Command{
	Use:   "update --cores core1,core2,... <--target mist|mister...>",
	Short: "Updates compiled files for cores or prepares GitHub action files",
	Long: `Updates compiled files for cores or prepares GitHub action files`,
	Run: func(cmd *cobra.Command, args []string) {
		up_cfg.Targets = make(map[string]bool)
		for _,each := range up_targets {
			up_cfg.Targets[each] = true
		}
		if up_all {
			up_cfg.Targets["mist"]    = true
			up_cfg.Targets["sidi"]    = true
			up_cfg.Targets["pocket"]  = true
			up_cfg.Targets["mister"]  = true
			up_cfg.Targets["neptuno"] = true
			up_cfg.Targets["mcp"]     = true
			up_cfg.Targets["mc2"]     = true
		}
		update.Run( &up_cfg, args)
	},
	// Args: cobra.MinimumNArgs(1),
}

func init() {
	rootCmd.AddCommand(updateCmd)
	flag := updateCmd.Flags()

	target_flag := goflag.NewFlagSet("Target parser", goflag.ContinueOnError )
	target_flag.Func( "target", "Adds a new target", func(t string) error { up_cfg.Targets[t] = true; return nil } )
	flag.StringSliceVarP( &up_targets, "target","t",[]string{"mist"}, "Comma separated list of targets" )

	flag.AddGoFlagSet( target_flag )
	flag.BoolVar( &up_cfg.Dryrun,  "dry",     false, "Ignored")
	flag.BoolVar( &up_cfg.Dryrun,  "dryrun",  false, "Ignored")
	flag.BoolVar( &up_cfg.Debug,   "debug",   false, "Does not define JTFRAME_RELEASE, does not store in git")
	flag.BoolVar( &up_cfg.Nohdmi,  "nohdmi",  false, "HDMI disabled in MiSTer")
	flag.BoolVar( &up_cfg.Nosnd,   "nosnd",   false, "define the NOSOUND macro")
	flag.BoolVar( &up_cfg.Nogit,   "nogit",   false, "Does not store in git")
	flag.BoolVar( &up_cfg.Seed,    "seed",    false, "Random seed iteration used for compilation")
	flag.BoolVar( &up_cfg.Seed,    "private", false, "Build for JTALPHA team")
	flag.BoolVar( &up_cfg.Actions, "actions", false, "Updates GitHub actions")
	flag.StringVar(&up_cfg.Network, "network", "", "Ignored")
	flag.StringVar(&up_cfg.CoreList, "cores", "", "Comma separated list of cores")
	flag.StringVar(&up_cfg.Group, "group", "", "Core group specified in $JTROOT/.jtupdate")
	flag.Int64("jobs", 0, "Ignored ")
	flag.BoolVar( &up_all, "all", false, "updates all target platforms")
}
