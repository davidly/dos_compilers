@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem PowerBASIC apps write to video memory (-m shows it after the app ends) and wait on
rem the timer tick. -x makes timer ticks follow emulated time at 4.77 MHz, so the cycle
rem count doesn't depend on how fast the host is. Needs an ntvdm with -x.

del %1.EXE 2>nul

ntvdm -r:. -c PBCL.EXE %1

ntvdm -x -r:. -c -m -p %1.EXE
