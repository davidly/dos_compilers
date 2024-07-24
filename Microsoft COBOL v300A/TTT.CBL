         IDENTIFICATION DIVISION.
         PROGRAM-ID.  TTT.
      *  REMARKS. prove tic-tac-toe is not winnable against a good foe.
         ENVIRONMENT DIVISION.
         CONFIGURATION SECTION.
         DATA DIVISION.
         WORKING-STORAGE SECTION.
         01 BOARD.
             05 B PIC 9(04) COMP OCCURS 9 TIMES.
             05 VALST PIC 9(04) COMP OCCURS 10 TIMES.
             05 ALPHAST PIC 9(04) COMP OCCURS 10 TIMES.
             05 BETAST PIC 9(04) COMP OCCURS 10 TIMES.
             05 XST PIC 9(04) COMP OCCURS 10 TIMES.
             05 PMST PIC 9(04) COMP OCCURS 10 TIMES.
         01 MOVECOUNT PIC 9(04) COMP VALUE 0.
         01 DEPTH PIC 9(04) COMP VALUE 0.
         01 NUM-DISP PIC 9999.
         01 ITER PIC 9(04) COMP VALUE 0.
         01 WI PIC 9(04) COMP VALUE 0.
         01 VAL PIC 9(04) COMP VALUE 0.
         01 T PIC 9(04) COMP VALUE 0.
         01 D PIC 9(04) COMP VALUE 0.
         01 M PIC 9(04) COMP VALUE 0.
         01 X PIC 9(04) COMP VALUE 0.
         01 PM PIC 9(04) COMP VALUE 0.
         01 SC PIC 9(04) COMP VALUE 0.
         01 Z PIC 9(04) COMP VALUE 0.
         01 ALPHA PIC 9(04) COMP VALUE 0.
         01 BETA PIC 9(04) COMP VALUE 0.
         01 FIRSTMOVE PIC 9(04) COMP VALUE 0.

         PROCEDURE DIVISION.
         MAIN.
             DISPLAY 'hello from cobol'.
             MOVE 1 TO ITER.
         INITBOARD.
             MOVE 0 TO B( ITER ).
             ADD 1 TO ITER.
             IF ITER < 10 GO TO INITBOARD.

             MOVE 0 TO ITER.
         NEXTITER.
             MOVE 0 TO MOVECOUNT.
             MOVE 1 TO FIRSTMOVE.
             PERFORM RUNMM.
             MOVE 2 TO FIRSTMOVE.
             PERFORM RUNMM.
             MOVE 5 TO FIRSTMOVE.
             PERFORM RUNMM.
             ADD 1 TO ITER.
             IF ITER < 10 GO TO NEXTITER.

             DISPLAY 'final move count and winner: '.
             MOVE MOVECOUNT TO NUM-DISP.
             DISPLAY NUM-DISP.
             MOVE SC TO NUM-DISP.
             DISPLAY NUM-DISP.

             STOP RUN.

         RUNMM.
             MOVE 1 TO B( FIRSTMOVE ).
             MOVE FIRSTMOVE TO X
             MOVE 2 TO ALPHA
             MOVE 9 TO BETA
             PERFORM MINMAX.
             MOVE 0 TO B( FIRSTMOVE ).

         WINNER.
             MOVE 0 TO WI.
             MOVE B( 1 ) TO T.
             IF 0 NOT = T AND T=B(2) AND T=B(3) MOVE T TO WI
             ELSE IF 0 NOT= T AND  T=B(4) AND T=B(7) MOVE T TO WI.

             IF 0 = WI
               MOVE B(2) TO T
               IF 0 NOT= T AND T=B(5) AND T=B(8) MOVE T TO WI
               ELSE
                 MOVE B(3) TO T
                 IF 0 NOT= T AND T=B(6) AND T=B(9) MOVE T TO WI
                 ELSE
                   MOVE B(4) TO T
                   IF 0 NOT= T AND T=B(5) AND T=B(6) MOVE T TO WI
                   ELSE
                     MOVE B(7) TO T
                     IF 0 NOT= T AND T=B(8) AND T=B(9) MOVE T TO WI
                     ELSE
                       MOVE B(5) TO T
                       IF 0 NOT= T AND T=B(1) AND T=B(9) MOVE T TO WI
                       ELSE
                         IF 0 NOT= T AND T=B(3) AND T=B(7) MOVE T TO WI.

         SHOWPOS.
             MOVE B(Z) TO NUM-DISP.
             DISPLAY NUM-DISP.

         SHOWBOARD.
             DISPLAY 'board: '.
             PERFORM SHOWPOS VARYING Z FROM 1 BY 1 UNTIL Z>9.

         INITVALPM.
             DIVIDE DEPTH BY 2 GIVING D.
             MULTIPLY D BY 2 GIVING M.

             IF DEPTH NOT = M
                 MOVE 2 TO VAL
                 MOVE 1 TO PM
             ELSE
                 MOVE 9 TO VAL
                 MOVE 2 TO PM.

         MINMAX.
             ADD 1 TO MOVECOUNT.
             MOVE 0 TO VAL.

             IF DEPTH > 3
                 PERFORM WINNER
                 IF WI NOT = 0
                     IF WI = 1 MOVE 6 TO VAL ELSE MOVE 4 TO VAL
                 ELSE IF DEPTH = 8 MOVE 5 TO VAL.

             IF 0 = VAL
                 PERFORM INITVALPM

                 ADD 1 TO DEPTH
                 PERFORM MAKEMOVE VARYING X FROM 1 BY 1 UNTIL (X>9)
                 SUBTRACT 1 FROM DEPTH.

             MOVE VAL TO SC.

         UPDATEODD.
                 IF SC = 6 MOVE 10 TO X.
                 IF SC > VAL MOVE SC TO VAL.
                 IF VAL NOT < BETA MOVE 10 TO X.
                 IF VAL > ALPHA MOVE VAL TO ALPHA.

         UPDATEEVEN.
                 IF SC = 4 MOVE 10 TO X.
                 IF SC < VAL MOVE SC TO VAL.
                 IF VAL NOT > ALPHA MOVE 10 TO X.
                 IF VAL < BETA MOVE VAL TO BETA.

         UPDATESTATE.
                 IF PM = 1 PERFORM UPDATEODD
                 ELSE PERFORM UPDATEEVEN.
  
         MAKEMOVE.
             IF B( X ) = 0
                 MOVE PM TO B( X )

                 MOVE VAL TO VALST( DEPTH )
                 MOVE X TO XST( DEPTH )
                 MOVE PM TO PMST( DEPTH )
                 MOVE ALPHA TO ALPHAST( DEPTH )
                 MOVE BETA TO BETAST( DEPTH )

                 PERFORM MINMAX

                 MOVE BETAST( DEPTH ) TO BETA
                 MOVE ALPHAST( DEPTH ) TO ALPHA
                 MOVE PMST( DEPTH ) TO PM
                 MOVE XST( DEPTH ) TO X
                 MOVE VALST( DEPTH ) TO VAL

                 MOVE 0 TO B( X )

                 PERFORM UPDATESTATE.

