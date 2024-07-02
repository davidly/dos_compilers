tpc /m /l /dSingleExe makeres
if errorlevel 1 goto error
makeres
tpc /m /l /dSingleExe tvfm
if errorlevel 1 goto error
copy /b tvfm.exe+tvfm.tvr temp.exe
copy temp.exe tvfm.exe
del temp.exe
goto done
:error
@echo Error encountered building TVFM
:done
