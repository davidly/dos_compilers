#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c qcl /DDOSTIME "/I..\\include" /AS /Ox /Gs /c $str.C
ntvdm -u -r:. -c link "$str,,$str,..\\lib\\slibce+..\\lib\\em"

rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
