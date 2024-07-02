;(**************************************************************************)
;(*                                                                        *)
;(*  MODULA-2    Library                                                   *)
;(*                                                                        *)
;(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                   *)
;(*                                                                        *)
;(*  Module  :                            				   *)
;(*    Longs, imported when LONGINT are used          		           *)
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

          name Longs

; list of exported procedures

; LONGSETS
          public  pushLSet__Longs
          public  areSetsEQ__Longs
          public  superSet__Longs
          public  subSet__Longs
          public  union__Longs
          public  intersection__Longs
          public  complement__Longs      
          public  unionCompl__Longs

; LONGINTEGER
          public  LMult__Longs
          public  LMultU__Longs
          public  LDiv__Longs

;INITIALIZATION                 
          public  $INIT__Longs

          PUBLIC  KEY__05feb87_1233_OF_Longs
          PUBLIC  $OK__05feb87_1233_OF_Longs

KEY__05feb87_1233_OF_Longs EQU 0

MODULE_TABLE_DATA SEGMENT WORD PUBLIC 'FAR_DATA'
$OK__05feb87_1233_OF_Longs DW 0AE45H,2F1H,0
MODULE_TABLE_DATA ENDS

Longs_TEXT      SEGMENT BYTE PUBLIC 'CODE'      ; Program Code Segment 
                assume cs:Longs_TEXT
                

pushLSet__Longs  proc far
;***************************************************************************
;* The procedure pushes a longset on the stack                             *
;*                                                                         *
;* parameters IN : address of set         :DS:SI                           *
;*               : length of set in bytes : CX                             *
;*                                                                         *
;*           OUT : none                                                    *
;***************************************************************************
   
                pop     ax                      ;save return address
                pop     bx                      
                inc     cx                      ;round to next greater
                and     cx,     0FEH            ;  even number
                sub     sp,     cx              ;allocate space on stack
                push    bx                      ;push return address on
                push    ax                      ;  top of stack
                mov     ax,     ss              ;load destination pointer
                mov     es,     ax
                mov     di,     sp
                add     di,     4
                mov     ax,     cx              ;save number of bytes
                
                sar     cx,     1               ;#bytes -> #words
                cld                             ;addresses are incremented
                rep     movsw
                
                sub     si,     ax              ;restore pointer
                
                ret
pushLSet__Longs  endp

areSetsEQ__Longs proc far
;***************************************************************************
;* The procedure compares two sets on equality                             *
;*                                                                         *
;* parameters IN : address of set1        : DS:SI                          *
;*                 address of set2        : ES:DI                          *
;*               : length of set in bytes : CX                             *
;*                                                                         *
;*           OUT : result                 : AX (0=NOT EQUAL 1=EQUAL)       *
;***************************************************************************
                sar     cx,     1               ;next smaller # of words
                cld                             ;incremental compare
                repe    cmpsw
                jne     not_EQ
                test    ax,     1               ;test if odd # of bytes
                je      _EQ                     ;even # -> only cmpsw
                cmpsb                           ;compare last byte
                jne     not_EQ
_EQ:            mov     ax,     1
                jmp     done_eq
not_EQ:         xor     ax,     ax
done_eq:        ret

areSetsEQ__Longs endp

superSet__Longs  proc far
;***************************************************************************
;* The procedure  evaluates if A is super set of B (A>=B)                  *
;* i.e all elements of B are included in A                                 *
;* parameters  IN : set A : DS:SI                                          *
;*                  set B : ES:DI                                          *
;* parameters OUT : result is passed in AX (0 = FALSE  1 = TRUE)           *
;***************************************************************************

                push    ax                      ;save odd/even-flag
                sar     cx,     1               ;next smaller # of words
                cld
load1:          lodsw                           ;load sourceword and INC SI
                not     ax
                and     ax,     es:[di]         ;if result<> 0 -> not incl.
                jnz     _pop
                inc     di                      ;next destination word
                inc     di                                      
                loop    load1
                
                pop     ax                      ;restore odd/even-flag
                test    ax,     1               ;test if odd # of bytes
                jz      incl                    ;even # -> comp completed
                lodsb                           ;load last byte
                not     al
                and     al,     es:[di]
                jnz     not_incl
incl:           mov     ax,     1
                jmp     done_incl
_pop:           pop     ax                      ;remove odd/even 
                                                ;  flag from stack
not_incl:       xor     ax,     ax
done_incl:      ret
superSet__Longs  endp                            
                                                

