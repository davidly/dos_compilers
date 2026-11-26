@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -e:INCLUDE=. LC -ms -v -g %1.C
rem floating point (MM) also needs the math library
set libs=S\LC.LIB+LAPI.LIB
if /i "%1" == "mm" set libs=S\LCM.LIB+%libs%
ntvdm -r:. LINK S\C.OBJ %1.OBJ,%1,,%libs%

del %1.OBJ 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -p %1.EXE
