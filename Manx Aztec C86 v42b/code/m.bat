@echo off
rem build and run a benchmark, e.g. m sieve
setlocal

del %1.EXE 2>nul
del %1.O 2>nul
del ctmp* 2>nul

ntvdm -r:.. -e:include=c:\include,path=c:\bin ..\bin\cc -DAZTEC86 +F +A %1.C
ntvdm -r:.. -e:lib=c:\lib ..\bin\ln %1 c:\lib\m.lib c:\lib\c.lib

del %1.O 2>nul
del ctmp* 2>nul

ntvdm -r:. -c -p %1.EXE
