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

clib: clib.$O

OBJSD= ../libs/begin-sd.$O ../libs/abeginsd.$O ../libs/heap-sd.$O 
OBJLD= ../libs/begin-ld.$O ../libs/abeginld.$O ../libs/heap-ld.$O 

clib.o clib.olc: $(OBJSD)

clib.old clib.ol: $(OBJLD)

../libs/begin-sd.$O: begin-sd.asm
	$(AS) -o $@ $(AFLAGS) begin-sd.asm
	sqz $@

../libs/begin-ld.$O: begin-ld.asm
	$(AS) -o $@ $(AFLAGS) begin-ld.asm
	sqz $@

../libs/abeginsd.$O: abeginsd.asm
	$(AS) -o $@ $(AFLAGS) abeginsd.asm
	sqz $@

../libs/abeginld.$O: abeginld.asm
	$(AS) -o $@ $(AFLAGS) abeginld.asm
	sqz $@

../libs/heap-sd.$O: heap-sd.asm
	$(AS) -o $@ $(AFLAGS) heap-sd.asm
	sqz $@

../libs/heap-ld.$O: heap-ld.asm
	$(AS) -o $@ $(AFLAGS) heap-ld.asm
	sqz $@

