#!/bin/bash
# Copies the contents of JTBIN to a test folder
# in MiSTer

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

cd $JTBIN/mister
for i in *; do
    cp $i/releases/*.rbf $CORES
    cp $i/releases/*.mra $ROOT
done

cp -r $JTBIN/mra/_alternatives $ROOT

# Copy the files to MiSTer
sshpass -p $MISTERPASSWD ssh -l $MRUSER mister.home "rm -rf /media/fat/_JTBIN"
if sshpass -p $MISTERPASSWD scp -r $TEMP/* $MRUSER@${MRHOST}:/media/fat; then
    rm -rf $TEMP
else
    echo "Copy to MiSTer failes. Temporary files in " $TEMP
    exit 1
fi

