@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.LST 2>nul
del %1.MP1 2>nul
del %1.OBJ 2>nul
del DOSLIBS.LST 2>nul
del DOSLIBS.OBJ 2>nul

ntvdm -r:. PLM86 %1.PLM OPTIMIZE(3)
ntvdm -r:. ASM86 DOSLIBS.ASM
ntvdm -r:. LINK86 %1.OBJ,DOSLIBS.OBJ,PLM86.LIB TO %1.EXE EXE

del %1.LST 2>nul
del %1.MP1 2>nul
del %1.OBJ 2>nul
del DOSLIBS.LST 2>nul
del DOSLIBS.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
