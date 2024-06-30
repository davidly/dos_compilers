rem -h flag is required for pas2 and generated apps so the top of ram is on a 64k-1 boundary
rem due to bugs in the apps that try to copy 64k-1 bytes of ram and wrap.

del %1.exe

ntvdm -c pas1 %1,%1,%1,%1
del con.lst
ntvdm -h -c pas2
ntvdm -c link %1 djldos,,,,

ntvdm -h -p %1

