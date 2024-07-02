build.bat
echo off
if NOT '%1'=='RESTART' goto makeall
shift
goto %RESTART%
:makeall
make clean
:SMALL
set RESTART=SMALL
make MODEL= AMODEL=0 %1 %2 %3 %4 %5 %6
if ERRORLEVEL 1 goto quit
make clean
:COMPACT
set RESTART=COMPACT
make MODEL=lc AMODEL=1 %1 %2 %3 %4 %5 %6
if ERRORLEVEL 1 goto quit
make clean
:MEDIUM
set RESTART=MEDIUM
make MODEL=ld AMODEL=2 %1 %2 %3 %4 %5 %6
if ERRORLEVEL 1 goto quit
make clean
:LARGE
set RESTART=LARGE
make MODEL=l AMODEL=3 %1 %2 %3 %4 %5 %6
if ERRORLEVEL 1 goto quit
make clean
set RESTART=
echo All models built OK.
goto done
:quit
echo Build failed making %RESTART% model libraries.
echo To restart build type "build RESTART [parameters]"
:done
c.bld
dos20/dosdir.o
dos20/monitor.o
dos20/profil.o
stdio/tmpfile.o
stdio/perror.o
stdio/fdopen.o
stdio/fgets.o
stdio/assert.o
stdio/fprintf.o
stdio/fputs.o
stdio/fread.o
stdio/fscanf.o
stdio/fseek.o
stdio/gets.o
stdio/getchar.o
stdio/getw.o
stdio/puterr.o
stdio/puts.o
stdio/putw.o
stdio/scanf.o
stdio/agetc.o
stdio/getc.o
stdio/setbuf.o
stdio/ungetc.o
stdio/tmpnam.o
stdio/mktemp.o
misc/atoi.o
misc/atol.o
misc/calloc.o
misc/lcalloc.o
misc/qsort.o
misc/sscanf.o
misc/scan.o
misc/rand.o
misc/abort.o
misc/raise.o
dos20/bdos.o
dos20/bdosx.o
dos20/chmod.o
dos20/csread.o
dos20/ctime.o
dos20/asctime.o
dos20/dostime.o
dos20/dup.o
dos20/execl.o
dos20/execlp.o
dos20/execvp.o
dos20/execv.o
dos20/exec.o
dos20/fexecl.o
dos20/fexecv.o
dos20/fcbinit.o
dos20/getcwd.o
dos20/ioctl.o
dos20/dioctl.o
dos20/localtim.o
dos20/mkdir.o
dos20/stat.o
dos20/system.o
misc/sprintf.o
dos20/fexec.o
dos20/getenv.o
dos20/utime.o
dos20/ftime.o
dos20/time.o
dos20/wait.o
dos20/access.o
mch86/cswt.o
mch86/cswit.o
mch86/clswit.o
mch86/farcall.o
mch86/fcall.o
mch86/index.o
mch86/olsubs.o
mch86/movblock.o
mch86/peek.o
mch86/port.o
mch86/rindex.o
mch86/segread.o
mch86/setjmp.o
mch86/setmem.o
mch86/strcat.o
mch86/strcpy.o
mch86/strncpy.o
mch86/strstr.o
mch86/stricmp.o
mch86/strlwr.o
mch86/strrev.o
mch86/swapmem.o
dos20/lmalloc.o
mch86/sysint.o
mch86/toupper.o
mch86/csav.o
dos20/dos.o
dos20/dosx.o
mch86/memccpy.o
mch86/memchr.o
mch86/memcmp.o
mch86/memcpy.o
mch86/memset.o
dos20/syserr.o
mch86/pointers.o
mch86/fptrs.o
mch86/ptradd.o
mch86/strchr.o
mch86/strrchr.o
dos20/clock.o
misc/signal.o
dos20/sighand.o
dos20/sigfix.o
misc/sigtable.o
dos20/mon.o
dos20/clk.o
stdio/fopen.o
stdio/fwrite.o
stdio/printf.o
stdio/putchar.o
stdio/aputc.o
stdio/putc.o
stdio/getbuff.o
misc/malloc.o
misc/format.o
misc/ctype.o
dos20/open.o
mch86/lsubs.o
mch86/strcmp.o
mch86/strlen.o
dos20/sys.o
mch86/ptrdiff.o
dos20/sbegin.o
dos20/croot.o
mch86/fltstub.o
dos20/stkover.o
dos20/stksiz.o
dos20/io.o
dos20/ttyio.o
mch86/movmem.o
dos20/isatty.o
dos20/ssbrk.o
dos20/filelock.o
c86.bld
stdio/tmpfile.o
stdio/perror.o
stdio/fdopen.o
stdio/fgets.o
stdio/fopen.o
stdio/assert.o
stdio/fprintf.o
stdio/fputs.o
stdio/fread.o
stdio/fscanf.o
stdio/fseek.o
stdio/fwrite.o
stdio/gets.o
stdio/getchar.o
stdio/getw.o
stdio/printf.o
stdio/puterr.o
stdio/puts.o
stdio/putchar.o
stdio/aputc.o
stdio/putw.o
stdio/putc.o
stdio/scanf.o
stdio/agetc.o
stdio/getc.o
stdio/getbuff.o
stdio/setbuf.o
stdio/ungetc.o
stdio/tmpnam.o
stdio/mktemp.o
misc/atoi.o
misc/atol.o
misc/calloc.o
misc/qsort.o
misc/sscanf.o
misc/scan.o
misc/rand.o
misc/abort.o
misc/raise.o
misc/signal.o
misc/sigtable.o
misc/malloc.o
misc/sprintf.o
misc/format.o
misc/ctype.o
mch86/cswt.o
mch86/cswit.o
mch86/clswit.o
mch86/farcall.o
mch86/fcall.o
mch86/index.o
mch86/lsubs.o
mch86/olsubs.o
mch86/peek.o
mch86/port.o
mch86/rindex.o
mch86/segread.o
mch86/setjmp.o
mch86/strlen.o
mch86/strncpy.o
mch86/swapmem.o
mch86/sysint.o
mch86/toupper.o
cpm86/sbrk.o
mch86/memccpy.o
mch86/memchr.o
mch86/memcmp.o
mch86/memcpy.o
mch86/memset.o
cpm86/access.o
cpm86/csread.o
mch86/movblock.o
cpm86/execl.o
cpm86/exec.o
cpm86/ioctl.o
cpm86/isatty.o
cpm86/lseek.o
cpm86/read.o
cpm86/rename.o
cpm86/write.o
cpm86/blkio.o
mch86/csav.o
mch86/pointers.o
mch86/fptrs.o
mch86/ptrdiff.o
mch86/ptradd.o
mch86/strchr.o
mch86/strrchr.o
cpm86/stkover.o
cpm86/begin.o
cpm86/croot.o
cpm86/close.o
cpm86/open.o
mch86/strcmp.o
cpm86/ceof.o
cpm86/find.o
mch86/setmem.o
mch86/strcat.o
mch86/strcpy.o
mch86/movmem.o
cpm86/unlink.o
mch86/fltstub.o
cpm86/bdos.o
cpm86/fcbinit.o
cpm86/user.o
cl.bld
dos20/monitor.o
dos20/profil.o
dos20/dosdir.o
stdio/tmpfile.o
stdio/perror.o
stdio/fdopen.o
stdio/fgets.o
stdio/assert.o
stdio/fprintf.o
stdio/fputs.o
stdio/fread.o
stdio/fscanf.o
stdio/fseek.o
stdio/gets.o
stdio/getchar.o
stdio/getw.o
stdio/puterr.o
stdio/puts.o
stdio/putw.o
stdio/scanf.o
stdio/agetc.o
stdio/getc.o
stdio/setbuf.o
stdio/ungetc.o
stdio/tmpnam.o
stdio/mktemp.o
misc/atoi.o
misc/atol.o
misc/calloc.o
misc/lcalloc.o
misc/qsort.o
misc/sscanf.o
misc/scan.o
misc/rand.o
misc/abort.o
misc/raise.o
dos20/bdos.o
dos20/bdosx.o
dos20/chmod.o
dos20/csread.o
dos20/ctime.o
dos20/asctime.o
dos20/dostime.o
dos20/dup.o
dos20/execl.o
dos20/execlp.o
dos20/execvp.o
dos20/execv.o
dos20/exec.o
dos20/fexecl.o
dos20/fexecv.o
dos20/fcbinit.o
dos20/getcwd.o
dos20/ioctl.o
dos20/dioctl.o
dos20/localtim.o
dos20/mkdir.o
dos20/stat.o
dos20/system.o
misc/sprintf.o
dos20/fexec.o
dos20/getenv.o
dos20/utime.o
dos20/ftime.o
dos20/time.o
dos20/wait.o
dos20/access.o
mch86/cswit.o
mch86/clswit.o
mch86/farcall.o
mch86/fcall.o
mch86/index.o
mch86/movblock.o
mch86/peek.o
mch86/port.o
mch86/rindex.o
mch86/segread.o
mch86/setjmp.o
mch86/setmem.o
mch86/strcat.o
mch86/strcpy.o
mch86/strncpy.o
mch86/strstr.o
mch86/stricmp.o
mch86/strlwr.o
mch86/strrev.o
mch86/swapmem.o
mch86/sysint.o
mch86/toupper.o
mch86/csav.o
dos20/dos.o
dos20/dosx.o
mch86/memccpy.o
mch86/memchr.o
mch86/memcmp.o
mch86/memcpy.o
mch86/memset.o
dos20/syserr.o
mch86/pointers.o
mch86/fptrs.o
mch86/strchr.o
mch86/strrchr.o
dos20/clock.o
misc/signal.o
dos20/sighand.o
dos20/sigfix.o
misc/sigtable.o
dos20/mon.o
dos20/clk.o
stdio/fopen.o
stdio/fwrite.o
stdio/printf.o
stdio/putchar.o
stdio/aputc.o
stdio/putc.o
stdio/getbuff.o
misc/ldlmallo.o
misc/ldmalloc.o
misc/format.o
misc/ctype.o
dos20/open.o
mch86/lsubs.o
mch86/strcmp.o
mch86/strlen.o
dos20/sys.o
mch86/ptrdiff.o
mch86/ptradd.o
dos20/lbegin.o
dos20/stksiz.o
dos20/croot.o
mch86/fltstub.o
dos20/stkover.o
dos20/io.o
dos20/ttyio.o
mch86/movmem.o
dos20/isatty.o
dos20/lsbrk.o
dos20/filelock.o
clc.bld
stdio/tmpfile.o
dos20/monitor.o
dos20/profil.o
dos20/dosdir.o
stdio/perror.o
stdio/fdopen.o
stdio/fgets.o
stdio/assert.o
stdio/fprintf.o
stdio/fputs.o
stdio/fread.o
stdio/fscanf.o
stdio/fseek.o
stdio/gets.o
stdio/getchar.o
stdio/getw.o
stdio/puterr.o
stdio/puts.o
stdio/putw.o
stdio/scanf.o
stdio/agetc.o
stdio/getc.o
stdio/setbuf.o
stdio/ungetc.o
stdio/tmpnam.o
stdio/mktemp.o
misc/atoi.o
misc/atol.o
misc/calloc.o
misc/lcalloc.o
misc/qsort.o
misc/sscanf.o
misc/scan.o
misc/rand.o
misc/abort.o
misc/raise.o
dos20/bdos.o
dos20/bdosx.o
dos20/chmod.o
dos20/csread.o
dos20/ctime.o
dos20/asctime.o
dos20/dostime.o
dos20/dup.o
dos20/execl.o
dos20/execlp.o
dos20/execvp.o
dos20/execv.o
dos20/exec.o
dos20/fexecl.o
dos20/fexecv.o
dos20/fcbinit.o
dos20/getcwd.o
dos20/ioctl.o
dos20/dioctl.o
dos20/localtim.o
dos20/mkdir.o
dos20/stat.o
dos20/system.o
misc/sprintf.o
dos20/fexec.o
dos20/getenv.o
dos20/utime.o
dos20/ftime.o
dos20/time.o
dos20/wait.o
dos20/access.o
mch86/cswit.o
mch86/clswit.o
mch86/farcall.o
mch86/fcall.o
mch86/index.o
mch86/movblock.o
mch86/peek.o
mch86/port.o
mch86/rindex.o
mch86/segread.o
mch86/setjmp.o
mch86/setmem.o
mch86/strcat.o
mch86/strcpy.o
mch86/strncpy.o
mch86/strstr.o
mch86/stricmp.o
mch86/strlwr.o
mch86/strrev.o
mch86/swapmem.o
dos20/lmalloc.o
mch86/sysint.o
mch86/toupper.o
mch86/csav.o
dos20/dos.o
dos20/dosx.o
mch86/memccpy.o
mch86/memchr.o
mch86/memcmp.o
mch86/memcpy.o
mch86/memset.o
dos20/syserr.o
mch86/pointers.o
mch86/fptrs.o
mch86/ptradd.o
mch86/strchr.o
mch86/strrchr.o
dos20/clock.o
misc/signal.o
dos20/sighand.o
dos20/sigfix.o
misc/sigtable.o
dos20/mon.o
dos20/clk.o
stdio/fopen.o
stdio/fwrite.o
stdio/printf.o
stdio/putchar.o
stdio/aputc.o
stdio/putc.o
stdio/getbuff.o
misc/malloc.o
misc/format.o
misc/ctype.o
dos20/open.o
mch86/lsubs.o
mch86/strcmp.o
mch86/strlen.o
dos20/sys.o
mch86/ptrdiff.o
dos20/sbegin.o
dos20/croot.o
mch86/fltstub.o
dos20/stkover.o
dos20/io.o
dos20/ttyio.o
mch86/movmem.o
dos20/isatty.o
dos20/ssbrk.o
dos20/stksiz.o
dos20/filelock.o
cld.bld
dos20/monitor.o
dos20/profil.o
dos20/dosdir.o
stdio/tmpfile.o
stdio/perror.o
stdio/fdopen.o
stdio/fgets.o
stdio/assert.o
stdio/fprintf.o
stdio/fputs.o
stdio/fread.o
stdio/fscanf.o
stdio/fseek.o
stdio/gets.o
stdio/getchar.o
stdio/getw.o
stdio/puterr.o
stdio/puts.o
stdio/putw.o
stdio/scanf.o
stdio/agetc.o
stdio/getc.o
stdio/setbuf.o
stdio/ungetc.o
stdio/tmpnam.o
stdio/mktemp.o
misc/atoi.o
misc/atol.o
misc/calloc.o
misc/lcalloc.o
misc/qsort.o
misc/sscanf.o
misc/scan.o
misc/rand.o
misc/abort.o
misc/raise.o
dos20/bdos.o
dos20/bdosx.o
dos20/chmod.o
dos20/csread.o
dos20/ctime.o
dos20/asctime.o
dos20/dostime.o
dos20/dup.o
dos20/execl.o
dos20/execlp.o
dos20/execvp.o
dos20/execv.o
dos20/exec.o
dos20/fexecl.o
dos20/fexecv.o
dos20/fcbinit.o
dos20/getcwd.o
dos20/ioctl.o
dos20/dioctl.o
dos20/localtim.o
dos20/mkdir.o
dos20/stat.o
dos20/system.o
misc/sprintf.o
dos20/fexec.o
dos20/getenv.o
dos20/utime.o
dos20/ftime.o
dos20/time.o
dos20/wait.o
dos20/access.o
mch86/cswit.o
mch86/clswit.o
mch86/farcall.o
mch86/fcall.o
mch86/index.o
mch86/movblock.o
mch86/peek.o
mch86/port.o
mch86/rindex.o
mch86/segread.o
mch86/setjmp.o
mch86/setmem.o
mch86/strcat.o
mch86/strcpy.o
mch86/strncpy.o
mch86/swapmem.o
mch86/sysint.o
mch86/csav.o
mch86/strstr.o
mch86/stricmp.o
mch86/strlwr.o
mch86/strrev.o
mch86/toupper.o
dos20/dos.o
dos20/dosx.o
mch86/memccpy.o
mch86/memchr.o
mch86/memcmp.o
mch86/memcpy.o
mch86/memset.o
dos20/syserr.o
mch86/pointers.o
mch86/fptrs.o
mch86/strchr.o
mch86/strrchr.o
dos20/clock.o
misc/signal.o
dos20/sighand.o
dos20/sigfix.o
misc/sigtable.o
dos20/mon.o
dos20/clk.o
stdio/fopen.o
stdio/fwrite.o
stdio/printf.o
stdio/putchar.o
stdio/aputc.o
stdio/putc.o
stdio/getbuff.o
misc/ldlmallo.o
misc/ldmalloc.o
misc/format.o
misc/ctype.o
dos20/open.o
mch86/lsubs.o
mch86/strcmp.o
mch86/strlen.o
dos20/sys.o
mch86/ptrdiff.o
mch86/ptradd.o
dos20/lbegin.o
dos20/stksiz.o
dos20/croot.o
mch86/fltstub.o
dos20/stkover.o
dos20/io.o
dos20/ttyio.o
mch86/movmem.o
dos20/isatty.o
dos20/lsbrk.o
dos20/filelock.o
m.bld
math/asin.o
math/atan.o
math/floor.o
math/pow.o
math/log.o
math/random.o
math/sin.o
math/sinh.o
math/sqrt.o
math/tan.o
math/tanh.o
math/exp.o
stdio/fprintf.o
stdio/printf.o
misc/sprintf.o
misc/fformat.o
stdio/fscanf.o
stdio/scanf.o
misc/sscanf.o
misc/fscan.o
math/atof.o
math/ftoa.o
math/frexp.o
math/fabs.o
math/fpst.o
math/fsubs.o
m87.bld
math/floor87.o
math/pow87.o
math/log87.o
math/random87.o
math/sin87.o
math/sinh87.o
math/tan87.o
math/tanh87.o
stdio/fprintf.o
stdio/printf.o
misc/sprintf.o
misc/fformat.o
stdio/fscanf.o
stdio/scanf.o
misc/sscanf.o
misc/fscan87.o
math/atof87.o
math/ftoa87.o
math/asin87.o
math/sqrt87.o
math/atan87.o
math/exp1087.o
math/exp87.o
math/fmod87.o
math/frexp87.o
math/fabs87.o
math/fpst.o
math/isnan.o
math/fsubs87.o
math/chk87.o
m87s.bld
math/asin.o
math/atan.o
math/floor.o
math/pow.o
math/log.o
math/random.o
math/sin.o
math/sinh.o
math/sqrt87s.o
math/tan.o
math/tanh.o
math/exp.o
stdio/fprintf.o
stdio/printf.o
misc/sprintf.o
misc/fformat.o
stdio/fscanf.o
stdio/scanf.o
misc/sscanf.o
misc/fscan.o
math/atof.o
math/ftoa.o
math/frexp87s.o
math/fabs.o
math/fpst.o
math/fsubs87s.o
makefile
MODEL=
AMODEL=0

