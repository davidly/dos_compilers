include macros.asm

        begcode bcdlow
c_public  bcd_add, bcd_sub, bcd_inc, bcd_dec
c_public  bcd_mul, bcd_mul10, bcd_div10
c_public  memrcmp, memtest
;
;  add(p1,p2);
;
;  p1 and p2 point to n byte areas - result is put in p1 area
;  p2 area not affected
;  returns nonzero if overflowed
;
func    bcd_add
        push    bp
        mov     bp,sp
        push    ds
        push    es
        push    si
        push    di
if LPTR
        mov     cx,p[bp]                ;get bcd length
        lds     si,p+2+SIZEPTR[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     si,p+2+SIZEPTR[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
        clc
bcdadd1:
        mov     al,ds:[si]
        adc     al,es:[di]
        daa
        stosb
        inc     si
        loop    bcdadd1
        rcl     ax,1
        and     ax,1
        pop     di
        pop     si
        pop     es
        pop     ds
        pop     bp
        ret
c_endp  bcd_add
;
;  sub(p1,p2);
;
;  p1 and p2 point to eight byte areas - result is put in p1 area
;  p2 area not affected
;  returns nonzero if overflowed
;
func    bcd_sub
        push    bp
        mov     bp,sp
        push    ds
        push    es
        push    si
        push    di
if LPTR
        mov     cx,p[bp]                ;get bcd length
        lds     si,p+2+SIZEPTR[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     si,p+2+SIZEPTR[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
        clc
bcdsub1:
        mov     al,es:[di]
        sbb     al,ds:[si]
        das
        stosb
        inc     si
        loop    bcdsub1
        rcl     ax,1
        and     ax,1
        pop     di
        pop     si
        pop     es
        pop     ds
        pop     bp
        ret
c_endp  bcd_sub
;
;  inc(a)    Just up it by one quickly as possible
;
func    bcd_inc
        push    bp
        mov     bp,sp
        push    es
        push    di
if LPTR
        mov     cx,p[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
bcdinc1:
        push    cx
        mov     al,es:[di]
        and     al,0fh
        cmp     al,9
        jnc     bcdinc2
        pop     cx
        inc     byte ptr es:[di]
        sub     al,al
        jmp     short bcdincex
bcdinc2:
        mov     al,es:[di]
        mov     cl,4
        shr     al,cl
        cmp     al,9
        jnc     bcdinc3
        inc     al
        shl     al,cl
        pop     cx
        stosb
        sub     al,al
        jmp     short bcdincex
bcdinc3:
        sub     al,al
        stosb
        pop     cx
        loop    bcdinc1
        mov     ax,0ffh                 ;signal overflow
bcdincex:
        pop     di
        pop     es
        pop     bp
        ret
c_endp  bcd_inc
;
;  dec(a)    Just knock it down by one quickly as possible
;
func    bcd_dec
        push    bp
        mov     bp,sp
        push    es
        push    di
if LPTR
        mov     cx,p[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
bcddec1:
        push    cx
        mov     al,es:[di]
        and     al,0fh
        or      al,al
        jz      bcddec2
        pop     cx
        dec     byte ptr es:[di]
        sub     al,al
        jmp     short bcddecex
bcddec2:
        mov     al,es:[di]
        mov     cl,4
        shr     al,cl
        or      al,al
        jz      bcddec3
        dec     al
        shl     al,cl
        add     al,9
        pop     cx
        stosb
        sub     al,al
        jmp     short bcddecex
bcddec3:
        mov     al,99h
        stosb
        pop     cx
        loop    bcdinc1
        mov     ax,0ffh                 ;signal underflow
bcddecex:
        pop     di
        pop     es
        pop     bp
        ret
c_endp  bcd_dec
;
;  mul(p1,d);
;
;  p1 points to eight byte area - result is put in p1
;  d is a digit to multiply by
;  returns nonzero if overflowed
;
func    bcd_mul
        push    bp
        mov     bp,sp
        push    es
        push    di
if LPTR
        mov     cx,p[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
        mov     bl,p+2+SIZEPTR[bp]
        sub     bh,bh
bcdmul1:
        push    cx              ;preserve counter
        mov     al,es:[di]      ;get first digit
        and     al,0fh
        mul     bl              ;multiply
        add     al,bh           ;add any carry
        aam                     ;split into decimal digits
        mov     bh,ah
        push    ax              ;save result
        mov     al,es:[di]
        mov     cl,4
        shr     al,cl            ;get second digit
        mul     bl              ;multiply
        add     al,bh           ;add any carry
        aam                     ;split into decimal digits
        mov     bh,ah
        shl     al,cl           ;move into high nibble
        pop     cx              ;recover first digit
        add     al,cl           ;and put in low nibble
        stosb                   ;store away
        pop     cx
        loop    bcdmul1         ;go for next
        sub     ah,ah
        mov     al,bh
        pop     di
        pop     es
        pop     bp
        ret
c_endp  bcd_mul
;
;
;  mul10(p1);
;
;  p1 points to eight byte area - result is put in p1
;  multiply by 10
;  returns nonzero if overflowed
;
func    bcd_mul10
        push    bp
        mov     bp,sp
        push    es
        push    di
if LPTR
        les     cx,p[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
        sub     bl,bl
mul10:
        push    cx              ;preserve counter
        mov     al,es:[di]      ;get first digit
        mov     dl,al
        mov     cx,4
        shr     dl,cl
        shl     al,cl
        add     al,bl
        mov     bl,dl
        stosb                   ;store away
        pop     cx
        loop    mul10         ;go for next
        sub     ah,ah
        mov     al,bl
        pop     di
        pop     es
        pop     bp
        ret
c_endp  bcd_mul10
;
;  div10(p1);
;
;  p1 points to eight byte area - result is put in p1
;  divide by 10
;  no return value
;
func    bcd_div10
        push    bp
        mov     bp,sp
        push    es
        push    di
if LPTR
        les     cx,p[bp]
        les     di,p+2[bp]
else
        mov     cx,p[bp]
        mov     di,p+2[bp]
        push    ds
        pop     es
endif
        add     di,cx
        dec     di              ;point at most significant
        sub     bl,bl
        std                     ;direction backwards
div10:
        push    cx              ;preserve counter
        mov     al,es:[di]      ;get most significant digits
        mov     dl,al
        mov     cx,4
        shl     dl,cl
        shr     al,cl
        add     al,bl
        mov     bl,dl
        stosb                   ;store away
        pop     cx
        loop    div10           ;go for next
        cld
        pop     di
        pop     es
        pop     bp
        ret
c_endp  bcd_div10
;
;       int memrcmp(s1,s2,n)
; Returns:
;       > 0     if s1 > s2
;       = 0     if s1 == s2
;       < 0     if s1 < s2
;
;
func    memrcmp
        push    BP                                 
        mov     BP,SP
        push    SI
        push    DI                            
    if SPTR
        mov     SI,P+2[BP]              ;get source pointer (s2)
        mov     DI,P[BP]                ;get destination pointer (s1)
    else
        push    DS
        lds     SI,p+SIZEPTR[BP]        ;get source pointer (s2)
        les     DI,p[BP]                ;get destination pointer (s1)
    endif
        mov     CX,p+SIZEPTR+SIZEPTR[BP]        	;CX = n
        add     SI,CX
        add     DI,CX
        dec     SI
        dec     DI                      ;point at last byte of each
        clr     AX
        std
        repe    cmpsb                   ;compare string
        je      L3                      ;strings are equal
        jae     L4                      ;s1 < s2
        inc     AX                      ;s1 > s2
        jmp     short L3

L4:     dec     AX                      ;AX = -1
L3:
        cld                             ;direction flag back in standard state
    if LPTR
        pop     DS
    endif
        pop     DI
        pop     SI
        pop     BP                                 
        ret                                        
c_endp  memrcmp
;
;
;       int memtest(s,n)
; Returns:
;       non-zero if all s not zeros
;
;
func    memtest
        push    bp
        mov     bp,sp
        push    di
    if SPTR
        push    ds
        pop     es
        mov     di,p[BP]                ;get destination pointer (s)
    else
        les     di,p[BP]                ;get destination pointer (s)
    endif
        mov     cx,p+SIZEPTR[BP]        ;CX = n
        sub     al,al
        repe    scasb                   ;compare each byte with 0
        jnz     X1
        sub     ax,ax
        jmp     short X2
X1:     mov     ax,0ffffh
X2:     pop     di
        pop     bp                                 
        ret                                        
c_endp  memtest
;
        endcode bcdlow
        end
