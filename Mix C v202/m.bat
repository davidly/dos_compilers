@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.COM 2>nul
del %1.MIX 2>nul

ntvdm -r:. cc %1.C
ntvdm -r:. linker %1

del %1.MIX 2>nul

ntvdm -r:. -c -p %1.COM
