@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem Some apps built by this compiler need to be loaded above 64k (ntvdm -h) or they
rem crash with a stack error. The benchmarks don't.

del %1.EXE 2>nul
del CON.LST 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. pas1 %1,%1,%1,%1;
ntvdm -r:. pas2
ntvdm -r:. link %1,%1,,pascal.lib

del CON.LST 2>nul
del %1.OBJ 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
