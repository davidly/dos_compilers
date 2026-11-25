@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem /n removes array bounds checks and must be after the source file.
rem The compiler adds each unit to its program library, ADA.ALB; the original is restored after the build.
rem The first run is the interpreter on the .AXE file; the second is native code from a86.
rem a86 produces bad code for the stock ttt.ada so the board is passed as an argument,
rem and for the stock e.ada so more locals were added to reduce complexity.

del %1.AXE 2>nul
del %1.EXE 2>nul

copy /y ADA.ALB ADA.ALB.SAV >nul
ntvdm -r:. ADA %1.ADA /n
ntvdm -r:. LINKLIB %1
ntvdm -r:. A86 %1.AXE /n
move /y ADA.ALB.SAV ADA.ALB >nul

ntvdm -r:. -c -p AI %1
ntvdm -r:. -c -p %1.EXE
