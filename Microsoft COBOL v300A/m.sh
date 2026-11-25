#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.GRP

ntvdm -u -r:. -h -c COBOL $str,$str,$str,$str
ntvdm -u -r:. -h -c LINK $str,,$str,lcobol.lib,nul.def

rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.GRP

ntvdm -u -r:. -c -p $str.EXE
