; File EIGHTS.LSP  (C)		12/29/85	    Soft WareHouse, Inc.


;		T h e   E I G H T S   P u z z l e

; EIGHTS searches for the next node using an Ordered State-space
; search as described in "Principles of Artificial Intelligence", by
; Nils J. Nilsson, 1980, Tioga Publishing Co., Palo Alto, CA; Pgs 85-88.
; Program originally written by Mr. Peter A. Harada of Honolulu, Hawaii.

(LOOP (PRINC '*) (EVAL (READ)) ((NULL RDS)) )

(DEFUN EIGHTS (
    LEGAL-LST RSLT-LST CENTER-COLUMN CHAR)
  (LOOP
    (CLEAR-SCREEN)  (TERPRI)
    (CENTER "* * *   T h e   E I G H T S   P u z z l e   * * *")
    (TERPRI 2)
    (WRITE-STRING "Enter in random order the digits 1 through 8 and a space:")
    (SETQ CENTER-COLUMN (TRUNCATE (CADDDR (MAKE-WINDOW)) 2))
    (SET-CURSOR 6 (- CENTER-COLUMN 8))   (WRITE-STRING " ----------- ")
    (SET-CURSOR 7 (- CENTER-COLUMN 8))   (WRITE-STRING "|   |   |   |")
    (SET-CURSOR 8 (- CENTER-COLUMN 8))   (WRITE-STRING "|---+---+---|")
    (SET-CURSOR 9 (- CENTER-COLUMN 8))   (WRITE-STRING "|   |   |   |")
    (SET-CURSOR 10 (- CENTER-COLUMN 8))  (WRITE-STRING "|---+---+---|")
    (SET-CURSOR 11 (- CENTER-COLUMN 8))  (WRITE-STRING "|   |   |   |")
    (SET-CURSOR 12 (- CENTER-COLUMN 8))  (WRITE-STRING " ----------- ")
    (SETQ LEGAL-LST (LIST 1 2 3 4 5 6 7 8 " "))
    (SETQ RSLT-LST (LIST NIL NIL NIL NIL NIL NIL NIL NIL NIL))
    (READ-ROW 7 (- CENTER-COLUMN 6) '(0 1 2))
    (READ-ROW 9 (- CENTER-COLUMN 6) '(7 8 3))
    (READ-ROW 11 (- CENTER-COLUMN 6) '(6 5))
    (SET-CURSOR 11 (+ CENTER-COLUMN 2))
    (SETQ CHAR (CAR LEGAL-LST))
    ( ((EQ (PRINC CHAR) '" ")
	(SETQ CHAR 9) ) )
    (TERPRI 3)
    (RPLACA (NTHCDR 4 RSLT-LST) CHAR)
    (EIGHTS-AUX RSLT-LST)
    ((NOT (Y-OR-N-P "Do you want me to solve another one?"))) ) )

(DEFUN EIGHTS-AUX (START GOAL OPEN CLOSED NODE0 NODEI
    NODEJ SUCCESSORS NEXPANSIONS N TEMPOPEN)
  ((NOT (SOLVABLE START))
    (WRITE-LINE "That is an impossible starting position.")
    (TERPRI) )
  (SETQ NODE0 START)
  (SETQ GOAL '(1 2 3 4 5 6 7 8 9))
  (SETQ N (SETQ NEXPANSIONS 0))
  (SETQ OPEN (LIST (LIST (F* NODE0 N) N NODE0 NIL)))
  (LOOP
    (PRINC '*)
    (SETQ OPEN (APPEND TEMPOPEN OPEN))
    (SETQ OPEN (DELETE (SETQ NODEI (GET-MIN-NODE OPEN GOAL)) OPEN 'EQUAL))
    (PUSH NODEI CLOSED)
    ((EQUAL (CADDR NODEI) GOAL)
      (OUTPUT-SOLUTION START NODEI CLOSED NEXPANSIONS) )
    (SETQ SUCCESSORS (EXPAND-NODE (CADDR NODEI)))
    (SETQ N (ADD1 (CADR NODEI)))
    (SETQ TEMPOPEN NIL)
    (LOOP
      ((NULL SUCCESSORS))
      (INCQ NEXPANSIONS)
      (SETQ NODEJ (LIST (F* (CAR SUCCESSORS) N) N (CAR SUCCESSORS)
			(CADDR NODEI)))
      (SETQ INOPEN (CONTAINED-INP OPEN NODEJ))
      (SETQ INCLOSED (CONTAINED-INP CLOSED NODEJ))
      ( ((AND (NULL INOPEN) (NULL INCLOSED))
	  (PUSH NODEJ TEMPOPEN) )
	((AND (NULL INOPEN) (< (CAR NODEJ) (CAR INCLOSED)))
	  (SETQ CLOSED (DELETE (GET-MIN-NODE CLOSED (CADDR NODEJ))
		CLOSED 'EQUAL))
	  (PUSH NODEJ TEMPOPEN) )
	((AND (NULL INCLOSED) (< (CAR NODEJ) (CAR INOPEN)))
	  (SETQ OPEN (DELETE (GET-MIN-NODE OPEN (CADDR NODEJ)) OPEN 'EQUAL))
	  (PUSH NODEJ TEMPOPEN) ) )
      (POP SUCCESSORS) ) ) )

(DEFUN CONTAINED-INP (LST NODE TEMP)
  (SETQ NODE (CADDR NODE))
  (LOOP
    ((NULL LST) NIL)
    (SETQ TEMP (POP LST))
    ((EQUAL (CADDR TEMP) NODE) TEMP) ) )

(DEFUN EXPAND-NODE (NODE)
  (MAPCAR 'XCHG-POS (NTH (POSITION 9 NODE) MOVE-LIST)) )

(DEFUN XCHG-POS (PAIR LST TEMP1 TEMP2)
  (SETQ LST (COPY-LIST NODE))
  (SETQ TEMP1 (NTHCDR (CAR PAIR) LST))
  (SETQ TEMP2 (NTHCDR (CADR PAIR) LST))
  (SETQ TEMP (CAR TEMP2))
  (RPLACA TEMP2 (CAR TEMP1))
  (RPLACA TEMP1 TEMP)  LST )

(SETQ MOVE-LIST '(((0 1) (0 7))		((0 1) (1 2) (1 8))
		  ((1 2) (2 3))		((3 8) (2 3) (3 4))
		  ((4 5) (3 4))		((5 6) (4 5) (5 8))
		  ((5 6) (6 7))		((7 8) (0 7) (6 7))
		  ((7 8) (3 8) (1 8) (5 8)) ) )

(SETQ POS-LIST '((0 1 2 3 4 3 2 1 0)	(1 0 1 2 3 2 3 2 0)
		 (2 1 0 1 2 3 4 3 0)	(3 2 1 0 1 2 3 2 0)
		 (4 3 2 1 0 1 2 3 0)	(3 2 3 2 1 0 1 2 0)
		 (2 3 4 3 2 1 0 1 0)	(1 2 3 2 3 2 1 0 0)
		 (2 1 2 1 2 1 2 1 0) ) )

(DEFUN F* (LAYOUT N)
  (+ N (H* LAYOUT N)) )

(DEFUN H* (LAYOUT N PWEIGHT SWEIGHT)
  (SETQ PWEIGHT 1)  (SETQ SWEIGHT 3)		; Adjustable weights
  (+ (* PWEIGHT (P* LAYOUT N)) (* SWEIGHT (S* LAYOUT N))))

(DEFUN P* (LAYOUT N SUM POSITION)
  (SETQ SUM 0)
  (SETQ POSITION POS-LIST)
  (LOOP
    ((NULL LAYOUT) SUM)
    (INCQ SUM (NTH (+ (POP LAYOUT) -1) (POP POSITION))) ) )

(DEFUN S* (LAYOUT N
    SUM NUM)
  (SETQ SUM 1)
  ( ((EQ (CAR LAYOUT) 9)
      (SETQ LAYOUT (COPY-LIST (CDR LAYOUT))) )
    ((EQ (CAR (LAST LAYOUT)) 9)
      (SETQ SUM 0)
      (SETQ LAYOUT (COPY-LIST LAYOUT)) )
    (SETQ LAYOUT (REMOVE 9 LAYOUT)) )
  (RPLACA (LAST LAYOUT) (CAR LAYOUT))
  (LOOP
    (SETQ NUM (POP LAYOUT))
    ((NULL LAYOUT) SUM)
    ( ((EQ NUM 8)
	((EQ (CAR LAYOUT) 1))
	(INCQ SUM 2) )
      ((EQ (ADD1 NUM) (CAR LAYOUT)))
      (INCQ SUM 2) ) ) )

(DEFUN GET-MIN-NODE (NODE-LST CONSTANT
    MIN-NODE)
  (SETQ MIN-NODE (POP NODE-LST))
  (LOOP
    ((NULL NODE-LST) MIN-NODE)
    (SETQ NODE (POP NODE-LST))
    ((EQUAL (CADDR NODE) CONSTANT) NODE)
    ( ((> (CAR MIN-NODE) (CAR NODE))
	(SETQ MIN-NODE NODE) )
      ((AND (EQUAL (CAR MIN-NODE) (CAR NODE))
	    (> (CADR MIN-NODE) (CADR NODE)) )
	(SETQ MIN-NODE NODE) ) ) ) )

; SOLVABLE's algorthm is from "Mathematical Games and Pastimes"
; by A. P. Domoryad; Macmillan Co., 1964, Pgs 79-85.

(DEFUN SOLVABLE (LST
    FLAG)
  (MAPC '(LAMBDA (NUM) (DISORDER NUM LST)) LST)
  (EQ (NOT FLAG) (EVENP (POSITION 9 LST))) )

(DEFUN DISORDER (NUM LST)
  ((EQ NUM (CAR LST)))
  ((> (CAR LST) NUM)
    (SETQ FLAG (NOT FLAG))
    (DISORDER NUM (CDR LST)) )
  (DISORDER NUM (CDR LST)) )


(DEFUN OUTPUT-SOLUTION (START LASTNODE LST EXPANSIONS
    LST1 PRINTLIST)
  (TERPRI 2)
  (WRITE-STRING "The number of moves checked was ")  (PRINC EXPANSIONS)
  (WRITE-LINE " and the shortest sequence is:")  (TERPRI)
  (LOOP
    (PUSH (CADDR LASTNODE) PRINTLIST)
    (SETQ LST1 LST)
    (LOOP
      ((EQUAL (CAR (CDDDR LASTNODE)) (CADDR (CAR LST1)))
	(SETQ LASTNODE (CAR LST1)) )
      (POP LST1) )
    ((NULL (CAR (CDDDR LASTNODE)))
      (FORMAT-OUTPUT (PUSH START PRINTLIST)) ) ) )

(DEFUN FORMAT-OUTPUT (ANSWERS DISPLAY# S1 S2 S3 COUNTER)
  (SETQ DISPLAY# (TRUNCATE (+ 2 (LINELENGTH)) 7))
  (LOOP				; Prints DISPLAY# of squares
    ((NULL (CAR ANSWERS)))	; across the page from a list
    (SETQ COUNTER 0)		; of lists in ANSWERS
    (SETQ S1)
    (LOOP
      ((EQUAL COUNTER DISPLAY#))
      (SETQ S2 (POP ANSWERS))
      ((NULL S2))
      (PUSH S2 S1)
      (INCQ COUNTER) )
    (SETQ DISPLAY# COUNTER)
    (SETQ S1 (REVERSE S1))
    (PRINT-ROW S1 DISPLAY# '(0 1 2))
    (PRINT-ROW S1 DISPLAY# '(7 8 3))
    (PRINT-ROW S1 DISPLAY# '(6 5 4))
    (TERPRI) ) )

(DEFUN PRINT-ROW (LST DISPLAY# INDEX-LIST)
  (LOOP
    ((ZEROP DISPLAY#) (TERPRI))
    (PRIN3 (NTH (CAR INDEX-LIST) (CAR LST)))
    (PRIN3 (NTH (CADR INDEX-LIST) (CAR LST)))
    (PRIN3 (NTH (CADDR INDEX-LIST) (POP LST)))
    (SPACES 1)
    (DECQ DISPLAY#) ) )

(DEFUN PRIN3 (NUM)
  ((EQ NUM 9)
    (WRITE-STRING "  ") )
  (PRINC NUM)
  (SPACES 1) )

(DEFUN READ-ROW (ROW COL LST
    READ-CHAR)
  (LOOP
    (SET-CURSOR ROW COL)
    (LOOP
      (SETQ CHAR (READ-CHAR))
      ((EQ CHAR (ASCII 3))		;Abort EIGHTS if <CTRL-C> typed
	(THROW) )
      ( ((EQ CHAR '" "))
	(SETQ CHAR (- (ASCII CHAR) 48)) )
      ((MEMBER CHAR LEGAL-LST))
      (PRINC (ASCII 7)) )
    (SETQ LEGAL-LST (REMOVE CHAR LEGAL-LST))
    ( ((EQ (PRINC CHAR) '" ")
	(SETQ CHAR 9) ) )
    (RPLACA (NTHCDR (POP LST) RSLT-LST) CHAR)
    ((NULL LST))
    (INCQ COL 4) ) )

(DEFUN CENTER (MSG)
  (SET-CURSOR (ROW)
	(TRUNCATE (- (CADDDR (MAKE-WINDOW)) (LENGTH MSG)) 2))
  (WRITE-LINE MSG) )

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

(EIGHTS (RDS))
