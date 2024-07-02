;******************************************************************************
;
;       MODULA-2    Run-Time Support  ( RTS )
;
;              LOGITECH SA,   CH-1122 Romanel    (Switzerland)
;              LOGITECH Inc,  Fremont, CA 94555  (USA)
;
;       Module  :    Interrupt controller handling for RTS:
;                    - constant and macro definitions
;
;                    Note that this include-file is also used by
;                    the Target Monitor (TMON) of the LOGITECH
;                    Modula-2 ROM TOOLS.
;
;       Release :    3.10 - July 89
;
;       Copyright (C)  1987 - 1989 Logitech, All rights reserved
;
;       Permission is hereby granted to registered users to use or abstract
;       the following program in the implementation of customized versions.
;       This permission does not include the right to redistribute the source
;       code of this program.
;
;       History:
;          Jul-87:      Original version (macro definitions in file MACRO.RTS)
;       02-May-88/akg:  StackCheck marco removed (not needed any more)
;       06-May-88/akg:  Renamed to RTSINTCO.INC, interrupt controller
;                       definitions and macros. Extended for adaptability
;                       to a different target hardware.
;       22-Sep-88/akg:  Some comments added and corrected.
;       04-Jul-89/akg:  Version 3.10 (no changes).
;
;******************************************************************************
        SUBTTL  Interrupt Controller Handling for RTS and TMON

; The following definitions relate to input/output and interrupt
; handling. The values given are valid for an IBM-PC/AT or a compatible
; target system. If your target system is different, it is likely,
; that the values in the declarations below must be modified.
;
; Note that this include-file is used by the modules of the Modula-2
; Run-Time Support (RTS), as well as by the modules of the Target
; Monitor (TMON) of the LOGITECH Modula-2 ROM TOOLS.
;
; If you have to adapt these definitions to your target hardware, then
; you should also check the corresponding RTS and TMON modules that use
; the macros defined in this include-file.

; Remark: If your target hardware is different and contains an 80x87
;         coprocessor that you use for REAL arithmetic, then you might
;         also need to adapt the modules RTS87 or RTSM87 of the RTS.


;------------------------------------------------------------
; The following points should be checked out:
;
; a) Is there an interrupt controller in your target computer (chip
;    number is typically 8259)?
;
; b) Is input/output from/to the interrupt controller done through
;    i/o-ports or is it memory-mapped (i.e. the registers of the
;    interrupt controller have fixed memory addresses)?
;
; c) Which ports (or memory addresses) are used for the interrupt
;    controller? The declarations below must be changed accordingly.


;------------------------------------------------------------
; The following definitions may be modified in order to adapt
; the RTS and the TMON to the specific configuration of the
; target system.

        INTERRUPT_CTRL  EQU     TRUE
        ; This switch must be set to TRUE if an interrupt controller
        ; is present in the target system, and to FALSE otherwise.
        ; The code used below refers to an 8259 interrupt controller.
        ; If a different controller is used, this code must be
        ; adapted accordingly. In that case, it may also be necessary
        ; to adapt the RTS and TMON modules that use the macros
        ; defined in this include-file.
        ; If no interrupt controller is present in the target
        ; computer, then the use of priorities in the heading of
        ; a Modula-2 module has no effect.

        CTRL_PORT_IO    EQU     TRUE
        ; If this switch is TRUE, then input/output from/to the
        ; interrupt controller on the target system is through ports.
        ; If it is FALSE, then memory-mapped input/output is used
        ; to access the interrupter controller. This switch has
        ; no effect, if INTERRUPT_CTRL = FALSE.


IF INTERRUPT_CTRL
;------------------------------------------------------------
; Constants used for handling the interrupt controller
; ====================================================

; Note that the modules of the RTS and of the TMON do NOT
; refer to these constants directly. Instead, they only use
; the macros defined below, which is the only place where
; these constants are used.

        MASK_8259       EQU      21H
        ; Port address of control word 1 in the interrupt controller.
        ; This port is used to read and write the interrupt mask.

        CTRL_W2_8259    EQU      20H
        ; Port address of control word 2 in the interrupt controller.
        ; This port is used to send the End-Of-Interrupt code.

        EOI_8259        EQU      20H
        ; End-Of-Interrupt code to be sent to the interrupt controller.

  IF NOT CTRL_PORT_IO
        CTRL_IO_SEGMENT EQU       0H
        ; Segment address to be used for memory-mapped input/output
        ; from/to the interrupt controller. If memory-mapped i/o is
        ; used, this value must be set accordingly.
  ENDIF

