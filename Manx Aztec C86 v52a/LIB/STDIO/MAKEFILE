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
	clearerr.$O fclose.$O fdopen.$O feof.$O ferror.$O _format.$O \
	fgetc.$O fgetpos.$O\
	fgets.$O filbuf.$O fileopen.$O fopen.$O format.$O fprintf.$O fputc.$O\
	fputs.$O fread.$O freopen.$O fscanf.$O fseek.$O fsetpos.$O ftell.$O \
	fwrite.$O getbuf.$O\
	getchar.$O gets.$O getw.$O perror.$O printf.$O putchar.$O puts.$O \
	putw.$O remove.$O rename.$O rewind.$O scan.$O scanf.$O setbuf.$O \
	setvbuf.$O sprintf.$O sscanf.$O\
	tmpfile.$O tmpnam.$O ungetc.$O vfprintf.$O vprintf.$O vsprintf.$O\
	putc.$O aputc.$O getc.$O agetc.$O

MOBJ=\
	_format.$O format.$O scan.$O \
	fprintf.$O printf.$O sprintf.$O \
	fscanf.$O scanf.$O sscanf.$O

clib: $(OBJ)

mlib: $(MOBJ)
