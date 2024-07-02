;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    Strings, operations on strings					   *)
;(*                                                                        *)
;(*    Release :    Dec 89                                                 *)
;(*                                                                        *)
;(*    Copyright (C)  1987, 1989 Logitech, All rights reserved             *)
;(*                                                                        *)
;(*    Permission is hereby granted to registered users to use or abstract *)
;(*    the following program in the implementation of customized versions. *)
;(*    This permission does not include the right to redistribute the      *)
;(*    source code of this program.                                        *)
;(*                                                                        *)
;(**************************************************************************)

	TITLE	Strings

	.RADIX	16

	PUBLIC	L__ConstAssign__Strings
	PUBLIC	L__Assign__Strings
	PUBLIC	L__Insert__Strings
	PUBLIC	L__Delete__Strings
	PUBLIC	L__Pos__Strings
	PUBLIC	L__Copy__Strings
	PUBLIC	L__Concat__Strings
	PUBLIC	L__Length__Strings
	PUBLIC	L__CompareStr__Strings

	PUBLIC	$INIT__Strings

        PUBLIC  KEY__10aug87_2031_OF_Strings
        PUBLIC  $OK__31jul87_1000_OF_Strings

KEY__10aug87_2031_OF_Strings EQU 0

IFDEF OS2
        EXTRN   DynParCopy_RTSLang:FAR
ELSE
        EXTRN   DynParCopy__RTSLanguage:FAR
ENDIF


MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__31jul87_1000_OF_Strings DW 0AEFFH,0258H,0
MODULE_TABLE_DATA ENDS

IFDEF MEDIUM
DGROUP	GROUP	MODULE_TABLE_DATA
ENDIF

Strings_TEXT	SEGMENT BYTE PUBLIC 'CODE'
                ASSUME  CS:Strings_TEXT
                ASSUME  DS:NOTHING
$BM__Strings:


;
; PROCEDURE Length (VAR str: ARRAY OF CHAR): CARDINAL;
;

L__Length__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP

	MOV	CX,[BP+000AH]
	INC	CX

	MOV	AL,0
	CLD
	LES	DI,[BP+0006H]
	REPNZ	SCASB
	JNE	$33
	DEC	DI

$33:
	MOV	AX,DI
	SUB	AX,[BP+0006H]

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	0006H

L__Length__Strings	ENDP

;
; PROCEDURE ConstAssign (source          : ARRAY OF CHAR;
;                        VAR destination : ARRAY OF CHAR);
;

L__ConstAssign__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP
	MOV	DI,000CH
	MOV	CX,0001
IFDEF OS2
	CALL	DynParCopy_RTSLang
ELSE
	CALL	DynParCopy__RTSLanguage
ENDIF
	PUSH	[BP+0010H]
	LES	BX,[BP+000CH]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	CX,AX

	MOV	AX,[BP+000AH]
	INC	AX

	CLD
	CMP	AX,CX
	JA	$00

	MOV	CX,AX

$00:	MOV	BX,CX

	LES	DI,[BP+0006]
	JCXZ	$01

	LDS	SI,[BP+000CH]
	REPNZ	MOVSB

$01:	CMP	AX,BX
	JNA	$02

	MOV	BYTE PTR ES:[DI],0

$02:

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	000CH

L__ConstAssign__Strings	ENDP


;
; PROCEDURE Assign (VAR source      : ARRAY OF CHAR;
;                   VAR destination : ARRAY OF CHAR);
;

L__Assign__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP

	PUSH	[BP+0010H]
	LES	BX,[BP+000CH]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	CX,AX

	MOV	AX,[BP+000AH]
	INC	AX

	CLD
	CMP	AX,CX
	JA	$10

	MOV	CX,AX

$10:	MOV	BX,CX

	LES	DI,[BP+0006H]
	JCXZ	$11
	LDS	SI,[BP+000CH]
	REPNZ	MOVSB

$11:
	CMP	AX,BX
	JBE	$12

	MOV	BYTE PTR ES:[DI],0
$12:

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF
	MOV	SP,BP
	POP	BP
	RET	000CH

L__Assign__Strings	ENDP


;
; PROCEDURE Insert (substr: ARRAY OF CHAR;
;                   VAR str: ARRAY OF CHAR;
;                   inx: CARDINAL);
;

L__Insert__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP
	SUB	SP,6
	MOV	DI,000EH
	MOV	CX,0001H
IFDEF OS2
	CALL	DynParCopy_RTSLang
ELSE
        CALL    DynParCopy__RTSLanguage
ENDIF

;	y:= Length(substr);

	PUSH	[BP+0012H]
	LES	BX,[BP+000EH]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	[BP-0004H],AX

;	IF y <> 0 THEN

	TEST	AX,AX
	JNE	$13
	JMP	$14

$13:
;	  x:=Length(str);     (* len of destination *)

	PUSH	[BP+000CH]
	LES	BX,[BP+0008H]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	[BP-0006H],AX

;	  IF inx > x THEN

	MOV	CX,[BP+0006H]
	CMP	CX,AX
	JBE	$15

