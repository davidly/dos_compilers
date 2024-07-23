CC  The FMHELLO program illustrates how to use multiple threads.
CC
CC  Use this command line to compile:
CC
CC      FL -MT fmhello.for
CC
CC  Or build the FORTRAN run-time DLL (using the FDLLOBJS batch file)
CC  and compile with this command:
CC
CC      FL -MD fmhello.for frtexe.obj frtlib.lib
CC
CC  To run, specify the number of times you want each thread to say
CC  hello. For example, to start three threads speaking 5, 7, and 9
CC  times, respectively, use this command:
CC
CC      FMHELLO 5 7 9
CC

      INTERFACE TO INTEGER*2 FUNCTION BEGINTHREAD(rtn, stk, size, arg)
      INTEGER*4 rtn [value]
      INTEGER*1 stk(*)
      INTEGER*4 size
      INTEGER*4 arg
      END

      INTERFACE TO INTEGER*2 FUNCTION DosSleep( time )
      INTEGER*4 time [value]
      END

CC    Routine for each thread to say 'hello world'
CC
      SUBROUTINE child( loopcnt )

      INTEGER*4 loopcnt
      INTEGER*4 i, result(2:32)
      INTEGER*2 DosSleep, threadid, tid
      LOGICAL*2 ready
      AUTOMATIC tid, i
      COMMON    ready, result

      tid = threadid()

      DO WHILE( .NOT. ready )
         i = DosSleep( 0 )
      END DO

      DO i = 1, loopcnt
         WRITE (*,*) 'Hello world from thread ', tid
      END DO

C
C     Let the main program (thread 1) know thread is done.
C
      result(tid) = 1
      END


CC    Main code to launch threads.
CC
      INTEGER*4    result(2:32), hellocnt(31)
      INTEGER*2    i, next, lastid, rc
      INTEGER*2    BEGINTHREAD, DosSleep
      INTEGER*1    stack [allocatable](:,:)
      LOGICAL*2    ready
      CHARACTER*10 argbuf
      EXTERNAL     child
      COMMON       ready, result

      i = NARGS() - 1
      IF( i .GE. 32) STOP 'Error: Too many arguments'

C
C     Allocate a 2K stack for each thread specified on the command line.
C
      IF( i .GT. 0) ALLOCATE( stack(2048, i) )
C
C     Bring up one thread for each argument.
C
      ready  = .FALSE.
      lastid = 0

      DO next = 1, i
         CALL GETARG( next, argbuf, rc )
         READ (argbuf, '(I10)') hellocnt(next)
C
C        Bring up the new thread and pass the corresponding argument.
C
         rc = BEGINTHREAD( LOCFAR( child ),
     +                     stack(1,next),
     +                     2048,
     +                     hellocnt(next) )

C
C        Keep track of how many threads were brought up.
C
         IF( rc .GT. lastid ) lastid = rc

      END DO

C
C     Tell the user how many threads were brought up.
C
      WRITE (*,*) 'Number of threads = ', next - 1
      WRITE (*,*) 'Maximum thread ID = ', lastid

C
C     Let the threads begin execution and wait for them to complete.
C
      ready = .TRUE.

      DO j = 1, next - 1
         i = 2
C
C        Check until a thread signals completion.  Clear flag and
C        start over, until all threads have finished.
C
         DO WHILE( result(i) .EQ. 0 )
            rc = DosSleep( 0 )
            i  = i + 1
            IF( i .GT. lastid ) i = 2
         END DO
         result(i) = 0
      END DO

      END
