;_ macros.asm   Wed Feb  3 1988   Modified by: Walter Bright */
; Copyright (C) 1985-1988 by Northwest Software
; All Rights Reserved
; Written by Walter Bright

; Determine which memory model we are assembling for. For .COM files,
; force S model.
    ifdef I8086T
I8086S equ	1
    else
    ifndef I8086S
    ifndef I8086M
    ifndef I8086C
    ifndef I8086L		;if none of the memory models are defined
I8086S equ	1		;default to S model
    endif
    endif
    endif
    endif
    endif

ifdef __OS2__
	.286C
endif

;Decide if SI and DI are saved across function calls
SAVESIDI equ	1		;1 means SI and DI are saved across functions

;Decide if we want to use Microsoft C calling conventions
;or Lattice C calling conventions
MSC	equ	1		;ifdef means use Microsoft C calling conventions
				;ifndef means use Lattice

; Macros to bracket data segment stuff.

begdata	macro
    ifdef MSC
_DATA	segment word public 'DATA'
_DATA	ends
CONST	segment word public 'CONST'
CONST	ends
_BSS	segment word public 'BSS'
_BSS	ends
DGROUP	group	_DATA,CONST,_BSS
_DATA	segment
    else
DGROUP	group	data
data	segment	word public 'data'
    endif
	assume ds:DGROUP
	endm

enddata	macro
    ifdef MSC
_DATA	ends
    else
data	ends
    endif
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macros specific to each memory model in an attempt to make it easier
; to write memory model independent code.
;	begcode,endcode		Use to bracket code sections
;	P			Offset on BP to first argument on stack
;				(excluding any local variables)
;	SPTR			1 if small data model
;	LPTR			1 if large pointers (large data)
;	LCODE			1 if large code model
;	ESeqDS			1 if ES == DS at all times
;	SSeqDS			1 if SS == DS at all times
;	SIZEPTR			# of bytes in a pointer
;	func			Declare a function as NEAR or FAR
;	callm			Call function as NEAR or FAR

;;;;;;;;;;;;;; SMALL MEMORY MODEL ;;;;;;;;;;;;;;;;;

ifdef I8086S
    ifdef MSC
begcode	macro	module
_TEXT	segment	word public 'CODE'
	assume	cs:_TEXT
	endm

endcode	macro	module
_TEXT	ENDS
	endm
    else
begcode	macro	module
pgroup	group	prog
prog	segment	byte public 'prog'
	assume	cs:pgroup
	endm

endcode	macro	module
prog	ends
	endm
    endif

P	equ	4	; Offset of start of parameters on the stack frame
SPTR	equ	1
LPTR	equ	0
LCODE	equ	0
ESeqDS	equ	0
SSeqDS	equ	1
SIZEPTR	equ	2	; Size of a pointer

    ifdef MSC
func	macro	name
_&name	proc	near
    ifndef name
name	equ	_&name
    endif
	endm

callm	macro	name
	call	near ptr _&name
	endm
    else
func	macro	name
name	proc	near
	endm

callm	macro	name
	call	near ptr name
	endm
    endif
endif

;;;;;;;;;;;;;;;;; MEDIUM MEMORY MODEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ifdef I8086M
    ifdef MSC
begcode	macro	module
module&_TEXT	segment word public 'CODE'
	assume	cs:module&_TEXT
	endm

endcode	macro	module
module&_TEXT	ends
	endm
    else
begcode	macro	module
module&_code	segment	byte public 'code'
	assume	cs:module&_code
	endm

endcode	macro	module
module&_code	ends
	endm
    endif

P	equ	6	; Offset of start of parameters on the stack frame
SPTR	equ	1
LPTR	equ	0
LCODE	equ	1
ESeqDS	equ	0
SSeqDS	equ	1
SIZEPTR	equ	2

    ifdef MSC
func	macro	name
_&name	proc	far
    ifndef name
name	equ	_&name
    endif
	endm

callm	macro	name
	call	far ptr _&name
	endm
    else
func	macro	name
name	proc	far
	endm

callm	macro	name
	call	far ptr name
	endm
    endif
endif

;;;;;;;;;;;;;;;;; COMPACT MEMORY MODEL ;;;;;;;;;;;;;;

ifdef I8086C
    ifdef MSC
begcode	macro	module
_TEXT	segment word public 'CODE'
	assume	cs:_TEXT
	endm

endcode	macro	module
_TEXT	ends
	endm
    else
begcode	macro	module
cgroup	group	code
code	segment	byte public 'code'
	assume	cs:cgroup
	endm

endcode	macro	module
code	ends
	endm
    endif

P	equ	4	; Offset of start of parameters on the stack frame
SPTR	equ	0
LPTR	equ	1
LCODE	equ	0
ESeqDS	equ	0
SSeqDS	equ	0
SIZEPTR	equ	4

    ifdef MSC
func	macro	name
_&name	proc	near
    ifndef name
name	equ	_&name
    endif
	endm

callm	macro	name
	call	near ptr _&name
	endm
    else
func	macro	name
name	proc	near
	endm

callm	macro	name
	call	near ptr name
	endm
    endif
endif

