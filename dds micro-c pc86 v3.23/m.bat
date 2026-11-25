@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul

ntvdm -r:. -e:MCDIR=. cc %1 m=S -q

ntvdm -r:. -c -p %1.EXE
