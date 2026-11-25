@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem FOR1 and FOR2 have bugs that require -h so they load at >= 64k and < 640k

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -h -r:. FOR1 %1.FOR,,,;
ntvdm -h -r:. FOR2
ntvdm -r:. LINK %1,,,;

del %1.OBJ 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
