@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.COM 2>nul

ntvdm -r:. -c TURBOCL.COM %1

ntvdm -r:. -c -p %1.COM
