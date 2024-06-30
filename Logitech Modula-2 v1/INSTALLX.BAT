pause * Loading Modula-2/86 system onto current drive from drive A: *
pause Insert 'System' disk in drive A:
copy a:comppara.sym \m2lib\sym
copy a:*.def \m2lib\def
copy a:*.mod \m2lib\mod
pause Insert 'Compiler' disk in drive A:
copy a:*.lod \m2lod
copy a:*.sym \m2lib\sym
pause Insert 'Linker' disk in drive A:
copy a:*.lod \m2lod
copy a:*.lnk \m2lib\lnk
copy a:*.ref \m2lib\ref
rem ****** BEFORE USING MODULA-2/86 PLEASE MAKE SURE THAT ****************
rem *  You have a CONFIG.SYS file, and it includes 'FILES=12'            *
rem *  You have an AUTOEXEC.BAT file, and it sets the search paths,      *
rem *  as described in the INSTALLATION section of the manual.           *
rem **********************************************************************
del installx.bat