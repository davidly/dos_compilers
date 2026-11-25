@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -c -r:.. -e:path=c:\bin;c:\binb,include=c:\include,lib=c:\lib ..\BIN\CL.EXE /nologo /B1 C1L /B2 C2L /Owx /Fe%1.EXE %1.C

del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
