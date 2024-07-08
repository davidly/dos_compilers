;
; CALL_DOS.ASM
;
; A program to call DOS from Artek Ada
; (C) 1985, 86, 87 Artek Corporation
;
; Author : V. Thorsteinsson
;
; As per the Artek Calling Convention rev. 2,
; SI points to parameters and DI points to local
; variables at entry.  BP must not be modified.
; SS, ES, and DS all point to the data segment
; and must be preserved.
; The frames of statically enclosing subprograms
; cannot be accessed.  Static data also cannot
; be accessed.
;
CGROUP  GROUP CODE
CODE    SEGMENT 'CODE'
ASSUME  CS:CGROUP, DS:NOTHING, ES:NOTHING
;
DOSCALL PROC    FAR
        MOV     BX, [SI]        ; Load the address of REGS (parameter)
        PUSH    BP
        PUSH    ES
        PUSH    BX
        MOV     AX, [BX]
        MOV     CX, [BX+4]
        MOV     DX, [BX+6]
        MOV     SI, [BX+8]
        LES     DI, [BX+10]
        MOV     BX, [BX+2]
        INT     21h
        MOV     BP, BX
        POP     BX
        MOV     [BX], AX
        MOV     [BX+2], BP
        MOV     [BX+4], CX
        MOV     [BX+6], DX
        MOV     [BX+8], SI
        MOV     [BX+10], DI
        MOV     [BX+12], ES
        PUSHF
        POP     AX
        MOV     [BX+14], AX     ; Set flags
        POP     ES
        POP     BP
DOSCALL ENDP
;
CODE    ENDS

        END     DOSCALL

