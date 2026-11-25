#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. LC -ms $str.C
ntvdm -u -r:. LINK CS.OBJ $str.OBJ,$str,,LCS.LIB

rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
