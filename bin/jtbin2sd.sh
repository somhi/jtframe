#!/bin/bash
# Copies the contents of JTBIN to the SD card

function show_help {
cat<<HELP
    JTFRAME (c) Jose Tejada 2023

Copies the contents of JTBIN or the release folder to
a SD card with the name of the target device.

Usage:

jtbin2sd.sh [-l|--local]

-l, --local     Uses JTROOT/release instead of JTBIN (default)
-g, --git       Uses JTBIN as the target folder
-v, --verbose

future options:
-s, --setname   Uses the given setname as the core.arc
HELP
}

LOCAL=1
V=
CNT=0

while [ $# -gt 0 ]; do
    case "$1" in
        -l|--local) LOCAL=1;;
        -g|--git)
            LOCAL=0;; # JTBIN will not be modified
        -v|--verbose)
            V=-v;;
        -h|--help)
            show_help
            exit 1;;
        *) echo "Unknown argument $1"; exit 1;;
    esac
    shift
done

if [ $LOCAL = 1 ]; then
    export JTBIN=$JTROOT/release
fi

cd $JTBIN/mra

TEMP=`mktemp --directory`
ROMDONE=

function make_roms {
    if [ -z "$ROMDONE" ]; then
        find -name "*.mra" -print0 | parallel -0 mra -z $HOME/.mame/roms -O $TEMP -A
        ROMDONE=TRUE
    fi
}

for i in SIDI MIST POCKET; do
    DST=/media/$USER/$i
    if [ ! -d $DST ]; then
        continue
    fi
    rm -rf $DST/* &
    make_roms
    wait
    if [ $i = POCKET ]; then
        cp -r $V $JTBIN/pocket/raw/* $DST
        # Copy Pocket assets
        for k in $ROM/cp_*sh; do
            $k $ROM
        done
    else
        cp $V $TEMP/* $DST
        cp $V $JTBIN/${i,,}/*rbf $DST
        # Get the main MRA as the core's arc for JTAG programming
        for CORE in $JTBIN/mister/*; do
            MR=$CORE/releases
            echo $MR
            if [ ! -d "$MR" ]; then continue; fi
            cd $MR
            CORENAME=JT$(basename $CORE)
            CORENAME=${CORENAME^^}
            echo $CORENAME
            FIRST=`find . -name "*.mra" | head -n 1`
            if [ -z "$FIRST" ]; then continue; fi
            mra -A -s -a $DST/$CORENAME.arc "$FIRST"
            cp $V --no-clobber $DST/$CORENAME.arc $DST/core.arc
        done
    fi
    CNT=$((CNT+1))
done

if [ $CNT = 0 ]; then
    echo "Nothing done"
fi

rm -rf $TEMP