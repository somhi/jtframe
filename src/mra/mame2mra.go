package mra

import (
	"bufio"
	"bytes"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"io/fs"
	"log"
	"math"
	"math/rand"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/jotego/jtframe/jtdef"
	toml "github.com/komkom/toml"
)

type Args struct {
	Def_cfg                   jtdef.Config
	Toml_path, Xml_path       string
	outdir, altdir, pocketdir string
	Info                      []Info
	Buttons                   string
	Year                      string
	Verbose, SkipMRA, SkipPocket bool
	Show_platform             bool
	JTbin                     bool  // copy to JTbin
	Author, URL  		      string
	// private
	firmware_dir			  string
	macros					  map[string]string
}

type RegCfg struct {
	Name, Rename,
	Machine, Setname  string
	Start             string // Matches a macro in macros.def that should be an integer value
	start			  int    // Private translation of the Start value
	Width, Len        int
	Rom_len           int
	Reverse, Skip     bool
	No_offset         bool // Using the default offset helps in some CPU configurations. If the file order is not changed,
						   // keeping the original offset usually has no effect as the offset is just the file size
						   // when reverse=true or a sort/sequence changes the file order, the offset may introduce
						   // warning messages or fillers, so no_offset=true is needed
	Sort_byext        bool
	Sort              bool // Sort by number sections
	Sort_alpha        bool // Sort by full alpha comparison
	Sort_even         bool // sort ROMs by pushing all even ones first, and then the odd ones
	Sort_reverse      bool // inverts the sorting
	Singleton         bool // Each file can only merge with itself to make interleave sections
	// The upper and lower halves of the same file are merged together
	Ext_sort  []string // sorts by matching the file extension
	Name_sort []string // sorts by name
	Regex_sort []string // sorts by name apply regular expression
	Sequence   []int    // File sequence, where the first file is identified with a 0, the next with 1 and so on
						// ROM files can be repeated or omitted in the sequence
	Frac      struct {
		Bytes, Parts int
	}
	Custom struct { // If there is not dump available, jtframe will try to make one
		// the assembly source code must be in cores/corename/firmware/machine.s or setname.s
		// Machine, Setname string // Optional filters
		Dev              string // Device name for assembler
	}
	Files []MameROM // This replaces the information in mame.xml completely if present
}

type HeaderCfg struct {
	Len, Fill int
	Dev       []struct {
		Byte, Value int
		Dev         string
	}
	Data []struct {
		Machine, Setname string
		Pointer          int
		Data             string
	}
	Offset struct {
		Bits    int
		Reverse bool
		Start   int // Start location for the offset table
		Regions []string
	}
}

type Info struct {
	Tag, Value string
}

type Mame2MRA struct {
	Global struct {
		Info      []Info
		Mraauthor []string
		Platform  string // Used by the Pocket target
		Zip       struct {
			Alt string
		}
		Overrule []struct { // overrules values in MAME XML
			Machine, Setname string
			Rotate int
		}
	}

	Features struct {
		Ddr, Beta, Debug, Qsound, Cheat bool
		Nvram                           int
	}

	Parse ParseCfg

	Buttons struct {
		Core  int
		Names []struct {
			Machine, Setname string
			Names            string
		}
	}

	Dipsw struct {
		Delete []string
		base   int // Define it macros.def as JTFRAME_MIST_DIPBASE
		Bitcnt int // Total bit count (including all switches)
		// Defaults [] struct {
		// 	Machine, Setname string
		// 	Value			 int
		// }
		Extra []struct {
			Machine, Setname    string
			Name, Options, Bits string
		}
		Rename []struct {
			Name, To string // Will make Name <- To
			Values []string // Will rename the values if present
		}
	}

	Rbf struct {
		Name string
		Dev  []struct {
			Dev, Rbf string
		}
		Machines []struct {
			Machine, Setname, Rbf string
		}
	}

	Header HeaderCfg

	ROM struct {
		Regions []RegCfg
		Order   []string
		Remove  []string // Remove specific files from the dump
		// Splits break a file into chunks using the offset and length MRA attributes
		// Offset sets the break point, and Min_len the minimum length for each chunk
		// This can be used to group several files in a different order (see Golden Axe)
		// or to make a file look bigger than it is (see Bad Dudes)
		Splits []struct {
			Machine, Setname string
			Region  string
			Namehas string	// The setname of the game in MAME must contain the "namehas" string
			Offset, Min_len  int
		}
		Blanks []struct {
			Machine, Setname, Region string
			Offset, Len              int
		}
		Patches []struct {
			Machine, Setname string
			Offset           int
			Value            string
		}
	}
}

type XMLAttr struct {
	Name, Value string
}

type XMLNode struct {
	name, text string
	comment    bool
	attr       []XMLAttr
	children   []*XMLNode
	depth      int
	indent_txt bool
}

// first XML node of a ROM region
type StartNode struct{
	node *XMLNode
	pos int
}

func (n *XMLNode) GetNode(name string) *XMLNode {
	for _, c := range n.children {
		if c.name == name {
			return c
		}
	}
	return nil
}

func (n *XMLNode) AddNode(names ...string) *XMLNode {
	var child XMLNode
	child.name = names[0]
	n.children = append(n.children, &child)
	child.depth = n.depth + 1
	if len(names) > 1 {
		child.text = names[1]
		for k := 2; k < len(names); k++ {
			child.text = child.text + names[k]
		}
	}
	return &child
}

func (n *XMLNode) AddAttr(name, value string) *XMLNode {
	n.attr = append(n.attr, XMLAttr{name, value})
	return n
}

func (n *XMLNode) AddIntAttr(name string, value int) *XMLNode {
	n.attr = append(n.attr, XMLAttr{name, strconv.Itoa(value)})
	return n
}

func (n *XMLNode) SetText(value string) *XMLNode {
	n.text = value
	return n
}

func (n *XMLNode) GetAttr(name string) string {
	for _, a := range n.attr {
		if a.Name == name {
			return a.Value
		}
	}
	return ""
}

func (n *XMLNode) FindNode(name string) (found *XMLNode) {
	if n.name == name {
		return n
	} else {
		for _, each := range n.children {
			found = each.FindNode(name)
			if found != nil {
				return found
			}
		}
	}
	found = nil
	return found
}

