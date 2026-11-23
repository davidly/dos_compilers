@echo off
setlocal
if "%~1"=="" goto usage
if not "%~2"=="" goto usage
if /i not "%~x1"==".BAS" if not "%~x1"=="" goto usage
set "name=%~n1"
for %%L in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") do call set "name=%%name:%%~L%%"
pushd "%~dp0" || exit /b 1
ntvdm -c QB.EXE "%name%.BAS/O;" <nul
set "result=%errorlevel%"
if not "%result%"=="0" goto done
ntvdm -c LINK.EXE "%name%,,%name%,,,;" <nul
set "result=%errorlevel%"
:done
popd
exit /b %result%
:usage
echo Usage: m.bat name[.BAS] 1>&2
exit /b 1
