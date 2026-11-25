#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# QB.EXE's separate-compilation mode; /O makes a stand-alone .EXE.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c QB.EXE "$str.BAS/O;"
ntvdm -u -r:. -c LINK.EXE "$str,,$str,,,;"

rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
