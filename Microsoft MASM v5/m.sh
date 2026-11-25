#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.CRF
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.LST

ntvdm -u -r:. -h "bin\\masm" /Zi /Zd /z /L "$str,,,;"
ntvdm -u -r:. -h "bin\\link" /CP:1 $str,,$str,,nul.def

rm -f $str.CRF
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.LST

ntvdm -u -r:. -c -p $str.EXE
