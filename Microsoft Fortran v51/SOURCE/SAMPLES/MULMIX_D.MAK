# MULMIX_D.MAK
# Make file for FORTRAN 5.1 mixed-language example using .DLL

all : mulmix_d.exe mullib.dll


# Update the resource if necessary

mulmix.res : mulmix.rc mulmix.h
    rc /r mulmix.rc


# Update the C object file if necessary

mulmix.obj : mulmix.c mulmix.h
    cl /c /AL /Gsw /Oas /Zpe mulmix.c


# Update the FORTRAN object file if necessary

mulf_d.obj : mulf.for
    fl /c /Gw /Aw /G2 /FoMULF_D.OBJ mulf.for


# Update the C object file if necessary

mulc_d.obj: mulc.c
    cl /c /AL /Gsw /Aw /FoMULC_D.OBJ mulc.c

# Update the .DLL if necessary
mullib.dll : mulf_d.obj mulc_d.obj
    link mulf_d.obj mulc_d.obj , mullib.dll, nul, \
        /NOD /NOE ldllfewc.lib ldllcew.lib libw.lib , mullib.def
    rc mullib.dll


# Update the executable file if necessary, and if so,
# add the resource back in.

mulmix_d.exe : mulmix.obj mulmix_d.def mulmix.res
    link mulmix, mulmix_d.exe, nul, libw /NOD llibcew, mulmix_d.def
    rc mulmix.res mulmix_d.exe