;;;;;;;;;;;;;;;; LARGE MEMORY MODEL ;;;;;;;;;;;;;;;;;;;

ifdef I8086L
    ifdef MSC
begcode	macro	module
module&_TEXT	segment	word 'CODE'
	assume	cs:module&_TEXT
	endm

endcode	macro	module
module&_TEXT	ends
	endm
    else
begcode	macro	module
module&_prog	segment	byte 'prog'
	assume	cs:module&_prog
	endm

endcode	macro	module
module&_prog	ends
	endm
    endif


P	equ	6	; Offset of start of parameters on the stack frame
SPTR	equ	0
LPTR	equ	1
LCODE	equ	1
ESeqDS	equ	0
SSeqDS	equ	0
SIZEPTR	equ	4

    ifdef MSC
func	macro	name
_&name	proc	far
    ifndef name
name	equ	_&name
    endif
	endm

callm	macro	name
	call	far ptr _&name
	endm
    else
func	macro	name
name	proc	far
	endm

callm	macro	name
	call	far ptr name
	endm
    endif
endif

;Macros to replace public, extrn, and endp for C-callable assembly routines,
; and to define labels: c_label defines labels,
; c_public replaces public, c_extrn replaces extrn, and c_endp replaces endp

    ifdef MSC

c_name	macro	name
	name equ _&name
	endm

c_label	macro	name
_&name:
	endm

c_public macro	a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    ifnb <a>			;;Check for blank argument
	public	_&a
	a equ _&a
      ifnb <b>
	c_public b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
      endif
    endif
	endm

c_extrn	macro	a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    ifnb <a>			;;Check for blank argument
	extrn	_&a:b
	a equ _&a
      ifnb <c>
	c_extrn	c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
      endif
    endif
	endm

c_endp	macro	name
_&name	ENDP
	endm

    else

c_name	macro	name
	endm

c_label	macro	name
name:
	endm

c_public macro	a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    ifnb <a>			;;Check for blank argument
	public	a
      ifnb <b>
	c_public b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
      endif
    endif
	endm

c_extrn	macro	a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    ifnb	<a>			;;Check for blank argument
	extrn	a:b
      ifnb <c>
	c_extrn	c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
      endif
    endif
	endm

c_endp	macro	name
name	endp
	endm

    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define function ctor as a static constructor

static_ctor macro	ctor
    if LCODE
XIFB	segment	word public 'DATA'
XIFB	ends
XIF	segment	word public 'DATA'
	dd	ctor
XIF	ends
XIFE	segment	word public 'DATA'
XIFE	ends
    else
XIB	segment	word public 'DATA'
XIB	ends
XI	segment	word public 'DATA'
	dw	ctor
XI	ends
XIE	segment	word public 'DATA'
XIE	ends
    endif
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define function ctor as a static destructor

static_dtor macro	dtor
    if LCODE
XCFB	segment	word public 'DATA'
XCFB	ends
XCF	segment	word public 'DATA'
	dd	dtor
XCF	ends
XCFE	segment	word public 'DATA'
XCFE	ends
    else
XCB	segment	word public 'DATA'
XCB	ends
XC	segment	word public 'DATA'
	dw	dtor
XC	ends
XCE	segment	word public 'DATA'
XCE	ends
    endif
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Other more or less useful macros

setESeqDS macro		;set ES == DS, if not already true
    ife ESeqDS
	push	DS
	pop	ES
    endif
	endm

.push	macro	list
	irp	arg,<list>
	 push	arg
	endm
	endm

.pop	macro	list
	irp	arg,<list>
	 pop	arg
	endm
	endm

; Macros to save and restore regs destroyed by a function

.save	macro	list
    if SAVESIDI
	irp	arg,<list>
	 push	arg
	endm
    endif
	endm

.restore macro	list
    if SAVESIDI
	irp	arg,<list>
	 pop	arg
	endm
    endif
	endm

; Macros to save and restore ES, but only if ESeqDS is 1.
pushES	macro
    if	ESeqDS
	push	ES
    endif
	endm

popES	macro
    if	ESeqDS
	pop	ES
    endif
	endm

clr	macro	list		;clear a register
	irp	reg,<list>
	 xor	reg,reg
	endm
	endm

tst	macro	reg
	or	reg,reg
	endm

jmps	macro	lbl
	jmp	short	lbl
	endm

.if	macro	arg1,cond,arg2,lbl
	cmp	arg1,arg2
	j&cond	lbl
	endm

;sob	macro	arg,lbl
;	ifidn	<arg>,<CX>
;	 loop	lbl
;	else
;	 dec	arg
;	 jnz	lbl
;	endif
;	endm

ifndef nobdos
bdos	macro	func
	ifnb	<func>
	 mov	AH,func
	endif
	int	21h
	endm
endif

.retf	macro	val		;force assembler to build a far return
	ifnb	<val>
	 db	0CAh
	 dw	val
	else
	 db	0CBh
	endif
	endm

; Sometimes MASM ignores my segment overrides.
segES	macro
	db	26h
	endm

; 32 bit negate
neg32	macro	reg1,reg2
	 neg	reg1
	 neg	reg2
	 sbb	reg1,0
	endm
