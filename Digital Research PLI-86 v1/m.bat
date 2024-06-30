ntvdm pli.exe %1 $L $I
ntvdm link86 %1,plilib.l86,pcdio.obj,div2.obj,fdiv2.obj

ntvdm -c -p %1


