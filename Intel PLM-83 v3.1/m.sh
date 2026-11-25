#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.MP1
rm -f $str.OBJ
rm -f DOSLIBS.LST
rm -f DOSLIBS.OBJ

ntvdm -u -r:. PLM86 $str.PLM "OPTIMIZE(3)"
ntvdm -u -r:. ASM86 DOSLIBS.ASM
ntvdm -u -r:. LINK86 $str.OBJ,DOSLIBS.OBJ,PLM86.LIB TO $str.EXE EXE

rm -f $str.LST
rm -f $str.MP1
rm -f $str.OBJ
rm -f DOSLIBS.LST
rm -f DOSLIBS.OBJ

ntvdm -u -r:. -c -p $str.EXE
