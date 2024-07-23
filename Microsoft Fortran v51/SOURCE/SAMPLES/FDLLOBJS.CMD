@echo off
setlocal
if %1.==. goto Message
set DESTIN=%1
set DLLNAME=%2
if %2.==. set DLLNAME=frtlib
if not %3.==. set LIBF=%3
if not %3.==. goto Start
for %%A in (%LIB%) do if exist %%A\FRTLIB.OBJ set LIBF=%%A& goto Start
echo Can't find components in LIB directory
goto Exit
:Start
echo.
echo    Build dynamic link library.
echo.
echo LINK %LIBF%\FRTLIB.OBJ,%DESTIN%\%DLLNAME%.DLL,,%LIBF%\FDLLOBJS/NOE,FDLLOBJS.DEF;
LINK %LIBF%\FRTLIB.OBJ,%DESTIN%\%DLLNAME%.DLL,,%LIBF%\FDLLOBJS/NOE,FDLLOBJS.DEF;
echo.
echo    Build imports library.
echo.
for %%A in (%PATH%) do if exist %%A\IMPLIB.EXE goto Skip2
echo Can't find IMPLIB.EXE in PATH
goto Exit
:Skip2
echo IMPLIB %LIBF%\%DLLNAME%.LIB FDLLOBJS.DEF DIFFHLP.DEF
IMPLIB %LIBF%\%DLLNAME%.LIB FDLLOBJS.DEF DIFFHLP.DEF
goto Exit
:Message
echo   This batch file creates a dynamic link library and a corresponding
echo   imports library containing the FORTRAN run-time. The imports library 
echo   (which is invoked at link time) specifies the symbols and routines 
echo   that will be imported from the dynamic link library at run time.  
echo   Your PATH should point to the directory containing IMPLIB.EXE.  Your 
echo   LIB environment variable should have a pathname for OS2.LIB.
echo   The files FDLLOBJS.DEF, DIFFHLP.DEF and FDLLOBJS.LIB should be in the 
echo   same directory as FDLLOBJS.CMD.
echo.
echo    Syntax:
echo        FDLLOBJS destin [dllname] [libdir]
echo.
echo    Arguments:
echo        destin    Specify destination directory (should be in LIBPATH
echo                  in CONFIG.SYS). Use . for current directory.
echo        dllname   Default is FRTLIB (extension is .DLL for dynalink
echo                  library or .LIB for imports library)
echo        libdir    Default is LIB environment variable
echo.
echo    Examples:
echo        FDLLOBJS C:\BINP
echo                  Puts FRTLIB.DLL in C:\BINP and FRTLIB.LIB
echo                  in LIB directory.
echo        FDLLOBJS . DYNAF D:\LIBF
echo                  Puts DYNAF.DLL in current and DYNAF.LIB in D:\LIBF
:Exit
endlocal