subSet__Longs    proc far

;***************************************************************************
;* evaluates if A is subSet of B (A>=B)                                    *
;* i.e all elements of A are included in B                                 *
;* parameters  IN : set A : ES:DI                                          *
;*                  set B : DS:SI                                          *
;* parameters OUT : result is passed in AX (0 = FALSE  1 = TRUE)           *
;***************************************************************************


                push    ax                      ;save odd/even-flag
                sar     cx,     1               ;next smaller # of words
                cld
load6:          lodsw                           ;load sourceword and INC SI
                not     ax
                and     ax,     es:[di]         ;if result<> 0 -> not incl.
                jnz     _pop
                inc     di                      ;next destination word
                inc     di                                      
                loop    load6
                
                pop     ax                      ;restore odd/even-flag
                test    ax,     1               ;test if odd # of bytes
                jz      incl2                   ;even # -> comp completed
                lodsb                           ;load last byte
                not     al
                and     al,     es:[di]
                jnz     not_incl2
incl2:          mov     ax,     1
                jmp     done_incl2
pop2:           pop     ax                      ;remove odd/even 
                                                ;  flag from stack
not_incl2:      xor     ax,     ax
done_incl2:     ret
subSet__Longs    endp                            
 
union__Longs     proc far
;***************************************************************************
;* The procedure forms the union of 2 sets  B := A+B                       *
;* parameters  IN : set A : ES:DI                                          *
;*                  set B : DS:SI                                          *
;*                  length in bytes : CX                                   *            
;*                                                                         *
;* parameters OUT : set B contains the result                              *
;***************************************************************************

                push    ax                      ;saving of odd/even flag
                sar     cx,     1               ;next smaller # of words
                cld                             
load2:          lodsw                           ;load source-op in AX
        
                or      es:[di],        ax
                inc     di                      ;destination pointer to
                inc     di                      ;  next word
                loop    load2
                
                pop     ax
                test    ax,     1               ;check if odd # of bytes
                jz      union_done
                lodsb                           ;load last byte
                or      es:[di],        al
union_done:     ret             
union__Longs     endp

intersection__Longs  proc far
;***************************************************************************
;* The procedure forms the intersection of 2 sets  B := A*B                *
;* parameters  IN : set A : ES:DI                                          *
;*                  set B : DS:SI                                          *
;*                  length in bytes : CX                                   *            
;*                                                                         *
;* parameters OUT : set B contains the result                              *
;***************************************************************************
                
                push    ax                      ;saving of odd/even flag
                sar     cx,     1               ;next smaller # of words
                cld                             
load3:          lodsw                           ;load source-op in AX
        
                and     es:[di],        ax
                inc     di                      ;destination pointer to
                inc     di                      ;  next word
                loop    load3
                
                pop     ax
                test    ax,     1               ;check if odd # of bytes
                jz      intersec_done
                lodsb                           ;load last byte
                and     es:[di],        al
intersec_done:  ret
        
intersection__Longs  endp

complement__Longs  proc far
;***************************************************************************
;* The procedure forms the difference of 2 sets  B := A-B                  *
;* parameters  IN : set A : ES:DI                                          *
;*                  set B : DS:SI                                          *
;*                  length in bytes : CX                                   *            
;*                                                                         *
;* parameters OUT : set B contains the result                              *
;***************************************************************************
                push    ax                      ;saving of odd/even flag
                sar     cx,     1               ;next smaller # of words
                cld                             
load4:          lodsw                           ;load source-op in AX
                not     ax                      ;c := (a) and (not (b))
                and     es:[di],        ax
                inc     di                      ;destination pointer to
                inc     di                      ;  next word
                loop    load4
                
                pop     ax
                test    ax,     1               ;check if odd # of bytes
                jz      compl_done
                lodsb                           ;load last byte
                not     al
                and     es:[di],        al
compl_done:     ret
complement__Longs  endp            

unionCompl__Longs  proc far
;***************************************************************************
;* The procedure forms the symmetric difference of 2 sets  B := A-B        *
;* parameters  IN : set A : ES:DI                                          *
;*                  set B : DS:SI                                          *
;*                  length in bytes : CX                                   *            
;*                                                                         *
;* parameters OUT : set B contains the result                              *
;***************************************************************************
                push    ax                      ;saving of odd/even flag
                sar     cx,     1               ;next smaller # of words
                cld                             
