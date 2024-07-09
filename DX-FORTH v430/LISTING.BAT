echo off
echo Usage: LISTING screenfile output
if "%1"=="" goto end
if "%2"=="" goto end
forth %1 :noname 'DX c! 2 doscall ; sys-vec 8 + ! listing bye >%2
echo done!
:end
