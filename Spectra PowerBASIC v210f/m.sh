#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# PowerBASIC apps write to video memory (-m shows it after the app ends) and wait on
# the timer tick. -x makes timer ticks follow emulated time at 4.77 MHz, so the cycle
# count doesn't depend on how fast the host is. Needs an ntvdm with -x.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

rm -f $str.EXE

ntvdm -u -r:. -c PBCL.EXE $str

ntvdm -u -x -r:. -c -m -p $str.EXE
