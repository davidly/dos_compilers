@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. LC -ms %1.C
ntvdm -r:. LINK CS.OBJ %1.OBJ,%1,,LCS.LIB

del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
