#!/bin/bash
# Define JTROOT before sourcing this file

if (echo $PATH | grep modules/jtframe/bin -q); then
    unalias jtcore
    PATH=$(echo $PATH | sed 's/:[^:]*jtframe\/bin//g')
    PATH=$(echo $PATH | sed 's/:\.//g')
    unset JT12 JT51 CC MRA ROM CORES
fi

export JTROOT=$(pwd)
export JTFRAME=$JTROOT/modules/jtframe
# . path comes before JTFRAME/bin as setprj.sh
# can be in the working directory and in JTFRAME/bin
PATH=$PATH:.:$JTFRAME/bin

if [ -d "$JTBIN" ]; then
    export JTBIN=$JTROOT/release
    mkdir -p $JTBIN
fi

# derived variables
if [ -e $JTROOT/cores ]; then
    export CORES=$JTROOT/cores
    # Adds all core names to the auto-completion list of bash
    echo $CORES
    ALLFOLDERS=
    for i in $CORES/*; do
        j=$(basename $i)
        if [[ -d $i && $j != modules ]]; then
            ALLFOLDERS="$ALLFOLDERS $j "
        fi
    done
    complete -W "$ALLFOLDERS" jtcore
    complete -W "$ALLFOLDERS" swcore
    unset ALLFOLDERS
else
    export CORES=$JTROOT
fi

export ROM=$JTROOT/rom
export RLS=$JTROOT/release
export MRA=$JTROOT/release/mra
export MRA=$JTROOT/release/mra
DOC=$JTROOT/doc
MAME=$JTROOT/doc/mame
export MODULES=$JTROOT/modules

function swcore {
    IFS=/ read -ra string <<< $(pwd)
    j="/"
    next=0
    good=
    for i in ${string[@]};do
        if [ $next = 0 ]; then
            j=${j}${i}/
        else
            next=0
            j=${j}$1/
        fi
        if [ "$i" = cores ]; then
            next=1
            good=1
        fi
    done
    if [[ $good && -d $j ]]; then
        cd $j
    else
        cd $JTROOT/cores/$1
    fi
    pwd
}

if [ "$1" != "--quiet" ]; then
    echo "Use swcore <corename> to switch to a different core once you are"
    echo "inside the cores folder"
fi

# Git prompt
source $JTFRAME/bin/git-prompt.sh
export GIT_PS1_SHOWUPSTREAM=
export GIT_PS1_SHOWDIRTYSTATE=
export GIT_PS1_SHOWCOLORHINTS=
function __git_subdir {
    PWD=$(pwd)
    echo ${PWD##${JTROOT}/}
}
PS1='[$(__git_subdir)$(__git_ps1 " (%s)")]\$ '

function jtpull {
    cd $JTFRAME
    git pull
    cd -
}

# Displays all available macros
# The argument is used to filter the output
function jtmacros {
    case "$1" in
        --using|-u)
            for i in `find $CORES -name "*.def" | xargs grep --files-with-matches "$2"`; do
                i=`dirname $i`
                i=${i##$CORES/}
                i=${i%%/cfg}
                len0=${#i}
                i=${i%%/ver/game}
                len1=${#i}
                if [ $len0 = $len1 ]; then echo $i; fi
            done;;
        --help|-h)
            cat<<EOF
jtmacros shows macro related information.
Usage:
    --using|-u name     shows all cores using a given macro
    --help|-h           shows this screen
    name                shows the description of macro "name"
    no arguments        shows the description of all macros
EOF
        ;;
        *)
            if [ ! -z "$1" ]; then
                grep -i "$1" $JTFRAME/doc/macros.md
            else
                cat $JTFRAME/doc/macros.md
                echo
            fi;;
    esac
}

# check that git hooks are present
# Only the pre-commit is added automatically, the post-commit must
# be copied manually as it implies automatic pushing to the server
cp --no-clobber $JTFRAME/bin/pre-commit $JTROOT/.git/hooks/pre-commit
cp $JTFRAME/bin/post-merge $(git rev-parse --git-path hooks)/post-merge