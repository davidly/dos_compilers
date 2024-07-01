echo off
REM
REM (C)Copyright Microsoft Corporation, 1986
REM
REM batch file used to invoke make file to build startup
REM	Usage:	startup (models)
REM		(models) is a blank separated list of memory
REM		model designators as follows:
REM			S:	small model
REM			M:	medium model
REM			C:	compact model
REM			L:	large model
REM	Examples: 
REM		startup S M 
REM			builds small and medium model objects 
REM			and links with null c program
REM
REM		startup S C M L
REM			builds objects for all memory models
REM			and links with null c program

if NOT "%1" == "" goto nextdir
echo	Usage: startup (models)
echo	(models) is a blank separated list of memory
echo	model designators as follows:
echo		S:	small model
echo		M:	medium model
echo		C:	compact model
echo		L:	large model
echo	Example:
echo		startup S M
echo		builds small and medium model objects and 
echo		links with null c program
goto end

:nextdir
if "%1" == "" goto finished

if "%1" == "S" goto argok
if "%1" == "M" goto argok
if "%1" == "C" goto argok
if "%1" == "L" goto argok
echo off
echo	Error: 	invalid argument to startup.bat
echo		The valid arguments to startup.bat are S M C and L.
echo		The model designators must be upper case.
goto end

:argok
echo on
cd %1
copy ..\*.h 
copy ..\*.inc
make MODEL=%1 ..\makefile 
del *.h
del msdos.inc
del brkctl.inc
del cmacros.inc
IF NOT ERRORLEVEL 0 goto failure

cd ..

shift
goto nextdir

:failure
ECHO *** startup link failed ***

:finished
echo **** Finished

:end
