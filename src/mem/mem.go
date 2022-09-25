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
    Date: 23-9-2022 */

package mem

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"text/template"

	"github.com/jotego/jtframe/jtfiles"

	"gopkg.in/yaml.v2"
)

type Args struct {
	Core    string
	CfgFile string
	Verbose bool
	// The memory selection (SDRAM, DDR, BRAM...) will be here
}

type SDRAMBus struct {
	Name       string `yaml:"name"`
	Offset	   string `yaml:"offset"`
	Addr_width int    `yaml:"addr_width"`
	Data_width int    `yaml:"data_width"`
}

type SDRAMBank struct {
	Buses  []SDRAMBus `yaml:"buses"`
}

type SDRAMCfg struct {
	Preaddr bool `yaml:"preaddr"`	// Pass some signals to the game so it can remap the download address
	Noswab bool `yaml:"noswab"`		// SWAB parameter of jtframe_download
	Banks []SDRAMBank `yaml:"banks"`
}

type Include struct {
	Game string `yaml:"game"` // if not null, it will load from that game folder
	File string `yaml:"file"` // if null, mem.yaml will be used
}

type MemConfig struct {
	Include []Include  `yaml:include`
	SDRAM     SDRAMCfg `yaml:"sdram"`
	Game      string   `yaml:"game"`  // optional: Overrides using Core as the jt<core>_game module
	// There will be other memory models supported here
	// Like DDR, BRAM, etc.
	// This part does not go in the YAML file
	// But is acquired from the .def or the Args
	Core   string
	Macros map[string]string
	// Precalculated values
	Colormsb int
	Unused [4]bool // true for unused banks
}

func parse_file( core, filename string, cfg *MemConfig, args Args ) bool {
	filename = jtfiles.GetFilename(core, filename, "")
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		if args.Verbose {
			log.Printf("jtframe mem: no memory file (%s)", filename)
		}
		return false
	}
	if args.Verbose {
		fmt.Println("Read ", filename)
	}
	err_yaml := yaml.Unmarshal(buf, cfg)
	if err_yaml != nil {
		log.Fatalf("jtframe mem: cannot parse file\n\t%s\n\t%v", filename, err_yaml)
	}
	if args.Verbose {
		fmt.Println("jtframe mem: memory configuration:")
		fmt.Println(*cfg)
	}
	include_copy := make( []Include, len(cfg.Include))
	copy( include_copy, cfg.Include )
	cfg.Include = nil
	for _,each := range include_copy {
		fname := each.File
		if fname=="" {
			fname="mem"
		}
		parse_file( each.Game, fname, cfg, args )
		fmt.Println( each.Game, fname )
	}
	// Reload the YAML to overwrite values that the included files may have set
	err_yaml = yaml.Unmarshal(buf, cfg)
	if err_yaml != nil {
		log.Fatalf("jtframe mem: cannot parse file\n\t%s\n\t%v for a second time", filename, err_yaml)
	}
	return true
}

func Run(args Args) {
	var cfg MemConfig
	if !parse_file( args.Core, "mem", &cfg, args ) {
		// the mem.yaml file does not exist, that's
		// normally ok
		return
	}
	// Check that the arguments make sense
	if len(cfg.SDRAM.Banks)>4 || len(cfg.SDRAM.Banks)==0 {
		log.Fatalf("jtframe mem: the number of banks must be between 1 and 4 but %d were found.",len(cfg.SDRAM.Banks))
	}
	for k := 0; k<4; k++ {
		if k < len(cfg.SDRAM.Banks) {
			cfg.Unused[k] = len(cfg.SDRAM.Banks[k].Buses)==0
		} else {
			cfg.Unused[k] = true
		}
	}
	// Execute the template
	cfg.Core = args.Core
	tpath := filepath.Join(os.Getenv("JTFRAME"), "src", "mem", "template.v")
	t := template.Must(template.ParseFiles(tpath))
	var buffer bytes.Buffer
	t.Execute(&buffer, &cfg)
	outpath := "jt"+args.Core+"_game_sdram.v"
	outpath = filepath.Join( os.Getenv("CORES"),args.Core,"hdl", outpath )
	ioutil.WriteFile( outpath, buffer.Bytes(), 0644 )
}
