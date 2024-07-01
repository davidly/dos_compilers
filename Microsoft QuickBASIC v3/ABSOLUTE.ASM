	TITLE	ABSOLUTE - helper for assembly routines

;***
; ABSOLUTE - Helper for calling BASIC interpreter assembly routines
;
; Just used to clear information from the stack to various registers and
; memory locations.
;***

CODE	SEGMENT BYTE PUBLIC 'CODE'

	ASSUME	CS:CODE

	PUBLIC	ABSOLUTE

ABSOLUTE PROC	FAR

	POP	DI			;return offset
	POP	SI			;return segment
	POP	BX			;address of routine offset
	PUSH	SI			;restack return segment
	PUSH	DI			;restack return offset
	PUSH	DS:[0]			;stack DEF SEG segment
	PUSH	[BX]			;stack routine offset
	RET				;far return to start of called routine

ABSOLUTE ENDP

CODE	ENDS
	END
