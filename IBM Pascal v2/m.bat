del %1.cod 2>nul
del %1.obj 2>nul
del %1.lst 2>nul
del %1.exe 2>nul

ntvdm pas1 %1,%1,%1,%1;
ntvdm pas2
ntvdm pas3
ntvdm link %1,%1,,pascal.lib

del %1.cod 2>nul
del %1.obj 2>nul
del %1.lst 2>nul
del %1.map 2>nul
