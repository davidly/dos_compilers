del %1.rel 1>nul 2>nul
del %1.com 1>nul 2>nul

rem compile
ntvdm -r:. for1 %1,%1,%1,%1
if %ERRORLEVEL% NEQ 0 goto eof
ntvdm -r:. pas2
ntvdm -r:. pas3

rem link
ntvdm -r:. -e:LIB=libs -f link %1,%1,%1,fortran.lib+cexec.lib

:eof

