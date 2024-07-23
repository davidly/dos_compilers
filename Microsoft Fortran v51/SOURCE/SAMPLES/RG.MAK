#
# RG.MAK - Old-style (non-PWB) makefile for building REALG
#

# Define macros

FOR       = fl
FFLAGS    = /Os
LFLAGS    = /NOI /EXE /FAR /PACKC
LINKER    = link
OBJS      = RGMAIN.OBJ RGINIT.OBJ RGGRID.OBJ RGGRAPH.OBJ
LIBS      = GRAPHICS.LIB
#
# Define the "all" target. In this case, building all consists
# of building REALG.EXE.
#
all: REALG.EXE
#
# Specify what suffixes NMAKE should "know" about
#
.SUFFIXES:
.SUFFIXES: .obj .for
#
# Specify the rule for building REALG.EXE from the object files
# and the libraries.
#
REALG.exe : $(OBJS)
    $(LINKER) $(LFLAGS) $(OBJS),$@,,$(LIBS);
#
# Define the inference rule for making an object file from a
# FORTRAN source file.
#
.for.obj :
        $(FOR) /c $(FFLAGS) /Fo$@ $<
#
# Define the "clean" target. This clean target simply deletes
# some intermediate files that might be clutter after a release
# of an executable file.
#
clean:
    del *.obj
    del *.mdt
    del *.ilk
    del *.sym
