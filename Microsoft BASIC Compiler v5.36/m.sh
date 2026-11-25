#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.LST

ntvdm -u -r:. -c bascom $str.BAS,,$str.LST,
ntvdm -u -r:. -c link "$str,,$str,.\\,nul"

rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.LST

ntvdm -u -r:. -c -p $str.EXE
