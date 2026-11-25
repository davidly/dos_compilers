@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.COD 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. cl /Ox /DDOSTIME /AS /Gs /Ze /Zp -I inc -I inc\sys -L lib %1.C
ntvdm -r:. link %1,,%1,lib\slibfp+lib\slibc+lib\em

del %1.COD 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
