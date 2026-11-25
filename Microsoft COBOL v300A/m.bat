@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul
del %1.GRP 2>nul

ntvdm -r:. -h -c COBOL %1,%1,%1,%1
ntvdm -r:. -h -c LINK %1,,%1,lcobol.lib,nul.def

del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul
del %1.GRP 2>nul

ntvdm -r:. -c -p %1.EXE
