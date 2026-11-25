@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem COBOL apps write to video memory; -m shows it after the app ends.

del %1.EXE 2>nul
del %1.LST 2>nul
del %1.GRP 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:.. -c -e:path=c:\binb;c:\binr COBOL %1,%1,%1,%1
ntvdm -r:.. -h -c -e:lib=c:\lib LINK %1,,%1,,nul.def

del %1.LST 2>nul
del %1.GRP 2>nul
del %1.MAP 2>nul
del %1.OBJ 2>nul

ntvdm -r:.. -c -m -p -e:path=c:\binb;c:\binr %1.EXE
