#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# /n removes array bounds checks and must be after the source file.
# The compiler adds each unit to its program library, ADA.ALB; the original is restored after the build.
# The first run is the interpreter on the .AXE file; the second is native code from a86.
# a86 produces bad code for the stock ttt.ada so the board is passed as an argument,
# and for the stock e.ada so more locals were added to reduce complexity.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.AXE
rm -f $str.EXE

cp -p ADA.ALB ADA.ALB.SAV
ntvdm -u -r:. ADA $str.ADA /n
ntvdm -u -r:. LINKLIB $str
ntvdm -u -r:. A86 $str.AXE /n
mv -f ADA.ALB.SAV ADA.ALB

ntvdm -u -r:. -c -p AI $str
ntvdm -u -r:. -c -p $str.EXE
