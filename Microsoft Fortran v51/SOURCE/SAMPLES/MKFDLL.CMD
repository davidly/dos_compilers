@echo off
setlocal
if %1.==. goto Message
set DESTIN=%1
set FDLL=%2
if %2.==. set FDLL=FRTLIB
if not %3.==. set LIBF=%3
if not %3.==. goto Start
for %%A in (%LIB%) do if exist %%A\FRTEXE.OBJ set LIBF=%%A& goto Start
echo Can't find components in LIB directory
goto Exit
:Start
for %%A in (%PATH%) do if exist %%A\FL.EXE goto Skip2
echo Can't find FL.EXE in PATH
goto Exit
:Skip2
echo.
echo    Build FMTMAIN.EXE
echo.
echo FL -MD FMTMAIN.FOR	%LIBF%\FRTEXE.OBJ %LIBF%\%FDLL%.LIB FMTMAIN.DEF

FL -MD FMTMAIN.FOR	%LIBF%\FRTEXE.OBJ %LIBF%\%FDLL%.LIB FMTMAIN.DEF

echo.
echo    Build FMTDLL.DLL
echo.
echo FL -MD -Fe%DESTIN%\FMTDLL.DLL FMTDLL.FOR %LIBF%\FRTDLL.OBJ %LIBF%\%FDLL%.LIB FMTDLL.DEF

FL -MD -Fe%DESTIN%\FMTDLL.DLL FMTDLL.FOR %LIBF%\FRTDLL.OBJ %LIBF%\%FDLL%.LIB FMTDLL.DEF

goto Exit
:Message
echo   This batch file demonstrates dynamic linking using Microsoft FORTRAN.
echo   It is assumed that you have built the example dynalink FORTRAN runtime 
echo   library (see FDLLOBJS.CMD). Your PATH should point to a directory 
echo   containing the Microsoft FORTRAN compiler and linker. Your LIB 
echo   environment variable should have a pathname for OS2.LIB.
echo.
echo   Syntax:    
echo              MKFDLL destin [frtdll] [libdir]
echo.
echo   Arguments:
echo     destin   Specify destination directory (should be in LIBPATH in
echo              CONFIG.SYS) for FMTDLL.DLL. Use . for current directory.
echo     frtdll   Specify the base name of the dynamically linked FORTRAN
echo              library built with FDLLOBJS.CMD. Default is FRTLIB.
echo     libdir   Specify directory containing special startup object files 
echo              and FORTRAN runtime imports library built with FDLLOBJS.CMD.
echo              Default is LIB environment variable
echo.
echo    Example:
echo              MKFDLL    C:\BINP MYLIB D:\LIBF
echo     Puts FMTDLL.DLL in C:\BINP. Uses a FORTRAN runtime imports library 
echo     named MYLIB.LIB found in D:\LIBF and a dynalink FORTRAN runtime named 
echo     MYLIB.DLL in C:\BINP. Finds support files in D:\LIBF.
:Exit
endlocal
