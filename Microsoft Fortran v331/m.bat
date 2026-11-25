@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul

ntvdm -r:. for1 %1,%1,%1,%1
ntvdm -r:. pas2
ntvdm -r:. pas3
ntvdm -r:. -e:LIB=libs -f link %1,%1,%1,fortran.lib+cexec.lib

del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul

ntvdm -r:. -c -p %1.EXE
