echo off
pc mixc1,dystring
if errorlevel 1 goto stop
if exist mixc.mix del mixc.mix
merge mixc mixc1 dystring
if errorlevel 1 goto stop
goto end
:stop
echo Errors building mixc
:end
