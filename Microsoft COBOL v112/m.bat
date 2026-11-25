@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem COBOL apps write to video memory; -m shows it after the app ends.

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -h -c -d COBOL %1,%1,%1/D;
ntvdm -r:. -h -c LINK %1,%1,%1,C:;

del %1.OBJ 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -m -p %1.EXE
