#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# F83 reads the benchmark as keystrokes from redirected input and polls for them.
# -x makes that polling (and the timer) follow emulated time, so the cycle count
# doesn't depend on how fast the host is. Needs an ntvdm with -x.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

ntvdm -u -x -r:. -c -p F83.COM < $str.F
