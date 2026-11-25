#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.INT
rm -f $str.LST

ntvdm -u -r:. -h -c -d COBOL "$str,$str,$str/D;"

rm -f $str.LST

ntvdm -u -r:. -c -p RUNCOB $str
