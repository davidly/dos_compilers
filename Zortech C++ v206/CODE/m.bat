@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:.. -e:path=c:\bin,lib=c:\lib ..\bin\ztc %1.C -Ic:\include -ms -c -DDOSTIME
ntvdm -r:.. -e:path=c:\bin,lib=c:\lib ..\bin\blink ct+%1, %1, %1, ZLs.LIB /noi /m;

del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
