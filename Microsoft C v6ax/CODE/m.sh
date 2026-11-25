#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -c -r:.. "-e:path=c:\\bin;c:\\binb,include=c:\\include,lib=c:\\lib" "..\\BIN\\CL.EXE" /nologo /B1 C1L /B2 C2L /Owx /Fe$str.EXE $str.C

rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
