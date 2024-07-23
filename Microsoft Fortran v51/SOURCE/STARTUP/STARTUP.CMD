echo off
REM
REM Copyright (c) 1986-1991, Microsoft Corporation.  All rights reserved.
REM
REM batch file used to invoke make file to build startup
REM	Usage:	startup [os] (models)
REM		[os] is an optional parameter specifying the operating
REM			system:  use either "DOS" or "OS2", if neither is
REM			given, both are built
REM		(models) is a blank separated list of memory
REM		model designators as follows:
REM			M:	medium model
REM			L:	large model
REM	Example:
REM		startup OS2 M L
REM			builds medium and large model objects for OS/2
REM			and links with null fortran program

if NOT "%1" == "" goto firstdir
echo	Usage: startup [os] (models)
echo	[os] is an optional operating system designator, either
echo		DOS or OS2
echo	(models) is a blank separated list of memory
echo	model designators as follows:
echo		M:	medium model
echo		L:	large model
echo	Example:
echo		startup DOS M L
echo		builds medium and large model DOS objects and
echo		links with null fortran program
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

if "%1" == "M" goto argok
if "%1" == "L" goto argok
echo off
echo	Error: 	invalid argument to startup.bat
echo		The valid arguments to startup.cmd are M, L, DOS and OS2.
echo		The model designators must be upper case.
goto end

:argok
echo You may see directory creation errors -- ignore these.
echo on
mkdir %1
mkdir %1\dos
mkdir %1\os2
cd %1
nmake CINC=%INCLUDE% MODEL=%1 %TARGET% /F ..\makefile
IF ERRORLEVEL 1 goto failure

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
