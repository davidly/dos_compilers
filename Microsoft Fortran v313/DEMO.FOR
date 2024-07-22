C     Bubble Sort Demonstration Program
C     Microsoft FORTRAN77
C     4 October 1982
C
C     The main routine reads from the terminal an array
C     of ten real numbers in F8.0 format and calls the
C     subroutine BUBBLE to sort them.
C
      REAL R(10)
      INTEGER I
      WRITE (*,001)
  001 FORMAT(1X,'Bubble Sort Demonstration Program.')
  100 DO 103 I=1,10
      WRITE (*,101) I
  101 FORMAT(1X,'Please input real number no. ',I2)
      READ (*,102) R(I)
  102 FORMAT(F8.0)
  103 CONTINUE
      CALL BUBBLE(R,10)
      WRITE (*,002)
  002 FORMAT(/1X,'The sorted ordering from lowest to highest is:')
      WRITE (*,003) (R(I),I = 1,10)
  003 FORMAT(2(1x,5F13.3/))
      STOP
      END
C
C     Subroutine    BUBBLE   performs   a   bubble   sort   on   a
C     one-dimensional real array of arbitrary  length.   It  sorts
C     the array in asscending order.
      SUBROUTINE BUBBLE(X,J)
      INTEGER J,A1,A2
      REAL X(J),TEMP
  100 IF (J .LE. 1) GOTO 101
  200 DO 201 A1 = 1,J-1
  300 DO 301 A2 = A1 + 1,J
  400 IF (X(A1) .LE. X(A2)) GOTO 401
      TEMP = X(A1)
      X(A1) = X(A2)
      X(A2) = TEMP
  401 CONTINUE
  301 CONTINUE
  201 CONTINUE
  101 CONTINUE
      RETURN
      END
