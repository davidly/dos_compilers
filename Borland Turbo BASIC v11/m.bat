@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem Turbo BASIC apps write to video memory; -m shows it after the app ends.

del %1.EXE 2>nul

ntvdm -r:. -c TBCL.EXE %1

ntvdm -r:. -c -m -p %1.EXE
