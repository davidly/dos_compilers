@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -e:INCLUDE=. LC -ms -v -g %1.C
ntvdm -r:. LINK S\C.OBJ %1.OBJ,%1,,S\LC.LIB+LAPI.LIB

del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
