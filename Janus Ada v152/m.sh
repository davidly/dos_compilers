#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.JRL
rm -f $str.PRN
rm -f $str.SYM

ntvdm -u -r:. janus $str /L /O1
ntvdm -u -r:. optimize $str
ntvdm -u -r:. jlink $str /O1

rm -f $str.JRL
rm -f $str.PRN
rm -f $str.SYM

ntvdm -u -r:. -c -p $str.EXE
