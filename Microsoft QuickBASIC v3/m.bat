@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem QB.EXE's separate-compilation mode; /O makes a stand-alone .EXE.

del %1.EXE 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c QB.EXE "%1.BAS/O;"
ntvdm -r:. -c LINK.EXE "%1,,%1,,,;"

del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
