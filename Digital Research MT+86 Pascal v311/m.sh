#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.ERR
rm -f $str.R86

ntvdm -u -r:. mt86 $str
ntvdm -u -r:. linkmt $str paslib.r86 fpreals.r86

rm -f $str.ERR
rm -f $str.R86

ntvdm -u -r:. -c -p $str.EXE
