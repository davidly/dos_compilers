@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.JRL 2>nul
del %1.PRN 2>nul
del %1.SYM 2>nul

ntvdm -r:. janus %1 /L /O1
ntvdm -r:. optimize %1
ntvdm -r:. jlink %1 /O1

del %1.JRL 2>nul
del %1.PRN 2>nul
del %1.SYM 2>nul

ntvdm -r:. -c -p %1.EXE
