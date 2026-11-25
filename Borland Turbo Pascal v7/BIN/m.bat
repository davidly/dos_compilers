@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.MAP 2>nul

ntvdm -r:.. TPC.EXE %1.PAS -$S- -GD

del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
