@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.OBJ 2>nul

ntvdm -r:. algol %1

ntvdm -r:. -c -p arun %1.OBJ
