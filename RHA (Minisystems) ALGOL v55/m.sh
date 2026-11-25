#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.OBJ

ntvdm -u -r:. algol $str

ntvdm -u -r:. -c -p arun $str.OBJ
