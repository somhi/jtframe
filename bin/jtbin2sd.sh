#!/bin/bash
# Copies the contents of JTBIN to the SD card

cd $JTBIN/mra

TEMP=`mktemp --directory`
ROMDONE=
for i in SIDI MIST; do
    DST=/media/$USER/$i
    if [ ! -d $DST ]; then
        continue
    fi
    rm -rf $DST/* &
    if [ -z "$ROMDONE" ]; then
        find -name "*.mra" -print0 | parallel -0 mra -z $HOME/.mame/roms -O $TEMP -A
        ROMDONE=TRUE
    fi
    wait
    cp $TEMP/* $DST
    cp $JTBIN/${i,,}/*rbf $DST
done

rm -rf $TEMP