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
    Date: 30-10-2022 */

package msg

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"path/filepath"
)

type Args struct {
	Core    string
}

func Run(args Args) {
	msgpath := filepath.Join( os.Getenv("CORES"),args.Core,"cfg", "msg" )
	fmsg, err := os.Open(msgpath)
	if err != nil {
		log.Fatal("jtframe msg: error opening ", msgpath, " file. ", err)
	}
	defer fmsg.Close()
	scanner := bufio.NewScanner(fmsg)
	data := make([]int16,0,1024)
	for scanner.Scan() {
		escape := false
		pal := 3
		cnt := 0
		line_data := make([]int16,32)
		k := 0
		for _, c := range scanner.Text() {
			if c == '\\' {
				escape = true
				continue
			}
			if escape {
				switch c {
					case 'R': pal=0
					case 'G': pal=1
					case 'B': pal=2
					case 'W': pal=3
					default: log.Fatal("ERROR: invalid palette code")
				}
				escape = false
				continue
			}
			if cnt>31 {
				log.Fatal("ERROR: line is longer than 32 characters")
			}
			cnt++
			coded := int(c)
			if coded <0x20 || coded>0x7f {
				log.Fatal("character code out of range ")
			}
			coded = (pal<<7) | ( (coded-0x20)&0x7f)
			line_data[k] = int16(coded)
			k++
		}
		data = append(data, line_data... )
	}
	// Save the files
	fhex, err := os.Create("msg.hex")
	if err != nil {
		log.Fatal("jtframe msg: cannot open msg.hex ", err)
	}
	fbin, err := os.Create("msg.bin")
	if err != nil {
		log.Fatal("jtframe msg: cannot open msg.bin ", err)
	}
	for _,c := range data {
		fhex.WriteString( fmt.Sprintf("%X\n",c))
		fbin.WriteString( fmt.Sprintf("%b\n",c))
	}
	fhex.Close()
	fbin.Close()
}
