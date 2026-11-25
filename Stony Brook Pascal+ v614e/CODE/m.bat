@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul

ntvdm -r:.. ..\PPC %1
ntvdm -r:.. -e:lib=.. ..\SBLINK %1

del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
