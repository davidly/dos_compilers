#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# Sources are in MOD; M2.RED sends objects to OBJ and apps to EXE.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f EXE/$str.EXE
rm -f OBJ/$str.OBJ

ntvdm -u -r:. m2 /c $str
ntvdm -u -r:. m2 /l $str

rm -f OBJ/$str.OBJ

ntvdm -u -r:. -c -p "EXE\\$str.EXE"
