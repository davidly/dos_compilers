#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. FOR1 "$str.FOR,,,;"
ntvdm -u -r:. FOR2
ntvdm -u -r:. FOR3
ntvdm -u -r:. LINK $str,,,partial.lib+dos20.lib

rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
