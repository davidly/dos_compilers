      PROGRAM MMI
C BYTE MAGAZINE OCTOBER 1982. JERRY POURNELLE. MATRIX MULTIPLY.
C VARIOUS BUGS NOT FOUND BECAUSE DIMENSIONS ARE SQUARE FIXED BY DAVID LEE
C INTEGER VERSION: 16-BIT ELEMENTS; THE SUM IS KEPT IN BASE 10000
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), ISH, ISL
      INTEGER*2 A, B, C, ISH, ISL

      INTEGER*2 ID1, ID2, ID3, ID4
      ISH = 0
      ISL = 0
      CALL FILLA
      CALL FILLB
      CALL FILLC
      CALL MATMUL
      CALL SUMMIT

      ID1 = ISL / 1000
      ID2 = MOD( ISL / 100, 10 )
      ID3 = MOD( ISL / 10, 10 )
      ID4 = MOD( ISL, 10 )
      WRITE( *, 1000 ) ISH, ID1, ID2, ID3, ID4
 1000 FORMAT( ' SUMM IS : ', I2, 4I1 )
      STOP
      END

      SUBROUTINE FILLA
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), ISH, ISL
      INTEGER*2 A, B, C, ISH, ISL
      INTEGER*2 I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 A( I, J ) = I + J
      RETURN
      END

      SUBROUTINE FILLB
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), ISH, ISL
      INTEGER*2 A, B, C, ISH, ISL
      INTEGER*2 I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 B( I, J ) = ( I + J ) / J
      RETURN
      END

      SUBROUTINE FILLC
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), ISH, ISL
      INTEGER*2 A, B, C, ISH, ISL
      INTEGER*2 I, J
      DO 10 I = 1, 20
      DO 10 J = 1, 20
   10 C( I, J ) = 0
      RETURN
      END

      SUBROUTINE MATMUL
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), ISH, ISL
      INTEGER*2 A, B, C, ISH, ISL
      INTEGER*2 I, J, K
      DO 10 I = 1, 20
      DO 10 J = 1, 20
      DO 10 K = 1, 20
   10 C( I, J ) = C( I, J ) + A( I, K ) * B( K, J )
      RETURN
      END

      SUBROUTINE SUMMIT
      COMMON /MATS/ A(20,20), B(20,20), C(20,20), ISH, ISL
      INTEGER*2 A, B, C, ISH, ISL
      INTEGER*2 I, J
      DO 20 I = 1, 20
      DO 20 J = 1, 20
      ISL = ISL + C( I, J )
   10 IF ( ISL .LT. 10000 ) GOTO 20
      ISL = ISL - 10000
      ISH = ISH + 1
      GOTO 10
   20 CONTINUE
      RETURN
      END
