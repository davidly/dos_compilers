#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# The Modula-2 linker (m2exe\m2l) fails, so QuickBASIC 7.1's link.exe is used instead.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -f -r:. "-e:m2sym=m2lib\\sym" "m2exe\\M2C.EXE" $str
ntvdm -u -h -f -r:. "-e:lib=m2lib\\lib" link $str,,,m2lib "m2rts.lib;"

rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
