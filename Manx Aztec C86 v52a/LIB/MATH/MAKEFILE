CC=cc
AS=as
CFLAGS=-n
AFLAGS=-dMODEL=
O=m

.c.$O:
	$(CC) -o $@ $(CFLAGS) $*.c
	sqz $@
.asm.$O:
	$(AS) -o $@ $(AFLAGS) $*.asm
	sqz $@

OBJ=\
	asin.$O fabs.$O floor.$O pow.$O random.$O\
	sinh.$O tanh.$O fpst.$O 

MOBJ=\
	atan.$O exp.$O log.$O sin.$O tan.$O fmod.$O \
	frexp.$O ldexp.$O modf.$O sqrt.$O fsubs.$O


M87OBJ=\
	atan87.$O exp87.$O log87.$O \
	exp1087.$O sin87.$O tan87.$O \
	fmod87.$O chk87.$O frexp87.$O sqrt87.$O \
	isnan.$O fsubs87.$O

MSOBJ=\
	atan.$O exp.$O log.$O sin.$O tan.$O fmod.$O \
	frexp87s.$O sqrt87s.$O fsubs87s.$O 

mlib: $(OBJ) mlib.$O

mlib.m mlib.mlc mlib.mld mlib.ml: $(MOBJ)

mlib.8 mlib.8lc mlib.8ld mlib.8l: $(M87OBJ)

mlib.s mlib.slc mlib.sld mlib.sl: $(MSOBJ)

