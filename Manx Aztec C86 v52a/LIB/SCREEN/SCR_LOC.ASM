;	Copyright (C) 1984 by Manx Software Systems
;	:ts=8
;
;	scr_loc(lin, col)  - place the location of the cursor in line and column
;
	include lmacros.h
;
	procdef scr_loc,<<lin,ptr>,<col,ptr>>
;
	pushds
	mov	ah,3
	mov	bh,0
	int	10h      	; find the location of cursor
	ldptr	bx,lin,ds	; move address of line into bx
	mov	0[bx],dh	; move cursor location into memory
	mov	byte ptr 1[bx],0
	ldptr	bx,col,ds	; move addres of col. into bx
	mov	0[bx],dl	; move cursor location into memory
	mov	byte ptr 1[bx],0
	popds
	pret
	pend	scr_loc
	finish
	end