;	    inx:=x            (* adjust 'inx' to len of 'str' *)

	MOV	[BP+0006H],AX

$15:
;	  END;
;	  IF x+y <= HIGH(str) THEN

	MOV	AX,[BP-0006H]
	ADD	AX,[BP-0004H]
	CMP	AX,[BP+000CH]
	JNBE	$16

;	    str[x+y]:=EOS     (* set EOS at end of sum of strings *)

	LES	BX,[BP+0008H]
	MOV	SI,AX
	MOV	BYTE PTR ES:[BX+SI],0

$16:
;	  END;
;	  IF y > HIGH(str)+1-inx THEN

	MOV	AX,[BP+000CH]
	INC	AX
	SUB	AX,[BP+0006H]
	CMP	[BP-0004H],AX
	JBE	$17

;	    y:=HIGH(str)+1-inx; (* adjust y to remaining len *)

	MOV	[BP-0004H],AX

$17:
;	  END;
;	  IF x > HIGH(str)+1-y  THEN

	MOV	AX,[BP+000CH]
	INC	AX
	SUB	AX,[BP-0004H]
	CMP	[BP-0006H],AX
	JBE	$18

;	    z:=HIGH(str)+1-inx-y;

	SUB	AX,[BP+0006H]
	MOV	[BP-0002H],AX
	JMP	SHORT $19

$18:
;	  ELSE
;	    z:=x-inx;

	MOV	AX,[BP-0006H]
	SUB	AX,[BP+0006H]
	MOV	[BP-0002H],AX

$19:
;	  END;
;	  x:=inx+z;

	ADD	AX,[BP+0006H]
	MOV	[BP-0006H],AX


	MOV	CX,[BP-0002H]
	CLD
	JCXZ	$20
	LDS	SI,[BP+0008H]
	ADD	SI,[BP-0006H]
	DEC	SI
	PUSH	DS
	POP	ES
	MOV	DI,SI
	ADD	DI,[BP-0004H]
	STD
	REPNZ	MOVSB
	CLD

$20:
	MOV	CX,[BP-0004H]
	JCXZ	$21
	LDS	SI,[BP+000EH]
	LES	DI,[BP+0008H]
	ADD	DI,[BP+0006H]
	REPNZ	MOVSB

$14:
$21:
;	END;

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	000EH

L__Insert__Strings	ENDP


;
; PROCEDURE Delete (VAR str: ARRAY OF CHAR;
;                   inx: CARDINAL;
;                   len: CARDINAL);
;

L__Delete__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP

	PUSH	[BP+000EH]
	LES	BX,[BP+000AH]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	CX,AX

	CLD
	CMP	WORD PTR [BP+0006H],0
	JE	$22

	SUB	CX,[BP+0008H]
	JBE	$22

	LES	DI,[BP+000AH]
	ADD	DI,[BP+0008H]
	SUB	CX,[BP+0006H]
	JBE	$23

	MOV	SI,DI
	PUSH	ES
	POP	DS
	ADD	SI,[BP+0006H]
	REPNZ	MOVSB

$23:
	MOV	BYTE PTR ES:[DI],0

$22:

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	000AH

L__Delete__Strings	ENDP


;
; PROCEDURE Pos (substr, str: ARRAY OF CHAR): CARDINAL;
;

L__Pos__Strings		PROC	FAR

	PUSH	BP
	MOV	BP,SP
	SUB	SP,0006H
;	MOV	DI,000CH
;	MOV	CX,0001H
;	CALL	DynParCopy_RTSLang
;	MOV	DI,0006H
;	MOV	CX,0001H
;	CALL	DynParCopy_RTSLang

;	lsub := Length(substr);

	PUSH	[BP+0010H]
	LES	BX,[BP+000CH]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	[BP-0004H],AX

;	ls := Length(str);

	PUSH	[BP+000AH]
	LES	BX,[BP+0006H]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	[BP-0002H],AX

;	IF  (lsub <> 0)  THEN

	CMP	WORD PTR [BP-0004H],0
	JE	$24

;	  i := 0;

	MOV	WORD PTR [BP-0006H],0

$26:
;	  WHILE i + lsub <= ls DO

	MOV	AX,[BP-0006H]
	ADD	AX,[BP-0004H]
	CMP	AX,[BP-0002H]
	JNBE	$24

	MOV	CX,[BP-0004H]
	CLD
	LDS	SI,[BP+0006H]
	LES	DI,[BP+000CH]
	ADD	SI,[BP-0006H]
	REPE	CMPSB
	JNE	$25

	MOV	AX,[BP-0006H]

$27:

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	000CH

$25:
	INC	WORD PTR [BP-0006H]
	JMP	$26

$24:
;	RETURN HIGH(str)+1

	MOV	AX,[BP+000AH]
	INC	AX
	JMP	$27

L__Pos__Strings		ENDP


;
; PROCEDURE  Copy (str: ARRAY OF CHAR;
;                  inx: CARDINAL;
;                  len: CARDINAL;
;                  VAR result: ARRAY OF CHAR);
;

