; Turbo Pascal 6.0 object-oriented example
; Assembler code for TCALC example
; Copyright (c) 1989,90 by Borland International, Inc.

MODEL TPASCAL

LOCALS

CODESEG

  PUBLIC Compare

; function Compare(var Source, Dest; Len : Word) : Boolean;
;
; Compares two areas of memory to see if they are identical.
;
; Variables:
;
;   Source : Far pointer to the location of the first area of memory.
;   Dest : Far pointer to the location of the second area of memory.
;   Len : The amount of memory to be compared in bytes.

Proc Compare Source : DWord, Dest : DWord, Len : Word
  push    ds              ; Save DS
  mov     cx,[Len]        ; Move Len to CX
  jcxz    @@0             ; Quit if Len = 0, returning True
  lds     si,[Source]     ; Load source pointer into DS:SI
  les     di,[Dest]       ; Load destination pointer into ES:DI
  cld                     ; Set direction to forward
  repz    cmpsb           ; Compare the two areas
  jz      @@0             ; Return True if the compare was completed
  mov     cl,1            ;
@@0:
  mov     al,cl           ; If CL = 0, return True, otherwise return False
  xor     al,1
  pop     ds              ; Restore DS
  ret
EndP

End
