del %1.obj
ntvdm /f /t /c qcl /DDOSTIME /I..\include /AS /Ox /Gs /c %1.c
ntvdm /t link %1,,%1,..\lib\slibce+..\lib\em
copy %1.exe %1_qc1.exe
ntvdm /c /p %1 10
