; Copyright (C) 1983  by Manx Software Systems
	include lmacros.h
	procdef toupper,<<val1,word>>
;
	mov	ax,val1
	cmp ax,-1
	je  tu_done
	sub	ah,ah
	cmp	al,'a'
	jl	tu_done
	cmp	al,'z'
	jg	tu_done
	sub	al,'a'-'A'
tu_done:
	pret
	pend	toupper
;
;
	procdef tolower,<<val2,word>>
;
	mov	ax,val2
	cmp ax,-1
	je  skip
	sub	ah,ah
	cmp	al,'A'
	jl	skip
	cmp	al,'Z'
	jg	skip
	add	al,'a'-'A'
skip:
	pret
	pend	tolower
	finish
	end
