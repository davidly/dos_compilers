rem ECHO OFF
REM ===========================================================
REM This batch file generates TVRDEMO.EXE, which is an overlaid
REM version TVDEMO that also uses resource files.
REM ===========================================================

REM Compile the program which generates the resource file...
ntvdm -c /e:path=..\..\bin ..\..\bin\TPC /m/l -e..\..\units genrdemo
if errorlevel 1 goto fail
copy c:\users\david\onedrive\ntvdm\tp_70\units\genrdemo.exe
ntvdm -c GENRDEMO
if errorlevel 1 goto fail

REM ===========================================================
REM To compile this demo with debug information, use the
REM following line:
REM TPC /m/v/l tvrdemo

REM Or use the following line to compile without debug info:
ntvdm -c /e:path=..\..\bin ..\..\bin\TPC /m/l -E..\..\units tvrdemo

if errorlevel 1 goto fail

REM ===========================================================
REM To generate a Turbo Debugger .TDS file, use the command
REM line above to generate debug info, and remove the REMs
REM from the following 2 lines:
REM tdstrip -s tvrdemo
REM touch tvrdemo.tds

if errorlevel 1 goto fail

REM ===========================================================
REM Use the DOS COPY command to append the overlay file and
REM the resource file to the end of the EXE file.  You must
REM specify the /B (binary) option for the COPY command.
copy c:\users\david\onedrive\ntvdm\tp_70\units\tvrdemo.exe
copy c:\users\david\onedrive\ntvdm\tp_70\units\tvrdemo.ovr
COPY /B TVRDEMO.EXE+TVRDEMO.OVR+TVRDEMO.TVR TVRDEMO.EXE
DEL TVRDEMO.TVR
DEL TVRDEMO.OVR
goto success

:fail
echo Error encountered building TVRDEMO.EXE

:success
