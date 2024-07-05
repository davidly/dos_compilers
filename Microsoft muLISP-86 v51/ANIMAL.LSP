;File:  ANIMAL.LSP  (C)		12/29/85	Soft Warehouse, Inc.


(LOOP (PRIN1 '*) (EVAL (READ)) ((NULL RDS)) )


(DEFUN ANIMAL (
    *BASE* *NAME* *DIRTY* )
  (CLEAR-SCREEN)
  (TERPRI 2)
  (CENTER "* * *   T H E   A N I M A L   G A M E   * * *")
  (TERPRI 3)
  (PRINTC "Hello, I would like to play the animal guessing game with you.")
  (TERPRI)
  (PRINTC "Please type in your first name and press the RETURN key so we")
  (PRINC "can chat on a more friendly basis:  ")
  (CLEAR-INPUT)
  (SETQ *NAME* (STRING-CAPITALIZE (READ-LINE)))
  (TERPRI)
  (PRINTC "Thanks " *NAME* ", now think of an animal and I will try to guess")
  (PRINTC "what it is by asking you some yes-or-no questions.")
  (TERPRI)
  (SETQ *BASE* *INIT-BASE*)
  ( ((OR
	(AND (RDS (PACK* *NAME* '.MEM))
	  (PRINTC "Would you like to refresh my memory about animals from")
	  (Y-OR-N-P "our previous session?") )
	(AND (RDS 'ANIMAL.MEM)
	  (PRINTC "Would you like to refresh my memory about animals from")
	  (Y-OR-N-P "the pre-built animal data file?") ) )
      (SETQ *BASE* (MAKE-BASE (READ))) ) )
  (RDS)
  (LOOP
    (TERPRI)
    (PRINC "After you think of an animal, press any key to start the game. ")
    (READ-KEY)
    (TERPRI 2)
    (PLAY-ROUND *BASE*)
    ((NOT (Y-OR-N-P "Would you like to play another round?")))
    (CLEAR-SCREEN) )
  (TERPRI)
  ( ((NOT *DIRTY*))
    (PRINTC *NAME* ", do you want me to save all you have taught me")
    ((Y-OR-N-P "so I will remember it next time we play Animal?")
      (WRS (PACK* *NAME* '.MEM))
      (PRT-BASE *BASE* 0)
      (TERPRI)
      (WRS)
      (SETQ *DIRTY*)
      (TERPRI) )
    (TERPRI) )
  (PRINTC "I hope you enjoyed playing the Animal Game " *NAME* ".")
  (PRINC "Let's get together again some time!")
  (TERPRI 2) )


(DEFUN PLAY-ROUND (BASE
    ANIMAL ANSWERS NEW-BASE QUESTION)
  (LOOP
    ((ATOM (CDR BASE))
      ((Y-OR-N-P (PACK* "I bet it's " (@ (CAR BASE)) "?"))
	(PRINTC "Yea, I got it!  Thanks for the game " *NAME* ".")
	(TERPRI) )
      (PRINC "I give up, what animal were you thinking of?  ")
      (SETQ ANIMAL (STRING-UPCASE (READ-LINE)))
      (TERPRI)
      ((EQ ANIMAL (CAR BASE))
	(PRINTC "Stop fooling around " *NAME* ", that is what I just guessed!")
	(TERPRI) )
      (SETQ NEW-BASE (ALREADY-EXISTS ANIMAL (REVERSE ANSWERS) *BASE*))
      ( ((NOT NEW-BASE))
	(PRINTC "I think you may have incorrectly answered the question")
	(TERPRI)
	(SPACES 10)
	(PRINTC """" (CAR NEW-BASE) "?""")
	(TERPRI)
	((Y-OR-N-P (PACK* *NAME*
		" are you sure you answered this question correctly?"))
	  (REMOVE-ANIMAL ANIMAL *BASE*)
	  (PRINTC "OK, I fixed by memory so I won't make that mistake again.")
	  (TERPRI) )
	(TERPRI)
	(RETURN) )
      (PRINTC "What question can I ask for which a YES answer indicates")
      (PRINTC (@ ANIMAL) " rather than " (@ (CAR BASE)) "?")
      (SETQ QUESTION (STRING-RIGHT-TRIM "?.! " (READ-LINE)))
      (TERPRI)
      (DISPLACE BASE (LIST QUESTION (LIST (CAR BASE)) (LIST ANIMAL)))
      (PRINTC "Thanks for telling me that.  I'll be sure to remember it.")
      (SETQ *DIRTY* T) )
    (PUSH (Y-OR-N-P (PACK* (CAR BASE) "?")) ANSWERS)
    (TERPRI)
    ( ((CAR ANSWERS)
	(SETQ BASE (CADDR BASE)) )
      (SETQ BASE (CADR BASE)) ) ) )

(DEFUN ALREADY-EXISTS (ANIMAL ANSWERS BASE)
  ((ATOM (CDR BASE)) NIL)
  ((CAR ANSWERS)
    ((MEMBER-BASE ANIMAL (CADR BASE)) BASE)
    (ALREADY-EXISTS ANIMAL (CDR ANSWERS) (CADDR BASE)) )
  ((MEMBER-BASE ANIMAL (CADDR BASE)) BASE)
  (ALREADY-EXISTS ANIMAL (CDR ANSWERS) (CADR BASE)) )

(DEFUN REMOVE-ANIMAL (ANIMAL BASE)
  ((MEMBER-BASE ANIMAL (CADR BASE))
    (SETQ SUB-BASE (CADR BASE))
    ((EQ ANIMAL (CAR (CADR SUB-BASE)))
      (RPLACA (CDR BASE) (CADDR SUB-BASE)) )
    ((EQ ANIMAL (CAR (CADDR SUB-BASE)))
      (RPLACA (CDR BASE) (CADR SUB-BASE)) )
    (REMOVE-ANIMAL ANIMAL (CADR BASE)) )
  (SETQ SUB-BASE (CADDR BASE))
  ((EQ ANIMAL (CAR (CADR SUB-BASE)))
    (RPLACA (CDDR BASE) (CADDR SUB-BASE)) )
  ((EQ ANIMAL (CAR (CADDR SUB-BASE)))
    (RPLACA (CDDR BASE) (CADR SUB-BASE)) )
  (REMOVE-ANIMAL ANIMAL (CADDR BASE)) )

(DEFUN MEMBER-BASE (ANIMAL BASE)
  (LOOP
    ((ATOM (CDR BASE))
      (EQ (CAR BASE) ANIMAL) )
    ((MEMBER-BASE ANIMAL (CADR BASE)))
    (SETQ BASE (CADDR BASE)) ) )

(DEFUN MAKE-BASE (BASE)
  ((ATOM BASE)
    (LIST BASE) )
  (LIST (CAR BASE) (MAKE-BASE (CADR BASE)) (MAKE-BASE (CADDR BASE))) )

(DEFUN PRT-BASE (BASE TAB PRIN1)
  (SPACES TAB)
  ((ATOM (CDR BASE))
    (PRIN1 (CAR BASE)) )
  (PRINC '"(")
  (PRINT (CAR BASE))
  (PRT-BASE (CADR BASE) (+ TAB 2))
  (TERPRI)
  (PRT-BASE (CADDR BASE) (+ TAB 2))
  (PRINC '")") )

(SETQ *INIT-BASE*
 '("Does it hava a backbone"
    ("Can it fly"
	(WORM)
	(MOSQUITO))
    ("Is it a warm blooded animal"
	("Does it have gills and live all its life in water"
	    ("Does it start life with gills and then become an air breather"
		("Does it have legs"
		    (SNAKE)
		    (CROCODILE))
		(FROG))
	    ("TUNA FISH"))
	("Does it nurse its young with milk"
	    ("Can it fly"
		(CHICKEN)
		(ROBIN))
	    ("Does it live in water"
		("Is it a commonly domesticated animal"
		    (TIGER)
		    (DOG))
		(DOLPHIN)) ))) )


(DEFUN DISPLACE (LST1 LST2)
  (RPLACA LST1 (CAR LST2))
  (RPLACD LST1 (CDR LST2)) )

(DEFUN @ (NOUN)
  ((FINDSTRING (CHAR NOUN 0) "AEIOUaeiou")
    (PACK* "an " NOUN) )
  (PACK* "a " NOUN) )

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

(ANIMAL (RDS))
