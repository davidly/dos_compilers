#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# Some apps built by this compiler need to be loaded above 64k (ntvdm -h) or they
# crash with a stack error. The benchmarks don't.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f CON.LST
rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. pas1 "$str,$str,$str,$str;"
ntvdm -u -r:. pas2
ntvdm -u -r:. link $str,$str,,pascal.lib

rm -f CON.LST
rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
