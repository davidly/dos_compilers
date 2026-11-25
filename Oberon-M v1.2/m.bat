@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem To use ntvdm, the libraries must be rebuilt for the 8086 (not 80186) with comp86em.

del %1.EXE 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c OC %1.MOD 8086
ntvdm -r:. -c LINK %1+LIO+SYS ;

del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
