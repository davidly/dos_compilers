#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. mc1 $str
ntvdm -u -r:. mc2 $str
ntvdm -u -r:. link $str + cs + gettm,, $str.map, mcs

rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
