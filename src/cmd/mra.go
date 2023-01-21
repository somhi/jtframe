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
    Date: 28-8-2022 */

package cmd

import (
	"os"
	"strings"
	"github.com/jotego/jtframe/mra"

	"github.com/spf13/cobra"
)

var mra_args mra.Args
var reduce bool

// mraCmd represents the mra command
var mraCmd = &cobra.Command{
	Use:   "mra <core-name,core-name...> or mra --reduce <path-to-mame.xml>",
	Short: "Parses the core's TOML file to generate MRA files",
	Long: `Parses the core's mame2mra.toml file to generate MRA files.

If called with --reduce, the argument must be the path to mame.xml,
otherwise the file mame.xml in $JTROOT/rom/mame.xml will be used.

Each repository is meant to have a reduced mame.xml file in $ROM as
part of the source file commited in git.

The output will either be created in $JTROOT/release or in $JTBIN
depending on the --git argument.

TOML elements (see full reference in mame2mra.go)

[parse]
sourcefile="mamefile.cpp"
skip.Setnames=["willskip1","willskip2"]
skip.Bootlegs=true # to skip bootlegs
mustbe.devices=[ "i8751"... ]
mustbe.machines=[ "machine name"... ]

[dipsw]
rename=[ {name="Bonus Life", to="Bonus" }, ... ]
delete=[ "name"... ]
# Add more options
extra={
	[ machine="", setname="", name="", options="", bits="" ],...
}

[header]
# Specify the length in macros.def: JTFRAME_HEADER=length
fill=0xff
dev=[ { dev="fd1089", byte=3, value=10 }, ...]
data = [
	{ machine="...", setname="...", pointer=3, data="12 32 43 ..." },
	...
]

offset = { bits=8, reverse=true, regions=["maincpu","gfx1"...]}

[buttons]
names=[
	{ setname="...", machine="...", names="shot,jump" }
]

[ROM]
# only specify regions that need parameters
regions = [
	{ name=maincpu, machine=optional, start="MACRONAME_START", width=16, len=0x10000, reverse=true, no_offset=true },
	{ name==soundcpu, sequence=[2,1,0,0], no_offset=true } # inverts the order and repeats the first ROM
	{ name=plds, skip=true },
	{ name=gfx1, skip=true, remove=[ "notwanted"... ] }, # remove specific files from the dump
	{ name=proms, files=[ {name="myname", crc="12345678", size=0x200 }... ] }	# Replace mame.xml information with specific files
]
# this is the order in the MRA file
order = [ "maincpu", "soundcpu", "gfx1", "gfx2" ]
# Default NVRAM contents, usually not needed
nvram = [
	{ machine="...", setname="...", data="00 22 33..." },...
]
`,
	Run: func(cmd *cobra.Command, args []string) {
		if reduce {
			mra.Reduce(args[0])
		} else { // regular operation, core names are separated by commas
			mra_args.Xml_path=os.Getenv("JTROOT")+"/rom/mame.xml"
			for _, each := range strings.Split(args[0],",") {
				mra_args.Def_cfg.Core = each
				mra.Run(mra_args)
			}
		}
	},
	Args: cobra.ExactArgs(1),
}

func init() {
	rootCmd.AddCommand(mraCmd)
	flag := mraCmd.Flags()

	mra_args.Def_cfg.Target = "mist"
	flag.StringVar(&mra_args.Def_cfg.Commit, "commit", "", "result of running 'git rev-parse --short HEAD'")
	// flag.StringVar(&mra_args.Xml_path, "xml", os.Getenv("JTROOT")+"/rom/mame.xml", "Path to MAME XML file")
	flag.StringVar(&mra_args.Year, "year", "", "Year string for MRA file comment")
	flag.BoolVarP(&mra_args.Verbose, "verbose", "v", false, "verbose")
	flag.BoolVarP(&reduce, "reduce", "r", false, "Reduce the size of the XML file by creating a new one with only the entries required by the cores.")
	flag.BoolVarP(&mra_args.SkipMRA, "skipMRA", "s", false, "Do not generate MRA files")
	flag.BoolVar(&mra_args.SkipPocket, "skipPocket", false, "Do not generate JSON files for the Pocket")
	flag.BoolVarP(&mra_args.Show_platform, "show_platform", "p", false, "Show platform name and quit")
	flag.BoolVarP(&mra_args.JTbin, "git", "g", false, "Save files to JTBIN")
	flag.StringVar(&mra_args.Buttons, "buttons", "", "Buttons used by the game -upto six-")
	flag.StringVar(&mra_args.Author, "author", "jotego", "Core author")
	flag.StringVar(&mra_args.URL, "url", "https://patreon.com/jotego", "Author's URL")
}
