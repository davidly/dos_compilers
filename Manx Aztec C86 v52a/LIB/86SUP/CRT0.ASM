; Copyright (C) 1983-1992 by Manx Software Systems
; :ts=8
; Note: This module must be assembled using Microsoft's MASM 
; or Borland's TASM assembler, not the Manx as assembler.
PGROUP	group	@CODE,PROG
@CODE	segment	byte public 'CODE'
@CODE	ends
PROG	segment	byte public 'CODE'
PROG	ends

DGROUP	group	@DATAB,@DATAI,@DATAT,@DATAU,@DATAV,@STACK

@DATAB	segment	para public 'DATAB'
@DATAB	ends

@DATAI	segment	word public 'DATAI'
	db	'Aztec C86 version 5.2a',0
	even
	public	__Dorg
__Dorg	label	 byte
@DATAI	ends

@DATAT	segment	word public 'DATAT'
	public	__Dend
__Dend	label	 byte
	public	__Uorg
__Uorg	label	 byte
@DATAT	ends

@DATAU	segment	word public 'DATAU'
@DATAU	ends

@DATAV	segment	word public 'DATAV'
	public	__Uend
__Uend	label	 byte
@DATAV	ends

@STACK	segment	para stack 'STACK'
First	db	2048 dup (?)
@STACK	ends
	end
