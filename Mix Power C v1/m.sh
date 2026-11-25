#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# pc.exe crashes after it's done because it trashes its own stack; its output is discarded.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MIX

ntvdm -u -r:. pc /c /ms /dpowerc /j /fi /q $str.C >/dev/null 2>&1
ntvdm -u -r:. pcl $str

rm -f $str.MIX

ntvdm -u -r:. -c -p $str.EXE
