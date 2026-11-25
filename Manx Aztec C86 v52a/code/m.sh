#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.O
rm -f ctmp*

ntvdm -u -r:.. "-e:include=c:\\include,path=c:\\bin" "..\\bin\\cc" -DAZTEC86 +F +A $str.C
ntvdm -u -r:.. "-e:lib=c:\\lib" "..\\bin\\ln" $str "c:\\lib\\libs\\m.lib" "c:\\lib\\libs\\c.lib"

rm -f $str.O
rm -f ctmp*

ntvdm -u -r:. -c -p $str.EXE
