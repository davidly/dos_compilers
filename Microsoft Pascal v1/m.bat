@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem -h is required for pas2 and the generated apps so the top of RAM is on a 64k-1 boundary;
rem they have bugs that copy 64k-1 bytes of RAM and wrap.

del %1.EXE 2>nul
del CON.LST 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c pas1 %1,%1,%1,%1
ntvdm -r:. -h -c pas2
ntvdm -r:. -c link %1 djldos,,,,

del CON.LST 2>nul
del %1.COD 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -h -c -p %1.EXE
