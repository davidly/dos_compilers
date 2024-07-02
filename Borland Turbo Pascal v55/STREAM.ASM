; Turbo Pascal 5.5 object-oriented example
; Assembler code for OBJECTS.PAS unit
; Copyright (c) 1989 by Borland International, Inc.

        TITLE   Stream

        INCLUDE OBJECTS.INC

CODE    SEGMENT BYTE PUBLIC

        ASSUME  CS:CODE

        PUBLIC  Stream@Get

Stream@Get      PROC    FAR

@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        PUSH    AX
        MOV     AX,SP
        PUSH    SS
        PUSH    AX
        MOV     AX,2
        PUSH    AX
        LES     DI,@Self
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    [DI].Stream$Read
        POP     BX
        OR      BX,BX
        JE      @@2
        LES     DI,@Self
        DEC     BX
        CMP     BX,ES:[DI].Stream@TypeCount
        JAE     @@1
        PUSH    ES
        PUSH    DI
        LES     DI,ES:[DI].Stream@TypeList
        SHL     BX,1
        PUSH    WORD PTR ES:[DI+BX]
        XOR     AX,AX
        PUSH    AX
        PUSH    AX
        LES     DI,@Self
        LES     DI,ES:[DI].Stream@ProcList
        SHL     BX,1
        SHL     BX,1
        CALL    ES:[DI+BX].SProc@LoadProc
        JMP     SHORT @@3
@@1:    MOV     AX,-2
        CALL    StreamError
@@2:    XOR     AX,AX
        MOV     DX,AX
@@3:    POP     BP
        RET     4

Stream@Get      ENDP

        PUBLIC  Stream@Put

Stream@Put      PROC    FAR

@B              EQU     (DWORD PTR [BP+10])
@Self           EQU     (DWORD PTR [BP+6])

        PUSH    BP
        MOV     BP,SP
        LES     DI,@B
        MOV     CX,ES
        OR      CX,DI
        JE      @@1
        MOV     AX,ES:[DI]
        LES     DI,@Self
        MOV     CX,ES:[DI].Stream@TypeCount
        JCXZ    @@2
        MOV     BX,CX
        LES     DI,ES:[DI].Stream@TypeList
        CLD
        REPNE   SCASW
        JNE     @@2
        NEG     CX
        ADD     CX,BX
@@1:    PUSH    CX
        MOV     AX,SP
        PUSH    SS
        PUSH    AX
        MOV     AX,2
        PUSH    AX
        LES     DI,@Self
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    [DI].Stream$Write
        POP     BX
        DEC     BX
        JS      @@3
        LES     DI,@Self
        PUSH    ES
        PUSH    DI
        PUSH    @B.w2
        PUSH    @B.w0
        LES     DI,ES:[DI].Stream@ProcList
        SHL     BX,1
        SHL     BX,1
        SHL     BX,1
        CALL    ES:[DI+BX].SProc@StoreProc
        JMP     SHORT @@3
@@2:    LES     DI,@Self
        MOV     AX,-1
        CALL    StreamError
@@3:    POP     BP
        RET     8

Stream@Put      ENDP

; Stream error handler
; In    AX    = Error code
;       ES:DI = Stream object pointer
; Uses  AX,BX,CX,DX,SI

        PUBLIC  StreamError

StreamError     PROC    NEAR

        PUSH    ES
        PUSH    DI
        PUSH    AX
        PUSH    ES
        PUSH    DI
        MOV     DI,ES:[DI]
        CALL    [DI].Stream$Error
        POP     DI
        POP     ES
        RET

StreamError     ENDP

CODE    ENDS

        END
