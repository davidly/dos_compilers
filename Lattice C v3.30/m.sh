#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -e:INCLUDE=. LC -ms -v -g $str.C
ntvdm -u -r:. LINK "S\\C.OBJ" "$str.OBJ,$str,,S\\LC.LIB+LAPI.LIB"

rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
