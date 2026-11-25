#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.SYM

ntvdm -u -r:. drc $str
ntvdm -u -r:. link86 $str

rm -f $str.OBJ
rm -f $str.SYM

ntvdm -u -r:. -c -p $str.EXE
