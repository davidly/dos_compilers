@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul

ntvdm -r:. -e:path=. cc %1 H=C:\ -O -S

ntvdm -r:. -c -p %1.EXE
