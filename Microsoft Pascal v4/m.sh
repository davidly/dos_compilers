#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c "binb\\pas1" $str,$str,$str,$str
ntvdm -u -r:. -c "binb\\pas2"
ntvdm -u -r:. -c "binb\\pas3"
ntvdm -u -r:. -e:lib=lib -c "binb\\link" $str djldos,$str,$str,,nul.def

rm -f $str.OBJ
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
