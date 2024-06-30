del %1.obj
del %1.exe

ntvdm -r:.. -c -d cobol %1,%1,%1,%1

rem link.exe that ships with cobol requires 286+ protected mode. use msvc v5's linker instead
rem qbx's link.exe executes code in a segment it just freed
ntvdm -h -i -c -r:.. /e:lib=c:\lib mcv5link %1,,%1,,nul.def

ntvdm -c -m -p %1

