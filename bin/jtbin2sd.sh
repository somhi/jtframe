#!/bin/bash
# Copies the contents of JTBIN to the SD card

function show_help {
cat<<HELP
    JTFRAME (c) Jose Tejada 2023

Copies the contents of JTBIN or the release folder to
a SD card with the name of the target device.

Usage:

jtbin2sd.sh [-l|--local]

-l, --local     Uses JTROOT/release instead of JTBIN
HELP
}

while [ $# -gt 0 ]; do
    case "$1" in
        -l|--local)
            export JTBIN=$JTROOT/release;;
        -h|--help)
            show_help
            exit 1;;
    esac
    shift
done

cd $JTBIN/mra

TEMP=`mktemp --directory`
ROMDONE=

function make_roms{
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
        cp -r $JTBIN/pocket/raw/* $DST
        # Copy Pocket assets
        for k in $ROM/cp_*sh; do
            $k
        done
    else
        cp $TEMP/* $DST
        cp $JTBIN/${i,,}/*rbf $DST
    fi
done


rm -rf $TEMP