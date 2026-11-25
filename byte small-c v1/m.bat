@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.MAP 2>nul
del %1.MAC 2>nul
del %1.OBJ 2>nul

ntvdm -r:. cc86 %1.C
ntvdm -r:. masm %1.MAC;;
ntvdm -r:. link /STACK:4096 %1,,%1,clib.lib,nul.def

del %1.MAP 2>nul
del %1.MAC 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -d -c -p %1.EXE
