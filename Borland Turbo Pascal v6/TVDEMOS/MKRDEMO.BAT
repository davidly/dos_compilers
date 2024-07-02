ECHO OFF
REM ===========================================================
REM This batch file generates TVRDEMO.EXE, which is an overlaid
REM version TVDEMO that also uses resource files.
REM ===========================================================
TPC /m genrdemo
if errorlevel 1 goto fail
GENRDEMO
if errorlevel 1 goto fail
TPC /m tvrdemo
if errorlevel 1 goto fail
COPY /B TVRDEMO.EXE+TVRDEMO.OVR+TVRDEMO.REZ TVRDEMO.EXE
DEL TVRDEMO.REZ
DEL TVRDEMO.OVR
goto success
:fail
echo Error encountered building TVRDEMO.EXE
:success
