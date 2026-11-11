       IDENTIFICATION DIVISION.
       PROGRAM-ID. TTT.
      * MS-DOS COBOL 2.1 does not support recursive PERFORM.
      * Search uses an explicit stack and declared binary indexes.
      * Character scores and fixed square aliases avoid numeric
      * conversions and constant subscript work in winner checks.
      * Alpha-beta pruning and ascending move order are unchanged.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 BOARD-TEXT PIC X(9).
       01 BOARD-DATA REDEFINES BOARD-TEXT.
          02 B PIC X OCCURS 9 TIMES INDEXED BY POS-I FIRST-I.
       01 WIN-BOARD REDEFINES BOARD-TEXT.
          02 B1 PIC X.
          02 B2 PIC X.
          02 B3 PIC X.
          02 B4 PIC X.
          02 B5 PIC X.
          02 B6 PIC X.
          02 B7 PIC X.
          02 B8 PIC X.
          02 B9 PIC X.
       01 SEARCH-STACK.
          02 FRAME OCCURS 9 TIMES INDEXED BY DEPTH-I.
             03 SAVED-ALPHA PIC X.
             03 SAVED-BETA PIC X.
             03 SAVED-VALUE PIC X.
             03 SAVED-POS PIC S9(4) COMP-0.
       01 COUNTER-INDEXES.
          02 COUNTER-BYTE PIC X OCCURS 2 TIMES
             INDEXED BY COUNT-I.
       01 ALPHA-I PIC X.
       01 BETA-I PIC X.
       01 VALUE-I PIC X.
       01 SCORE-I PIC X.
       01 LAST-N PIC S9(4) COMP-0.
       01 NUMBER-N PIC S9(4) COMP-0.
       01 NUM-DISP PIC 9999.
       01 PM PIC X.
       01 TEST-PIECE PIC X.
       PROCEDURE DIVISION.
       MAIN.
           DISPLAY 'hello from cobol'.
           MOVE ALL '0' TO BOARD-TEXT.
           SET COUNT-I TO 0.
           SET FIRST-I TO 1.
           PERFORM RUN-SEARCH THRU SEARCH-DONE.
           IF SCORE-I NOT = '5' GO TO BAD-SCORE.
           SET FIRST-I TO 2.
           PERFORM RUN-SEARCH THRU SEARCH-DONE.
           IF SCORE-I NOT = '5' GO TO BAD-SCORE.
           SET FIRST-I TO 5.
           PERFORM RUN-SEARCH THRU SEARCH-DONE.
           IF SCORE-I NOT = '5' GO TO BAD-SCORE.
           DISPLAY 'final move count and winner: '.
           SET NUMBER-N TO COUNT-I.
           MOVE NUMBER-N TO NUM-DISP.
           DISPLAY NUM-DISP.
           DISPLAY '000' SCORE-I.
           STOP RUN.
       BAD-SCORE.
           DISPLAY 'BUG SOMEWHERE; SCORE NOT TIE'.
           STOP RUN.
       RUN-SEARCH.
           MOVE '1' TO B(FIRST-I).
           SET LAST-N TO FIRST-I.
           SET DEPTH-I TO 1.
           MOVE '2' TO ALPHA-I.
           MOVE '9' TO BETA-I.
           MOVE '2' TO PM.
       ENTER-NODE.
           SET COUNT-I UP BY 1.
           IF DEPTH-I < 5 GO TO INIT-NODE.
           GO TO WIN-1 WIN-2 WIN-3 WIN-4 WIN-5 WIN-6
               WIN-7 WIN-8 WIN-9 DEPENDING ON LAST-N.
       WIN-1.
           MOVE B1 TO TEST-PIECE.
           IF TEST-PIECE = B2 AND TEST-PIECE = B3
               GO TO FOUND-WIN.
           IF TEST-PIECE = B4 AND TEST-PIECE = B7
               GO TO FOUND-WIN.
           IF TEST-PIECE = B5 AND TEST-PIECE = B9
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-2.
           MOVE B2 TO TEST-PIECE.
           IF TEST-PIECE = B1 AND TEST-PIECE = B3
               GO TO FOUND-WIN.
           IF TEST-PIECE = B5 AND TEST-PIECE = B8
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-3.
           MOVE B3 TO TEST-PIECE.
           IF TEST-PIECE = B1 AND TEST-PIECE = B2
               GO TO FOUND-WIN.
           IF TEST-PIECE = B6 AND TEST-PIECE = B9
               GO TO FOUND-WIN.
           IF TEST-PIECE = B5 AND TEST-PIECE = B7
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-4.
           MOVE B4 TO TEST-PIECE.
           IF TEST-PIECE = B5 AND TEST-PIECE = B6
               GO TO FOUND-WIN.
           IF TEST-PIECE = B1 AND TEST-PIECE = B7
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-5.
           MOVE B5 TO TEST-PIECE.
           IF TEST-PIECE = B4 AND TEST-PIECE = B6
               GO TO FOUND-WIN.
           IF TEST-PIECE = B2 AND TEST-PIECE = B8
               GO TO FOUND-WIN.
           IF TEST-PIECE = B1 AND TEST-PIECE = B9
               GO TO FOUND-WIN.
           IF TEST-PIECE = B3 AND TEST-PIECE = B7
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-6.
           MOVE B6 TO TEST-PIECE.
           IF TEST-PIECE = B4 AND TEST-PIECE = B5
               GO TO FOUND-WIN.
           IF TEST-PIECE = B3 AND TEST-PIECE = B9
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-7.
           MOVE B7 TO TEST-PIECE.
           IF TEST-PIECE = B8 AND TEST-PIECE = B9
               GO TO FOUND-WIN.
           IF TEST-PIECE = B1 AND TEST-PIECE = B4
               GO TO FOUND-WIN.
           IF TEST-PIECE = B3 AND TEST-PIECE = B5
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-8.
           MOVE B8 TO TEST-PIECE.
           IF TEST-PIECE = B7 AND TEST-PIECE = B9
               GO TO FOUND-WIN.
           IF TEST-PIECE = B2 AND TEST-PIECE = B5
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       WIN-9.
           MOVE B9 TO TEST-PIECE.
           IF TEST-PIECE = B7 AND TEST-PIECE = B8
               GO TO FOUND-WIN.
           IF TEST-PIECE = B3 AND TEST-PIECE = B6
               GO TO FOUND-WIN.
           IF TEST-PIECE = B1 AND TEST-PIECE = B5
               GO TO FOUND-WIN.
           GO TO NO-WIN.
       FOUND-WIN.
           MOVE '4' TO SCORE-I.
           IF TEST-PIECE = '1' MOVE '6' TO SCORE-I.
           GO TO RETURN-NODE.
       NO-WIN.
           IF DEPTH-I = 9
               MOVE '5' TO SCORE-I
               GO TO RETURN-NODE.
       INIT-NODE.
           MOVE '9' TO VALUE-I.
           IF PM = '1' MOVE '2' TO VALUE-I.
           SET POS-I TO 1.
       TRY-MOVE.
           IF B(POS-I) NOT = '0' GO TO NEXT-MOVE.
           MOVE PM TO B(POS-I).
           MOVE ALPHA-I TO SAVED-ALPHA(DEPTH-I).
           MOVE BETA-I TO SAVED-BETA(DEPTH-I).
           MOVE VALUE-I TO SAVED-VALUE(DEPTH-I).
           SET SAVED-POS(DEPTH-I) TO POS-I.
           SET LAST-N TO POS-I.
           SET DEPTH-I UP BY 1.
           IF PM = '1' MOVE '2' TO PM
           ELSE MOVE '1' TO PM.
           GO TO ENTER-NODE.
       NEXT-MOVE.
           SET POS-I UP BY 1.
           IF POS-I < 10 GO TO TRY-MOVE.
           MOVE VALUE-I TO SCORE-I.
       RETURN-NODE.
           IF DEPTH-I = 1 GO TO SEARCH-DONE.
           SET DEPTH-I DOWN BY 1.
           MOVE SAVED-ALPHA(DEPTH-I) TO ALPHA-I.
           MOVE SAVED-BETA(DEPTH-I) TO BETA-I.
           MOVE SAVED-VALUE(DEPTH-I) TO VALUE-I.
           SET POS-I TO SAVED-POS(DEPTH-I).
           MOVE '0' TO B(POS-I).
           IF PM = '1' MOVE '2' TO PM
           ELSE MOVE '1' TO PM.
           IF PM = '2' GO TO MINIMIZE-SCORE.
           IF SCORE-I NOT > VALUE-I GO TO NEXT-MOVE.
           MOVE SCORE-I TO VALUE-I.
           IF VALUE-I = '6' GO TO RETURN-NODE.
           IF VALUE-I NOT < BETA-I GO TO RETURN-NODE.
           IF VALUE-I > ALPHA-I MOVE VALUE-I TO ALPHA-I.
           GO TO NEXT-MOVE.
       MINIMIZE-SCORE.
           IF SCORE-I NOT < VALUE-I GO TO NEXT-MOVE.
           MOVE SCORE-I TO VALUE-I.
           IF VALUE-I = '4' GO TO RETURN-NODE.
           IF VALUE-I NOT > ALPHA-I GO TO RETURN-NODE.
           IF VALUE-I < BETA-I MOVE VALUE-I TO BETA-I.
           GO TO NEXT-MOVE.
       SEARCH-DONE.
           MOVE '0' TO B(FIRST-I).
