CC=cc
AS=as
CFLAGS=-n
AFLAGS=-dMODEL=
O=o

.c.$O:
	$(CC) -o $@ $(CFLAGS) $*.c
	sqz $@
.asm.$O:
	$(AS) -o $@ $(AFLAGS) $*.asm
	sqz $@

OBJ=\
	access.$O _access.$O bdos.$O bdosx.$O chmod.$O clk.$O csread.$O ftime.$O\
	dioctl.$O dos.$O dosdir.$O dostime.$O dosx.$O dup.$O exec.$O execl.$O\
	execlp.$O execv.$O execvp.$O fcbinit.$O fexec.$O fexecl.$O fexecv.$O \
	filelock.$O\
	getcwd.$O ioctl.$O mkdir.$O mon.$O monitor.$O profil.$O stat.$O \
	utime.$O wait.$O\
	peek.$O pointers.$O port.$O segread.$O sysint.$O \
	fnmerge.$O fnsplit.$O makepath.$O spltpath.$O

clib : $(OBJ) clib.$O

clib.o: ../libs/ovld.o ../libs/ovldpath.o ../libs/ovbgn.o

clib.olc clib.old clib.ol:

../libs/ovld.o: ovloader.c
	$(CC) $(CFLAGS) ovloader.c -o $@
../libs/ovldpath.o: ovloader.c
	$(CC) $(CFLAGS) -DDOS20 ovloader.c -o $@
../libs/ovbgn.o: ovbgn.asm
	$(AS) $(AFLAGS) ovbgn.asm -o $@
