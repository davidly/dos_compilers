echo off
echo.
echo Example of a main program in C that calls procedures in Modula-2.
echo.
echo Before executing this command file, make sure that both Logitech
echo Modula-2 and Microsoft C 5.1 are properly installed.  This batch
echo file assumes that the name of Microsoft C small-model library is
echo "SLIBCER.LIB" and that it is accessible through the "SET LIB="
echo environment setting.
echo.
echo (Note: if you have purchased only the Compiler Pack, you must
echo change the "m2l" command in this file to the corresponding "link"
echo command for DOS.)
echo.
pause
set m2sav=%m2lib%
echo on
set m2lib=%m2lib%;%lib%
cl /c main.c
m2c mod.def mod
m2l main mod /case /p /lib cmrts slibcer
rem link main mod,,,..\..\m2lib\lib\cmrts ..\..\m2lib\lib\m2lib slibcer;
main
pause
echo off
set m2lib=%m2sav%
set m2sav=
