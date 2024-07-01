echo off
if x%1 == xTINY    goto ok
if x%1 == xSMALL   goto ok
if x%1 == xCOMPACT goto ok
if x%1 == xMEDIUM  goto ok
if x%1 == xLARGE   goto ok
if x%1 == xHUGE    goto ok
echo BUILD-C0 must have argument: TINY, SMALL, COMPACT, MEDIUM, LARGE or HUGE
goto done
:ok
echo on
goto make-%1
:make-TINY
MASM C0,C0T     /D__TINY__    /MX;
goto done
:make-SMALL
MASM C0,C0S     /D__SMALL__   /MX;
goto done
:make-COMPACT
MASM C0,C0C     /D__COMPACT__ /MX;
goto done
:make-MEDIUM
MASM C0,C0M     /D__MEDIUM__  /MX;
goto done
:make-LARGE
MASM C0,C0L     /D__LARGE__   /MX;
goto done
:make-HUGE
MASM C0,C0H     /D__HUGE__    /MX;
echo on
:done
