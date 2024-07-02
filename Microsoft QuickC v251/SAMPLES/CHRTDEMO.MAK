PROJ	=CHRTDEMO
DEBUG	=1
CC	=qcl
CFLAGS_G	= /AS /W1 /Ze 
CFLAGS_D	= /Zi /Zr /Gi$(PROJ).mdt /Od 
CFLAGS_R	= /O /Ot /DNDEBUG 
CFLAGS	=$(CFLAGS_G) $(CFLAGS_D)
LFLAGS_G	= /CP:0xfff /NOI /SE:0x80 /ST:0x800 
LFLAGS_D	= /CO /INCR 
LFLAGS_R	= 
LFLAGS	=$(LFLAGS_G) $(LFLAGS_D)
RUNFLAGS	=
H = 	chrtdemo.h 
OBJS_EXT = 	
LIBS_EXT = 	

.asm.obj: ; $(AS) $(AFLAGS) -c $*.asm

all:	$(PROJ).EXE

chrtdemo.obj:	chrtdemo.c $(H)

chrtopt.obj:	chrtopt.c $(H)

chrtsupt.obj:	chrtsupt.c $(H)

$(PROJ).EXE:	chrtdemo.obj chrtopt.obj chrtsupt.obj $(OBJS_EXT)
	echo >NUL @<<$(PROJ).crf
chrtdemo.obj +
chrtopt.obj +
chrtsupt.obj +
$(OBJS_EXT)
$(PROJ).EXE

$(LIBS_EXT);
<<
	ilink -a -e "qlink $(LFLAGS) @$(PROJ).crf" $(PROJ)

run: $(PROJ).EXE
	$(PROJ) $(RUNFLAGS)

