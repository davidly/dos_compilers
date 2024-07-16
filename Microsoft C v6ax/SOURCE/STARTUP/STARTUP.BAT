echo off
REM
REM Copyright (c) 1986-1990, Microsoft Corporation.  All rights reserved.
REM
REM batch file used to invoke make file to build startup
REM	Usage:	startup [os] (models)
REM		[os] is an optional parameter specifying the operating
REM			system:  use either "DOS" or "OS2", if neither is
REM			given, both are built
REM		(models) is a blank separated list of memory
REM		model designators as follows:
REM			S:	small model
REM			M:	medium model
REM			C:	compact model
REM			L:	large model
REM	Examples: 
REM		startup OS2 S M
REM			builds small and medium model objects for OS/2
REM			and links with null c program
REM
REM		startup S C M L
REM			builds objects for all memory models
REM			and links with null c program

if NOT "%1" == "" goto firstdir
echo	Usage: startup [os] (models)
echo	[os] is an optional operating system designator, either
echo		DOS or OS2
echo	(models) is a blank separated list of memory
echo	model designators as follows:
echo		S:	small model
echo		M:	medium model
echo		C:	compact model
echo		L:	large model
echo	Example:
echo		startup DOS S M
echo		builds small and medium model DOS objects and
echo		links with null c program
goto end

:firstdir
SET TARGET=all

if "%1" == "DOS" goto dos
if not "%1" == "dos" goto notdos
:dos
SET TARGET=DOS
shift
goto nextdir

:notdos
if "%1" == "OS2" goto os2
if not "%1" == "os2" goto notos2
:os2
SET TARGET=OS2
shift
goto nextdir

:notos2
:nextdir
if "%1" == "" goto finished

if "%1" == "S" goto argok
if "%1" == "M" goto argok
if "%1" == "C" goto argok
if "%1" == "L" goto argok
echo off
echo	Error: 	invalid argument to startup.bat
echo		The valid arguments to startup.bat are S, M, C, L, DOS and OS2.
echo		The model designators must be upper case.
goto end

:argok
echo You may see directory creation errors -- ignore these.
echo on
mkdir %1
mkdir %1\dos
mkdir %1\os2
cd %1
nmk CINC=%INCLUDE% MODEL=%1 %TARGET% /F ..\makefile
IF ERRORLEVEL 1 goto failure

echo off
rem check for Small model DOS objects, build crtcom.obj for them
if %TARGET%==OS2 goto nocrtcom
if NOT %1==S goto nocrtcom
echo on
nmk CINC=%INCLUDE% MODEL=%1 crtcom /F ..\makefile
if errorlevel 1 goto failure

:nocrtcom
echo off

cd ..

shift
goto nextdir

:failure
echo off
ECHO *** startup build/link failed ***

:finished
set TARGET=
echo **** Finished

:end
