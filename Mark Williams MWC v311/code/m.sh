#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.O

ntvdm -u -r:.. "-e:CCHEAD=@C:\\lib\\cc -f -DMWC" "..\\bin\\cc" $str.C -lm

rm -f $str.O

ntvdm -u -r:. -c -p $str.EXE
