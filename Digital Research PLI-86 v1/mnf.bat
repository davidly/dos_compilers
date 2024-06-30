ntvdm pli.exe %1 $L
ntvdm link86 %1,pcdio.obj,plilib.l86

ntvdm -c -p %1


