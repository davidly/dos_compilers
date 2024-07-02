#_ makefile   Mon Oct 16 1989   Modified by: Samuel Druker */


CFLAGS=-DMSDOS

.c.obj:
	ztc -c $(CFLAGS) $*

makedep.com : makedep.obj mem.obj list.obj filespec.obj filesear.obj
	ztc -gl -mti makedep mem list filespec filesear.obj \
		$(LIB)\_mains.obj

filesear.obj : file.c
	ztc -c $(CFLAGS) -DAfilesear file -ofilesear.obj


menu.exe : menu.h menu.c
	ztc -mi -DTEST menu

