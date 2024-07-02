ztc -ms SLTEST cppts.lib
SLTEST
ztc -ms DLTEST cppts.lib
DLTEST
ztc -ms QSTEST cppts.lib
QSTEST
ztc -ms BVTEST cppts.lib
BVTEST
ztc -ms DYNTEST cppts.lib
DYNTEST
ztc -ms BINTEST cppts.lib
BINTEST test.txt
ztc -ms HSHTEST cppts.lib
HSHTEST test.txt
ztc -ms BCDTEST cppts.lib
BCDTEST
ztc -ms VMATEST cppts.lib
echo Put a blank formatted floppy in A:
pause
VMATEST -c
ztc -ms VMSTEST cppts.lib
echo Data file will be built on drive C
pause
VMSTEST -c
ztc -ms TIMTEST cppts.lib
TIMTEST
ztc -ms RTCTEST cppts.lib
RTCTEST
ztc -ms DIRTEST cppts.lib
DIRTEST
ztc -ms FNTEST cppts.lib
FNTEST .\fntest.exe
ztc -ms IVTEST cppts.lib
IVTEST
ztc -ms CETEST cppts.lib
CETEST
ztc -ms SETEST cppts.lib
SETEST
ztc -ms WINTEST cppts.lib
WINTEST
ztc -ms TEXTTEST cppts.lib
TEXTTEST
ztc -ms DATTEST cppts.lib
DATTEST
ztc -ms MONTEST cppts.lib
MONTEST
ztc -ms ETEST2 cppts.lib
ETEST2