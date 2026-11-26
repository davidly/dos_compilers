#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -e:INCLUDE=. LC -ms -v -g $str.C
# floating point (MM) also needs the math library
libs="S\\LC.LIB+LAPI.LIB"
[ "$str" = "MM" ] && libs="S\\LCM.LIB+$libs"
ntvdm -u -r:. LINK "S\\C.OBJ" "$str.OBJ,$str,,$libs"

rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
