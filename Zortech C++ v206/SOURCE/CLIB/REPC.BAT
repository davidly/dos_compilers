rem _ repc.bat   Tue Jul 5 1989  Modified by : Walter Bright
rem Copyright (C) 1985-1989 by Walter Bright
rem All rights reserved
rem Compile and replace a C module in all four libraries.
rem Use:	REPC modulename [sourcefilename]

if "" == "%2" goto module

ztc -c -o+space -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib zls -+%1;
if errorlevel 1 goto err

ztc -c -o+space -mm -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib zlm -+%1;
if errorlevel 1 goto err

ztc -c -o+space -mc -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib zlc -+%1;
if errorlevel 1 goto err

ztc -c -o+space -ml -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib zll -+%1;
if errorlevel 1 goto err
goto success

:module
ztc -c -o+space %1
if errorlevel 1 goto err
lib zls -+%1;
if errorlevel 1 goto err

ztc -c -o+space %1 -mm
if errorlevel 1 goto err
lib zlm -+%1;
if errorlevel 1 goto err

ztc -c -o+space %1 -mc
if errorlevel 1 goto err
lib zlc -+%1;
if errorlevel 1 goto err

ztc -c -o+space %1 -ml
if errorlevel 1 goto err
lib zll -+%1;
if errorlevel 1 goto err

:success
rem SUCCESS
:err

