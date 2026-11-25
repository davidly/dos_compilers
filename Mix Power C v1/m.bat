@echo off
rem build and run a benchmark, e.g. m sieve
setlocal
rem pc.exe crashes after it's done because it trashes its own stack; its output is discarded.

del %1.EXE 2>nul
del %1.MIX 2>nul

ntvdm -r:. pc /c /ms /dpowerc /j /fi /q %1.C 1>nul 2>nul
ntvdm -r:. pcl %1

del %1.MIX 2>nul

ntvdm -r:. -c -p %1.EXE
