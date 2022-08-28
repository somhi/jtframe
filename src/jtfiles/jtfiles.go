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

package jtfiles

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"gopkg.in/yaml.v2"
)

type Origin int

const (
	GAME Origin = iota
	FRAME
	TARGET
	MODULE
	JTMODULE
)

type FileList struct {
	From   string   `yaml:"from"`
	Get    []string `yaml:"get"`
	Unless string   `yaml:"unless"`
}

type JTModule struct {
	Name   string `yaml:"name"`
	Unless string `yaml:"unless"` // will be compared against env. variables and target argument
}

type JTFiles struct {
	Game    []FileList `yaml:"game"`
	JTFrame []FileList `yaml:"jtframe"`
	Target  []FileList `yaml:"target"`
	Modules struct {
		JT    []JTModule `yaml:"jt"`
		Other []FileList `yaml:"other"`
	} `yaml:"modules"`
	Here []string `yaml:"here"`
}

type Args struct {
	Corename string // JT core
	Parse    string // any file
	Output   string // Output file name
	Rel      bool
	SkipVHDL bool
	Format   string
	Target   string
}

var parsed []string
var CWD string
var args Args

func parse_args(args *Args) {
	flag.Usage = func() {
		fmt.Fprintf(flag.CommandLine.Output(), "%s, part of JTFRAME. (c) Jose Tejada 2021-2022.\nUsage:\n", os.Args[0])
		fmt.Fprint(flag.CommandLine.Output(),
			`    jtfiles look for three yaml files:
		- game.yaml, in the core folder
		- target.yaml, in $JTFRAME/target
		- sim.yaml, in $JTFRAME/target (when simulation output requested)

	 Each yaml file can call other files. The game.yaml file should avoid
	 files specific to a target. That's the only file that a JTFRAME user
	 should populate.
	 The files target.yaml and sim.yaml are part of JTFRAME and should not
	 be modified, except for adding support to new devices.

`)
		flag.PrintDefaults()
		os.Exit(0)
	}
	flag.StringVar(&args.Corename, "core", "", "core name")
	flag.StringVar(&args.Parse, "parse", "", "File to parse. Use either -parse or -core")
	flag.StringVar(&args.Output, "output", "", "Output file name with no extension. Default is 'game'")
	flag.StringVar(&args.Format, "f", "qip", "Output format. Valid values: qip, sim")
	flag.StringVar(&args.Target, "target", "", "Target platform: mist, mister, pocket, etc.")
	flag.BoolVar(&args.Rel, "rel", false, "Output relative paths")
	flag.BoolVar(&args.SkipVHDL, "novhdl", false, "Skip VHDL files")
	flag.Parse()
	if len(args.Corename) == 0 && len(args.Parse) == 0 {
		log.Fatal("JTFILES: You must specify either the core name with argument -core\nor a file name with -parse")
	}
}

func get_filename(args Args) string {
	var fname string
	if len(args.Corename) > 0 {
		cores := os.Getenv("CORES")
		if len(cores) == 0 {
			log.Fatal("JTFILES: environment variable CORES is not defined")
		}
		fname = cores + "/" + args.Corename + "/hdl/game.yaml"
	} else {
		fname = args.Parse
	}
	return fname
}

func append_filelist(dest *[]FileList, src []FileList, other *[]string, origin Origin) {
	if src == nil {
		return
	}
	if dest == nil {
		*dest = make([]FileList, 0)
	}
	for _, each := range src {
		// If an environment variable exists with the
		// name set at "unless", the section is skipped
		if each.Unless != "" {
			_, exists := os.LookupEnv(each.Unless)
			if exists {
				continue
			}
			if strings.ToLower(each.Unless) == strings.ToLower(args.Target) {
				continue
			}
		}
		var newfl FileList
		newfl.From = each.From
		newfl.Get = make([]string, 2)
		for _, each := range each.Get {
			each = strings.TrimSpace(each)
			if strings.HasSuffix(each, ".yaml") {
				var path string
				switch origin {
				case GAME:
					path = os.Getenv("CORES") + "/" + newfl.From + "/hdl/"
				case FRAME:
					path = os.Getenv("JTFRAME") + "/hdl/" + newfl.From + "/"
				case TARGET:
					path = os.Getenv("JTFRAME") + "/target/" + newfl.From + "/"
				default:
					path = os.Getenv("MODULES") + "/"
				}
				*other = append(*other, path+each)
			} else {
				newfl.Get = append(newfl.Get, each)
			}
		}
		if len(newfl.Get) > 0 {
			found := false
			for k, each := range *dest {
				if each.From == newfl.From {
					(*dest)[k].Get = append((*dest)[k].Get, newfl.Get...)
					found = true
					break
				}
			}
			if !found {
				*dest = append(*dest, newfl)
			}
		}
	}
}

