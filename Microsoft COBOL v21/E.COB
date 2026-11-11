       IDENTIFICATION DIVISION.
       PROGRAM-ID. E.
      * DIVIDE with REMAINDER avoids separate multiply/subtract steps.
      * Generate 192 digits using the 200-cell factorial spigot.
      * Packed decimal permits 15-digit blocks instead of one digit.
      * X and products stay below 200 * 10^15, within 18 digits.
      * The final block is truncated to the benchmark's 192 digits.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 REMAINDERS.
          02 A PIC 9(3) COMP-3 OCCURS 200 TIMES
             INDEXED BY N-I HIGH-I.
       01 X PIC 9(18) COMP-3.
       01 Q PIC 9(16) COMP-3.
       01 N-N PIC 9(3) COMP-3.
       01 CHUNK PIC 9(16).
       01 CHUNK-VIEW REDEFINES CHUNK.
          02 CHUNK-CHAR PIC X OCCURS 16 TIMES
             INDEXED BY CHUNK-I.
       01 RESULT-TEXT PIC X(196).
       01 RESULT-VIEW REDEFINES RESULT-TEXT.
          02 OUT-CHAR PIC X OCCURS 196 TIMES INDEXED BY OUT-I.
       01 RESULT-192 REDEFINES RESULT-TEXT PIC X(192).
       PROCEDURE DIVISION.
       MAIN.
           DISPLAY 'computing e'.
           SET N-I TO 2.
       INIT-A.
           MOVE 1 TO A(N-I).
           SET N-I UP BY 1.
           IF N-I < 201 GO TO INIT-A.
           MOVE 0 TO A(1).
           MOVE 2 TO A(2).
           MOVE 0 TO X.
           SET HIGH-I TO 214.
           SET OUT-I TO 1.
       OUTER-STEP.
           SET HIGH-I DOWN BY 15.
           SET N-I TO HIGH-I.
       INNER-STEP.
           SET N-N TO N-I.
           DIVIDE X BY N-N GIVING Q
               REMAINDER A(N-I + 1).
           MULTIPLY 1000000000000000 BY A(N-I) GIVING X.
           ADD Q TO X.
           SET N-I DOWN BY 1.
           IF N-I > 0 GO TO INNER-STEP.
           MOVE X TO CHUNK.
           SET CHUNK-I TO 2.
           IF OUT-I = 1 SET CHUNK-I TO 1.
       COPY-CHUNK.
           MOVE CHUNK-CHAR(CHUNK-I) TO OUT-CHAR(OUT-I).
           SET CHUNK-I UP BY 1.
           SET OUT-I UP BY 1.
           IF CHUNK-I < 17 GO TO COPY-CHUNK.
           IF HIGH-I > 19 GO TO OUTER-STEP.
           DISPLAY RESULT-192.
           DISPLAY 'done'.
           STOP RUN.
