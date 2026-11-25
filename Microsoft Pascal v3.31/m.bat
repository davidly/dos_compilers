@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c pas1 %1,%1,%1,%1
ntvdm -r:. -c pas2
ntvdm -r:. -c pas3
ntvdm -r:. -c link %1 djldos,,,,

del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
