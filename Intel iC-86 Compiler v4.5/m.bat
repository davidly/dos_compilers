@echo off

rem the compiler and libs\* c runtime is from https://winworldpc.com/product/intel-ic-86-compiler/45
rem the linker and u\* objects are from https://winworldpc.com/product/intel-iapx-86-88-family-utilities/42
rem use u not util for the directory name to keep the link86 command tail < 127 characters
setlocal

ntvdm -r:. -e::include:=inc ic86 %1.c small optimize(3) mod86 diagnostic( 2 ) define (INTELC)

if %ERRORLEVEL% == 0 ( goto nowlink )

echo compile failed
goto eof

:nowlink

rem 8087 required
rem ntvdm -r:. link86 libs\cstdoss.obj,c:\%1.obj,c:\libs\cdoss.lib,u\cel87.lib,u\8087.lib,libs\clib87.lib TO %1.exe exe

rem 8087 emulator
ntvdm -r:. link86 libs\cstdoss.obj,%1.obj,c:\libs\cdoss.lib,u\cel87.lib,u\e8087.lib,u\de8087,libs\clib87.lib TO %1.exe exe

if %ERRORLEVEL% == 0 ( goto eof )

echo link failed

:eof

