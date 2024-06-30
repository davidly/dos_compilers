; Default command line for BASIC:    MASM /Dmodel=medium /DBASIC power2;
; Default command line for C:        MASM /MX /Dmodel=small /DcLang power2;
; Default command line for FORTRAN:  MASM /Dmodel=large /DFORTRAN power2;
; Default command line for Pascal:   MASM /Dmodel=large /DPascal power2;

          INCLUDE mixed.inc
          setModel %model

          IFDEF   BASIC
reference EQU     1
          ENDIF
          IFDEF   FORTRAN
reference EQU     1
          ENDIF

          .CODE

; Function for C, FORTRAN, Pascal, Version 4 of QuickBASIC, and
;   future versions of Microsoft and IBM BASIC Compilers

          IFDEF   reference          ; Pass by reference for BASIC or FORTRAN 
hProc     Power2, Value:PTR, Count:PTR

          pLes    bx,Value           ; Load arguments passed by reference
          mov     ax,FP[bx]
          pLes    bx,Count
          mov     cx,FP[bx]

          ELSE                       ; Pass by value for C or Pascal
hProc     Power2, Value, Count

          mov     ax,Value           ; Load arguments passed by value
          mov     cx,Count
          ENDIF

          shl     ax,cl              ; AX = AX * (2 to power of CL)
                                     ; Return result in AX
          hRet
hEndp

          IFDEF   BASIC

; Subprogram for QuickBASIC, Versions 1, 2, and 3;
;     for the Microsoft BASIC Compiler through Version 5.36
;     for the IBM BASIC Compiler through Version 2.02

hProc     Power2S, Value, Count, RetVal

          pLes    bx,Value           ; Load BASIC arguments
          mov     ax,FP[bx]          ;   passed by reference
          pLes    bx,Count
          mov     cx,FP[bx]

          shl     ax,cl              ; AX = AX * (2 to power of CL)

          pLes    bx,RetVal          ; Load return address
          mov     FP[bx],ax          ;   and store result in it

          hRet
hEndp
          ENDIF   ; BASIC
          END

