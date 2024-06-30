      $set ans85 noosvs mf

        PROGRAM-ID. DIOPHANT.
      ******************************************************************
      *
      *              (C) Micro Focus Ltd. 1989
      *
      *                     DIOPHANT.CBL
      *
      * DIOPHANTINE - solve linear equation Ax + By = C
      *                 for integers x and y.
      *
      * Method:
      *         if A > B
      *             swap A and B
      *         fi
      *
      *         when A = 0
      *             set x = 0, y = C/B as solution, and fail if non-integer
      *         when A = 1
      *             set x = C, y = 0 as solution
      *         otherwise
      *             let D = largest integer < (B/A)
      *             let E = largets integer < (C/A)
      *             let F = B - A*D
      *             let G = C - A*E
      *             then Ax + By = C becomes
      *                 Ax + (F + A*D)y = (G + A*E)
      *             so   x + (F/A + D)y = (G/A + E)
      *             and (F/A)y + v = G/A   (since everything else is integral)
      *             so solve
      *                 Fy + Av = G for integers y and v
      *
      *             in COBOL terms:
      *
      *             divide B by A giving D remainder F
      *             divide C by A giving E remainder G
      *             solve Av + Fw = G for integers v and w
      *             set x = E - Dw + v, y = w as solution
      *
      *         if swapped
      *             swap x and y
      *         fi
      *
      *
      ******************************************************************
        WORKING-STORAGE SECTION.
        01  InitA   PIC s9(9) comp-5.
        01  InitB   PIC s9(9) comp-5.
        01  InitC   PIC s9(9) comp-5.
        01  SolvX   PIC s9(9) comp-5.
        01  SolvY   PIC s9(9) comp-5.
        01  FailFg  PIC X.
            88      OK  VALUE 'Y'.
            88      BAD VALUE 'N'.
            88      TRY VALUE '?'.
        LOCAL-STORAGE SECTION.
        01  D       PIC s9(9) comp-5.
        01  E       PIC s9(9) comp-5.
        01  F       PIC s9(9) comp-5.
        01  G       PIC s9(9) comp-5.
        01  V       PIC s9(9) comp-5.
        01  TEMP    PIC s9(9) comp-5.
        LINKAGE SECTION.
        01  A       PIC s9(9) comp-5.
        01  B       PIC s9(9) comp-5.
        01  C       PIC s9(9) comp-5.
        01  X       PIC s9(9) comp-5.
        01  Y       PIC s9(9) comp-5.
        PROCEDURE DIVISION.
        MAIN SECTION.
            DISPLAY "Solve Ax + By = C for integers x and y"
            DISPLAY "Enter value for A: " with no advancing
            ACCEPT InitA
            DISPLAY "Enter value for B: " with no advancing
            ACCEPT InitB
            DISPLAY "Enter value for C: " with no advancing
            ACCEPT InitC
            SET TRY TO TRUE
            CALL 'SOLVE' USING BY VALUE InitA InitB InitC
                               BY REFERENCE SolvX SolvY

            IF OK
                DISPLAY "Solution is: x = " SolvX ", y = " SolvY
            ELSE
                DISPLAY "No Solution exists."
            END-IF
            STOP RUN.

        SOLVE-DIOPHANTINE SECTION.
        ENTRY 'SOLVE' USING BY VALUE A B C BY REFERENCE X Y.

            IF A > B
      *     Use TEMP as a flag to indicate swapped or not.
                MOVE 1 TO TEMP
                CALL 'SWAP2' USING A B
            ELSE
                MOVE 0 TO TEMP
            END-IF

            EVALUATE A
                WHEN 0
                    DIVIDE C BY B GIVING D REMAINDER E
                    IF E = 0
                        MOVE 0 TO X
                        MOVE D TO Y
                        SET OK TO TRUE
                    ELSE
      *     No solution exists.
                        SET BAD TO TRUE
                        MOVE 0 TO X, Y
                    END-IF

                WHEN 1
                    MOVE C TO X
                    MOVE 0 TO Y
                    SET OK TO TRUE

                WHEN OTHER
      *     We must delve deeper to find a solution.
                    DIVIDE B BY A GIVING D REMAINDER F
                    DIVIDE C BY A GIVING E REMAINDER G

                    CALL 'SOLVE' USING BY VALUE A F G BY REFERENCE v Y

                    COMPUTE X = E - ( D * Y ) + v

            END-EVALUATE

            IF TEMP = 1
                CALL 'SWAP2' USING X Y
            END-IF

            EXIT PROGRAM.


      * Second level program to swap 2 variables using local temp variable.
        SWAPPER SECTION.
        ENTRY 'SWAP2' USING X Y.
            MOVE X    TO TEMP
            MOVE Y    TO X
            MOVE TEMP TO Y
            EXIT PROGRAM.
