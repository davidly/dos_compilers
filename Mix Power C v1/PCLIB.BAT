echo off
pc pclib.prj
if errorlevel 1 goto stop
if exist pclib.mix del pclib.mix
merge pclib init printf scanf stdlib io errors lib
if errorlevel 1 goto stop
goto end
:stop
echo Errors building pclib
:end
