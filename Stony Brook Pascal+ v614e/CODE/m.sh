#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ

ntvdm -u -r:.. "..\\PPC" $str
ntvdm -u -r:.. -e:lib=.. "..\\SBLINK" $str

rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