ENDIF ; INTERRUPT_CTRL


;------------------------------------------------------------
IN_AL   MACRO   PortAddr
;=======================
        ; Input of a byte from a port into AL.
        ; The following registers might be used: AL, DX.

IF PortAddr LT 100H
        IN      AL, PortAddr
ELSE
        MOV     DX, PortAddr
        IN      AL, DX
ENDIF

ENDM ; IN_AL


;------------------------------------------------------------
OUT_AL  MACRO   PortAddr
;=======================
        ; Output of the byte in AL to a port.
        ; The following registers might be used: AL, DX.

IF PortAddr LT 100H
        OUT     PortAddr, AL
ELSE
        MOV     DX, PortAddr
        OUT     DX, AL
ENDIF

ENDM ; OUT_AL


;------------------------------------------------------------
SetInterruptMask  MACRO    DSstate
;=================================

IFDEF ISTMON    ; we are assembling a TMON module
  IFNB <DSstate>
        .ERR    ; DSstate macro argument must not be used in case of TMON!
  ENDIF
        ; This macro sends the interrupt mask (passed in AL) to the
        ; interrupt controller mask register.
        ; The following registers might be used: AL, DX, ES.

ELSE            ; we are assembling a RTS module

        ; DSstate is DSset if DS is segment RTSMain_DATA
        ; else it is DSunset.
        ;
        ; This macro sends the logical OR between the process
        ; priority mask (passed in AL) and the RTS device mask
        ; to the interrupt controller mask register.
        ; The following registers might be used: AX, DX, ES, DS.

  IFIDN <DSstate>, <DSunset>    ; DS is not yet set to RTSMain_DATA
        MOV     DX, SEG RTSMain_DATA
        MOV     DS, DX
  ELSE
    IFIDN <DSstate>, <DSset>    ; DS is already set to RTSMain_DATA
    ELSE
        .ERR
    ENDIF
  ENDIF
        ASSUME  DS : RTSMain_DATA

        ; Mask all interrupts which are disabled either in the
        ; priority mask (in AL) or in the device mask.
        OR      AX, WORD PTR deviceMask__RTSMain
ENDIF ; ISTMON

IF INTERRUPT_CTRL
  IF CTRL_PORT_IO
        OUT_AL  MASK_8259       ; might use DX

; On some machines with a very fast processor, there may be
; some problem with the interrupt controller. During the 
; modification of the mask, the interrupt controller may not
; be able to respond to the acknowledge of the processor.
; In that case, you may use the following code instead of
; the one above:
;       PUSHF
;       CLI
;       OUT_AL  MASK_8259       ; might use DX
;       NOP
;       NOP
;       POPF

  ELSE ; memory-mapped i/o
        MOV     DX, CTRL_IO_SEGMENT
        MOV     ES, DX
        MOV     BYTE PTR ES:[MASK_8259], AL
  ENDIF
ELSE ; no interrupt controller
ENDIF ; INTERRUPT_CTRL

ENDM ; SetInterruptMask


;------------------------------------------------------------
GetInterruptMask  MACRO
;======================
        ; This macro returns in AX the currently valid interrupt mask.
        ; The following registers might be used: AX, DX, ES.

IF INTERRUPT_CTRL
  IF CTRL_PORT_IO
        IN_AL   MASK_8259       ; might use DX
        XOR     AH, AH
  ELSE ; memory-mapped i/o
        MOV     AX, CTRL_IO_SEGMENT
        MOV     ES, AX
        MOV     AL, BYTE PTR ES:[MASK_8259]
        XOR     AH, AH
  ENDIF
ELSE ; no interrupt controller
        XOR     AX, AX          ; return zero
ENDIF ; INTERRUPT_CTRL

ENDM ; GetInterruptMask


;------------------------------------------------------------
SendEOI  MACRO
;=============
        ; This macro sends an End-Of-Interrupt code (EOI) to the
        ; interrupt controller.
        ; The following registers might be used: AX, DX, ES.

IF INTERRUPT_CTRL
  IF CTRL_PORT_IO
        MOV     AL, EOI_8259
        OUT_AL  CTRL_W2_8259    ; might use DX
  ELSE ; memory-mapped i/o
        MOV     AX, CTRL_IO_SEGMENT
        MOV     ES, AX
        MOV     BYTE PTR ES:[CTRL_W2_8259], EOI_8259
  ENDIF
ELSE ; no interrupt controller
ENDIF ; INTERRUPT_CTRL

ENDM ; SendEOI
