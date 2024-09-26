del %1.o 2>nul
del %1.exe 2>nul

ntvdm pcc %1
ntvdm pccl %1

del %1.o 2>nul


