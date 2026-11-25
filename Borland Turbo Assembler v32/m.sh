#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c TASM $str.ASM -la
ntvdm -u -r:. -c TLINK $str.OBJ

rm -f $str.OBJ
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
