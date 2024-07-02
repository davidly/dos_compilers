; Turbo Pascal 6.0 example
; Assembler include file for WIN.PAS unit
; Copyright (c) 1989,90 by Borland International, Inc.

        TITLE   WIN

        LOCALS  @@

; Coordinate record

X               EQU     (BYTE PTR 0)
Y               EQU     (BYTE PTR 1)

; BIOS workspace equates

CrtMode         EQU     (BYTE PTR 49H)
CrtWidth        EQU     (BYTE PTR 4AH)

DATA    SEGMENT WORD PUBLIC

; Externals from CRT unit

        EXTRN   CheckSnow:BYTE,WindMin:WORD,WindMax:WORD

DATA    ENDS

CODE    SEGMENT BYTE PUBLIC

        ASSUME  CS:CODE,DS:DATA

; procedure WriteStr(X, Y: Byte; S: String; Attr: Byte);

        PUBLIC  WriteStr

WriteStr:

        PUSH    BP
        MOV     BP,SP
        LES     BX,[BP+8]
        MOV     CL,ES:[BX]
        MOV     SI,OFFSET CS:CrtWriteStr
        CALL    CrtWrite
        POP     BP
        RETF    10

; procedure WriteChar(X, Y, Count: Byte; Ch: Char; Attr: Byte);

        PUBLIC  WriteChar

WriteChar:

        PUSH    BP
        MOV     BP,SP
        MOV     CL,[BP+10]
        MOV     SI,OFFSET CS:CrtWriteChar
        CALL    CrtWrite
        POP     BP
        RETF    10

; procedure FillWin(Ch: Char; Attr: Byte);

        PUBLIC  FillWin

FillWin:

        MOV     SI,OFFSET CS:CrtWriteChar
        JMP     SHORT CommonWin

; procedure ReadWin(var Buf);

        PUBLIC  ReadWin

ReadWin:

        MOV     SI,OFFSET CS:CrtReadWin
        JMP     SHORT CommonWin

; procedure WriteWin(var Buf);

        PUBLIC  WriteWin

WriteWin:

        MOV     SI,OFFSET CS:CrtWriteWin

; Common FillWin/ReadWin/WriteWin routine

CommonWin:

        PUSH    BP
        MOV     BP,SP
        XOR     CX,CX
        MOV     DX,WindMin
        MOV     CL,WindMax.X
        SUB     CL,DL
        INC     CX
@@1:    PUSH    CX
        PUSH    DX
        PUSH    SI
        CALL    CrtBlock
        POP     SI
        POP     DX
        POP     CX
        INC     DH
        CMP     DH,WindMax.Y
        JBE     @@1
        POP     BP
        RETF    4

; Write string to screen

CrtWriteStr:

        PUSH    DS
        MOV     AH,[BP+6]
        LDS     SI,[BP+8]
        INC     SI
        JC      @@4
@@1:    LODSB
        MOV     BX,AX
@@2:    IN      AL,DX
        TEST    AL,1
        JNE     @@2
        CLI
@@3:    IN      AL,DX
        TEST    AL,1
        JE      @@3
        MOV     AX,BX
        STOSW
        STI
        LOOP    @@1
        POP     DS
        RET
@@4:    LODSB
        STOSW
        LOOP    @@4
        POP     DS
        RET

; Write characters to screen

CrtWriteChar:

        MOV     AL,[BP+8]
        MOV     AH,[BP+6]
        JC      @@4
        MOV     BX,AX
@@1:    IN      AL,DX
        TEST    AL,1
        JNE     @@1
        CLI
@@2:    IN      AL,DX
        TEST    AL,1
        JE      @@2
        MOV     AX,BX
        STOSW
        STI
        LOOP    @@1
        RET
@@4:    REP     STOSW
        RET

; Read window buffer from screen

CrtReadWin:

        PUSH    DS
        PUSH    ES
        POP     DS
        MOV     SI,DI
        LES     DI,[BP+6]
        CALL    CrtCopyWin
        MOV     [BP+6],DI
        POP     DS
        RET

; Write window buffer to screen

CrtWriteWin:

        PUSH    DS
        LDS     SI,[BP+6]
        CALL    CrtCopyWin
        MOV     [BP+6],SI
        POP     DS
        RET

; Window buffer copy routine

CrtCopyWin:

        JC      @@4
@@1:    LODSW
        MOV     BX,AX
@@2:    IN      AL,DX
        TEST    AL,1
        JNE     @@2
        CLI
@@3:    IN      AL,DX
        TEST    AL,1
        JE      @@3
        MOV     AX,BX
        STOSW
        STI
        LOOP    @@1
        RET
@@4:    REP     MOVSW
        RET

; Do screen operation
; In    CL = Buffer length
;       SI = Write procedure pointer
;       BP = Stack frame pointer

CrtWrite:

        MOV     DL,[BP+14]
        DEC     DL
        ADD     DL,WindMin.X
        JC      CrtExit
        CMP     DL,WindMax.X
        JA      CrtExit
        MOV     DH,[BP+12]
        DEC     DH
        ADD     DH,WindMin.Y
        JC      CrtExit
        CMP     DH,WindMax.Y
        JA      CrtExit
        XOR     CH,CH
        JCXZ    CrtExit
        MOV     AL,WindMax.X
        SUB     AL,DL
        INC     AL
        CMP     CL,AL
        JB      CrtBlock
        MOV     CL,AL

; Do screen operation
; In    CL = Buffer length
;       DX = CRT coordinates
;       SI = Procedure pointer

CrtBlock:

        MOV     AX,40H
        MOV     ES,AX
        MOV     AL,DH
        MUL     ES:CrtWidth
        XOR     DH,DH
        ADD     AX,DX
        SHL     AX,1
        MOV     DI,AX
        MOV     AX,0B800H
        CMP     ES:CrtMode,7
        JNE     @@1
        MOV     AH,0B0H
@@1:    MOV     ES,AX
        MOV     DX,03DAH
        CLD
        CMP     CheckSnow,1
        JMP     SI

; Exit from screen operation

CrtExit:

        RET

; function WinSize: Word;

        PUBLIC  WinSize

WinSize:

        MOV     AX,WindMax
        SUB     AX,WindMin
        ADD     AX,101H
        MUL     AH
        SHL     AX,1
        RETF

CODE    ENDS

        END
