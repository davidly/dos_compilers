;
;    Copyright (c) Mix Software 1988
;
; fwrite(buffer,itemsize,no_of_items,fp)
;    char *buffer;
;    int itemsize;
;    int no_of_items;
;    FILE *fp;
; { return (_write(fp,buffer,itemsize*no_of_items) / itemsize); }
;
         IDT  fwrite
         DEF  fwrite
         FREF _write
fwrite   MOV  BX,SP
         MOV  AX,[BX][%PARM2-2]                ; # of items
         MOV  CX,[BX][%PARM3-2]                ; item count
         CMP  AX,1
         JZ   FWRITE1SZ       ; avoid multiply by 1
         CMP  CX,%1
         JZ   FWRITE1I        ; avoid multiply by 1
         MUL  CX
         PUSH AX              ; pass count to _write
         PUSH [BX][%PARM1-2]  ; pass file pointer
         PUSH [BX][%PARM4-2]  ; pass address
         CALLFAR _write
         ADD  SP,%6
         CMP  AX,-1
         JZ   ERROR
         MOV  BX,SP
         MOV  CX,[BX][%PARM2-2]  ; item size
         CWD
         DIV  CX              ; convert byte count to item count
         RETSEG
ERROR    XOR  AX,AX
         RETSEG
;
;  Item size is 1
;
FWRITE1SZ PUSH CX
         PUSH [BX][%PARM1-2]
         PUSH [BX][%PARM4-2]
         CALLFAR _write
         ADD  SP,%6
         CMP  AX,-1
         JZ   ERROR
         RETSEG
;
;  Number of items is 1
;
FWRITE1I PUSH AX
         PUSH [BX][%PARM1-2]
         PUSH [BX][%PARM4-2]
         CALLFAR _write
         ADD  SP,%6
         CMP  AX,-1
         JZ   ERROR
         MOV  BX,SP
         CMP  AX,[BX][%PARM2-2]   ; is size == 1?
         JZ   ONE                 ; skip divide by 1
         MOV  CX,[BX][%PARM2-2]
         CWD
         DIV  CX
         RETSEG
ONE      MOV  AX,1
         RETSEG
         END
;
; ------------------------------------------------------------
;
;  _write(fp, bufptr, n)
;      int n;
;      FILE *fp;
;      char *bufptr;
;
         IDT  _write
         DEF  _write
         FREF _fflush
         FREF _rflush
         FREF _putc
         FREF _seekend
         REF  _fileerr
_write   PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1]
         TEST BX,BX
         JZ   FILEERR
;
; if (fp == NULL || !fp->file.init || !fp->file.openflg) return 0;
;
;        TEST BX,BX                            ; File ok?
;        JZ   ENDFL
;        CMP  %[BX][%FD$INIT],%0
;        JZ   ENDFL
;        CMP  %[BX][%FD$OPEN],%0
;        JZ   ENDFL
;
;   if (fp->file.dirty & fdread) {
;       if (_rflush(fp) != 0) return EOF;
;       }
;
         TEST %[BX][%FD$DIRTY],%FL$READ
         JNZ  FLUSH           ; file has been read, flush buffer
