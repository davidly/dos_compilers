; File: COMMON.LSP		12/29/85	  Soft Warehouse, Inc.


; COMMON LISP Library:  This file defines the library functions
; referred to in Chapter 5 of the muLISP-86 Reference Manual.


; Section 5.1:  Selector Functions

(MOVD 'LENGTH 'LIST-LENGTH)


; Section 5.2:  Constructor Functions

(MOVD 'REVERSE 'REVAPPEND)

(SETQ *GENSYM-PREFIX* "G")
(SETQ *GENSYM-COUNT* 0)

(DEFUN GENSYM (ATM)
; (GENSYM) returns the symbol whose print name consists of *GENSYM-PREFIX*
; concatenated to *GENSYM-COUNT* and increments *GENSYM-COUNT*.
; (GENSYM symbol) sets *GENSYM-PREFIX* to <symbol>.
; (GENSYM integer) sets *GENSYM-COUNT* to <integer>.
  ( ((NULL ATM))
    ((SYMBOLP ATM)
      (SETQ *GENSYM-PREFIX* ATM) )
    ((AND (INTEGERP ATM) (>= ATM 0))
      (SETQ *GENSYM-COUNT* ATM) ) )
  (PROG1 (PACK* *GENSYM-PREFIX* *GENSYM-COUNT*)
	 (INCQ *GENSYM-COUNT*)) )


; Section 5.3:  Modifier Functions

(MOVD 'NREVERSE 'NRECONC)
(MOVD 'SORT 'STABLE-SORT)


; Section 5.4:  Recognizer Functions

(MOVD 'SYMBOLP 'STRINGP)
(MOVD 'NUMBERP 'RATIONALP)


; Section 5.5:  Comparator Functions

(MOVD 'EQUAL 'TREE-EQUAL)


; Section 5.7:  Assignment Functions

