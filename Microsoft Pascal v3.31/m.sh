#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c pas1 $str,$str,$str,$str
ntvdm -u -r:. -c pas2
ntvdm -u -r:. -c pas3
ntvdm -u -r:. -c link $str djldos,,,,

rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
