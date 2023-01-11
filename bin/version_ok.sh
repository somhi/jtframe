#!/bin/bash

PRJCOMMIT=$(git rev-parse --short HEAD)

# if there is a version tag that matches the commit, use it instead
PRJTAG=`git tag --contains $PRJCOMMIT | grep "^v[0-9]\+\.[0-9]\+\.[0-9]\+$" | tail -n 1`
if [ ! -z "$PRJTAG" ]; then
    PRJCOMMIT=$PRJTAG;
    if [ "$1" = -v ]; then echo "Using version tag $PRJCOMMIT"; fi
    exit 0
else
    echo "Error: cannot use --git if there is no version tag for the commit"
    echo "Create the first version tag manually. Use jtmerge to create the tags after that."
    exit 1
fi
