;***
;brkctl.inc - definitions and structure for brkctl
;
;	Copyright (c) 1987-1988, Microsoft Corporation.  All rights reserved.
;
;Purpose:
;	The file contains brkctl command values and structure
;	definitions.
;
;*******************************************************************************

BR_ARGSEG= 1			; specified segment
BR_NEWSEG= 2			; new segment
BR_IMPSEG= 3			; last or new segment

MAXSEG=	20			; maximum brkctl segments for REAL mode
MAXSEG_PM =	64		; maximum brkctl segments for PROTECTED mode

segrec	struc			; defines brkctl segment offsets
	sz	dw      ?
	sg	dw      ?
segrec	ends

heaprec	struc			; defines heap descriptor offsets
	bottom	dw      ?
	roveroff dw      ?
	last	dw      ?
	top	dw      ?
	nextseg	dw      ?
heaprec	ends
