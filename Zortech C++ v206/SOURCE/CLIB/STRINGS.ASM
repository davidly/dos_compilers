;_ strings.asm   Mon Aug 28 1989   Modified by: Walter Bright */
;Copyright (C) 1985-1989 by Walter Bright
;All Rights Reserved
;Written by Walter Bright

include	macros.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare a string.
; Use:
;	int strcmp(s1,s2)
; Returns:
;	> 0	if s1 > s2
;	= 0	if s1 == s2
;	< 0	if s1 < s2
;

	ifdef	Astrcmp
	begcode	strcmp
	c_public	strcmp
func	strcmp
	mov	BX,SP
    if SPTR
	.save	SI
	mov	DX,DI			;save DI
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov     DI,P-2+2[BX]		;get source pointer (s2)
	mov     SI,P-2[BX]		;get destination pointer (s1)
    else
	.save	<SI,DI>
	mov	DX,DS
	les     DI,SS:P-2+4[BX]		;get source pointer (s2)
	lds	SI,SS:P-2[BX]		;get destination pointer (s1)
    endif
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb
	not	CX			;CX = string length of s2
	sub	DI,CX			;point DI back to beginning
	repe	cmpsb			;compare string
	je	L1			;strings are equal
    if 0
	jae	L2			;s1 < s2
	inc	AX			;s1 > s2
	jmps	L1

L2:	dec	AX			;AX = -1
    else
	sbb	AX,AX
	cmc
	adc	AX,0
    endif
L1:
    if SPTR
	mov	DI,DX
	.restore SI
    else
	mov	DS,DX
	.restore <DI,SI>
    endif
	ret                                        
c_endp	strcmp
	endcode	strcmp
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare a string of at most n chars (unsigned).
; Use:
;	int strncmp(s1,s2,n)
; Returns:
;	> 0	if s1 > s2
;	= 0	if s1 == s2
;	< 0	if s1 < s2
;

	ifdef	Astrncmp
	begcode	strncmp
	c_public	strncmp
func	strncmp
	push    BP                                 
	mov     BP,SP                              
	.save	<SI,DI>
    if SPTR
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov     DI,P+2[BP]		;get source pointer (s2)
	mov     SI,P[BP]		;get destination pointer (s1)
    else
	mov	BX,DS
	les     DI,P+4[BP]		;get source pointer (s2)
	lds	SI,P[BP]		;get destination pointer (s1)
    endif
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb
	not	CX			;CX = string length of s2
	sub	DI,CX			;point DI back to beginning
    if SPTR
	.if	CX b P+4[BP], L5
	mov	CX,P+4[BP]		;CX = min(CX,n)
    else
	.if	CX b P+8[BP], L5
	mov	CX,P+8[BP]		;CX = min(CX,n)
    endif
L5:	repe	cmpsb			;compare string
	je	L3			;strings are equal
    if 0
	jae	L4			;s1 < s2
	inc	AX			;s1 > s2
	jmps	L3

L4:	dec	AX			;AX = -1
    else
	sbb	AX,AX
	cmc
	adc	AX,0
    endif
L3:
    if LPTR
	mov	DS,BX
    endif
	.restore <DI,SI>
	pop     BP                                 
	ret                                        
c_endp	strncmp
	endcode	strncmp
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare an array of n bytes (unsigned).
; Use:
;	int memcmp(s1,s2,n)
; Returns:
;	> 0	if s1 > s2
;	= 0	if s1 == s2
;	< 0	if s1 < s2
;

	ifdef	Amemcmp
	begcode	memcmp
	c_public	memcmp
func	memcmp
	push    BP                                 
	mov     BP,SP                              
	.save	<SI,DI>
    if SPTR
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov	DI,P+2[BP]		;get source pointer (s2)
	mov     SI,P[BP]		;get destination pointer (s1)
    else
	mov	BX,DS
	les     DI,P+SIZEPTR[BP]	;get source pointer (s2)
	lds	SI,P[BP]		;get destination pointer (s1)
    endif
	mov	CX,P+SIZEPTR+SIZEPTR[BP]		;CX = n
	clr	AX
	repe	cmpsb			;compare string
	je	L3			;strings are equal
    if 0
	jae	L4			;s1 < s2
	inc	AX			;s1 > s2
	jmps	L3

L4:	dec	AX			;AX = -1
    else
	sbb	AX,AX
	cmc
	adc	AX,0
    endif
L3:
    if LPTR
	mov	DS,BX
    endif
	.restore <DI,SI>
	pop     BP                                 
	ret                                        
c_endp	memcmp
	endcode	memcmp
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculate length of string and return it.
;	int strlen(s)

	ifdef	Astrlen
	begcode	strlen
	c_public	strlen
