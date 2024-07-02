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
	assert.$O ctype.$O isalnum.$O isalpha.$O isascii.$O iscntrl.$O \
	isdigit.$O isgraph.$O islower.$O isprint.$O ispunct.$O isspace.$O \
	isupper.$O isxdigit.$O localeco.$O setjmp.$O setlocal.$O toupper.$O \
	signal.$O sigtable.$O

clib: $(OBJ)
