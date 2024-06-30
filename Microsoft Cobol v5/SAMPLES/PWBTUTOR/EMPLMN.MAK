#
# EMPLMN.MAK - A simple non-PWB makefile for building
# the PWB tutorial example program of EMPLMAIN.EXE.
#
# NOTE: The LIBS macro assumes the default
#  library name.  If you have installed with different
#  names, you must change the LIBS macro.
 
#
# Macros
#
COBOL =  cobol
COBFLAGS_G =  EDITOR "MS" NOQUERY
COBFLAGS_R = NOBOUND
LFLAGS_G = /BATCH/NOE/NOD
LINKER =  link
OBJS = EMPLMAIN.OBJ EMPLHLTH.OBJ
LIBS = LCOBOL COBAPI
FILES = EMPLMAIN.CBL EMPLHLTH.CBL
 
#
# The "all" target.
# Building 'all' builds EMPLMAIN.EXE.
#
all: EMPLMAIN.EXE
#
# The file suffixes NMAKE  needs to "know" about
# for this project.
#
.SUFFIXES:
.SUFFIXES: .OBJ .CBL
#
# An inference rule to make an object file from a
# COBOL source file.
#
.cbl .obj :
    $(COBOL) $< $(COBFLAGS_G) $(COBFLAGS_R);
 
#
# The description block for building EMPLMAIN.EXE
# from the object files and libraries.
#
EMPLMAIN.EXE : $(OBJS)
    $(LINKER) $(LFLAGS_G) $(OBJS),$@,,$(LIBS);
 
# The 'clean' target. Delete intermediate files
# that might be clutter after a release build
#
clean:
    -del *.obj
    -del *.bak
    -del *.tmp
    -del *.map
