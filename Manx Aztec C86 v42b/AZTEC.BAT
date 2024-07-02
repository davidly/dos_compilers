@echo off
if "%CLIB%" == "" goto START
goto END

   This is a modified version of the AZTEC Batch which should
   run on either a floppy or a hard drive...

:START
set CLIB=\AZTECC86\LIB\;
set INCLUDE=\AZTECC86\INCLUDE\;
set PATH=\AZTECC86\BIN;%PATH%;
:END
