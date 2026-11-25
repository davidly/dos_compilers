@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul

ntvdm -r:. FOR1 %1,%1,%1,%1
ntvdm -r:. PAS2
ntvdm -r:. PAS3
ntvdm -r:. -f LINK %1,%1,%1,FORTRAN.LEM

del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul

ntvdm -r:. -c -p %1.EXE
