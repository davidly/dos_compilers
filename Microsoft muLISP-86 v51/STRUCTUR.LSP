; File:	STRUCTUR.LSP  (C)	12/25/85	Soft Warehouse, Inc.

; COMMON.LSP must also be read in to use the functions in this file.


;			muLISP Array Facility

; The muLISP array facility provides a subset of the Common LISP array
; capability (see Chapter 17 of Common LISP, The Language by Guy L.
; Steele Jr. [1984]).  Arrays are realized as 3-element lists of the form:

;		(ARRAY <array-contents> <dims>)

; where <array-contents> is a list of lists "compatible in length"
; with <dims>, and <dims> is a list of zero or more positive integers.
; Thus, arrays carry type and dimension information around with them
; for fast array bounds checking.


; Array Creation (see Steele, Section 17.1):

; (MAKE-ARRAY <dimensions> {<option>}+) creates an array of dimensions
; <dimensions>.

; <dimensions> can be NIL, <dim>, or (<dim1> ... <dimn>).  <dim> must be
; a POSITIVE integer (Common LISP only requires <dim> to be a
; NON-NEGATIVE integer).

; <option> is an array creation option of the form:
;		 <keyword> <option-specifications>
; where <keyword> is one of the array option keywords described below.
; (Note: Keywords may be used in upper or lower case.)

; :INITIAL-ELEMENT expression
;   This option sets the initial value of each array element to <expression>.
;   If the :INITIAL-ELEMENT option is not given, the initial value of each
;   array element will be NIL.

; :INITIAL-CONTENTS expression
;   This option sets the initial contents of the array to a COPY of the
;   elements of <expression>, if <expression> is "compatible in length"
;   with the dimensions of the array (i.e. if the length of <expression>
;   is equal to the first dimension of the array and each element of
;   <expression> is "compatible in length" with the remaining dimensions
;   of the array).  If the :INITIAL-CONTENTS option is not given, each
;   array element will be determined in accordance with the
;   :INITIAL-ELEMENT option.

; The Common LISP array creation options :ELEMENT-TYPE, :ADJUSTABLE,
; :FILL-POINTER, :DISPLACED-TO, and :DISPLACED-INDEX-OFFSET are NOT
; supported.

; MAKE-ARRAY can generate the following error breaks:

; Dimension Error:  indicates that the dimension specification is
;   neither NIL, a positive integer, nor a list of positive integers.

; Incompatible Length:  indicates that the value specified for
;   the :INITIAL-CONTENTS is NOT "compatible in length" with the
;   dimensions of the array.


(DEFMACRO MAKE-ARRAY (DIMS . OPTIONS)
  (LIST 'MAKE-ARRAY-AUX DIMS (LIST 'QUOTE OPTIONS)) )

