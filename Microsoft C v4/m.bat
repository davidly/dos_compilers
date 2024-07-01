@echo off

del %1.exe
del %1.obj

rem use "ntvdm -h cl /help" to get command-line arguments
rem ntvdm cl /Ox /DDOSTIME /AS /Gc /Gs /Ze -I inc -I inc\sys -L lib %1.c
ntvdm -r:. cl /Ox /DDOSTIME /AS /Gs /Ze -I inc -I inc\sys -L lib %1.c
if %ERRORLEVEL% NEQ 0 goto alldone

rem use "ntvdm link /help" to get command-line arguments
ntvdm -r:. -e:lib=lib -h -t link %1,,%1,slibfp
if %ERRORLEVEL% NEQ 0 goto alldone

ntvdm -p %1

:alldone

