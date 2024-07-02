echo off
if not %1x==x goto :ok
echo.
echo You must specify the source drive of the installation disk.
echo For example:
echo.
echo    %0 A:
echo.
echo       or
echo.
echo    %0 B:
echo.
goto :done
:ok
copy %1m2inst.bat . >nul
m2inst %1
:done
