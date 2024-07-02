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
	cio.$O scr_cdel.$O scr_cins.$O scr_clea.$O scr_echo.$O scr_eol.$O\
	scr_eos.$O scr_getc.$O scr_home.$O scr_inve.$O scr_ldel.$O scr_lins.$O\
	scr_curs.$O scr_loc.$O scr_putc.$O scr_call.$O

slib: $(OBJ)
