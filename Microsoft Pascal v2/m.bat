@echo off
setlocal

del %1.exe 2>nul
del %1.lst 2>nul
del %1.map 2>nul
del %1.obj 2>nul
del %1.cod 2>nul

ntvdm -c pas1 %1,%1,%1,%1
ntvdm -c pas2
ntvdm -c link %1 djldos,,,,

del %1.lst
del %1.map
del %1.obj
del %1.cod

rem -h is required due to a bug in generated code that assumes the app is loaded on a 64k boundary

ntvdm -h -p %1

