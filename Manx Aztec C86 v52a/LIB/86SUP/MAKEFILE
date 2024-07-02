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
	clswit.$O croot.$O  cswit.$O  farcall.$O fcall.$O fltstub.$O fptrs.$O\
	lsubs.$O ptradd.$O ptrdiff.$O sys.$O sigfix.$O sighand.$O  stksiz.$O\
	sbrkc.$O brkc.$O sysc.$O dosclock.$O stkover.$O vars.$O _exit.$O csav.$O \
	filetime.$O

clib: $(OBJ) clib.$O

clib.o clib.olc: sbegin.$O ssbrk.$O rsvstkc.$O lmalloc.$O lcalloc.$O

clib.old clib.ol: lbegin.$O lsbrk.$O
