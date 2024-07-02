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
	abort.$O abs.$O atexit.$O atoi.$O atol.$O bsearch.$O calloc.$O\
	div.$O exit.$O qsort.$O getenv.$O labs.$O ldiv.$O\
	mblen.$O mbstowcs.$O mbtowc.c rand.$O strtol.$O strtoul.$O system.$O\
	wcstombs.$O wctomb.$O mallocc.$O freec.$O lfind.$O lsearch.$O \
	min.$O max.$O

MOBJ=atof.$O ftoa.$O strtod.$O strtold.$O

clib: $(OBJ) clib.$O

clib.o clib.olc: malloc.$O realloc.$O free.$O

clib.old clib.ol: ldlmallo.$O ldlcalloc.$O ldlrealloc.$O ldlfree.$O \
	ldmalloc.$O ldrealloc.$O ldfree.$O

mlib: $(MOBJ)
