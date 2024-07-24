@echo off
cls
echo        COBOL Advanced Program to Program (APPC) Demonstration
echo        ------------------------------------------------------
echo                        Battleships game
echo                        ----------------
if %1. == . goto noparam
if %1 == shared set appcmd=shared & goto okparam
if %1 == SHARED set appcmd=shared & goto okparam
if %1 == static set appcmd=static & goto okparam
if %1 == STATIC set appcmd=static & goto okparam
if %1 == animate set appcmd=animate & goto okparam
if %1 == ANIMATE set appcmd=animate & goto okparam
:noparam
echo     usage: 
echo           BATTLE ANIMATE   - create run files ready for ANIMATION
echo           BATTLE STATIC    - create run files by linking with STATIC          
echo                              run-time support (LCOBOL.LIB)
echo           BATTLE SHARED    - create run files by linking with SHARED
echo                              run-time support (COBLIB.LIB)
goto end

:okparam
echo ------------------------------------------------------------------------
echo Copying ADIS modules:
copy \cobol\lib\ADIS*.OBJ
copy \cobol\lib\ADIS.DEF
if not exist ADIS.OBJ goto noadis
if not exist ADISINIT.OBJ goto noadis
if not exist ADISKEY.OBJ goto noadis
if not exist ADISDYNA.OBJ goto noadis
if not exist ADIS.DEF goto noadis
echo ADIS+ADISINIT+ADISKEY+ADISDYNA >ADIS.LNK
if %appcmd% == shared goto shared

echo LIBRARY INITINSTANCE   >BATTAPPC.DEF
echo PROTMODE              >>BATTAPPC.DEF
echo DATA NONSHARED        >>BATTAPPC.DEF
echo EXPORTS BATTAPPC @1   >>BATTAPPC.DEF
echo IMPORTS APPC.APPC     >>BATTAPPC.DEF
echo IMPORTS ACSSVC.ACSSVC >>BATTAPPC.DEF
goto %appcmd%

:ANIMATE
echo Creating run files for Animation...
echo ------------------------------------------------------------------------
echo Compiling...
echo cobol battlel anim;
cobol battlel anim;
if not exist battlel.gnt goto compilerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo cobol battler anim;
cobol battler anim;
if not exist battler.gnt goto compilerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo cobol battappc anim opt(0);
cobol battappc anim omf(obj) opt(0);
if not exist battappc.obj goto compilerr
if exist battappc.int erase battappc.int
link battappc,,,coblib+os2,battappc.def;
echo Compiling finished.
echo ------------------------------------------------------------------------
echo Copy following files to remote machine:
echo   BATTLER.*
echo   BATTAPPC.*
echo To run on local machine enter:  ANIMATE BATTLEL
echo To run on remote machine enter: ANIMATE BATTLER
goto end

:STATIC
echo Creating run files with static run time system...
echo ------------------------------------------------------------------------
echo Compiling...
echo cobol battlel;
cobol battlel;
if not exist battlel.obj goto compilerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo cobol battler;
cobol battler;
if not exist battler.obj goto compilerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo cobol battappc;
cobol battappc;
if not exist battappc.obj goto compilerr
echo Compiling finished.
echo ------------------------------------------------------------------------

echo Linking...
: In this example, the sub program battappc.obj is linked on its
: own into a dll program.  You could, if you prefer link this object
: in directly with the main program to create one executable - this is
: what has been done for the example of linking with a shared run time below.
: Same point applies to the ADIS sub program modules.

echo link battlel /stack:3500,,,lcobol+os2;
link battlel /stack:3500,,,lcobol+os2;
if not exist battlel.exe goto linkerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo link battler /stack:3500,,,lcobol+os2;
link battler /stack:3500,,,lcobol+os2;
if not exist battler.exe goto linkerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo link battappc,,,lcobol+os2,battappc.def;
link battappc,,,lcobol+os2,battappc.def;
if not exist battappc.dll goto linkerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo link @adis.lnk,,,lcobol+os2,adis.def;
link @adis.lnk,,,lcobol+os2,adis.def;
if not exist adis.dll goto linkerr
echo Linking finished.
echo ------------------------------------------------------------------------

echo Copy following files to remote machine:
echo   BATTLER.EXE
echo   BATTAPPC.DLL
echo   ADIS.DLL
echo To run on local machine enter:  BATTLEL
echo To run on remote machine enter: BATTLER
echo Ensure directories containing .DLL files are on LIBPATH
goto end

:SHARED
echo Creating run files with shared run time system...
echo ------------------------------------------------------------------------
echo Compiling...
echo cobol battlel;
cobol battlel;
if not exist battlel.obj goto compilerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo cobol battler;
cobol battler;
if not exist battler.obj goto compilerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo cobol battappc;
cobol battappc;
if not exist battappc.obj goto compilerr
echo Compiling finished
echo ------------------------------------------------------------------------

echo Linking...
echo link battlel+battappc+@adis.lnk,,,coblib+os2+acs.lib;
link battlel+battappc+@adis.lnk,,,coblib+os2+c:\cmlib\acs.lib;
if not exist battlel.exe goto linkerr
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo link battler+battappc+@adis.lnk,,,coblib+os2+acs.lib;
link battler+battappc+@adis.lnk,,,coblib+os2+c:\cmlib\acs.lib;
if not exist battler.exe goto linkerr
echo Linking finished
echo ------------------------------------------------------------------------

echo Copy following file to remote machine:
echo   BATTLER.EXE

echo To run on local machine enter:  BATTLEL
echo To run on remote machine enter: BATTLER
goto end

:linkerr
echo Linking error.  Batch aborted.
goto end

:compilerr
echo Compliation error.  Batch aborted.
goto end

:noadis
echo ADIS Modules not found...  compilation aborted.
echo copy from your COBDIR directory:
echo       ADIS.OBJ, ADISKEY.OBJ, ADISINIT.OBJ, ADISDYNA.OBJ and ADIS.DEF

:end
if exist *.obj erase *.obj
if exist *.lnk erase *.lnk
if exist *.def erase *.def
if exist *.map erase *.map
set appcmd=

