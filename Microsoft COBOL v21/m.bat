del %1.obj 2>nul
del %1.exe 2>nul

ntvdm -r:. -h -c -d cobol %1,%1,%1/D;

ntvdm -c runcob %1
echo:


