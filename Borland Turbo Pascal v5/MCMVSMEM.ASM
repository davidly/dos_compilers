
;           Copyright (c) 1985, 87 by Borland International, Inc.

	TITLE	MCMVSMEM

DATA	SEGMENT	WORD PUBLIC

        ASSUME DS:DATA

        EXTRN CheckSnow : BYTE

DATA	ENDS

CODE	SEGMENT	BYTE PUBLIC

	ASSUME	CS:CODE

	PUBLIC	MoveToScreen, MoveFromScreen

; procedure MoveToScreen(var Source, Dest; Len : Word);

MoveToScreen	PROC	FAR
  push    bp
  mov     bp,sp
  push    bp                   ; Save Turbo's BP
  push    ds                   ;   and DS
  mov     bh,ds:CheckSnow      ; Load CheckSnow value
  lds     si,dword ptr [bp+12] ; Source pointer into DS:SI
  les     di,dword ptr [bp+8]  ; Dest pointer into ES:DI
  mov     cx,[bp+6]            ; Len value into CX
  cmp     cx,0                 ; Quit if Len = 0
  je      x0
  cmp     si,di
  jle     x1
  cld                          ; Set string direction to forward
  jmp short x2
x1:
  add     si,cx
  sub     si,2
  add     di,cx
  sub     di,2
  std
x2:
  cmp     bh,0
  je      x7
x3:
  shr     cx,1                 ; Change bytes to words
  mov     dx,3DAh              ; Point DX to CGA status port
  mov     bl,9                 ; Move horiz. + vertical retrace mask to bl
x4:     
  lodsw                        ; Grab a video word
  mov     bp,ax                ; Save it in BP
x5:     
  in      al,dx                ; Get 6845 status
  rcr     al,1                 ; Check horizontal retrace
  jb      x5                   ; Loop if in horizontal retrace: this prevents
                               ;   starting in mid-retrace, since there is
                               ;   exactly enough time for 1 and only 1 STOSW
                               ;   during horizontal retrace
  cli                          ; No ints during critical section
x6:     
  in      al,dx                ; Get 6845 status
  and     al,bl                ; Check for both kinds of retrace: IF the
                               ;   video board does not report horizontal
                               ;   retrace while in vertical retrace, this
                               ;   will allow several characters to be
                               ;   stuffed in during vertical retrace
  jz      x6                   ; Loop if equal to zero
  mov     ax,bp                ; Get the video word
  stosw                        ; Store the video word
  sti                          ; Allow interrupts
  loop    x4                   ; Go do next word
  jmp short x0
x7:
  shr     cx,1                 ; Change bytes to words
  rep     movsw
x0:
  pop     ds                   ; Restore DS
  pop     bp                   ;   and BP
  mov     sp,bp
  pop     bp
  ret     10
MoveToScreen	ENDP

; procedure MoveFromScreen(var Source, Dest; Len : Word);

MoveFromScreen	PROC	FAR
  push    bp
  mov     bp,sp
  push    bp                   ; Save Turbo's BP
  push    ds                   ;   and DS
  mov     bh,ds:CheckSnow      ; Load CheckSnow value
  lds     si,dword ptr [bp+12] ; Source pointer into DS:SI
  les     di,dword ptr [bp+8]  ; Dest pointer into ES:DI
  mov     cx,[bp+6]            ; Len value into CX
  cmp     cx,0                 ; Quit if Len = 0
  je      y0
  cmp     si,di
  jle     y1
  cld                          ; Set string direction to forward
  jmp short y2
y1:
  add     si,cx
  sub     si,2
  add     di,cx
  sub     di,2
  std
y2:
  cmp     bh,0
  je      y6
y3:
  shr     cx,1                 ; Change bytes to words
  mov     dx,3DAh              ; Point DX to CGA status port
y4:     
  in      al,dx                ; Get 6845 status
  rcr     al,1                 ; Check horizontal retrace
  jb      y4                   ; Loop if in horizontal retrace: this prevents
                               ;   starting in mid-retrace, since there is
                               ;   exactly enough time for 1 and only 1 LODSW
                               ;   during horizontal retrace
  cli                          ; No ints during critical section
y5:     
  in      al,dx                ; Get 6845 status
  rcr     al,1                 ; Check for horizontal retrace: LODSW is 1
                               ;   clock cycle slower than STOSW; because of
                               ;   this, the vertical retrace trick can't be
                               ;   used because it causes flicker!  (RCR AL,1
                               ;   is 1 cycle faster than AND AL,AH)
  jnb     y5                   ; Loop if not in retrace
  lodsw                        ; Load the video word
  sti                          ; Allow interrupts
  stosw                        ; Store the video word
  loop    y4                   ; Go do next word
  jmp short y0
y6:
  shr     cx,1                 ; Change bytes to words
  rep movsw
y0:
  pop     ds                   ; Restore DS
  pop     bp                   ;   and BP
  mov     sp,bp
  pop     bp
  ret     10
MoveFromScreen	ENDP

CODE	ENDS

	END
