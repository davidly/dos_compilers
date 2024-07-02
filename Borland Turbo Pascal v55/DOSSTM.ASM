; Turbo Pascal 5.5 object-oriented example
; Assembler code for OBJECTS.PAS unit
; Copyright (c) 1989 by Borland International, Inc.

        TITLE   DOSSTM

        INCLUDE OBJECTS.INC

CODE    SEGMENT BYTE PUBLIC

        EXTRN   StreamError:NEAR

        ASSUME  CS:CODE

        PUBLIC  DosStream@GetPos

DosStream@GetPos  PROC  FAR

@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CMP     ES:[DI].Stream@Status,0
        JNE     @@1
        XOR     CX,CX
        MOV     DX,CX
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AX,4201H
        INT     21H
        JNC     @@2
        CALL    StreamError
@@1:    MOV     AX,-1
        MOV     DX,AX
@@2:    POP     BP
        RET     4

DosStream@GetPos  ENDP

        PUBLIC  DosStream@Read

DosStream@Read  PROC    FAR

@Buf            EQU     (DWORD PTR [BP+12])
@Count          EQU     (WORD PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CMP     ES:[DI].Stream@Status,0
        JNE     @@2
        PUSH    DS
        LDS     DX,@Buf
        MOV     CX,@Count
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AH,3FH
        INT     21H
        POP     DS
        JC      @@1
        CMP     AX,CX
        JE      @@3
        MOV     AX,100
@@1:    CALL    StreamError
@@2:    LES     DI,@Buf
        MOV     CX,@Count
        XOR     AL,AL
        CLD
        REP     STOSB
@@3:    POP     BP
        RET     10

DosStream@Read  ENDP

        PUBLIC  DosStream@SetPos

DosStream@SetPos  PROC  FAR

@Pos            EQU     (DWORD PTR [BP+12])
@Mode           EQU     (BYTE PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CALL    StreamFlush
        JNE     @@1
        MOV     DX,@Pos.w0
        MOV     CX,@Pos.w2
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AL,@Mode
        MOV     AH,42H
        INT     21H
        JNC     @@1
        CALL    StreamError
@@1:    POP     BP
        RET     10

DosStream@SetPos  ENDP

        PUBLIC  DosStream@Truncate

DosStream@Truncate  PROC  FAR

@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CALL    StreamFlush
        JNE     @@1
        XOR     CX,CX
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AH,40H
        INT     21H
        JNC     @@1
        CALL    StreamError
@@1:    POP     BP
        RET     4

DosStream@Truncate  ENDP

        PUBLIC  DosStream@Write

DosStream@Write  PROC   FAR

@Buf            EQU     (DWORD PTR [BP+12])
@Count          EQU     (WORD PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CMP     ES:[DI].Stream@Status,0
        JNE     @@2
        PUSH    DS
        LDS     DX,@Buf
        MOV     CX,@Count
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AH,40H
        INT     21H
        POP     DS
        JC      @@1
        CMP     AX,CX
        JE      @@2
        MOV     AX,101
@@1:    CALL    StreamError
@@2:    POP     BP
        RET     10

DosStream@Write  ENDP

        PUBLIC  DosStream@Close

DosStream@Close  PROC   FAR

@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        CALL    StreamFlush
        JNE     @@1
        MOV     BX,ES:[DI].DosStream@Handle
        MOV     AH,3EH
        INT     21H
@@1:    POP     BP
        RET     4

DosStream@Close  ENDP

        PUBLIC  DosStream@Open

DosStream@Open  PROC    FAR

@Name           EQU     (DWORD PTR [BP+12])
@Mode           EQU     (WORD PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@Self
        PUSH    DS
        LDS     DX,@Name
        XOR     CX,CX
        MOV     AX,@Mode
        INT     21H
        POP     DS
        JNC     @@1
        CALL    StreamError
        MOV     AX,0FFFFH
@@1:    MOV     ES:[DI].DosStream@Handle,AX
        POP     BP
        RET     10

DosStream@Open  ENDP

; Call stream flush procedure
; In    ES:DI = Stream object pointer
; Out   ZF    = Status test
; Uses  AX,BX,CX,DX,SI

StreamFlush     PROC    NEAR

        PUSH    ES
        PUSH    DI
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    [DI].Stream$Flush
        POP     DI
        POP     ES
        CMP     ES:[DI].Stream@Status,0
        RET

StreamFlush     ENDP

CODE    ENDS

        END
