@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.SYM 2>nul

ntvdm -r:. pli.exe %1 $L $I
ntvdm -r:. link86 %1,plilib.l86,pcdio.obj,div2.obj,fdiv2.obj

del %1.OBJ 2>nul
del %1.SYM 2>nul

ntvdm -r:. -c -p %1.EXE
