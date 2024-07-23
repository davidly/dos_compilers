C MULF.FOR

      SUBROUTINE MUL(Num1 [VALUE], Num2 [VALUE])
      INTEGER*4 Num1, Num2
      INTEGER*4 Result

      Result = Num1 * Num2

      CALL PRINTRESULTS( Num1, Num2, Result )

      END
