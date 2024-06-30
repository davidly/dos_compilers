PGROUP  GROUP   PROG
PROG    SEGMENT BYTE PUBLIC 'PROG'
        PUBLIC  GETTM
        ASSUME  CS:PGROUP
GETTM   PROC    NEAR
        PUSH    BP              ;SAVE BP
        MOV     BP,SP

        POP     BP
        RET
GETTM   ENDP
PROG    ENDS
        END
