@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -e:include=include,init=bin,path=bin,lib=lib,tmp=tmp BIN\fl /FPc /Ox %1.FOR

del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
