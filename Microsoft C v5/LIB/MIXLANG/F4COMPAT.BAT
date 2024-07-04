echo off
if not "%1" == "" goto moreprocessing
if not "%2" == "" goto moreprocessing
:usage
echo ! usage:  F4COMPAT memory-model floating-point-model
echo !
echo !         where    memory-model is one of M or L
echo !         and      floating-point-model is one of 7, E, or A
echo !
echo !         (These two arguments are denoted x and y below.)
echo !
echo ! This batch file converts a Microsoft FORTRAN version
echo ! 4.00 or 4.01 run-time library xLIBFORy.LIB that has been
echo ! built with the C-compatibility setup option into one that is 
echo ! C 5.1/QC 1.01 compatible.  You don't need to run this batch file
echo ! for FORTRAN version 4.10, however.
echo !
echo ! Note that xDBGMSG.OBJ should be in the current directory.
echo !           xLIBFORy.LIB should be in the current directory.
echo !           LIB.EXE and ERROUT.EXE should be on the executable search PATH.
echo !           The old xLIBFORy.LIB will be saved in xLIBFORy.C40.
echo !
goto end
:moreprocessing
if "%1" == "L" goto okmemmodel
if "%1" == "l" goto okmemmodel
if "%1" == "M" goto okmemmodel
if "%1" == "m" goto okmemmodel
echo F4COMPAT : first argument (memory-model) should be M or L 
echo !
goto usage
:okmemmodel
if "%2" == "7" goto okfltmodel
if "%2" == "E" goto okfltmodel
if "%2" == "e" goto okfltmodel
if "%2" == "A" goto okfltmodel
if "%2" == "a" goto okfltmodel
echo F4COMPAT : second argument (floating-point-model) should be 7, E, or A
echo !
goto usage
:okfltmodel
if exist %1libfor%2.lib goto 111
echo F4COMPAT: cannot find %1libfor%2.lib in the current directory
goto end
:111
echo F4COMPAT : assuming that %1libfor%2.lib was built by means of 
echo            the FORTRAN setup program from MS FORTRAN 4.00 or 4.01
echo            and that the library was built with "C compatibility".
echo F4COMPAT : saving old copy as %1libfor%2.c40
copy %1libfor%2.lib %1libfor%2.c40
if exist %1dbgmsg.obj goto 222
echo F4COMPAT: cannot find %1dbgmsg.obj in the current directory
goto end
:222
if exist x.x del x.x
lib x.x;
if exist x.x goto 333
echo F4COMPAT : cannot find library manager (LIB.EXE) on executable search PATH
goto end
:333
del x.x
echo F4COMPAT : modifying %1libfor%2.lib for compatibility with C 5.1/QC 1.01
copy %1dbgmsg.obj dbgmsg.obj
errout errout > x.x
if exist x.x goto 444
echo F4COMPAT : cannot find ERROUT.EXE utility on executable search PATH
goto end
:444
del x.x
errout lib %1libfor%2.lib *onexit; > nul
:versioncheck
if not exist onexit.obj goto F401
del onexit.obj
:F400
lib %1libfor%2.lib -+dbgmsg-_chsize-_creat-onexit;
if errorlevel 1 goto error
goto cleanup
:F401
lib %1libfor%2.lib -+dbgmsg;
if errorlevel 1 goto error
goto cleanup
:error
echo F4COMPAT : %1libfor%2.lib: LIB manager encountered an error
goto end
:cleanup
echo F4COMPAT : The %1libfor%2.lib library should be used with
echo            the %1libc%2.lib   library from C 5.1/QC 1.01,
echo            and the C library should be mentioned before
echo            the FORTRAN library on the LINK line.
del dbgmsg.obj
del *.bak
:end
