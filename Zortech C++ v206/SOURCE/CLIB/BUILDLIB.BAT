rem _ buildlib.bat   Sun Feb 21 1988   Modified by: Walter Bright */
rem Copyright (C) 1985-1989 by Walter Bright
rem All rights reserved
rem Build all 4 libraries and startup files.

del int.obj
del ct.obj

make clean
make MODEL=M
if errorlevel 1 goto exit

make clean
make MODEL=C
if errorlevel 1 goto exit

make clean
make MODEL=L
if errorlevel 1 goto exit

make clean
make MODEL=S
if errorlevel 1 goto exit
make clean

echo SUCCESS
:exit
rem 

