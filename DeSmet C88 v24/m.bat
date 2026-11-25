@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem -nDESMETC doesn't work in this version of c88

del %1.EXE 2>nul
del %1.O 2>nul

ntvdm -r:. c88 %1
ntvdm -r:. bind %1 other

del %1.O 2>nul

ntvdm -r:. -c -p %1.EXE
