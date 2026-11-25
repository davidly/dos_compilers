@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c qcl /DDOSTIME /I..\include /AS /Ox /Gs /c %1.C
ntvdm -r:. -c link %1,,%1,..\lib\slibce+..\lib\em

del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
