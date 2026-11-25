#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.COD

ntvdm -u -r:. for1 $str,$str,$str,$str
ntvdm -u -r:. pas2
ntvdm -u -r:. pas3
ntvdm -u -r:. -e:LIB=libs -f link $str,$str,$str,fortran.lib+cexec.lib

rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ
rm -f $str.COD

ntvdm -u -r:. -c -p $str.EXE
