rem Compile and replace a C++ module in all four libraries.
rem Use:	REPC modulename [sourcefilename]

if "" == "%2" goto module

ztc -c -cpp -o+space -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib pls -+%1;
if errorlevel 1 goto err

ztc -c -cpp -o+space -mm -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib plm -+%1;
if errorlevel 1 goto err

ztc -c -cpp -o+space -mc -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib plc -+%1;
if errorlevel 1 goto err

ztc -c -cpp -o+space -ml -o%1.obj %2 -DA%1
if errorlevel 1 goto err
lib pll -+%1;
if errorlevel 1 goto err
goto success

:module
ztc -c -cpp -o+space %1
if errorlevel 1 goto err
lib pls -+%1;
if errorlevel 1 goto err

ztc -c -cpp -o+space %1 -mm
if errorlevel 1 goto err
lib plm -+%1;
if errorlevel 1 goto err

ztc -c -cpp -o+space %1 -mc
if errorlevel 1 goto err
lib plc -+%1;
if errorlevel 1 goto err

ztc -c -cpp -o+space %1 -ml
if errorlevel 1 goto err
lib pll -+%1;
if errorlevel 1 goto err

:success
rem SUCCESS
:err

