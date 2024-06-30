; 8086 version of app that proves you can't win at tic-tac-toe
; build with masm 5.0 like this:
;    ntvdm -h masm /Zi /Zd /z /l %1,,,;
;    ntvdm -h link %1,,%1,,nul.def
;
; board position:
;   0 1 2
;   3 4 5
;   6 7 8

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
x_piece             equ     1    
o_piece             equ     2    
blank_piece         equ     0

; arguments to minmax relative to bp/sp
; space between locals and arguments:
; 0-1  2 or 4 bytes for return pc if minmax is near or far (it's near here)
; 2-3  2 bytes to save BP

alpha_offset   equ   4
beta_offset    equ   6

dataseg segment para public 'data'
    assume ds: dataseg

    crlfmsg       db      13,10,0
    secondsmsg    db      ' seconds',13,10,0
    iterationsmsg db      'iterations: ',0
    zeroitersmsg  db      'iterations argument must be 1..32767',13,10,0
    movesmsg      db      'moves: ',0
    commaspmsg    db      ', ',0
    
    align 16
    board         db      0,0,0,0,0,0,0,0,0
    
    align 2
    iters         dw      0        ; iterations of running the app so far
    totaliters    dw      0        ; # of iterations to run in total
    
    align 4
    scratchpad    dd      0
    starttime     dd      0
    result        dd      0
    
    align 2
    winprocs      dw      proc0, proc1, proc2, proc3, proc4, proc5, proc6, proc7, proc8
dataseg ends

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

        lea      bx, [ board ]      ; global board pointer
        xor      ax, ax             ; make sure ah is 0
        mov      dx, ax             ; make sure dh is 0

again:
        xor      si, si             ; zero the global move count so it doesn't overflow

        ; run for the 3 unique first moves

        mov      ax, 0
        call     runmm
        mov      ax, 1
        call     runmm
        mov      ax, 4
        call     runmm

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

runmm proc near
        ; make the first move
        mov       di, ax
        push      di
        mov       byte ptr [ bx + di ], x_piece

        ; alpha and beta passed on the stack
        ; current move in di
        ; current value in dl
        ; current depth in cx
        ; global move count in si
        ; global board pointer in bx
        ; always 0 in ah and dh

        xor       cx, cx            ; depth in cx
        mov       al, max_score     ; pushing constants didn't start until the 80186
        push      ax                ; beta
        mov       al, min_score
        push      ax                ; alpha

        call      minmax_min

        ; restore the board at the first move position

        pop       di
        mov       byte ptr [ bx + di ], blank_piece

        ret
runmm endp

minmax_max proc near
        inc      si                 ; increment global move count

        cmp      cl, 4
        jl       short _max_no_winner_check

        shl      di, 1
        mov      al, o_piece
        call     word ptr [ offset winprocs + di ]

        cmp      al, o_piece
        mov      al, lose_score
        je       short _max_just_return_al

  _max_no_winner_check:
        push     bp
        mov      bp, sp             ; set bp to the stack location

        push     dx                 ; save caller's value
        mov      dl, min_score      ; dx has value
        mov      di, -1             ; di has the move 0..8
        inc      cx                 ; increment global depth

  _max_loop:
        cmp      di, 8
        je       short _max_load_value_return
        inc      di

        cmp      byte ptr [ bx + di ], 0
        jnz      short _max_loop

        push     di
        mov      byte ptr [ bx + di ], x_piece

        push     [ bp + beta_offset ]
        push     [ bp + alpha_offset ]

        call     minmax_min

        pop      di
        mov      byte ptr [ bx + di ], 0

        cmp      al, win_score                       ; can't do better than winning
        je       short _max_restore_value

        cmp      ax, dx                              ; compare score with value
        jle      short _max_loop

        cmp      al, [ bp + beta_offset ]            ; compare value with beta
        jge      short _max_restore_value            ; beta pruning

        mov      dx, ax                              ; update value with score
        cmp      al, [ bp + alpha_offset ]           ; compare value with alpha
        jle      short _max_loop

        mov      [ bp + alpha_offset ], al           ; update alpha with value
        jmp      short _max_loop

  _max_load_value_return:
        mov      ax, dx

  _max_restore_value:
        dec      cx
        pop      dx                 ; restore caller's value
        pop      bp

  _max_just_return_al:
        ret      4                  ; cleanup stack space used for arguments
minmax_max endp

minmax_min proc near
        inc      si                 ; increment global move count

        cmp      cl, 4
        jl       short _min_no_winner_check

        shl      di, 1
        mov      al, x_piece
        call     word ptr [ offset winprocs + di ]

        cmp      al, x_piece
        mov      al, win_score
        je       short _min_just_return_al

        cmp      cl, 8
        mov      al, tie_score
        je       short _min_just_return_al

  _min_no_winner_check:
        push     bp
        mov      bp, sp             ; set bp to the stack location

        push     dx                 ; save caller's value
        mov      dl, max_score      ; dx has value
        mov      di, -1             ; di has the move 0..8 
        inc      cx                 ; increment global depth

  _min_loop:
        cmp      di, 8
        je       short _min_load_value_return
        inc      di

        cmp      byte ptr [ bx + di ], 0
        jne      short _min_loop

        push     di
        mov      byte ptr [ bx + di ], o_piece

        push     [ bp + beta_offset ]
        push     [ bp + alpha_offset ]

        call     minmax_max

        pop      di
        mov      byte ptr [ bx + di ], 0

        cmp      al, lose_score                      ; can't do better than losing
        je       short _min_restore_value

        cmp      al, dl                              ; compare score with value
        jge      short _min_loop

        cmp      al, [ bp + alpha_offset ]           ; compare value with alpha
        jle      short _min_restore_value            ; alpha pruning

        mov      dx, ax                              ; update value with score
        cmp      al, [ bp + beta_offset ]            ; compare value with beta
        jge      short _min_loop

        mov      [ bp + beta_offset ], al            ; update beta with value
        jmp      short _min_loop

  _min_load_value_return:
        mov      ax, dx

  _min_restore_value:
        dec      cx
        pop      dx                 ; restore caller's value
        pop      bp

  _min_just_return_al:
        ret      4                  ; cleanup stack space used for arguments
minmax_min endp

IFDEF WinnerProc

; winner is no longer used since function pointers with the most recent move in ax are much faster

winner proc near
        xor      al, al
        mov      al, [ bx ]
        cmp      al, 0
        je       _win_check_3

        cmp      al, [ bx + 1 ]
        jne      _win_check_0_b
        cmp      al, [ bx + 2 ]
        jne      _win_check_0_b
        ret

  _win_check_0_b:
        cmp      al, [ bx + 3 ]
        jne      _win_check_3
        cmp      al, [ bx + 6 ]
        jne      _win_check_3
        ret

  _win_check_3:
        mov      al, [ bx + 3 ]
        cmp      al, 0
        je       _win_check_6

        cmp      al, [ bx + 4 ]
        jne      _win_check_6
        cmp      al, [ bx + 5 ]
        jne      _win_check_6
        ret

  _win_check_6:
        mov      al, [ bx + 6 ]
        cmp      al, 0
        je       _win_check_1

        cmp      al, [ bx + 7 ]
        jne      _win_check_1
        cmp      al, [ bx + 8 ]
        jne      _win_check_1
        ret

  _win_check_1:
        mov      al, [ bx + 1 ]
        cmp      al, 0
        je       _win_check_2

        cmp      al, [ bx + 4 ]
        jne      _win_check_2
        cmp      al, [ bx + 7 ]
        jne      _win_check_2
        ret
        
  _win_check_2:
        mov      al, [ bx + 2 ]
        cmp      al, 0
        je       _win_check_4

        cmp      al, [ bx + 5 ]
        jne      _win_check_4
        cmp      al, [ bx + 8 ]
        jne      _win_check_4
        ret

  _win_check_4:
        mov     al, [ bx + 4 ]
        cmp     al, 0
        je      _win_return

        cmp     al, [ bx ]
        jne     _win_check_4_b
        cmp     al, [ bx  + 8 ]
        jne     _win_check_4_b
        ret

  _win_check_4_b:
        cmp     al, [ bx + 2 ]
        jne     _win_return_blank
        cmp     al, [ bx + 6 ]
        je      _win_return

  _win_return_blank:
        xor     al, al
  _win_return:
        ret
winner endp

ENDIF ; WinnerProc

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

align 2
proc0 proc near
    cmp     al, [bx + 1]
    jne     short proc0_next_win
    cmp     al, [bx + 2]
    je      short proc0_yes

  proc0_next_win:
    cmp     al, [bx + 3]
    jne     short proc0_next_win2
    cmp     al, [bx + 6]
    je      short proc0_yes

  proc0_next_win2:
    cmp     al, [bx + 4]
    jne     short proc0_no
    cmp     al, [bx + 8]
    je      short proc0_yes

  proc0_no:
    mov     al, ah       ; ah is always 0. mov al, ah is 2 cycles. xor ax and xor al are both 3 cycles.

  proc0_yes:
    ret
proc0 endp

align 2
proc1 proc near
    cmp     al, [bx + 0]
    jne     short proc1_next_win
    cmp     al, [bx + 2]
    je      short proc1_yes

  proc1_next_win:
    cmp     al, [bx + 4]
    jne     short proc1_no
    cmp     al, [bx + 7]
    je      short proc1_yes

  proc1_no:
    mov     al, ah

  proc1_yes:
    ret
proc1 endp

align 2
proc2 proc near
    cmp     al, [bx + 0]
    jne     short proc2_next_win
    cmp     al, [bx + 1]
    je      short proc2_yes

  proc2_next_win:
    cmp     al, [bx + 5]
    jne     short proc2_next_win2
    cmp     al, [bx + 8]
    je      short proc2_yes

  proc2_next_win2:
    cmp     al, [bx + 4]
    jne     short proc2_no
    cmp     al, [bx + 6]
    je      short proc2_yes

  proc2_no:
    mov     al, ah

  proc2_yes:
    ret
proc2 endp

align 2
proc3 proc near
    cmp     al, [bx + 0]
    jne     short proc3_next_win
    cmp     al, [bx + 6]
    je      short proc3_yes

  proc3_next_win:
    cmp     al, [bx + 4]
    jne     short proc3_no
    cmp     al, [bx + 5]
    je      short proc3_yes

  proc3_no:
    mov     al, ah

  proc3_yes:
    ret
proc3 endp

align 2
proc4 proc near
    cmp     al, [bx + 0]
    jne     short proc4_next_win
    cmp     al, [bx + 8]
    je      short proc4_yes

  proc4_next_win:
    cmp     al, [bx + 2]
    jne     short proc4_next_win2
    cmp     al, [bx + 6]
    je      short proc4_yes

  proc4_next_win2:
    cmp     al, [bx + 1]
    jne     short proc4_next_win3
    cmp     al, [bx + 7]
    je      short proc4_yes

  proc4_next_win3:
    cmp     al, [bx + 3]
    jne     short proc4_no
    cmp     al, [bx + 5]
    je      short proc4_yes

  proc4_no:
    mov     al, ah

  proc4_yes:
    ret
proc4 endp

align 2
proc5 proc near
    cmp     al, [bx + 3]
    jne     short proc5_next_win
    cmp     al, [bx + 4]
    je      short proc5_yes

  proc5_next_win:
    cmp     al, [bx + 2]
    jne     short proc5_no
    cmp     al, [bx + 8]
    je      short proc5_yes

  proc5_no:
    mov     al, ah

  proc5_yes:
    ret
proc5 endp

align 2
proc6 proc near
    cmp     al, [bx + 2]
    jne     short proc6_next_win
    cmp     al, [bx + 4]
    je      short proc6_yes

  proc6_next_win:
    cmp     al, [bx + 0]
    jne     short proc6_next_win2
    cmp     al, [bx + 3]
    je      short proc6_yes

  proc6_next_win2:
    cmp     al, [bx + 7]
    jne     short proc6_no
    cmp     al, [bx + 8]
    je      short proc6_yes

  proc6_no:
    mov     al, ah

  proc6_yes:
    ret
proc6 endp

align 2
proc7 proc near
    cmp     al, [bx + 1]
    jne     short proc7_next_win
    cmp     al, [bx + 4]
    je      short proc7_yes

  proc7_next_win:
    cmp     al, [bx + 6]
    jne     short proc7_no
    cmp     al, [bx + 8]
    je      short proc7_yes

  proc7_no:
    mov     al, ah

  proc7_yes:
    ret
proc7 endp

align 2
proc8 proc near
    cmp     al, [bx + 0]
    jne     short proc8_next_win
    cmp     al, [bx + 4]
    je      short proc8_yes

  proc8_next_win:
    cmp     al, [bx + 2]
    jne     short proc8_next_win2
    cmp     al, [bx + 5]
    je      short proc8_yes

  proc8_next_win2:
    cmp     al, [bx + 6]
    jne     short proc8_no
    cmp     al, [bx + 7]
    je      short proc8_yes

  proc8_no:
    mov     al, ah

  proc8_yes:
    ret
proc8 endp

end
