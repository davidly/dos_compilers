rem _ romasm.bat   Thu Sep  8 1988   Modified by: Walter Bright */
rem Copyright (C) 1985-1989 by Walter Bright
rem All rights reserved
rem Replace an assembly language module in all four rom libraries.
rem Use:	ROMASM modulename [sourcefilename]

if "" == "%2" goto module
masm -Z -MX -DI8086S -R -DA%1 %2,%1;
if errorlevel 1 goto err
lib roms -+%1;
if errorlevel 1 goto err
masm -Z -MX -DI8086M -R -DA%1 %2,%1;
if errorlevel 1 goto err
lib romm -+%1;
if errorlevel 1 goto err
masm -Z -MX -DI8086C -R -DA%1 %2,%1;
if errorlevel 1 goto err
lib romc -+%1;
if errorlevel 1 goto err
masm -Z -MX -DI8086L -R -DA%1 %2,%1;
if errorlevel 1 goto err
lib roml -+%1;
if errorlevel 1 goto err
goto success

:module
masm -Z -MX -DI8086S -R %1;
if errorlevel 1 goto err
lib roms -+%1;
if errorlevel 1 goto err
masm -Z -MX -DI8086M -R %1;
if errorlevel 1 goto err
lib romm -+%1;
if errorlevel 1 goto err
masm -Z -MX -DI8086C -R %1;
if errorlevel 1 goto err
lib romc -+%1;
if errorlevel 1 goto err
masm -Z -MX -DI8086L -R %1;
if errorlevel 1 goto err
lib roml -+%1;
if errorlevel 1 goto err

:success
rem SUCCESS

:err

