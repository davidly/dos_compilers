;File:	METAMIND.LSP		12/29/85	Soft Warehouse, Inc.


(LOOP (PRIN1 '*) (EVAL (READ)) ((NULL RDS)) )

(DEFUN METAMIND (
    KEYLIST HELPMK HELPBR SEED)
  (CLEAR-SCREEN)
  (TERPRI)
  (CENTER "* * *   T H E   M E T A M I N D   G A M E   * * *")
  (TERPRI 2)
  (CENTER "Break the secret code using pure logic.")
  (TERPRI 3)
  (SETQ KEYLIST '(
    (BLU GRN WHI YEL RED BLK)
    (RED YEL GRN BLK BLU WHI)
    (BLK BLU YEL GRN WHI RED)
    (YEL WHI RED BLK BLU GRN)
      ))
  (LOOP
    (PRINC "Please enter a random number between 1 and 100: ")
    ((PLUSP (SETQ SEED (RATOM))))
    (TERPRI) )
  (TERPRI)
  (LOOP
    (PRINC "Would you like to be the code Maker or Breaker? (M/B) ")
    ( ((EQ (QUERY '(M B)) 'M)
	(TERPRI)
	(HELPMK)
	(CODEBREAKER) )
      (TERPRI)
      (HELPBR)
      (CODEMAKER) )
    (TERPRI)
    ((NOT (Y-OR-N-P "Do you want to play another round?")))
    (TERPRI 2) ) )

(DEFUN HELPMK ()
  ((EVAL HELPMK))
  (SETQ HELPMK T)
  (CENTER "So you want to challenge the champ!")
  (TERPRI 2)
  (PRINTC "Ok, after I make my guess, you type in the number of blacks")
  (PRINTC "(i.e. the number of guesses of the right color and right column),")
  (PRINTC "a space, and then the number of whites (i.e. of the remaining")
  (PRINTC "non-black guesses, the number of correct colors).  Then press")
  (PRINTC "the <RETURN> key.")
  (TERPRI) )

(DEFUN HELPBR (CTR)
  ((EVAL HELPBR))
  (SETQ HELPBR T)
  (PRINTC "So you want to out guess me.  Let me think of a code")
  (SETQ CTR 800)
  (PRIN1 "Hmmm . ")
  (LOOP
    ((ZEROP CTR))
    ( ((ZEROP (REM CTR 150)) (PRIN1 ". ")) )
    (DECQ CTR) )
  (TERPRI 2)
  (PRINTC "Ok, I have got one, now make a guess by typing in 4 of the")
  (PRINC "colors in the following list of colors:  ")
  (PRINT (CAR KEYLIST))
  (TERPRI) )


(DEFUN CODEBREAKER (
    MOVE GRAPH CTR KEYLST NUM)
  (SETQ KEYLIST (MAPCAR 'PERMUTE KEYLIST))
  (SETQ MOVE (FRSTMOV (CAR KEYLIST)))
  (SETQ GRAPH (NUGRAPH MOVE))
  (SETQ CTR 1)
  (LOOP
    (SPACES (TRUNCATE (- (LINELENGTH) 32) 2))
    (PRINC "Move: ")
    (PRINC CTR)
    (SPACES 3)
    (MAPC '(LAMBDA (COLOR) (PRIN1 COLOR) (SPACES 2)) MOVE)
    (SETQ NUM (RATOM))
    ((EQ NUM 4)
      (CLEAR-INPUT)
      (TERPRI)
      (PRINTC "Yea, I did it!  And it only took me " CTR " moves.")
      (TERPRI) )
    (SETQ GRAPH (MKGRAPH MOVE NUM (RATOM) MOVE NIL GRAPH KEYLIST))
    (INCQ CTR)
    (SETQ ERROR NIL)
    (SETQ KEYLST KEYLIST)
    (SETQ MOVE (MKMOVE GRAPH (POP KEYLST)))
    (TERPRI)
    ((EVAL ERROR)
      (PRINTC "I am afraid you have made a mistake in your counting.")
      (PRINTC "Let's start over.") ) ) )

(DEFUN PERMUTE (LST1 LST2 LST3)
  ((NULL LST1)
    (NCONC LST2 LST3) )
  ((NULL (CDR LST1))
    (NCONC (CONS (CAR LST1) LST3) LST2) )
  ((NULL (CDDR LST1))
    (NCONC (PERMUTE (CONS (CAR LST1) LST2))
	   (PERMUTE (CONS (CADR LST1) LST3))) )
  (PERMUTE (CDDDR LST1) (CONS (CADR LST1) LST3)
	 (LIST* (CADDR LST1) (CAR LST1) LST2)) )


(DEFUN FRSTMOV (KEY)
  (LIST (CAR KEY) (CADDR KEY) (CAR KEY) (CADDR KEY)) )

(DEFUN NUGRAPH (MOVE)
  ((NULL MOVE) T)
  (NUROW (NUGRAPH (CDR MOVE)) (CAR KEYLIST)) )

(DEFUN NUROW (GRAPH KEY)
  ((NULL KEY) NIL)
  (CONS GRAPH (NUROW GRAPH (CDR KEY))) )

(DEFUN MKMOVE (GRAPH KEY)
  (LOOP
    ((NULL GRAPH)
      (SETQ ERROR T) NIL)
    ((CAR GRAPH)
      ((ATOM (CAR GRAPH))
	(LIST (CAR KEY)) )
      (CONS (CAR KEY) (MKMOVE (CAR GRAPH) (POP KEYLST))) )
    (POP GRAPH)
    (POP KEY) ) )

(DEFUN MKGRAPH (MOVE BLACKS WHITES FREE UNUSED GRAPH KEYLST)
  ((NULL MOVE)
    ((ZEROP BLACKS)
      (EQ WHITES (INCOMMON FREE UNUSED)) ) )
  (MKNODE GRAPH (CAR KEYLST)) )

(DEFUN MKNODE (GRAPH KEY)
  ((NULL KEY) NIL)
  ((NULL (CAR GRAPH))
    (CONSNIL (MKNODE (CDR GRAPH) (CDR KEY))) )
  ((EQ (CAR MOVE) (CAR KEY))
    ((PLUSP BLACKS)
      (CONSNULL (MKGRAPH (CDR MOVE) (SUB1 BLACKS) WHITES
	(REMBER1 (CAR KEY) FREE) UNUSED (CAR GRAPH) (CDR KEYLST))
	  (MKNODE (CDR GRAPH) (CDR KEY))) )
    (CONSNIL (MKNODE (CDR GRAPH) (CDR KEY))) )
  (CONSNULL (MKGRAPH (CDR MOVE) BLACKS WHITES FREE
    (CONS (CAR KEY) UNUSED) (CAR GRAPH) (CDR KEYLST))
      (MKNODE (CDR GRAPH) (CDR KEY))) )


(DEFUN CODEMAKER (CODE MOVE CTR)
  (SETQ KEYLIST (MAPCAR 'PERMUTE KEYLIST))
  (SETQ CODE (MKCODE KEYLIST))
  (SETQ CTR 1)
  (LOOP
    (SPACES (TRUNCATE (- (LINELENGTH) 32) 2))
    (PRIN1 "Move: ")
    (PRIN1 CTR)
    (SPACES 3)
    ((CODEMATCH CODE (READMOVE CODE) 0)
      (TERPRI)
      (PRINTC "That took you " CTR (COND
		((EQ CTR 1) " move.")
		(" moves.") ) )
      ((< CTR 6)
	(PRINTC "Hey you're good, let's play again!") )
      ((< CTR 8)
	(PRINTC "That was a hard one, want to try to improve your score?") )
      (PRINTC "Better take a break and let me be the code breaker.") )
    (TERPRI)
    (INCQ CTR) ) )

(DEFUN MKCODE (KEYLST)
  ((NULL KEYLST) NIL)
  (CONS (NTH (RANDOM 4) (CAR KEYLST)) (MKCODE (CDR KEYLST))) )

(DEFUN CODEMATCH (CODE1 MOVE1 BLACKS CODE2 MOVE2)
  ((NULL CODE1)
    (SPACES (+ (TRUNCATE (- (LINELENGTH) 32) 2) 28))
    ((EQ (PRIN1 BLACKS) 4))
    (SPACES 2)
    (SAMETYPE CODE2 MOVE2 0)
    NIL )
  ((EQ (CAR CODE1) (CAR MOVE1))
    (CODEMATCH (CDR CODE1) (CDR MOVE1) (ADD1 BLACKS) CODE2 MOVE2) )
  (CODEMATCH (CDR CODE1) (CDR MOVE1) BLACKS (CONS (CAR CODE1) CODE2)
    (CONS (CAR MOVE1) MOVE2)) )

(DEFUN SAMETYPE (CODE MOVE WHITES)
  ((NULL CODE)
    (PRINT WHITES) )
  ((MEMBER (CAR CODE) MOVE)
    (SAMETYPE (CDR CODE) (REMBER1 (CAR CODE) MOVE) (ADD1 WHITES)) )
  (SAMETYPE (CDR CODE) MOVE WHITES) )

(DEFUN READMOVE (CODE)
  ((NULL CODE) NIL)
  (CONS (RATOM) (READMOVE (CDR CODE))) )

(DEFUN CONSNULL (X Y)
  ((NULL X)
    ((NULL Y) NIL)
    (CONS NIL Y) )
  (CONS X Y) )

(DEFUN CONSNIL (X)
  ((NULL X) NIL)
  (CONS NIL X) )

(DEFUN INCOMMON (LST1 LST2
    TOT )
  (SETQ TOT 0)
  (LOOP
    ((OR (NULL LST1) (NULL LST2)) TOT)
    ( ((MEMBER (CAR LST1) LST2)
	(SETQ LST2 (REMBER1 (CAR LST1) LST2))
	(INCQ TOT) ) )
    (POP LST1) ) )

(DEFUN REMBER1 (X L)
  ((NULL L) NIL)
  ((EQ X (CAR L)) (CDR L))
  (CONS (CAR L) (REMBER1 X (CDR L))) )

(DEFUN REPLACE (X Y L)
  ((NULL L) NIL)
  ((EQ X (CAR L))
    (CONS Y (REPLACE X Y (CDR L))) )
  (CONS (CAR L) (REPLACE X Y (CDR L))) )

(DEFUN RANDOM (NUM)
  (SETQ SEED (REM (+ 2113233 (* SEED 271821)) 9999991))
  (REM SEED NUM) )

(DEFUN Y-OR-N-P (MSG
    CHAR READ-CHAR RDS WRS )
  ( ((NULL MSG))
    (FRESH-LINE)
    (WRITE-STRING (PACK* MSG " (Y/N) ")) )
  (CLEAR-INPUT)
  (LOOP
    (SETQ CHAR (CHAR-UPCASE (READ-CHAR)))
    ((EQ CHAR 'Y)
      (WRITE-LINE CHAR)
      T )
    ((EQ CHAR 'N)
      (WRITE-LINE CHAR)
      NIL )
    (WRITE-BYTE 7) ) )

(DEFUN QUERY (LST
     CHAR RDS )
  (CLEAR-INPUT)
  (LOOP
    (SETQ CHAR (CHAR-UPCASE (READ-KEY)))
    ((MEMBER CHAR LST)
      (PRINC CHAR)
      (TERPRI)
      CHAR )
    (PRIN1 (ASCII 7)) ) )

(DEFUN READ-KEY (
    READ-CHAR RDS)
  (READ-CHAR) )

(DEFUN PRINTC LST
  (PRINC (PACK LST))
  (TERPRI)
  'T )

(DEFUN CENTER (MSG)
  (SET-CURSOR (ROW)
	(TRUNCATE (- (CADDDR (MAKE-WINDOW)) (LENGTH MSG)) 2))
  (WRITE-LINE MSG) )

(METAMIND (RDS))
