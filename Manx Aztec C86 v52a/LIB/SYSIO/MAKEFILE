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

OBJ= \
	io.$O isatty.$O open.$O ttyio.$O ttyio2.$O readc.$O writec.$O closec.$O \
	openc.$O lseekc.$O unlinkc.$O renamec.$O creatc.$O isattyc.$O mktemp.$O 

clib: $(OBJ)

io.$O: ioincl.h

ioincl.h: ioincl.c
	cc -w -o ioincl.h ioincl.c