load5:          lodsw                           ;load source-op in AX
        
                xor     es:[di],        ax
                inc     di                      ;destination pointer to
                inc     di                      ;  next word
                loop    load5
                
                pop     ax
                test    ax,     1
                              ;check if odd # of bytes
                jz      uni_Compl_done
                lodsb                           ;load last byte
                xor     es:[di],        al
uni_Compl_done: ret
unionCompl__Longs  endp

LMult__Longs     proc far
;***************************************************************************
; multiplication of 2 32bit signed numbers
;
; high part of multiplicant [bp+12]
; low part  of multiplicant [bp+10]   
; high part of multiplier   [bp+8]
; low  part of multiplier   [bp+6]
;
; dx and cx used ---> they will be saved by compiler if needed
; product returned in bx,ax (high to low order)
;***************************************************************************
;
                push    bp
                mov     bp, sp
                
                xor     cx, cx                  ;negflag (cx) = 0
                cmp     word ptr [bp+12], 0     ;
                jns     not_minus               ;is 1st operand neg?
                                        
                neg     word ptr [bp+12]        ;generating of 2s complement
                neg     word ptr [bp+10]        ;
                sbb     word ptr [bp+12],0      ;
                not     cx                      ;
                
not_minus:      cmp     word ptr [bp+8], 0      ;is 2nd operand neg?
                jns     go_mul
                
                neg     word ptr [bp+8]         ;generating of 2s complement
                neg     word ptr [bp+6]         ;
                sbb     word ptr [bp+8],0       ;
		not	cx                      ;
		
;performing of the unsigned multiplication
go_mul:         cmp     word ptr [bp+12], 0     ;if hi1 = 0 then
                jne     hi1diff0                ;  
                
                cmp     word ptr [bp+8], 0      ;if hi2 = 0 then
                jne     hi2diff0
                
                                                ;here hi1=hi2=0
                mov     ax, word ptr [bp+6]     ;ax      := lo2
                mul     word ptr [bp+10]        ;(dx,ax) := lo1 * lo2
                jmp     mult_done               
                                                ;here hi1=0 & hi2#0
hi2diff0:       mov     ax, word ptr [bp+10]    ;ax      := lo1
                mul     word ptr [bp+6]         ;(dx,ax) := lo1 * lo2
                push    dx                      ;
                push    ax                      ;
                
                mov     ax, word ptr [bp+10]    ;ax      := lo1
                mul     word ptr [bp+8]         ;(dx,ax) := lo1 * hi2
                jb      mult_ovflw              ;if dx <> 0 then ovflw
                
                pop     bx                      ;bx := prev ax
                pop     dx                      ;dx := prev dx
                add     dx, ax
                xchg    ax, bx
                jb      mult_ovflw
                jmp     mult_done
                
                                                ;here h1#0
hi1diff0:       cmp     word ptr [bp+8], 0      ;if hi2=0 then
                jne     mult_ovflw
                
                mov     ax, word ptr [bp+10]    ;ax      := lo1
                mul     word ptr [bp+6]         ;(dx,ax) := lo1 * lo2
                push    dx                      ;
                push    ax                      ;
                mov     ax, word ptr [bp+6]     ;ax      := lo2
                mul     word ptr [bp+12]        ;(dx,ax) := hi1 * lo2
                jb      mult_ovflw              ;if dx <> 0 then ovflw
                
                pop     bx
                pop     dx
                add     dx, ax
                xchg    ax, bx
                jb      mult_ovflw
                
;adjusting of the sign of the result
mult_done:      cmp	dx, 0
                js      verify_min
                cmp     cx, 0
                jne     change_sign
                clc
                jmp     mult_ok
        
change_sign:    neg     dx
                neg     ax
                sbb     dx, 0
                clc
                
mult_ok:        xchg    bx, dx
                mov     sp, bp
                pop     bp
                ret     8

verify_min:     cmp     cx, 0
                jz      mult_ovflw
                cmp     dx, 8000h
                jne     mult_ovflw
                cmp     ax, 0
                clc
                jz      mult_ok
                
mult_ovflw:     stc
                jmp     mult_ok         

LMult__Longs    endp

LMultU__Longs     proc far