func is_parsed(name string) bool {
	for _, k := range parsed {
		if name == k {
			return true
		}
	}
	return false
}

func parse_yaml(filename string, files *JTFiles) {
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		if parsed == nil {
			log.Printf("Warning: cannot open file %s. YAML processing still used for JTFRAME board.", filename)
			return
		} else {
			log.Fatalf("JTFILES: cannot open referenced file %s", filename)
		}
	}
	if parsed == nil {
		parsed = make([]string, 0)
	}
	parsed = append(parsed, filename)
	var aux JTFiles
	err_yaml := yaml.Unmarshal(buf, &aux)
	if err_yaml != nil {
		//fmt.Println(err_yaml)
		log.Fatalf("JTFILES: cannot parse file\n\t%s\n\t%v", filename, err_yaml)
	}
	other := make([]string, 0)
	// Parse
	append_filelist(&files.Game, aux.Game, &other, GAME)
	append_filelist(&files.JTFrame, aux.JTFrame, &other, FRAME)
	append_filelist(&files.Target, aux.Target, &other, TARGET)
	append_filelist(&files.Modules.Other, aux.Modules.Other, &other, MODULE)
	if files.Modules.JT == nil {
		files.Modules.JT = make([]JTModule, 0)
	}
	for _, each := range aux.Modules.JT {
		// Parse the YAML file if it exists
		fname := filepath.Join(os.Getenv("MODULES"), each.Name, "hdl", each.Name+".yaml")
		f, err := os.Open(fname)
		if err == nil {
			f.Close()
			parse_yaml(fname, files)
		} else {
			files.Modules.JT = append(files.Modules.JT, each)
		}
	}
	for _, each := range other {
		if !is_parsed(each) {
			parse_yaml(each, files)
		}
	}
	// "here" files
	if files.Here == nil {
		files.Here = make([]string, 0)
	}
	dir := filepath.Dir(filename)
	for _, each := range aux.Here {
		fullpath := filepath.Join(dir, each)
		if strings.HasSuffix(each, ".yaml") && !is_parsed(each) {
			parse_yaml(fullpath, files)
		} else {
			files.Here = append(files.Here, fullpath)
		}
	}
}

func make_path(path, filename string, rel bool) (item string) {
	var err error
	oldpath := filepath.Join(path, filename)
	if rel {
		item, err = filepath.Rel(CWD, oldpath)
	} else {
		item = filepath.Clean(oldpath)
	}
	if err != nil {
		log.Fatalf("JTFILES: Cannot parse path to %s\n", oldpath)
	}
	return item
}

func dump_filelist(fl []FileList, all *[]string, origin Origin, rel bool) {
	for _, each := range fl {
		var path string
		switch origin {
		case GAME:
			path = filepath.Join(os.Getenv("CORES"), each.From, "hdl")
		case FRAME:
			path = filepath.Join(os.Getenv("JTFRAME"), "hdl", each.From)
		case TARGET:
			path = filepath.Join(os.Getenv("JTFRAME"), "target", each.From)
		case MODULE:
			path = filepath.Join(os.Getenv("MODULES"), each.From)
		default:
			path = os.Getenv("JTROOT")
		}
		for _, each := range each.Get {
			if len(each) > 0 {
				*all = append(*all, make_path(path, each, rel))
			}
		}
	}
}

func dump_jtmodules(mods []JTModule, all *[]string, rel bool) {
	modpath := os.Getenv("MODULES")
	if mods == nil {
		return
	}
	for _, each := range mods {
		if len(each.Name) > 0 {
			lower := strings.ToLower(each.Name)
			lower = filepath.Join(lower, "hdl", lower+".yaml")

			*all = append(*all, make_path(modpath, lower, rel))
		}
	}
}

