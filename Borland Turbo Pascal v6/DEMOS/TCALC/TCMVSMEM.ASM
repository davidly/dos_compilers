; Turbo Pascal 6.0 object-oriented example
; Assembler code for TCALC example
; Copyright (c) 1989,90 by Borland International, Inc.

MODEL TPASCAL

LOCALS

DATASEG

  EXTRN CheckSnow : BYTE

CODESEG

  PUBLIC MoveToScreen, MoveFromScreen

; procedure MoveToScreen(var Source, Dest; Len : Word);
;
; Moves memory from normal RAM to screen memory, making sure that the video
; interference that can occur when you do this on certain CGA's is
; prevented.
;
; Variables:
;
;   Source : Far pointer to the location of the memory to be moved.
;   Dest : Far pointer to the destination of the memory to be moved.
;   Len : The amount in bytes of the memory to be moved.

Proc MoveToScreen Source : DWord, Dest : DWord, Len : Word
  push    ds                   ; Save DS
  mov     bh,[CheckSnow]       ; Load CheckSnow value
  lds     si,[Source]          ; Source pointer into DS:SI
  les     di,[Dest]            ; Dest pointer into ES:DI
  mov     cx,[Len]             ; Len value into CX
  jcxz    @@0                  ; Quit if Len = 0
  cmp     si,di                ; Find out if source comes before destination
                               ;   in memory
  jle     @@1                  ; If it does, copy from end of memory area
  cld                          ; Set direction to forward
  jmp     short @@2
@@1:
  add     si,cx                ; Move SI and DI to the ends of the memory
  sub     si,2                 ;   areas
  add     di,cx
  sub     di,2
  std                          ; Set direction to backward
@@2:
  cmp     bh,0                 ; If CheckSnow is false, use fast screen I/O
  je      @@7
@@3:
  shr     cx,1                 ; Change bytes to words
  mov     dx,3DAh              ; Point DX to CGA status port
  mov     bl,9                 ; Move horiz. + vertical retrace mask to bl
@@4:
  lodsw                        ; Grab a video word
  mov     bp,ax                ; Save it in BP
@@5:
  in      al,dx                ; Get 6845 status
  rcr     al,1                 ; Check horizontal retrace
  jb      @@5                  ; Loop if in horizontal retrace: this prevents
                               ;   starting in mid-retrace, since there is
                               ;   exactly enough time for 1 and only 1 STOSW
                               ;   during horizontal retrace
  cli                          ; No ints during critical section
@@6:
  in      al,dx                ; Get 6845 status
  and     al,bl                ; Check for both kinds of retrace: IF the
                               ;   video board does not report horizontal
                               ;   retrace while in vertical retrace, this
                               ;   will allow several characters to be
                               ;   stuffed in during vertical retrace
  jz      @@6                  ; Loop if equal to zero
  mov     ax,bp                ; Get the video word
  stosw                        ; Store the video word
  sti                          ; Allow interrupts
  loop    @@4                  ; Go do next word
  jmp     short @@0
@@7:
  shr     cx,1                 ; Change bytes to words
  rep     movsw
@@0:
  pop     ds                   ; Restore DS
  ret
ENDP

; procedure MoveFromScreen(var Source, Dest; Len : Word);
;
; Moves memory to normal RAM from screen memory, making sure that the video
; interference that can occur when you do this on certain CGA's is
; prevented.
;
; Variables:
;
;   Source : Far pointer to the location of the memory to be moved.
;   Dest : Far pointer to the destination of the memory to be moved.
;   Len : The amount in bytes of the memory to be moved.

Proc MoveFromScreen Source : DWord, Dest : DWord, Len : Word
  push    ds                   ; Save DS
  mov     bh,[CheckSnow]       ; Load CheckSnow value
  lds     si,[Source]          ; Source pointer into DS:SI
  les     di,[Dest]            ; Dest pointer into ES:DI
  mov     cx,[Len]             ; Len value into CX
  jcxz    @@0                  ; Quit if Len = 0
  cmp     si,di                ; Find out if source comes before destination
                               ;   in memory
  jle     @@1
  cld                          ; Set direction to forward
  jmp     short @@2
@@1:
  add     si,cx                ; Move SI and DI to the ends of the memory
  sub     si,2                 ;   areas
  add     di,cx
  sub     di,2
  std                          ; Set direction to backward
@@2:
  cmp     bh,0                 ; If CheckSnow is false, use fast screen I/O
  je      @@6
@@3:
  shr     cx,1                 ; Change bytes to words
  mov     dx,3DAh              ; Point DX to CGA status port
@@4:
  in      al,dx                ; Get 6845 status
  rcr     al,1                 ; Check horizontal retrace
  jb      @@4                  ; Loop if in horizontal retrace: this prevents
                               ;   starting in mid-retrace, since there is
                               ;   exactly enough time for 1 and only 1 LODSW
                               ;   during horizontal retrace
  cli                          ; No ints during critical section
@@5:
  in      al,dx                ; Get 6845 status
  rcr     al,1                 ; Check for horizontal retrace: LODSW is 1
                               ;   clock cycle slower than STOSW; because of
                               ;   this, the vertical retrace trick can't be
                               ;   used because it causes flicker!  (RCR AL,1
                               ;   is 1 cycle faster than AND AL,AH)
  jnb     @@5                  ; Loop if not in retrace
  lodsw                        ; Load the video word
  sti                          ; Allow interrupts
  stosw                        ; Store the video word
  loop    @@4                  ; Go do next word
  jmp     short @@0
@@6:
  shr     cx,1                 ; Change bytes to words
  rep     movsw
@@0:
  pop     ds                   ; Restore DS
  ret
ENDP

END
