; utility functions for calling into DOS from Microsoft Pascal v1 through v4
;
;  function dostime : word; External;
;  var startTicks: word;
;  startTicks := dostime;
;
;  function getpsp : word; External;
;  var psp : word;
;  psp := getpsp;
;
;  function pspbyte( offset : word ) : integer; External;
;  var result : integer;
;  result := pspbyte( 80 ); { get command tail length }
;

.model large

code segment
assume cs:code

; returns a count of hundredths of a second in ax
; only uses hs, seconds, and the low digit of minutes since that's all that fits in two bytes
;    54000 = 9 * 60 * 100
; +   5900 = 59 * 100
; +     99
; --------
;    59999

public getticks
getticks PROC FAR
    push bx
    push cx
    push dx
    push di
    push si

    mov ah, 2ch
    int 21h
    push dx
    mov ah, 0
    mov al, dh
    mov bx, 100
    mul bx
    pop dx
    mov dh, 0
    add ax, dx

    push ax
    mov ax, cx
    and ax, 0ffh
    mov cx, 10
    mov dx, 0
    div cx
    mov ax, dx
    mov cx, 6000
    mul cx
    pop bx
    add ax, bx

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    ret
getticks ENDP

public getpsp
getpsp PROC FAR
    push bx
    push cx
    push dx
    push di
    push si

    mov ah, 062h
    int 21h
    mov ax, bx

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    ret
getpsp ENDP

public pspbyte
pspbyte PROC FAR
    push bx
    push cx
    push dx
    push di
    push si
    push es
    push bp

    mov bp, sp
    mov ah, 062h
    int 21h
    mov es, bx

    ; the argument is here. 7 pushes above + 2 for the return address = 9 * 2 = 18.

    mov bx, word ptr[ bp + 18 ]   
    xor ah, ah
    mov  al, byte ptr es: [ bx ]

    pop bp
    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    ret
pspbyte ENDP

code ends               
end

