//go:build ! pocket

package mra

import "fmt"

var pocket_warning bool

func dump_pocket(machine *MachineXML, cfg Mame2MRA, args Args, macros map[string]string) {
	if args.Verbose && !pocket_warning {
		fmt.Println("****  Skipping Pocket file generation ****")
		pocket_warning = true
	}
	// Does nothing
}
