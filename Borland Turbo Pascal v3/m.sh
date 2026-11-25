#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# patchtp3.py removes the startup CPU speed check Turbo Pascal 3.02a puts in every app;
# on an emulator it runs for a very long time and throws off the benchmark numbers.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.COM

ntvdm -u -r:. -c TURBOCL.COM $str
python3 patchtp3.py $str.COM

ntvdm -u -r:. -c -p $str.COM
