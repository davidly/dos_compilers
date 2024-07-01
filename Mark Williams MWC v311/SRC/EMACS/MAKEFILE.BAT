: makefile.bat 3/11/86
: MSDOS batch file to build executable MicroEMACS me.exe.
: Remember to put MicroEMACS source files into a separate directory!
: Uses "tempfile" to avoid MSDOS command line length restrictions.
: Requires header "ed.h" in addition to files listed below.

echo ansi.c basic.c buffer.c display.c file.c fileio.c >tempfile
echo line.c main.c random.c region.c search.c spawn.c >>tempfile
echo tcap.c termio.c vt52.c window.c word.c           >>tempfile

cc -VQUIET -o me @tempfile
del tempfile
