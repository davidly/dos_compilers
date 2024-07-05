; File: MULISP83.LSP (C)	12/29/85	Soft Warehouse, Inc.

;			muLISP-83 Compatibility File


; This file makes it possible for muLISP-86 to run muLISP-83 programs
; with no or only a few changes required.  WARNING: This file should
; NOT be read into a running muLISP-86 system more than once.

(SETQ *READ-UPCASE* NIL)	;Turns off auto uppercase conversion.
(SETQ *PRINT-ESCAPE* NIL)	;Turns off printing of escape chars.
(SETQ PUTD NIL)			;Turns on full D-code condensing.

(COPY-CHAR-TYPE '\" '\|)	;Make " a multiple escape char.

(CSMEMORY 849 (ASCII '\"))	;Display multiple escape char as ".

(COPY-CHAR-TYPE '\| 'A)		;Make | not a multiple escape char.

(COPY-CHAR-TYPE (ASCII 12) 'A)	;Make <page> a constituent char.

(COPY-CHAR-TYPE '"," '" ")	;Make , a whitespace char.

				;Set up muLISP-83 break chars.
(SET-BREAK-CHARS (CONS (ASCII 26)
  '(! $ & "(" ")" * + "," - "." / : < = > ? @ "[" \\ "]" ^ _ ` { | } ~)))

				;Make % a comment delimiter.
(SET-MACRO-CHAR '"%" '(LAMBDA () (PEEK-CHAR '"%") (READ-CHAR)) 'COMMENT)

				;Make ' a NONterminating macro char.
(SET-MACRO-CHAR '"'" (GET-MACRO-CHAR '"'") T)

(PUTD 'READ-LST (GET-MACRO-CHAR '"("))

(PUTD 'READ-BRACKET '(LAMBDA (EXPN)
  (SETQ EXPN (READ-LST))
  ((EQ (PEEK-CHAR 'T) '"]")
    (READ-CHAR) EXPN)
  (CONS EXPN (READ-BRACKET)) ))

(SET-MACRO-CHAR '"[" (GETD READ-BRACKET))  ;Make [ a super-parenthesis.

(MOVD 'SYMBOLP 'NAME)
(MOVD 'EQL 'EQ)
(MOVD 'IDENTITY 'NONNULL)
(MOVD '< 'LESSP)
(MOVD '> 'GREATERP)
(MOVD '+ 'PLUS)
(MOVD '- 'DIFFERENCE)
(MOVD '- 'MINUS)
(MOVD '* 'TIMES)
(MOVD 'CLEAR-SCREEN 'CLRSCRN)
(MOVD 'SET-CURSOR 'CURSOR)


; WARNING: The '86 functions TRUNCATE, REM, and DIVIDE return different
; values than the '83 functions QUOTIENT, REMAINDER, and DIVIDE when
; given negative arguments.  See the Reference Manual for details.

(MOVD 'TRUNCATE 'QUOTIENT)
(MOVD 'REM 'REMAINDER)

(MOVD 'MEMBER 'MEMBER-AUX)
(PUTD 'MEMBER '(LAMBDA (ITEM LST)
  (MEMBER-AUX ITEM LST 'EQUAL) ))

(MOVD 'ASSOC 'ASSOC-AUX)
(PUTD 'ASSOC '(LAMBDA (ITEM LST)
  (ASSOC-AUX ITEM LST 'EQUAL) ))

(MOVD 'APPEND 'APPEND-AUX)
(PUTD 'APPEND '(LAMBDA LST
  ((NULL (CDR LST))
    (COPY-LIST (CAR LST)) )
  (APPLY 'APPEND-AUX LST) ))

(PUTD 'NTH '(LAMBDA (ARG1 ARG2)
  ((NUMBERP ARG2)
    (NTHCDR (SUB1 ARG2) ARG1) )
  (CAR (NTHCDR ARG1 ARG2)) ))

(MOVD 'SUBSTRING 'SUBSTRING-AUX)
(PUTD 'SUBSTRING '(LAMBDA (ARG N M)
  ((NUMBERP N)
    ((NUMBERP M)
      (SUBSTRING-AUX ARG (SUB1 N) (SUB1 M)) )
    (SUBSTRING-AUX ARG (SUB1 N)) )
  ((NUMBERP M)
    (SUBSTRING-AUX ARG N (SUB1 M)) )
  (SUBSTRING-AUX ARG) ))

(MOVD 'FINDSTRING 'FINDSTRING-AUX)
(PUTD 'FINDSTRING '(LAMBDA (ARG1 ARG2 N)
  ( ((NUMBERP N)
      (DECQ N) ) )
  (SETQ N (FINDSTRING-AUX ARG1 ARG2 N))
  ((NUMBERP N)
    (ADD1 N) )
  N ))

(PUTD 'READCH '(LAMBDA (FLAG
    READ-CHAR )
  (SETQ READ-CHAR READCH)
  (SETQ RATOM (READ-CHAR FLAG))
  ((LESSP 47 (ASCII RATOM) 58)
    (SETQ RATOM (DIFFERENCE (ASCII RATOM) 48)) )
  ((NULL READ)
    (SETQ RATOM (STRING-UPCASE RATOM)) )
  RATOM ))

(PUTD 'READP '(LAMBDA (READ-CHAR)
  (SETQ READ-CHAR READCH)
  (LISTEN FLAG) ))

(PUTD RADIX '(LAMBDA (NUM)
  (PROG1 *READ-BASE* (SETQ *READ-BASE* NUM *PRINT-BASE* NUM)) ))

(MOVD 'UNDEFINED 'UNDEFINED-AUX)
(PUTD 'UNDEFINED '(LAMBDA #LST#
  ((ATOM (CAR #LST#))
    ((EQ (CAR #LST#) (CAAR #LST#))
      (APPLY UNDEFINED-AUX #LST#) )
    (EVAL (CONS (CAAR #LST#) (CDR #LST#))) )
  (APPLY UNDEFINED-AUX #LST#) ))

(RDS)
