CC       DEMOEXEC.FOR - Demonstration program for calling C system and
CC       spawnp library functions. These functions are included in the
CC       FORTRAN library. They are discussed in Chapter 3 of the Advanced
CC       Topics manual.
CC
CC       To compile and link DEMOEXEC.FOR type the command:
CC
CC              FL DEMOEXEC.FOR

C
C       Include file containing interfaces for system and spawnlp.
C

$INCLUDE: 'EXEC.FI'

C
C       Declare return types
C
        INTEGER*2 SYSTEM, SPAWNLP

C
C       Invoke COMMAND.COM with the command line:
C
C               dir *.for
C
        I = SYSTEM( 'dir *.for'C )
        IF( I .EQ. -1 ) STOP 'Could not run COMMAND.COM'

C
C       Invoke a child process:
C
C               EXEHDR DEMOEXEC.EXE
C
        I = SPAWNLP( 0, LOC( 'exehdr'C ), LOC( 'exehdr'C ),
     +                  LOC( 'demoexec.exe'C ), INT4( 0 ) )
        IF( I .EQ. -1 ) STOP 'Could not spawn EXEHDR program'
        END
