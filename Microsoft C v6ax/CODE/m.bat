ntvdm -c -r:.. -e:path=c:\bin;c:\binb,include=c:\include,lib=c:\lib ..\bin\cl.exe /nologo /B1 C1L /B2 C2L /Owx /Fe%1.exe /Fc%1.cod %1.c
ntvdm -c -p %1


