echo off
rem installation for Modula-2 3.40 Compiler Pack

if exist %1m2340cp1.exe goto :disk1ok

:disk1
echo.
echo Insert Logitech Modula-2 Compiler Pack Disk #1 in drive %1 and
pause
if not exist %1m2340cp1.exe goto :disk1
:disk1ok
%1m2340cp1 -d -o

:disk2
echo.
echo Insert Logitech Modula-2 Compiler Pack Disk #2 in drive %1 and
pause
if not exist %1m2340cp2.exe goto :disk2
%1m2340cp2 -d -o

:disk3
echo.
echo Insert Logitech Modula-2 Compiler Pack Disk #3 in drive %1 and
pause
if not exist %1m2340cp3.exe goto :disk3
%1m2340cp3 -d -o

echo.
