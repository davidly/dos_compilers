del %1.obj
ntvdm /f /c qcl /DDOSTIME /I..\include /AS /Ox /Gs /c %1.c
ntvdm /t link %1,,%1,..\lib\slibce+..\lib\em

ntvdm /c /p %1
