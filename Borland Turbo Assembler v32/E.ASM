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

e_dataseg segment para public 'data'
    assume ds: e_dataseg

    array         db      digits dup( ? ) ; at offset 0 so di is n in the inner loop
    crlfmsg       db      13,10,0
    donemsg       db      'done',13,10,0
    highval       dw      digits
e_dataseg ends

.code

start:
        mov      ax, e_dataseg
        mov      ds, ax
        mov      es, ax

        ; while n > 0 do begin
        ;     a[ n ] := 1;
        ;     n := n - 1;
        ; end;

        mov      ax, 0101h
        mov      di, offset array
        mov      cx, ( digits / 2 )
        cld
        rep stosw

        ; a[ 1 ] := 2;
        ; a[ 0 ] := 0;

        mov      di, offset array
        mov      byte ptr[ di + 1 ], 2
        mov      byte ptr[ di ], 0

        ; in the inner loop ax is x, bx is n - 1, cx is a multiple of n, dl collects the quotient,
        ; bp is a mask, di points to a[ n ] (and is n) and si points to a[ n - 1 ]. dh is always 0.
        ; There is no div: for n >= 2, x < 10n because a[ n - 1 ] < n - 1 and x DIV ( n + 1 ) < 10,
        ; so the quotient and remainder come from 4 branchless subtract steps (60 cycles vs. 95 for div).
        ; n = 1 is handled after the loop: x MOD 1 is 0 and x DIV 1 is x.

        xor      dx, dx

  outerloop:
        mov      di, [ highval ]
        dec      di               ; high := high - 1;
        mov      [ highval ], di  ; n := high;  di is also n since the array is at offset 0
        lea      si, [ di - 1 ]
        mov      bx, si           ; bx counts down n - 1 for the iterations for n = high down to 2
        xor      ax, ax           ; x := 0;
        std                       ; stosb and lodsb walk down the array

  innerloop:
        mov      cx, di           ; x < 10n, so the quotient fits in 4 bits. compute it from 8n down to n
        shl      cx, 1
        shl      cx, 1
        shl      cx, 1
        mov      dl, dh           ; dh is always 0
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        shr      cx, 1
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        shr      cx, 1
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        shr      cx, 1
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        stosb                     ; a[ n ] := x MOD n;  the remainder is in al and ah is 0
        lodsb                     ; load a[ n - 1 ]
        shl      ax, 1            ; x := 10 * a[ n - 1 ] + x DIV n;
        mov      cx, ax
        shl      ax, 1
        shl      ax, 1
        add      ax, cx
        add      ax, 15           ; dl has 15 - x DIV n
        sub      ax, dx
        dec      bx               ; n := n - 1;
        jz       innerdone        ; if n is 1 the loop is done
        mov      cx, di           ; x < 10n, so the quotient fits in 4 bits. compute it from 8n down to n
        shl      cx, 1
        shl      cx, 1
        shl      cx, 1
        mov      dl, dh           ; dh is always 0
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        shr      cx, 1
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        shr      cx, 1
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        shr      cx, 1
        sub      ax, cx           ; try to subtract this multiple of n
        sbb      bp, bp           ; bp = -1 if it didn't fit, else 0
        adc      dl, dl           ; collect the inverted quotient bit
        and      bp, cx
        add      ax, bp           ; add it back if it didn't fit
        stosb                     ; a[ n ] := x MOD n;  the remainder is in al and ah is 0
        lodsb                     ; load a[ n - 1 ]
        shl      ax, 1            ; x := 10 * a[ n - 1 ] + x DIV n;
        mov      cx, ax
        shl      ax, 1
        shl      ax, 1
        add      ax, cx
        add      ax, 15           ; dl has 15 - x DIV n
        sub      ax, dx
        dec      bx               ; n := n - 1;
        jz       innerdone        ; if n is 1 the loop is done
        jmp      innerloop        ; too far for a short conditional jump

  innerdone:
        cld
        mov      byte ptr [ array + 1 ], 0 ; a[ 1 ] := x MOD 1;  x := 10 * a[ 0 ] + x DIV 1 is just x
        call     printint         ; show the next digit(s) of e

        cmp      word ptr [ highval ], 9 ; while high > 9 do begin (re-written as a do until loop)
        jz       alldone
        jmp      outerloop

  alldone:
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