func	strlen
	mov	BX,SP
	mov	DX,DI			;save DI
    if SPTR
	mov	AX,DS
	mov	ES,AX
      if SSeqDS
	mov     DI,P-2[BX]		;DI = s
      else
	mov     DI,SS:P-2[BX]		;DI = s
      endif
    else
	les	DI,SS:P-2[BX]
    endif
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb
	mov	AX,CX
	not	AX			;AX = string length
	dec	AX
	mov	DI,DX
	ret                                        
c_endp	strlen
	endcode	strlen
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cat s2 to s1 till a zero byte.
; Use:
;	char *strcat(s1,s2)
; Returns:
;	s1
;
	ifdef	Astrcat
	begcode	strcat
	c_public	strcat
func	strcat
	push    BP                                 
	mov     BP,SP                              
	.save	<SI,DI>
    if SPTR
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov     SI,P+2[BP]		;get source pointer
	mov     DI,P[BP]		;get destination pointer
    else
	push	DS
	les	DI,P[BP]		;get destination pointer (s1)
    endif
	mov	BX,DI			;save it
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb			;find end of s1
	dec	DI			;DI -> EOS of s1
	mov	DX,DI
    if SPTR
	mov	DI,SI			;DI -> s2
    else
	les	DI,P+4[BP]		;ES:DI = s2
    endif
	mov	CX,-1
	repne	scasb
	not	CX			;CX = strlen(s2) + 1 (for EOS)
	mov	DI,DX			;DI -> end of s1
    if SPTR
	rep	movsb			;transfer bytes (including EOS)
	mov	AX,BX			;return pointer to s1
    else
	mov	ES,P+2[BP]		;ES:DI -> end of s1
	lds     SI,P+4[BP]		;get source pointer (s2)
	rep	movsb			;transfer bytes (including EOS)
	mov	AX,BX
	mov	DX,ES			;DX,AX points to s1
	pop	DS
    endif
	.restore <DI,SI>
	pop	BP
	ret                                        
c_endp	strcat
	endcode	strcat
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cat s2 to s1 till a zero byte or n bytes are copied.
; Use:
;	char *strncat(char *s1,char *s2,unsigned n)
; Returns:
;	s1
;
	ifdef	Astrncat
	begcode	strncat
	c_public	strncat
func	strncat
	push    BP                                 
	mov     BP,SP                              
	.save	<SI,DI>
    if SPTR
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov     SI,P+2[BP]		;get source pointer (s2)
	mov     DI,P[BP]		;get destination pointer (s1)
    else
	push	DS
	les	DI,P[BP]		;get destination pointer (s1)
	mov	BX,DI			;set up offset of return value (s1)
    endif
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb			;find end of s1
	dec	DI			;point at terminating 0
	mov	DX,DI			;save
    if SPTR
	mov	DI,SI			;DI -> s2
    else
	les	DI,P+SIZEPTR[BP]	;ES:DI -> s2
    endif
	mov	CX,-1
	repne	scasb
	not	CX
	dec	CX			;CX = strlen(s2)
	.if	CX b P+SIZEPTR+SIZEPTR[BP], L6
	mov	CX,P+SIZEPTR+SIZEPTR[BP]	;CX = min(CX,n)
L6:	mov	DI,DX			;DI -> end of s1
    if LPTR
	mov	ES,P+2[BP]		;ES = segment of s1
	lds	SI,P+SIZEPTR[BP]	;DS:SI -> s2
    endif
	rep	movsb			;transfer bytes
	stosb				;terminate with a 0
    if SPTR
	mov	AX,P[BP]		;return pointer to s1
    else
	mov	AX,BX
	mov	DX,ES			;DX,AX = s1
	pop	DS
    endif
	.restore <DI,SI>
	pop	BP
	ret                                        
c_endp	strncat
	endcode	strncat
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy s2 to s1 till a zero byte.
; Use:
;	char *strcpy(s1,s2)
;
	ifdef	Astrcpy
	begcode	strcpy
	c_public	strcpy
func	strcpy
    if SPTR
	mov     BX,SP                              
	.save	SI
	mov	DX,DI
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov     DI,P-2+2[BX]		;get source pointer (s2)
	mov	SI,DI			;save it
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb			;find end of s2
	not	CX			;CX = strlen(s2) + 1 (for EOS)
	mov	DI,P-2[BX]		;DI -> s1
	mov	AX,DI			;return value
	rep	movsb			;transfer bytes (including EOS)
	mov	DI,DX
	.restore SI
    else
	mov	BX,SP                              
	.save	<SI,DI>
	les	DI,SS:P-2+4[BX]		;ES:DI = s2
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb			;find end of s2
	not	CX			;CX = strlen(s2) + 1 (for EOS)
	mov	DX,DS
	les	DI,SS:P-2[BX]
	lds	SI,SS:P-2+4[BX]
	mov	AX,DI			;return value is s1
	rep	movsb
	mov	DS,DX
	.restore <DI,SI>
	mov	DX,ES
    endif
	ret                                        
