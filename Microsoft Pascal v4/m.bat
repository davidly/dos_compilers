@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c binb\pas1 %1,%1,%1,%1
ntvdm -r:. -c binb\pas2
ntvdm -r:. -c binb\pas3
ntvdm -r:. -e:lib=lib -c binb\link %1 djldos,%1,%1,,nul.def

del %1.OBJ 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
