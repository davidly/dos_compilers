@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. mc1 %1
ntvdm -r:. mc2 %1
ntvdm -r:. link %1 + cs + gettm,, %1.map, mcs

del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
