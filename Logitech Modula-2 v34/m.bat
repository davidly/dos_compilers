@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem The Modula-2 linker (m2exe\m2l) fails, so QuickBASIC 7.1's link.exe is used instead.

del %1.EXE 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -f -r:. -e:m2sym=m2lib\sym m2exe\M2C.EXE %1
ntvdm -h -f -r:. -e:lib=m2lib\lib link %1,,,m2lib m2rts.lib;

del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:. -c -p %1.EXE
