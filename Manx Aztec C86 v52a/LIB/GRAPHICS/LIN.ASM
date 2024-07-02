; Copyright (C) 1984 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
dataseg segment word public 'data'

	extrn _oldx_:word, _oldy_:word

deltax	dw	0
deltay	dw	0
yincr	dw	0
 	
dataseg ends
	assume ds:dataseg
ifdef FARPROC
	extrn	$pnt:far
else
	extrn	$pnt:near
endif

	public $inline
$inline	proc
	cmp	si,ax
	jbe	noxchg
	xchg	si,ax
	xchg	di,bx
noxchg:	
	jne	novert
	jmp	vertical
novert:
	sub	ax,si	
	mov	[deltax],ax
	sub	bx,di
	jnz	nohoriz
	jmp	horizontal
nohoriz:
	mov	cx,1
	jns	notneg
	neg	cx
	neg	bx
notneg:	mov	[yincr],cx
	mov	[deltay],bx
	cmp	ax,bx
	jg	case2

	mov	dx,[deltax]
	shl	dx,1
	mov	bx,dx
	mov	ax,[deltay]
	shl	ax,1
	sub	bx,ax
	mov	ax,dx
	sub	ax,[deltax]

	mov	cx,[deltay]
lp1:	dec	cx
	js	done
	call	$pnt
	add	di,[yincr]
	cmp	ax,0
	jl	incr1
	inc	si
	add	ax,bx
	jmp	short lp1
incr1:
	add	ax,dx
	jmp	short lp1

case2:

	mov	dx,[deltay]
	shl	dx,1           ;dx <- 2 * deltay
	mov	bx,dx
	mov	ax,[deltax]
	shl	ax,1           
	sub	bx,ax         ;bx <- 2*deltay - 2 * deltax
	mov	ax,dx
	sub	ax,[deltax]         ;ax <- 2*deltay - deltax

	mov	cx,[deltax]
lp2:	dec	cx
	js	done
	call	$pnt
	inc	si
	cmp	ax,0
	jl	incr2
	add	di,[yincr]
	add	ax,bx
	jmp	short lp2
incr2:
	add	ax,dx
	jmp	short lp2

vertical:                  ;si = xval, di,bx = yvals
	cmp	di,bx
	jle	yorder
	xchg	bx,di
yorder:
	sub	bx,di
vplot:
	call	$pnt
	inc	di
	dec	bx
	jns	vplot
	jmp	short done

horizontal:                ;ax=deltax, si,di = start point
	call	$pnt
	inc	si
	dec	ax
	jns	horizontal
	;jmp	short done

done: 
	ret
$inline	endp

	procdef	lineto,<<xdest,word>,<ydest,word>>

		; lineto (dest_x, dest_y);
	push	si
	push	di
	push	es
	mov	si,[_oldx_]
	mov	di,[_oldy_]
	mov	ax,xdest
	mov	bx,ydest
	mov	[_oldx_],ax
	mov	[_oldy_],bx
	call 	$inline			;pops si,di,es before returning
	pop es
	pop di
	pop si
	pret
	pend	lineto

	procdef	line,<<srcx,word>,<srcy,word>,<ddstx,word>,<ddsty,word>>
		; line (src_x, src_y, dest_x, dest_y);
	push	si
	push	di
	push	es
	mov	si,srcx
	mov	di,srcy
	mov	ax,ddstx
	mov	bx,ddsty
	mov	[_oldx_],ax
	mov 	[_oldy_],bx
	call $inline
	pop es
	pop di
	pop si
	pret
	pend	line
	finish
	end