;
;       if (fp->file.flags & fdfilter) {
;
NOFLUSH  MOV  AL,[BX][%FD$FLAGS]
         TEST AL,%FL$UNBUF    ; unbuffered file?
         JNZ  UNBUFR
         TEST AL,%FL$LFEED    ; text mode?
         JZ   NOCR
;
; Write and insert carriage return before linefeed
;
;           while (n-- != 0) {
;               if ((c = *bufptr++) == NEWLINE) {
;                   if (_putc(RETURN,fp) != RETURN) return EOF;
;                   }
;               if (_putc(c,fp) != c) return EOF;
;               }
;
;  bx = file
;  di = file buffer
;  si = buffer address
;  dx = count remaining
;  cx = buffer count
;
         MOV  SI,[BP][%PARM2]
         MOV  DX,[BP][%PARM3] ; Requested count
         TEST DX,DX
         JZ   DONE1
         MOV  DI,[BX][%FD$PTR]
         MOV  CX,[BX][%FD$COUNT]
         JCXZ MORE1
         MOV  AX,DS
         MOV  ES,AX
COPY1    LODSB                ; Get a byte
NEXTCH1  CMP  AL,>0A
         JZ   ADDCR
COPY1A   STOSB                ; Store in file buffer
         DEC  DX              ; count character
         JZ   DONE1A          ; read complete
         LOOP COPY1
MORE1    CALL PUTBLK
         JB   FILEERR
         MOV  AX,DS
         MOV  ES,AX
         JMPS COPY1
ADDCR    MOV  AL,>0D
         STOSB
         MOV  AL,>0A
         LOOP COPY1A
         CALL PUTBLK
         JB   FILEERR
         MOV  AX,DS
         MOV  ES,AX
         MOV  AL,>0A
         JMPS COPY1A
DONE1A   DEC  CX
DONE1B   MOV  [BX][%FD$COUNT],CX
         MOV  [BX][%FD$PTR],DI
         CMP  DI,[BX][%FD$BUFR]
         JZ   DONE1
         MOV  %[BX][%FD$DIRTY],%FL$WRITE
DONE1    MOV  AX,[BP][%PARM3]
         SUB  AX,DX
         POP  BP
         RETSEG
NOCR     JMP  NOCR1
;
FILEERR2 POP  CX
         POP  SI
FILEERR  MOV  AX,-1
         POP  BP
         RETSEG
;
FLUSH    PUSH BX
         CALLFAR _rflush
         POP  BX
         TEST AX,AX
         JZ   NOFLUSH
         JMPS FILEERR
;
;  File is not buffered
;
UNBUFR   TEST AL,%FL$BIN
         JZ   UNBUFR0
         JMP  DIRECT
UNBUFR0  MOV  CX,[BP][%PARM3]
         JCXZ UBDONE
         MOV  SI,[BP][%PARM2]
UNBLOOP  LODSB
         CMP  AL,>0A
         JZ   UBCR
         XOR  AH,AH
UBPUT    PUSH SI
         PUSH CX
UBPUT2   PUSH BX
         PUSH AX
         CALLFAR _putc
         POP  DX
         POP  BX
         POP  CX
         POP  SI
         CMP  AX,-1
         JZ   FILEERR
         LOOP UNBLOOP
UBDONE   MOV  AX,[BP][%PARM3]
         POP  BP
         RETSEG
;
UBCR     TEST %[BX][FD$FLAGS],%FL$LFEED
         JZ   UBPUT
         PUSH SI
         PUSH CX
         PUSH BX
         MOV  AX,>000D
         PUSH AX
         CALLFAR _putc
         POP  DX
         POP  BX
         CMP  AX,-1
         JZ   FILEERR2
         MOV  AX,>000A
         JMPS UBPUT2
DIRECT1  JMP  DIRECT
;
;   File is binary and buffered
;
NOCR1    MOV  AX,[BP][%PARM3] ; Length of write
         CMP  AX,[BX][%FD$BUFSZ]
         JA   DIRECT1         ; Use direct file io
         XOR  DX,DX           ; already done is 0
         MOV  SI,[BP][%PARM2] ; buffer pointer
         MOV  DI,[BX][%FD$PTR]
BINMOVE  MOV  CX,[BX][%FD$COUNT]
         JCXZ NOMOVE
         MOV  AX,[BP][%PARM3]
         SUB  AX,DX           ; Additional needed
         CMP  CX,AX
         JB   MOVEALL
         MOV  CX,AX           ; Use only part of buffer
MOVEALL  PUSH CX
         MOV  AX,DS
         MOV  ES,AX
         MOV  DI,[BX][%FD$PTR]
         CLD
         REP
         MOVSB
         POP  CX
         SUB  [BX][%FD$COUNT],CX
         MOV  [BX][%FD$PTR],DI
         MOV  %[BX][%FD$DIRTY],%FL$WRITE
;
;  CX contains count of moved characters
;
NOMOVE   ADD  DX,CX
         MOV  CX,[BP][%PARM3]
         SUB  CX,DX           ; Characters left
         JCXZ DONE4
         TEST %[BX][%FD$DIRTY],%FL$WRITE
         JZ   NOWRITE
         TEST %[BX][%FD$FLAGS],%FL$APPEN
         JZ   W1
         PUSH SI
         PUSH DI
         PUSH CX
         PUSH DX
         PUSH BX
         CALLFAR _seekend
         POP  BX
         POP  DX
         POP  CX
         POP  DI
         POP  SI
W1       MOV  AX,>4000
         PUSH DX
         PUSH BX
         MOV  %[BX][%FD$DIRTY],%0
         MOV  DX,[BX][%FD$BUFR]
         MOV  [BX][%FD$PTR],DX
         MOV  CX,DI
         SUB  CX,DX
         MOV  BX,[BX][%FD$HNDL]
         JCXZ EMPTY
         INT  >21
         POP  BX
         POP  DX
         JNB  OK1
FLERROR  PUSH DX
         PUSH BX
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         POP  BX
         POP  BX
         POP  DX
         MOV  [BX][%FD$COUNT],0
DONE4    MOV  AX,DX
         POP  BP
         RETSEG
EMPTY    POP  BX
         POP  DX
         XOR  AX,AX
;
OK1      CMP  AX,CX
         MOV  AX,[BX][%FD$BUFSZ]
         MOV  [BX][%FD$COUNT],AX
         JZ   BINMOVE0
         MOV  AX,E$NOSPAC
         JMPS FLERROR
NOWRITE  MOV  CX,[BX][%FD$BUFSZ]
         MOV  [BX][%FD$COUNT],CX
         MOV  CX,[BX][%FD$BUFR]
         MOV  [BX][%FD$PTR],CX
BINMOVE0 JMP  BINMOVE
;
DIRECT   TEST %[BX][%FD$DIRTY],%FL$WRITE
         JZ   DIR1
         PUSH BX
         CALLFAR _fflush
         POP  BX
DIR1     MOV  AX,[BX][%FD$BUFR]
         MOV  [BX][%FD$PTR],AX
         MOV  [BX][%FD$COUNT],0
         MOV  %[BX][%FD$DIRTY],0
         TEST %[BX][%FD$FLAGS],%FL$APPEN
         JZ   W2
         PUSH BX
         CALLFAR _seekend
         POP  BX
W2       MOV  AX,>4000
         MOV  BX,[BX][%FD$HNDL]
         MOV  CX,[BP][%PARM3]
         MOV  DX,[BP][%PARM2]
         INT  >21
         JB   FLERROR
         POP  BP
         RETSEG
;
;  Write the file buffer
;     bx = file
;     di = current pointer
;   resets di to start of buffer, cx to length
;
PUTBLK   PUSH DX
         PUSH BX
         MOV  DX,[BX][%FD$BUFR]
         MOV  CX,DI
         SUB  CX,DX           ; buffer count
         JCXZ EMPTY2
         TEST %[BX][%FD$FLAGS],%FL$APPEN
         JZ   W3
         PUSH SI
         PUSH DI
         PUSH CX
         PUSH DX
         PUSH BX
         CALLFAR _seekend
         POP  BX
         POP  DX
         POP  CX
         POP  DI
         POP  SI
W3       MOV  AX,>4000
         MOV  BX,[BX][%FD$HNDL]
         INT  >21
         POP  BX
         POP  DX
         JB   ERROR
EXITPUT  MOV  DI,[BX][%FD$BUFR]
         MOV  CX,[BX][%FD$BUFSZ]
         MOV  %[BX][%FD$DIRTY],%0
         CLC
         RET
EMPTY2   POP  BX
         POP  DX
         JMPS EXITPUT
ERROR    POP  BX
         PUSH BX
         PUSH BX
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         POP  BX
         POP  DX
         STC
         RET
;
         END
