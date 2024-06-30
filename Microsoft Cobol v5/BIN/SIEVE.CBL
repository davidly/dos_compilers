         IDENTIFICATION DIVISION.
         PROGRAM-ID.  SIEVE.
      *  REMARKS. BYTE magazine benchmark.
      *  REMARKS. MS Cobol limits array sizes to 1023.
      *  REMARKS. Projected runtime for 8190 is 4853 seconds.
         ENVIRONMENT DIVISION.
         CONFIGURATION SECTION.
         DATA DIVISION.
         WORKING-STORAGE SECTION.
         01 MISC.
             03 I PIC 9(4) COMP.
             03 PRIME PIC 9(5) COMP.
             03 K PIC 9(4) COMP.
             03 TOTAL-PRIME-COUNT PIC 9(4) COMP.
         02 SIEVETABLE.
             04 FLAGS PIC 9 COMP OCCURS 8191 TIMES.
         01 NUM-DISP PIC 9999.

         PROCEDURE DIVISION.
         MAIN.
             PERFORM ITER-ROUTINE 10 TIMES.
             MOVE TOTAL-PRIME-COUNT TO NUM-DISP.
             DISPLAY NUM-DISP ' primes'.
             STOP RUN.

         ITER-ROUTINE.
             MOVE ZEROES TO TOTAL-PRIME-COUNT.
             PERFORM TFR VARYING I FROM 1 BY 1 UNTIL I = 8191.
             PERFORM DCP THRU DCE VARYING I FROM 0 BY 1 UNTIL I = 8190.

         TFR.
             MOVE 1 TO FLAGS(I).
             
         DCP.
             IF FLAGS( I + 1 ) = 0
                 GO TO DCE.
             COMPUTE PRIME = I + I + 3.
             COMPUTE K = I + PRIME.

         FIRST1.
             IF K > 8190 GO TO NEXT1.
             MOVE 0 TO FLAGS( K + 1 ).
             COMPUTE K = PRIME + K.
             GO TO FIRST1.

         NEXT1.
             ADD 1 TO TOTAL-PRIME-COUNT.
      *       MOVE PRIME TO NUM-DISP.
      *       DISPLAY 'FOUND PRIME = ' NUM-DISP.

         DCE.
             EXIT.

