rem _ buildlib.bat   Mon Feb  8 1988   Modified by: Walter Bright */
rem Copyright (C) 1988-1989 by Walter Bright
rem All rights reserved
rem Build all 4 C++ libraries.

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

echo SUCCESS
:exit
echo 
