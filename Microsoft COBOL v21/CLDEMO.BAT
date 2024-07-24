ECHO OFF
ECHO This batch file makes drive B: the default drive.
ECHO It also puts drive A: on your search path by issuing 
ECHO   PATH A:\.
ECHO Any PATH you have previously set up should be restored 
ECHO   after running this file by re-booting your system 
ECHO   or issuing your own PATH command.
ECHO You may cancel this file by typing CTRL-C after the PAUSE command.
ECHO *********************************************** 
ECHO Put source files on drive B: - include DEMO.CPY
ECHO ON
PAUSE  Put COBOL COMPILER in drive A:
B:
PATH A:\
COBOL DEMO/D;
COBOL BUILD/D;
COBOL UPDATE/D;
ECHO OFF
ECHO Be sure to restore any previous PATH now.
ECHO ON
