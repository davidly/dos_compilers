ECHO OFF
CLS
ECHO ÿ
ECHO Note that you need almost 1 MegaByte free on your hard disk; if you have
ECHO less than a MegaByte, abort and copy just those files you really need.
ECHO ÿ
ECHO Type Ctrl-Break to abort if you don't have a hard disk or would rather
ECHO just do it yourself - - - 
ECHO ÿ
PAUSE
IF "%3" == "" GOTO ExeNoDir
IF EXIST %3\*.* GOTO GotExeDir
md %3
:GotExeDir
ECHO Now copying BC.EXE, BRUN40.EXE, QB.EXE, LIB.EXE and LINK.EXE to %1%3
copy a:*.exe %3
GOTO CopyLib
:ExeNoDir
ECHO Now copying BC.EXE, BRUN40.EXE, QB.EXE, LIB.EXE and LINK.EXE to %1%2
copy a:*.exe %2
:CopyLib
ECHO Now copying QB.HLP to %1%2
copy a:qb.hlp %2
IF "%4" == "" GOTO LibNoDir
IF EXIST %4\*.* GOTO GotLibDir
md %4
:GotLibDir
ECHO Now copying BRUN40.LIB to %1%4
copy a:brun40.lib %4
GOTO CopyOther
:LibNoDir
ECHO Now copying BRUN40.LIB to %1%2
copy a:brun40.lib %2
:CopyOther
ECHO ÿ
ECHO Put Disk 2 in drive A:
PAUSE
ECHO ÿ
IF "%4" == "" GOTO Lib2NoDir
IF EXIST %4\*.* GOTO Got2LibDir
md %4
:Got2LibDir
ECHO Now copying BCOM40.LIB and BQLB40.LIB to %1%4
copy a:b*.lib %4
GOTO CopyRest
:Lib2NoDir
ECHO Now copying BCOM40.LIB and BQLB40.LIB to %1%2
copy a:b*.lib %2
:CopyRest
ECHO ÿ
IF "%3" == "" GOTO Exe2NoDir
ECHO Now copying MOUSE.COM to %1%3
copy a:mouse.com %3
GOTO FinishUp
:Exe2NoDir
ECHO Now copying MOUSE.COM to %1%2
copy a:mouse.com %2
:FinishUp
ECHO ÿ
ECHO Now copying BAS files to %1%2
copy a:*.bas %2
copy a:\source\*.* %2
ECHO ÿ
ECHO Now copying other supporting files to %1%2
copy a:qb.* %2
copy a:*.obj %2
ECHO ÿ
ECHO Installation complete.
ECHO ÿ
ECHO Installation does NOT include modifying DOS environment variables.
IF "%3" == "" GOTO Exe3NoDir
ECHO Since you specified %1%3 for EXE and COM files, you should ensure
ECHO you have an appropriate PATH= parameter in your autoexec.bat.
:Exe3NoDir
IF "%4" == "" GOTO Lib3NoDir
ECHO Since you specified %1%4 for LIB files, you should ensure you have an
ECHO appropriate LIB= parameter in your autoexec.bat.
:Lib3NoDir
ECHO For complete information on setting DOS environment variables for use
ECHO with QuickBASIC, see the section entitled 'Setting DOS Environment
ECHO Variables' in the 'Learning and Using QuickBASIC' manual.
ECHO ÿ
ECHO Note that installation does not copy README.DOC or PACKING.LST from disk 1
ECHO nor QBHERC.COM, FIXSHIFT.COM, ABSOLUTE.ASM or INTRPT.ASM from disk 2.
