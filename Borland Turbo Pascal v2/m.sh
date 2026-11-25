#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.COM

ntvdm -u -r:. -c TURBOCL.COM $str

ntvdm -u -r:. -c -p $str.COM
