ada %1%2
if errorlevel 4 goto error
linklib %1
rem Compilation successful
goto end
:error
rem Errors were found
:end
