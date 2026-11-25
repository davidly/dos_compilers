@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem The compiler and libs\* C runtime are from https://winworldpc.com/product/intel-ic-86-compiler/45
rem The linker and u\* objects are from https://winworldpc.com/product/intel-iapx-86-88-family-utilities/42
rem The directory is u, not util, to keep the link86 command tail < 127 characters.
rem This links with the 8087 emulator; to require an 8087 use u\8087.lib instead of u\e8087.lib,u\de8087.

del %1.EXE 2>nul
del %1.LST 2>nul
del %1.MP1 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -e::include:=inc ic86 %1.C small optimize(3) mod86 diagnostic( 2 ) define (INTELC)
ntvdm -r:. link86 libs\cstdoss.obj,%1.obj,c:\libs\cdoss.lib,u\cel87.lib,u\e8087.lib,u\de8087,libs\clib87.lib TO %1.EXE exe

del %1.LST 2>nul
del %1.MP1 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
