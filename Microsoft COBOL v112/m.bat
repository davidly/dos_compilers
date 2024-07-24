del %1.obj 2>nul
del %1.exe 2>nul

ntvdm -r:. -h -c -d cobol %1,%1,%1/D;

ntvdm -h -c -r:. link %1,%1,%1,C:;

ntvdm -c -m %1

