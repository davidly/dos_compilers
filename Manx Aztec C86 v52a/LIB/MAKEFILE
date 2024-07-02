N=
TARG=clib
CC=cc
AS=as
# -n for no debug info
# +y for no $begin refs
CFLAGS=-n +y
AFLAGS=
O=o

#
# default action:
# make all versions of all libraries:
#
all:	c_all m_all m87_all ms_all s_all g_all

#
# for making C libraries:
#
c_all:		c clc cld cl

c:
	make LIB=c   TARG=clib O=o   "CFLAGS=$(CFLAGS)"     "AFLAGS=-dMODEL=" \
		clib
clc:
	make LIB=clc TARG=clib O=olc "CFLAGS=$(CFLAGS) +lc" "AFLAGS=-dMODEL=1" \
		clib
cld:
	make LIB=cld TARG=clib O=old "CFLAGS=$(CFLAGS) +ld" "AFLAGS=-dMODEL=2" \
		clib
cl:
	make LIB=cl  TARG=clib O=ol  "CFLAGS=$(CFLAGS) +l"  "AFLAGS=-dMODEL=3" \
		clib

#
# for making IEEE software emulation math libraries:
#
m_all:		m mlc mld ml

m:
	make LIB=m   CC=$(CC) TARG=mlib O=m \
		"CFLAGS=$(CFLAGS) -dFLOAT" AFLAGS= mlib
mlc:
	make LIB=mlc CC=$(CC) TARG=mlib O=mlc \
		"CFLAGS=$(CFLAGS) +lc -dFLOAT" "AFLAGS=-dMODEL=1" mlib
mld:
	make LIB=mld CC=$(CC) TARG=mlib O=mld \
		"CFLAGS=$(CFLAGS) +ld -dFLOAT" "AFLAGS=-dMODEL=2" mlib
ml:
	make LIB=ml  CC=$(CC) TARG=mlib O=ml \
		"CFLAGS=$(CFLAGS) +l -dFLOAT"  "AFLAGS=-dMODEL=3" mlib

#
# for making 8087 math libraries:
#
m87_all:	m87 m87lc m87ld m87l

m87:
	make LIB=m87  CC=$(CC) TARG=mlib O=8 \
		"CFLAGS=$(CFLAGS) +e -dFLOAT" "AFLAGS=-dMODEL=" mlib
m87lc:
	make LIB=m87lc CC=$(CC) TARG=mlib O=8lc \
		"CFLAGS=$(CFLAGS) +e +lc -dFLOAT" "AFLAGS=-dMODEL=1" mlib
m87ld:
	make LIB=m87ld CC=$(CC) TARG=mlib O=8ld \
		"CFLAGS=$(CFLAGS) +e +ld -dFLOAT" "AFLAGS=-dMODEL=2" mlib
m87l:
	make LIB=m87l  CC=$(CC) TARG=mlib O=8l \
		"CFLAGS=$(CFLAGS) +e +l -dFLOAT" "AFLAGS=-dMODEL=3" mlib
#
# for making sensing math libraries:
#
ms_all:	ms mslc msld msl

ms:
	make LIB=ms  CC=$(CC) TARG=mlib O=s \
		"CFLAGS=$(CFLAGS) -dFLOAT" "AFLAGS=-dMODEL=" mlib
mslc:
	make LIB=mslc CC=$(CC) TARG=mlib O=slc \
		"CFLAGS=$(CFLAGS) +lc -dFLOAT" "AFLAGS=-dMODEL=1" mlib
msld:
	make LIB=msld CC=$(CC) TARG=mlib O=sld \
		"CFLAGS=$(CFLAGS) +ld -dFLOAT" "AFLAGS=-dMODEL=2" mlib
msl:
	make LIB=msl  CC=$(CC) TARG=mlib O=sl \
		"CFLAGS=$(CFLAGS) +l -dFLOAT" "AFLAGS=-dMODEL=3" mlib

#
# make screen libraries:
#
s_all:		s slc sld sl

s:
	make LIB=s   TARG=slib O=o   "CFLAGS=$(CFLAGS)"     "AFLAGS=-dMODEL=" \
		slib
slc:
	make LIB=slc TARG=slib O=olc "CFLAGS=$(CFLAGS) +lc" "AFLAGS=-dMODEL=1" \
		slib
