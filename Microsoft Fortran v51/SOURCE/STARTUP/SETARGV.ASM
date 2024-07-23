	page	,132
	title	setargv - generic _setargv routine
;***
;setargv.asm - generic _setargv routine
;
;	Copyright (c) 1986-1990, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	Generic _setargv.
;	This stub module is for use with all memory models
;	and for both Protected-mode and Real-mode libraries.
;
;*******************************************************************************


include version.inc
.xlist
include cmacros.inc
.list

	public	__setargv	; this module

	extrn	___setargv:near ; actual wildcard expander

sBegin	code

	assumes cs,code
;***
;_setargv - sets argv by calling __setargv
;
;Purpose:
;	Routine directly transfers to __setargv (defined in stdargv.asm).
;
;Entry:
;	See __setargv.
;
;Exit:
;	See __setargv.
;
;Uses:
;	See __setargv.
;
;Exceptions:
;	See __setargv.
;
;*******************************************************************************

__setargv:
	jmp	___setargv	; jump to library routine to do real work

sEnd	code

	end
