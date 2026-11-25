@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -f -e:include=include,lib=lib qcl /Gs /Ox /DDOSTIME %1.C

del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
