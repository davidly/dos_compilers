@echo off

ntvdm -r:.. tcc  -DDOSTIME -ms -Z -O -G -I..\include -L..\lib -e%1.exe %1.c

rem ntvdm -r:.. tcc -DDOSTIME -ms -Z -O -G -I..\include -L..\lib -c %1.c
rem ntvdm -r:.. tlink -L..\lib ..\lib\c0s.obj+%1.obj, %1.exe, /x, ..\lib\CS.LIB+..\lib\EMU.LIB+..\lib\maths.lib

