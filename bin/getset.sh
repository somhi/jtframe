#!/bin/bash

# This file is part of JT_FRAME.
# JTFRAME program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# JTFRAME program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Jose Tejada Gomez. Twitter: @topapate
# Date: 3-1-2023

# Finds the right MRA file and extracts the rom file for it

if [ $# -ne 2 ]; then
    cat <<EOF
get.sh <core name> <MAME setname>

Extracts the .rom file and places it in the $ROM folder.

1. Regenerates the MRA files by running jtframe mra
2. Searches through them looking for the right one to parse
3. Runs the mra or orca tool to get the .rom file
EOF
    exit 1
fi

if [ -z "$JTROOT" ]; then
    echo "JTROOT is not defined. Call setprj.sh before getset.sh"
    exit 1
fi

CORENAME=$1
SETNAME=$2

function require {
    if [ ! -e "$1" ]; then
        echo "getset.sh: cannot find $1"
        exit 1
    fi

}

TOOL=mra

# Fallback tool: orca
# orca is a screen reader in Ubuntu. It can get confusing...
if ! which orca > /dev/null; then
    TOOL=orca
fi

require "$CORES/$CORENAME/cfg/mame2mra.toml"
require "$ROM/mame.xml"

cd $ROM
AUX=`mktemp`
if ! jtframe mra $CORENAME > $AUX; then
    cat $AUX
    rm $AUX
    exit 1
fi
rm $AUX

MATCHES=`mktemp`

find mra -name "*.mra" -print0 | xargs -0 grep --files-with-matches ">$SETNAME<" > $MATCHES
if [ `wc -l $MATCHES | cut -f 1 -d ' '` -gt 1 ]; then
    echo "getset.sh: More than one MRA file contained $SETNAME"
    cat $MATCHES
    rm $MATCHES
    exit 1
fi

$TOOL -z $HOME/.mame/roms "$(cat $MATCHES)" || echo $?
rm -f $MATCHES

