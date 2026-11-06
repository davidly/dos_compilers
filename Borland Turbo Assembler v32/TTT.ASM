; 8086 version of app that proves you can't win at tic-tac-toe
; build with masm 5.0 like this:
;    ntvdm -h masm /Zi /Zd /z /l %1,,,;
;    ntvdm -h link %1,,%1,,nul.def
;
; board position:
;   0 1 2
;   3 4 5
;   6 7 8
;
; The board is kept in registers as bitmasks where bit n is board position n:
;   bx  the complement of the X positions. X has a winning line L when ( bx AND L ) is 0
;   di  the empty positions. O has a winning line L when ( ( di OR NOT bx ) AND L ) is 0
; Each position has its own entry point for min (after X moved there) and max (after O moved
; there) that checks just the lines through that position for a win, then jumps to the shared
; loop. The loops over the 9 possible moves are unrolled.
;
; other registers:
;   cl  alpha. changed by max, so max saves and restores cx
;   ch  max's value
;   dl  beta. changed by min, so min saves and restores dx
;   dh  min's value
;   si  global move count
;   bp  the bit for the move being made or unmade
;   al  score returned by min and max

dosseg
.model small
.stack 100h

; DOS constants

dos_write_char     equ   2h
dos_realtime_clock equ   1ah
dos_exit           equ   4ch

default_iterations  equ     1    ; # of times to run (max 32767)
max_score           equ     9    ; maximum score
min_score           equ     2    ; minimum score
win_score           equ     6    ; winning score
tie_score           equ     5    ; tie score
lose_score          equ     4    ; losing score

dataseg segment para public 'data'
    assume ds: dataseg

    crlfmsg       db      13,10,0
    secondsmsg    db      ' seconds',13,10,0
    iterationsmsg db      'iterations: ',0
    zeroitersmsg  db      'iterations argument must be 1..32767',13,10,0
    movesmsg      db      'moves: ',0
    commaspmsg    db      ', ',0

    align 2
    iters         dw      0        ; iterations of running the app so far
    totaliters    dw      0        ; # of iterations to run in total

    align 4
    scratchpad    dd      0
    starttime     dd      0
    result        dd      0
dataseg ends

; MASM wants one blank-separated list, so these are the winning lines as bitmasks

row0    equ     007h
row1    equ     038h
row2    equ     1c0h
col0    equ     049h
col1    equ     092h
col2    equ     124h
diag0   equ     111h
diag2   equ     054h


; X makes the first move at position sq, then O's best reply is found

runmm macro sq
        mov       bx, not ( 1 shl sq )     ; X is only at sq
        mov       di, 1ffh xor ( 1 shl sq ) ; everything else is empty
        mov       cl, min_score             ; alpha
        mov       dl, max_score             ; beta
        call      min_&sq
endm

; min is called after X moved at sq. If X won, return win_score. Otherwise find O's best move.

minentry macro sq, l1, l2, l3, l4
        local    xwins
min_&sq:
        inc      si                 ; increment global move count
        irp      line, <l1, l2, l3, l4>
        ifnb     <line>
        test     bx, line
        jz       xwins
        endif
        endm
        jmp      min_loop
  xwins:
        mov      al, win_score
        ret
endm

; max is called after O moved at sq. If O won, return lose_score. Otherwise find X's best move.

maxentry macro sq, l1, l2, l3, l4
        local    owins
max_&sq:
        inc      si                 ; increment global move count
        mov      ax, bx
        not      ax
        or       ax, di             ; ax has a 0 bit for each O
        irp      line, <l1, l2, l3, l4>
        ifnb     <line>
        test     ax, line
        jz       owins
        endif
        endm
        jmp      max_loop
  owins:
        mov      al, lose_score
        ret
endm

; try O at position sq if it's empty. retlabel pops dx and returns al.
; if stublabel is given, a retlabel stub is placed after this move's code.

