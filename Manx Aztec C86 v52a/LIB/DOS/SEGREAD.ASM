; :ts=8
;Copyright (C) 1983, 1985 by Manx Software Systems
	include lmacros.h
	procdef segread,<<segs,ptr>>
ifdef LONGPTR
	mov	cx,es
	ldptr	bx,segs,es
ifdef FARPROC
	mov	ax,4[bp]
	mov	es:[bx],ax
else
	mov	es:[bx],cs
endif
	mov	es:2[bx],ss
	mov	es:4[bx],ds
	mov	es:6[bx],cx

else

	mov	bx,segs
ifdef FARPROC
	mov	ax,4[bp]
	mov	[bx],ax
else
	mov	[bx],cs
endif
	mov	2[bx],ss
	mov	4[bx],ds
	mov	6[bx],es

endif
	pret
	pend	segread
	finish
	end
