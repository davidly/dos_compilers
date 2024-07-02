@echo off

del %1.exe 2>nul
del %1.obj 2>nul

rem use "ntvdm -h cl /help" to get command-line arguments
ntvdm -r:. -h cl /Ox /DDOSTIME /AS /Gs /Ze -I inc -I inc\sys -L lib %1.c
if %ERRORLEVEL% NEQ 0 goto alldone

rem use "ntvdm link /help" to get command-line arguments
ntvdm -r:. -h -t link %1,,%1,lib\slibce
if %ERRORLEVEL% NEQ 0 goto alldone

ntvdm -p %1

:alldone

