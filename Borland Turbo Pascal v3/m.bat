@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem patchtp3.py removes the startup CPU speed check Turbo Pascal 3.02a puts in every app;
rem on an emulator it runs for a very long time and throws off the benchmark numbers.

set "PY=python"
where py >nul 2>&1 && set "PY=py -3"

del %1.COM 2>nul

ntvdm -r:. -c TURBOCL.COM %1
%PY% patchtp3.py %1.COM

ntvdm -r:. -c -p %1.COM
