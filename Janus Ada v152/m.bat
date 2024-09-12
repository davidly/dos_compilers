@echo off
setlocal

del %1.exe 2>nul
del %1.jrl 2>nul
del %1.prn 2>nul
del %1.sym 2>nul

ntvdm janus %1 /L /O1
ntvdm optimize %1
ntvdm jlink %1 /O1

del %1.jrl 2>nul
del %1.prn 2>nul
del %1.sym 2>nul

