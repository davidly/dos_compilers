;File:  INTERLIS.LSP		12/27/85	Soft Warehouse, Inc.


;			Interlisp Compatiblity File

;References in this file are to the 1978 edition of the Interlisp Reference
;Manual, by Warren Teitelman, published by the Xerox Palo Alto Research
;Center and Bolt, Beranek & Newman.  Each function definition is preceded
;by a brief description of its affect and value.  See the Interlisp
;Reference Manual for a more complete description of the function.



;	Section 5:  Primitive Functions and Predicates

;RPLNODE [object1, object2, object3]  replaces the car of <object1>
;with <object2> and the cdr of <object1> with <object3>.

(DEFUN RPLNODE (OBJ1 OBJ2 OBJ3)
  (RPLACD (RPLACA OBJ1 OBJ2) OBJ3) )


;RPLNODE2 [object1, object2]  replaces the car of <object1> with the
;car of <object2> and the cdr of <object1> with the cdr of <object2>.

(DEFUN RPLNODE2 (OBJ1 OBJ2)
  (RPLACD (RPLACA OBJ1 (CAR OBJ2)) (CDR OBJ2)) )


;KWOTE [object]  returns an expression that when evaluated is <object>.

(DEFUN KWOTE (OBJ)
  ((OR (NULL OBJ) (NUMBERP OBJ)) OBJ)
  (LIST 'QUOTE OBJ) )


;SELECTQ [object, clause1, clause2, ..., default]  based on <object>,
;selects a clause list to be sequentially evaluated.

(DEFUN SELECTQ (NLAMBDA LST$
  (SELECTQ-AUX (EVAL (CAR LST$)) (CDR LST$)) ))

(DEFUN SELECTQ-AUX (OBJ LST)
  ((NULL LST) NIL)
  (LOOP
    ((NULL (CDR LST))
      (EVAL (CAR LST)) )
    ((OR (EQ OBJ (CAAR LST))
	(AND (NOT (ATOM (CAAR LST))) (MEMBER OBJ (CAAR LST))) )
      (SETQ LST (CDAR LST))
      (LOOP
	((NULL (CDR LST))
	  (EVAL (CAR LST)) )
	(EVAL (POP LST)) ) )
    (POP LST) ) )


;SETQQ [name, expression]  a no-eval function that sets <name> to
;<expression>.

(DEFUN SETQQ (NLAMBDA (NAM$ EXP$)
  (SET NAM$ EXP$)
  EXP$ ))


(MOVD 'NAME 'LITATOM)			;Literal atom predicate

(MOVD 'ATOM 'NLISTP)			;No list predicate

(DEFUN NILL NIL				;Returns NIL
  NIL )

(MOVD 'EQL 'EQP)


;EQLENGTH [list, n]  is equivalent to EQ [LENGTH[list], n].

(DEFUN EQLENGTH (LST NUM)
  (LOOP
    ((ATOM LST)
      (ZEROP NUM) )
    ((ZEROP NUM) NIL)
    (POP LST)
    (DECQ NUM) ) )


;EQUALN [object1, object2, n]  is equivalent to EQUAL except that the
;comparison is limited to a depth of <n> levels of recursion.  If that
;depth is exceeded, '? is returned instead.

(DEFUN EQUALN (OBJ1 OBJ2 NUM TEMP)
  (LOOP
    ((ATOM OBJ1)
      (EQ OBJ1 OBJ2) )
    ((ATOM OBJ2) NIL)
    ((NOT (PLUSP NUM))
      '? )
    (DECQ NUM)
    (SETQ TEMP (EQUALN (POP OBJ1) (POP OBJ2) NUM))
    ((OR (NULL TEMP) (EQ TEMP ?)) TEMP) ) )


(MOVD 'MEMBER 'MEMB)


;EQMEMB [atom, list]  returns T if EQ [atom, list] or MEMB [atom, list].
;Otherwise, it returns NIL.

(DEFUN EQMEMB (ATM LST)
  ((EQ ATM LST))
  (MEMB ATM LST) )


;PUTASSOC [key, object, a-list]  replaces the value associated with
;<key> on <a-list> with <object>.

(DEFUN PUTASSOC (KEY OBJ ALST
    TEMP )
  (SETQ TEMP (ASSOC KEY ALST))
  ((NULL TEMP)
    (NCONC ALST (LIST (CONS KEY OBJ)))
    OBJ )
  (RPLACD TEMP OBJ)
  OBJ )


;	Section 6:  List Manipulation and Concatenation

;NCONC1 [list, object]  adds <object> to the end of <list> by modifying
;the last cons of <list>.

(DEFUN NCONC1 (LST OBJ)
  (NCONC LST (CONS OBJ)) )


;DOCOLLECT [object, list]  efficiently adds <object> to the end of
;<list> which is maintained as a pointer to a circular list.

(DEFUN DOCOLLECT (OBJ LST)
  ((ATOM LST)
    (CONS OBJ) )
  ((ATOM (CDR LST))
    ((NULL (CAR LST))
      (RPLACA LST OBJ) )
    (RPLACD LST (CONS OBJ))
    (RPLACD (CDR LST) (CDR LST))
    LST )
  (RPLACD (CDR LST) (CONS OBJ (CDDR LST)))
  (RPLACD LST (CDDR LST)) )


;ENDCOLLECT [list, tail]  replaces the tail of <list> with <tail> making
;<list> no longer circular and returns the resulting list.

(DEFUN ENDCOLLECT (LST TAIL)
  ((ATOM LST) TAIL)
  ((ATOM (CDR LST))
    ((NULL (CAR LST))
      ((ATOM TAIL) TAIL)
      (RPLNODE2 LST TAIL) )
    (RPLACD LST TAIL) )
  (RPLACD LST (PROG1 (CDDR LST) (RPLACD (CDR LST) TAIL))) )


;ATTACH [object, list]  adds <object> to the front of <list> by
;modifying the first cons of <list>.

(DEFUN ATTACH (OBJ LST)
  ((NULL LST)
    (CONS OBJ) )
  ((ATOM LST) NIL)
  (RPLACA (RPLACD LST (CONS (CAR LST) (CDR LST))) OBJ) )


;DREMOVE [atom, list]  removes <atom> from <list> by modifying <list>.

(DEFUN DREMOVE (ATM LST
    TEMP )
  ((ATOM LST) NIL)
  ((EQ ATM (CAR LST))
    ((ATOM (CDR LST)) NIL)
    (RPLACA LST (CADR LST))
    (RPLACD LST (CDDR LST))
    (DREMOVE ATM LST) )
  (SETQ TEMP LST)
  (LOOP
    ((ATOM (CDR TEMP)) LST)
    ( ((EQ ATM (CADR TEMP))
	(RPLACD TEMP (CDDR TEMP)) )
      (POP TEMP) ) ) )


;MKLIST [object]  returns (LIST object) if <object> is a nonNIL atom;
;otherwise, it returns <object>.

(DEFUN MKLIST (OBJ)
  ((NULL OBJ) OBJ)
  ((ATOM OBJ)
    (CONS OBJ) )
  OBJ )


;COPY [object]  copies <object> down to the atomic level.

(MOVD 'COPY-TREE 'COPY)


;DREVERSE [list]  reverses <list> without consing by modifying <list>.

(MOVD NREVERSE DREVERSE)


;DSUBST [new, old, object]  substitutes <new> for all sub-expressions
;EQUAL to <old> in <object> without consing.

(DEFUN DSUBST (NEW OLD OBJ)
  ((EQUAL OLD OBJ) NEW)
  ((ATOM OBJ) OBJ)
  (RPLACD (RPLACA OBJ (DSUBST NEW OLD (CAR OBJ)))
	(DSUBST NEW OLD (CDR OBJ))) )


;SUBLIS [a-list, object, flag]  substitutes in <object> for each key in
;<a-list> the associated value.  If <flag> is NIL, a new structure is
;created only if necessary.  If <flag> is nonNIL, new structure is always
;created.

(DEFUN SUBLIS (ALST OBJ FLG
    TEMP1 TEMP2 )
  ((ATOM OBJ)
    (SETQ TEMP1 (ASSOC OBJ ALST))
    ((NULL TEMP1) OBJ)
    (CDR TEMP1) )
  (SETQ TEMP1 (SUBLIS ALST (CAR OBJ) FLG)
	TEMP2 (SUBLIS ALST (CDR OBJ) FLG))
  ((AND (NOT FLG) (EQ (CAR OBJ) TEMP1) (EQ (CDR OBJ) TEMP2)) OBJ)
  (CONS TEMP1 TEMP2) )


;NLEFT [list, n, tail]  returns <n> more elements from the end of <list>
;than <tail>.  <tail> should be NIL or a tail of <list>.

(DEFUN NLEFT (LST NUM TAIL)
  ((OR (NULL LST) (EQ LST TAIL))
    ((OR (NOT (NUMBERP NUM)) (ZEROP NUM)) LST)
    1 )
  (SETQ TAIL (NLEFT (CDR LST) NUM TAIL))
  ((NUMBERP TAIL)
    ((EQ TAIL NUM) LST)
    (ADD1 TAIL) )
  TAIL )


;LASTN [list, n]  returns CONS[list1,list2] where <list2> is the last
;<n> elements of <list> and <list1> is the remaining elements of <list>.

(DEFUN LASTN (LST NUM
    TAIL )
  ((NULL (SETQ TAIL (NLEFT LST NUM))) NIL)
  (CONS (LDIFF LST TAIL) TAIL) )


;EQLENGTH [list, n]  was defined earlier.


;COUNTDOWN [object, n]  returns the larger of 0 or <n> minus the number
;of nodes in <object>.

(DEFUN COUNTDOWN (OBJ NUM)
  ((ZEROP NUM) NUM)
  ((PLUSP NUM)
    (LOOP
      ((ATOM OBJ) NUM)
      (SETQ NUM (COUNTDOWN (POP OBJ) (SUB1 NUM)))
      ((ZEROP NUM) NUM) ) ) )


;LDIFF [list1, tail, list2]  returns a list of the elements of <list1>
;up to <tail> nconced onto <list2>.

(DEFUN LDIFF (LST1 TAIL LST2)
  ((ATOM TAIL)
    (NCONC LST2 LST1) )
  (NCONC LST2 (LDIFF-AUX LST1)) )

(DEFUN LDIFF-AUX (LST)
  ((OR (ATOM LST) (EQ LST TAIL)) NIL)
  (CONS (CAR LST) (LDIFF-AUX (CDR LST))) )


;LDIFFERENCE [list1, list2]  returns a list of the elements in <list1>
;that are not a MEMBER of <list2>.

(MOVD 'SET-DIFFERENCE 'LDIFFERENCE)


;ALPHORDER [atom1, atom2]  a predicate for alphabetizing atoms.  Numbers
;come before names and are sorted numerically.

(MOVD 'STRING< 'ALPHORDER)


;	Section 7:  Property Lists and Hash Links

;In muLISP, property lists are association lists of the form:
;	((KEY.VALUE) (KEY.VALUE) ... (KEY.VALUE)).

;In Interlisp, property lists are lists of the form:
;	(KEY VALUE KEY VALUE ... KEY VALUE).


;GETPROPLIST [name]  returns <name>'s p-list (property list).

(DEFUN GETPROPLIST (NAM)
  ((NAME NAM)
    (CDR NAM) ) )


;SETPROPLIST [name, list]  replaces the p-list of <name> with <list>
;and returns <list>.

(DEFUN SETPROPLIST (NAM LST)
  ((AND NAM (NAME NAM))
    (RPLACD NAM LST)
    LST ) )


;GETPROP [name, key]  returns the property value on <name>'s p-list under
;the indicator <key>.  NIL is returned if no such property exists.
;GETPROP is equivalent to the muLISP function GET.

(MOVD 'GET 'GETPROP)


;PUTPROP [name, key, object]  puts on <name>'s p-list under the indicator
;<key> the property value <object>.  PUTPROP is equivalent to the muLISP
;function PUT.

(MOVD 'PUT 'PUTPROP)


;PUTPROPS [name, key1, object1, ..., keyn, objectn]  an NLAMBDA, no-spread
;function that puts properties on <name>'s p-list.

(DEFUN PUTPROPS (NLAMBDA LST$
  (PUTPROPS-AUX (CAR LST$) (CDR LST$)) ))

(DEFUN PUTPROPS-AUX (NAM LST)
  (LOOP
    ((ATOM LST) NAM)
    (PUT NAM (POP LST) (POP LST)) ) )


;PUTQQ [name, key, object]  a no-eval function that puts on <name>'s
;p-list under <key> the property value <object>.  If a PUTQQ command is
;issued from the muSTAR editor, the property is flagged for saving,
;making PUTQQ roughly equivalent to the Interlisp SAVEPUT function.


;ADDPROP [name, key, object, flag]  nconcs <object> to the <key>
;property on <name>'s p-list if <flag> is NIL.  If <flag> is nonNIL,
;<object> is consed onto the front of the property.

(DEFUN ADDPROP (NAM KEY OBJ FLG
    TEMP )
  (SETQ TEMP (ASSOC KEY (CDR NAM)))
  ((NULL TEMP)
    (PUTPROP NAM KEY (LIST OBJ)) )
  ((NULL FLG)
    (CDR (NCONC TEMP (LIST OBJ))) )
  (CDR (RPLACD TEMP (CONS OBJ (CDR TEMP)))) )


;REMPROP [name, key]  removes the property <key> from <name>'s p-list.
;REMPROP is a primitively defined muLISP function.


;REMPROPLIST [name, list]  removes from <name>'s p-list the properties
;whose keys are members of <list>.

(DEFUN REMPROPLIST (NAM LST)
  (LOOP
    ((ATOM LST) NIL)
    (REMPROP NAM (POP LST)) ) )


;CHANGEPROP [name, key1, key2]  replaces the key for the <key1> property
;on <name>'s p-list with <key2>.

(DEFUN CHANGEPROP (NAM KEY1 KEY2)
  ((SETQ KEY1 (ASSOC KEY1 (CDR NAM)))
    (RPLACA KEY1 KEY2)
    NAM ) )


;PROPNAMES [name]  returns a list of the keys on <name>'s p-list.

(DEFUN PROPNAMES (NAM
    LST )
  (LOOP
    (SETQ NAM (CDR NAM))
    ((NULL NAM)
      (REVERSE LST) )
    ( ((ATOM (CAR NAM)))
      (PUSH (CAAR NAM) LST) ) ) )


;GETLIS [name, list]  returns <name>'s p-list beginning with the first
;key that is a member of <list>.

(DEFUN GETLIS (NAM LST)
  ((NULL NAM) NIL)
  ( ((NAME NAM)
      (SETQ NAM (CDR NAM)) ) )
  (LOOP
    ((NULL NAM) NIL)
    ((AND (NOT (ATOM (CAR NAM))) (MEMBER (CAAR NAM) LST))
      NAM )
    (POP NAM) ) )


;DEFLIST [list, key]  for each element of <list>, puts on the p-list of
;the car of the element under the indicator <key> the cadr of the element.

(DEFUN DEFLIST (LST KEY)
  (LOOP
    ((NULL LST) NIL)
    (PUTPROP (CAAR LST) KEY (CADAR LST))
    (POP LST) ) )



;	Section 8:  Function Definition and Evaluation

;DEFINE [definition-list]  defines the functions on <definition-list>
;where each element of <definition-list> is a list of the form:
;	(name (LAMBDA (arg-list) body)),
;or of the form:
;	(name (arg-list) body).

(DEFUN DEFINE (LST
    OBJ )
  (LOOP
    ((ATOM LST) NIL)
    (SETQ OBJ (POP LST))
    ( ((OR (ATOM OBJ) (NOT (NAME (CAR OBJ)))))
      ((OR (EQ (CAADR OBJ) 'LAMBDA) (EQ (CAADR OBJ) 'NLAMBDA))
	(PUTD (CAR OBJ) (CADR OBJ)) )
      (PUTD (CAR OBJ) (CONS 'LAMBDA (CDR OBJ))) ) ) )


;DEFINEQ [list1, list2, ..., listn]  a no-eval function that applies
;DEFINE to each element of <list1> through <listn>.

(DEFUN DEFINEQ (NLAMBDA LST$
  (DEFINE LST$) ))


;BOUNDP [name]  returns T if <name> currently has a value other than
;itself or NOBIND.  Otherwise it returns NIL.

(DEFUN BOUNDP (NAM)
  (NOT (OR (EQ NAM (CAR NAM)) (EQ (CAR NAM) 'NOBIND))) )


;APPLY* [function, arg1, arg2, ..., argn]  applies <function> to the
;arguments <arg1> through <argn>.  The <function> argument in a call
;to APPLY* is not evaluated.

(DEFMACRO APPLY* (FUNC . ARGS)
  (CONS* 'FUNCALL (LIST 'QUOTE FUNC) ARGS) )


;RPT [n, expression]  evaluates <expression> <n> times.

(DEFUN RPT (NUM EXP)
  ((PLUSP NUM)
    (LOOP
      ((EQ NUM 1)
	(EVAL EXP) )
      (EVAL EXP)
      (DECQ NUM) ) ) )


;RPTQ [n, expression]  is equivalent to RPT except <expression> is not
;evaluated before the function is called.

(DEFUN RPTQ (NLAMBDA (NUM$ EXP$)
  (RPT (EVAL NUM$) EXP$) ))



;	Section 11:  Functions with Functional Arguments


;Since the map functions in this section conflict with the primitive muLISP
;map functions, their names are preceeded with an I standing for Interlisp.

;IMAP [list, function1, function2]  if <function2> is NIL, it applies
;<function1> to successive cdrs of <list> beginning with the whole list.
;If <function2> is nonNIL, it uses <function2> instead of cdr to step
;through <list>.

(DEFUN IMAP (LST FUN1 FUN2)
  ((NULL FUN2)
    (LOOP
      ((ATOM LST) NIL)
      (FUNCALL FUN1 LST)
      (POP LST) ) )
  (LOOP
    ((ATOM LST) NIL)
    (FUNCALL FUN1 LST)
    (SETQ LST (FUNCALL FUN2 LST)) ) )


;IMAPC [list, function1, function2]  if <function2> is NIL, it applies
;<function1> to successive elements of <list> beginning with the whole
;list.  If <function2> is nonNIL, it uses <function2> instead of cdr
;to step through <list>.

(DEFUN IMAPC (LST FUN1 FUN2)
  ((NULL FUN2)
    (LOOP
      ((ATOM LST) NIL)
      (FUNCALL FUN1 (POP LST)) ) )
  (LOOP
    ((ATOM LST) NIL)
    (FUNCALL FUN1 (CAR LST))
    (SETQ LST (FUNCALL FUN2 LST)) ) )


;IMAPLIST [list, function1, function2]  returns a list of the same values
;computed by IMAP [list, function1, function2].

(DEFUN IMAPLIST (LST FUN1 FUN2)
  ((ATOM LST) NIL)
  ((NULL FUN2)
    (CONS (FUNCALL FUN1 LST) (IMAPLIST (CDR LST) FUN1)) )
  (CONS (FUNCALL FUN1 LST) (IMAPLIST (FUNCALL FUN2 LST) FUN1 FUN2)) )


;IMAPCAR [list, function1, function2]  returns a list of the same values
;computed by IMAPC [list, function1, function2].

(DEFUN IMAPCAR (LST FUN1 FUN2)
  ((ATOM LST) NIL)
  ((NULL FUN2)
    (CONS (FUNCALL FUN1 (CAR LST)) (IMAPCAR (CDR LST) FUN1)) )
  (CONS (FUNCALL FUN1 (CAR LST)) (IMAPCAR (FUNCALL FUN2 LST) FUN1 FUN2)) )


;IMAPCON [list, function1, function2]  concatenates the values computed
;by IMAP [list, function1, function2] using NCONC.

(DEFUN IMAPCON (LST FUN1 FUN2
    RSLT ANS )
  (LOOP
    ((ATOM LST) RSLT)
    (SETQ RSLT (FUNCALL FUN1 LST))
    (SETQ LST (COND
	(FUNCALL FUN2 (FUNCALL FUN2 LST))
	((CDR LST)) ))
    ((NOT (ATOM RSLT))
      (SETQ ANS RSLT)
      (LOOP
	((ATOM LST) ANS)
	(SETQ RSLT (LAST RSLT))
	(RPLACD RSLT (FUNCALL FUN1 LST))
	(SETQ LST (COND
	  (FUNCALL FUN2 (FUNCALL FUN2 LST))
	  ((CDR LST)) )) ) ) ) )


;IMAPCONC [list, function1, function2]  concatenates the values computed
;by IMAPC [list, function1, function2] using NCONC.

(DEFUN IMAPCONC (LST FUN1 FUN2
    RSLT ANS )
  (LOOP
    ((ATOM LST) RSLT)
    (SETQ RSLT (FUNCALL FUN1 (CAR LST)))
    (SETQ LST (COND
	(FUNCALL FUN2 (FUNCALL FUN2 LST))
	((CDR LST)) ))
    ((NOT (ATOM RSLT))
      (SETQ ANS RSLT)
      (LOOP
	((ATOM LST) ANS)
	(SETQ RSLT (LAST RSLT))
	(RPLACD RSLT (FUNCALL FUN1 (CAR LST)))
	(SETQ LST (COND
	  (FUNCALL FUN2 (FUNCALL FUN2 LST))
	  ((CDR LST)) )) ) ) ) )


;SUBSET [list, function1, function2]  applies <function1> to the elements
;of <list> and returns a list of the elements for which the results were
;nonNIL.  If <function2> is nonNIL, it is used for stepping through <list>.

(DEFUN SUBSET (LST FUN1 FUN2)
  ((ATOM LST) NIL)
  ((FUNCALL FUN1 (CAR LST))
    (CONS (CAR LST) (SUBSET (COND
	  (FUNCALL FUN2 (FUNCALL FUN2 LST))
	  ((CDR LST)) ) FUN1 FUN2)) )
  (SUBSET (COND
      (FUNCALL FUN2 (FUNCALL FUN2 LST))
      ((CDR LST)) ) FUN1 FUN2) )


;IMAP2C [list1, list2, function1, function2]  if <function2> is NIL, it
;applies <function1> to successive elements of <list1> and <list2>.  If
;<function2> is nonNIL, it uses <function2> instead of cdr to step
;through <list>.

(DEFUN IMAP2C (LST1 LST2 FUN1 FUN2)
  ((NULL FUN2)
    (LOOP
      ((OR (ATOM LST1) (ATOM LST2)) NIL)
      (FUNCALL FUN1 (POP LST1) (POP LST2)) ) )
  (LOOP
    ((OR (ATOM LST1) (ATOM LST2)) NIL)
    (FUNCALL FUN1 (CAR LST1) (CAR LST2))
    (SETQ LST1 (FUNCALL FUN2 LST1)
	  LST2 (FUNCALL FUN2 LST2)) ) )


;IMAP2CAR [list1, list2, function1, function2]  returns a list of the
;same values computed by IMAP2C [list1, list2, function1, function2].

(DEFUN IMAP2CAR (LST1 LST2 FUN1 FUN2)
  ((OR (ATOM LST1) (ATOM LST2)) NIL)
  ((NULL FUN2)
    (CONS (FUNCALL FUN1 (CAR LST1) (CAR LST2))
	  (IMAP2CAR (CDR LST1) (CDR LST2) FUN1)) )
  (CONS (FUNCALL FUN1 (CAR LST1) (CAR LST2))
	(IMAP2CAR (FUNCALL FUN2 LST1) (FUNCALL FUN2 LST2) FUN1 FUN2)) )



;	Section 13:  Numbers and Arithmetic Functions

(MOVD 'EQL 'EQN)

(MOVD 'INTEGERP 'FIXP)

(MOVD '+ 'PLUS)

(MOVD '- 'MINUS)
(MOVD '- 'DIFFERENCE)

(MOVD '* 'TIMES)

(MOVD '/ 'QUOTIENT)

(MOVD 'REM 'REMAINDER)

(MOVD '> 'GREATERP)

(MOVD '< 'LESSP)

(MOVD '>= 'GEQ)

(MOVD '<= 'LEQ)

(MOVD 'LOGIOR 'LOGOR)

(MOVD 'SHIFT 'RSH)


;	Section 14:  Input/Output Functions

(MOVD 'READ-CHAR 'READCH)

;READLINE []  reads a line from the terminal and returns it as a list.

(DEFUN READLINE (
    READ-CHAR RDS )
  (SETQ READ-CHAR T)			;Set line edit mode
  (READLINE-AUX (READ-CHAR T)) )

(DEFUN READLINE-AUX (CHAR)
  ((EQ CHAR (ASCII 13)) NIL)
  ((EQ CHAR '"]") NIL)
  ((EQ CHAR '")") NIL)
  ((EQ CHAR '" ")
    (SETQ CHAR (READ-CHAR T))
    ((EQ CHAR (ASCII 13))
      (PRIN1 '"...")
      (READLINE-AUX (READ-CHAR T)) )
    (READLINE-AUX CHAR) )
  (CONS (READ) (READLINE-AUX (READ-CHAR T))) )


;PRIN2 [object]  outputs <object> to the COS putting double quote marks
;around names containing special characters.

(DEFUN PRIN2 (OBJ
    PRIN1 )
  (SETQ PRIN1)
  (PRIN1 OBJ) )


;TAB [n, m]  outputs <m> spaces (1 if <m> is NIL) and then outputs
;enough spaces to move to column <n>.

(DEFUN TAB (NUM1 NUM2)
  ( ((NULL NUM2)
      (SPACES 1) )
    (SPACES NUM2) )
  (SPACES (DIFFERENCE NUM1 (SPACES))) )

(RDS)
