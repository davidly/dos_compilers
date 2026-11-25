#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# Builds using the project file {B}.pr

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f TERMINAL.OBJ
rm -f ASCII.OBJ
rm -f INOUT.OBJ
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. "-e:PATH=c:\\SYS" "SYS\\TSC" /m $str.pr

rm -f TERMINAL.OBJ
rm -f ASCII.OBJ
rm -f INOUT.OBJ
rm -f $str.OBJ
rm -f $str.MAP

ntvdm -u -r:. -c -p $str.EXE
