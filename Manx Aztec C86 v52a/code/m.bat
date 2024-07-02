ntvdm -c -e:include=c:\include,path=c:\bin -r:.. ..\bin\cc -DAZTEC86 -L100 +F +A %1.c
del ctmp* 1>nul 2>nul
ntvdm -r:.. -e:lib=c:\lib\libs ..\bin\ln %1 c:\lib\libs\m.lib c:\lib\libs\c.lib
