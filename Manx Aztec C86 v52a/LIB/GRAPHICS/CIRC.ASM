; Copyright (C) 1984 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
dataseg segment word public 'data'

aldx	dw	0
aldy	dw	0

	public _yaspect_,_xaspect_
_yaspect_	dw	5
_xaspect_	dw	6

scale	dw	1024
scale2	dw	512


aspect	dw	0	;function computed aspect (scaled)
invasp	dw	0	;reciprocal of aspect (scaled too)

xorg	dw	0
yorg	dw	0
radius	dw	0

dataseg ends

	assume ds:dataseg
;--------------------------------------------------------
;procedure circle(x,y,radius)
;
;draws a circle at center (x,y) with aspect ratio
;yaspect/xaspect; radius in column units
;
;Dan Lee 7/1/1982 SourceWare
;Modified from DDJ May '83 for CI C-86 by Davin 6/22/1983 
;remodified for Aztec C86, 6/84
;
;--------------------------------------------------------
ifdef FARPROC
	extrn	$inline:far,$pnt:far
else
	extrn	$inline:near,$pnt:near
endif
	procdef set_asp,<<x_asp,word>,<y_asp,word>> 
		;set_asp (x_aspect, y_aspect);
	mov	ax, x_asp
	mov	[_xaspect_],ax
	mov	ax, y_asp
	mov	[_yaspect_],ax
	pret
	pend	set_asp

	procdef	circle,<<_xorg,word>,<_yorg,word>,<irad,word>>

	mov	cx,_xorg
	mov	[xorg],cx
	mov	dx,_yorg
	mov	[yorg],dx
	mov	ax,irad
	pop	bp
	push	es
	push	si
	push	di			;save register variables
	or	ax,ax
	jnz	okrad
	jmp	single	
okrad:	mov	[radius],ax
	mov	ax,_yaspect_	;get yaspect
	mul	[scale]		;ax=yaspect*scale
	shl	ax,1
	div	_xaspect_		;ax=(yaspect*scale)/xaspect
	inc	ax
	shr	ax,1
	mov	[aspect],ax	;store aspect*scale
	mov	ax,_xaspect_	;get xaspect in ax
	mul	[scale]		;ax=xaspect*scale
	shl	ax,1
	div	_yaspect_		;ax=(xaspect*scale)/yaspect
	inc	ax
	shr	ax,1
	mov	[invasp],ax	;store inv aspect*scale
;
; Plot 0 to 45 degrees.
; Increase y by one unit and
; decrease x by TAN units*inv aspect ratio.
;
	mov	ax,[radius]	;get radius for initial x
	mul	[scale]		;ax=radius*scale
	xor	di,di		;zero initial y value

nlp1:	push	ax		;save lo word x*scale
	push	dx		;save hi word x*scale
	add	ax,[scale2]
	adc	dx,0
	div	[scale]		
	mov	[aldx],ax      ; aldx,aldy are old relative coord's
	mov	[aldy],di
	pop	dx
	pop	ax

lp1:	push	ax		;save lo word x*scale
	push	dx		;save hi word x*scale
	add	ax,[scale2]
	adc	dx,0
	div	[scale]		
	mov	bx,ax		;bx=1st quad x
	add	ax,[xorg]	;add x origin

	push	bp
	push	di      ;relative y-coord
	push	bx		;relative x-coord
	mov	bp,sp
	mov	bx,[yorg]	;get y origin
	sub	bx,di		;and sub y to plot
	call	pnt1
	pop	cx         ;1st quad x val
	pop	di
	mov	[aldx],cx
	mov	[aldy],di
	pop	bp

;cx = 1st quad x, di = 1st quad y
	inc	di		;get new y
	mov	ax,di		;ax=y
	mul	[invasp]	;ax=y*inv aspect*scale
	div	cx		;ax=TAN*inv aspect*scale
	xor	dx,dx		;zero remainder
	mov	si,ax		;si=TAN*inv aspect*scale
	div	[invasp]	;ax=TAN
	cmp	ax,1		;TAN=1?
	pop	dx		;dx=hi word x*scale
	pop	ax		;ax=lo word x*scale
	jae	part2		;yes, go to next sector
	neg	si		;to decrement x
	add	ax,si		;new x value
	adc	dx,-1		;hi word carry
	jmp	short lp1	;plot new point
