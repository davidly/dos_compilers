#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# COBOL apps write to video memory; -m shows it after the app ends.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -h -c -d COBOL "$str,$str,$str/D;"
ntvdm -u -r:. -h -c LINK "$str,$str,$str,C:;"

rm -f $str.OBJ
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -m -p $str.EXE
