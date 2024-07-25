; 8086 assembly to compute e to n digits.
; build with masm 5.0 like this:
;    ntvdm -h masm /Zi /Zd /z /l %1,,,;
;    ntvdm -h link %1,,%1,,nul.def
; replicate this:
;        #define TRUE 1
;        #define FALSE 0
;        #define SIZE 8190
;        
;        char flags[SIZE+1];
;        
;        int main()
;                {
;                int i,k;
;                int prime,count,iter;
;        
;                for (iter = 1; iter <= 10; iter++) {    /* do program 10 times */
;                        count = 0;                      /* initialize prime counter */
;                        for (i = 0; i <= SIZE; i++)     /* set all flags true */
;                                flags[i] = TRUE;
;                        for (i = 0; i <= SIZE; i++) {
;                                if (flags[i]) {         /* found a prime */
;                                        prime = i + i + 3;      /* twice index + 3 */
;                                        for (k = i + prime; k <= SIZE; k += prime)
;                                                flags[k] = FALSE;       /* kill all multiples */
;                                        count++;                /* primes found */
;                                        }
;                                }
;                        }
;                printf("%d primes.\n",count);           /*primes found in 10th pass */
;                return 0;
;                }
;

dosseg
.model small
.stack 100h

; DOS constants

dos_write_char     equ   2h
dos_realtime_clock equ   1ah
dos_exit           equ   4ch

; app constants

true       equ 1
false      equ 0
loops      equ 10
arraysize  equ 8190

sieve_dataseg segment para public 'sievedata'
    assume ds: sieve_dataseg

    crlfmsg       db      13,10,0
    primesmsg     db      ' primes.',13,10,0
    ITER          dw      0
    PKFLAGS       dd      0
    
    align 16
    flags         db      arraysize + 1 dup( ? )
    afterflags    db      0
sieve_dataseg ends

.code

start:
        mov      ax, sieve_dataseg
        mov      ds, ax

  iteragain:                        ; for ( iter = 1; iter <= 10; iter++ )
        xor      dx, dx             ; count of primes found

        ; set all array entries to true:  for (i = 0; i <= SIZE; i++) flags[i] = TRUE;

        mov      ah, true
        mov      al, true
        mov      di, offset flags
        mov      cx, ( arraysize + 2 ) / 2 ; 4096
        push     ds
        pop      es
        cld
        rep stosw

        ; iterate through array entries and count primes

        mov      di, offset afterFlags   ; handy place for this constant
        xor      cx, cx             ; handy place for 0
        xor      bx, bx             ; bx is "i" in the outer for loop

  nextprime:                        ; for (i = 0; i <= SIZE; i++) {
        cmp      byte ptr [ flags + bx ], 0
        jz       flagisoff

        mov      ax, 3              ; ax == prime = i + i + 3
        add      ax, bx
        add      ax, bx
        mov      si, offset flags
        add      si, bx             ; for (k = i + prime; k <= SIZE; k += prime)

        add      si, ax             ; k += prime
        cmp      si, di             ; is si >= offset afterFlags? (i.e. k <= size)
        jge      inccount           ; redundant check to the one in the loop below but it saves a jump instruction in the loop

  kloop:                        
        mov      [ si ], cl         ; flags[ k ] = false. use cl for 0 because it's faster than an immediate
        add      si, ax             ; k += prime
        cmp      si, di             ; is si >= offset afterFlags? (i.e. k <= size)
        jl       kloop

  inccount:
        inc      dx                 ; count++

  flagisoff:                        ; check if outer loop is done
        inc      bx
        cmp      bx, arraysize + 1
        jnz      nextprime

  checknextiter:                    ; are we done iterating loops times?
        inc      word ptr [ ITER ]
        cmp      word ptr [ ITER ], loops
        jnz      iteragain

        mov      ax, dx
        call     printint

        call     printcrlf
        mov      dx, offset primesmsg
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
