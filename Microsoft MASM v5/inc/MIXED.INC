; High-Level-Language Interface Macros - Version 1.0
;   for Microsoft Macro Assembler 5.0
; (C) Copyright Microsoft Corporation, 1987.

;   Syntax		     Purpose
;   ------		     -------
;
;   setModel		     Sets model from text equate
;
;   hProc  <name [NEAR|FAR]> [,<USES reglist>] [,arg[:type] [,arg[:type]]]...
;			     Starts a procedure with optional stack arguments
;
;   hLocal var[:type] [,var[:type]]...
;			     Defines local stack variables
;
;   hRet		     Returns from the current procedure
;
;   hEndp		     Ends the current procedure
;
;   ifFP  statement	     Assembles statement if far data
;
;   FPoperand		     Conditionally provides ES override for data
;
;   pLes  register,address   Conditionally loads data through ES
;
;   pLds  register,address   Conditionally loads data through DS

if1

; Set model passed from command line

setModel macro
    setModelDoit %model
endm

setModelDoit macro option

    .model option
endm

; Declare high level routine and parameters

hProc macro funName, a,b,c,d,e,f,g,h,i,j

; FP - supply far pointer ES overide as needed

    if @Datasize
      FP equ <es:>
    else
      FP equ < >
    endif

    cParm=0
    cbLocals=0
    argBase = 2 + @CodeSize*2
    cbReturn = 0
    localBase = 2

    tokenize funName
    adjustType %token1
    conCat procName, %token0
    conCat nearFar, %token1

    tokenize a
    hScanParms %token0, <a>, b,c,d,e,f,g,h,i,j

    hProcFinish %procName, %nearFar, %regPushed
    endm

; Preprocess arg list to save registers

hScanParms macro use, regList, b,c,d,e,f,g,h,i,j

    ifidni <use>,<uses>
	regPushed equ <regList>
	hScanArgs b,c,d,e,f,g,h,i,j
    else
	regPushed equ <>
	hScanArgs regList,b,c,d,e,f,g,h,i,j
    endif
endm

; Scan parameter list to process args

hScanArgs macro a,b,c,d,e,f,g,h,i,j

    irp arg,<a,b,c,d,e,f,g,h,i,j>

	ifb <arg>
	    exitm
	endif

	fetType arg

	ifdef cLang
	    createArg %argNameCur, %typeNameCur, %argBase+cParm+2
	else
	    createArg %argNameCur, %typeNameCur, %argBase-cbType-cParm,+cParm
	endif

	cParm = cParm + cbType + 2
    endm
endm

; Generate procedure and stack frame

hProcFinish macro funName, nearFar, regList

    ifdef cLang
	funNameCur equ <_&funName>
    else
	funNameCur equ <funName>
	cbReturn = cParm

    endif

    funNameCur proc nearFar
	public funNameCur
	if cParm
	    push    Bp
	    mov     Bp,Sp
	endif
	pushReg regList
endm

; Save registers

pushReg macro use,b,c,d,e,f,g

	regPushed equ <>
	irp reg, <b,c,d,e,f,g>

	    ifb <reg>
		exitm
	    endif

	    conCat regPushed, <,> %regPushed
	    conCat regPushed, reg, %regPushed
	    push   reg
	    localBase = localBase + 2
	endm
endm

; Declare local stack variables

hLocal macro a,b,c,d,e,f,g,h,i,j

    irp arg,<a,b,c,d,e,f,g,h,i,j>

	ifb <arg>
	    exitm
	endif

	fetType arg
	createArg %argNameCur, %typeNameCur, %-cbLocals-localBase

	cbLocals = cbLocals + cbType + 2
    endm

    ife cParm			    ; Create empty frame if no params
	push	Bp
	mov	Bp,Sp
    endif

    sub Sp,cbLocals
endm

; Split argment into argNameCur and typeNameCur

fetType macro arg
    cbType=0
    fColon=0
    argNameCur equ < >
    typeNameCur equ < >
    .xcref fColon, argNameCur

    irpc aChar,arg
	if fColon
	    conCat typeNameCur, %typeNameCur, aChar
	else
	    ifidni <aChar>,<:>
		fColon=1
	    else
		conCat argNameCur,%argNameCur,aChar
	    endif
	endif
    endm
    adjustType %typeNameCur
endm

; Tokenize arg into text macro name tokenN
tokenize macro a,b,c,d,e,f,g,h,i,j

    cPart = 0
    doTokenSet 1

    irp aWord,<a,b,c,d,e,f,g,h,i,j>
	ifb <aWord>
	    exitm
	endif

	doTokenSet %cPart, aWord
	cPart = cPart+1
    endm
endm

; Set tokenN to a value

doTokenSet macro tokenNum, aWord
    token&tokenNum equ <aWord>
    endm

; Map typeName to byte count and ptr size

adjustType macro typeName

    ifb <typeName>
	cbType = 0
	typeNameCur equ <word>
	exitm
    endif

    ifidni <typeName>,<byte>
	cbType = 0
	exitm
    endif

    ifidni <typeName>,<word>
	cbType = 0
	exitm
    endif

    ifidni <typeName>,<dword>
	cbType = 2
	exitm
    endif

    ifidni <typeName>,<ptr>
	cbType = (1 + @DataSize) AND 2
	if (cbType EQ 2)
	    typeNameCur equ <dword>
	else
	    typeNameCur equ <word>
	endif
	exitm
    endif

    ifidni <typeName>,<fword>
	cbType = 4
	exitm
    endif

    ifidni <typeName>,<qword>
	cbType = 6
	exitm
    endif

    ifidni <typeName>,<tword>
	cbType = 8
	exitm
    endif

    ifidni <typeName>,<near>
	argBase = 2
	exitm
    endif

    ifidni <typeName>,<far>
	argBase = 4
    endif
endm

; Concatenate a character to a text macro

conCat macro symbol,text,char
    symbol equ <text&char>
endm

; Create text macro for an arg

createArg macro argName, typeName, offsetParm, argFactor
    argName equ <typeName ptr [Bp]+offsetParm&argFactor>
endm

; Generate high level return

hRet macro

    popRegs %regPushed

    if cParm or cbLocals
	pop	Bp
    endif
	ret	cbReturn
endm

; Restore saved registers

popRegs macro regList

    if cbLocals
      ifnb <regList>
	    add     Sp,cbLocals
	else
	    mov     Sp,Bp
      endif
    endif

    irp reg, <regList>
	ifnb <reg>
	    pop reg
	endif
    endm
endm

; End a high level procedure

hEndp macro
funNameCur  endp
endm

; Execute instruction if far data

ifFP	macro a,b,c,d,e,f,g,h,i,j

if @datasize
       a b c d e f g h i j
endif
endm

; Load 16/32 bit pointers into [ES:] reg

pLes macro reg, address

    if @datasize

	les reg,address
    else
	mov reg,address

    endif
endm

;Load 16/32 bit pointers into [DS:] reg

pLds macro reg, address

    if @datasize

	lds reg,address
    else
	mov reg,address

    endif
endm

.xcref createArg, conCat, fetType, cbType, argBase, pushReg, hScanArgs, hScanParms
.xcref adjustType, typeNameCur, setModelDoit, tokenize, dotokenSet
.xcref token0, token1, regPushed, hProcFinish, procName, localBase, popRegs

endif ; Define on pass1 only
