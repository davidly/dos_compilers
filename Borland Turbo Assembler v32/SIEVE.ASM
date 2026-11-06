; 8086 assembly to find primes like BYTE's benchmark
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
lastmarker equ 2729         ; i + prime > SIZE for larger i, so later primes mark nothing

sieve_dataseg segment para public 'sievedata'
    assume ds: sieve_dataseg

    ; flags must be at offset 0 so a flag's offset is its index i and prime - 1 is just 2 * ( i + 1 ).
    ; allocate 8192 bytes even though 8191 will actually be used by the sieve algorithm
    flags         db      arraysize + 1 dup( ? )
    afterflags    db      0
    crlfmsg       db      13,10,0
    primesmsg     db      ' primes.',13,10,0
    ITER          dw      0
sieve_dataseg ends

.code

start:
        mov      ax, sieve_dataseg
        mov      ds, ax
        mov      es, ax
        cld                         ; good for the duration of this app

  iteragain:                        ; for ( iter = 1; iter <= 10; iter++ )

        ; set all array entries to true:  for (i = 0; i <= SIZE; i++) flags[i] = TRUE;

        mov      ax, 0101h
        xor      di, di             ; offset flags
        mov      cx, ( arraysize + 2 ) / 2 ; 4096
        rep stosw

        xor      ax, ax             ; al is 0 for both scanning and marking
        mov      bp, ax             ; bp is the count of primes found. count = 0;
        mov      dx, ax             ; dx is the offset of the next flag to examine
        mov      si, offset afterflags ; end of the flags array

        ; iterate through the array entries that can mark multiples

  nextprime:                        ; for (i = 0; i <= SIZE; i++) {
        mov      di, dx
        mov      cx, lastmarker + 1
        sub      cx, di             ; cx is the count of array entries to search (at most)
        repe     scasb              ; scan the array for a non-zero flag
        je       countrest          ; if one wasn't found, count the flags that can't mark anything

        inc      bp                 ; count++
        mov      dx, di             ; continue the scan after this prime
        mov      bx, di
        shl      bx, 1              ; bx = prime - 1 = 2 * ( i + 1 ). stosb adds the other 1
        add      di, bx             ; di = offset of flags[ i + prime ], which is <= SIZE
        mov      cx, arraysize
        sub      cx, bx             ; cx = afterflags - prime. both of a pair of marks fit if di < cx
        jmp      short markcheck

  markloop:                         ; for (k = i + prime; k <= SIZE; k += prime) flags[ k ] = false;
        stosb
        add      di, bx
        stosb
        add      di, bx
        cmp      di, cx
        jae      marktail
        stosb
        add      di, bx
        stosb
        add      di, bx
        cmp      di, cx
        jae      marktail
        stosb
        add      di, bx
        stosb
        add      di, bx
        cmp      di, cx
        jae      marktail
        stosb
        add      di, bx
        stosb
        add      di, bx
  markcheck:
        cmp      di, cx
        jb       markloop

  marktail:                         ; at most one more multiple fits
        cmp      di, si
        jae      nextprime
        stosb
        jmp      nextprime

  countrest:                        ; add up the remaining flags, which are each 0 or 1
        mov      si, lastmarker + 1 ; even, so words are aligned. 13 * 21 * 10 words end at SIZE - 1
        mov      dx, 13

  countchunk:                       ; sum at most 210 words so neither byte of the total overflows
        xor      bx, bx
        mov      cx, 21

  countloop:
        rept     10
        lodsw
        add      bx, ax
        endm
        loop     countloop

        xor      ah, ah
        mov      al, bh
        add      bp, ax
        mov      bh, ah
        add      bp, bx
        dec      dx
        jnz      countchunk

        mov      al, [ si ]         ; flags[ SIZE ]
        add      bp, ax

  checknextiter:                    ; are we done iterating loops times?
        inc      word ptr [ ITER ]
        cmp      word ptr [ ITER ], loops
        jz       showresult
        jmp      iteragain          ; really checking for 0..9, not 1..10

  showresult:
        mov      ax, bp
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