sld:
	make LIB=sld TARG=slib O=old "CFLAGS=$(CFLAGS) +ld" "AFLAGS=-dMODEL=2" \
		slib
sl:
	make LIB=sl  TARG=slib O=ol  "CFLAGS=$(CFLAGS) +l"  "AFLAGS=-dMODEL=3" \
		slib

#
# make graphics libraries:
#
g_all:		g glc gld gl

g:
	make LIB=g   TARG=glib O=o   "CFLAGS=$(CFLAGS)"     "AFLAGS=-dMODEL=" \
		glib
glc:
	make LIB=glc TARG=glib O=olc "CFLAGS=$(CFLAGS) +lc" "AFLAGS=-dMODEL=1" \
		glib
gld:
	make LIB=gld TARG=glib O=old "CFLAGS=$(CFLAGS) +ld" "AFLAGS=-dMODEL=2" \
		glib
gl:
	make LIB=gl  TARG=glib O=ol  "CFLAGS=$(CFLAGS) +l"  "AFLAGS=-dMODEL=3" \
		glib

#
# delete object modules:
#
all_clean:	c_all_clean m_all_clean ms_all_clean m87_all_clean \
	g_all_clean s_all_clean

c_all_clean: c_clean clc_clean cld_clean cl_clean

c_clean:
	make O=o cclean
clc_clean:
	make O=olc cclean
cld_clean:
	make O=old cclean
cl_clean:
	make O=ol cclean

m_all_clean:	m_clean mlc_clean mld_clean ml_clean

m_clean:
	make O=m mclean
mlc_clean:
	make O=mlc mclean
mld_clean:
	make O=mld mclean
ml_clean:
	make O=ml mclean

m87_all_clean:	m87_clean m87lc_clean m87ld_clean m87l_clean

m87_clean:
	make O=8 mclean
m87lc_clean:
	make O=8lc mclean
m87ld_clean:
	make O=8ld mclean
m87l_clean:
	make O=8l mclean

ms_all_clean:	ms_clean mslc_clean msld_clean msl_clean

ms_clean:
	make O=s mclean
mslc_clean:
	make O=slc mclean
msld_clean:
	make O=sld mclean
msl_clean:
	make O=sl mclean

g_all_clean: g_clean glc_clean gld_clean gl_clean

g_clean:
	make O=o gclean
glc_clean:
	make O=olc gclean
gld_clean:
	make O=old gclean
gl_clean:
	make O=ol gclean

s_all_clean: s_clean slc_clean sld_clean sl_clean

s_clean:
	make O=o sclean
slc_clean:
	make O=olc sclean
sld_clean:
	make O=old sclean
sl_clean:
	make O=ol sclean

##############################################################################
# The following dependencies (clib, mlib, m87lib, cclean, mclean, m87clean)
# are used when make re-invokes itself. i.e. when you type "make c"
# make invokes make again to create clib, with appropriate macros defined.
# Don't try to make these directly.
#
clib:
	cd 86sup
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\dos
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\misc
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\rom86
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\stdio
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\stdlib
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\string
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\sysio
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\time
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\inp
	del $(LIB).out
	make $N LIB=$(LIB) O=$O
	cd ..

mlib:
	cd stdlib
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\stdio
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS) -DFLOAT" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\time
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\math
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\inp
	del $(LIB).out
	make $N LIB=$(LIB)
	cd ..

slib:
	cd screen
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\inp
	del $(LIB).out
	make $N LIB=$(LIB) O=$O
	cd ..

glib:
	cd graphics
	make $N CC=$(CC) AS=$(AS) "CFLAGS=$(CFLAGS)" "AFLAGS=$(AFLAGS)" O=$O $(TARG)
	cd ..\inp
	del $(LIB).out
	make $N LIB=$(LIB) O=$O
	cd ..

cclean:
	del 86sup\*.$O
	del dos\*.$O
	del misc\*.$O
	del rom86\*.$O
	del stdio\*.$O
	del stdlib\*.$O
	del sysio\*.$O
	del time\*.$O

mclean:
	del math\*.$O 
	del stdlib\*.$O 
	del stdio\*.$O 
	del time\*.$O 

gclean:
	del graphics\*.$O

sclean:
	del screen\*.$O
