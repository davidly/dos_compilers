ECHO OFF
IF "%1" == "" GOTO UsageExit
IF "%2" == "" GOTO UsageExit
%1
IF EXIST %2\*.* GOTO DoSetup
md %2
:DoSetup
cd %2
copy a:setup1.bat
setup1 %1 %2 %3 %4

:UsageExit
CLS
ECHO Usage:   A:SETUP drive workDir [exeDir [libDir] ]
ECHO ÿ
ECHO          Where
ECHO                drive is the drive on which QuickBASIC is to be
ECHO                    installed                        (ex: C:)
ECHO                workDir is the pathname to where you want your
ECHO                    QuickBASIC source programs to go (ex: \QB4)
ECHO                exeDir  is the pathname to where you want the
ECHO                    executeable files to go          (ex: \BIN)
ECHO                libDir  is the pathname to where you want the
ECHO                    library files to go              (ex: \LIB)
ECHO ÿ
ECHO          Examples:  a:setup c: \qb4 \bin \lib
ECHO                     a:setup c: \qb4   (copies ALL files to c:\qb4)
ECHO ÿ
ECHO Note:    This setup batch file is intended only for assisting you 
ECHO          in installing QuickBASIC onto your hard disk.   Its use is
ECHO          optional; you can just copy all the files to the directory(s) 
ECHO          of your choice, if you wish.   If you do not have a hard disk, 
ECHO          see the section entitled 'Installing QuickBASIC: Floppy-Disk 
ECHO          Setup' in the 'Learning and Using QuickBASIC' manual.
