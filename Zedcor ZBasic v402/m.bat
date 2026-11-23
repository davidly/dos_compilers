@echo off
setlocal
pushd "%~dp0" || exit /b 1
ntvdm -c ZBASICCL.COM %* <nul
set "result=%errorlevel%"
popd
exit /b %result%
