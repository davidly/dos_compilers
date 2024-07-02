#_ makefile   Thu Mar  1 1990   Modified by: Walter Bright */

CFLAGS= -DMSDOS -o+space

.c.obj:
	ztc -c $(CFLAGS) $*

FILE=filedire.obj filecopy.obj fileexis.obj filesett.obj \
	filetime.obj filesear.obj

all: archive.com update.com makedep.com menu.exe

clean:
	del *.obj
        
archive.com : archive.obj mem.obj filespec.obj filedire.obj filecopy.obj \
	filesett.obj filetime.obj
	ztc -mti archive.obj mem.obj filespec.obj filedire.obj filecopy.obj \
	 filesett.obj filetime.obj

update.com : update.obj mem.obj filespec.obj filedire.obj filecopy.obj \
	filesett.obj filetime.obj
	ztc -mti update.obj mem.obj filespec.obj filedire.obj filecopy.obj \
	 filesett.obj filetime.obj

makedep.com : makedep.obj mem.obj list.obj filespec.obj filesear.obj
	ztc -gl -mti makedep.obj mem.obj list.obj filespec.obj filesear.obj \
		\zortech\lib\_mains.obj

menu.exe : menu.h menu.c
	ztc -mi -DTEST menu

$(FILE) : file.h file.c
	ztc -c $(CFLAGS) -DA$* file -o$*.obj