minmove macro sq, retlabel, stublabel
        local    next
        test     di, 1 shl sq
        jz       next
        mov      bp, 1 shl sq
        xor      di, bp             ; O moves at sq
        call     max_&sq
        mov      bp, 1 shl sq
        xor      di, bp             ; restore the board

        cmp      al, lose_score     ; can't do better than losing
        je       retlabel
        cmp      al, dh             ; compare score with value
        jge      next
        cmp      al, cl             ; compare score with alpha
        jle      retlabel           ; alpha pruning
        mov      dh, al             ; update value with score
        cmp      al, dl             ; compare value with beta
        jge      next
        mov      dl, al             ; update beta with value
        ifnb     <stublabel>
        jmp      short next
  stublabel:
        pop      dx
        ret
        endif
  next:
endm

; try X at position sq if it's empty. retlabel pops cx and returns al.

maxmove macro sq, retlabel, stublabel
        local    next
        test     di, 1 shl sq
        jz       next
        mov      bp, 1 shl sq
        xor      di, bp             ; X moves at sq
        xor      bx, bp
        call     min_&sq
        mov      bp, 1 shl sq
        xor      di, bp             ; restore the board
        xor      bx, bp

        cmp      al, win_score      ; can't do better than winning
        je       retlabel
        cmp      al, ch             ; compare score with value
        jle      next
        cmp      al, dl             ; compare score with beta
        jge      retlabel           ; beta pruning
        mov      ch, al             ; update value with score
        cmp      al, cl             ; compare value with alpha
        jle      next
        mov      cl, al             ; update alpha with value
        ifnb     <stublabel>
        jmp      short next
  stublabel:
        pop      cx
        ret
        endif
  next:
endm

.code

start:
        mov      ax, dataseg
        mov      ds, ax
        mov      di, 0
        mov      [ di + totaliters ], default_iterations
        xor      ax, ax
        cmp      al, byte ptr es: [ di + 128 ]   ; command tail length is 128 bytes into the PSP
        jz       done_with_arguments

        mov      cx, 129            ; string is guaranteed to be 0x0d terminated by DOS
        push     ds
        mov      ax, es             ; temporarily make ds point to the psp
        mov      ds, ax
        call     atou               ; pointer to string in cx, unsigned integer result in ax
        pop      ds
        mov      [ di + totaliters ], ax
        cmp      ax, 0
        jnz      done_with_arguments

        mov      dx, offset zeroitersmsg   ; the argument isn't valid; show error and exit
        call     printstring

        mov      al, 1
        mov      ah, dos_exit
        int      21h

done_with_arguments:
        xor      ax, ax
        int      dos_realtime_clock
        mov      word ptr [ starttime ], dx
        mov      word ptr [ starttime + 2 ], cx

again:
        xor      si, si             ; zero the global move count so it doesn't overflow

        ; run for the 3 unique first moves

        runmm    0
        runmm    1
        runmm    4

        inc      word ptr [ iters ]
        mov      ax, [ totaliters ]
        cmp      ax, [ iters ]
        jne      again

        push     si                 ; save the global move count for later

        call     printelap
        mov      dx, offset secondsmsg
        call     printstring

        mov      dx, offset movesmsg
        call     printstring

        pop      ax                 ; restore the global move count for printing
        call     printint
        call     printcrlf

        mov      dx, offset iterationsmsg
        call     printstring

        mov      ax, [iters]
        call     printint
        call     printcrlf

        mov      al, 0
        mov      ah, dos_exit
        int      21h
;start endp

