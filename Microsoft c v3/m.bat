@echo off

del %1.exe
del %1.obj

rem use "ntvdm cl /help" to get command-line arguments
ntvdm -t cl /Ox /DDOSTIME /AS /Gs /Ze /Zp -I inc -I inc\sys -L lib %1.c
if %ERRORLEVEL% NEQ 0 goto alldone

rem use "ntvdm link /help" to get command-line arguments
ntvdm -t link %1,,%1,lib\slibfp+lib\slibc+lib\em
if %ERRORLEVEL% NEQ 0 goto alldone

rem ntvdm -d -C -p %1

:alldone