all: dos math86 math87 maths graph scn rom
	@echo all done

math: math86 math87 maths
	@echo math all done

clean:
	del dos20\*.o
	del math\*.o
	del mch86\*.o
	del misc\*.o
	del stdio\*.o
	del cpm86\*.o
	del graphics\*.o
	del screen\*.o

dos: mkdos20 mkmch86 mkmisc mkstdio
	del libs\c$(MODEL).lib
	lb libs/c$(MODEL).lib -f c$(MODEL).bld

cpm: mkcpm mkmch86 mkmisc mkstdio
	del libs\c86$(MODEL).lib
	lb libs/c86$(MODEL).lib -f c86$(MODEL).bld

math86: mkmath mathmisc mathstdio
	del libs\m$(MODEL).lib
	lb libs/m$(MODEL).lib -f m.bld

maths: mkmath mathmisc mathstdio
	del libs\m87s$(MODEL).lib
	lb libs/m87s$(MODEL).lib -f m87s.bld

math87: mkmath87 mathmisc mathstdio
	del libs\m87$(MODEL).lib
	lb libs/m87$(MODEL).lib -f m87.bld

graph:
	cd graphics
	make MODEL=$(MODEL) AMODEL=$(AMODEL) DIR=..\libs\ ..\libs\g$(MODEL).lib
	cd ..

