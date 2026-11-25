#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE

ntvdm -u -r:. qpl $str.PAS

ntvdm -u -r:. -c -p $str.EXE
