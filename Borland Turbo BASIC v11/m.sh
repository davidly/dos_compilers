#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# Turbo BASIC apps write to video memory; -m shows it after the app ends.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE

ntvdm -u -r:. -c TBCL.EXE $str

ntvdm -u -r:. -c -m -p $str.EXE
