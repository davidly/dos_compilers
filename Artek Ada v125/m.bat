@echo off
setlocal

rem /n removes array bounds checks and must be after the source file
ntvdm ada %1.ada /n
ntvdm linklib %1

rem interpreter
ntvdm -c -p ai %1

rem native code. I've found a86 to be buggy.
rem    note: a86 produces bad code for ttt.ada. it uses inconsistent addresses for the "board" array.
rem    note2: a86 produces bad code for e.ada but the workaround to use more local variables worked.
del %1.exe 2>nul
ntvdm a86 %1.axe /n
ntvdm -c -p %1.exe


