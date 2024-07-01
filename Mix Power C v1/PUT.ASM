;
;    Copyright (c) Mix Software 1988
;
;  fputc(c,fp)
;      int c;
;      FILE *fp;
;
         IDT  fputc
         DEF  fputc
         FREF _rflush
         FREF _putc
fputc    MOV  BX,SP
         MOV  SI,[BX][%PARM2-2]
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
;   if (fp->file.dirty & fdread) {
;       if (_rflush(fp) != 0) return EOF;
;
         TEST %[SI][%FD$DIRTY],%FL$READ
         JNZ  FLUSH
;
;   if (c != NEWLINE) {
;
NOFLUSH  MOV  AX,[BX][%PARM1-2]
         CMP  AL,>0A
         JZ   NEWLINE
;
;      if (fp->file.count--) return (*(fp->file.ptr++) = c);
;
         MOV  CX,[SI][%FD$COUNT]
         JCXZ BUFFULL
         DEC  CX
         MOV  [SI][%FD$COUNT],CX
         MOV  DI,[SI][%FD$PTR]
         MOV  %[DI],AL
         INC  DI
         MOV  [SI][%FD$PTR],DI
         RETSEG
;
;      else {
;         fp->file.count++;
;         return _putc(c,fp); } }
;
BUFFULL  PUSH SI
         PUSH AX
         CALLFAR _putc
         ADD  SP,%4
         RETSEG
;
;   if ( (fp->file.flags & fdbinary) ||
;       ((fp->file.flags & fdfilter) == 0) ) return _putc(c,fp);
;
NEWLINE  TEST [SI][%FD$FLAGS],%FL$LFEED
         JZ   NOCR
;
;   if (_putc('\r',fp) == EOF) return EOF;
;
         PUSH SI
         MOV  AX,>000D
         PUSH AX
         CALLFAR _putc
         POP  DX
         POP  SI
         INC  AX
         JNZ  PUTLF
         DEC  AX
         RETSEG
PUTLF    MOV  AX,>000A
NOCR     PUSH SI
         PUSH AX
;
;   return _putc(c,fp);
;
         CALLFAR _putc
         ADD  SP,%4
         RETSEG
;
FLUSH    PUSH SI
         CALLFAR _rflush
         POP  SI
         MOV  BX,SP
         TEST AX,AX
         JZ   NOFLUSH
;
ENDFL    MOV  AX,-1
         RETSEG
         END
;
;
;  _putc(c,fp)
;      int c;
;      FILE *fp;
;
;   Lowest level file output (one character)
;        file validity has already been checked
;
         IDT  _putc
         DEF  _putc
         FREF _fflush
         FREF _seekend
         REF  _fileerr
DISKFULL EQU  >009A
;
_putc    PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM2]
;
;   if (fp->file.device == 'o') {
;       _sys_adx(0x0200,c);
;       return c; }
;
         CMP  %[SI][%FD$DEV],'o'
         JNZ  NOTSTD
         MOV  DX,[BP][%PARM1]
         MOV  AX,>0200
         INT  >21
         MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
;
;   if (fp->file.count--) return (*(fp->file.ptr++) = c);
;
NOTSTD   MOV  AX,[BP][%PARM1]
         MOV  CX,[SI][%FD$COUNT]
         JCXZ BUFFULL
         DEC  CX
         MOV  [SI][%FD$COUNT],CX
         MOV  DI,[SI][%FD$PTR]
         MOV  %[DI],AL
         INC  DI
         MOV  [SI][%FD$PTR],DI
EXIT     POP  BP
         RETSEG
;
;       fp->file.count = 0;
;
BUFFULL  MOV  [SI][%FD$COUNT],0
;
;       if (fp->file.device == 'd') return c;
;
         CMP  [SI][%FD$DEV],'d'
         JZ   EXIT
;
;       if (fp->file.dirty & fdwrite) {
;           if (_fflush(fp) != 0) return EOF; }
;
         TEST %[SI][%FD$DIRTY],%FL$WRITE
         JZ   NOFLUSH
         PUSH SI
         CALLFAR _fflush
         POP  SI
         TEST AX,AX
         JNZ  ENDFL
;
;      if (fp->file.flags & fdunbufr) {
;           if (_sysabcd(0x4000,fp->file.handle,1,&c,&status) != 0) {
;               (*_fileerr)(status,fp);
;               return EOF; }
;
NOFLUSH  TEST %[SI][%FD$FLAGS],%FL$UNBUF
         JZ   USEBUFR
;  Seek to end of file if append mode
         TEST [SI][%FD$FLAGS],FL$APPEN
         JNZ  PUTACHAR
         PUSH SI
         CALLFAR _seekend
         POP  SI
PUTACHAR LEA  DX,[BP][%PARM1]
         MOV  BX,[SI][%FD$HNDL]
         MOV  CX,1
         MOV  AX,>4000
         INT  >21
         JNB  OK1
ERROR    PUSH [BP][%PARM2]
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
ENDFL    MOV  AX,-1
         POP  BP
         RETSEG
;
;           return c;
;
OK1      EQU  $
         CMP  AX,1
         JZ   OK2
         MOV  AX,DISKFULL
         JMPS ERROR
OK2      MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
;
;       fp->file.ptr = fp->file.bufr;
;       fp->file.count = fp->file.bufsize - 1;
;       *fp->file.ptr++ = c;
;       fp->file.dirty |= fdwrite;
;       return c;
;
USEBUFR  MOV  BX,[SI][%FD$BUFR]
         MOV  AX,[SI][%FD$BUFSZ]
         DEC  AX
         MOV  [SI][%FD$COUNT],AX
         MOV  AX,[BP][%PARM1]
         MOV  %[BX],AL
         INC  BX
         MOV  [SI][%FD$PTR],BX
         OR   %[SI][%FD$DIRTY],%FL$WRITE
         POP  BP
         RETSEG
;
         END
