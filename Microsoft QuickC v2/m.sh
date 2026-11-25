#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ

ntvdm -u -r:. -f -e:include=include,lib=lib qcl /Gs /Ox /DDOSTIME $str.C

rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
