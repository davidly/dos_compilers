REM - Compile the sample PLM program

plm86 sample.plm %1 %2
if errorlevel 1 goto stop

REM - Assemble the Small-Model PLM to DOS interface routines

asm86 doslibs.asm
if errorlevel 1 goto stop

REM - 1st (recommended) method of producing an EXE file

REM - Use LINK86 to produce a .86 file

link86 sample.obj, doslibs.obj, c:\intel\plm86.lib to sample1.86 bind
if errorlevel 1 goto stop

REM - USE UDI2DOS program to produce SAMPLE1.EXE file

UDI2DOS sample1
if errorlevel 1 goto stop

REM - SAMPLE1.EXE is now done

REM - 2nd (alternate) method of producing an EXE file
REM   This method produces EXE files that are about 10K smaller
REM   than the 1st method, but it will not work if any of the
REM   object files use floating point operations, and it has
REM   some problems with version 2.30 of LINK.

REM - Use LINK86 to pre-link the object files

link86 sample.obj, doslibs.obj, c:\intel\plm86.lib to sample2.lnk initcode
if errorlevel 1 goto stop

REM - Use LINK (supplied with DOS) to produce SAMPLE2.EXE file
REM   Note that Version 2.30 of LINK occasionally produces
REM   unexpected errors on this step.  If an error occurs,
REM   execute some other program before executing LINK.
REM   Versions 2.10 and 2.20 of LINK do not seem to have this
REM   problem.

link sample2.lnk;;;
if errorlevel 1 goto stop

REM - SAMPLE2.EXE is now done

REM - To execute SAMPLE1, place a disk in drive A, and enter SAMPLE1
REM - To execute SAMPLE2, place a disk in drive A, and enter SAMPLE2

:stop
