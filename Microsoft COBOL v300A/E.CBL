       IDENTIFICATION DIVISION.
       PROGRAM-ID. E.
      * 192 digits from the 200-cell factorial spigot.
      * 2-digit blocks use native unsigned binary COMP-5 arithmetic.
      * X and products stay below 20,000, within a 16-bit word.
      * Keep all operands the same size and arithmetic in-place.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 REMAINDERS.
          02 A PIC 9(4) COMP-5 OCCURS 200 TIMES.
       01 X PIC 9(4) COMP-5.
       01 Q PIC 9(4) COMP-5.
       01 R PIC 9(4) COMP-5.
       01 N-N PIC 9(4) COMP-5.
       01 N-I PIC 9(4) COMP-5.
       01 HIGH-I PIC 9(4) COMP-5.
       01 CHUNK-I PIC 9(4) COMP-5.
       01 OUT-I PIC 9(4) COMP-5.
       01 CHUNK PIC 9(3).
       01 CHUNK-VIEW REDEFINES CHUNK.
          02 CHUNK-CHAR PIC X OCCURS 3 TIMES.
       01 RESULT-TEXT PIC X(193).
       01 RESULT-VIEW REDEFINES RESULT-TEXT.
          02 OUT-CHAR PIC X OCCURS 193 TIMES.
       01 RESULT-192 REDEFINES RESULT-TEXT PIC X(192).
       PROCEDURE DIVISION.
       MAIN.
           DISPLAY 'computing e'.
           MOVE 2 TO N-I.
       INIT-A.
           MOVE 1 TO A(N-I).
           ADD 1 TO N-I.
           IF N-I < 201 GO TO INIT-A.
           MOVE 0 TO A(1).
           MOVE 2 TO A(2).
           MOVE 0 TO X.
           MOVE 201 TO HIGH-I.
           MOVE 1 TO OUT-I.
       OUTER-STEP.
           SUBTRACT 2 FROM HIGH-I.
           MOVE HIGH-I TO N-I.
       INNER-STEP.
           MOVE N-I TO N-N.
           MOVE X TO R.
           DIVIDE N-N INTO X.
           MOVE X TO Q.
           MULTIPLY N-N BY X.
           SUBTRACT X FROM R.
           MOVE R TO A(N-I + 1).
           MOVE A(N-I) TO X.
           MULTIPLY 100 BY X.
           ADD Q TO X.
           SUBTRACT 1 FROM N-I.
           IF N-I > 0 GO TO INNER-STEP.
           MOVE X TO CHUNK.
           MOVE 2 TO CHUNK-I.
           IF OUT-I = 1 MOVE 1 TO CHUNK-I.
       COPY-CHUNK.
           MOVE CHUNK-CHAR(CHUNK-I) TO OUT-CHAR(OUT-I).
           ADD 1 TO CHUNK-I.
           ADD 1 TO OUT-I.
           IF CHUNK-I < 4 GO TO COPY-CHUNK.
           IF HIGH-I > 9 GO TO OUTER-STEP.
           DISPLAY RESULT-192.
           DISPLAY 'done'.
           STOP RUN.
