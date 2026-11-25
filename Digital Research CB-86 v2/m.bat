@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.SYM 2>nul

ntvdm -r:. cb86 %1
ntvdm -r:. link86 %1 = %1

del %1.OBJ 2>nul
del %1.SYM 2>nul

ntvdm -r:. -c -p %1.EXE
