ntvdm cc86 %1.c
ntvdm masm %1.mac;;
ntvdm link /STACK:4096 %1,,%1,clib.lib,nul.def




