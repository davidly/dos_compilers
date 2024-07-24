del %1.obj
del %1.exe

ntvdm -r:. -h -c -d cobol %1,%1,%1,%1

ntvdm -h -c -r:. link %1,,%1,lcobol.lib,nul.def

ntvdm -c %1

