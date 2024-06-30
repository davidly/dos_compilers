del %1.map
del %1.exe
del %1.lst
del %1.obj

ntvdm -h bin\masm /Zi /Zd /z /l %1,,,;
ntvdm -h bin\link /CP:1 %1,,%1,,nul.def

