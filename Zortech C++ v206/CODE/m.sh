#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:.. "-e:path=c:\\bin,lib=c:\\lib" "..\\bin\\ztc" $str.C "-Ic:\\include" -ms -c -DDOSTIME
ntvdm -u -r:.. "-e:path=c:\\bin,lib=c:\\lib" "..\\bin\\blink" ct+$str, $str, $str, ZLs.LIB /noi "/m;"

rm -f $str.MAP
rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
