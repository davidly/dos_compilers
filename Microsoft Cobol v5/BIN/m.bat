@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem link.exe that ships with COBOL requires a 286+ in protected mode, so Microsoft C v5's
rem linker (mcv5link) is used. QuickBASIC 7.1's link.exe executes code in a segment it just freed.
rem COBOL apps write to video memory; -m shows it after the app ends.

del %1.EXE 2>nul
del %1.OBJ 2>nul
del %1.GRP 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:.. -c -d cobol %1,%1,%1,%1
ntvdm -r:.. -h -c -e:lib=c:\lib mcv5link %1,,%1,,nul.def

del %1.OBJ 2>nul
del %1.GRP 2>nul
del %1.LST 2>nul
del %1.MAP 2>nul

ntvdm -r:. -c -m -p %1.EXE
