#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE

ntvdm -u -r:. tpc $str "/\$S-" "/\$R-" /B

ntvdm -u -r:. -c -p $str.EXE
