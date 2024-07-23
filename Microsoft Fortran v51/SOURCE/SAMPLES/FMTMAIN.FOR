CC  FMTMAIN program to illustrate calling a multithread dynamic link
CC  library routine.  To be linked with FMTDLL.DLL at run time.
CC
CC  Compile FMTMAIN.FOR and link to create an executable file.
CC  FMTMAIN.DEF lists the routines imported from FMTDLL.DLL.
CC
CC  Assuming that the example dynamic-link FORTRAN runtime library is on
CC  your LIBPATH (see FDLLOBJS.CMD), compile with the following command:
CC
CC      FL -MD fmtmain.for frtexe.obj frtlib.lib fmtmain.def
CC
      INTERFACE TO SUBROUTINE dynalibtest [LOADDS] ( i, j )
      INTEGER*4 i, j
      END

      INTEGER*4 init, noinit

      init = 10101010
      WRITE (*,*) 'in main code...'
      WRITE (*,*) 'INIT   = ', init
      WRITE (*,*) 'NOINIT = ', noinit
      WRITE (*,*)
C
C     Call dynamic link library to swap values in arguments.
C
      CALL dynalibtest( init, noinit )

      WRITE (*,*)
      WRITE (*,*) 'back in main code...'
      WRITE (*,*) 'INIT   = ', init
      WRITE (*,*) 'NOINIT = ', noinit
      END
