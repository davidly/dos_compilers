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
	index.$O memccpy.$O memchr.$O memcmp.$O memcopy.$O memcpy.$O\
	memmove.$O memset.$O movmemc.$O movblock.$O movmem.$O rindex.$O\
	setmemc.$O setmem.$O strcat.$O strchr.$O strcmp.$O strcoll.$O strcpy.$O\
	strcspn.$O stricmp.$O strlen.$O strncat.$O strncmp.$O strncpy.$O\
	strpbrk.$O strrchr.$O strrev.$O strspn.$O strstr.$O strtok.$O\
	strxfrm.$O swapmem.$O strerror.$O strlwr.$O syserr.$O mbtowc.$O\
	xstrerror.$O strnicmp.$O strdup.$O

clib: $(OBJ)
