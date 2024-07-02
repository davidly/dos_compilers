ntvdm -r:. -e:lib=..\lib /h /c qcl /DDOSTIME /I..\include /Fm%1.map /AS /Ox /Gs %1.c
rem ntvdm -r:. /h /c qcl /DDOSTIME /I..\include /AS /Ox /Gs /c %1.c
rem ntvdm -r:. /h qlink %1,,%1,..\lib\slibce+..\lib\em