(DEFUN MAKE-ARRAY-AUX (DIMS OPTIONS)
  (IF (NUMBERP DIMS) (SETQ DIMS (LIST DIMS)))
  ((AND (LISTP DIMS)
	(EVERY '(LAMBDA (N) (AND (INTEGERP N) (PLUSP N)))
	       DIMS) )
    (LET ((conts (EVAL (CADR (MEMBER ':INITIAL-CONTENTS OPTIONS)))) )
      ((NULL conts)
	(LIST 'ARRAY
	      (MAKE-ARRAY-CONTENTS DIMS
		  (EVAL (CADR (MEMBER ':INITIAL-ELEMENT OPTIONS))))
	       DIMS) )
      ((ARRAY-CONTENTS-P DIMS conts)
	(LIST 'ARRAY
	      (COPY-ARRAY-CONTENTS DIMS conts)
	      DIMS) )
      (BREAK (LIST* 'MAKE-ARRAY DIMS OPTIONS) "Incompatible Length") ) )
  (BREAK (LIST* 'MAKE-ARRAY DIMS OPTIONS) "Dimension Error") )

(DEFUN MAKE-ARRAY-CONTENTS (DIMS INITELEM)
; Creates an array contents structure "compatible in length" with DIMS,
; and with INITELEM as the value of each element.
  ((NULL (CDR DIMS))
    (MAKE-LIST (CAR DIMS) INITELEM) )
  (LET ((dim (CAR DIMS))
	(aconts NIL) )
    (LOOP
      ((ZEROP dim) aconts)
      (PUSH (MAKE-ARRAY-CONTENTS (CDR DIMS) INITELEM) aconts)
      (DECQ dim) ) ) )

(DEFUN ARRAY-CONTENTS-P (DIMS ACONTS)
; Tests whether ACONTS is a list "compatible in length" with DIMS.
  ((NULL DIMS) T)
  ((= (LENGTH ACONTS) (CAR DIMS))
    (EVERY '(LAMBDA (ELEM) (ARRAY-CONTENTS-P (CDR DIMS) ELEM) )
	   ACONTS) ) )

(DEFUN COPY-ARRAY-CONTENTS (DIMS ACONTS)
; Copies ACONTS in accordance with DIMS.  Elements of ACONTS outside
; the scope of DIMS (i.e. actual elements of the array) are NOT copied.
  ((NULL (CDR DIMS))
    (COPY-LIST ACONTS) )
  (MAPCAR '(LAMBDA (ELEM) (COPY-ARRAY-CONTENTS (CDR DIMS) ELEM) )
	  ACONTS) )


; Array Access (see Steele, Section 17.2):

; If <subscript1> ... <subscriptn> are non-negative integers,
; (AREF <array> <subscript1> ... <subscriptn>) returns the specifed
; element of <array>; and
; (SETF (AREF <array> <subscript1> ... <subscriptn>) <expr>) sets the
; specified element of <array> to the value of <expr>.

; Note that AREF contains NO array bounds error checking.  This provides
; good execution speed, but means that such checking must be done by the
; user using the function ARRAY-IN-BOUNDS-P, defined below.

(DEFMACRO AREF (ARRAY . SUBSCRIPTS)
  (SETQ ARRAY (LIST 'CADR ARRAY))
  (LOOP
    ((NULL SUBSCRIPTS) ARRAY)
    (SETQ ARRAY (LIST 'NTH (POP SUBSCRIPTS) ARRAY)) ) )


; Array Information (see Steele, Section 17.3):

(DEFUN ARRAY-RANK (ARRAY)
; Returns the "rank" of ARRAY.
  (LENGTH (CADDR ARRAY)) )

(DEFUN ARRAY-DIMENSION (ARRAY AXISNUMBER)
; Returns the dimension of ARRAY along the AXISNUMBER axis (where
; 0 is the first axis of any array).
  (NTH AXISNUMBER (CADDR ARRAY)) )

(DEFUN ARRAY-DIMENSIONS (ARRAY)
; Returns the list of dimensions of ARRAY.
  (CADDR ARRAY) )

(DEFUN ARRAY-TOTAL-SIZE (ARRAY)
; Returns the total number of elements in ARRAY.
  (REDUCE '* (CADDR ARRAY)) )

(DEFUN ARRAY-IN-BOUNDS-P AREFSPEC
; Tests whether AREFSPEC, an array/subscripts specification of
; the form used in AREF, is within the bounds of the array.
  (EVERY '(LAMBDA (I B) (AND (INTEGERP I) (< -1 I B)))
	 (CDR AREFSPEC)
	 (CADDAR AREFSPEC)) )


;		muLISP Structure Facility

; The muLISP structure facility provides a subset of the Common LISP
; structure capability (see Chapter 19 of Common LISP, The Language
; by Guy L. Steele Jr. [1984]).  Named structures are realized as lists
; of the form:

;		(<structname> <slot-1> <slot-2> ... <slot-n>)

; Unnamed structures are realized as lists of the form:

;		      (<slot-1> <slot-2> ... <slot-n>)

; All structure functions -- constructors, accessors, copiers, and
; predicates -- are implemented as MACROs.  This yields good execution
; speed, and integrates nicely with the SETF implementation.  However,
; there are some costs:
; 1.  Structures must be defined BEFORE their functions are used.
; 2.  Structure functions cannot be APPLYed, FUNCALLed, mapped down
;     lists, etc., by themselves.  This can be accomplished by
;     "wrapping" the function in a LAMBDA; for example, instead of
;     (MAPCAR 'SLOT-NAME X) use (MAPCAR '(LAMBDA (S) (SLOT-NAME S)) X).
; 3.  Redefining a structure will NOT cause all uses of structure
;     functions to be redefined (i.e. re-expanded) UNLESS the
;     control variable MACROEXPAND is NIL.  For this reason,
;     it is recommended that MACROEXPAND be set to NIL during
;     program development.  This will slow down execution speed
;     during development, but make modifications much easier.

; The structure functions contain NO execution or expansion time error
; checking.  This provides good execution speed, but means that any
; error checking needed must be supplied by the user.

; Structure definition components -- options, slot names, slot values,
; a :NAMED flag, and structure functions (MACROs) -- are stored on the
; property list of the structure's name.  In addition, a list of the
; structures supported is stored on the property list of each structure
; function.  (See the functions PUTSTRUCT and REMSTRUCT below).


; Structure Definition (see Steele, Section 19.2):

; (DEFSTRUCT <name-and-options> {<slot-description>}+) creates a
; structure data type.  <name-and-options> has the form <name> or
; (<name> {<option>}+), where <name> is a symbol and <option> is a
; DEFSTRUCT option (see below).  Each <slot-description> has the form
; <slotname> or (<slotname> <expr>), where <slotname> is a symbol
; and <expr> is any evaluable muLISP expression.  Note that "slot
; options" are NOT supported.


; Defstruct Options (see Steele, Section 19.5):

; DEFSTRUCT options have the form <keyword> or
; (<keyword> . <option-specifications>) where <keyword> is a defstruct
; option keyword (Note: Keywords may be used in upper or lower case).

; :CONC-NAME prefix
;   This option modifies the default prefix naming of <slotname>'s
;   accessor function as follows:
;   1.	If the :CONC-NAME option is not given, the accessor function
;	will be named (PACK* <structname> "-" <slotname>).
;   2.	If <prefix> is a nonNIL symbol, the accessor function will be
;	named (PACK* <prefix> <slotname>).
;   3.	If <prefix> is NIL, the accessor function will be named
;	<slotname> (i.e. with NO prefix).

; :CONSTRUCTOR consname [arglist]
;   This option modifies the default naming of the standard keyword
;   constructor function and specifies additional positional
;   constructor functions as follows:
;   1.	If the :CONSTRUCTOR option is not given, a standard keyword
;	constructor named (PACK* "MAKE-" <structname>) will be provided.
;   2.	If <consname> is a nonNIL symbol, a standard keyword
;	constructor named <consname> will be provided.
;   3.	If <consname> is NIL, NO keyword constructor will be provided.
;   4.	If <consname> is a symbol and <arglist> is a list of names of
;	slots of the structure, a positional constructor named
;	<consname> will be provided.
;   (Note that more than one :CONSTRUCTOR option can be included in a
;   structure definition.)

; :COPIER copyname
;   This option modifies the default naming of the standard copier
;   function as follows:
;   1.	If the :COPIER option is not given, a standard copier named
;	(PACK* "COPY-" <structname>) will be provided.
;   2.	If <copyname> is a nonNIL symbol, a standard copier named
;	<copyname> will be provided.
;   3.	If <copyname> is NIL, NO copier will be provided.

; :PREDICATE predname
;   This option modifies the default naming of the standard predicate
;   function of named structures as follows:
;   1.	If the :PREDICATE option is not given, a standard predicate
;	named (PACK* <structname> "-P") will be provided.
;   2.	If <predname> is a nonNIL symbol, a standard predicate named
;	<predname> will be provided.
;   3.	If <predname> is NIL, NO predicate will be provided.

; :INCLUDE inclstruct {<slotdescrip>}+
;   This option includes the slots of a previously defined structure
;   in the structure being defined (the structure being defined
;   becomes an extension and specialization of the :INCLUDEd structure)
;   as follows:
;   1.	If the :INCLUDE option is not given, no other structure will
;	be included.
;   2.	If <inclstruct> is a previously defined structure, the structure
;	being defined will include the slots of <inclstruct>.
;   3.	If <inclstruct> is a previously defined structure and each
;	<slotdescrip> describes a slot in <inclstruct>, the structure
;	being defined will include the slots of <inclstruct>, but with
;	original default values overridden by {<slotdescrip>}+.
;   (Note that included structures must be :NAMED or not :NAMED
;   consistently with the structure being defined.)

; :TYPE LIST
;   This option used in conjunction with the :NAMED option forces a
;   particular representation for the structure being defined as follows:
;   1.	If the :TYPE option is not given, the structure being defined
;	will be represented as a list and will be :NAMED.
;   2.	If the :TYPE option is given, the structure being defined
;	will be represented as a list and will NOT be :NAMED, unless
;	the structure definition explicitly specifies the :NAMED option.
;   (Note that only the type LIST is valid.)

; :NAMED
;   This option used in conjunction with the :TYPE option forces a
;   particular representation for the structure being defined as follows:
;   1.	If the :NAMED option is not given, the structure being defined
;	will be :NAMED unless an explicit :TYPE option is specified.
;   2.	If the :NAMED option is given, the structure being defined will
;	be :NAMED irrespective of any :TYPE specifications.

; The Common LISP DEFSTRUCT options :PRINT-FUNCTION and :INITIAL-OFFSET
; are NOT supported.


; DEFSTRUCT can generate the following error breaks:

; Nonsymbolic Argument:  indicates that a nonsymbol was given as the
;   name for a structure or a slot in the structure.

; Unsupported Option:  indicates that an unsupported DEFSTRUCT option
;   was given.

; Unnamed Structure:  indicates that a predicate option was given for
;   an unnamed structure.

; Undefined Structure:  indicates that the name of an undefined
;   structure was given for inclusion in a structure.

; Include Error:  indicates that a named structure was given for inclusion
;   in an unnamed structure, or that an unnamed structure was given for
;   inclusion in a named structure.

; Incompatible definition:  indicates that a definition for a function
;   is incompatible with the existing definition of the function.


(DEFMACRO DEFSTRUCT (STRUCTSPEC . SLOTSPECS)
  (LIST 'DEFSTRUCT-AUX
	(LIST 'QUOTE STRUCTSPEC)
	(LIST 'QUOTE SLOTSPECS)) )

(DEFUN DEFSTRUCT-AUX (STRUCTSPEC SLOTSPECS)
  (LET* ((name (GET-STRUCT-NAME STRUCTSPEC))
	 (options (GET-STRUCT-OPTIONS name STRUCTSPEC))
	 (slotnams (GET-STRUCT-SLOT-NAMES name SLOTSPECS))
	 (slotvals (GET-STRUCT-SLOT-VALUES name SLOTSPECS))
	 (named? (OR (ASSOC ':NAMED options)
		     (NOT (ASSOC ':TYPE options))) ) )
    (LET ((istruct (ASSOC ':INCLUDE options)) )
      ((CHECK-INCLUDED-STRUCT name istruct named?)
	(SETQ slotnams
	      (APPEND (GET (CADR istruct) 'STRUCT-SLOTNAMES)
		      slotnams))
	(SETQ slotvals
	      (MAPCAR '(LAMBDA (SNAM SVAL)
			   ((CADR (ASSOC SNAM (CDDR istruct))) )
			   SVAL)
		      slotnams
		      (APPEND (GET (CADR istruct) 'STRUCT-SLOTVALS)
			      slotvals))) ) )
    (PUTSTRUCT name options slotnams slotvals named?
	(CHECK-STRUCT-MACDEFS name
	    (APPEND (FORM-STRUCT-CONSTRUCTORS name options slotnams
					      slotvals named?)
		    (FORM-STRUCT-ACCESSORS name options slotnams
					   named?)
		    (FORM-STRUCT-PREDICATE name options named?)
		    (FORM-STRUCT-COPIER name options)))) ) )


(DEFUN GET-STRUCT-NAME (STRUCTSPEC)
; Extracts and returns the structure name specification from STRUCTSPEC,
; verifying that it is a symbol.
  (LET ((stnam (IF (CONSP STRUCTSPEC) (CAR STRUCTSPEC) STRUCTSPEC) ) )
    ((SYMBOLP stnam) stnam)
    (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS) "Nonsymbolic Argument") ) )

(DEFUN GET-STRUCT-OPTIONS (NAME STRUCTSPEC)
; Extracts the structure option specifications from STRUCTSPEC, verifying
; that each is a supported option.  Collects and returns the options in
; a uniform "a-list" format.
  ((ATOM STRUCTSPEC) NIL)
  (MAPCAR '(LAMBDA (OPT)
	       (LET ((optnam (IF (CONSP OPT) (CAR OPT) OPT) ) )
		 ((AND (SYMBOLP optnam)
		       (MEMBER (SETQ optnam (STRING-UPCASE optnam))
			       '(:CONC-NAME :CONSTRUCTOR :COPIER
				 :PREDICATE :INCLUDE :TYPE :NAMED)) )
		   (CONS optnam (IF (CONSP OPT) (CDR OPT))) )
		 (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
			"Unsupported Option") ) )
	  (CDR STRUCTSPEC)) )

(DEFUN GET-STRUCT-SLOT-NAMES (NAME SLOTSPECS)
; Extracts the structure slot names from SLOTSPECS, verifying that each
; is a symbol.  Returns a list of the slot names.
  (MAPCAR '(LAMBDA (SLOT)
	       (LET ((snam (IF (CONSP SLOT) (CAR SLOT) SLOT)) )
		 ((SYMBOLP snam) snam)
		 (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
			"Nonsymbolic Argument") ) )
	  SLOTSPECS) )

(DEFUN GET-STRUCT-SLOT-VALUES (NAME SLOTSPECS)
; Extracts the structure slot values from SLOTSPECS, supplying NIL as
; the value for any slot without a specified value.  Returns a list of
; the slot values.
  (MAPCAR '(LAMBDA (SLOT) (IF (CONSP SLOT) (CADR SLOT)))
	  SLOTSPECS) )


(DEFUN CHECK-INCLUDED-STRUCT (NAME ISTRUCT NAMED?)
; Checks that the (:INCLUDE ...) option ISTRUCT (if any) specifies a
; valid, previously defined structure which is compatible with the
; structure being defined.
  ((NULL ISTRUCT) NIL)
  (LET ((iname (CADR ISTRUCT)) )
    ((GET iname 'STRUCT-MACROS)
      ((GET iname 'NAMED-STRUCT)
	((IDENTITY NAMED?) T)
	(BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	       "Include Error") )
      ((NOT NAMED?) T)
      (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	     "Include Error") )
    (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	   "Undefined Structure") ) )

(DEFUN CHECK-STRUCT-MACDEFS (NAME MACDEFS)
; Checks that each MACRO (<name> . <definition>) pair in the list
; MACDEFS will NOT cause an incompatible redefinition of an existing
; function.
  (MAPCAR '(LAMBDA (MACDEF)
	       ((OR (NULL (GETD (CAR MACDEF) T))
		    (EQUAL (GETD (CAR MACDEF)) (CDR MACDEF)) )
		  MACDEF)
	       (IF (NULL (GET (CAR MACDEF) 'STRUCTS))
		   (PUT (CAR MACDEF) 'STRUCTS (CONS)) )
	       ((NULL (REMOVE NAME (GET (CAR MACDEF) 'STRUCTS)))
		  MACDEF)
	       (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
		      "Incompatible Definition") )
	MACDEFS) )


(DEFUN FORM-STRUCT-CONSTRUCTORS (NAME OPTIONS SLOTNAMS SLOTVALS NAMED?)
; Formulates constructor functions as MACROs for the structure NAME in
; accordance with OPTIONS, SLOTNAMS, SLOTVALS, and NAMED?.  Returns a
; list of constructor function (<name> . <definition>) pairs (or NIL
; if no constructor functions were desired).
  (LET ((consopt (ASSOC ':CONSTRUCTOR OPTIONS)) )
    ((NULL consopt)
      (LIST (CONS (PACK* 'MAKE- NAME)
		  (STRUCT-KEYWORD-CONSTRUCTOR NAME SLOTNAMS SLOTVALS
			NAMED?))) )
    (MAPCAN '(LAMBDA (OPT)
		 ((EQ (CAR OPT) ':CONSTRUCTOR)
		   ((NULL (CDR OPT))
		     (LIST (CONS (PACK* 'MAKE- NAME)
				 (STRUCT-KEYWORD-CONSTRUCTOR NAME
				       SLOTNAMS SLOTVALS NAMED?))) )
		   ((NULL (CADR OPT)) )
		   ((NULL (CDDR OPT))
		     (LIST (CONS (CADR OPT)
				 (STRUCT-KEYWORD-CONSTRUCTOR NAME
				       SLOTNAMS SLOTVALS NAMED?))) )
		   (LIST (CONS (CADR OPT)
			       (STRUCT-POSITIONAL-CONSTRUCTOR NAME
				     SLOTNAMS SLOTVALS (CADDR OPT)
				     NAMED?))) ) )
	    OPTIONS) ) )

(DEFUN STRUCT-KEYWORD-CONSTRUCTOR (NAME SLOTNAMS SLOTVALS NAMED?)
; Formulates a keyword constructor function as a MACRO for the structure
; NAME in accordance with SLOTNAMS, SLOTVALS, and NAMED?.  Returns the
; definition for the constructor.
  (LIST 'MACRO
	'SLOTSPECS
	(APPEND '(LIST* 'LIST)
		(IF NAMED? (LIST (LIST 'QUOTE (LIST 'QUOTE NAME))))
		(LIST (LIST 'MAPCAR
			    ''(LAMBDA (SNAM SVAL)
				  (LET ((spec (MEMBER (PACK* '":" SNAM)
						      SLOTSPECS)) )
				    ((NULL spec) SVAL)
				    (CADR spec) ) )
			    (LIST 'QUOTE SLOTNAMS)
			    (LIST 'QUOTE SLOTVALS) ) ) ) ) )

(DEFUN STRUCT-POSITIONAL-CONSTRUCTOR (NAME SLOTNAMS SLOTVALS ARGS NAMED?)
; Formulates a positional constructor as a MACRO for the structure NAME
; in accordance with SLOTNAMS, SLOTVALS, ARGS, and NAMED?.  Returns the
; definition for the constructor.
  (LIST 'MACRO
	'BODY
	(APPEND '(LIST 'LIST)
		(IF NAMED? (LIST (LIST 'QUOTE (LIST 'QUOTE NAME))))
		(MAPCAR '(LAMBDA (SNAM SVAL)
			     ((MEMBER SNAM ARGS)
			       (LIST 'NTH
				     (ADD1 (POSITION SNAM ARGS))
				     'BODY) )
			     SVAL)
			SLOTNAMS
			SLOTVALS) ) ) )

(DEFUN FORM-STRUCT-ACCESSORS (NAME OPTIONS SLOTNAMS NAMED?)
; Formulates accessor functions as MACROs for the structure NAME in
; accordance with OPTIONS, SLOTNAMS, and NAMED?.  Returns a list of
; accessor function  (<name> . <definition>) pairs.
  (LET ((namopt (ASSOC ':CONC-NAME OPTIONS)) )
    (LET ((prefix (COND ((OR (NULL namopt)
			     (NULL (CDR namopt)) )
			  (PACK* NAME '"-") )
			((NULL (CADR namopt)) '"")
			((CADR namopt)) ) )
	  (slotpsn (IF NAMED? 1 0)) )
      (MAPCAR '(LAMBDA (SNAM)
		  (CONS (PACK* prefix SNAM)
			(LIST 'MACRO 'BODY
			      (LIST 'LIST ''NTH slotpsn (LIST 'CADR 'BODY)))
			(INCQ slotpsn)) )
	      SLOTNAMS) ) ) )

(DEFUN FORM-STRUCT-PREDICATE (NAME OPTIONS NAMED?)
; Formulates a predicate function as a MACRO for the structure NAME in
; accordance with OPTIONS and NAMED?.  Returns a list consisting of the
; predicate function (<name> . <definition>) pair (or NIL if no predicate
; function was desired).
  (LET ((predopt (ASSOC ':PREDICATE OPTIONS)) )
    ((NOT NAMED?)
      ((OR (NULL predopt)
	   (AND (CDR predopt)
		(NULL (CADR predopt)) ) ) )
      (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	     "Unnamed Structure") )
    ((OR (NULL predopt)
	 (NULL (CDR predopt))
	 (CADR predopt))
      (LIST (CONS (IF (OR (NULL predopt) (NULL (CDR predopt)))
		      (PACK* NAME '"-P")
		      (CADR predopt) )
		  (LIST 'MACRO
			'BODY
			(LIST 'LIST
			      ''EQ
			      (LIST 'LIST
				    ''CAR
				    (LIST 'CADR 'BODY))
			      (LIST 'QUOTE (LIST 'QUOTE NAME)))) ) ) ) ) )

(DEFUN FORM-STRUCT-COPIER (NAME OPTIONS)
; Formulates a copier function as a MACRO for the structure NAME in
; accordance with OPTIONS.  Returns a list consisting of the copier
; function (<name> . <definition>) pair (or NIL if no copier function
; was desired).
  (LET ((copyopt (ASSOC ':COPIER OPTIONS)) )
    ((OR (NULL copyopt)
	 (NULL (CDR copyopt))
	 (CADR copyopt))
      (LIST (CONS (IF (OR (NULL copyopt) (NULL (CDR copyopt)))
		      (PACK* 'COPY- NAME)
		      (CADR copyopt) )
		  (LIST 'MACRO
			'BODY
			(LIST 'LIST
			      ''COPY-LIST
			      (LIST 'CADR 'BODY)) ) ) ) ) ) )


(DEFUN PUTSTRUCT (NAME OPTIONS SLOTNAMS SLOTVALS NAMED? MACDEFS)
; Installs the structure NAME.
  (IF (GET NAME 'STRUCT-MACROS) (REMSTRUCT NAME) )
  (PUT NAME 'STRUCT-OPTIONS OPTIONS)
  (PUT NAME 'STRUCT-SLOTNAMES SLOTNAMS)
  (PUT NAME 'STRUCT-SLOTVALS SLOTVALS)
  (PUT NAME 'NAMED-STRUCT NAMED?)
  (PUT NAME 'STRUCT-MACROS
       (MAPCAR '(LAMBDA (MACDEF)
		    (PUT (CAR MACDEF) 'STRUCTS
			 (CONS NAME (GET (CAR MACDEF) 'STRUCTS)))
		    (PUTD (CAR MACDEF) (CDR MACDEF)) )
	       MACDEFS))
  NAME )

(DEFUN REMSTRUCT (NAME)
; Removes the structure NAME.
  (REMPROP NAME 'STRUCT-OPTIONS)
  (REMPROP NAME 'STRUCT-SLOTNAMES)
  (REMPROP NAME 'STRUCT-SLOTVALS)
  (REMPROP NAME 'NAMED-STRUCT)
  (MAPC '(LAMBDA (MACDEF)
	     (LET ((sts (REMOVE NAME (GET MACDEF 'STRUCTS))) )
	       ((NULL sts)
		 (REMPROP MACDEF 'STRUCTS)
		 (REMD MACDEF) )
	       (PUT MACDEF 'STRUCTS sts) ) )
	(GET NAME 'STRUCT-MACROS) )
  (REMPROP NAME 'STRUCT-MACROS) )

(RDS)
