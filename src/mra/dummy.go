//go:build !pocket

package mra

import "fmt"

var pocket_warning bool

func pocket_add(machine *MachineXML, cfg Mame2MRA, args Args, macros map[string]string, def_dipsw string ) {
	if args.Verbose && !pocket_warning {
		fmt.Println("****  Skipping Pocket file generation ****")
		pocket_warning = true
	}
	// Does nothing
}

func pocket_init(cfg Mame2MRA, args Args, macros map[string]string) {
	// Does nothing
}

func pocket_save() {
	// Does nothing
}
