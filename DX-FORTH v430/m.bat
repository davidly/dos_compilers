@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem DX-Forth waits on the timer tick. -x makes timer ticks follow emulated time at
rem 4.77 MHz, so the cycle count doesn't depend on how fast the host is. Needs an ntvdm with -x.

ntvdm -x -r:. -c -p FORTH - include %1.F %1 bye
