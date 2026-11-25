#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.COD
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -h cl /Ox /DDOSTIME /AS /Gs /Ze -I inc -I "inc\\sys" -L lib $str.C
ntvdm -u -r:. -e:lib=lib -h link $str,,$str,slibfp

rm -f $str.COD
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
