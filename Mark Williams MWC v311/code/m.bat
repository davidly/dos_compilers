@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.O 2>nul

ntvdm -r:.. "-e:CCHEAD=@C:\lib\cc -f -DMWC" ..\bin\cc %1.C -lm

del %1.O 2>nul

ntvdm -r:. -c -p %1.EXE
