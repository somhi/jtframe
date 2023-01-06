#!/bin/bash
# Copies the contents of JTBIN to a test folder
# in MiSTer

function show_help {
cat<<HELP
    JTFRAME (c) Jose Tejada 2023

Copies the contents of JTBIN or the release folder to
a MiSTer device in the network.

Usage:

jtbin2mr.sh [-l|--local]

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

if [ -z "$MISTERPASSWD" ]; then
    echo "Define the MiSTer password in the environment variable MISTERPASSWD"
    exit 1
fi

if [ -z "$MRHOST" ]; then
    MRHOST=mister.home
fi

if [ -z "$MRUSER" ]; then
    MRUSER=root
fi

TEMP=`mktemp --directory`

ROOT=$TEMP/_JTBIN
CORES=$ROOT/cores

mkdir -p $CORES

if [ -d $JTBIN/mister ]; then
    cd $JTBIN/mister
    for i in *; do
        cp $i/releases/*.rbf $CORES
        cp $i/releases/*.mra $ROOT
    done
fi

cp -r $JTBIN/mra/_alternatives $ROOT

# Copy the files to MiSTer
sshpass -p $MISTERPASSWD ssh -l $MRUSER mister.home "rm -rf /media/fat/_JTBIN"
if sshpass -p $MISTERPASSWD scp -r $TEMP/* $MRUSER@${MRHOST}:/media/fat; then
    rm -rf $TEMP
else
    echo "Copy to MiSTer failes. Temporary files in " $TEMP
    exit 1
fi

