; 8086 assembly to compute e to n digits.
; When DIGITS is 200, the first 192 digits are displayed:
; 271828182845904523536028747135266249775724709369995957496696762772407663035354759457138217852516642742746639193200305992181741359662904357290033429526059563073813232862794349076323382988075319
;
; equivalent to:
;     program e;
;     const
;        DIGITS = 200;
;     type
;         arrayType = array[ 0..DIGITS ] of integer;
;     var 
;         high, n, x : integer;
;         a : arrayType;
;     begin
;         high := DIGITS;
;         x := 0;
;         n := high - 1;
;         while n > 0 do begin
;             a[ n ] := 1;
;             n := n - 1;
;         end;
;     
;         a[ 1 ] := 2;
;         a[ 0 ] := 0;
;     
;         while high > 9 do begin
;             high := high - 1;
;             n := high;
;             while 0 <> n do begin
;                 a[ n ] := x MOD n;
;                 x := 10 * a[ n - 1 ] + x DIV n;
;                 n := n - 1;
;             end;
;     
;             Write( x );
;         end;
;     
;         writeln; writeln( 'done' );
;     end.

; build with masm 5.0 like this:
;    ntvdm -h masm /Zi /Zd /z /l %1,,,;
;    ntvdm -h link %1,,%1,,nul.def
;

dosseg
.model small
.stack 100h

; DOS constants

dos_write_char     equ   2h
dos_realtime_clock equ   1ah
dos_exit           equ   4ch

; app constants

true   equ 1
false  equ 0
digits equ 200

dataseg segment para public 'data'
    assume ds: dataseg

    crlfmsg       db      13,10,0
    donemsg       db      'done',13,10,0
    
    align 16
    array         db      digits dup( ? )
dataseg ends

.code

start:
        mov      ax, dataseg
        mov      ds, ax

        ; why is the loop backwards? no idea.
        ; while n > 0 do begin
        ;     a[ n ] := 1;
        ;     n := n - 1;
        ; end;

        ; register bh is n. di is a[]. bl is a constant 1

        mov      bl, 1
        mov      bh, digits - 1
        mov      di, offset array + digits - 1

  ainit:
        mov      byte ptr [ di ], bl
        dec      di
        dec      bh
        jnz      ainit

        ; a[ 1 ] := 2;
        ; a[ 0 ] := 0;

        mov      di, offset array
        mov      byte ptr[ di + 1 ], 2
        mov      byte ptr[ di ], 0

        ; register bx is n. register si is high. register di is x at the start of each inner loop

        mov      si, DIGITS

  outerloop:
        dec      si               ; high := high - 1;
        mov      bx, si           ; n := high;
        xor      di, di           ; x := 0;

  innerloop:
        xor      dx, dx
        mov      ax, di
        div      bx               ; computes both x MOD n and x DIV n. dx has remainder, ax has result
        mov      di, ax           ; save the result of the division in di. ah is guaranteed to be 0.

        mov      byte ptr[ offset array + bx ], dl  ; a[ n ] := x MOD n;

        mov      al, byte ptr [ offset array + bx - 1 ] ; load a[ n - 1 ] into al
        mov      cx, 10
        mul      cx
        add      di, ax           ; x := 10 * a[ n - 1 ] + x DIV n;

        dec      bx               ; n := n - 1;
        jnz      innerloop        ; if n isn't 0 then loop again

        mov      ax, di
        call     printint         ; show the next digit(s) of e
        
        cmp      si, 9            ; while high > 9 do begin (re-written as a do until loop)
        jnz      outerloop

        call     printcrlf
        mov      dx, offset donemsg
        call     printstring

        mov      al, 0
        mov      ah, dos_exit
        int      21h
;start endp

; print the integer in ax

printint proc near
        test     ah, 80h
        push     ax
        push     bx
        push     cx
        push     dx
        push     di
        push     si

        jz       _prpositive
        neg      ax                 ; just one instruction for complement + 1
        push     ax
        mov      dx, '-'
        mov      ah, dos_write_char
        int      21h
        pop      ax
  _prpositive:
        xor      cx, cx
        xor      dx, dx
        cmp      ax, 0
        je       _przero
  _prlabel1:
        cmp      ax, 0
        je       _prprint1     
        mov      bx, 10       
        div      bx                 
        push     dx             
        inc      cx             
        xor      dx, dx
        jmp      _prlabel1
  _prprint1:
        cmp      cx, 0
        je       _prexit
        pop      dx
        add      dx, 48
        mov      ah, dos_write_char
        int      21h
        dec      cx
        jmp      _prprint1
  _przero:
        mov      dx, '0'
        mov      ah, dos_write_char
        int      21h
  _prexit:
        pop      si
        pop      di
        pop      dx
        pop      cx
        pop      bx
        pop      ax
        ret
printint endp

printcrlf proc near
        push     ax
        push     bx
        push     cx
        push     dx
        push     di
        push     si
        mov      dx, offset crlfmsg
        call     printstring
        pop      si
        pop      di
        pop      dx
        pop      cx
        pop      bx
        pop      ax
        ret
printcrlf endp

printstring proc near
        push     ax
        push     bx
        push     cx
        push     dx
        push     di
        push     si

        mov      di, dx

  _psnext:
        mov      al, byte ptr [ di ]
        cmp      al, 0
        je       _psdone
        mov      dx, ax
        mov      ah, dos_write_char
        int      21h

        inc      di
        jmp      _psnext

  _psdone:
        pop      si
        pop      di
        pop      dx
        pop      cx
        pop      bx
        pop      ax
        ret
printstring endp

end
