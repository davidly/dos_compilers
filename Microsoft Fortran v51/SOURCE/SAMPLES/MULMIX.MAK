# MULMIX.MAK
# Make file for statically-linked FORTRAN 5.1
# mixed-language example

all : mulmix.exe


# Update the resource if necessary

mulmix.res : mulmix.rc mulmix.h
    rc /r mulmix.rc


# Update the C object file if necessary

mulmix.obj : mulmix.c mulmix.h
    cl /c /AL /Gsw /Oas /Zpe /FPc mulmix.c


# Update the FORTRAN object file if necessary

mulf.obj : mulf.for
    fl /c /G2 /FoMULF.OBJ mulf.for


# Update the C object file if necessary

mulc.obj : mulc.c
    cl /c /AL /Gsw /Oas /Zpe /FPc mulc.c

# Update the executable file if necessary, and if so,
# add the resource back in.

mulmix.exe : mulmix.obj mulf.obj mulc.obj mulmix.def mulmix.res
    link mulmix mulf mulc, mulmix.exe, nul, \
      libw /NOD /NOE llibfewc llibcew noqwin, mulmix.def
    rc mulmix.res mulmix.exe

