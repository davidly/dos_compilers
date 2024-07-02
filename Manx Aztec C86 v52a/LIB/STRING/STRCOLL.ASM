; :ts=8
;Copyright (C) 1983 by Manx Software Systems
	include	lmacros.h

;
;	We currently don't have any special collation sequences, so
;	just do a regular strcmp() call.
;

	public	strcoll_
ifdef	FARPROC
	extrn	strcmp_:far
else
	extrn	strcmp_:near
endif

strcoll_:
	jmp	strcmp_
