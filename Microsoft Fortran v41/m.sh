#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.OBJ

ntvdm -u -r:. -e:include=include,init=bin,path=bin,lib=lib,tmp=tmp "BIN\\fl" /FPc /Ox $str.FOR

rm -f $str.OBJ

ntvdm -u -r:. -c -p $str.EXE
