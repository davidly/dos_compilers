echo off
pc pclib2.prj
if errorlevel 1 goto stop
if exist pclib2.mix del pclib2.mix
merge pclib2 graphics screen stdlib2 lib2
if errorlevel 1 goto stop
goto end
:stop
echo Error creating pclib2
:end
