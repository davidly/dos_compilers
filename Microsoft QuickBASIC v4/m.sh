#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# mi.sh / mi.bat run the benchmark in the QuickBASIC interpreter instead.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c bc $str.BAS $str.OBJ $str.LST /O
ntvdm -u -r:. -c link "$str,,$str,,,;"

rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
