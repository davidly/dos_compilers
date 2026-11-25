@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. BASCOM %1.BAS,,%1.LST,
ntvdm -r:. LINK %1,,,;

del %1.OBJ 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
