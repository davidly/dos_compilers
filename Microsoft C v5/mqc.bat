@echo off

del %1.exe
del %1.obj

ntvdm -r:. -h qcl /DDOSTIME /AS /Ot /Gs /c -I inc -I inc\sys %1.c
if %ERRORLEVEL% NEQ 0 goto alldone

ntvdm -r:. -h link %1,,%1,lib\slibce,lib\quicklib.obj
if %ERRORLEVEL% NEQ 0 goto alldone

ntvdm -p %1

:alldone

