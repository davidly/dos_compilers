del %1.cod 2>nul
del %1.obj 2>nul
del %1.lst 2>nul
del %1.map 2>nul
del %1.exe 2>nul

ntvdm pas1 %1,%1,%1,%1;
ntvdm pas2
ntvdm link %1,%1,,pascal.lib

del con.lst 2>nul
del %1.cod 2>nul
del %1.obj 2>nul
del %1.lst 2>nul
del %1.map 2>nul

rem Some binaries created by this compiler require being loaded above 64k or
rem they crash with a stack error.
rem Use ntvdm's -h switch to enable them to run, e.g.:
rem ntvdm -h sieve.exe

