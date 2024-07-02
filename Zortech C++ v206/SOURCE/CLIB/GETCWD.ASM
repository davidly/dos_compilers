;_ getcwd.asm   Wed Jul 12 1989   Modified by: Walter Bright */
; OS2 support added by Nikki Locke May 1989 */
; Copyright (C) 1985-1989 by Walter Bright
; All Rights Reserved
; Written by Walter Bright

        include macros.asm

        begdata
        c_extrn         errno,word

    ifndef __OS2__
tmpbuf  db      ?,':','\'
        db      64 dup (?)
    endif
        enddata

    ifdef __OS2__
extrn   DOSQCURDISK:far
extrn   DOSQCURDIR:far
    endif

    if LCODE
        c_extrn         malloc,far
    else
        c_extrn         malloc,near
    endif

        begcode getcwd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get current working directory.
;       char *getcwd(char *pbuf,size_t Nbytes);
; Input:
;       pbuf    where to store the pathname
;       n       maximum length of pathname including terminating 0
; Returns:
;       if successful
;               pbuf
;       else
;               NULL
;               errno = ENOMEM (out of memory), ERANGE (pathname longer
;                       than n-1 characters)

        c_public        getcwd
func    getcwd

Nbytes  equ     <word ptr P+SIZEPTR[BP]>

    ifdef __OS2__
        push    BP
        mov     BP,SP
        sub     SP,8
Buflen  equ     word ptr -8[BP]
Drive   equ     word ptr -6[BP]
Drmap   equ     word ptr -4[BP]

        ;Determine number of bytes required to hold path
        xor     AX,AX
        push    AX              ;current drive (0)
        push    AX
        push    AX              ;NULL for path buffer
        mov     Buflen,AX       ;0 for buffer size
        push    SS
        lea     AX,Buflen
        push    AX
        call    DOSQCURDIR
        .if     AX ne 111, L3a  ;must be ERROR_BUFFER_OVERFLOW
        mov     CX,Buflen
        add     CX,3            ;for d:\

    if SPTR
        .if     <word ptr P[BP]> ne 0, L33      ;if (pbuf != NULL)
    else
        mov     AX,P+2[BP]
        or      AX,P[BP]
        jne     L33
    endif

        ;malloc the larger of CX or Nbytes
        .if     CX be Nbytes, L4
        mov     Nbytes,CX
L4:     push    Nbytes
        callm   malloc
        add     SP,2
        mov     P[BP],AX
    if LPTR
        mov     P+2[BP],DX              ;pbuf = malloc(Nbytes);
    endif

    if SPTR
        or      AX,AX                   ;if (pbuf != NULL)
    else
        or      AX,DX
    endif
        jz      enomem
        jmp     short L5

L33:    .if     CX a Nbytes, erange     ;insufficient buffer size

        ; get current drive letter
L5:     push    SS
        lea     AX,Drive
        push    AX
        push    SS
        lea     AX,Drmap
        push    AX
        call    DOSQCURDISK
        tst     AX
L3a:    jnz     L3                      ;error
        mov     AX,Drive                ;drive A is 1, B is 2, etc.
        add     AL,'A'-1

    if SPTR
        mov     BX,P[BP]
        mov     [BX],AL
        mov     byte ptr 1[BX],':'
        mov     byte ptr 2[BX],'\'
    else
        les     BX,P[BP]
        mov     ES:[BX],AL
        mov     byte ptr ES:1[BX],':'
        mov     byte ptr ES:2[BX],'\'
    endif

        push    0               ;current drive (0)
      if LPTR
        push    ES
      else
        push    DS
      endif
        add     BX,3            ;skip over D:\
        push    BX              ;output buffer
        mov     AX,Nbytes
        sub     AX,3
        mov     Buflen,AX
        push    SS
        lea     AX,Buflen
        push    AX
        call    DOSQCURDIR
        test    AX,AX
        jnz     L3
        mov     AX,P[BP]
      if LPTR
        mov     DX,ES
      endif

L2:     mov     SP,BP
        pop     BP
        ret

    else ;__OS2__

        push    BP
        mov     BP,SP
        .save   <SI,DI>

        bdos    019h
        mov     DL,AL
        add     AL,'A'
        mov     tmpbuf,AL
        inc     DL              ;DL = drive number
        mov     SI,offset DGROUP:tmpbuf+3
        bdos    47h             ;get current directory
        jc      L3
        mov     SI,offset DGROUP:tmpbuf

        ;CX = length of buffer required (strlen(tmpbuf) + 1)
        mov     DI,SI
        push    DS
        pop     ES
        mov     CX,-1
        repne   scasb
        not     CX

    if SPTR
        .if     <word ptr P[BP]> ne 0, L33      ;if (pbuf != NULL)
    else
        mov     BX,P+2[BP]
        or      BX,P[BP]
        jne     L33
    endif
        push    CX
        .if     CX a Nbytes, L4
        mov     CX,Nbytes
L4:     push    CX
        callm   malloc
        add     SP,2
        pop     CX
        mov     DI,AX
    if SPTR
        tst     AX
        jz      enomem                  ;insufficient memory
    else
        or      AX,DX
        jz      enomem                  ;insufficient memory
        mov     ES,DX
    endif
        jmp     short L5

L33:    .if     CX a Nbytes, erange
    if SPTR
        mov     DI,P[BP]
    else
        les     DI,P[BP]
    endif
L5:
    if SPTR
        push    DS
        pop     ES
    else
        mov     DX,ES
    endif
        mov     AX,DI
        rep     movsb
L2:     .restore <DI,SI>
        pop     BP
        ret
    endif ;__OS2__

erange: mov     AX,1003                 ;ERANGE
L3:     mov     errno,AX

        ;return (char *) NULL;
        xor     AX,AX
    if LPTR
        cwd
    endif
        jmp     L2

enomem: mov     AX,8                    ;ENOMEM
        jmp     L3

c_endp  getcwd

        endcode getcwd

        end