func xml_str(in string) string {
	out := strings.ReplaceAll(in, "&", "&amp;")
	out = strings.ReplaceAll(out, "'", "&apos;")
	out = strings.ReplaceAll(out, "<", "&lt;")
	out = strings.ReplaceAll(out, ">", "&gt;")
	out = strings.ReplaceAll(out, `\`, "&quot;")
	return out
}

func (n *XMLNode) Dump() string {
	var s, indent string
	for k := 0; k < n.depth; k++ {
		indent += "    "
	}
	if n.comment {
		return indent + "<!-- " + n.name + " -->"
	}
	s = fmt.Sprintf("%s<%s", indent, n.name)
	if len(n.attr) > 0 {
		for _, a := range n.attr {
			s += fmt.Sprintf(" %s=\"%v\"", a.Name, xml_str(a.Value))
		}
	}
	if len(n.text) > 0 {
		// dump text
		s = s + ">"
		if n.indent_txt {
			lines := strings.Split(xml_str(n.text), "\n")
			for _, l := range lines {
				s += "\n" + indent
				if len(l) > 0 {
					s += "    " + l
				}
			}
		} else {
			s += xml_str(n.text)
		}
		s = s + fmt.Sprintf("</%s>", n.name)
	} else {
		if len(n.children) > 0 {
			s = s + ">" + n.text
			for _, c := range n.children {
				s = s + "\n" + c.Dump()
			}
			s = s + fmt.Sprintf("\n%s</%s>", indent, n.name)
		} else {
			s = s + "/>"
		}
	}
	return s
}

func (this *StartNode) add_length( pos int ) {
	if this.node != nil {
		lenreg := pos - this.pos
		if lenreg > 0 {
			this.node.name = fmt.Sprintf("%s - length 0x%X (%d bits)", this.node.name, lenreg,
				int(math.Ceil( math.Log2(float64(lenreg)))) )
		}
	}
}

type ParsedMachine struct {
	machine *MachineXML
	mra_xml *XMLNode
	cloneof bool
	def_dipsw string
}

func Run(args Args) {
	parse_args(&args)
	mra_cfg := parse_toml(&args) // macros become part of args
	if args.Verbose {
		fmt.Println("Parsing", args.Xml_path)
	}
	ex := NewExtractor(args.Xml_path)
	parent_names := make(map[string]string)
	// Set the RBF Name if blank
	if mra_cfg.Rbf.Name == "" {
		mra_cfg.Rbf.Name = "jt" + args.Def_cfg.Core
	}
	// Set the platform name if blank
	if mra_cfg.Global.Platform == "" {
		mra_cfg.Global.Platform = "jt"+args.Def_cfg.Core
	}
	if args.Show_platform {
		fmt.Printf("%s", mra_cfg.Global.Platform)
		return
	}
	var data_queue []ParsedMachine
	if !args.SkipPocket {
		pocket_init(mra_cfg, args)
	}
extra_loop:
	for {
		machine := ex.Extract(mra_cfg.Parse)
		if machine == nil {
			break
		}
		if args.Verbose {
			fmt.Print("Found ", machine.Name)
			if machine.Cloneof != "" {
				fmt.Printf(" (%s)", machine.Cloneof)
			}
			fmt.Println()
		}
		cloneof := false
		if machine.Cloneof != "" {
			cloneof = true
		} else {
			parent_names[machine.Name] = machine.Description
		}
		if skip_game( machine, mra_cfg, args ) {
			continue extra_loop
		}
		for _, each := range mra_cfg.Global.Overrule {
			if is_family( each.Machine, machine ) || each.Setname == machine.Name || (each.Setname=="" && each.Machine=="") {
				if each.Rotate != 0 {
					machine.Display.Rotate = each.Rotate
				}
			}
		}
		for _, reg := range mra_cfg.ROM.Regions {
			for k, r := range machine.Rom {
				if r.Region == reg.Rename && reg.Rename != "" {
					machine.Rom[k].Region = reg.Name
				}
			}
		}
		mra_xml, def_dipsw := make_mra(machine, mra_cfg, args)
		pm := ParsedMachine{machine, mra_xml, cloneof, def_dipsw}
		data_queue = append(data_queue, pm)
	}
	// Add explicit parents to the list
	for _, p := range mra_cfg.Parse.Parents {
		parent_names[p.Name] = p.Description
	}
	// Dump MRA is delayed for later so we get all the parent names collected
	if args.Verbose || len(data_queue)==0 {
		fmt.Println("Total: ", len(data_queue), " games")
	}
	main_copied := args.SkipMRA
	old_deleted := false
	for _, d := range data_queue {
		_, good := parent_names[d.machine.Cloneof]
		if good || len(d.machine.Cloneof) == 0 {
			if !args.SkipPocket {
				pocket_add(d.machine, mra_cfg, args, d.def_dipsw)
			}
			if !args.SkipMRA {
				// Delete old MRA files
				if !old_deleted {
					filepath.WalkDir( args.outdir, func( path string, d fs.DirEntry, err error) error {
						if err == nil {
							if !d.IsDir() && strings.HasSuffix(path,".mra") {
								delete_old_mra( args, path )
							}
						}
						return nil
					} )
					old_deleted = true
				}
				// Do not merge dump_mra and the OR in the same line, or the compiler may skip
				// calling dump_mra if main_copied is already set
				dumped := dump_mra(args, d.machine, mra_cfg, d.mra_xml, d.cloneof, parent_names)
				main_copied = dumped || main_copied
			}
		} else {
			fmt.Printf("Skipping derivative '%s' as parent '%s' was not found\n",
				d.machine.Name, d.machine.Cloneof)
		}
	}
	if !main_copied {
		fmt.Printf("ERROR (%s): No single MRA was highlighted as the main one. Set it in the TOML file parse.main key\n",args.Def_cfg.Core)
		os.Exit(1)
	}
	if !args.SkipPocket {
		pocket_save()
	}
}

func skip_game( machine *MachineXML, mra_cfg Mame2MRA, args Args ) bool {
	if mra_cfg.Parse.Skip.Bootlegs &&
		strings.Index(
			strings.ToLower(machine.Description), "bootleg") != -1 {
		if args.Verbose {
			fmt.Println("Skipping ", machine.Description, "for it's a bootleg")
		}
		return true
	}
	for _, d := range mra_cfg.Parse.Skip.Descriptions {
		if strings.Index(machine.Description, d) != -1 {
			if args.Verbose {
				fmt.Println("Skipping ", machine.Description, "for its description")
			}
			return true
		}
	}
	for _, each := range mra_cfg.Parse.Skip.Setnames {
		if each == machine.Name {
			if args.Verbose {
				fmt.Println("Skipping ", machine.Description, "for matching setname")
			}
			return true
		}
	}
	for _, each := range mra_cfg.Parse.Skip.Machines {
		if is_family( each, machine ) {
			if args.Verbose {
				fmt.Println("Skipping ", machine.Description, "for matching machine name")
			}
			return true
		}
	}
	// Parse Must-be conditions
	device_ok := len(mra_cfg.Parse.Mustbe.Devices)==0
	device_check:
	for _,each := range mra_cfg.Parse.Mustbe.Devices {
		for _,check := range machine.Devices {
			if each == check.Name {
				device_ok = true
				break device_check
			}
		}
	}
	// Check must-be machine names
	machine_ok := len(mra_cfg.Parse.Mustbe.Machines)==0
	for _,each := range mra_cfg.Parse.Mustbe.Machines {
		if is_family( each, machine ) {
			if args.Verbose {
				fmt.Println("Parsing ", machine.Description, "for matching machine name")
			}
			machine_ok = true
			break
		}
	}
	return !(device_ok && machine_ok)
}

func rm_spsp( a string ) string {
	re := regexp.MustCompile(" +")
	return re.ReplaceAllString(a," ") // Remove duplicated spaces
}

////////////////////////////////////////////////////////////////////////
func fix_filename(filename string) string {
	x := strings.ReplaceAll(filename, "World?", "World")
	x = rm_spsp(x)
	return strings.ReplaceAll(x, "?", "x")
}

func delete_old_mra( args Args, path string ) {
	mradata, e := os.ReadFile( path )
	if e != nil {
		fmt.Println("Cannot read ", path )
		os.Exit(1)
	}
	var testmra MRA
	e = xml.Unmarshal(mradata, &testmra)
	if e != nil {
		fmt.Println("Cannot Unmarshal ", path,"\n\t",e )
		os.Exit(1)
	}
	if strings.ToUpper(testmra.Rbf) == args.macros["CORENAME"] {
		if e = os.Remove(path); e!=nil {
			fmt.Println("Cannot delete ", path)
			os.Exit(1)
		}
		if args.Verbose {
			fmt.Println("Deleted ", path)
		}
	}
}

func dump_mra(args Args, machine *MachineXML, mra_cfg Mame2MRA, mra_xml *XMLNode, cloneof bool, parent_names map[string]string ) bool {
	fname := args.outdir
	game_name := strings.ReplaceAll(mra_xml.GetNode("name").text, ":", "")
	game_name = strings.ReplaceAll(game_name, "/", "-")
	// Create the output directory
	if args.outdir != "." && args.outdir != "" {
		if args.Verbose {
			fmt.Println("Creating folder ", args.outdir)
		}
		err := os.MkdirAll(args.outdir, 0777)
		if err != nil && !os.IsExist(err) {
			log.Fatal(err, args.outdir)
		}
	}
	// Redirect clones to their own folder
	main_mra := (!cloneof && mra_cfg.Parse.Main=="") || (machine.Name == mra_cfg.Parse.Main)
	if cloneof && !main_mra {
		pure_name := parent_names[machine.Cloneof]
		pure_name = strings.ReplaceAll(pure_name, ":", "")
		if k := strings.Index(pure_name, "("); k != -1 {
			pure_name = pure_name[0:k]
		}
		if k := strings.Index(pure_name, " - "); k != -1 {
			pure_name = pure_name[0:k]
		}
		pure_name = strings.ReplaceAll(pure_name,"/","") // Prevent the creation of folders!
		pure_name = strings.TrimSpace(pure_name)
		pure_name = rm_spsp(pure_name)
		fname = filepath.Join( args.altdir, "_" + pure_name )

		err := os.MkdirAll(fname, 0777)
		if err != nil && !os.IsExist(err) {
			log.Fatal(err, fname)
		}
	}
	fname += "/" + fix_filename(game_name) + ".mra"
	// fmt.Println("Output to ", fname)
	var b strings.Builder
	b.WriteString(mra_disclaimer(machine, args.Year))
	b.WriteString( mra_xml.Dump() )
	b.WriteString("\n")
	os.WriteFile(fname, []byte(b.String()),0666)
	main_copied := false
	if main_mra {
		// Look for the RBF name
		rbf_name := mra_xml.FindNode("rbf").text // it must find it
		rbf_name = rbf_name[2:] // deletes the initial jt
		if args.JTbin {
			fname = os.Getenv("JTBIN")
		} else {
			fname = filepath.Join(os.Getenv("JTROOT"),"release")
		}
		fname = filepath.Join( fname, "mister", rbf_name, "releases" )
		os.MkdirAll(fname, 0775 )
		fname = filepath.Join( fname, fix_filename(game_name) + ".mra" )
		if args.Verbose {
			fmt.Println("Creating ",fname)
		}
		os.WriteFile(fname, []byte(b.String()),0666)
		main_copied = true
	}
	return main_copied
}

func mra_disclaimer(machine *MachineXML, year string) string {
	var disc strings.Builder
	disc.WriteString("<!--          FPGA arcade hardware by Jotego\n")
	disc.WriteString(`
              This core is available for hardware compatible with MiST and MiSTer
              Other FPGA systems may be supported by the time you read this.
              This work is not mantained by the MiSTer project. Please contact the
              core author for issues and updates.

              (c) Jose Tejada, `)
	if year == "" {
		disc.WriteString(fmt.Sprintf("%d", time.Now().Year()))
	} else {
		disc.WriteString(year)
	}
	disc.WriteString(
		`. Please support this research
              Patreon: https://patreon.com/jotego

              The author does not endorse or participate in illegal distribution
              of copyrighted material. This work can be used with compatible
              software. This software can be homebrew projects or legally
              obtained memory dumps of compatible games.

              This file license is GNU GPLv2.
              You can read the whole license file in
              https://opensource.org/licenses/gpl-2.0.php

-->

`)
	return disc.String()
}

func guess_world_region(name string) string {
	p0 := strings.Index(name, "(")
	if p0 < 0 {
		return "World"
	}
	name = name[p0+1:]
	p1 := strings.Index(name, ")")
	if p1 < 0 {
		return "World"
	}
	name = strings.ToLower(name[:p1])
	if strings.Index(name, "world") > 0 {
		return "World"
	}
	if strings.Index(name, "japan") > 0 {
		return "Japan"
	}
	if strings.Index(name, "euro") > 0 {
		return "Europe"
	}
	if strings.Index(name, "asia") > 0 {
		return "Asia"
	}
	if strings.Index(name, "korea") > 0 {
		return "Korea"
	}
	if strings.Index(name, "taiwan") > 0 {
		return "Taiwan"
	}
	if strings.Index(name, "hispanic") > 0 {
		return "Hispanic"
	}
	if strings.Index(name, "brazil") > 0 {
		return "Brazil"
	}
	return "World"
}

func set_rbfname(root *XMLNode, machine *MachineXML, cfg Mame2MRA, args Args) *XMLNode {
	name := cfg.Rbf.Name
check_devs:
	for _, cfg_dev := range cfg.Rbf.Dev {
		for _, mac_dev := range machine.Devices {
			if cfg_dev.Dev == mac_dev.Name {
				name = cfg_dev.Rbf
				break check_devs
			}
		}
	}
	// Machine definitions override DEV definitions
	for _, each := range cfg.Rbf.Machines {
		if each.Machine == "" {
			continue
		}
		if machine.Cloneof == each.Machine || machine.Name == each.Machine {
			name = each.Rbf
			break
		}
	}
	// setname definitions have the highest priority
	for _, each := range cfg.Rbf.Machines {
		if each.Setname == "" {
			continue
		}
		if machine.Name == each.Setname {
			name = each.Rbf
			break
		}
	}
	if name == "" {
		fmt.Printf("\tWarning: no RBF name defined\n")
	}
	return root.AddNode("rbf", name)
}

func mra_name(machine *MachineXML, cfg Mame2MRA) string {
	for _, ren := range cfg.Parse.Rename {
		if ren.Setname == machine.Name {
			return ren.Name
		}
	}
	return machine.Description
}

// Do not pass the macros to make_mra, but instead modifiy the configuration
// based on the macros in parse_toml
func make_mra(machine *MachineXML, cfg Mame2MRA, args Args) (*XMLNode, string) {
	root := XMLNode{name: "misterromdescription"}
	n := root.AddNode("about").AddAttr("author", "jotego")
	n.AddAttr("webpage", "https://patreon.com/jotego")
	n.AddAttr("source", "https://github.com/jotego")
	n.AddAttr("twitter", "@topapate")
	root.AddNode("name", mra_name(machine, cfg)) // machine.Description)
	root.AddNode("setname", machine.Name)
	set_rbfname(&root, machine, cfg, args)
	root.AddNode("mameversion", Mame_version())
	root.AddNode("year", machine.Year)
	root.AddNode("manufacturer", machine.Manufacturer)
	root.AddNode("players", strconv.Itoa(machine.Input.Players))
	if len(machine.Input.Control) > 0 {
		root.AddNode("joystick", machine.Input.Control[0].Ways)
	}
	n = root.AddNode("rotation")
	switch machine.Display.Rotate {
		case 90:   n.SetText("vertical (cw)")
		case 270:  n.SetText("vertical (ccw)")
		default:   n.SetText("horizontal")
	}
	root.AddNode("region", guess_world_region(machine.Description))
	// Custom tags, sort them first
	info := append(cfg.Global.Info, args.Info...)
	sort.Slice(info, func(p, q int) bool {
		return info[p].Tag[0] < info[q].Tag[0]
	})
	for _, t := range info {
		root.AddNode(t.Tag, t.Value)
	}
	// MRA author
	if len(cfg.Global.Mraauthor) > 0 {
		authors := ""
		for k, a := range cfg.Global.Mraauthor {
			if k > 0 {
				authors += ","
			}
			authors += a
		}
		root.AddNode("mraauthor", authors)
	}
	// ROM load
	make_ROM(&root, machine, cfg, args )
	// Beta
	if cfg.Features.Beta {
		n := root.AddNode("rom").AddAttr("index", "17")
		n.AddAttr("zip", "jtbeta.zip").AddAttr("md5", "None")
		n.AddNode("part").AddAttr("name", "beta.bin")
	}
	if cfg.Features.Debug {
		n := root.AddNode("rom").AddAttr("index", "16")
		n.AddAttr("zip", "debug.zip").AddAttr("md5", "None")
		n.AddNode("part").AddAttr("name", "debug.bin")
	}
	// NVRAM
	if cfg.Features.Nvram != 0 {
		n := root.AddNode("nvram").AddAttr("index", "2")
		n.AddIntAttr("size", cfg.Features.Nvram)
	}
	// coreMOD
	make_coreMOD(&root, machine, cfg)
	// DIP switches
	def_dipsw := make_switches(&root, machine, cfg, args)
	// Buttons
	make_buttons(&root, machine, cfg, args)
	return &root, def_dipsw
}

func hexdump(data []byte, cols int) string {
	var bld strings.Builder
	l := len(data)
	bld.Grow(l << 2)
	for k := 0; k < l; k++ {
		fmtstr := "%02X "
		if (k % cols) == (cols - 1) {
			fmtstr = "%02X\n"
		}
		bld.WriteString(fmt.Sprintf(fmtstr, data[k]))
	}
	return bld.String()
}

func make_buttons(root *XMLNode, machine *MachineXML, cfg Mame2MRA, args Args) {
	button_def := "button 1,button 2"
	button_set := false
	for _, b := range cfg.Buttons.Names {
		// default definition is allowed
		if (b.Machine == "" && b.Setname == "" && !button_set) || is_family(b.Machine,machine) {
			button_def = b.Names
			button_set = true
		}
	}
	for _, b := range cfg.Buttons.Names {
		// Explicit setname has higher priority
		if b.Setname == machine.Name {
			//fmt.Printf("Explicit assignment for %s to %s\n", b.Setname, b.Names)
			button_def = b.Names
		}
	}
	// an explicit command line argument will override the values in TOML
	if args.Buttons != "" {
		button_def = args.Buttons
	}
	// Generic default value
	if button_def == "" {
		button_def = "Shot,Jump"
	}
	n := root.AddNode("buttons")
	buttons := strings.Split(button_def, ",")
	buttons_str := ""
	count := 0
	for k := 0; k < len(buttons) && k < cfg.Buttons.Core; k++ {
		buttons_str += buttons[k] + ","
		if buttons[k] != "-" {
			count++
			if count > 6 {
				fmt.Println("Warning: cannot support more than 6 buttons")
				break
			}
		}
	}
	pad := "Y,X,B,A,R,L,"
	for k := len(buttons); k < 6 && k < cfg.Buttons.Core; k++ {
		buttons_str += "-,"
	}
	pad = pad[0 : cfg.Buttons.Core*2]
	buttons_str += "Start,Coin,Core credits"
	n.AddAttr("names", buttons_str)
	n.AddAttr("default", pad+"Start,Select,-")
	n.AddIntAttr("count", count)
}

func make_coreMOD(root *XMLNode, machine *MachineXML, cfg Mame2MRA) {
	coremod := 0
	if machine.Display.Rotate != 0 {
		root.AddNode("Vertical game").comment = true
		coremod |= 1
		if machine.Display.Rotate !=90 {
			coremod |= 4
		}
	}
	n := root.AddNode("rom").AddAttr("index", "1")
	n = n.AddNode("part")
	n.SetText(fmt.Sprintf("%02X", coremod))
}

func make_devROM(root *XMLNode, machine *MachineXML, cfg Mame2MRA, pos *int) {
	for _, dev := range machine.Devices {
		if strings.Contains(dev.Name, "fd1089") {
			reg_cfg := find_region_cfg( machine, "fd1089", cfg)
			if delta := fill_upto(pos, reg_cfg.start, root); delta < 0 {
				fmt.Printf(
					"\tstart offset overcome by 0x%X while adding FD1089 LUT\n", -delta)
			}
			root.AddNode(fmt.Sprintf(
				"FD1089 base table starts at 0x%X", *pos)).comment = true
			root.AddNode("part").SetText(hexdump(fd1089_bin[:], 16)).indent_txt = true
			*pos += len(fd1089_bin)
		}
	}
}

func is_family(name string, machine *MachineXML) bool {
	return name != "" && (name == machine.Name || name == machine.Cloneof)
}

// if the region is marked for splitting returns the
// offset at which it must occur. Otherwise, zero
// only one split per region will be applied
func is_split(reg string, machine *MachineXML, cfg Mame2MRA) (offset, min_len int) {
	offset = 0
	min_len = 0
	for _, split := range cfg.ROM.Splits {
		if 	(split.Region != ""  && split.Region != reg) ||
			(split.Machine != "" && !is_family(split.Machine, machine)) ||
			(split.Setname != "" && split.Setname != machine.Name) ||
			(split.Namehas != "" && !strings.Contains(machine.Name, split.Namehas)) {
			continue
		}
		offset = split.Offset
		min_len = split.Min_len
	}
	return offset, min_len
}

// if the region is marked for a blank at this point returns its length
// otherwise, zero
func is_blank(curpos int, reg string, machine *MachineXML, cfg Mame2MRA) (blank_len int) {
	blank_len = 0
	offset := 0
	for _, blank := range cfg.ROM.Blanks {
		if blank.Region != reg && blank.Region != "" {
			continue
		}
		if (blank.Machine == "" && blank.Setname == "") || // apply to all
			is_family(blank.Machine, machine) || // apply to machine
			(blank.Setname == machine.Name) { // apply to a setname
			offset = blank.Offset
			blank_len = blank.Len
		}
	}
	if offset != 0 && offset == curpos {
		return blank_len
	} else {
		return 0
	}
}

func parse_singleton( reg_roms []MameROM, reg_cfg *RegCfg, p *XMLNode ) int {
	pos := 0
	if reg_cfg.Width!=16 && reg_cfg.Width!=32 {
		log.Fatal("jtframe mra: singleton only supported for width 16 and 32")
	}
	var n *XMLNode
	p.AddNode("Singleton region. The files are merged with themselves.").comment = true
	msb     := (reg_cfg.Width/8)-1
	divider := reg_cfg.Width>>3
	mapfmt  := fmt.Sprintf("%%0%db",divider)
	for _, r := range reg_roms {
		n = p.AddNode("interleave").AddAttr("output", fmt.Sprintf("%d", reg_cfg.Width))
		mapbyte := 1
		if reg_cfg.Reverse {
			mapbyte = 1 << msb // 2 for 16 bits, 8 for 32 bits
		}
		for k:=0; k<divider; k++ {
			m := add_rom(n, r)
			m.AddAttr("offset", fmt.Sprintf("0x%04x", r.Size/divider*k))
			m.AddAttr("map", fmt.Sprintf(mapfmt,mapbyte))
			m.AddAttr("length", fmt.Sprintf("0x%04X", r.Size/divider))
			// Second half
			if reg_cfg.Reverse {
				mapbyte >>= 1
			} else {
				mapbyte <<= 1
			}
		}
		pos += r.Size
	}
	return pos
}


func parse_straight_dump( split, split_minlen int, reg string, reg_roms []MameROM, reg_cfg *RegCfg, p *XMLNode, machine *MachineXML, cfg Mame2MRA, pos *int ) {
	reg_pos := 0
	start_pos := *pos
	for _, r := range reg_roms {
		offset := r.Offset
		if reg_cfg.No_offset {
			offset = 0
		} else {
			if delta := fill_upto(pos, ((offset&-2)-reg_pos)+*pos, p); delta < 0 {
				fmt.Printf("Warning: ROM start overcome at 0x%X (expected 0x%X - delta=%X)\n",
					*pos, ((offset&-2)-reg_pos)+*pos, delta)
				fmt.Printf("\t while parsing region %s (%s)\n", reg_cfg.Name, machine.Name)
			}
		}
		rom_pos := *pos
		// check if the next ROM should be split
		rom_len := 0
		var m *XMLNode
		if reg_cfg.Reverse {
			pp := p.AddNode("interleave").AddAttr("output", "16")
			m = add_rom(pp, r)
			m.AddAttr("map", "12")
		} else {
			m = add_rom(p, r)
		}
		// Parse ROM splits by marking the dumped ROM above
		// as only the first half, filling in a blank, and
		// adding the second half
		if *pos-start_pos <= split && *pos-start_pos+r.Size > split && split_minlen > (r.Size>>1) {
			fmt.Printf("\t-split on single ROM file at %X\n", split)
			rom_len = r.Size >> 1
			m.AddAttr("length", fmt.Sprintf("0x%X", rom_len))
			*pos += rom_len
			fill_upto(pos, *pos+split_minlen-rom_len, p)
			// second half
			if reg_cfg.Reverse {
				pp := p.AddNode("interleave").AddAttr("output", "16")
				m = add_rom(pp, r)
				m.AddAttr("map", "12")
			} else {
				m = add_rom(p, r)
			}
			m.AddAttr("length", fmt.Sprintf("0x%X", rom_len))
			m.AddAttr("offset", fmt.Sprintf("0x%X", rom_len))
			*pos += rom_len
		} else {
			*pos += r.Size
		}
		if reg_cfg.Rom_len > r.Size {
			fill_upto(pos, reg_cfg.Rom_len+rom_pos, p)
		}
		reg_pos = *pos - start_pos
		if blank_len := is_blank(reg_pos, reg, machine, cfg); blank_len > 0 {
			fill_upto(pos, *pos+blank_len, p)
			p.AddNode(fmt.Sprintf("Blank ends at 0x%X", *pos)).comment = true
		}
		reg_pos = *pos - start_pos
	}
}

func parse_i8751(reg_cfg *RegCfg, p *XMLNode, machine *MachineXML, pos *int, args Args ) bool {
	path := filepath.Join(args.firmware_dir, machine.Name+".s" )
	f, e := os.Open(path)
	if e != nil {
		path := filepath.Join(args.firmware_dir, machine.Cloneof+".s" )
		f, e = os.Open(path)
		if e != nil {
			log.Println("jtframe mra: cannot find custom firmware for ",machine.Name)
			return false
		}
	}
	f.Close()
	binname := fmt.Sprintf("mra%X%X.bin",rand.Int(), rand.Int())
	cmd := exec.Command("as31", "-Fbin", "-O"+binname, path)
	e = cmd.Run()
	if e != nil {
		log.Println("jtframe mra, problem running as31:\n\t",e)
		return false
	}
	// Read the result and add it as data
	bin, e := ioutil.ReadFile(binname)
	if e != nil {
		log.Println("jtframe mra, problem reading as31 output:\n\t",e)
		return false
	}
	*pos += len(bin)
	p.AddNode("Using custom firmware (no known dump)").comment = true
	node := p.AddNode("part")
	node.indent_txt = true
	node.SetText(hexdump(bin, 16 ))
	return true
}

func parse_custom(reg_cfg *RegCfg, p *XMLNode, machine *MachineXML, pos *int, args Args ) bool {
	if reg_cfg.Custom.Dev == "" {
		return false
	}
	switch reg_cfg.Custom.Dev {
		case "i8751": {
			return parse_i8751( reg_cfg, p, machine, pos, args )
		}
		default: log.Fatal("jtframe mra: unsupported custom.dev=",reg_cfg.Custom.Dev)
	}
	return false
}

func parse_regular_interleave( split, split_minlen int, reg string, reg_roms []MameROM, reg_cfg *RegCfg, p *XMLNode, machine *MachineXML, cfg Mame2MRA, pos *int ) {
	reg_pos := 0
	start_pos := *pos
	group_cnt := 0
	if !reg_cfg.No_offset {
		// Try to determine from the offset the word-length of each ROM
		// as well as the isolated ones
		fmt.Println("Parsing ", reg_cfg.Name)
		for k:=0; k<len(reg_roms); {
			// Try to make a group
			kmin := k
			kmax := kmin
			wlen := 8
			for j:=kmin; j<len(reg_roms); j++ {
				if (reg_roms[kmin].Offset&^0xf) != (reg_roms[j].Offset&^0xf ) {
					break
				}
				if reg_roms[j].Offset & 1 != 0 {
					wlen = 1
				}
				if wlen > 1 && (reg_roms[j].Offset & 2) != 0 {
					wlen = 2
				}
				if wlen > 2 && (reg_roms[j].Offset & 4) != 0 {
					wlen = 4
				}
				kmax=j
			}
			if kmin!=kmax {
				fmt.Printf("\tGroup found (%d-%d)\n",kmin,kmax)
				group_cnt++
				if (kmax-kmin+1)*wlen != (reg_cfg.Width>>3) {
					fmt.Printf("jtframe mra: the number of ROMs for the %d-bit region (%s) is not even (%s).\nUsing ROMs:\n",
						reg_cfg.Width, reg_cfg.Name, machine.Name )
					for j:=kmin;j<=kmax;j++ {
						fmt.Printf("\t%s\n",reg_roms[j].Name)
					}
					os.Exit(1)
				}
			}
			for j:=kmin; j<=kmax && kmin!=kmax; j++ {
				reg_roms[j].group = group_cnt
				reg_roms[j].wlen  = wlen
				fmt.Println("\t\t",reg_roms[j].Name)
			}
			group_cnt += kmax-kmin+1
			k = kmax+1
		}
	} else {
		// If no_offset is set, then assume all are grouped together and the word length is 1 byte
		if (len(reg_roms) % (reg_cfg.Width / 8)) != 0 {
			log.Fatal(fmt.Sprintf("The number of ROMs for the %d-bit region (%s) is not even in %s",
				reg_cfg.Width, reg_cfg.Name, machine.Name ))
		}
		for j,_ := range reg_roms {
			reg_roms[j].group = 1
			reg_roms[j].wlen  = 1
		}
		group_cnt = len(reg_roms)
	}
	n := p
	deficit := 0
	for split_phase := 0; split_phase <= split && split_phase < 2; split_phase++ {
		if split_phase == 1 {
			p.AddNode(fmt.Sprintf("ROM split at %X (%X)", *pos, *pos-start_pos)).comment = true
		}
		chunk0 := *pos
		for k := 0; k <len(reg_roms); {
			r := reg_roms[k]
			mapstr := ""
			rom_cnt := 1
			if r.group != 0 {
				// make interleave node at the expected position
				if deficit > 0 {
					fill_upto(pos, *pos+deficit, p)
				}
				reg_pos = *pos - start_pos
				offset := r.Offset
				if reg_cfg.No_offset {
					offset = 0
				}
				fill_upto(pos, ((offset&-2)-reg_pos)+*pos, p)
				deficit = 0
				n = p.AddNode("interleave").AddAttr("output", fmt.Sprintf("%d", reg_cfg.Width))
				// Prepare the map
				for j:=r.wlen; j>0; j-- {
					mapstr = mapstr + strconv.Itoa(j)
				}
				for j:=r.wlen; j<(reg_cfg.Width>>3); j++ {
					mapstr = "0" + mapstr
				}
				rom_cnt = (reg_cfg.Width>>3)/r.wlen;
			}
			process_rom := func( j int) {
				r = reg_roms[j]
				fmt.Println("Parsing ",r.Name)
				m := add_rom( n, r)
				if( mapstr!="") {
					m.AddAttr("map", mapstr)
					mapstr = mapstr[r.wlen:] + mapstr[0:r.wlen] // rotate the active byte
				}
				if split != 0 {
					m.AddAttr("length", fmt.Sprintf("0x%X", r.Size/2))
					if split_phase == 1 {
						m.AddAttr("offset", fmt.Sprintf("0x%X", r.Size/2))
					}
					*pos += r.Size / 2
				} else {
					*pos += r.Size
					if reg_cfg.Rom_len > r.Size {
						deficit += reg_cfg.Rom_len - r.Size
					}
				}
				reg_pos = *pos - start_pos
				if blank_len := is_blank(reg_pos, reg, machine, cfg); blank_len > 0 {
					fill_upto( pos, *pos+blank_len, p)
					p.AddNode(fmt.Sprintf("Blank ends at 0x%X", *pos)).comment = true
				}
			}
			if reg_cfg.Reverse {
				for j:=k+rom_cnt-1; j>=k;j-- {
					process_rom(j)
				}
			} else {
				for j:=k;j<k+rom_cnt;j++ {
					process_rom(j)
				}
			}
			n=p
			k += rom_cnt
		}
		if *pos-chunk0 < split_minlen {
			// fmt.Printf("\tsplit minlen = %x (dumped = %X) \n", split_minlen, *pos-chunk0)
			fill_upto(pos, split_minlen+chunk0, p)
		}
	}
}

func sdram_bank_comment( root *XMLNode, pos int, macros map[string]string) {
	for k,v := range macros { // []string{"JTFRAME_BA1_START","JTFRAME_BA2_START","JTFRAME_BA3_START"} {
		start, _ := strconv.ParseInt( v, 0, 32 )
		if start==0 {
			continue
		}
		if int(start)==pos {
			root.AddNode(k).comment = true
		}
	}
}

func make_ROM(root *XMLNode, machine *MachineXML, cfg Mame2MRA, args Args) {
	if len(machine.Rom) == 0 {
		return
	}
	if args.Verbose {
		fmt.Println("Parsing ", machine.Name)
	}
	// Create nodes
	p := root.AddNode("rom").AddAttr("index", "0")
	zipname := machine.Name + ".zip"
	if len(machine.Cloneof) > 0 {
		zipname += "|" + machine.Cloneof + ".zip"
	}
	if len(cfg.Global.Zip.Alt) > 0 {
		zipname += "|" + cfg.Global.Zip.Alt
	}
	p.AddAttr("zip", zipname)
	p.AddAttr("md5", "None")
	regions := cfg.ROM.Order
	// Add regions unlisted in the config to the final list
	sorted_regs := make(map[string]bool)
	for _, r := range regions {
		sorted_regs[r] = true
	}
	cur_region := ""
	for _, rom := range machine.Rom {
		if cur_region != rom.Region {
			cur_region = rom.Region
			_, ok := sorted_regs[rom.Region]
			if !ok {
				regions = append(regions, cur_region)
			}
		}
	}
	var header *XMLNode
	if cfg.Header.Len > 0 {
		header = p.AddNode("part")
		header.indent_txt = true
	}
	pos := 0
	reg_offsets := make(map[string]int)

	var previous StartNode
	for _, reg := range regions {
		reg_cfg := find_region_cfg(machine, reg, cfg)
		if reg_cfg.Skip {
			continue
		}
		// Warn about unsorted regions
		_, sorted := sorted_regs[reg]
		if !sorted {
			fmt.Printf("\tunlisted region for sorting %s in %s\n", reg, machine.Name )
		}
		reg_roms := extract_region(reg_cfg, machine.Rom, cfg.ROM.Remove)
		// Skip empty regions
		if len(reg_roms) == 0 {
			continue
		}
		// Skip regions with "nodump" ROMs
		nodump := false
		for _, each := range reg_roms {
			if each.Status == "nodump" {
				nodump = true
			}
		}
		// Proceed with the ROM listing
		if delta := fill_upto(&pos, reg_cfg.start, p); delta < 0 {
			fmt.Printf(
				"\tstart offset overcome by 0x%X while parsing region %s in %s\n",
				-delta, reg, machine.Name)
		}
		sdram_bank_comment( p, pos, args.macros )
		// comment with start and length of region
		previous.add_length(pos)
		previous.node = p.AddNode(fmt.Sprintf("%s - starts at 0x%X", reg, pos))
		previous.node.comment = true
		previous.pos = pos
		start_pos := pos

		if nodump {

			if parse_custom( reg_cfg, p, machine, &pos, args ) {
				fill_upto(&pos, start_pos+reg_cfg.Len, p)
			} else {
				p.AddNode(fmt.Sprintf("Skipping region %s because there is no dump known",
					reg_cfg.Name)).comment = true
			}
			continue
		}

		reg_offsets[reg] = pos
		reg_roms = apply_sort(reg_cfg, reg_roms,machine.Name)
		if reg_cfg.Singleton {
			// Singleton interleave case
			pos += parse_singleton( reg_roms, reg_cfg, p )
		} else {
			split, split_minlen := is_split(reg, machine, cfg)
			// Regular interleave case
			if (reg_cfg.Width!=0 && reg_cfg.Width!=8) && len(reg_roms) > 1  {
				parse_regular_interleave( split, split_minlen, reg, reg_roms, reg_cfg, p, machine, cfg, &pos )
			}
			if reg_cfg.Frac.Parts != 0 {
				pos += make_frac(p, reg_cfg, reg_roms)
			} else if (reg_cfg.Width <= 8 || len(reg_roms) == 1)  {
				parse_straight_dump( split, split_minlen, reg, reg_roms, reg_cfg, p, machine, cfg, &pos )
			}
		}
		fill_upto(&pos, start_pos+reg_cfg.Len, p)
	}
	previous.add_length(pos)
	make_devROM(p, machine, cfg, &pos)
	p.AddNode(fmt.Sprintf("Total 0x%X bytes - %d kBytes", pos, pos>>10)).comment = true
	make_patches(p, machine, cfg)
	if header != nil {
		fill_header(header, reg_offsets, pos, cfg.Header, machine)
	}
}

func make_patches(root *XMLNode, machine *MachineXML, cfg Mame2MRA) {
	for _, each := range cfg.ROM.Patches {
		if is_family(each.Machine, machine) ||
			each.Setname == machine.Name ||
			(each.Machine == "" && each.Setname == "") {
			// apply the patch
			root.AddNode("patch", each.Value).AddAttr("offset", fmt.Sprintf("0x%X", each.Offset))
		}
	}
}

func set_header_offset(headbytes []byte, pos int, reverse bool, bits, offset int) {
	offset >>= bits
	headbytes[pos] = byte((offset >> 8) & 0xff)
	headbytes[pos+1] = byte(offset & 0xff)
	if reverse {
		aux := headbytes[pos]
		headbytes[pos] = headbytes[pos+1]
		headbytes[pos+1] = aux
	}
}

func fill_header(node *XMLNode, reg_offsets map[string]int,
	total int, cfg HeaderCfg, machine *MachineXML) {
	devs := machine.Devices
	headbytes := make([]byte, cfg.Len)
	for k := 0; k < cfg.Len; k++ {
		headbytes[k] = byte(cfg.Fill)
	}
	// Fill ROM offsets
	unknown_regions := make([]string, 0)
	if len(cfg.Offset.Regions) > 0 {
		pos := cfg.Offset.Start
		for _, r := range cfg.Offset.Regions {
			offset, ok := reg_offsets[r]
			if !ok {
				unknown_regions = append(unknown_regions, r)
				offset = 0
			}
			// fmt.Printf("region %s offset %X\n", r, offset)
			set_header_offset(headbytes, pos, cfg.Offset.Reverse, cfg.Offset.Bits, offset)
			pos += 2
		}
		set_header_offset(headbytes, pos, cfg.Offset.Reverse, cfg.Offset.Bits, total)
	}
	if len(unknown_regions) > 0 {
		fmt.Printf("\tmissing region(s)")
		for _, uk := range unknown_regions {
			fmt.Printf(" %s", uk)
		}
		fmt.Printf(". Offset set to zero in the header (%s)\n",machine.Name)
	}
	// Manual headers
	for _, each := range cfg.Data {
		if (len(each.Machine) != 0 && !is_family(each.Machine, machine)) || (len(each.Setname) != 0 && each.Setname != machine.Name) {
			continue // skip it
		}
		pos := each.Pointer
		for k, hexbyte := range strings.Split(each.Data, " ") {
			if pos+k > len(headbytes) {
				log.Fatal("Header pointer larger than declared header")
			}
			conv, _ := strconv.ParseInt(hexbyte, 16, 0)
			headbytes[pos+k] = byte(conv)
		}
	}
	// Device dependent values
	for _, d := range cfg.Dev {
		found := false
		for _, ref := range devs {
			if d.Dev == ref.Name {
				found = true
				break
			}
		}
		if found {
			if d.Byte >= len(headbytes) {
				log.Fatal("Header device-byte falls outside the header")
			}
			headbytes[d.Byte] = byte(d.Value)
		}
	}
	node.SetText(hexdump(headbytes, 8))
}

func make_frac(parent *XMLNode, reg_cfg *RegCfg, reg_roms []MameROM) int {
	dumped := 0
	if (len(reg_roms) % reg_cfg.Frac.Parts) != 0 {
		// There are not enough ROMs, so repeat the last one
		// This is useful in cases such as having 3bpp graphics
		missing := reg_cfg.Frac.Parts - (len(reg_roms) % reg_cfg.Frac.Parts)
		// filled contains the original ROM list with
		// fillers inserted at the end of each group of ROMs
		var filled []MameROM
		step := len(reg_roms) / missing
		for k := 0; k < missing; k++ {
			filled = append(filled, reg_roms[k*step:(k+1)*step]...)
			filled = append(filled, filled[len(filled)-1])
		}
		reg_roms = filled
		////fmt.Println("Added ", missing, " roms to the end")
		//for k, r := range reg_roms {
		//	fmt.Println(k, " - ", r.Name)
		//}
	}
	output_bytes := reg_cfg.Frac.Parts / reg_cfg.Frac.Bytes
	if (output_bytes % 2) != 0 {
		log.Fatal(fmt.Sprintf(
			"Region %s: frac output_bytes (%d) is not a multiple of 2",
			reg_cfg.Name, output_bytes))
	}
	// ROM entries
	var n *XMLNode
	group_size := 0
	group_start := 0
	frac_groups := len(reg_roms) / reg_cfg.Frac.Parts
	for k, r := range reg_roms {
		cnt := k / reg_cfg.Frac.Parts
		mod := k % reg_cfg.Frac.Parts
		if mod == 0 {
			if k != 0 && (reg_cfg.Rom_len != 0 || reg_cfg.Len != 0) {
				exp_size := reg_cfg.Rom_len * reg_cfg.Frac.Parts
				if reg_cfg.Len/frac_groups > exp_size {
					exp_size = reg_cfg.Len / frac_groups
				}
				fill_upto(&dumped, group_start+exp_size*cnt, parent)
			}
			n = parent.AddNode("interleave").AddIntAttr("output", output_bytes*8)
			group_size = 0
			group_start = dumped
		}
		m := n.AddNode("part").AddAttr("name", r.Name)
		if len(r.Crc) > 0 {
			m.AddAttr("crc", r.Crc)
		}
		m.AddAttr("map", make_frac_map(reg_cfg.Reverse, reg_cfg.Frac.Bytes,
			output_bytes, mod))
		dumped += r.Size
		group_size += r.Size
	}
	return dumped
}

func make_frac_map(reverse bool, bytes, total, step int) string {
	mapstr := make([]byte, total)
	for k := 0; k < total; k++ {
		mapstr[k] = '0'
	}
	c := byte('1')
	j := step * bytes
	js := 1
	if !reverse {
		j = total - j - 1
		js = -1
	}
	// fmt.Println("Reverse = ", reverse, "j = ", j, "total = ", total, " step = ", step)
	for i := 0; i < bytes; {
		mapstr[j] = c
		c = c + 1
		i++
		j += js
	}
	var builder strings.Builder
	builder.Grow(total)
	builder.Write(mapstr)
	return builder.String()
}

func extract_region( reg_cfg *RegCfg, roms []MameROM, remove []string) (ext []MameROM) {
	// Custom list
	if len(reg_cfg.Files)>0 {
		// fmt.Println("Using custom files for ", reg_cfg.Name)
		ext = make( []MameROM, len(reg_cfg.Files))
		copy( ext, reg_cfg.Files )
		for k,_ := range ext {
			ext[k].Region = reg_cfg.Name
		}
		return
	}
	// MAME list
roms_loop:
	for _, r := range roms {
		if r.Region == reg_cfg.Name {
			for _, rm := range remove {
				if rm == r.Name {
					continue roms_loop
				}
			}
			ext = append(ext, r)
		}
	}
	return
}

func cmp_count(a, b string, rmext bool) bool {
	if rmext { // removes the file extension
		// this helps comparing file names like abc123.bin
		k := strings.LastIndex(a, ".")
		if k != -1 {
			a = a[0:k]
		}
		k = strings.LastIndex(b, ".")
		if k != -1 {
			b = b[0:k]
		}
	}
	re := regexp.MustCompile("[0-9]+")
	asub := re.FindAllString( a, -1 )
	bsub := re.FindAllString( b, -1 )
	kmax := len(asub)
	if len(bsub) < kmax {
		kmax = len(bsub)
	}
	low := true
	for k:=0;k<kmax;k++ {
		aint, _ := strconv.Atoi(asub[k])
		bint, _ := strconv.Atoi(bsub[k])
		if aint > bint {
			low = false
			break
		}
	}
	return low
}

func sort_byext(reg_cfg *RegCfg, roms []MameROM, setname string) {
	// If all the ROMs have the same extension,
	// it will sort by name instead
	allequal := true
	ext := ""
	for k, r := range roms {
		da := strings.LastIndex(r.Name, ".")
		if da == -1 {
			if ext != "" {
				allequal = false
				break
			} else {
				continue
			}
		} else {
			if k == 0 {
				ext = r.Name[da:]
				continue
			} else {
				if ext != r.Name[da:] {
					allequal = false
					break
				}
			}
		}
	}
	if !allequal {
		// Sort by extension
		sort.Slice(roms, func(i, j int) bool {
			var a *MameROM = &roms[i]
			var b *MameROM = &roms[j]
			da := strings.LastIndex(a.Name, ".")
			db := strings.LastIndex(b.Name, ".")
			if da == -1 {
				return true
			}
			if db == -1 {
				return false
			}
			if reg_cfg.Sort_alpha {
				return strings.Compare(a.Name[da:], b.Name[db:]) < 0
			} else {
				return cmp_count(a.Name[da:], b.Name[db:], false)
			}
		})
	} else {
		// All extensions were equal, so sort by name
		fmt.Printf("\tsorting %s by name as all extensions were equal (%s)\n", reg_cfg.Name, setname)
		sort.Slice(roms, func(i, j int) bool {
			var a *MameROM = &roms[i]
			var b *MameROM = &roms[j]
			if reg_cfg.Sort_alpha {
				return strings.Compare(a.Name, b.Name) < 0
			} else {
				return cmp_count(a.Name, b.Name, true)
			}
		})
	}
}

func sort_even_odd(reg_cfg *RegCfg, roms []MameROM, even_first bool) {
	if !even_first {
		log.Fatal("even_first==false not implemented")
	}
	if reg_cfg.Sort_reverse {
		log.Fatal("even_first==false not implemented")
	}
	base := make([]MameROM, len(roms))
	copy(base, roms)
	// Copy the even ones
	for i := 0; i < len(roms); i += 2 {
		roms[i>>1] = base[i]
	}
	half := len(roms) >> 1
	// Copy the odd ones
	for i := 1; i < len(roms); i += 2 {
		roms[(i>>1)+half] = base[i]
	}
}

func sort_ext_list(reg_cfg *RegCfg, roms []MameROM) {
	base := make([]MameROM, len(roms))
	copy(base, roms)
	k := 0
	for _, ext := range reg_cfg.Ext_sort {
		for i, _ := range base {
			if strings.HasSuffix(base[i].Name, ext) {
				roms[k] = base[i]
				k++
				break
			}
		}
	}
}

func sort_name_list(reg_cfg *RegCfg, roms []MameROM) {
	// fmt.Println("Applying name sorting ", reg_cfg.Name_sort)
	base := make([]MameROM, len(roms))
	copy(base, roms)
	k := 0
	for _, each := range reg_cfg.Name_sort {
		for i, _ := range base {
			if base[i].Name == each {
				roms[k] = base[i]
				k++
				break
			}
		}
	}
}

func sort_regex_list(reg_cfg *RegCfg, roms []MameROM) {
	// fmt.Println("Applying name sorting ", reg_cfg.Name_sort)
	base := make([]MameROM, len(roms))
	copy(base, roms)
	k := 0
	for _, each := range reg_cfg.Regex_sort {
		re := regexp.MustCompile(each)
		for i, _ := range base {
			if re.MatchString(base[i].Name) {
				roms[k] = base[i]
				k++
				break
			}
		}
	}
}

func sort_fullname(reg_cfg *RegCfg, roms []MameROM) {
	sort.Slice(roms, func(i, j int) bool {
		var a *MameROM = &roms[i]
		var b *MameROM = &roms[j]
		if reg_cfg.Sort_alpha {
			return strings.Compare(a.Name, b.Name) < 0
		} else {
			return cmp_count(a.Name, b.Name, true)
		}
	})
}

func apply_sequence(reg_cfg *RegCfg, roms []MameROM) []MameROM{
	kmax := len(roms)
	seqd := make([]MameROM,len(reg_cfg.Sequence))
	copy(seqd,roms)
	for i, k := range reg_cfg.Sequence {
		if k >= kmax {
			k=0		// Not necessarily an error, as some ROM sets may have more files than others
		}
		seqd[i] = roms[k]
	}
	return seqd
}

func apply_sort(reg_cfg *RegCfg, roms []MameROM, setname string) []MameROM{
	if len(reg_cfg.Sequence) > 0 {
		return apply_sequence( reg_cfg, roms )
	}
	if len(reg_cfg.Ext_sort) > 0 {
		sort_ext_list(reg_cfg, roms)
		return roms
	}
	if len(reg_cfg.Name_sort) > 0 {
		sort_name_list(reg_cfg, roms)
		return roms
	}
	if len(reg_cfg.Regex_sort) > 0 {
		sort_regex_list(reg_cfg, roms)
		return roms
	}
	if reg_cfg.Sort_even {
		sort_even_odd(reg_cfg, roms, true)
		return roms
	}
	if reg_cfg.Sort_byext {
		sort_byext(reg_cfg, roms, setname)
		if reg_cfg.Sort_reverse {
			base := make([]MameROM, len(roms))
			copy(base, roms)
			for i := 0; i < len(roms); i++ {
				roms[i] = base[len(roms)-1-i]
			}
		}
		return roms
	}
	if reg_cfg.Sort_alpha || reg_cfg.Sort {
		sort_fullname( reg_cfg, roms )
		return roms
	}
	return roms
}

func add_rom(parent *XMLNode, rom MameROM) *XMLNode {
	n := parent.AddNode("part").AddAttr("name", rom.Name)
	if len(rom.Crc) > 0 {
		n.AddAttr("crc", rom.Crc)
	}
	return n
}

func fill_upto(pos *int, fillto int, parent *XMLNode) int {
	if fillto == 0 {
		return 0
	}
	delta := fillto - *pos
	if delta <= 0 {
		return delta
	}
	parent.AddNode("part", " FF").AddAttr("repeat", fmt.Sprintf("0x%X", fillto-*pos))
	*pos += delta
	return delta
}

func find_region_cfg(machine *MachineXML, regname string, cfg Mame2MRA) *RegCfg {
	var best *RegCfg
	for k, each := range cfg.ROM.Regions {
		if each.Name == regname  {
			if each.Setname == machine.Name {
				best = &cfg.ROM.Regions[k]
				break
			}
			if is_family( each.Machine, machine ) || (each.Setname=="" && each.Machine=="" && best == nil) {
				best = &cfg.ROM.Regions[k]
			}
		}
	}
	// the region does not have a configuration in the TOML file, set a default one:
	if best == nil {
		best = &RegCfg{
			Name: regname,
		}
	}
	return best
}

// make_DIP
func make_switches(root *XMLNode, machine *MachineXML, cfg Mame2MRA, args Args) string {
	if len(machine.Dipswitch) ==0 {
		return "ff,ff"
	}
	def_str := ""
	n := root.AddNode("switches")
	// Switch for MiST
	n.AddAttr("page_id", "1")
	n.AddAttr("page_name", "Switches")
	n.AddIntAttr("base", cfg.Dipsw.base)
	last_tag := ""
	base := 0
	def_cur := 0xff
	game_bitcnt := cfg.Dipsw.Bitcnt
	diploop:
	for _, ds := range machine.Dipswitch {
		ignore := false
		for _, del := range cfg.Dipsw.Delete {
			if del == ds.Name {
				ignore = true
				break
			}
		}
		if ds.Condition.Tag != "" && ds.Condition.Value==0 {
			continue diploop // This switch depends on others, skip it
		}
		// Rename the DIP
		for _, each := range cfg.Dipsw.Rename {
			if each.Name == ds.Name {
				if each.To != "" {
					ds.Name = each.To
				}
				for k, v := range each.Values {
					if k>len(ds.Dipvalue) {
						break
					}
					if v != "" {
						ds.Dipvalue[k].Name = v
					}
				}
				break
			}
		}
		bitmin := 0
		for bitmin=0; bitmin<(1<<32);bitmin++ {
			if (ds.Mask & (1<<bitmin)) != 0 {
				break
			}
		}
		bitmax := bitmin + int( math.Ceil(math.Log2( float64(len(ds.Dipvalue)))) ) - 1
		if ds.Tag != last_tag {
			if len(last_tag) > 0 {
				// Record the default values
				if len(def_str) > 0 {
					def_str += ","
				}
				def_str = def_str + fmt.Sprintf("%02x", def_cur)
				def_cur = 0xff
				base += 8
			}
			last_tag = ds.Tag
			m := n.AddNode(last_tag)
			m.comment = true
		}
		sort.Slice(ds.Dipvalue, func(p, q int) bool {
			return ds.Dipvalue[p].Value < ds.Dipvalue[q].Value
		})
		options := ""
		var opt_dev int
		opt_dev = -1
		next_val := 0
		for _, opt := range ds.Dipvalue {
			if len(options) != 0 {
				options += ","
			}
			this_value := opt.Value >> bitmin
			for next_val < this_value {
				options += "-,"
				next_val++
			}
			options += strings.ReplaceAll(opt.Name, ",", " ")
			next_val++
			if opt.Default == "yes" {
				opt_dev = opt.Value
			}
		}
		if !ignore {
			options = strings.Replace(options, " Coins", "", -1)
			options = strings.Replace(options, " Coin", "", -1)
			options = strings.Replace(options, " Credits", "", -1)
			options = strings.Replace(options, " Credit", "", -1)
			options = strings.Replace(options, " and every ", " & *", -1)
			options = strings.Replace(options, "00000", "00k", -1)
			options = strings.Replace(options, "0000", "0k", -1)
			// remove comments
			re := regexp.MustCompile(`\([^)]*\)`)
			options = re.ReplaceAllString(options, "")
			// remove double spaces
			re = regexp.MustCompile(" +")
			options = re.ReplaceAllString(options, " ")
			// remove spaces around the comma
			re = regexp.MustCompile(" ,")
			options = re.ReplaceAllString(options, ",")
			re = regexp.MustCompile(", ")
			options = re.ReplaceAllString(options, ",")
			m := n.AddNode("dip")
			m.AddAttr("name", ds.Name)
			bitstr := strconv.Itoa(base + bitmin)
			if bitmin != bitmax {
				bitstr += fmt.Sprintf(",%d", base+bitmax)
			}
			game_bitcnt = Max(game_bitcnt, bitmax+base)
			// Check that the DIP name plus each option length isn't longer than 28 characters
			// which is MiSTer's OSD length
			name_len := len(ds.Name)
			for _, each := range strings.Split(options, ",") {
				if tl := name_len + len(each) - 26; tl > 0 {
					fmt.Printf("\tWarning DIP option too long for MiSTer (%d extra):\n\t%s:%s\n",
						tl, ds.Name, each)
				}
			}
			m.AddAttr("bits", bitstr)
			m.AddAttr("ids", options)
		}
		// apply the default value
		if bitmax+1-bitmin < 0 {
			fmt.Printf("bitmin = %d, bitmax=%d\n", bitmin, bitmax)
			log.Fatal("Don't know how to parse DIP ", ds.Name)
		}
		mask := 1 << (1 + Max(cfg.Dipsw.Bitcnt, bitmax) - bitmin)
		mask = (((mask - 1) << bitmin) ^ 0xffff) & 0xffff
		def_cur &= mask
		opt_dev = opt_dev & (mask ^ 0xffff)
		def_cur |= opt_dev
	}
	//base = Max(base, len(def_str)>>2)
	// fmt.Printf("\t1. def_str=%s. base/game_bitcnt = %d/%d \n", def_str, base, game_bitcnt)
	if base < game_bitcnt {
		// Default values of switch parsed last
		if len(def_str) > 0 {
			def_str += ","
		}
		cur_str := fmt.Sprintf("%02x", def_cur)
		def_str += cur_str
		base += len(cur_str) << 2
		// fmt.Printf("\t2. def_str=%s. base/game_bitcnt = %d/%d \n", def_str, base, game_bitcnt)
		for k := base; k < game_bitcnt; k += 8 {
			def_str += ",ff"
			// fmt.Printf("\tn. def_str=%s. base/game_bitcnt = %d/%d \n", def_str, base, game_bitcnt)
		}
	}
	n.AddAttr("default", def_str)
	// Add DIP switches in the extra section, note that these
	// one will always have a default value of 1
	for _, each := range cfg.Dipsw.Extra {
		if args.Verbose {
			fmt.Printf("\tChecking extra DIPSW %s for %s/%s (current %s/%s)\n",
				each.Name, each.Machine, each.Setname, machine.Cloneof, machine.Name)
		}
		if (is_family(each.Machine, machine) || each.Setname == machine.Name) ||
			(each.Machine == "" && each.Setname == "") {
			m := n.AddNode("dip")
			m.AddAttr("name", each.Name)
			m.AddAttr("ids", each.Options)
			m.AddAttr("bits", each.Bits)
		}
	}
	return def_str
}

func Max(x, y int) int {
	if x > y {
		return x
	}
	return y
}

type flag_info struct {
	pargs *Args
}

func (p *flag_info) String() string {
	s := ""
	if p.pargs != nil {
		for _, i := range p.pargs.Info {
			if len(s) > 0 {
				s += ";"
			}
			s = s + i.Tag + "=" + i.Value
		}
	}
	return s
}

func (p *flag_info) Set(a string) error {
	s := strings.Split(a, "=")
	var i Info
	i.Tag = s[0]
	if len(s) > 1 {
		i.Value = s[1]
	}
	p.pargs.Info = append(p.pargs.Info, i)
	return nil
}

func parse_toml(args *Args) (mra_cfg Mame2MRA) {
	macros := jtdef.Make_macros(args.Def_cfg)
	// fmt.Println(macros)
	// Replaces words starting with $ with the corresponding macro
	// and translates the hexadecimal 0x to 'h where needed
	// This functionality is tagged for deletion in favour of
	// using macro names as strings in the TOML, so the TOML
	// syntax does not get broken
	str := jtdef.Replace_Macros(args.Toml_path, macros)
	str = Replace_Hex(str)
	if args.Verbose {
		fmt.Println("TOML file after replacing the macros:")
		fmt.Println(str)
	}

	json_enc := toml.New(bytes.NewBufferString(str))
	dec := json.NewDecoder(json_enc)

	err := dec.Decode(&mra_cfg)
	if err != nil {
		fmt.Println("jtframe mra: problem while parsing TOML file after JSON transformation:\n\t",err)
		fmt.Println(json_enc)
		os.Exit(1)
	}
	mra_cfg.Dipsw.base, _ = strconv.Atoi(macros["JTFRAME_MIST_DIPBASE"])
	// Set the number of buttons to the definition in the macros.def
	if mra_cfg.Buttons.Core==0 {
		mra_cfg.Buttons.Core, _ = strconv.Atoi(macros["JTFRAME_BUTTONS"])
	}
	if mra_cfg.Header.Len > 0 {
		fmt.Println(`The use of header.len in the TOML file is deprecated.
Set JTFRAME_HEADER=length in macros.def instead`)
	}
	aux, _ := strconv.ParseInt(macros["JTFRAME_HEADER"],0,32)
	mra_cfg.Header.Len = int(aux)
	if len(mra_cfg.Dipsw.Delete)==0 {
		mra_cfg.Dipsw.Delete=[]string{"Unused","Unknown"}
	}
	// Add the NVRAM section if it was in the .def file
	if macros["JTFRAME_IOCTL_RD"] != "" {
		if mra_cfg.Features.Nvram != 0 {
			log.Printf(`The use of nvram in the TOML file is deprecated. Just define the macro
	JTFRAME_IOCTL_RD in macros.def instead.\nFound nvram=%d`,mra_cfg.Features.Nvram)
		}
		aux, err := strconv.ParseInt(macros["JTFRAME_IOCTL_RD"],0,32)
		mra_cfg.Features.Nvram = int(aux)
		if err != nil {
			fmt.Println("JTFRAME_IOCTL_RD was ill defined")
			fmt.Println(err)
		}
	}
	// For each ROM region, set the no_offset flag if a
	// sorting option was selected
	// And translate the Start macro to the private start integer value
	for k:=0; k<len(mra_cfg.ROM.Regions); k++ {
		this := &mra_cfg.ROM.Regions[k]
		if this.Start != "" {
			start_str, good1 := macros[this.Start]
			if !good1 {
				fmt.Printf("ERROR: ROM region %s uses undefined macro %s in core %s\n", this.Name, this.Start, args.Def_cfg.Core )
				os.Exit(1)
			}
			aux, err := strconv.ParseInt( start_str, 0, 64)
			if err != nil {
				fmt.Println("ERROR: Macro %s is used as a ROM start, but its value (%s) is not a number\n",
					this.Start, start_str )
				os.Exit(1)
			}
			this.start = int(aux)
		}
		if this.Sort_byext || this.Sort || this.Sort_alpha || this.Sort_even ||
			this.Sort_reverse || this.Singleton || len(this.Ext_sort)>0 ||
			len(this.Name_sort)>0 || len(this.Regex_sort)>0 || len(this.Sequence)>0 {
			this.No_offset = true
		}
	}
	args.macros = macros
	return mra_cfg
}

func Replace_Hex(orig string) string {
	scanner := bufio.NewScanner(strings.NewReader(orig))
	var builder strings.Builder
	re := regexp.MustCompile(`0x[0-9a-fA-F]*`)
	for scanner.Scan() {
		t := scanner.Text()
		matches := re.FindAll([]byte(t), -1)
		for _, match := range matches {
			val, _ := strconv.ParseInt(string(match[2:]), 16, 0)
			conv := fmt.Sprintf("%d", val)
			t = strings.Replace(t, string(match), conv, -1)
		}
		builder.WriteString(t + "\n")
	}
	return builder.String()
}

////////////////// Devices
var fd1089_bin = [256]byte{
	0x00, 0x1c, 0x76, 0x6a, 0x5e, 0x42, 0x24, 0x38, 0x4b, 0x67, 0xad, 0x81,
	0xe9, 0xc5, 0x03, 0x2f, 0x45, 0x69, 0xaf, 0x83, 0xe7, 0xcb, 0x01, 0x2d,
	0x02, 0x1e, 0x78, 0x64, 0x5c, 0x40, 0x2a, 0x36, 0x32, 0x2e, 0x44, 0x58,
	0xe4, 0xf8, 0x9e, 0x82, 0x29, 0x05, 0xcf, 0xe3, 0x93, 0xbf, 0x79, 0x55,
	0x3f, 0x13, 0xd5, 0xf9, 0x85, 0xa9, 0x63, 0x4f, 0xb8, 0xa4, 0xc2, 0xde,
	0x6e, 0x72, 0x18, 0x04, 0x0c, 0x10, 0x7a, 0x66, 0xfc, 0xe0, 0x86, 0x9a,
	0x47, 0x6b, 0xa1, 0x8d, 0xbb, 0x97, 0x51, 0x7d, 0x17, 0x3b, 0xfd, 0xd1,
	0xeb, 0xc7, 0x0d, 0x21, 0xa0, 0xbc, 0xda, 0xc6, 0x50, 0x4c, 0x26, 0x3a,
	0x3e, 0x22, 0x48, 0x54, 0x46, 0x5a, 0x3c, 0x20, 0x25, 0x09, 0xc3, 0xef,
	0xc1, 0xed, 0x2b, 0x07, 0x6d, 0x41, 0x87, 0xab, 0x89, 0xa5, 0x6f, 0x43,
	0x1a, 0x06, 0x60, 0x7c, 0x62, 0x7e, 0x14, 0x08, 0x0a, 0x16, 0x70, 0x6c,
	0xdc, 0xc0, 0xaa, 0xb6, 0x4d, 0x61, 0xa7, 0x8b, 0xf7, 0xdb, 0x11, 0x3d,
	0x5b, 0x77, 0xbd, 0x91, 0xe1, 0xcd, 0x0b, 0x27, 0x80, 0x9c, 0xf6, 0xea,
	0x56, 0x4a, 0x2c, 0x30, 0xb0, 0xac, 0xca, 0xd6, 0xee, 0xf2, 0x98, 0x84,
	0x37, 0x1b, 0xdd, 0xf1, 0x95, 0xb9, 0x73, 0x5f, 0x39, 0x15, 0xdf, 0xf3,
	0x9b, 0xb7, 0x71, 0x5d, 0xb2, 0xae, 0xc4, 0xd8, 0xec, 0xf0, 0x96, 0x8a,
	0xa8, 0xb4, 0xd2, 0xce, 0xd0, 0xcc, 0xa6, 0xba, 0x1f, 0x33, 0xf5, 0xd9,
	0xfb, 0xd7, 0x1d, 0x31, 0x57, 0x7b, 0xb1, 0x9d, 0xb3, 0x9f, 0x59, 0x75,
	0x8c, 0x90, 0xfa, 0xe6, 0xf4, 0xe8, 0x8e, 0x92, 0x12, 0x0e, 0x68, 0x74,
	0xe2, 0xfe, 0x94, 0x88, 0x65, 0x49, 0x8f, 0xa3, 0x99, 0xb5, 0x7f, 0x53,
	0x35, 0x19, 0xd3, 0xff, 0xc9, 0xe5, 0x23, 0x0f, 0xbe, 0xa2, 0xc8, 0xd4,
	0x4e, 0x52, 0x34, 0x28}

////////////////////////////////////
// Command line arguments

func parse_args(args *Args) {
	cores := os.Getenv("CORES")
	if args.Toml_path == "" && args.Def_cfg.Core != "" {
		if len(cores) == 0 {
			log.Fatal("JTFILES: environment variable CORES is not defined")
		}
		args.Toml_path = filepath.Join( cores,args.Def_cfg.Core,"cfg","mame2mra.toml")
	}
	if args.Verbose {
		fmt.Println("Parsing ",args.Toml_path)
	}
	release_dir := filepath.Join(os.Getenv("JTROOT"), "release")
	if args.JTbin {
		release_dir = os.Getenv("JTBIN")
		if release_dir =="" {
			log.Fatal("jtframe mra: JTBIN path must be defined")
		}
	}
	args.outdir = filepath.Join( release_dir, "mra" )
	args.altdir = filepath.Join( args.outdir, "_alternatives" )
	args.pocketdir = filepath.Join( release_dir, "pocket", "raw" )
	args.firmware_dir = filepath.Join( cores,args.Def_cfg.Core,"firmware")
}
