@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.MIX 2>nul

ntvdm -r:. pc -f /c /ms /dpowerc /dDOSTIME /j /fi /q %1.C 1>nul 2>nul
ntvdm -r:. pcl %1

del %1.MIX 2>nul

ntvdm -r:. -c -p %1.EXE
