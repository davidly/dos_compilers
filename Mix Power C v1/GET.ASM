;
;    Copyright (c) Mix Software 1988
;
; ------------------------------------------------------------
;
;  fgetc(fp)
;      FILE *fp;
;
         IDT  fgetc
         DEF  fgetc
         FREF _fflush
         FREF _getc
fgetc    MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         TEST SI,SI
         JZ   ENDFL
;
; if (fp == NULL || !fp->file.init || !fp->file.openflg) return EOF;
;
;        TEST SI,SI                            ; File ok?
;        JZ   ENDFL
;        CMP  %[SI][%FD$INIT],%0
;        JZ   ENDFL
;        CMP  %[SI][%FD$OPEN],%0
;        JZ   ENDFL
;
;   if (fp->file.dirty & fdwrite) {
;       }
;
         TEST %[SI][%FD$DIRTY],%FL$WRITE
         JNZ  FLUSH
;
;   if (fp->file.count) {
;      c = *(fp->file.ptr++);
;      fp->file.count--; }
;
NOFLUSH  MOV  CX,[SI][%FD$COUNT]
         JCXZ NEEDMORE
         DEC  CX
         MOV  [SI][%FD$COUNT],CX
         MOV  BX,[SI][%FD$PTR]
         MOV  AL,[BX]
         XOR  AH,AH
         INC  BX
         MOV  [SI][%FD$PTR],BX
;
;   if (fp->file.flags & fdbinary) return c;
;
OK       TEST %[SI][%FD$FLAGS],%FL$BIN
         JNZ  DONE
;
;   while (c == RETURN && (fp->file.flags & fdfilter)) c = _getc(fp);
;
NOTBIN   TEST %[SI][%FD$FLAGS],%FL$LFEED
         JZ   NOTCR
NEXTCR   CMP  AX,>000D
         JNZ  NOTCR
         PUSH SI
         CALLFAR _getc
         POP  SI
         JMPS NEXTCR
;
;   if (c == 0x1a && (fp->file.flags & fdctlz)) return EOF;
;
NOTCR    CMP  AX,>001A
         JNZ  NOTCTLZ
         TEST %[SI][%FD$FLAGS],%FL$CTLZ
         JZ   NOTCTLZ
ENDFL    MOV  AX,-1
         RETFAR
;
;   else return c;
;
DONE     EQU   $
NOTCTLZ  RETFAR
;
;   else c = _getc(fp);
;
NEEDMORE PUSH SI
         CALLFAR _getc
         POP  SI
         JMPS OK
;
;       if (_fflush(fp) != 0) return EOF;
;
FLUSH    PUSH SI
         CALLFAR _fflush
         POP  SI
         TEST AX,AX
         JNZ  ENDFL
         JMPS NOFLUSH
         END
;
; ------------------------------------------------------------
;  _getc(fp)
;  FILE *fp;
;
         IDT  _getc
         DEF  _getc
         REF  $$UBCON
         REF  _fileerr
_getc    MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
;
;   if (fp->file.count--) return *(fp->file.ptr++);
;
         MOV  CX,[SI][%FD$COUNT]
         JCXZ NEEDMORE
         DEC  CX
         MOV  [SI][%FD$COUNT],CX
         MOV  BX,[SI][%FD$PTR]
         MOV  AL,[BX]
         XOR  AH,AH
         INC  BX
         MOV  [SI][%FD$PTR],BX
         RETSEG
;
;
;       if ((device = fp->file.device) == 'c' || device == 'i') {
;
NEEDMORE MOV  AL,[SI][%FD$DEV]
         CMP  AL,'c'
         JZ   CONSOLE
         CMP  AL,'i'
         JNZ  FILE
;
;           if ((fp->file.flags & fdecho) || ($$UBCON & 2))
;               return _sys_al(0x0700);
;
CONSOLE  TEST %[SI][%FD$FLAGS],%FL$ECHO
         JNZ  NOECHO
         TEST %[$$UBCON],%>02
         JZ   ECHO
NOECHO   MOV  AX,>0700
CONDIR   INT  >21
         XOR  AH,AH
         RETSEG
;
;           if ((fp->file.flags & fdunbufr) || ($$UBCON & 1))
;               return _sys_al(0x0100);
;
ECHO     TEST %[SI][%FD$FLAGS],%FL$UNBUF
         JNZ  UNBUFR
         TEST %[$$UBCON],%>01
         JZ   FILE
UNBUFR   MOV  AX,>0100
         JMPS CONDIR
;
;       if (fp->file.flags & fdunbufr) {
;
FILE     TEST %[SI][%FD$FLAGS],%FL$UNBUF
         JZ   USEBUFR
;
;  Read one character (unbuffered)
;           if (_sysabcd(0x3f00,handle,1,&c,&fp->file.count) != 0) {
;               (*_fileerr)(fp->file.count,fp);
;               fp->file.count = 0;
;               return EOF; }
;
         MOV  BX,[SI][%FD$HNDL]
         MOV  CX,1
         SUB  SP,%2
         MOV  DX,SP
         MOV  AX,>3F00
         INT  >21
         JNB  READOK
         MOV  BX,SP
         PUSH [BX][%PARM1]
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%6
         MOV  AX,-1
         RETSEG
;
;           else {
;               if (fp->file.count) return c;
;
READOK   TEST AX,AX
         JZ   ATEND
         POP  AX
         XOR  AH,AH
         RETSEG
;
;               else {
;                   fp->file.eofflag = 1;
;                   return EOF; } } }
;
ATEND    POP  AX
FILEEND  MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         MOV  %[SI][%FD$EOF],%1
ENDFL    MOV  AX,-1
         RETSEG
;
;       fp->file.ptr = fp->file.bufr;
;       if (_sysabcd(0x3f00,handle,fp->file.bufsize,
;           fp->file.bufr,&fp->file.count) != 0) {
;
USEBUFR  MOV  DX,[SI][%FD$BUFR]
         MOV  [SI][%FD$PTR],DX
         MOV  AX,>3F00
         MOV  BX,[SI][%FD$HNDL]
         MOV  CX,[SI][%FD$BUFSZ]
         INT  >21
         JNB  READOK2
;
;           (*_fileerr)(fp->file.count,fp);
;           fp->file.count = 0;
;           return EOF; }
;
         MOV  BX,SP
         PUSH [BX][%PARM1-2]
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         JMPS ENDFL
READOK2  MOV  CX,AX
         JCXZ FILEEND
;
;       fp->file.dirty = fdread;
;
         MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         OR   %[SI][%FD$DIRTY],%FL$READ
;
;       if (fp->file.count--) return *(fp->file.ptr++);
;
         DEC  CX
         MOV  [SI][%FD$COUNT],CX
         MOV  BX,[SI][%FD$PTR]
         MOV  AL,[BX]
         XOR  AH,AH
         INC  BX
         MOV  [SI][%FD$PTR],BX
         RETSEG
;
;       else {
;           fp->file.count = 0;
;           fp->file.eofflag = 1;
;           return EOF;
;           }
;
         END
