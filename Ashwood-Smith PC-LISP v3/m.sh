#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

ntvdm -u -r:. -c -p PC-LISP.EXE $str.LSP
