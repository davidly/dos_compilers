@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

ntvdm -r:. -c -p HELLO %1.TRU
