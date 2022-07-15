#!/bin/bash

HEADER=0
CONV=conv=notrunc

BA1_START=$( printf "%d" $BA1_START )
BA2_START=$( printf "%d" $BA2_START )
BA3_START=$( printf "%d" $BA3_START )

BA1_LEN=$((BA2_START-BA1_START))
BA2_LEN=$((BA3_START-BA2_START))

while [ $# -gt 0 ]; do
    case "$1" in
        -header)
            shift
            HEADER=$( printf "%d" $1 );;
        -swab)
            CONV=${CONV},swab;;
        -help)
            cat<<EOF
rom2sdram [-header len]
    Reads rom.bin and creates sdram_bank[0,1,2,3] files for simulation
    if the BA1_START, BA2_START and BA3_START environment variables
    are defined, the sdram_bank[1,2,3].bin files will be created, otherwise
    only sdram_bank0 will be created
EOF
            exit 0
    esac
    shift
done

rm -f sdram_bank?.{hex,bin}
dd if=/dev/zero of=sdram_bank0.bin count=16384

if [ $BA1_START -gt 0 ]; then
    dd if=rom.bin of=sdram_bank0.bin $CONV iflag=count_bytes,skip_bytes count=$BA1_START skip=$HEADER
    dd if=/dev/zero of=sdram_bank1.bin count=16384
    dd if=rom.bin of=sdram_bank1.bin $CONV iflag=count_bytes,skip_bytes count=$BA1_LEN skip=$((HEADER+$BA1_START))
    if [ $BA2_START -gt 0 ]; then
        dd if=/dev/zero of=sdram_bank2.bin count=16384
        dd if=rom.bin of=sdram_bank2.bin $CONV iflag=count_bytes,skip_bytes count=$BA2_LEN skip=$((HEADER+$BA2_START))
    fi
    if [ $BA3_START -gt 0 ]; then
        dd if=/dev/zero of=sdram_bank3.bin count=16384
        dd if=rom.bin of=sdram_bank3.bin $CONV iflag=count_bytes,skip_bytes skip=$((HEADER+$BA3_START))
    fi
else
    dd if=rom.bin of=sdram_bank0.bin
fi