c_endp	strcpy
	endcode	strcpy
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy exactly n chars from s2 to s1, padding with nulls if necessary.
; Use:
;	char *strncpy(s1,s2,n)
;
	ifdef	Astrncpy
	begcode	strncpy
	c_public	strncpy
func	strncpy
	push    BP                                 
	mov     BP,SP                              
	.save	<SI,DI>
    if SPTR
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov     DI,P+2[BP]		;get source pointer
	mov	BX,DI			;save it
    else
	les	DI,P+4[BP]
    endif
	clr	AX			;scan for 0
	mov	CX,-1			;largest possible string
	repne	scasb			;find end of s2
	not	CX			;CX = strlen(s2) + 1 (for EOS)
    if SPTR
	mov	DX,P+4[BP]		;DX = n
    else
	mov	DX,P+8[BP]
    endif
	.if	DX ae CX, L7		;if n >= strlen(s2) + 1
	mov	CX,DX			;CX = min(CX,n)
L7:	sub	DX,CX			;DX = # of nulls to pad
    if SPTR
	mov	DI,P[BP]		;DI -> s1
	mov	SI,BX			;SI -> s2
    else
	push	DS
	les	DI,P[BP]
	mov	BX,DI			;for return value
	lds	SI,P+4[BP]
    endif
	rep	movsb			;transfer bytes (including EOS)
	mov	CX,DX			;# of nulls to pad
	clr	AL
	rep	stosb
    if SPTR
	mov	AX,P[BP]		;return value
    else
	mov	AX,BX
	mov	DX,ES
	pop	DS
    endif
	.restore <DI,SI>
	pop	BP
	ret                                        
c_endp	strncpy
	endcode	strncpy
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set n bytes in s to c.
;	char *memset(char *p,int c,int n)
; Returns:
;	p

	ifdef	Amemset
	begcode	memset
	c_public	memset
func	memset
	push	BP
	mov	BP,SP
	.save	<DI>
    if SPTR
      ife ESeqDS
	mov	DX,DS
	mov	ES,DX
      endif
	mov	DI,P[BP]	;p
    else
	les	DI,P[BP]	;p
	mov	DX,ES		;return original value of p in DX,AX
    endif
	mov	CX,P+SIZEPTR+2[BP]	;n
	jcxz	M1
	mov	AL,P+SIZEPTR[BP]	;c
	rep	stosb
M1:	mov	AX,P[BP]
	.restore <DI>
	pop	BP
	ret
c_endp	memset
	endcode	memset
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy n bytes from p2 to p1.
;	void *memcpy(void *p1,void *p2,n)
; Returns:
;	p1

    ifdef Amemcpy
	c_public	memcpy
	begcode	memcpy

	c_public	memmove		;alternate entry point
func	memmove
c_endp	memmove

func	memcpy
	mov	BX,SP
    if SPTR
	mov	CX,P-2+SIZEPTR+SIZEPTR[BX]	;CX = n
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov	DX,SI			;save SI
	mov	SI,P-2+SIZEPTR[BX]	;p2
	mov	AX,P-2[BX]		;p1
    else
	mov	CX,SS:P-2+SIZEPTR+SIZEPTR[BX]	;CX = n
	.save	SI
	mov	DX,DS
	lds	SI,SS:P-2+SIZEPTR[BX]	;DS:SI = p2
	les	AX,SS:P-2[BX]		;ES:DI = p1
    endif
	mov	BX,DI			;save DI
	mov	DI,AX			;AX = original offset value of p1
	.if	SI b DI, M1		;if reverse copy is necessary
	shr	CX,1
	jz	M2			;if n is 0 or 1
	rep	movsw
M2:	jnc	M5			;if n is even
	movsb
M5:
    if SPTR
	mov	SI,DX
    else
	mov	DS,DX
	mov	DX,ES			;DX:AX = original value of p1
	.restore SI
    endif
	mov	DI,BX
	ret

M1:	add	SI,CX
	dec	SI
	add	DI,CX
	dec	DI
	std				;reverse direction of copy
	shr	CX,1
	jnc	M6
	movsb
M6:	jcxz	M7
	dec	SI
	dec	DI
	rep	movsw
M7:	cld
	jmps	M5

c_endp	memcpy
	endcode	memcpy
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	void movedata(unsigned srcseg,unsigned srcoff,unsigned destseg,
;		unsigned destoff,size_t numbytes);

    ifdef Amovedata
	c_public	movedata
	begcode		movedata
func	movedata
	push	BP
	mov	BP,SP
	.push	<SI,DI,DS>
	mov	DS,P[BP]
	mov	SI,P+2[BP]
	mov	ES,P+4[BP]
	mov	DI,P+6[BP]
	mov	CX,P+8[BP]	;get numbytes
	shr	CX,1		;convert to word count
	jz	L3		;only move 1 or 0 bytes
	repz	movsw
