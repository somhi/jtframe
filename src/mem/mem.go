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
	Addr_width int    `yaml:"addr_width"`
	Data_width int    `yaml:"data_width"`
}

type SDRAMBank struct {
	Buses  []SDRAMBus `yaml:"buses"`
}

type SDRAMCfg struct {
	Banks []SDRAMBank `yaml:"banks"`
}

type MemConfig struct {
	Include []string `yaml:include` // not supported yet
	PROM_en bool `yaml:"PROM_en"`
	SDRAM   SDRAMCfg `yaml:"sdram"`
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

func Run(args Args) {
	filename := jtfiles.GetFilename(args.Core, "mem", "")
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Printf("jtframe mem: cannot open referenced file %s", filename)
		return
	}
	if args.Verbose {
		fmt.Println("Read ", filename)
	}
	var cfg MemConfig
	err_yaml := yaml.Unmarshal(buf, &cfg)
	if err_yaml != nil {
		log.Fatalf("jtframe mem: cannot parse file\n\t%s\n\t%v", filename, err_yaml)
	}
	if args.Verbose {
		fmt.Println("jtframe mem: memory configuration:")
		fmt.Println(cfg)
	}
	// Check that the arguments make sense
	if len(cfg.SDRAM.Banks)>4 || len(cfg.SDRAM.Banks)==0 {
		log.Fatalf("jtframe mem: the number of banks must be between 1 and 4 but %d were found.",len(cfg.SDRAM.Banks))
	}
	for k := len(cfg.SDRAM.Banks); k<4; k++ {
		cfg.Unused[k] = true
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
