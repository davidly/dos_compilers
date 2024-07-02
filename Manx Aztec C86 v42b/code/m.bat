ntvdm -e:include=c:\include,path=c:\bin -r:.. ..\bin\cc -DAZTEC86 +F +A %1.c
del ctmp* 1>nul 2>nul
ntvdm -r:.. -e:lib=c:\lib ..\bin\ln %1 c:\lib\m.lib c:\lib\c.lib

