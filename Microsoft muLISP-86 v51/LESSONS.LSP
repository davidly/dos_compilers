; File:  LESSONS.LSP  (c)	12/29/85	Soft Warehouse, Inc.


;		The muLISP Tutorial System Lesson Driver

(PROGN  (WRITE-BYTE 13)
	(SPACES 2)
	(TERPRI)
	(WRITE-STRING "Loading the muLISP Tutorial System: ")
	(LOOP
	  (EVAL (READ))
	  (PRINC '*) ) )

(SETQ *LESSON-DRIVE* '||)

(DEFUN LESSONS (
    NUM LEFT-COLUMN )
  (WRS)
  (SETQ DEFAULT-LESSON 1)
  (LOOP
    (RDS)
    (MOVD 'APP# 'APPEND)
    (MOVD 'REV# 'REVERSE)
    (MOVD 'MBR# 'MEMBER)
    (CLEAR-SCREEN)
    (SETQ *HIGH-INTENSITY* T)
    (CENTER "m u L I S P - 8 5")
    (TERPRI)
    (CENTER "T U T O R I A L   S Y S T E M")
    (SETQ *HIGH-INTENSITY*)
    (SETQ LEFT-COLUMN (MAX 0 (- (TRUNCATE (CADDDR (MAKE-WINDOW)) 2) 22)))
    (SET-CURSOR 5 LEFT-COLUMN)
    (WRITE-STRING "Lesson		   Subject")
    (DISPLAY-MENU SUBJECT-LIST 7 LEFT-COLUMN)
    (TERPRI 2)
    (PRINC "When this program asks you to select ")
    (PRINC "from a list of options and you are not")
    (PRINC "sure which one to choose, press the ")
    (PRINC "SPACE BAR for the best default option.")
    (TERPRI 2)
    (PRINC "Enter desired lesson number or press \"Q\" ")
    (PRINC "to quit: ")
    (SETQ DEFAULT-LESSON (QUERY (LIST* DEFAULT-LESSON 'Q '(1 2 3 4 5 6))))
    ((EQ DEFAULT-LESSON 'Q)
	(SYSTEM) )
    (CATCH NIL (READ-LESSON (PACK* 'MULISP DEFAULT-LESSON)))
    (SETQ DEFAULT-LESSON (IF
      (EQ DEFAULT-LESSON (LENGTH SUBJECT-LIST))
      1
      (ADD1 DEFAULT-LESSON) )) ) )

(SETQ SUBJECT-LIST '(
  "Data objects and primitive functions"
  "Defining functions using recursion"
  "Symbols, numbers, and conses"
  "List processing & iterative functions"
  "Numerical programming techniques"
  "Implementing turtle graphics routines"
))

(DEFUN READ-LESSON (FILE-NAME
    EXPN PTRLST BRKFLG)
  ((EQ (RDS (PACK* *LESSON-DRIVE* FILE-NAME ".LES")))
    ((EQ *LESSON-DRIVE* "A:")
      (TERPRI)
      (PRINC "Enter the drive that contains the file ")
      (PRINC (PACK* FILE-NAME ".LES: "))
      (SETQ *LESSON-DRIVE* (QUERY '(Q A B C D E F G H I J K L M N O P)))
      ((EQ *LESSON-DRIVE* 'Q))
      (SETQ *LESSON-DRIVE* (PACK* *LESSON-DRIVE* '\:))
      (READ-LESSON FILE-NAME) )
    (SETQ *LESSON-DRIVE* "A:")
    (READ-LESSON FILE-NAME) )
  (READPTR 0)
  (LOOP
    ( ((EQ (PEEK-CHAR) '$)
	(READ-CHAR)
	(EVAL (READ)) ) )
    ((EQ (READ-LINE) 'CLRSCRN)) )
  (CLEAR-SCREEN)
  (PUSH (READPTR) PTRLST)
  (LOOP
    ((NOT (LISTEN)))
    ( ((EQ (PEEK-CHAR) '$)
	(SETQ ECHO T)
	(PRINC (READ-CHAR))
	(SETQ EXPN (READ)
	      ECHO)
	((EQ (CAR EXPN) 'DEFUN)
	  (EVAL EXPN) )
	(TERPRI)
	(PRINC (EVAL EXPN)) )
      ((EQ (SETQ EXPN (READ-LINE)) 'CONTINUE)
	( ((EQ (CDR PTRLST))
	    (LBREAK '("Continue lesson" "Abort lesson"))
	    (PUSH (READPTR) PTRLST) )
	  ((EQ BRKFLG)
	    ((LBREAK '("Continue lesson" "Abort lesson" "Previous screen"))
	      (PUSH (READPTR) PTRLST) )
	    (POP PTRLST)
	    (READPTR (CAR PTRLST)) )
	  ((LBREAK '("Continue lesson" "Break lesson" "Abort lesson"
		"Previous screen"))
	    (PUSH (READPTR) PTRLST) )
	  (POP PTRLST)
	  (READPTR (CAR PTRLST)) )
	(CLEAR-SCREEN) )
      ((EQ EXPN 'BREAK)
	(SETQ BRKFLG T)
	((LBREAK '("Break lesson" "Continue lesson" "Abort lesson"
		"Previous screen")) )
	(POP PTRLST)
	(READPTR (CAR PTRLST))
	(CLEAR-SCREEN) )
      ((EQ EXPN 'CLRSCRN)
	(PUSH (READPTR) PTRLST)
	(CLEAR-SCREEN) )
      (WRITE-LINE EXPN) ) ) )

(DEFUN LBREAK (LST
    CHAR RDS WRS READ-CHAR)
  (SETQ CHAR (OPTIONS LST))
  ((EQ CHAR 'A)
    (THROW) )
  ((EQ CHAR 'C))
  ((EQ CHAR 'P) NIL)
  ((EQ CHAR 'B)
    (SETQ READ-CHAR 'READ-CHAR)
    (CATCH NIL (DRIVER))
    (RDS (PACK* *LESSON-DRIVE* FILE-NAME ".LES")) )
  ((EQ CHAR 'S)
    (SYSTEM) ) )

(DEFUN OPTIONS (LST1
    LST2 *PRINT-DOWNCASE* WRS)
  (WRITE-BYTE 13)
  (LOOP
    (PUSH (CAR (UNPACK (PRINC (POP LST1)))) LST2)
    ((EQ LST1))
    (WRITE-STRING ", ") )
  (WRITE-STRING " (")
  (SETQ LST2 (REV# LST2)
	LST1 LST2)
  (LOOP
    (PRINC (POP LST1))
    ((EQ LST1))
    (PRINC '/) )
  (WRITE-STRING ")? ")
  (QUERY LST2) )

(DEFUN QUERY (LST
    RDS READ-CHAR CHAR)
  (CLEAR-INPUT)
  (LOOP
    (SETQ CHAR (CHAR-UPCASE (READ-CHAR)))
    (IF (<= 48 (ASCII CHAR) 57)
	(SETQ CHAR (- (ASCII CHAR) 48)))
    ((MBR# CHAR LST)
      (PRINC CHAR)
      (TERPRI)
      CHAR )
    ((EQ CHAR '" ")
      (PRINC (CAR LST))
      (TERPRI)
      (CAR LST) )
    ( ((EQ CHAR (ASCII 10)))
      ((EQ BELL))
      (WRITE-BYTE 7) ) ) )

(DEFUN DISPLAY-MENU (OPTION-LIST ROW COLUMN
    NUM )
  (SETQ NUM 0)
  (IF (> (CADDDR (MAKE-WINDOW)) 50)
	(INCQ COLUMN 3) )
  (LOOP
    ((EQ OPTION-LIST))
    (SET-CURSOR (+ ROW NUM) COLUMN)
    (PRINC (INCQ NUM))
    (SPACES 1)
    (IF (> (CADDDR (MAKE-WINDOW)) 50) (SPACES 3))
    (WRITE-LINE (POP OPTION-LIST)) ) )

(DEFUN CENTER (MSG)
  (SET-CURSOR (ROW)
	(TRUNCATE (- (CADDDR (MAKE-WINDOW)) (LENGTH MSG)) 2))
  (WRITE-LINE MSG) )

(MOVD 'REVERSE 'REV#)
(MOVD 'MEMBER 'MBR#)
(MOVD 'APPEND 'APP#)

(SETQ DRIVER 'LESSONS)

(RETURN)