;***************************************************************************
; multiplication of 2 32bits unsigned numbers + no overflow tests
;
; high part of multiplicant [bp+12]
; low part  of multiplicant [bp+10]   
; high part of multiplier   [bp+8]
; low  part of multiplier   [bp+6]
;
; dx and cx used ---> they will be saved by compiler if needed
; product returned in bx,ax (high to low order)
;***************************************************************************
;
                push    bp
                mov     bp, sp
                
                cmp     word ptr [bp+12], 0     ;if hi1 = 0 then
                jne     hi1dif0                 ;  
                
                cmp     word ptr [bp+8], 0      ;if hi2 = 0 then
                jne     hi2dif0                 ;
                
                                                ;here hi1=hi2=0
                mov     ax, word ptr [bp+6]     ;ax      := lo2
                mul     word ptr [bp+10]        ;(dx,ax) := lo1 * lo2
                xchg    bx, dx
                jmp     lmult_done               
                                                ;here hi1=0 & hi2#0
hi2dif0:        mov     ax, word ptr [bp+10]    ;ax      := lo1
                mul     word ptr [bp+6]         ;(dx,ax) := lo1 * lo2
                mov     cx, ax
                mov     bx, dx

                mov     ax, word ptr [bp+10]    ;ax      := lo1
                mul     word ptr [bp+8]         ;(dx,ax) := lo1 * hi2
                
                add     bx, ax
                xchg    ax, cx

                jmp     lmult_done
                
                                                ;here hi1#0
hi1dif0:        cmp     word ptr [bp+8], 0      ;if hi2#0 then
                jne     hi12dif0

                                                ;here hi1#0 & hi2=0
                mov     ax, word ptr [bp+10]    ;ax      := lo1
                mul     word ptr [bp+6]         ;(dx,ax) := lo1 * lo2
                mov     cx, ax
                mov     bx, dx

                mov     ax, word ptr [bp+6]     ;ax      := lo2
                mul     word ptr [bp+12]        ;(dx,ax) := hi1 * lo2
                
                add     bx, ax
                xchg    ax, cx
                jmp     lmult_done

hi12dif0:                                       ;here hi1#0 & hi2#0
                mov     ax, word ptr [bp+8]     ;ax      := hi2
                mul     word ptr [bp+10]        ;(dx,ax) := hi2 * lo1
                mov     bx, ax

                mov     ax, word ptr [bp+6]     ;ax      := lo2
                mul     word ptr [bp+12]        ;(dx,ax) := lo2 * hi1
                add     bx, ax

                mov     ax, word ptr [bp+6]     ;ax      := lo2
                mul     word ptr [bp+10]        ;(dx,ax) := lo2 * lo1
                add     bx, dx

lmult_done:     mov     sp, bp
                pop     bp
                ret     8


LMultU__Longs    endp


LDiv__Longs      proc far
;***************************************************************************
;PARAMETERS IN:
;dividend_hi : on top of stack     [bp+12]
;dividend_lo : next word on stack  [bp+10]
;divisor_hi  : next word on stack  [bp+08]
;divisor_lo  : next word on stack  [bp+06]
;
;PARAMETERS OUT:
;quotient low  : BX
;quotient high : CX
;remainder low : AX
;remainder high: DX
;***************************************************************************
;
		push	bp		;save bp on stack
		mov	bp,sp		;bp := sp
		push	si		;save si on stack
		push    di		;save di on stack
		
		xor	si,si		;si(gn indicator) := 0
		
Check_1:	mov	ax,[bp+12]	;if dividend_hi is negative then
		test	ax,ax		;change sign and negate
		jge	Check_2		;si(gn indicator).
		not	si		;si := NOT(si)
		mov	dx,[bp+10]	;dx := dividend_lo
		neg	ax		;negate dividend_hi
		neg	dx		;negate dividend_lo
		sbb	ax,00		;subtract dividend_hi by borrow
		mov	[bp+10],dx	;move dividend back to 
		mov	[bp+12],ax	;stack.
		
Check_2:	push	si		;save sign of dividend
		mov	ax,[bp+08]	;If divisor_hi >= 0 then
		test	ax,ax		;    goto Check_3
		jg	Check_3		;If divisor_hi = 0 then
		je	Chk_for_0	;    goto Chk_for_0
		not	si		;(divisor_hi is neg.) si := NOT(si)
		mov	dx,[bp+06]	;dx := divisor_lo
		neg	ax		;negate divisor_hi
		neg	dx		;negate divisor_lo
		sbb	ax,00		;subtract divisor_hi by borrow
		mov	[bp+06],dx	;move divisor back
		mov	[bp+08],ax	;to stack
		jmp	Check_3		;goto Check_3
Chk_for_0:	mov	dx,[bp+06]	;if divisor_lo # 0 then 
		test	dx,dx		;     goto Check_3
		jne	Check_3		;(divisor is zero!)
