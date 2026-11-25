#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# To use ntvdm, the libraries must be rebuilt for the 8086 (not 80186) with comp86em.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ

ntvdm -u -r:. -c OC $str.MOD 8086
ntvdm -u -r:. -c LINK $str+LIO+SYS ";"

rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
