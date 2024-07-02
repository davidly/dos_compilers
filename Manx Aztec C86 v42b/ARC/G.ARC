makefile
# Copyright (C) Manx Software Systems, Inc. 1987.  All rights reserved.

# Note: the object files below are in the correct order for linking,
#	thus the OBJ macro should be changed with caution.  If you are in doubt,
#	use the ORD utility to build a correctly ordered list.

OBJ=mode.o circ.o lin.o point.o address.o scr_call.o

CC=cc
AS=as
MODEL=
AMODEL=0

.c.o:
	$(CC) +$(MODEL) -n $*.c -o $@
	sqz $@

.asm.o:
	$(AS) -dMODEL=$(AMODEL) $*.asm -o $@
	sqz $@

$(DIR)g$(MODEL).lib: $(OBJ)
	del $(DIR)g$(MODEL).lib
	lb $(DIR)g$(MODEL).lib $(OBJ)
	@echo graphics done
address.asm
; Copyright (C) 1984 by Manx Software Systems, Inc.
; :ts=8
dataseg segment word public 'data'

	public	$address

$address	equ	this word	;/* vertical address table */ 	
	dw	7920+8192
	dw	7920
	dw	7840+8192
	dw	7840
	dw	7760+8192
	dw	7760
	dw	7680+8192
	dw	7680
	dw	7600+8192
	dw	7600
	dw	7520+8192
	dw	7520
	dw	7440+8192
	dw	7440
	dw	7360+8192
	dw	7360
	dw	7280+8192
	dw	7280
	dw	7200+8192
	dw	7200
	dw	7120+8192
	dw	7120
	dw	7040+8192
	dw	7040
	dw	6960+8192
	dw	6960
	dw	6880+8192
	dw	6880
	dw	6800+8192
	dw	6800
	dw	6720+8192
	dw	6720
	dw	6640+8192
	dw	6640
	dw	6560+8192
	dw	6560
	dw	6480+8192
	dw	6480
	dw	6400+8192
	dw	6400
	dw	6320+8192
	dw	6320
	dw	6240+8192
	dw	6240
	dw	6160+8192
	dw	6160
	dw	6080+8192
	dw	6080
	dw	6000+8192
	dw	6000
	dw	5920+8192
	dw	5920
	dw	5840+8192
	dw	5840
	dw	5760+8192
	dw	5760
	dw	5680+8192
	dw	5680
	dw	5600+8192
	dw	5600
	dw	5520+8192
	dw	5520
	dw	5440+8192
	dw	5440
	dw	5360+8192
	dw	5360
	dw	5280+8192
	dw	5280
	dw	5200+8192
	dw	5200
	dw	5120+8192
	dw	5120
	dw	5040+8192
	dw	5040
	dw	4960+8192
	dw	4960
	dw	4880+8192
	dw	4880
	dw	4800+8192
	dw	4800
	dw	4720+8192
	dw	4720
	dw	4640+8192
	dw	4640
	dw	4560+8192
	dw	4560
	dw	4480+8192
	dw	4480
	dw	4400+8192
	dw	4400
	dw	4320+8192
	dw	4320
	dw	4240+8192
	dw	4240
	dw	4160+8192
	dw	4160
	dw	4080+8192
	dw	4080
	dw	4000+8192
	dw	4000
	dw	3920+8192
	dw	3920
	dw	3840+8192
	dw	3840
	dw	3760+8192
	dw	3760
	dw	3680+8192
	dw	3680
	dw	3600+8192
	dw	3600
	dw	3520+8192
	dw	3520
	dw	3440+8192
	dw	3440
	dw	3360+8192
	dw	3360
	dw	3280+8192
	dw	3280
	dw	3200+8192
	dw	3200
	dw	3120+8192
	dw	3120
	dw	3040+8192
	dw	3040
	dw	2960+8192
	dw	2960
	dw	2880+8192
	dw	2880
	dw	2800+8192
	dw	2800
	dw	2720+8192
	dw	2720
	dw	2640+8192
	dw	2640
	dw	2560+8192
	dw	2560
	dw	2480+8192
	dw	2480
	dw	2400+8192
	dw	2400
	dw	2320+8192
	dw	2320
	dw	2240+8192
	dw	2240
	dw	2160+8192
	dw	2160
	dw	2080+8192
	dw	2080
	dw	2000+8192
	dw	2000
	dw	1920+8192
	dw	1920
	dw	1840+8192
	dw	1840
	dw	1760+8192
	dw	1760
	dw	1680+8192
	dw	1680
	dw	1600+8192
	dw	1600
	dw	1520+8192
	dw	1520
	dw	1440+8192
	dw	1440
	dw	1360+8192
	dw	1360
	dw	1280+8192
	dw	1280
	dw	1200+8192
	dw	1200
	dw	1120+8192
	dw	1120
	dw	1040+8192
	dw	1040
	dw	960+8192
	dw	960
	dw	880+8192
	dw	880
	dw	800+8192
	dw	800
	dw	720+8192
	dw	720
	dw	640+8192
	dw	640
	dw	560+8192
	dw	560
	dw	480+8192
	dw	480
	dw	400+8192
	dw	400
	dw	320+8192
	dw	320
	dw	240+8192
	dw	240
	dw	160+8192
	dw	160
	dw	80+8192
	dw	80
	dw	0+8192
	dw	0

