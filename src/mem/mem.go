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
	"fmt"
	"io/ioutil"
	"log"

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
	Number int
	Buses  []SDRAMBus `yaml:"buses"`
}

type SDRAMCfg struct {
	Banks []SDRAMBank `yaml:"banks"`
}

type MemConfig struct {
	Include []string `yaml:include` // not supported yet
	SDRAM   SDRAMCfg `yaml:"sdram"`
	// There will be other memory models supported here
	// Like DDR, BRAM, etc.
}

func Run(args Args) {
	filename := jtfiles.GetFilename(args.Core, "mem", "")
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("jtframe mem: cannot open referenced file %s", filename)
	}
	if args.Verbose {
		fmt.Println("Read ", filename)
	}
	var cfg MemConfig
	err_yaml := yaml.Unmarshal(buf, &cfg)
	if err_yaml != nil {
		//fmt.Println(err_yaml)
		log.Fatalf("jtframe mem: cannot parse file\n\t%s\n\t%v", filename, err_yaml)
	}
	fmt.Println(cfg)
}
