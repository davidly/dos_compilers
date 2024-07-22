@echo off
setlocal

del %1.exe 1>nul 2>nul
del %1.lst 1>nul 2>nul
del %1.map 1>nul 2>nul
del %1.obj 1>nul 2>nul
del %1.cod 1>nul 2>nul

rem compile
ntvdm -r:. for1 %1,%1,%1,%1
if %ERRORLEVEL% NEQ 0 goto eof
ntvdm -r:. pas2
ntvdm -r:. pas3

rem link
ntvdm -r:. -f link %1,%1,%1,fortran.lem

del %1.lst 1>nul 2>nul
del %1.map 1>nul 2>nul
del %1.obj 1>nul 2>nul
del %1.cod 1>nul 2>nul

:eof

