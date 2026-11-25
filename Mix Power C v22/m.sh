#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE
rm -f $str.MIX

ntvdm -u -r:. pc -f /c /ms /dpowerc /dDOSTIME /j /fi /q $str.C >/dev/null 2>&1
ntvdm -u -r:. pcl $str

rm -f $str.MIX

ntvdm -u -r:. -c -p $str.EXE
