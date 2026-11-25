#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# -h is required for pas2 and the generated apps so the top of RAM is on a 64k-1 boundary;
# they have bugs that copy 64k-1 bytes of RAM and wrap.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f CON.LST
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c pas1 $str,$str,$str,$str
ntvdm -u -r:. -h -c pas2
ntvdm -u -r:. -c link $str djldos,,,,

rm -f CON.LST
rm -f $str.COD
rm -f $str.LST
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -h -c -p $str.EXE
