#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MAP
rm -f $str.MAC
rm -f $str.OBJ

ntvdm -u -r:. cc86 $str.C
ntvdm -u -r:. masm "$str.MAC;;"
ntvdm -u -r:. link /STACK:4096 $str,,$str,clib.lib,nul.def

rm -f $str.MAP
rm -f $str.MAC
rm -f $str.OBJ

ntvdm -u -r:. -d -c -p $str.EXE
