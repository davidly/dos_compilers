@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem Builds using the project file {B}.pr

del %1.EXE 2>nul
del TERMINAL.OBJ 2>nul
del ASCII.OBJ 2>nul
del INOUT.OBJ 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -e:PATH=c:\SYS SYS\TSC /m %1.pr

del TERMINAL.OBJ 2>nul
del ASCII.OBJ 2>nul
del INOUT.OBJ 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
