; 8086 assembly version of the BYTE magazine October 1982 matrix multiply
; (Jerry Pournelle). Integer version: A, B, and C hold the same small whole
; numbers as the floating point versions, and the sum is 465880.
;
; equivalent to:
;     for i := 1 to 20 do for j := 1 to 20 do A[ i, j ] := i + j;
;     for i := 1 to 20 do for j := 1 to 20 do B[ i, j ] := ( i + j ) div j;
;     for i := 1 to 20 do for j := 1 to 20 do C[ i, j ] := 0;
;     for i := 1 to 20 do for j := 1 to 20 do for k := 1 to 20 do
;         C[ i, j ] := C[ i, j ] + A[ i, k ] * B[ k, j ];
;     summ := sum of C[ i, j ]
;
; A and B fit in bytes (A <= 40, B <= 21) and C in words. The loops run
; i, k, j so that A[ i, k ] is fixed in the inner loop; for each one a
; table of A[ i, k ] * 0..21 words is built with additions (much cheaper
; than the 8086's mul), and the inner loop adds table[ B[ k, j ] ] to
; C[ i, j ]. B is stored doubled so its values index the word table
; directly. The sum is 32 bits.

dosseg
.model small
.stack 100h

dos_print_string   equ   9h
dos_exit           equ   4ch

n      equ 20
bmax   equ 21                     ; largest value in B

mm_dataseg segment para public 'data'
    assume ds: mm_dataseg

    amat          db      n * n dup( ? )
    bmat          db      n * n dup( ? )      ; 2 * B[ i, j ]
    cmat          dw      n * n dup( ? )
    ptable        dw      bmax + 1 dup( ? )  ; A[ i, k ] * 0 .. bmax
    summsg        db      'summ is : $'
    digits        db      10 dup( ? )
    digitsend     db      13, 10, '$'
mm_dataseg ends

.code

start:
        mov      ax, mm_dataseg
        mov      ds, ax
        mov      es, ax
        cld

        ; A[ i, j ] := i + j  (0-based: i + j + 2)

        mov      di, offset amat
        xor      bx, bx                    ; bl = i
  fai:  xor      cx, cx                    ; cl = j
  faj:  mov      al, bl
        add      al, cl
        add      al, 2
        stosb
        inc      cl
        cmp      cl, n
        jne      faj
        inc      bl
        cmp      bl, n
        jne      fai

        ; B[ i, j ] := ( i + j ) div j, stored doubled  (0-based: ( i + j + 2 ) div ( j + 1 ))

        mov      di, offset bmat
        xor      bx, bx                    ; bl = i
  fbi:  xor      cx, cx                    ; cl = j
  fbj:  mov      al, bl
        add      al, cl
        add      al, 2
        xor      ah, ah
        mov      dl, cl
        inc      dl
        div      dl                        ; al = quotient
        shl      al, 1
        stosb
        inc      cl
        cmp      cl, n
        jne      fbj
        inc      bl
        cmp      bl, n
        jne      fbi

        ; C := 0

        mov      di, offset cmat
        mov      cx, n * n
        xor      ax, ax
        rep stosw

        ; multiply

        mov      si, offset amat           ; A[ i, k ]
        mov      bp, offset cmat           ; C[ i, 0 ]
        mov      dh, n                     ; i count
  mi:   mov      dl, n                     ; k count
        mov      bx, offset bmat           ; B[ k, 0 ]
  mk:   lodsb                              ; ax = A[ i, k ]
        xor      ah, ah

        ; table of A[ i, k ] * 0 .. bmax

        push     dx
        mov      dx, ax
        xor      ax, ax
        mov      di, offset ptable
        mov      cx, bmax + 1
  mt:   stosw
        add      ax, dx
        loop     mt
        pop      dx

        ; C[ i, j ] := C[ i, j ] + table[ B[ k, j ] ] for j := 1 to 20

        push     si
        mov      si, bx
        mov      di, bp
        mov      cx, n
  mj:   lodsb                              ; 2 * B[ k, j ]
        mov      bl, al
        xor      bh, bh
        mov      ax, ptable[ bx ]
        add      [ di ], ax
        inc      di
        inc      di
        loop     mj
        mov      bx, si                    ; B[ k + 1, 0 ]
        pop      si

        dec      dl
        jnz      mk
        add      bp, n * 2                 ; C[ i + 1, 0 ]
        dec      dh
        jnz      mi

        ; summ := sum of C, 32 bits in dx:ax

        mov      si, offset cmat
        mov      cx, n * n
        xor      ax, ax
        xor      dx, dx
  sl:   add      ax, [ si ]
        adc      dx, 0
        inc      si
        inc      si
        loop     sl

        ; print it: divide dx:ax by 10 repeatedly, storing digits backwards

        mov      di, offset digitsend
        mov      bx, 10
  pd:   mov      cx, ax                    ; low word
        mov      ax, dx
        xor      dx, dx
        div      bx                        ; high word / 10
        xchg     ax, cx                    ; cx = high quotient, ax = low word
        div      bx                        ; (remainder:low) / 10
        dec      di
        add      dl, '0'
        mov      [ di ], dl
        mov      dx, cx                    ; dx:ax = quotient
        mov      cx, ax
        or       cx, dx
        jnz      pd

        push     di
        mov      dx, offset summsg
        mov      ah, dos_print_string
        int      21h
        pop      dx
        mov      ah, dos_print_string
        int      21h

        mov      ax, dos_exit shl 8
        int      21h

end start