L3:	jnc	L2		;if not odd byte count
	movsb			;move odd byte
L2:	.pop	<DS,DI,SI>
L1:	pop	BP
	ret
c_endp	movedata
	endcode	movedata
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return pointer to first occurrence of char c in string s.
;	char *index(s,c)
;	char *s,c;

    ifdef	Aindex
	begcode	strchr
	c_public index,strchr

func	strchr
c_endp	strchr

func	index
	push    BP                                 
	mov     BP,SP                              
	.save	<DI>
    if SPTR
      ife ESeqDS
	mov	AX,DS
	mov	ES,AX
      endif
	mov	DI,P[BP]		;DI = s
    else
	les	DI,P[BP]		;ES:DI = s
    endif
	clr	AX
	mov	CX,-1
	repne	scasb
	not	CX			;CX = length of s (including NULL)
	sub	DI,CX			;DI = s
    if SPTR
	mov	AL,P+2[BP]		;AL = c
    else
	mov	AL,P+4[BP]		;AL = c
    endif
	repne	scasb			;scan for c
	mov	AX,0			;assume we didn't find it
    if SPTR
	jnz	L8			;didn't find it
	mov	AX,DI			;yes, found it
	dec	AX
    else
	cwd
	jnz	L8
	mov	DX,ES
	mov	AX,DI
	dec	AX
    endif
L8:	.restore <DI>
	pop	BP
	ret     
c_endp	index                                   
	endcode	strchr
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare strings just like strcmp(), except that case is ignored.

    ifdef Astrcmpl
	begcode	strcmpl
	c_public	strcmpl
func	strcmpl
	push	BP
	mov	BP,SP
	mov	DX,SI
    if SPTR
	mov	SI,P[BP]
	mov	BX,P+SIZEPTR[BP]
    else
	push	DS
	lds	SI,P[BP]		;DS:SI -> p1
	les	BX,P+SIZEPTR[BP]	;ES:BX -> p2
    endif
L1:	lodsb				;AL = *p1++
    if SPTR
	mov	CL,[BX]
    else
	mov	CL,ES:[BX]
    endif
	inc	BX			;CL = *p2++
	.if	AL ne CL, L2		;strings are different at this char
	tst	AL			;end of string?
	jnz	L1			;no
	jmps	L3

L2:	;Perhaps when converted to lower case, they will be the same
	.if	AL b 'A', L3
	.if	AL a 'Z', L4
	add	AL,'a' - 'A'		;convert AL to lower case
L4:	.if	CL b 'A', L3
	.if	CL a 'Z', L5
	add	CL,'a' - 'A'		;convert CL to lower case
L5:	.if	AL e CL, L1		;same now, so continue looping

L3:	clr	AH
	mov	CH,AH
	sub	AX,CX
    if LPTR
	pop	DS
    endif
	mov	SI,DX
	pop	BP
	ret
c_endp	strcmpl
	endcode	strcmpl
    endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare strings just like memcmp(), except that case is ignored.

    ifdef Amemicmp
	begcode	memicmp
	c_public	memicmp
func	memicmp
	push	BP
	mov	BP,SP
	.save	SI
    if SPTR
	mov	SI,P[BP]
	mov	BX,P+SIZEPTR[BP]
    else
	push	DS
	lds	SI,P[BP]		;DS:SI -> p1
	les	BX,P+SIZEPTR[BP]	;ES:BX -> p2
    endif
	mov	CX,P+SIZEPTR+SIZEPTR[BP] ;CX = numbytes
	jcxz	match
	mov	AH,'A'
	mov	DH,'Z'
L1:	lodsb				;AL = *p1++
    if SPTR
	mov	DL,[BX]
    else
	mov	DL,ES:[BX]
    endif
	inc	BX			;DL = *p2++
	.if	AL ne DL, L2		;strings are different at this char
	loop	L1			;try next char
	jmps	match

L2:	;Perhaps when converted to lower case, they will be the same
	.if	AL b AH, nomatch
	.if	AL a DH, L4
	add	AL,'a' - 'A'		;convert AL to lower case
L4:	.if	DL b AH, nomatch
	.if	DL a DH, L5
	add	DL,'a' - 'A'		;convert DL to lower case
L5:	.if	AL ne DL, nomatch	;different, we're done
	loop	L1
match:	mov	AX,CX			;return 0 in AX
    if LPTR
	pop	DS
    endif
	.restore SI
	pop	BP
	ret

nomatch:
	clr	AH
	mov	DH,AH
	sub	AX,DX
    if LPTR
	pop	DS
    endif
	.restore SI
	pop	BP
	ret
c_endp	memicmp
	endcode	memicmp
    endif

	end