scn:
	cd screen
	make MODEL=$(MODEL) AMODEL=$(AMODEL) DIR=..\libs\ ..\libs\s$(MODEL).lib
	cd ..

rom:
	cd mch86
	make MODEL=$(MODEL) AMODEL=$(AMODEL) DIR=..\libs\ ..\libs\\$(MODEL)rom.o
	cd ..

ovly:
	cd mch86
	make MODEL=$(MODEL) AMODEL=$(AMODEL) DIR=..\libs\ ovly$(MODEL)
	cd ..

mkdos20:
	cd dos20
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld$(MODEL)
	cd ..

mkcpm:
	cd cpm86
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld$(MODEL)
	cd ..

mkmath:
	cd math
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld$(MODEL)
	cd ..

mkmath87:
	cd math
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld87$(MODEL)
	cd ..

mkmch86:
	cd mch86
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld$(MODEL)
	cd ..

mkmisc:
	cd misc
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld$(MODEL)
	cd ..

mathmisc:
	cd misc
	make MODEL=$(MODEL) AMODEL=$(AMODEL) math
	cd ..

mkstdio:
	cd stdio
	make MODEL=$(MODEL) AMODEL=$(AMODEL) bld$(MODEL)
	cd ..

mathstdio:
	cd stdio
	make MODEL=$(MODEL) AMODEL=$(AMODEL) math
	cd ..

arc:
	mkarcv build.arc <build.bld
