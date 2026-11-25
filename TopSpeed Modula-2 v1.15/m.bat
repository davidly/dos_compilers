@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem Sources are in MOD; M2.RED sends objects to OBJ and apps to EXE.

del EXE\%1.EXE 2>nul
del OBJ\%1.OBJ 2>nul

ntvdm -r:. m2 /c %1
ntvdm -r:. m2 /l %1

del OBJ\%1.OBJ 2>nul

ntvdm -r:. -c -p EXE\%1.EXE
