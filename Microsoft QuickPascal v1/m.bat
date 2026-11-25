@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul

ntvdm -r:. qpl %1.PAS

ntvdm -r:. -c -p %1.EXE
