PROJ	=GRDEMO
DEBUG	=1
CC	=qcl
CFLAGS_G	=
CFLAGS_D	=/Od /Gi$(PROJ).mdt /Zi /Zr
CFLAGS_R	=/O /DNDEBUG
CFLAGS	=$(CFLAGS_G) $(CFLAGS_D)
LFLAGS_G	=/NOI
LFLAGS_D	=/INCR /CO
LFLAGS_R	=
LFLAGS	=$(LFLAGS_G) $(LFLAGS_D)
RUNFLAGS	=
OBJS_EXT = 	
LIBS_EXT = 	

all:	$(PROJ).exe

grdemo.obj:	grdemo.c

menu.obj:	menu.c

turtle.obj:	turtle.c

$(PROJ).exe:	grdemo.obj menu.obj turtle.obj $(OBJS_EXT)
	echo >NUL @<<$(PROJ).crf
grdemo.obj +
menu.obj +
turtle.obj +
$(OBJS_EXT)
$(PROJ).exe

$(LIBS_EXT);
<<
	ilink -a -e "link $(LFLAGS) @$(PROJ).crf" $(PROJ)

run: $(PROJ).exe
	$(PROJ) $(RUNFLAGS)

