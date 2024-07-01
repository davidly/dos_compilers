;
;   Copyright (c) Mix Software 1988
;
; ------------------------------------------------------------
;
            idt     sound
            def     sound
;
;  sound(int freq, int duration)
;

ROMDATA     EQU     40H
TIMER_LOW   EQU     6CH
TIMER       EQU     40H
PORTB       EQU     61H
;
freq        EQU     6
duration    EQU     freq+2
;
sound       push  bp
            mov   bp,sp
            mov   cx,[bp][%duration]
            mov   bx,[bp][%freq]
            cmp   bx,0
            je    LENGTH
            mov   ax,13532
            mov   dx,18
            div   bx
            call  BEEPER
LENGTH      jcxz  EXIT
            mov   bx,ROMDATA
            mov   ds,bx
            mov   bx,[TIMER_LOW]
TICKLOOP    cmp   bx,[TIMER_LOW]
            je    TICKLOOP
            inc   bx
            loop  TICKLOOP
EXIT        xor   ax,ax
            call  BEEPER
            mov   ax,ss
            mov   ds,ax
            pop   bp
            retfar
;
BEEPER      push    ax
            in      al,PORTB
            and     al,0FCH       ;mask off lower 3 bits
            out     PORTB,al
            mov     al,0B6H
            out     TIMER+3,al
            pop     ax
            cmp     ax,0
            je      DONE
            out     TIMER+2,al
            mov     al,ah
            out     TIMER+2,al
            in      al,PORTB
            or      al,3
            out     PORTB,al
DONE        ret
;
            END
