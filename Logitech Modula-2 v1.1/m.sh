#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.LOD
rm -f $str.LNK
rm -f $str.REF
rm -f $str.MAP

ntvdm -u -r:. m2 comp $str.MOD /S- /R- /T-
ntvdm -u -r:. m2 link $str

rm -f $str.LNK
rm -f $str.REF
rm -f $str.MAP

ntvdm -u -r:. -c -p m2 $str.LOD
