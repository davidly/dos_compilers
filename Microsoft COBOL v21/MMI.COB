       IDENTIFICATION DIVISION.
       PROGRAM-ID. MMI.
      * BYTE magazine October 1982. Jerry Pournelle. Matrix multiply.
      * COBOL has no floating point; this uses packed decimal, which
      * holds the small whole numbers in A, B, and C exactly.
      * Subscripts are binary: COBOL-80 v4.01 faults on packed ones.
      * Expected result: 465880
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 MA.
          02 MA-ROW OCCURS 20 TIMES.
             03 A PIC 9(3) COMP-3 OCCURS 20 TIMES.
       01 MB.
          02 MB-ROW OCCURS 20 TIMES.
             03 B PIC 9(3) COMP-3 OCCURS 20 TIMES.
       01 MC.
          02 MC-ROW OCCURS 20 TIMES.
             03 C PIC 9(5) COMP-3 OCCURS 20 TIMES.
       01 I PIC 99 COMP.
       01 J PIC 99 COMP.
       01 K PIC 99 COMP.
       01 T PIC 99 COMP.
       01 SUMM PIC 9(7) COMP-3.
       01 SUMM-OUT PIC Z(6)9.
       PROCEDURE DIVISION.
       MAIN.
           MOVE 0 TO SUMM.
           PERFORM FILL-A-ROW VARYING I FROM 1 BY 1 UNTIL I > 20.
           PERFORM FILL-B-ROW VARYING I FROM 1 BY 1 UNTIL I > 20.
           PERFORM FILL-C-ROW VARYING I FROM 1 BY 1 UNTIL I > 20.
           PERFORM MULTIPLY-ROW VARYING I FROM 1 BY 1 UNTIL I > 20.
           PERFORM SUM-ROW VARYING I FROM 1 BY 1 UNTIL I > 20.
           MOVE SUMM TO SUMM-OUT.
           DISPLAY 'summ is : ' SUMM-OUT.
           STOP RUN.
       FILL-A-ROW.
           PERFORM FILL-A VARYING J FROM 1 BY 1 UNTIL J > 20.
       FILL-A.
           ADD I J GIVING A(I, J).
       FILL-B-ROW.
           PERFORM FILL-B VARYING J FROM 1 BY 1 UNTIL J > 20.
       FILL-B.
           ADD I J GIVING T.
           DIVIDE J INTO T GIVING B(I, J).
       FILL-C-ROW.
           PERFORM FILL-C VARYING J FROM 1 BY 1 UNTIL J > 20.
       FILL-C.
           MOVE 0 TO C(I, J).
       MULTIPLY-ROW.
           PERFORM MULTIPLY-COL VARYING J FROM 1 BY 1 UNTIL J > 20.
       MULTIPLY-COL.
           PERFORM MULTIPLY-STEP VARYING K FROM 1 BY 1 UNTIL K > 20.
       MULTIPLY-STEP.
           COMPUTE C(I, J) = C(I, J) + A(I, K) * B(K, J).
       SUM-ROW.
           PERFORM SUM-STEP VARYING J FROM 1 BY 1 UNTIL J > 20.
       SUM-STEP.
           ADD C(I, J) TO SUMM.
