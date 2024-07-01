/ High speed screen update for Rainbow.
/ MWC-86 has this in CP/M-86 but not in MS-DOS.
/ putline(row, col, buf);
/ Row and column are origin 1.
/ The buf is a pointer to an array of characters.
/ It won't write past the end of the line in
/ the video RAM; it looks for the FF at the end
/ of the line.
/ This routine by Bob McNamara.

	.globl	putline_

Scr_Seg = 0xEE00
ScrPtr	= 3

putline_:
	push	si
	push	di
	push	es
	mov	ax,$Scr_Seg	/point our extra segment into screen RAM
	mov	es,ax
	mov	di,es:ScrPtr+1	/di <- base line address
	and	di,$0x0fff
	movb	al,$0xff
	cld

	mov	bx,sp
	mov	dx,8(bx)	/dx = row number to write
	mov	si,12(bx)	/si = string to be moved
	mov	bx,10(bx)	/bx = column number to start at
	dec	bx		/column number starts at 1
	dec	dx		/row number starts at 1 too
	jz	2f
1:
	mov	cx,$140
	repnz scasb
	mov	di,es:(di)	/di = pointer to next line
	and	di,$0x0fff
	dec	dx
	jnz	1b
2:	
	add	di,bx		/di -> offset in row
3:
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	cmpb	al,es:(di)
	jz	4f
	movsb
	jmp	3b
4:
	pop	es
	pop	di
	pop	si
	ret