;
; Plot 45 to 90 degrees.
; Decrease x by one unit and
; increase y by COT units*aspect ratio.
;
part2:	mov	ax,di		;get next y to plot
	mul	[scale]		;dx:ax=y*scale
	mov	di,cx		;di=last x value
	dec	di		;next x to plot
lp2:	push	ax		;save lo word y*scale
	push	dx		;save hi word y*scale
	add	ax,[scale2]	;'one-half'
	adc	dx,0
	div	[scale]		;ax=y
	mov	bx,ax       ;bx=1st quad y co-ord

	add	ax,[yorg]	;add y origin
	mov	cx,[xorg]	;cx=x origin
	add	cx,di		;x to plot

	push	bp
	push	bx
	push	di
	mov	bp,sp
	mov	bx,ax
	mov	ax,cx
	call	pnt2
	pop	di
	pop	bx
	mov	[aldx],di
	mov	[aldy],bx
	pop	bp

	or	di,di		;90 degrees?
	js	exit		;yes, exit
	dec	di		;get new x
	mov	ax,di		;ax=x
	imul	[aspect]	;ax=x*aspect*scale
	idiv	bx		;ax=COT*aspect*scale
	mov	si,ax		;si=change in y
	pop	dx		;dx=hi word y*scale
	pop	ax		;ax=lo word y*scale
	xor	bx,bx
	or	si,si		;for sign check
	jns	skp		;positive
	mov	bx,-1		;negative carry
skp:	add	ax,si		;ax=new x value
	adc	dx,bx
	jmp	short lp2	;plot next point

exit:	add	sp,4		;release parms
	jmp alldone

pnt1	proc near
;bp points to rel x coord and bp+2 points to rel y coord
;abs coords of point are in ax,bx

	mov	si,[aldx]
	add	si,[xorg]     ;si is old abs x
	mov	di,[yorg]
	mov	cx,[aldy]
	sub	di,cx          ;di is old abs y

	call	$goinline ;write 1st quad point
	sub	ax,word ptr [bp]		;get 2nd quad x+origin
	sub	ax,word ptr [bp]
	sub	si,[aldx]
	sub	si,[aldx]
	call	$goinline		;write 2nd quad point
	add	bx,word ptr 2[bp]		;get 3rd quad y+origin
	add	bx,word ptr 2[bp]
	add	di,[aldy]
	add di,[aldy]
	call	$goinline		;write 3rd quad point
	add	ax,word ptr [bp]		
	add	ax,word ptr [bp] ;get 4th quad x+origin
	add	si,[aldx]
	add	si,[aldx]
	call	$goinline		;plot 4th quad point
	ret
pnt1	endp

pnt2	proc	near
	mov	si,[aldx]
	add	si,[xorg]
	mov	di,[yorg]
	add di,[aldy]

	call	$goinline ;write 1st quad point
	sub	ax,word ptr [bp]		;get 2nd quad x+origin
	sub	ax,word ptr [bp]
	sub	si,[aldx]
	sub	si,[aldx]
	call	$goinline		;write 2nd quad point
	sub	bx,word ptr 2[bp]		;get 3rd quad y+origin
	sub	bx,word ptr 2[bp]
	sub	di,[aldy]
	sub di,[aldy]
	call	$goinline		;write 3rd quad point
	add	ax,word ptr [bp]		
	add	ax,word ptr [bp] ;get 4th quad x+origin
	add	si,[aldx]
	add	si,[aldx]
	call	$goinline		;plot 4th quad point
	ret
pnt2	endp

single:
	mov	si,cx
	mov	di,dx
	call	$pnt
alldone:
	pop	di
	pop	si
	pop	es
	ret

$goinline	proc near
	push	ax
	push	bx
	push	si
	push	di
	call	$inline			;pops es,di,si
	pop	di
	pop	si
	pop	bx
	pop	ax
	ret
$goinline	endp

	pend	circle
	finish
	end
