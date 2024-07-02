echo off
echo.
echo Before executing this command file, make sure that Logitech Modula-2
echo has been properly installed.
echo.
echo This batch file will compile, link, and execute the file I/O example.
echo.
echo (Note: if you have purchased only the Compiler Pack, you must
echo change the "m2l" command in this file to the corresponding "link"
echo command for DOS.)
echo.
pause
echo on
m2c fileio
m2l fileio/o/p
rem link fileio,,,..\..\m2lib\lib\m2rts ..\..\m2lib\lib\m2lib;
fileio
