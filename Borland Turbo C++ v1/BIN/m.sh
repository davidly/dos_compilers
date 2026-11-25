#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ

ntvdm -u -r:.. tcc -DDOSTIME -ms -Z -O -G "-I..\\include" "-L..\\lib" -e$str.EXE $str.C

rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
