#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# FOR1 and FOR2 have bugs that require -h so they load at >= 64k and < 640k

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -h -r:. FOR1 "$str.FOR,,,;"
ntvdm -u -h -r:. FOR2
ntvdm -u -r:. LINK "$str,,,;"

rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
