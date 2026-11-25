#!/bin/bash
# build and run a benchmark, e.g. ./m.sh sieve
# DX-Forth waits on the timer tick. -x makes timer ticks follow emulated time at
# 4.77 MHz, so the cycle count doesn't depend on how fast the host is. Needs an ntvdm with -x.

str=$(tr '[a-z]' '[A-Z]' <<< "$1")

ntvdm -u -x -r:. -c -p FORTH - include $str.F $str bye
