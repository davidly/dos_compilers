; Copyright (C) 1984 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
dataseg segment para public 'data'

	extrn	$address:word
	public _oldx_,_oldy_,_color_,_maxx_,_maxy_
	_oldx_	dw 0
	_oldy_	dw 0
	_color_	db 1
	_maxx_	dw 320
	_maxy_	dw 200
	public	_plotf_, _plottbl_
	public mid,ultra,bios
	public clrmsk,colmsk

clrmsk	db	00111111b,11001111b,11110011b,11111100b
			;/* clrmsk for point mode 0 */

onmask	db	10000000b,01000000b,00100000b,00010000b,
	db	00001000b,00000100b,00000010b,00000001b

offmask	db	01111111b,10111111b,11011111b,11101111b
	db	11110111b,11111011b,11111101b,11111110b

colmsk	db	00000000b,00000000b,00000000b,00000000b	;/* color_ masks */
	db	01000000b,00010000b,00000100b,00000001b
	db	10000000b,00100000b,00001000b,00000010b
	db	11000000b,00110000b,00001100b,00000011b

_plottbl_	dw	offset mid	;medium res
	dw	offset ultra	;high res
	dw	offset bios	;bios

_plotf_	dw	offset ptquit

dataseg ends
	assume ds:dataseg,cs:codeseg

	public $pnt
$pnt	proc
	cmp	si,[_maxx_]	;si=x,di=y  does not set oldx & oldy
	ja	quit
	cmp	si,0
	jb	quit
	cmp	di,[_maxy_]
	ja	quit
	cmp	di,0
	jnb	$pnt3
	jmp	quit
$pnt3:	
	push	ax
	push 	bx	
	mov	bl,[_color_]	;entry #3 si=x,di=y  no clipping ! 
$pnt4:
	mov	bh,0
;entry #5 si=x,di=y,bx=color_   
;  	
$pnt5:	mov	ax,0b800h	; set es to point to hires segment
	mov	es,ax
	push	di
	shl	di,1		;mult y*2 (addr table is 2 bytes wide)
	jmp	[_plotf_]	;jmp to ptquit, mid or ultra

mid:	push	si

	mov	di,$address[di]	;get vert address from table

	mov	ax,si		;save x in si

	and	si,3
	shr	ax,1		;divide by 4 (4 dots per byte)
	shr	ax,1

	add	di,ax		;get addr of byte on screen

	sal	bl,1		; color_ table is 4 by 4 so mult color_ * 4
	sal	bl,1
	mov	bl,colmsk[si+bx]
	mov	al,clrmsk[si]
	and	es:[di],al
	or	es:[di],bl
	pop	si
ptquit:	pop	di
	pop	bx
	pop	ax
quit:	
	ret

ultra:	mov	di,$address[di]
	mov	ax,si
	push	si
	and	si,7
	shr	ax,1
	shr	ax,1
	shr	ax,1
	add	di,ax
	or	bl,bl
	jz	black
	mov	al,onmask[si]
	or	es:[di],al
	pop	si
	jmp short ptquit
black:	mov	al,offmask[si]	
	and	es:[di],al
	pop	si
	jmp short ptquit

bios:	pop	di
	push	di
	push	dx
	push	cx
	mov	dx,_maxy_
	sub	dx,di
	mov	cx,si
	mov	ah,0Ch
	mov	al,bl	
	mov	bh,00h
	int	10H
	pop	cx
	pop	dx
	jmp short ptquit
	
	procdef	point,<<xcoord,word>,<ycoord,word>>

	push	si
	push	di
	push	es
	mov	si,xcoord
	mov	di,ycoord

	mov	[_oldx_],si	;si=x,di=y   sets oldx and oldy
	mov	[_oldy_],di
	call	$pnt

	pop	es
	pop	di
	pop	si
	pret
	pend	point
	finish
	end
