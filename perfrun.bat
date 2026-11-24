@echo off
rem Build and time the benchmarks for every compiler; see perfrun.py for details.
rem usage: perfrun [-j jobs] [-t seconds] [-k] [name-filter ...]
setlocal
set "PY=python"
where py >nul 2>&1 && set "PY=py -3"
%PY% "%~dp0perfrun.py" %*
