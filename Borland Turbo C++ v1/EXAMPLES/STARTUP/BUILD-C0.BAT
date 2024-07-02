if %1.==TINY.    goto ok
if %1.==SMALL.   goto ok
if %1.==COMPACT. goto ok
if %1.==MEDIUM.  goto ok
if %1.==LARGE.   goto ok
if %1.==HUGE.    goto ok
for %%i in (TINY SMALL COMPACT MEDIUM LARGE HUGE) do call BUILD-C0 %%i
goto done
:ok
echo on
goto make-%1
:make-TINY
TASM  /D__TINY__    /MX /i..\h C0,C0T
goto done
:make-SMALL
TASM  /D__SMALL__   /MX /i..\h C0,C0S
goto done
:make-COMPAC
TASM  /D__COMPACT__ /MX /i..\h C0,C0C
goto done
:make-MEDIUM
TASM  /D__MEDIUM__  /MX /i..\h C0,C0M
goto done
:make-LARGE
TASM  /D__LARGE__   /MX /i..\h C0,C0L 
goto done
:make-HUGE
TASM  /D__HUGE__    /MX /i..\h C0,C0H 
echo on
:done
