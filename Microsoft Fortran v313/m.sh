#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.COD

ntvdm -u -r:. FOR1 $str,$str,$str,$str
ntvdm -u -r:. PAS2
ntvdm -u -r:. PAS3
ntvdm -u -r:. -f LINK $str,$str,$str,FORTRAN.LEM

rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.COD

ntvdm -u -r:. -c -p $str.EXE
