@echo off
setlocal
pushd "%~dp0" || exit /b 1
ntvdm -r:. -c PBCL.EXE %* <nul
set "result=%errorlevel%"
popd
exit /b %result%
