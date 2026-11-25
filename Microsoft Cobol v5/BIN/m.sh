#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# link.exe that ships with COBOL requires a 286+ in protected mode, so Microsoft C v5's
# linker (mcv5link) is used. QuickBASIC 7.1's link.exe executes code in a segment it just freed.
# COBOL apps write to video memory; -m shows it after the app ends.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.GRP
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:.. -c -d cobol $str,$str,$str,$str
ntvdm -u -r:.. -h -c "-e:lib=c:\\lib" mcv5link $str,,$str,,nul.def

rm -f $str.OBJ
rm -f $str.GRP
rm -f $str.LST
rm -f $str.MAP

ntvdm -u -r:. -c -m -p $str.EXE