dataseg ends
	end
circ.asm
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
lin.asm
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
mode.c
/* Copyright (C) 1984 by Manx Software Systems, Inc. */

extern int _maxx;
extern int _xaspect, _yaspect;
extern char _color;
extern	int _plotf,_plottbl[];

mode (val)
{
	switch (val)  {
	case 'l': case 'L': case 3:
		scr_call (3);
		break;
	case 'm': case 'M': case 4:
		_plotf = _plottbl[0];
		_xaspect = 6;
		_yaspect = 5;
		_maxx = 319;
		scr_call (4);
		break;
	case 'h': case 'H': case 6:
		_plotf = _plottbl[1];
		_xaspect = 4;
		_yaspect = 1;
		_maxx = 639;
		scr_call (6);
		break;
	default:
		if (val < 0 || val > 6)
			return;
		scr_call (val);
		break;
	}
}

color (c)
{
	switch (c)  {
	case 'w': case 'W': case 'y': case 'Y': case 3:
		_color = 3;
		break;
	case 'm': case 'M': case 'r': case 'R': case 2:
		_color = 2;
		break;
	case 'c': case 'C': case 'g': case 'G': case 1:
		_color = 1;
		break;
	default:
		_color = 0;
		break;
	}
}

palette (c)
{
	if (c)  
		scr_call (11 << 8,1<<8 | 1,0,0);
	else
		scr_call (11 << 8,1<<8 | 0,0,0);
}

ground (c)
{
	scr_call (11 << 8, 0 << 8 | c,0,0);
}
point.asm
; Copyright (C) 1984 by Manx Software Systems, Inc.
; :ts=8
	include lmacros.h
dataseg segment para public 'data'

	extrn	$address:word
	public _oldx_,_oldy_,_color_,_maxx_
	_oldx_	dw 0
	_oldy_	dw 0
	_color_	db 1
	_maxx_	dw 320
	public	_plotf_, _plottbl_
	public mid,ultra
	public clrmsk,colmsk

clrmsk	db	00111111b,11001111b,11110011b,11111100b
			;/* clrmsk for point mode 0 */

onmask	db	10000000b,1000000b,100000b,10000b,1000b,100b,10b,1b
offmask	db	01111111b,10111111b,11011111b,11101111b
	db	11110111b,11111011b,11111101b,11111110b

colmsk	db	0,0,0,0	;/* color_ masks */
	db	1000000b,10000b,100b,1
	db	10000000b,100000b,1000b,10b
	db	11000000b,110000b,1100b,11b

_plottbl_	dw	offset mid	;medium res
	dw	offset ultra	;high res

_plotf_	dw	offset ptquit

dataseg ends
	assume ds:dataseg,cs:codeseg

	public $pnt
$pnt	proc
	cmp	si,[_maxx_]	;si=x,di=y  does not set oldx & oldy
	ja	quit
	cmp	si,0
	jb	quit
	cmp	di,199
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
scr_call.asm
; Copyright (C) 1984 by Manx Software Systems
; :ts=8
	include lmacros.h
;
;	scr_call(ax,bx,cx,dx) - issue int 10 with ax,... set to args
;
;
	procdef	scr_call,<<aax,word>,<bbx,word>,<ccx,word>,<ddx,word>>
 	push	si
 	push	di
	mov	ax,aax
	mov	bx,bbx
	mov	cx,ccx
	mov	dx,ddx
	int 	10h
 	pop 	di
 	pop	si
	pret
	pend	scr_call
	finish
	end