Set_cf:		stc			;Set carry flag
		jmp	Return		;goto Return
				
Check_3:	test	ax,ax		;If divisor > 16Bit Then
		jnz	Shift_Ops	;     goto Shift_Ops.
		mov	ax,[bp+12]	;if dividend_hi # 8000H then
		cmp	ax,8000h	;     goto Div_Hi
		jne	Div_Hi		;
		cmp     si,0		;if Quotient < 0 then
		jnz	Div_Hi		;     goto Div_Hi
		jmp	Set_cf		;Goto Set_cf
Div_Hi:		mov	bx,[bp+06]	;(Division if divisor <= 16 Bit)
		xor	dx,dx		;dx := 0   (ax := divident_hi)
		div	bx		;(dx,ax) := Dividend_hi/Divisor_lo
		mov	cx,ax		;cx := Quotient_hi
		mov	ax,[bp+10]	;ax := Dividend_lo
		div	bx		;(dx,ax) := Dividend_lo/Divisor_lo
		mov	bx,ax		;bx := Quotient_lo
		mov	ax,dx		;ax := Remainder_lo
		xor	dx,dx		;dx := Remainder_hi := 0
		jmp	Adj_Quo		;goto Adj_Quo
		
Shift_Ops:	mov	bx,ax		;Shift dividend and divisor to the
		mov	cx,[bp+06]	;right (divides dividend and
		mov	dx,[bp+12]	;divisor by two) until divisor is
		mov	ax,[bp+10]	;smaller than 16 Bit.
Loop_1:		shr	bx,1		;
		rcr	cx,1		;Dividend => Dividend_sh
		shr	dx,1		;Divisor  => Divisor_sh
		rcr	ax,1		;
		test	bx,bx		;
		jnz	Loop_1		;
Calc_Quot:	div	cx		;(dx,ax) := Dividend_sh/Divisor_sh
		mov	di,ax		;Save Quotient in di
		xor	dx,dx		;
		push	dx		;Multiply Quotient by Divisor
		push	ax		;(call LMultU__Longs)
		push	[bp+08]		;Result will be Dividend_x
		push	[bp+06]		;
		call	LMultU__Longs	;
		cmp	bx,[bp+12]	;If Dividend_x_hi > Dividend_hi then
		ja	Correct_Res	;     goto Correct_Res
		jb	Calc_Rem2	;If Dividend_x_hi < Dividend_hi then
		cmp	ax,[bp+10]	;     goto Calc_Rem
		jbe	Calc_Rem2	;If Dividend_x_lo <= Dividend_lo then
		nop			;     goto Calc_Rem
Correct_Res:	dec	di		;Decrement di by 1 (correct Quotient)
		sub	ax,[bp+06]	;ax := Dividend_x_lo - Divisor_lo 
		sbb	bx,[bp+08]	;bx := Dividend_X_hi - Divisor_hi
		
Calc_Rem2:	push	ax		;Save ax on stack
		push	bx		;Save bx on stack
		mov	ax,[bp+10]	;ax := Dividend_lo
		mov	dx,[bp+12]	;dx := Dividend_hi
		sub	ax,[bp-08]	;ax := Dividend_lo - Dividend_x_lo
		sbb	dx,[bp-10]	;dx := Dividend_hi - Dividend_x_hi
		mov	bx,di		;bx := Quotient_lo
		xor	cx,cx		;cx := 0
		add	sp,4		;correct stack pointer
		
Adj_Quo:	test	si,si		;if si(gn indicator) = 0 then
		jz	Adj_Rem		;     goto Adj_Rem
		neg	cx		;negate Quotient_hi
		neg	bx		;negate Quotient_lo
		sbb	cx,00		;subtract borrow from Quotient_hi
Adj_Rem:	pop	si		;get sign of Dividend
		test	si,si		;if Dividend was positiv then
		jz	Adj_End		;     goto Adj_End
		neg	dx		;negate Remainder_hi
		neg	ax		;negate Remainder_lo
		sbb	dx,00		;subtract borrow from Quotient_hi
Adj_End:	clc			;clear carry flag (no error)
		
Return:		pop     di		;restore registers
		pop	si		;and set stack
		mov	sp,bp		;pointer on entry value.
		pop	bp		;
		ret	8		;
		
                
LDiv__Longs      endp


$INIT__Longs     proc far                        ; initialization part
                ret
$INIT__Longs     endp    
      
                                                                      
Longs_TEXT    ENDS 

        END      
        
