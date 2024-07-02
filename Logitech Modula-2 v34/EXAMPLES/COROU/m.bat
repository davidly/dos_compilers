ntvdm -r:..\.. -e:m2sym=c:\m2lib\sym ..\..\m2exe\M2C.EXE corou

rem the modula 2 linker fails
rem ntvdm -r:..\.. -e:m2lib=m2lib\lib ..\..\m2exe\m2l corou/o/p

rem the qbx linker works fine
ntvdm -r:..\.. -e:lib=c:\m2lib\lib ..\..\link corou,,,m2lib m2rts.lib;