(DEFMACRO SETF LST
  ((NULL LST) NIL)
  ((NULL (CDDR LST))
    ((ATOM (CAR LST))
      (CONS 'SETQ LST) )
    (MAKE-SET-FORM (CAR LST) (CADR LST)) )
  (CONS 'PROGN (SETF-AUX LST)) )

(DEFUN SETF-AUX (LST)
  ((NULL LST) NIL)
  ((ATOM (CAR LST))
    (CONS (LIST 'SETQ (CAR LST) (CADR LST)) (SETF-AUX (CDDR LST))) )
  (CONS (MAKE-SET-FORM (CAR LST) (CADR LST)) (SETF-AUX (CDDR LST))) )

(DEFUN MAKE-SET-FORM (PLACE VALUE)
  ((EQ (CAR PLACE) 'CAR)
    (LIST 'CAR (LIST 'RPLACA (CADR PLACE) VALUE)) )
  ((OR (EQ (CAR PLACE) 'CDR) (EQ (CAR PLACE) 'REST))
    (LIST 'CDR (LIST 'RPLACD (CADR PLACE) VALUE)) )
  ((EQ (CAR PLACE) 'NTH)
    (LIST 'CAR (LIST 'RPLACA (CONS 'NTHCDR (CDR PLACE)) VALUE)) )
  ((EQ (CAR PLACE) 'GET)
    (LIST 'PUT (CADR PLACE) (CADDR PLACE) VALUE) )
  ((EQ (CAR PLACE) 'SYMBOL-FUNCTION)
    (LIST 'PUTD (CADR PLACE) VALUE) )
  ((GET (CAR PLACE) 'CAR)  (LIST 'CAR
      (LIST 'RPLACA (LIST (GET (CAR PLACE) 'CAR) (CADR PLACE)) VALUE)) )
  ((GET (CAR PLACE) 'CDR)  (LIST 'CDR
      (LIST 'RPLACD (LIST (GET (CAR PLACE) 'CDR) (CADR PLACE)) VALUE)) )
  ((GET (CAR PLACE) 'NTH)
    (LIST 'CAR (LIST 'RPLACA
		     (LIST 'NTHCDR (GET (CAR PLACE) 'NTH) (CADR PLACE))
		     VALUE)) )
  ((MACRO-FUNCTION-P (CAR PLACE))
    (MAKE-SET-FORM (MACROEXPAND PLACE) VALUE) )
  (BREAK (LIST 'SETF PLACE VALUE) "Invalid Place Form") )

(MAPC '(LAMBDA (PAIR) (PUT (CAR PAIR) 'CAR (CDR PAIR)))
  '((CAAR . CAR) (CADR . CDR)
    (CAAAR . CAAR) (CAADR . CADR) (CADAR . CDAR) (CADDR . CDDR)
    (CAAAAR . CAAAR) (CAAADR . CAADR) (CAADAR . CADAR) (CAADDR . CADDR)
    (CADAAR . CDAAR) (CADADR . CDADR) (CADDAR . CDDAR) (CADDDR . CDDDR)) )

(MAPC '(LAMBDA (PAIR) (PUT (CAR PAIR) 'CDR (CDR PAIR)))
  '((CDAR . CAR) (CDDR . CDR)
    (CDAAR . CAAR) (CDADR . CADR) (CDDAR . CDAR) (CDDDR . CDDR)
    (CDAAAR . CAAAR) (CDAADR . CAADR) (CDADAR . CADAR) (CDADDR . CADDR)
    (CDDAAR . CDAAR) (CDDADR . CDADR) (CDDDAR . CDDAR) (CDDDDR . CDDDR)) )

(MAPC '(LAMBDA (PAIR) (PUT (CAR PAIR) 'NTH (CDR PAIR)))
  '((FIRST . 0) (SECOND . 1) (THIRD . 2) (FOURTH . 3) (FIFTH . 4)
    (SIXTH . 5) (SEVENTH . 6) (EIGHTH . 7) (NINTH . 8) (TENTH . 9)) )

(DEFMACRO PUSHNEW (OBJ SYM TEST)
  (LIST 'SETQ SYM (LIST 'ADJOIN OBJ SYM TEST)) )


; Section 5.10:  Definition Primitives

(MOVD 'REMD 'FMAKUNBOUND)


; Section 5.11.1:  Character Functions

(DEFUN DIGIT-CHAR-P (SYM N)
  ((SYMBOLP SYM)
    ( ((AND (INTEGERP N) (<= 2 N 36)))
      (SETQ N 10) )
    ((NUMERIC-CHAR-P SYM)
      (SETQ SYM (- (ASCII SYM) 48))
      ((< SYM N) SYM) )
    ((UPPER-CASE-P SYM)
      (SETQ SYM (- (ASCII SYM) 55))
      ((< SYM N) SYM) ) ) )

(DEFUN CHAR-CODE (SYM)
  ((SYMBOLP SYM)
    (ASCII SYM) ) )

(DEFUN CODE-CHAR (N)
  ((AND (INTEGERP N) (<= 0 N 255))
    (ASCII N) ) )


; Section 5.11.2:  String Functions

(DEFMACRO STRING-EQUAL (ATM1 ATM2)
  (LIST 'STRING= ATM1 ATM2 T) )

(DEFMACRO STRING-LESSP (ATM1 ATM2)
  (LIST 'STRING< ATM1 ATM2 T) )

(DEFMACRO STRING-GREATERP (ATM1 ATM2)
  (LIST 'STRING> ATM1 ATM2 T) )

(DEFMACRO STRING-NOT-GREATERP (ATM1 ATM2)
  (LIST 'STRING<= ATM1 ATM2 T) )

(DEFMACRO STRING-NOT-LESSP (ATM1 ATM2)
  (LIST 'STRING>= ATM1 ATM2 T) )

(DEFMACRO STRING-NOT-EQUAL (ATM1 ATM2)
  (LIST 'STRING/= ATM1 ATM2 T) )


; Section 5.12:  Arithmetic Functions

(DEFMACRO INCF (PLACE N)
  ((NULL N)
    ((ATOM PLACE)
      (LIST 'INCQ PLACE) )
    (MAKE-SET-FORM PLACE (LIST 'ADD1 PLACE)) )
  ((ATOM PLACE)
    (LIST 'INCQ PLACE N) )
  (MAKE-SET-FORM PLACE (LIST '+ PLACE N)) )

(DEFMACRO DECF (PLACE N)
  ((NULL N)
    ((ATOM PLACE)
      (LIST 'DECQ PLACE) )
    (MAKE-SET-FORM PLACE (LIST 'SUB1 PLACE)) )
  ((ATOM PLACE)
    (LIST 'DECQ PLACE N) )
  (MAKE-SET-FORM PLACE (LIST '- PLACE N)) )


; Section 5.12.5:  Irrational and Transcendental Functions

(DEFUN GET-CONSTANT (CONSTANT FORM)
;GET-CONSTANT returns the value of numerical constant, accurate to the
;current precision.
  ((EQL (PRECISION) (GET CONSTANT 'PRECISION))
    (EVAL CONSTANT) )
  (SET CONSTANT
       (IF (AND (GET CONSTANT 'PRECISION)
		(< (PRECISION) (GET CONSTANT 'PRECISION)) )
	   (/ (NUMERATOR (EVAL CONSTANT)) (DENOMINATOR (EVAL CONSTANT)))
	   (EVAL FORM) ))
  (PUT CONSTANT 'PRECISION (PRECISION))
  (EVAL CONSTANT) )


(DEFUN EXP (N)
;(EXP n) returns e^n, accurate to the current precision.
  ((NUMBERP N)
    ((ZEROP N) 1)
    ((PLUSP (PRECISION))
      ((MINUSP N)
	(/ 1 (EXP (- N))) )
      ((= N 1)
	(GET-CONSTANT 'E '(EXP-AUX 1)) )
      ((> N 1)
	(LET ((Q (DIVIDE (NUMERATOR N) (DENOMINATOR N))))
	  (* (EXPT-AUX (GET-CONSTANT 'E '(EXP-AUX 1)) (CAR Q))
	     (EXP-AUX (/ (CDR Q) (DENOMINATOR N)))) ) )
      (EXP-AUX N) )
    (BREAK (LIST 'EXP N) "Infinite Precision") )
  (BREAK (LIST 'EXP N) "Nonnumeric Argument") )

(DEFUN EXP-AUX (N
;If 0<n<=1, (EXP-AUX n) returns e^n, accurate to the current
;precision, using the fact that EXP (p/q) =
;((...(((q+p)2q+p^2)3q+p^3)4q+...+p^(m-1))mq + p^m) / (m! q^m),
    P Q M TERM NUMR DENR PRECISION BITLENGTH )
  (SETQ PRECISION (* 32 (PRECISION))
	M 1
	P (NUMERATOR N)
	Q (DENOMINATOR N)
	TERM P
	NUMR (+ P Q)
	DENR Q )
  (LOOP
    (INCQ M)
    (SETQ TERM (* P TERM)
	  NUMR (+ TERM (* Q NUMR M))
	  DENR (* Q DENR M)
	  BITLENGTH (- PRECISION (INTEGER-LENGTH DENR)) )
    ( ((MINUSP BITLENGTH)
	(SETQ TERM (SHIFT TERM BITLENGTH)
	      DENR (SHIFT DENR BITLENGTH)
	      NUMR (SHIFT NUMR BITLENGTH) ) ) )
    ((ZEROP TERM)
      (/ NUMR DENR) ) ) )

(IF (PLUSP (PRECISION)) (EXP 1))		;Initialize the variable E


(DEFUN EXPT (N M)
;(EXPT n m) returns n^m.
  ((AND (NUMBERP N) (NUMBERP M))
    ((ZEROP M) 1)
    ((ZEROP N)
      ((MINUSP M)
	(BREAK (LIST 'EXPT N M) "Zero Divide") )
      0 )
    ((MINUSP M)
      (/ 1 (EXPT-AUX N (- M))) )
    (EXPT-AUX N M) )
  (BREAK (LIST 'EXPT N M) "Nonnumeric Argument") )

(DEFUN EXPT-AUX (N M
;If m>0, (EXPT-AUX n m) returns n^m.  If m is a ratio the result may
;be only an approximation to n^m, accurate to the current precision.
    ANS )
  ((= N 1) 1)
  ((INTEGERP M)
    ((= M 1) N)
    (SETQ ANS 1)
    (LOOP				;Binary power method
      ( ((ODDP M)
	  (SETQ ANS (* N ANS)) ) )
      ((ZEROP (SETQ M (SHIFT M -1))) ANS)
      (SETQ N (* N N)) ) )
  ((PLUSP (PRECISION))
    ((MINUSP N)
      ((ODDP (DENOMINATOR M))
	((EVENP (NUMERATOR M))
	  (EXP (* M (LN-AUX (- N)))) )
	(- (EXP (* M (LN-AUX (- N))))) )
      (BREAK (LIST 'EXPT N M) "Invalid Argument") )
    (EXP (* M (LN-AUX N))) )
  (BREAK (LIST 'EXPT N M) "Infinite Precision") )


(DEFUN LOG (N M)
;(LOG n m) returns base m logarithm of n.  m defaults to e, the base
;of the natural logarithms.
  (SETQ N (LN N))
  ((NULL M) N)
  ((ZEROP M) 0)
  (/ N (LN M)) )

(DEFUN LN (N)
;(LN n) returns ln n, the natural logarithm of n.
  ((NUMBERP N)
    ((PLUSP N)
      ((= N 1) 0)
      ((PLUSP (PRECISION))
	((= N 2)
	  (GET-CONSTANT 'LN2 '(LN-AUX 2)) )
	(LN-AUX N) )
      (BREAK (LIST 'LN N) "Infinite Precision") )
    (BREAK (LIST 'LN N) "Invalid Argument") )
  (BREAK (LIST 'LN N) "Nonnumeric Argument") )

(DEFUN LN-AUX (N
;If n>0, (LN-AUX n) returns ln n, accurate to the current precision,
;using the fact that with p/q = (x-1)/(x+1) = u,
;LN x = 2 (u + u^3/3 + u^5/5 + ... + u^m/m) =
;(...(((6pq^2 + 2p^3)5q^2 + 2 3p^5)7q^2 + 2 3 5p^7)9q^2 +
;	...+2 3 5 ...(m-2)p^m) / (3 5 ...m q^m),
    P Q PLEN QLEN SHIFT M TERM NUMR DENR PRECISION BITLENGTH )
  ((= N 2)
    (SETQ PRECISION (* 32 (PRECISION))
	  M 11
	  TERM 945
	  NUMR 638195436
	  DENR 1841443065 )
; LN 2 ~= (2/9) (1 + (1/9)/3 + (1/9)^2/5 + ... + (1/9)^m/(2m+1)) =
;   2 (...(((9 3 + 1)9 5 + 3)9 7 + 3 5)9 9 + ... + 3 5 ...(2m-1))
;   / (3 5 ...(2m+1) 3^(2m+1)),  with single-precision head start
    (LOOP
      (SETQ TERM (* M TERM)
	    M (+ M 2)
	    NUMR (+ TERM (* 9 M NUMR))
	    DENR (* 9 M DENR)
	    BITLENGTH (- PRECISION (INTEGER-LENGTH NUMR)) )
      ( ((MINUSP BITLENGTH)
	  (SETQ	TERM (SHIFT TERM BITLENGTH)
		NUMR (SHIFT NUMR BITLENGTH)
		DENR (SHIFT DENR BITLENGTH) ) ) )
      ((ZEROP TERM)
	(/ (SHIFT NUMR 1) DENR) ) ) )
  ((< (NUMERATOR N) (DENOMINATOR N))
    (- (LN-AUX (/ 1 N))) )
  (SETQ PRECISION (* 32 (PRECISION))
	SHIFT 0
	P (NUMERATOR N)
	Q (DENOMINATOR N)
	PLEN (INTEGER-LENGTH P)
	QLEN (INTEGER-LENGTH Q) )
  ( ((> PLEN QLEN)			;Make  3/4 < N <= 3/2:
      ((> (SHIFT P 1) (* 3 Q))
	(SETQ SHIFT (- PLEN QLEN))
	((> PLEN PRECISION)
	  (SETQ P (SHIFT P (- PRECISION PLEN))
		Q (SHIFT Q (- PRECISION QLEN)))
	  ((> (SHIFT P 1) (* 3 Q))
	    (SETQ SHIFT (ADD1 SHIFT)
		  N (/ P (SHIFT Q 1))) )
	  ((< (SHIFT P 2) (* 3 Q))
	    (SETQ SHIFT (SUB1 SHIFT)
		  N (/ P (SHIFT Q -1))) )
	  (SETQ N (/ P Q)) )
	((> (SHIFT P 1) (* 3 (SETQ Q (SHIFT Q SHIFT))))
	  (SETQ SHIFT (ADD1 SHIFT)
		N (/ P (SHIFT Q 1))) )
	((< (SHIFT P 2) (* 3 Q))
	  (SETQ SHIFT (SUB1 SHIFT)
		N (/ P (SHIFT Q -1))) )
	(SETQ N (/ P Q)) ) )
    ((> (SHIFT P 1) (* 3 Q))
      (SETQ SHIFT 1
	    N (/ P (SHIFT Q 1))) ) )
  (SETQ N (/ (- (NUMERATOR N) (DENOMINATOR N))
	     (+ (NUMERATOR N) (DENOMINATOR N)))
	PLEN (* N N)
	P (NUMERATOR PLEN)
	Q (DENOMINATOR PLEN)
	NUMR (SHIFT (NUMERATOR N) 1)
	TERM NUMR
	DENR (DENOMINATOR N)
	PRECISION (- PRECISION (INTEGER-LENGTH SHIFT))
	M 1)
  (LOOP
    (SETQ TERM (* M TERM P)
	  M (+ M 2)
	  NUMR (+ TERM (* NUMR Q M))
	  DENR (* M Q DENR)
	  BITLENGTH (- PRECISION (INTEGER-LENGTH NUMR)))
    ( ((MINUSP BITLENGTH)
	(SETQ TERM (SHIFT TERM BITLENGTH)
	      NUMR (SHIFT NUMR BITLENGTH)
	      DENR (SHIFT DENR BITLENGTH)) ) )
    ((ZEROP TERM)
      ((ZEROP SHIFT)
	(/ NUMR DENR) )
      (+ (* SHIFT (GET-CONSTANT 'LN2 '(LN-AUX 2))) (/ NUMR DENR)) ) ) )

(IF (PLUSP (PRECISION)) (LN 2))		;Initialize the variable LN2


(DEFUN SQRT (N)
;If n is positive, (SQRT n) returns square root of n.
  (EXPT N 1/2) )


(DEFUN ISQRT (N)
;If n is a nonnegative integer, (ISQRT n) returns the greatest integer
;less than or equal to the positive square root of n.
  ((INTEGERP N)
    ((>= N 0)
      ((= N 0) 0)
      (ISQRT-AUX N) )
    (BREAK (LIST 'ISQRT N) "Invalid Argument") )
  (BREAK (LIST 'ISQRT N) "Noninteger Argument") )

(DEFUN ISQRT-AUX (N
;If n is a positive integer, (ISQRT-AUX n) returns the greatest integer
;less than or equal to n^(1/2).  ISQRT-AUX uses Newton's method.
    SHIFT INC ANS)
  (SETQ ANS 1
	INC 1
	SHIFT (* (- (TRUNCATE (SUB1 (INTEGER-LENGTH N)) 2)) 2) )
  (LOOP		;Start with 1-bit precision & repeatedly doubling
    ((ZEROP SHIFT))
    (SETQ ANS (SHIFT ANS INC)
	  SHIFT (+ SHIFT (SHIFT INC 1))
	  ANS (+ ANS (FLOOR (- (SHIFT N SHIFT) (* ANS ANS)) (* 2 ANS)))
	  INC (MIN (SHIFT INC 1) (TRUNCATE (- SHIFT) 2)) ) )
  ((<= (* ANS ANS) N) ANS)
  (SUB1 ANS) )

(DEFUN PI ()
;(PI) returns pi, accurate to the current precision.
  ((PLUSP (PRECISION))
    (GET-CONSTANT 'PI '(PI-AUX)) )
  (BREAK (CONS 'PI) "Infinite Precision") )

(DEFUN PI-AUX (
;(PI-AUX) returns pi, using the fact that 4/pi =
;SIGMA ((-1)^m (1123 + 21460 m) (1 3 ...(2m-1)) (1 3 ...(4m-1))
;  / ((882^(2m+1) 32^m (m!)^3), m, 0, PINF), rearranged over a common
;denominator (Ramanujan, Quart. J. Pure & Appl. Math. 45, p. 350, 1914).
    N M TERM NUMR DENR PRECISION BITLENGTH )
  (SETQ PRECISION (* 32 (PRECISION))
	M 0
	N 1123
	TERM 1
	NUMR 3528
	DENR N )
  (LOOP
    (INCQ M)
    (SETQ N (+ N 21460)
	  TERM (* TERM (- (+ M M) 1) (- 1 (* 4 M)) (- (* 4 M) 3))
	  BITLENGTH (* M M M 24893568)
	  NUMR (* NUMR BITLENGTH)
	  DENR (+ (* DENR BITLENGTH) (* N TERM))
	  BITLENGTH (- (+ PRECISION (INTEGER-LENGTH N)) (INTEGER-LENGTH DENR)) )
    ( ((MINUSP BITLENGTH)
	(SETQ TERM (SHIFT TERM BITLENGTH)
	      DENR (SHIFT DENR BITLENGTH)
	      NUMR (SHIFT NUMR BITLENGTH)) ) )
    ((ZEROP TERM)
      (/ NUMR DENR) ) ) )

(IF (PLUSP (PRECISION)) (PI))		;Initialize the variable PI


(DEFUN SIN (N
; (SIN n) returns the sine of n radians.
    Q )
  ((NUMBERP N)
    ((ZEROP N) 0)
    ((PLUSP (PRECISION))
      (SETQ Q (/ N (/ (PI) 4))
	    N (DIVIDE (NUMERATOR Q) (DENOMINATOR Q)))
      (SINCOS (MOD (CAR N) 8) (/ (CDR N) (DENOMINATOR Q))) )
    (BREAK (LIST 'SIN N) "Infinite Precision") )
  (BREAK (LIST 'SIN N) "Nonnumeric Argument") )

(DEFUN COS (N
; (COS n) returns the cosine of n radians.
    Q )
  ((NUMBERP N)
    ((ZEROP N) 1)
    ((PLUSP (PRECISION))
      (SETQ Q (/ N (/ (PI) 4))
	    N (DIVIDE (NUMERATOR Q) (DENOMINATOR Q)))
      (SINCOS (MOD (+ 2 (CAR N)) 8) (/ (CDR N) (DENOMINATOR Q))) )
    (BREAK (LIST 'COS N) "Infinite Precision") )
  (BREAK (LIST 'COS N) "Nonnumeric Argument") )

(DEFUN TAN (N)
; (TAN n) returns the tangent of n radians.
  (/ (SIN N) (COS N)) )


(DEFUN SINCOS (N Q)
; Returns the sine or cosine of an appropriately reduced angle.
  ((> N 3)
    (- (SINCOS (- N 4) Q)) )
  ((ZEROP N)
    (SETQ Q (* Q (/ (PI) 4)))
    (SINCOS-AUX Q 1 (NUMERATOR Q) (DENOMINATOR Q)) )
  ((EQ N 1)
    (SINCOS-AUX (* (- 1 Q) (/ (PI) 4)) 0 1 1) )
  ((EQ N 2)
    (SINCOS-AUX (* Q (/ (PI) 4)) 0 1 1) )
  (SETQ Q (* (- 1 Q) (/ (PI) 4)))
  (SINCOS-AUX Q 1 (NUMERATOR Q) (DENOMINATOR Q)) )

(DEFUN SINCOS-AUX (ARG N NUMR DENR
; (SIN1 n) returns the sine of n radians, where 0 <= n <= pi/4 radians.
; SIN (x=p/q) ~= x - x^3/3! + x^5/5! - ... +|- x^n/n! =
; ((...((2*3pq^2 - p^3)4*5q^2 + p^5)6*7q^2 - ...)(n-1)nq^2 +|- p^n) / (n! q^n)
; (COS1 n) returns the cosine of n radians, where 0 <= n <= pi/4 radians.
; COS (x=p/q) ~= 1 - x^2/2! + x^3/3! - ... +|- x^n/n! =
; ((...((2q^2 - p^2)3*4q^2 + p^4)5*6q^2 - ...)(n-1)nq^2 +|- p^n) / (n! q^n)
    MNARGSQ DARGSQ TERM PRECISION BITLENGTH )
  (SETQ PRECISION (* 32 (PRECISION))
	DARGSQ (* ARG ARG)
	MNARGSQ (- (NUMERATOR DARGSQ))
	DARGSQ (DENOMINATOR DARGSQ)
	TERM NUMR)
  (LOOP
    (SETQ N (+ N 2)
	  ARG (* (SUB1 N) N)
	  DENR (* ARG DARGSQ DENR)
	  TERM (* MNARGSQ TERM)
	  NUMR (+ (* ARG DARGSQ NUMR) TERM)
	  BITLENGTH (- PRECISION (INTEGER-LENGTH NUMR)))
    ( ((MINUSP BITLENGTH)
	(SETQ TERM (SHIFT TERM BITLENGTH)
	      NUMR (SHIFT NUMR BITLENGTH)
	      DENR (SHIFT DENR BITLENGTH)) ) )
    ((ZEROP TERM)
      (/ NUMR DENR) ) ) )


(DEFUN ASIN (N)
; (ASIN n) returns the inverse sine of n in radians.  Note that
; for all -1 <= n <= 1, -pi/2 <= (ASIN n) <= pi/2.
  ((NUMBERP N)
    ((PLUSP (PRECISION))
      ((MINUSP N)
	(- (ASIN (- N))) )
      ((= N 1)
	(/ (PI) 2) )
      ((< N 1)
	(ATAN (NUMERATOR N)
	      (SQRT (* (- (DENOMINATOR N) (NUMERATOR N))
		       (+ (DENOMINATOR N) (NUMERATOR N))))) )
      (BREAK (LIST 'ASIN N) "Invalid Argument") )
    (BREAK (LIST 'ASIN N) "Infinite Precision") )
  (BREAK (LIST 'ASIN N) "Nonnumeric Argument") )

(DEFUN ACOS (N)
; (ACOS n) returns the inverse cosine of n in radians.  Note that
; for all -1 <= n <= 1, 0 <= (ACOS n) <= pi.
  ((NUMBERP N)
    ((= N 1) 0)
    ((PLUSP (PRECISION))
      ((= N -1)
	(PI) )
      ((<= -1 N 1)
	((< (ABS N) 1)
	  (ATAN (SQRT (* (- (DENOMINATOR N) (NUMERATOR N))
			 (+ (DENOMINATOR N) (NUMERATOR N)) ))
		(NUMERATOR N)) ) )
      (BREAK (LIST 'ACOS N) "Invalid Argument") )
    (BREAK (LIST 'ACOS N) "Infinite Precision") )
  (BREAK (LIST 'ACOS N) "Nonnumeric Argument") )


(DEFUN ATAN (N M
; (ATAN n m) returns in radians the angle corresponding to the vector
; whose opposite component is n and whose adjacent component is m.
; m defaults to 1.  Note that for all n and m, -pi < (ATAN n m) <= pi.
; With v = x/(1+x^2) = r/s,  u = xv = p/q,  ATAN (x) ~=
; (1 + 2u/3 + 2 4u^2/(3 5) +...+ 2 4 ...(2n)u^n/(3 5 ...(2n+1))) v =
; ((...((3rq + 2rp)5q + 2 4rp^2)7q +...)(2n+1)q + 2 4 ...(2n)rp^n)
; / (3 5 ...(2n+1)sq^n)
   INDX NUMR TERM DENR NARG DARG PRECISION BITLENGTH )
  ((PLUSP (PRECISION))
    ((NUMBERP N)
      ((NUMBERP M)	;Reduce two-argument case to one argument
	((PLUSP M)
	  (ATAN (/ N M)) )
	((ZEROP M)
	  ((PLUSP N)
	    (/ (PI) 2) )
	  ((MINUSP N)
	    (/ (PI) -2) )
	  (BREAK (LIST 'ATAN N M) "Invalid Argument") )
	((ZEROP N)
	  (PI) )
	((MINUSP N)
	   (- (/ (PI) -2) (ATAN (/ M N))) )
	(+ (/ (PI) 2) (ATAN (/ (- M) N))) )
      ((NULL M)
	((MINUSP N)
	  (- (ATAN (- N))) )
	((> N 1)
	  (- (/ (PI) 2) (ATAN (/ 1 N))) )
	(SETQ PRECISION (* 32 (PRECISION))
	      M (/ N (ADD1 (* N N)))
	      N (* N M)
	      NARG (NUMERATOR N)
	      DARG (DENOMINATOR N)
	      INDX 1
	      NUMR (NUMERATOR M)
	      TERM NUMR
	      DENR (DENOMINATOR M) )
	(LOOP
	  (INCQ INDX 2)
	  (SETQ TERM (* (SUB1 INDX) NARG TERM)
		NUMR (+ TERM (* INDX DARG NUMR))
		DENR (* INDX DARG DENR)
		BITLENGTH (- PRECISION (INTEGER-LENGTH NUMR)))
	  ( ((MINUSP BITLENGTH)
	      (SETQ NUMR (SHIFT NUMR BITLENGTH)
		    DENR (SHIFT DENR BITLENGTH)
		    TERM (SHIFT TERM BITLENGTH)) ) )
	  ((ZEROP TERM)
	    (/ NUMR DENR) ) ) )
      (BREAK (LIST 'ATAN N M) "Nonnumeric Argument") )
    (BREAK (LIST 'ATAN N M) "Nonnumeric Argument") )
  (BREAK (LIST 'ATAN N M) "Infinite Precision") )


; Section 5.12.7:  Bitwise Logical Functions

(MOVD 'SHIFT 'ASH)


; Section 5.12.8:  Random Numbers

(DEFUN RANDOM (N STATE
    BL COUNT ANS)
  (IF (RANDOM-STATE-P STATE)
      (SETQ *RANDOM-STATE* STATE) )
  (SETQ *RANDOM-STATE*
		(LOGAND (ADD1 (* 3141592653 *RANDOM-STATE*)) 4294967295))
  ((AND (INTEGERP N) (PLUSP N))
    (SETQ ANS *RANDOM-STATE*
	  BL (- -10 (INTEGER-LENGTH N))
	  COUNT 0)
    (LOOP			; concatenate 32-bit random integers
      ((> BL (DECQ COUNT 32))
	(SHIFT (* N ANS) COUNT) )
      (SETQ *RANDOM-STATE*
	      (LOGAND (ADD1 (* 3141592653 *RANDOM-STATE*)) 4294967295)
	    ANS (+ (SHIFT ANS 32) *RANDOM-STATE*)) ) )
  ((NUMBERP N)
    (SETQ ANS (SHIFT 1 (- (* 32 (MAX (PRECISION) 1)) 10)))
    (/ (* (ABS N) (RANDOM ANS)) ANS) ) )

(DEFUN MAKE-RANDOM-STATE (STATE)
  ((NULL STATE) *RANDOM-STATE*)
  ((EQ STATE 'T)
    (TIME) )
  ((RANDOM-STATE-P STATE) STATE) )

(SETQ *RANDOM-STATE* (MAKE-RANDOM-STATE 'T))

(DEFUN RANDOM-STATE-P (OBJ)
  (AND (INTEGERP OBJ) (>= OBJ 0)) )


; Section 5.13.2:  Input Functions

(SETQ *LPAR* '\()
(SETQ *RPAR* '\))

(DEFUN READ-BACKQUOTE (
; This backquote facility conforms to the Common LISP standard except
; that nested backquote forms are not supported.  See Section 22.1.3
; of Common LISP by Steele [1984].
    CHAR FORM-LIST )
  (SETQ CHAR (PEEK-CHAR T))
  ((EQ CHAR '\,)
    (READ-CHAR)
    (SETQ CHAR (PEEK-CHAR))
    ((OR (EQ CHAR '\@) (EQ CHAR '\.))
      (BREAK CHAR "Syntax Error") )
    (READ) )
  ((NEQ CHAR *LPAR*)
    (LIST 'QUOTE (READ)) )
  (READ-CHAR)
  (LOOP
    (SETQ CHAR (PEEK-CHAR T))
    ((EQ CHAR *RPAR*)
      (READ-CHAR)
      ((NULL FORM-LIST) NIL)
      ((NULL (CDR FORM-LIST))
	(CAR FORM-LIST) )
      (CONS 'NCONC (NREVERSE FORM-LIST)) )
    ((EQ CHAR '\.)
      (READ-CHAR)
      (SETQ CHAR (PEEK-CHAR T))
      ((EQ CHAR '\,)
	(READ-CHAR)
	(SETQ CHAR (PEEK-CHAR))
	((OR (EQ CHAR '\@) (EQ CHAR '\.))
	  (BREAK CHAR "Syntax Error") )
	(PUSH (READ) FORM-LIST)
	((EQ (READ-CHAR) *RPAR*)
	  (CONS 'NCONC (NREVERSE FORM-LIST)) )
	(BREAK '\. "Syntax Error") )
      (PUSH (READ-BACKQUOTE) FORM-LIST)
      ((EQ (READ-CHAR) *RPAR*)
	(CONS 'NCONC (NREVERSE FORM-LIST)) )
      (BREAK '\. "Syntax Error") )
    ( ((EQ CHAR '\,)
	(READ-CHAR)
	(SETQ CHAR (PEEK-CHAR))
	((EQ CHAR '\@)
	  (READ-CHAR)
	  (PUSH (READ) FORM-LIST)
	  ((EQ (PEEK-CHAR T) *RPAR*))
	  (PUSH (LIST 'COPY-LIST (POP FORM-LIST)) FORM-LIST) )
	((EQ CHAR '\.)
	  (READ-CHAR)
	  (PUSH (READ) FORM-LIST) )
	(PUSH (LIST 'LIST (READ)) FORM-LIST) )
      (PUSH (LIST 'LIST (READ-BACKQUOTE)) FORM-LIST) ) ) )

(SET-MACRO-CHAR '\` '(LAMBDA ()
  (READ-BACKQUOTE) ))


; Section 5.15.1:  Evaluation Recognizers

(DEFUN EVAL-FUNCTION-P (SYM)
  (EQ (GETD SYM T) 'LAMBDA) )

(DEFUN NO-EVAL-FUNCTION-P (SYM)
  (EQ (GETD SYM T) 'NLAMBDA) )

(DEFUN MACRO-FUNCTION-P (SYM)
  (EQ (GETD SYM T) 'MACRO) )

(DEFUN SPECIAL-FORM-P (SYM)
  (EQ (GETD SYM T) 'SPECIAL) )

(DEFUN FBOUNDP (SYM)
  (GETD SYM T) )

(DEFUN FUNCTIONP (OBJ)
  ((SYMBOLP OBJ))
  ((ATOM OBJ) NIL)
  (EQ (CAR OBJ) 'LAMBDA) )


; Section 5.15.2:  Evaluation and Function Application

(DEFUN SYMBOL-VALUE (SYM)
  ((SYMBOLP SYM)
    (CAR SYM) ) )

(DEFUN SYMBOL-PLIST (SYM)
  ((SYMBOLP SYM)
    (CDR SYM) ) )

(DEFUN SYMBOL-FUNCTION (SYM)
  ((SYMBOLP SYM)
    ((FBOUNDP SYM)
      (GETD SYM) )
    (BREAK (LIST 'SYMBOL-FUNCTION SYM) "Undefined Function") ) )


; Section 5.15.3:  Macro Expansion Functions

(DEFUN MACRO-FUNCTION (SYM)
  ((MACRO-FUNCTION-P SYM)
    (GETD SYM) ) )


; Section 5.16:  Control Constructs

(DEFMACRO PROG2 (FORM1 . FORMS)
  (LIST 'PROGN FORM1 (CONS 'PROG1 FORMS)) )

(DEFMACRO WHEN (TEST . BODY)
  (LIST 'IF TEST (CONS 'PROGN BODY)) )

(DEFMACRO UNLESS (TEST . BODY)
  (LIST 'IF TEST NIL (CONS 'PROGN BODY)) )

(DEFMACRO LET (LETLIST . BODY)
   (CONS (LIST* 'LAMBDA
		(MAPCAR 'CAR LETLIST)
		BODY)
	 (MAPCAR 'CADR LETLIST)) )

(DEFMACRO LET* (LETLIST . BODY)
   (LIST (LIST* 'LAMBDA
		(MAPCAR 'CAR LETLIST)
		(CONS 'SETQ
		      (MAPCAN '(LAMBDA (LST) (LIST (CAR LST) (CADR LST)))
			      LETLIST))
		BODY)) )

(DEFMACRO DO (LETLIST . BODY)
  (CONS (LIST 'LAMBDA
	      (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR))) LETLIST)
	      (CONS 'LOOP
		    (APPEND BODY (LIST (CONS 'PSETQ
			(MAPCAN '(LAMBDA (VAR)
				   ((ATOM VAR) NIL)
				   ((CADDR VAR)
				     (LIST (CAR VAR) (CADDR VAR)) ) )
				LETLIST))))))
	(MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) NIL (CADR VAR))) LETLIST)) )

(DEFMACRO DO* (LETLIST . BODY)
  (LIST (LIST 'LAMBDA
	      (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR)))
		      LETLIST)
	      (CONS 'SETQ
		    (MAPCAN '(LAMBDA (VAR)
			       ((ATOM VAR)
				 (LIST VAR NIL) )
			       (LIST (CAR VAR) (CADR VAR)))
			    LETLIST))
	      (CONS 'LOOP
		    (APPEND BODY (LIST (CONS 'SETQ
			(MAPCAN '(LAMBDA (VAR)
				   ((ATOM VAR) NIL)
				   ((CADDR VAR)
				     (LIST (CAR VAR) (CADDR VAR)) ) )
				LETLIST))))))) )

(DEFMACRO DOLIST ((VAR LISTFORM RSLTFORM) . BODY)
  (LET ((DOLIST (GENSYM)))
    (LIST 'LET
	  (LIST (LIST DOLIST LISTFORM))
	  (LIST* 'LOOP
		 (LIST (LIST 'ATOM DOLIST) RSLTFORM)
		 (LIST 'SETQ VAR (LIST 'POP DOLIST))
		 BODY)) ) )

(DEFMACRO DOTIMES ((VAR COUNTFORM RSLTFORM) . BODY)
  (LET ((DOTIMES (GENSYM)))
    (LIST 'LET
	  (LIST (LIST VAR 0)
		(LIST DOTIMES COUNTFORM))
	  (LIST* 'LOOP
		 (LIST (LIST '>= VAR DOTIMES) RSLTFORM)
		 (APPEND BODY (LIST (LIST 'INCQ VAR))))) ) )


; PROG [var-list, expn1, expn2, ..., expnm]  sets the local variables
; in <var-list> to NIL and sequentially evaluates <expn1> through <expnm>,
; unless the functions GO or RETURN are encountered.  This PROG interpreter
; is included for completeness.  We strongly recommend that functions using
; PROG be translated into equivalent muLISP functions using the LOOP
; construct, since the resulting function will be much more efficient.

(DEFUN PROG (NLAMBDA LST$
  (EVAL (LIST (CONS 'LAMBDA (LIST (CAR LST$) (LIST 'PROG-AUX
      '(CDR LST$)))))) ))

(DEFUN PROG-AUX (BDY$
    LST$ GO-LABEL$ ANS$)
  (SETQ LST$ BDY$)
  (LOOP
    ((NULL LST$) ANS$)
    (SETQ ANS$ (EVAL (POP LST$)))
    ( ((NULL GO-LABEL$))
      (SETQ LST$ (CDR (MEMBER GO-LABEL$ BDY$))
	    GO-LABEL$) ) ) )


;GO [label]  if within a PROG, transfers control to the expression in
;the PROG body immediately following <label>.

(DEFUN GO (NLAMBDA (LABEL$)
  (SETQ GO-LABEL$ LABEL$) ))


(SETQ *COMMMAND-DRIVE* "")

(DEFUN DOS (COMMAND
; (DOS command) executes the MS-DOS <command>, and returns the exit code.
; If the MS-DOS command processor is not on the default drive, the user
; is prompted for the drive containing COMMAND.COM.  See the EXECUTE
; function in Section 5.16 for an example using DOS.
    READ-CHAR RDS WRS )
  (LOOP
    ((EXECUTE (PACK* *COMMAND-DRIVE* "COMMAND.COM")
	      (IF COMMAND (PACK* "/C " COMMAND))))
    (FRESH-LINE)
    (WRITE-STRING "Enter COMMAND.COM drive letter: ")
    (SETQ *COMMAND-DRIVE* (PRINC (CHAR-UPCASE (READ-CHAR))))
    (TERPRI)
    ((NOT (ALPHA-CHAR-P *COMMAND-DRIVE*)) NIL)
    (SETQ *COMMAND-DRIVE* (PACK* *COMMAND-DRIVE* '\:)) ) )


; Section 22.4:  Querying the User

(DEFUN Y-OR-N-P (MSG
    CHAR READ-CHAR RDS WRS )
  ( ((NULL MSG))
    (FRESH-LINE)
    (WRITE-STRING (PACK* MSG " (Y/N) ")) )
  (CLEAR-INPUT)
  (LOOP
    (SETQ CHAR (CHAR-UPCASE (READ-CHAR)))
    ((EQ CHAR 'Y) (WRITE-LINE CHAR) T)
    ((EQ CHAR 'N) (WRITE-LINE CHAR) NIL)
    (WRITE-BYTE 7) ) )

(DEFUN YES-OR-NO-P (MSG
    LINE READ-CHAR RDS WRS )
  (SETQ READ-CHAR T)
  (CLEAR-INPUT)
  (LOOP
    ( ((NULL MSG))
      (FRESH-LINE)
      (WRITE-STRING (PACK* MSG " (Yes or No) ")) )
    (WRITE-BYTE 7)
    (SETQ LINE (CHAR-UPCASE (READ-LINE)))
    ((EQ LINE 'YES) T)
    ((EQ LINE 'NO) NIL) ) )

(RDS)
