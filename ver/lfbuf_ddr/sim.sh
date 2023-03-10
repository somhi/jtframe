#!/bin/bash

iverilog test.v ../hdl/video/jtframe_lfbuf*.v ../hdl/ram/jtframe_ram/*.v -stest -o sim && sim -lxt
rm -f sim
