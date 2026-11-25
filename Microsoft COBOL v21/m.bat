@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.INT 2>nul
del %1.LST 2>nul

ntvdm -r:. -h -c -d COBOL %1,%1,%1/D;

del %1.LST 2>nul

ntvdm -r:. -c -p RUNCOB %1
