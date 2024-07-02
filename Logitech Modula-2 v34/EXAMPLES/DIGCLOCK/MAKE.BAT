echo off
echo.
echo Before executing this command file, make sure that Logitech Modula-2
echo has been properly installed.
echo.
echo This batch file will compile, link, and execute the ANSI screen
echo example.  NOTE: this program requires that you have the DOS ANSI.SYS
echo device driver installed in your CONFIG.SYS file (refer to your DOS
echo manual for more details).
echo.
echo (Note: if you have purchased only the Compiler Pack, you must
echo change the "m2l" command in this file to the corresponding "link"
echo command for DOS.)
echo.
pause
echo on
m2c ansiscre.def ansiscre digclock
m2l digclock/o/p
rem link digclock,,,..\..\m2lib\lib\m2rts ..\..\m2lib\lib\m2lib;
digclock