L__Copy__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP
	PUSH	AX
	MOV	DI,0010H
	MOV	CX,0001H
IFDEF OS2
	CALL	DynParCopy_RTSLang
ELSE
        CALL    DynParCopy__RTSLanguage
ENDIF

;	x:= Length(str);

	PUSH	[BP+0014H]
	LES	BX,[BP+0010H]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	[BP-0002H],AX

;	IF  (inx < x)  THEN

	MOV	CX,[BP+000EH]
	CMP	CX,AX
	JNB	$28

;	  IF  ((inx + len) > x)  THEN

	MOV	AX,[BP+000EH]
	ADD	AX,[BP+000CH]
	CMP	AX,[BP-0002H]
	JBE	$29

;	    len:= x-inx;

	MOV	AX,[BP-0002H]
	SUB	AX,[BP+000EH]
	MOV	[BP+000C],AX

$29:
;	  END;
;	  IF  (len > (HIGH(result)+1))  THEN

	MOV	AX,[BP+000AH]
	INC	AX
	CMP	[BP+000CH],AX
	JBE	$30

;	    len:= HIGH(result)+1;

	MOV	[BP+000CH],AX

$30:
;	  END; 

	MOV	CX,[BP+000CH]
	CLD
	LES	DI,[BP+0006H]
	JCXZ	$31
	LDS	SI,[BP+0010H]
	ADD	SI,[BP+000EH]
	REPNZ	MOVSB

$31:
	MOV	CX,[BP+000CH]
	CMP	CX,[BP+000AH]
	JNBE	$32
	MOV	BYTE PTR ES:[DI],0
	JMP	SHORT $32

$28:
;	ELSE  (* 'inx' points after end of string *)

	LES	DI,[BP+0006H]
	MOV	BYTE PTR ES:[DI],0

$32:
;	END;

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	0010H

L__Copy__Strings	ENDP


;
; PROCEDURE Concat (s1, s2: ARRAY OF CHAR;
;                   VAR result: ARRAY OF CHAR);
;

L__Concat__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP
	MOV	DI,0012H
	MOV	CX,0001H
IFDEF OS2
	CALL	DynParCopy_RTSLang
ELSE
	CALL    DynParCopy__RTSLanguage
ENDIF
	MOV	DI,000CH
	MOV	CX,0001H
IFDEF OS2
	CALL	DynParCopy_RTSLang
ELSE
	CALL    DynParCopy__RTSLanguage
ENDIF

;	Assign(s1,result);

	PUSH	[BP+0016H]
	LES	BX,[BP+0012H]
	PUSH	ES
	PUSH	BX
	PUSH	[BP+000AH]
	LDS	SI,[BP+0006H]
	PUSH	DS
	PUSH	SI
	CALL	L__Assign__Strings

;	Insert(s2,result,Length(s1))

	PUSH	[BP+0010H]
	LES	BX,[BP+000CH]
	PUSH	ES
	PUSH	BX
	PUSH	[BP+000AH]
	LDS	SI,[BP+0006H]
	PUSH	DS
	PUSH	SI
	PUSH	[BP+0016H]
	LES	DI,[BP+0012H]
	PUSH	ES
	PUSH	DI
	CALL	L__Length__Strings
	PUSH	AX
	CALL	L__Insert__Strings

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	0012H

L__Concat__Strings	ENDP


;
; PROCEDURE CompareStr (s1, s2: ARRAY OF CHAR): INTEGER;
;

L__CompareStr__Strings	PROC	FAR

	PUSH	BP
	MOV	BP,SP
;	MOV	DI,000CH
;	MOV	CX,0001H
;	CALL	DynParCopy_RTSLang
;	MOV	DI,0006H
;	MOV	CX,0001H
;	CALL	DynParCopy_RTSLang

	PUSH	[BP+000AH]
	LES	BX,[BP+0006H]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	DX,AX

	PUSH	DX
	PUSH	[BP+0010H]
	LES	BX,[BP+000CH]
	PUSH	ES
	PUSH	BX
	CALL	L__Length__Strings
	MOV	CX,AX
	POP	DX
	CLD
	XOR	AX,AX
	CMP	DX,CX
	JE	$34
	JA	$35

	MOV	AX,0FFFFH
	JMP	SHORT $34

$35:
	MOV	CX,DX
	MOV	AX,0001H

$34:
	INC	CX
	LES	DI,[BP+0006H]
	LDS	SI,[BP+000CH]
	REPE	CMPSB
	JCXZ	$36
	JNBE	$37

	MOV	AX,0FFFFH
	JMP	SHORT $36

$37:
	MOV	AX,0001H

$36:

IFDEF MEDIUM
	MOV	BX,DGROUP
	MOV	DS,BX
ENDIF

	MOV	SP,BP
	POP	BP
	RET	000CH

L__CompareStr__Strings	ENDP



;$BODY__Strings	PROC	FAR
;	RET
;$BODY__Strings	ENDP


$INIT__Strings	PROC	FAR
	RET
$INIT__Strings	ENDP


Strings_TEXT	ENDS

	END
