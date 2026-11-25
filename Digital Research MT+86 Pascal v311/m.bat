@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.ERR 2>nul
del %1.R86 2>nul

ntvdm -r:. mt86 %1
ntvdm -r:. linkmt %1 paslib.r86 fpreals.r86

del %1.ERR 2>nul
del %1.R86 2>nul

ntvdm -r:. -c -p %1.EXE
