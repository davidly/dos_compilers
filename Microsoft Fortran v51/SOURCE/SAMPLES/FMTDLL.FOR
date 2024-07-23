CC  FMTDLL dynamic link library.  To be linked with FMTMAIN at run time.
CC
CC  Compile FMTDLL.FOR and link to create a dynamic-link-library.
CC  FMTDLL.DEF lists the routines which FMTDLL.DLL will export.
CC
CC  Assuming that the example dynamic-link FORTRAN runtime library is on
CC  your LIBPATH (see FDLLOBJS.CMD), compile with the following command:
CC
CC      FL -MD -Fefmtdll.dll fmtdll.for frtdll.obj frtlib.lib fmtdll.def
CC
CC  Note that this example DLL requires runtime support.
CC  If the WRITE statement is removed, then specification of a dynamically
CC  linked FORTRAN runtime library on the above command-line is unneccesary.
CC

      SUBROUTINE dynalibtest [LOADDS] ( a1, a2 )

      INTEGER*4 a1, a2
      INTEGER*4 temp

      WRITE (*,*) 'inside dynalibtest()...swapping arguments'

C
C     Swap the values of the arguments.
C
      temp = a1
      a1   = a2
      a2   = temp
      END
