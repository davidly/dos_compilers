      PROGRAM MM
C BYTE MAGAZINE OCTOBER 1982. JERRY POURNELLE. MATRIX MULTIPLY.
C VARIOUS BUGS NOT FOUND BECAUSE DIMENSIONS ARE SQUARE FIXED BY DAVID LEE
C A AND B HOLD SMALL WHOLE NUMBERS, SO THE SUM IS EXACTLY 465880
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), SUMM
      REAL A, B, C, SUMM

      SUMM = 0.0
      CALL FILLA
      CALL FILLB
      CALL FILLC
      CALL MATMUL
      CALL SUMMIT

      WRITE( *, 1000 ) SUMM
      IF ( SUMM .EQ. 465880.0 ) WRITE( *, 1001 )
 1000 FORMAT( ' SUMM IS : ', F10.1 )
 1001 FORMAT( ' SUMM IS EXACTLY 465880' )
      STOP
      END

      SUBROUTINE FILLA
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), SUMM
      REAL A, B, C, SUMM
      INTEGER I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 A( I, J ) = I + J
      RETURN
      END

      SUBROUTINE FILLB
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), SUMM
      REAL A, B, C, SUMM
      INTEGER I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 B( I, J ) = ( I + J ) / J
      RETURN
      END

      SUBROUTINE FILLC
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), SUMM
      REAL A, B, C, SUMM
      INTEGER I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 C( I, J ) = 0.0
      RETURN
      END

      SUBROUTINE MATMUL
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), SUMM
      REAL A, B, C, SUMM
      INTEGER I, J, K
      DO 10 I = 1, 20
      DO 10 J = 1, 20
      DO 10 K = 1, 20
   10 C( I, J ) = C( I, J ) + A( I, K ) * B( K, J )
      RETURN
      END

      SUBROUTINE SUMMIT
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), SUMM
      REAL A, B, C, SUMM
      INTEGER I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 SUMM = SUMM + C( I, J )
      RETURN
      END
