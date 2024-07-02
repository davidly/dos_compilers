PROJ	=MISCDEMO
DEBUG	=1
CC	=qcl
AS	=qcl
CFLAGS_G	=
CFLAGS_D	=/Od /Gi$(PROJ).mdt /Zi /Zr
CFLAGS_R	=/O /DNDEBUG
CFLAGS	=$(CFLAGS_G) $(CFLAGS_D)
AFLAGS_G	=/Cx /P1
AFLAGS_D	=/Zi
AFLAGS_R	=/DNDEBUG
AFLAGS	=$(AFLAGS_G) $(AFLAGS_D)
LFLAGS_G	=/NOI
LFLAGS_D	=/INCR /CO
LFLAGS_R	=
LFLAGS	=$(LFLAGS_G) $(LFLAGS_D)
RUNFLAGS	=
OBJS_EXT = 	
LIBS_EXT = 	

.asm.obj: ; $(AS) $(AFLAGS) -c $*.asm

all:	$(PROJ).EXE

miscdemo.obj:	miscdemo.asm

misc.obj:	misc.asm

common.obj:	common.asm

$(PROJ).EXE:	miscdemo.obj misc.obj common.obj $(OBJS_EXT)
	echo >NUL @<<$(PROJ).crf
miscdemo.obj +
misc.obj +
common.obj +
$(OBJS_EXT)
$(PROJ).EXE

$(LIBS_EXT);
<<
	ilink -a -e "link $(LFLAGS) @$(PROJ).crf" $(PROJ)

run: $(PROJ).EXE
	$(PROJ) $(RUNFLAGS)

