#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# COBOL apps write to video memory; -m shows it after the app ends.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.LST
rm -f $str.GRP
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:.. -c "-e:path=c:\\binb;c:\\binr" COBOL $str,$str,$str,$str
ntvdm -u -r:.. -h -c "-e:lib=c:\\lib" LINK $str,,$str,,nul.def

rm -f $str.LST
rm -f $str.GRP
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:.. -c -m -p "-e:path=c:\\binb;c:\\binr" $str.EXE