minmax proc near
        minentry 0, row0, col0, diag0
        minentry 1, row0, col1
        minentry 2, row0, col2, diag2
        minentry 3, row1, col0
        minentry 4, row1, col1, diag0, diag2
        minentry 5, row1, col2
        minentry 6, row2, col0, diag2
        minentry 7, row2, col1
        minentry 8, row2, col2, diag0

  min_tie:
        mov      al, tie_score
        ret

  min_loop:
        test     di, di             ; if the board is full it's a tie
        jz       min_tie
        push     dx                 ; save caller's beta and value
        mov      dh, max_score      ; dh has value
        minmove  0, min_ret_a
        minmove  1, min_ret_a, min_ret_a
        minmove  2, min_ret_a
        minmove  3, min_ret_b
        minmove  4, min_ret_b, min_ret_b
        minmove  5, min_ret_b
        minmove  6, min_ret_c
        minmove  7, min_ret_c
        minmove  8, min_ret_c
        mov      al, dh             ; return value
  min_ret_c:
        pop      dx
        ret

        maxentry 0, row0, col0, diag0
        maxentry 1, row0, col1
        maxentry 2, row0, col2, diag2
        maxentry 3, row1, col0
        maxentry 4, row1, col1, diag0, diag2
        maxentry 5, row1, col2
        maxentry 6, row2, col0, diag2
        maxentry 7, row2, col1
        maxentry 8, row2, col2, diag0

  max_loop:
        push     cx                 ; save caller's alpha and value
        mov      ch, min_score      ; ch has value
        maxmove  0, max_ret_a
        maxmove  1, max_ret_a, max_ret_a
        maxmove  2, max_ret_a
        maxmove  3, max_ret_b
        maxmove  4, max_ret_b, max_ret_b
        maxmove  5, max_ret_b
        maxmove  6, max_ret_c
        maxmove  7, max_ret_c
        maxmove  8, max_ret_c
        mov      al, ch             ; return value
  max_ret_c:
        pop      cx
        ret
minmax endp

atou proc near ; string input in cx. unsigned 16-bit integer result in ax
        push    di
        push    bx
        push    cx
        mov     bx, 0               ; running total is in bx
        mov     di, cx
        mov     cx, 10

  _skipspaces:
        cmp     byte ptr [di ], ' '
        jne     _atouNext
        inc     di
        jmp     _skipspaces

  _atouNext:
        cmp     byte ptr [ di ], '0'     ; if not a digit, we're done. Works with null and 0x0d terminated strings
        jb      _atouDone
        cmp     byte ptr [ di ], '9' + 1
        jge     _atouDone

        mov     ax, bx
        mul     cx
        mov     bx, ax

        xor     ah, ah
        mov     al, byte ptr [ di ]
        sub     ax, '0'
        add     bx, ax
        inc     di
        jmp     _atouNext

  _atouDone:
        mov     ax, bx
        pop     cx
        pop     bx
        pop     di
        ret
atou endp

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

printcommasp proc near
        push     ax
        push     bx
        push     cx
        push     dx
        push     di
        push     si
        mov      dx, offset commaspmsg
        call     printstring
        pop      si
        pop      di
        pop      dx
        pop      cx
        pop      bx
        pop      ax
        ret
printcommasp endp

prperiod proc near
        push     ax
        push     bx
        push     cx
        push     dx
        push     di
        push     si
        mov      dx, '.'
        mov      ah, dos_write_char
        int      21h
        pop      si
        pop      di
        pop      dx
        pop      cx
        pop      bx
        pop      ax
        ret
prperiod endp

printelap proc near
        push     ax
        push     bx
        push     cx
        push     dx
        push     di
        push     si
        xor      ax, ax
        int      dos_realtime_clock
        mov      word ptr [ scratchpad ], dx
        mov      word ptr [ scratchpad + 2 ], cx
        mov      dl, 0
        mov      ax, word ptr [ scratchpad ]
        mov      bx, word ptr [ starttime ]
        sub      ax, bx
        mov      word ptr [ result ], ax
        mov      ax, word ptr [ scratchpad + 2 ]
        mov      bx, word ptr [ starttime + 2 ]
        sbb      ax, bx
        mov      word ptr [ result + 2 ], ax
        mov      dx, word ptr [ result + 2 ]
        mov      ax, word ptr [ result ]
        mov      bx, 10000
        mul      bx
        mov      bx, 18206
        div      bx
        xor      dx, dx
        mov      bx, 10
        div      bx
        push     dx
        call     printint
        call     prperiod
        pop      ax
        call     printint
        pop      si
        pop      di
        pop      dx
        pop      cx
        pop      bx
        pop      ax
        ret
printelap endp

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
