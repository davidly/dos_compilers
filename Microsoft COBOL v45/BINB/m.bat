del %1.obj
del %1.exe

ntvdm -r:.. -c -e:path=c:\binb;c:\binr cobol %1,%1,%1,%1

ntvdm -h -c -r:.. -e:lib=c:\lib link %1,,%1,,nul.def

ntvdm -c -m -r:.. -e:path=c:\binb;c:\binr %1

