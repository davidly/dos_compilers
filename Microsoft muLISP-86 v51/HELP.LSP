; File:	HELP.LSP  (C)		12/28/85	Soft Warehouse, Inc.

;			muLISP Help Facility

; To use the Help Facility, read this file into muLISP using the RDS
; command: (RDS HELP).  Then if <name> is the name of a muLISP primitive,
; the command (HELP 'name) displays <name>'s arguments or initial value
; and <name>'s page number in Chapter 5 of the muLISP Reference Manual.


(PROG1

(DEFUN HELP (NAME
    READ-CHAR RDS WRS )
  (SETQ READ-CHAR 0)
  (LOOP
    (FRESH-LINE)
    ((GET NAME 'HELP-POINTER)
      ((RDS *HELP-FILE*)
	(READPTR (GET NAME 'HELP-POINTER))
	(WRITE-LINE (READ-LINE))
	T )
      (WRITE-LINE (PACK* *HELP-FILE* "not found"))
      NIL )
    (WRITE-STRING "Enter primitive name: ")
    (CLEAR-INPUT)
    (SETQ NAME (STRING-UPCASE (READ-LINE)))
    ((EQ NAME '||)) ) )

(MOVD 'HELP '?)

(SETQ *HELP-FILE* (INPUTFILE))

(LOOP
  ((NOT (LISTEN))
    (TERPRI 2)
    (WRITE-LINE
      "For help on the muLISP primitive <name>, enter:  (HELP name)")
    (SETQ RDS) )
  ((LAMBDA (NUM LINE)
      ((EQ LINE ||))
      (PUT (STRING-RIGHT-TRIM |: | (SUBSTRING LINE 0 (FINDSTRING '| | LINE)))
	   'HELP-POINTER NUM))
    (READPTR)
    (READ-LINE)) ) )

ABS [n]				Numerical	Function	139
ACONS [key, object, alist]	Constructor	Function	36
ACOS [n]			Numerical	Function	137
ADD1 [n]			Numerical	Function	126
ADJOIN [object, list, test]	Constructor	Function	33
ALLOCATE [n]			Memory		Function	236
ALPHA-CHAR-P [symbol]		Character	Function	90
ALPHANUMERICP [symbol]		Character	Function	90
AND [form1, ... formn]		Logical		Special form	66
APPEND [list1, ... listn]	Constructor	Function	21
APPLY [function, arg1, ..., list]  Evaluator	Function	201
ASCII [atom]			Character	Function	94
ASH [n, m]			Numerical	Function	150
ASIN [n]			Numerical	Function	137
ASSOC [key, alist, test]	Searcher	Function	16
ASSOC-IF [test, alist]		Searcher	Function	16
ATAN [n]			Numerical	Function	137
ATOM [object]			Recognizer	Function	56
*AUTO-NEWLINE*: T		Screen		Control var.	265

BACKGROUND-COLOR [n]		Screen		Function	263
BINARY-LOAD [filename, offset]	Hardware	Function	255
*BLINK*: NIL			Screen		Control var.	265
BREAK [object, message]		User interface	Function	243
BUTLAST [list, n]		Constructor	Function	26

CAAAAR [object]			Selector	Function	5
CAAADR [object]			Selector	Function	5
CAAAR [object]			Selector	Function	5
CAADAR [object]			Selector	Function	5
CAADDR [object]			Selector	Function	5
CAADR [object]			Selector	Function	5
CAAR [object]			Selector	Function	5
CADAAR [object]			Selector	Function	5
CADADR [object]			Selector	Function	5
CADAR [object]			Selector	Function	5
CADDAR [object]			Selector	Function	5
CADDDR [object]			Selector	Function	5
CADDR [object]			Selector	Function	5
CADR [object]			Selector	Function	5
CAR [object]			Selector	Function	5
CATCH [label, form1, ...]	Control		Special form	226
CDAAAR [object]			Selector	Function	5
CDAADR [object]			Selector	Function	5
CDAAR [object]			Selector	Function	5
CDADAR [object]			Selector	Function	5
CDADDR [object]			Selector	Function	5
CDADR [object]			Selector	Function	5
CDAR [object]			Selector	Function	5
CDDAAR [object]			Selector	Function	5
CDDADR [object]			Selector	Function	5
CDDAR [object]			Selector	Function	5
CDDDAR [object]			Selector	Function	5
CDDDDR [object]			Selector	Function	5
CDDDR [object]			Selector	Function	5
CDDR [object]			Selector	Function	5
CDR [object]			Selector	Function	4
CEILING [n, m]			Numerical	Function	143
CHAR [atom, n]			String		Function	100
CHAR-CODE [symbol]		Character	Function	95
CHAR-DOWNCASE [symbol]		Character	Function	96
CHAR-EQUAL [sym1, ... symn]	Character	Function	93
CHAR-GREATERP [sym1, ... symn]	Character	Function	93
CHAR-LESSP [sym1, ... symn]	Character	Function	93
CHAR-NOT-EQUAL [sym1, ... symn]	Character	Function	93
CHAR-NOT-GREATERP [sym1, ... ]	Character	Function	93
CHAR-NOT-LESSP [sym1, ... symn]	Character	Function	93
CHAR-UPCASE [symbol]		Character	Function	96
CHAR= [symbol1, ... symboln]	Character	Function	92
CHAR< [symbol1, ... symboln]	Character	Function	92
CHAR> [symbol1, ... symboln]	Character	Function	92
CHAR<= [symbol1, ... symboln]	Character	Function	92
CHAR>= [symbol1, ... symboln]	Character	Function	92
CHAR/= [symbol1, ... symboln]	Character	Function	92
CLEAR-INPUT []			Input		Function	160
CLEAR-SCREEN []			Screen		Function	259
CODE-CHAR [n]			Character	Function	95
COLUMN []			Screen		Function	259
COMMENT [comments]		Control		Special form	225
COND [cond1, ... condn]		Control		Special form	221
CONS [obj1, obj2]		Constructor	Function	18
CONSP [object]			Recognizer	Function	58
CONSTANTP [object]		Evaluator	Function	197
COPY-ALIST [alist]		Constructor	Function	22
COPY-CHAR-TYPE [chr1, chr2, flg]Input		Function	167
COPY-LIST [list]		Constructor	Function	22
COPY-TREE [object]		Constructor	Function	22
COS [n]				Numerical	Function	136
COUNT [object, list, test]	Searcher	Function	11
COUNT-IF [test, list]		Searcher	Function	11
CSMEMORY [offset, value, flag]	Hardware	Function	249
CURSOR-LINES [start, endline]	Screen		Function	264

DECF [place, n]			Numerical	Macro		128
DECQ [symbol, n]		Numerical	Special form	127
DEFMACRO [sym, arglist, form1, ...]  Definition	Special form	88
DEFUN [sym, arglist, form1, ...]  Definition	Special form	87
DELETE [item, list, test]	Modifier	Function	44
DELETE-DUPLICATES [list, test]	Modifier	Function	45
DELETE-IF [test, list]		Modifier	Function	44
DELETE-LINES [n]		Screen		Function	261
DENOMINATOR [n]			Numerical	Function	141
DIGIT-CHAR-P [symbol, n]	Character	Function	91
DISPLAY-PAGE [n]		Screen		Function	265
DIVIDE [n, m]			Numerical	Function	147
DO [letlist, form1, ... formn]	Control		Macro		223
DO* [letlist, form1, ... formn]	Control		Macro		223
DOLIST [(var, list, result) form1, ...]  Control Macro		224
DOTIMES [(var, count, result) form1, ...]  Control Macro	224
DRIVER []			User interface	Function	241
DSMEMORY [offset, value, flag]	Hardware	Function	249

ECHO: NIL			I/O		Control var.	173, 190
EIGHTH [list]			Selector	Function	7
ENDP [object]			Recognizer	Function	59
EOF				I/O		Keyword		159, 180
EQ [obj1, obj2]			Comparator	Function	60
EQL [obj1, obj2]		Comparator	Function	61
EQUAL [obj1, obj2, test]	Comparator	Function	62
EVAL [object]			Evaluator	Function	199
EVAL-FUNCTION-P [symbol]	Evaluator	Function	196
EVENP [object]			Numerical	Function	114
EVERY [test, list1, ..., listn]	Evaluator	Function	212
EXECUTE [program, command-line]	Control		Function	231
EXP [n]				Numerical	Function	132
EXPT [n, m]			Numerical	Function	133

FBOUNDP [symbol]		Evaluator	Function	196
FIFTH [list]			Selector	Function	7
FILL [list, object]		Modifier	Function	40
FIND [object, list, test]	Searcher	Function	14
FIND-IF [test, list]		Searcher	Function	14
FINDSTRING [atom1, atom2, n]	String		Function	106
FIRST [list]			Selector	Function	7
FIRSTN [n, list]		Constructor	Function	23
FLAG [symbol, attribute]	Flag		Function	79
FLAGP [symbol, attribute]	Flag		Function	79
FLOOR [n, m]			Numerical	Function	142
FMAKUNBOUND [symbol]		Definition	Function	85
FOREGROUND-COLOR [n]		Screen		Function	263
FOURTH [list]			Selector	Function	7
*FREE-LIST*: '*FREE-LIST*	Memory		Variable	235
FRESH-LINE []			Output		Function	185
FUNCALL [function, arg1, ... arg2]  Evaluator	Function	203
FUNCTIONP [object]		Evaluator	Function	197

GCD [n1, n2, ..., nm]		Numerical	Function	129
GET [symbol, key]		Property	Function	77
GET-BREAK-CHARS []		Input		Function	172
GET-MACRO-CHAR [char, flag]	Input		Function	167
GETD [symbol, flag]		Definition	Function	82
GETSET [parameter]		Miscellaneous	Function	268

*HIGH-INTENSITY*: NIL		Screen		Control var.	265

IDENTITY [object]		Control		Function	219
IF [testform, thenform, elseform]  Control	Special form	220
*IGNORE-CASE*: NIL		Input		Control var.	173
INCF [place, n]			Numerical	Macro		128
INCQ [symbol, n]		Numerical	Special form	127
INPUTFILE [filename]		Input		Function	158
INSERT-LINES [n]		Screen		Function	261
INTEGER-LENGTH [n]		Numerical	Function	151
INTEGERP [object]		Recognizer	Function	55
INTERRUPT [n]			Hardware	Function	254
INTERSECTION [list1, list2, test]  Constructor	Function	34
ISQRT [n]			Numerical	Function	135

LAMBDA				Definition	Keyword		82
LAST [list]			Selector	Function	8
LCM [n1, ..., nm]		Numerical	Function	131
LCONC [dotted-pair, list]	Modifier	Function	50
LDIFF [list, tail]		Constructor	Function	25
LENGTH [object]			Selector	Function	10
LET [letlist, form1, ... formn]	Control		Macro		222
LET* [letlist, form1, ... formn]Control		Macro		222
LINELENGTH [n]			Output		Function	189
LINELENGTH: 'LINELENGTH		Output		Control var.	190
LIST [obj1, ..., objn]		Constructor	Function	19
LIST* [obj1, ..., objn]		Constructor	Function	19
LIST-LENGTH [object]		Selector	Function	10
LISTEN []			Input		Function	161
LISTP [object]			Recognizer	Function	58
LN [n]				Numerical	Function	134
LOAD [filename]			Environment	Function	239
LOCATION [object]		Hardware	Function	252
LOG [n, base]			Numerical	Function	134
LOGAND [n1, ..., nm]		Numerical	Function	149
LOGIOR [n1, ..., nm]		Numerical	Function	149
LOGNOT [n]			Numerical	Function	148
LOGXOR [n1, ..., nm]		Numerical	Function	149
LOOP [form1, ..., formn]	Control		Special form	217
LOWER-CASE-P [symbol]		Character	Function	89

MACRO				Definition	Keyword		82
MACRO-FUNCTION [symbol]		Evaluator	Function	205
MACRO-FUNCTION-P [symbol]	Evaluator	Function	196
MACROEXPAND [form]		Evaluator	Function	206
MACROEXPAND-1 [form]		Evaluator	Function	206
MAKE-LIST [n, object, list]	Constructor	Function	20
MAKE-RANDOM-STATE [state]	Numerical	Function	153
MAKE-WINDOW [row, col, rows, cols]  Screen	Function	262
MAPC [function, list1, ...]	Evaluator	Function	208
MAPCAN [function, list1, ...]	Evaluator	Function	210
MAPCAR [function, list1, ...]	Evaluator	Function	209
MAPCON [function, list1, ...]	Evaluator	Function	210
MAPL [function, list1, ...]	Evaluator	Function	208
MAPLIST [function, list1, ...]	Evaluator	Function	209
MAX [n1, ..., nm]		Numerical	Function	121
MEMBER [object, list, test]	Searcher	Function	13
MEMBER-IF [test, list]		Searcher	Function	13
MEMORY [address, value, flag]	Hardware	Function	247
MERGE [list1, list2, test]	Modifier	Function	52
MIN [n1, ..., nm]		Numerical	Function	121
MINUSP [object]			Numerical	Function	113
MISMATCH [list1, list2, test]	Searcher	Function	12
MOD [n, m]			Numerical	Function	146
MOVD [symbol1, symbol2]		Definition	Function	84

NBUTLAST [list, n]		Modifier	Function	42
NCONC [list1, ..., listn]	Modifier	Function	41
NEQ [obj1, obj2]		Comparator	Function	60
NEQL [obj1, obj2]		Comparator	Function	61
NIL				Evaluator	Constant	197
NINTH [list]			Selector	Function	7
NLAMBDA				Definition	Keyword		82
NO-EVAL-FUNCTION-P [symbol]	Evaluator	Function	196
NOT [object]			Logical		Function	65
NOTANY [test, list1, ...]	Evaluator	Function	211
NOTEVERY [test, list1, ...]	Evaluator	Function	212
NRECONC [list, object]		Modifier	Function	43
NREVERSE [list, object]		Modifier	Function	43
NSUBLIS [alist, object, test]	Modifier	Function	48
NSUBST [new, old, object, test]	Modifier	Function	47
NSUBST-IF [new, test, object]	Modifier	Function	47
NSUBSTITUTE [new, old, list, test]  Modifier	Function	46
NSUBSTITUTE-IF [new, test, list]  Modifier	Function	46
NTH [n, list]			Selector	Function	9
NTHCDR [n, list]		Selector	Function	9
NULL [object]			Recognizer	Function	57
NUMBERP [object]		Recognizer	Function	55
NUMERATOR [n]			Numerical	Function	141
NUMERIC-CHAR-P [symbol]		Character	Function	90

OBLIST []			Constructor	Function	37
ODDP [object]			Numerical	Function	114
OPENFILES []			Input		Function	158
OR [form1, ..., formn]		Logical		Special form	67
ORDERP [object1, object2]	Comparator	Function	64
OUTPUTFILE [filename]		Output		Function	179

PACK [list]			String		Function	98
PACK* [atom1, ..., atomn]	String		Function	98
PAIRLIS [keys, objects, alist]	Constructor	Function	36
PEEK-CHAR [flag]		Input		Function	164
PI []				Numerical	Function	138
PLUSP [object]			Numerical	Function	113
POP [symbol]			Assignment	Special form	73
PORTIO [port, value, flag]	Hardware	Function	251
POSITION [object, list, test]	Searcher	Function	15
POSITION-IF [test, list]	Searcher	Function	15
PRECISION [n]			Numerical	Function	109
PRIN1 [object]			Output		Function	183
PRINC [object]			Output		Function	184
PRINT [object]			Output		Function	184
*PRINT-BASE*: 10		Output		Control var.	191
*PRINT-DOWNCASE*: NIL		Output		Control var.	190
*PRINT-ESCAPE*: T		Output		Control var.	191
PRINT-LENGTH [atom]		String		Function	107
*PRINT-POINT*: 7		Output		Control var.	192
*PRINTER-ECHO*: NIL		Output		Control var.	193
PROG1 [form1, ... formn]	Control		Special form	218
PROG2 [form1, ... formn]	Control		Macro		218
PROGN [form1, ... formn]	Control		Special form	216
PSETQ [symbol1, form1, ...]	Assignment	Special form	71
PUSH [form, symbol]		Assignment	Special form	74
PUSHNEW [form, symbol, test]	Assignment	Macro		74
PUT [symbol, key, object]	Property	Function	76
PUTD [symbol, definition]	Definition	Function	83
PUTD: 'PUTD			Definition	Control var.	86

QUOTE [object]			Control		Special form	215

RANDOM [n, state]		Numerical	Function	152
*RANDOM-STATE*			Numerical	Control var.	153
RANDOM-STATE-P [object]		Numerical	Function	154
RASSOC [key, alist, test]	Searcher	Function	17
RASSOC-IF [test, alist]		Searcher	Function	17
RATIONALP [object]		Recognizer	Function	55
RATOM []			Input		Function	171
RDS [filename]			Input		Function	156
READ []				Input		Function	166
*READ-BASE*: 10			Input		Control var.	173
READ-BYTE []			Input		Function	165
READ-CHAR [peek-flag]		Input		Function	162
READ-CHAR: 'READ-CHAR		Input		Control var.	173
READ-LINE []			Input		Function	165
*READ-UPCASE*: T		Input		Control var.	174
READPTR [n]			Input		Function	159
RECLAIM []			Memory		Function	232
REDUCE [function, list, init]	Evaluator	Function	213
REGISTER [n, m]			Hardware	Function	253
REM [n, m]			Numerical	Function	146
REMD [symbol]			Definition	Function	85
REMFLAG [symbol, attribute]	Flag		Function	80
REMOVE [item, list, test]	Constructor	Function	28
REMOVE-DUPLICATES [list, test]	Constructor	Function	29
REMOVE-IF [test, list]		Constructor	Function	28
REMPROP [symbol, key]		Property	Function	78
REPLACE [list1, list2]		Modifier	Function	40
REST [list]			Selector	Function	7
RESTART []			Control		Function	230
RETURN [object]			Control		Function	229
REVAPPEND [list, object]	Constructor	Function	27
REVERSE [list, object]		Constructor	Function	27
ROUND [n, m]			Numerical	Function	145
ROW []				Screen		Function	259
RPLACA [obj1, obj2]		Modifier	Function	38
RPLACD [obj1, obj2]		Modifier	Function	39

SAVE [filename]			Environment	Function	237
SECOND [list]			Selector	Function	7
SET [symbol, object]		Assignment	Function	69
SET-BREAK-CHARS [list, flag]	Input		Function	172
SET-CURSOR [row, column]	Screen		Function	259
SET-DIFFERENCE [list1, list2, test]  Constructor  Function	35
SET-MACRO-CHAR [char, defn, flg]  Input		Function	167
SETF [place1, form1, ... ]	Assignment	Macro		72
SETQ [symbol1, form1, ...]	Assignment	Special form	70
SEVENTH [list]			Selector	Function	7
SHIFT [n, m]			Numerical	Function	150
SIGNUM [n]			Numerical	Function	140
SIN [n]				Numerical	Function	136
SIXTH [list]			Selector	Function	7
SNAPSHOT [address, atom]	Hardware	Function	256
SOME [test, list1, ... listn]	Evaluator	Function	211
SORT [list, test]		Modifier	Function	53
SPACES [n]			Output		Function	186
SPECIAL				Definition	Keyword		82
SPECIAL-FORM-P [symbol]		Evaluator	Function	196
SPLIT [list]			Modifier	Function	51
SQRT [n]			Numerical	Function	135
STABLE-SORT [list, test]	Modifier	Function	53
STACK-LIST []			Constructor	Function	37
STRING-CAPITALIZE [atom]	String		Function	105
STRING-DOWNCASE [atom]		String		Function	105
STRING-EQUAL [atom1, atom2]	String		Macro		101
STRING-GREATERP [atom1, atom2]	String		Macro		103
STRING-LEFT-TRIM [chars, atom]	String		Function	104
STRING-LESSP [atom1, atom2]	String		Macro		103
STRING-NOT-EQUAL [atm1, atm2]	String		Macro		103
STRING-NOT-GREATERP [atm1, atm2]  String	Macro		103
STRING-NOT-LESSP [atm1, atm2]	String		Macro		103
STRING-RIGHT-TRIM [chars, atom]	String		Function	104
STRING-TRIM [chars, atom]	String		Function	104
STRING-UPCASE [atom]		String		Function	105
STRING=  [atom1, atom2, flag]	String		Function	101
STRING<  [atom1, atom2, flag]	String		Function	102
STRING>  [atom1, atom2, flag]	String		Function	102
STRING<=  [atom1, atom2, flag]	String		Function	102
STRING>=  [atom1, atom2, flag]	String		Function	102
STRING/=  [atom1, atom2, flag]	String		Function	102
STRINGP [object]		Recognizer	Function	54
SUB1 [n]			Numerical	Function	126
SUBLIS [alist, object, test]	Constructor	Function	32
SUBLIST [list, n, m]		Constructor	Function	24
SUBSETP [list1, list2, test]	Comparator	Function	63
SUBST [new, old, object, test]	Constructor	Function	31
SUBST-IF [new, test, object]	Constructor	Function	31
SUBSTITUTE [new, old, list, test]  Constructor	Function	30
SUBSTITUTE-IF [new, test, list]	Constructor	Function	30
SUBSTRING [atom, n, m]		String		Function	99
SYMBOL-FUNCTION [symbol]	Evaluator	Function	198
SYMBOL-PLIST [symbol]		Evaluator	Function	198
SYMBOL-VALUE [symbol]		Evaluator	Function	198
SYMBOLP [object]		Recognizer	Function	54
SYSTEM [n]			Control		Function	230

TAILP [list1, list2]		Comparator	Function	63
TAN [n]				Numerical	Function	136
TCONC [dotted-pair, object]	Modifier	Function	49
TENTH [list]			Selector	Function	7
TERPRI [n]			Output		Function	185
THIRD [list]			Selector	Function	7
THROW [label, object]		Control		Function	228
TIME [flag]			Miscellaneous	Function	267
TONE [frequency, duration]	Miscellaneous	Function	266
TREE-EQUAL [object1, object2, test]  Comparator	Function	62
TRUNCATE [n, m]			Numerical	Function	144

UNDEFINED [symbol, form1, ...]	Evaluator	Function	204
UNDERFLOW [n]			Numerical	Function	111
UNION [list1, list2, test]	Constructor	Function	34
UNLESS [testform, form1, ... formn]  Control	Macro		220
UNPACK [atom]			String		Function	97
UNREAD-CHAR []			Input		Function	163
UNWIND-PROTECT [form1, form2, ...]  Control	Special form	227
UPPER-CASE-P [symbol]		Character	Function	89

WHEN [testform, form1, ... formn]  Control	Macro		220
WRITE-BYTE [n]			Output		Function	188
WRITE-LINE [symbol]		Output		Function	187
WRITE-STRING [symbol]		Output		Function	187
WRITEPTR [n]			Output		Function	180
WRS [filename, reopen-flag]	Output		Function	176

Y-OR-N-P [message]		User interface	Function	246
YES-OR-NO-P [message]		User interface	Function	246

ZEROP [object]			Numerical	Function	112
+ [n1, ..., nm]			Numerical	Function	122
- [n1, ..., nm]			Numerical	Function	123
* [n1, ..., nm]			Numerical	Function	124
/ [n1, ..., nm]			Numerical	Function	125

= [n1, ..., nm]			Numerical	Function	115
/= [n1, ..., nm]		Numerical	Function	116
< [n1, ..., nm]			Numerical	Function	117
> [n1, ..., nm]			Numerical	Function	118
<= [n1, ..., nm]		Numerical	Function	119
>= [n1, ..., nm]		Numerical	Function	120

\  back slash			Input		Escape char.	166
|  vertical bar			Input		Escape char.	166

(  left parenthesis		Input		Macro char.	168
)  right parenthesis		Input		Macro char.	168
]  right square bracket		Input		Macro char.	168
,  comma			Input		Macro char.	169
'  single quote			Input		Macro char.	169
"  double quote			Input		Macro char.	170
;  semicolon			Input		Macro char.	169

++				User interface	Variable	241
+++				User interface	Variable	241
**				User interface	Variable	241
***				User interface	Variable	241
