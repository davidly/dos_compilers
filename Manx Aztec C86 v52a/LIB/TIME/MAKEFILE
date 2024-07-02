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
	asctime.$O clock.$O ctime.$O gmtime.$O localtim.$O\
	time.$O mktime.$O strftime.$O dosdattim.$O

MOBJ=difftime.$O

clib: $(OBJ)

mlib: $(MOBJ)
