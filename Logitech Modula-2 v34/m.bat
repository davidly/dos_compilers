ntvdm -f -r:. -e:m2sym=m2lib\sym m2exe\M2C.EXE %1

rem the modula 2 linker fails
rem ntvdm -r:. -e:m2lib=m2lib\lib m2exe\m2l %1/o/p

rem the qbx linker works fine
ntvdm -h -f -r:. -e:lib=m2lib\lib link %1,,,m2lib m2rts.lib;

ntvdm %1

