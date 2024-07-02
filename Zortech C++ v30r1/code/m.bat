ntvdm -e:path=c:\bin -r:.. ..\bin\ztc %1.c -Ic:\include -ms -c -DDOSTIME 

ntvdm -e:path=c:\bin,lib=c:\lib -r:.. ..\bin\blink ct+%1, %1, %1, ZLs.LIB /noi ;

