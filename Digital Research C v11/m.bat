del %1.obj 2>nul
del %1.sym 2>nul
del %1.exe 2>nul

ntvdm -r:. drc %1
ntvdm -r:. link86 %1

del %1.obj 2>nul
del %1.sym 2>nul

