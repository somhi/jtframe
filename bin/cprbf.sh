#!/bin/bash

# Copy files from JTBIN to the local JTROOT/release folder
# Useful to prepare a release folder where new MRAs will be tested
# using an old RBF

for i in $*; do
    SRC=$JTBIN/mister/$i/releases/jt$i.rbf
    DST=$JTROOT/release/mister/$i/releases
    if [ ! -e $SRC ]; then
        echo "The core $i does not exist in JTBIN. Skipping it"
        echo "Cannot find $SRC"
        continue
    fi
    if [ ! -d $DST ]; then
        echo "Regenerating MRA files"
        jtframe mra $i
    fi
    cp -v $SRC $DST
done