func collect_files(files JTFiles, rel bool) []string {
	all := make([]string, 0)
	dump_filelist(files.Game, &all, GAME, rel)
	dump_filelist(files.JTFrame, &all, FRAME, rel)
	dump_filelist(files.Target, &all, TARGET, rel)
	dump_jtmodules(files.Modules.JT, &all, rel)
	dump_filelist(files.Modules.Other, &all, MODULE, rel)
	for _, each := range files.Here {
		if rel {
			each, _ = filepath.Rel(CWD, each)
		}
		all = append(all, each)
	}
	sort.Strings(all)
	if len(all) > 0 {
		// Remove duplicated files
		uniq := make([]string, 0)
		for _, each := range all {
			if len(uniq) == 0 || each != uniq[len(uniq)-1] {
				uniq = append(uniq, each)
			}
		}
		// Check that files exist
		for _, each := range uniq {
			if _, err := os.Stat(each); os.IsNotExist(err) {
				fmt.Println("JTFiles warning: file", each, "not found")
			}
		}
		return uniq
	} else {
		return all
	}
}

func get_output_name(args Args) string {
	var fname string
	if args.Output != "" {
		fname = args.Output
	} else if args.Parse != "" {
		fname = strings.TrimSuffix(filepath.Base(args.Parse), ".yaml")
	} else {
		fname = "game"
	}
	return fname
}

func dump_qip(all []string, args Args, do_target bool) {
	fname := get_output_name(args) + ".qip"
	if do_target {
		fname = "target.qip"
	}
	fout, err := os.Create(fname)
	if err != nil {
		log.Fatal(err)
	}
	defer fout.Close()
	for _, each := range all {
		filetype := ""
		switch filepath.Ext(each) {
		case ".sv":
			filetype = "SYSTEMVERILOG_FILE"
		case ".vhd":
			filetype = "VHDL_FILE"
		case ".v":
			filetype = "VERILOG_FILE"
		case ".qip":
			filetype = "QIP_FILE"
		case ".sdc":
			filetype = "SDC_FILE"
		default:
			{
				log.Fatalf("JTFILES: unsupported file extension %s in file %s", filepath.Ext(each), each)
			}
		}
		aux := "set_global_assignment -name " + filetype
		if args.Rel {
			aux = aux + "[file join $::quartus(qip_path) " + each + "]"
		} else {
			aux = aux + " " + each
		}
		fmt.Fprintln(fout, aux)
	}
}

func dump_sim(all []string, args Args, do_target, noclobber bool) {
	fname := get_output_name(args) + ".f"
	if do_target {
		fname = "target.f"
	}
	flag := os.O_CREATE | os.O_WRONLY
	if noclobber {
		flag = flag | os.O_APPEND
	} else {
		flag = flag | os.O_TRUNC
	}

	fout, err := os.OpenFile(fname, flag, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer fout.Close()
	for _, each := range all {
		dump := true
		switch filepath.Ext(each) {
		case ".sv":
			dump = true
		case ".vhd":
			dump = !args.SkipVHDL
		case ".v":
			dump = true
		case ".qip":
			dump = false
		case ".sdc":
			dump = false
		default:
			{
				log.Fatalf("JTFILES: unsupported file extension %s in file %s", filepath.Ext(each), each)
			}
		}
		if dump {
			fmt.Fprintln(fout, each)
		}
	}
}

func parse_one(path string, dump2target, noclobber bool, skip []string, args Args) (uniq []string) {
	var files JTFiles
	if !dump2target {
		parse_yaml(get_filename(args), &files)
	}
	parse_yaml(path, &files)
	all := collect_files(files, args.Rel)
	// Remove files that could have appeared in the game section
	for _, s := range all {
		found := false
		for _, s2 := range skip {
			if s == s2 {
				found = true
				break
			}
		}
		if !found {
			uniq = append(uniq, s)
		}
	}
	switch args.Format {
	case "syn", "qip":
		dump_qip(uniq, args, dump2target)
	default:
		dump_sim(uniq, args, dump2target, noclobber)
	}
	return uniq
}

func Run(args Args) {
	CWD, _ = os.Getwd()

	game_files := parse_one(os.Getenv("JTFRAME")+"/hdl/jtframe.yaml", false, false, nil, args)

	if args.Target != "" {
		target_files := parse_one(os.Getenv("JTFRAME")+"/target/"+args.Target+"/target.yaml", true, false, game_files, args)
		if args.Format == "sim" {
			all_files := append(target_files, game_files...)
			parse_one(os.Getenv("JTFRAME")+"/target/"+args.Target+"/sim.yaml", true, true, all_files, args)
		}
	}
}
