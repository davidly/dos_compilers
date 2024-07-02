; Turbo Pascal 5.5 object-oriented example
; Assembler include file for OBJECTS.PAS unit
; Copyright (c) 1989 by Borland International, Inc.

; *******************************************************
; *                                                     *
; *     EQUATES AND MACROS                              *
; *                                                     *
; *******************************************************

        LOCALS  @@

; Object definition macro

OBJECT MACRO Name,Parent
  FIELD MACRO FName,FType,FCount
    &Name&@&&FName EQU (FType PTR &Name&@)
    &Name&@ = &Name&@ + FType * FCount
  ENDM
  METHOD MACRO MName
    IFE &Name&$
      &Name&@VMT EQU (WORD PTR &Name&@)
      &Name&@ = &Name&@ + WORD
      &Name&$ = 4
    ENDIF
    &Name&$&&MName EQU (DWORD PTR &Name&$)
    &Name&$ = &Name&$ + DWORD
  ENDM
  IFNB <Parent>
    &Name&@ = &Parent&@
    &Name&$ = &Parent&$
  ELSE
    &Name&@ = 0
    &Name&$ = 0
  ENDIF
ENDM

; 4-Byte record

ByteRec         STRUC
b0              DB      ?
b1              DB      ?
b2              DB      ?
b3              DB      ?
ByteRec         ENDS

; 4-Word record

WordRec         STRUC
w0              DW      ?
w2              DW      ?
w4              DW      ?
w6              DW      ?
WordRec         ENDS

; Base object type

OBJECT Base
  METHOD Done

; SProc object type

OBJECT SProc
  FIELD StoreProc,DWORD,1
  FIELD LoadProc,DWORD,1

; Stream object type

OBJECT Stream,Base
  FIELD TypeCount,WORD,1
  FIELD TypeList,DWORD,1
  FIELD ProcList,DWORD,1
  FIELD Status,WORD,1
  METHOD Error
  METHOD Flush
  METHOD GetPos
  METHOD Read
  METHOD RegisterTypes
  METHOD SetPos
  METHOD Truncate
  METHOD Write

; DosStream object type

OBJECT DosStream,Stream
  FIELD Handle,WORD,1

; BufStream object type

OBJECT BufStream,DosStream
  FIELD Buffer,DWORD,1
  FIELD BufSize,WORD,1
  FIELD BufPtr,WORD,1
  FIELD BufEnd,WORD,1
