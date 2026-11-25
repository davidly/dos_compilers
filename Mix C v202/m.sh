#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.COM
rm -f $str.MIX

ntvdm -u -r:. cc $str.C
ntvdm -u -r:. linker $str

rm -f $str.MIX

ntvdm -u -r:. -c -p $str.COM
