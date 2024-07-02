; Turbo Pascal 5.5 object-oriented example
; Assembler code for OBJECTS.PAS unit
; Copyright (c) 1989 by Borland International, Inc.

        TITLE   BUFSTM

        INCLUDE OBJECTS.INC

CODE    SEGMENT BYTE PUBLIC

        EXTRN   StreamError:NEAR
        EXTRN   DosStream@GetPos:NEAR

        ASSUME  CS:CODE

        PUBLIC  BufStream@Flush

BufStream@Flush  PROC   FAR

@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CMP     ES:[DI].Stream@Status,0
        JNE     @@1
        MOV     AL,2
        CALL    FlushBuffer
@@1:    POP     BP
        RET     4

BufStream@Flush  ENDP

        PUBLIC  BufStream@GetPos

BufStream@GetPos  PROC  FAR

@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        PUSH    ES
        PUSH    DI
        PUSH    CS
        CALL    DosStream@GetPos
        OR      DX,DX
        JS      @@1
        LES     DI,@Self
        SUB     AX,ES:[DI].BufStream@BufEnd
        SBB     DX,0
        ADD     AX,ES:[DI].BufStream@BufPtr
        ADC     DX,0
@@1:    POP     BP
        RET     4

BufStream@GetPos  ENDP

        PUBLIC  BufStream@Read

BufStream@Read  PROC    FAR

@Buf            EQU     (DWORD PTR [BP+12])
@Count          EQU     (WORD PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CMP     ES:[DI].Stream@Status,0
        JNE     @@6
        MOV     AL,1
        CALL    FlushBuffer
        JNE     @@6
        XOR     DX,DX
@@1:    MOV     CX,@Count
        SUB     CX,DX
        JE      @@7
        LES     DI,@Self
        MOV     AX,ES:[DI].BufStream@BufEnd
        SUB     AX,ES:[DI].BufStream@BufPtr
        JA      @@2
        PUSH    CX
        PUSH    DX
        PUSH    DS
        LDS     DX,ES:[DI].BufStream@Buffer
        MOV     CX,ES:[DI].BufStream@BufSize
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AH,3FH
        INT     21H
        POP     DS
        POP     DX
        POP     CX
        JC      @@5
        MOV     ES:[DI].BufStream@BufPtr,0
        MOV     ES:[DI].BufStream@BufEnd,AX
        OR      AX,AX
        JE      @@4
@@2:    CMP     CX,AX
        JB      @@3
        MOV     CX,AX
@@3:    PUSH    DS
        LDS     SI,ES:[DI].BufStream@Buffer
        ADD     SI,ES:[DI].BufStream@BufPtr
        ADD     ES:[DI].BufStream@BufPtr,CX
        LES     DI,@Buf
        ADD     DI,DX
        ADD     DX,CX
        CLD
        REP     MOVSB
        POP     DS
        JMP     @@1
@@4:    MOV     AX,101
@@5:    CALL    StreamError
@@6:    LES     DI,@Buf
        MOV     CX,@Count
        XOR     AL,AL
        CLD
        REP     STOSB
@@7:    POP     BP
        RET     10

BufStream@Read  ENDP

        PUBLIC  BufStream@Write

BufStream@Write  PROC   FAR

@Buf            EQU     (DWORD PTR [BP+12])
@Count          EQU     (WORD PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CMP     ES:[DI].Stream@Status,0
        JNE     @@4
        MOV     AL,0
        CALL    FlushBuffer
        JNE     @@4
        XOR     DX,DX
@@1:    MOV     CX,@Count
        SUB     CX,DX
        JE      @@4
        LES     DI,@Self
        MOV     AX,ES:[DI].BufStream@BufSize
        SUB     AX,ES:[DI].BufStream@BufPtr
        JA      @@2
        PUSH    CX
        PUSH    DX
        MOV     AL,1
        CALL    FlushBuffer
        POP     DX
        POP     CX
        JNE     @@4
        MOV     AX,ES:[DI].BufStream@BufSize
@@2:    CMP     CX,AX
        JB      @@3
        MOV     CX,AX
@@3:    PUSH    DS
        MOV     AX,ES:[DI].BufStream@BufPtr
        ADD     ES:[DI].BufStream@BufPtr,CX
        LES     DI,ES:[DI].BufStream@Buffer
        ADD     DI,AX
        LDS     SI,@Buf
        ADD     SI,DX
        ADD     DX,CX
        CLD
        REP     MOVSB
        POP     DS
        JMP     @@1
@@4:    POP     BP
        RET     10

BufStream@Write  ENDP

; Flush stream buffer
; In    AL    = Flush mode (0=Read,1=Write,2=Both)
;       ES:DI = BufStream pointer
; Out   ZF    = Status test

FlushBuffer     PROC    NEAR

        MOV     CX,ES:[DI].BufStream@BufPtr
        SUB     CX,ES:[DI].BufStream@BufEnd
        JE      @@4
        MOV     BX,ES:[DI].DosStream@Handle
        JA      @@1
        CMP     AL,1
        JE      @@4
        MOV     DX,CX
        MOV     CX,-1
        MOV     AX,4201H
        INT     21H
        JMP     SHORT @@3
@@1:    CMP     AL,0
        JE      @@4
        PUSH    DS
        LDS     DX,ES:[DI].BufStream@Buffer
        MOV     AH,40H
        INT     21H
        POP     DS
        JC      @@2
        CMP     AX,CX
        JE      @@3
        MOV     AX,101
@@2:    CALL    StreamError
@@3:    XOR     AX,AX
        MOV     ES:[DI].BufStream@BufPtr,AX
        MOV     ES:[DI].BufStream@BufEnd,AX
        CMP     AX,ES:[DI].Stream@Status
@@4:    RET

FlushBuffer     ENDP

CODE    ENDS

        END
