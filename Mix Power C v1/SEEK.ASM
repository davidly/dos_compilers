;
;    Copyright (c) Mix Software 1988
;
;  position a file
;
;  int fseek(fp, offset, origin)
;     FILE *fp;
;     long offset;
;     int  origin;
;
         IDT  fseek
         DEF  fseek
         REF  _fileerr
         FREF _fseek
fseek    MOV  BX,SP
         PUSH [BX][%PARM4-2]
         PUSH [BX][%PARM3-2]
         PUSH [BX][%PARM2-2]
         PUSH [BX][%PARM1-2]
         CALLFAR _fseek
         ADD  SP,%8
         CMP  DX,-1
         JNZ  OK
         CMP  AX,-1
         JNZ  OK
         RETFAR
OK       XOR  AX,AX
         RETFAR
         END
;
;  position a file
;
;  long _fseek(fp, offset, origin)
;     FILE *fp;
;     long offset;
;     int  origin;
;
         IDT  _fseek
         DEF  _fseek
         REF  _fileerr
         FREF _fflush
         FREF _rflush
_fseek   MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         TEST SI,SI
         JZ   NOFILE
         TEST %[SI][%FD$DIRTY],%FL$WRITE+FL$READ
         JNZ  FLUSH
;
;  fp->file.count = 0;
;
DOSEEK   MOV  [SI][%FD$COUNT],0
;
;  if ((handle = fp->file.handle) == -1) handle = 2;
;
         MOV  BX,[SI][%FD$HNDL]
         CMP  BX,%-1
         JZ   USE2
;
;  reg.byte.ah = 0x42;
;  reg.byte.al = origin;
;  reg.word.bx = handle;
;  longword.longvalue = offset;
;  reg.word.cx = longword.words.msword;
;  reg.word.dx = longword.words.lsword;
;  longword.words.msword = reg.word.dx;
;  longword.words.lsword = reg.word.ax;
;  return longword.longvalue;
;
HNDLSET  MOV  AH,>42
         MOV  SI,SP
         MOV  AL,[SI][%PARM3+2-2]
         MOV  DX,[SI][%PARM2-2]
         MOV  CX,[SI][%PARM2+2-2]
;
;  if (bios(0x21,&reg) & 0x01) return (*_fileerr)(reg.word.ax,fp);
;
         INT  >21
         JB   ERROR
;
;  longword.words.msword = reg.word.dx;
;  longword.words.lsword = reg.word.ax;
;  return longword.longvalue;
;
         RETSEG
;
ERROR    MOV  SI,SP
         PUSH [SI][%PARM1-2]
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         CWD
         RETSEG
NOFILE   MOV  AX,-1
         CWD
         RETSEG
;
;  if (fp->file.dirty & fdwrite) {
;     if (_fflush(fp) != 0) return EOF;
;     }
;
FLUSH    TEST %[SI][%FD$DIRTY],%FL$WRITE
         JZ   FLUSHR
         PUSH SI
         CALLFAR _fflush
ENDFLUSH POP  SI
         TEST AX,AX
         JZ   DOSEEK
         DEC  AX
         RETSEG
;
;  else if (fp->file.dirty & fdread) {
;     if (_rflush(fp) != 0) return EOF;
;     }
;
FLUSHR   PUSH SI
         CALLFAR _rflush
         JMPS ENDFLUSH
USE2     MOV  BX,2
         JMPS HNDLSET
         END
;
;  return the current file position
;  long ftell(fp)
;     FILE *fp;
;
         IDT  ftell
         DEF  ftell
         FREF _seekend
         REF  _fileerr
ftell    MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         TEST SI,SI
         JZ   NULL
         TEST %[SI][%FD$FLAGS],%FL$APPEN
         JZ   FIND
         TEST %[SI][%FD$DIRTY],%FL$WRITE
         JZ   FIND
         PUSH SI
         CALLFAR _seekend
         POP  SI
FIND     EQU  $
;
;  reg.byte.ah = 0x42;
;  reg.byte.al = 1
;  reg.word.bx = handle;
;  reg.word.cx = 0
;  reg.word.dx = 0
;
         MOV  AX,>4201
         XOR  CX,CX
         XOR  DX,DX
         MOV  BX,[SI][%FD$HNDL]
;
;  if (bios(0x21,&reg) & 0x01) return (*_fileerr)(reg.word.ax,fp);
;
         PUSH SI
         INT  >21
         POP  SI
         JB   ERROR
;
;  longword.words.msword = reg.word.dx;
;  longword.words.lsword = reg.word.ax;
;  return longword.longvalue;
;
         TEST %[SI][%FD$DIRTY],%FL$WRITE+FL$READ
         JNZ  BUFRUSED
         RETSEG
;
;  if (fp->file.dirty & fdwrite) {
;     offset = fp->file.ptr - fp->file.bufr;
;     }
;
BUFRUSED TEST %[SI][%FD$DIRTY],%FL$WRITE
         JZ   READBUFR
ADDOFF   MOV  CX,[SI][%FD$PTR]
         SUB  CX,[SI][%FD$BUFR]
         ADD  AX,CX
         ADC  DX,%0
         RETSEG
;
;  else if (fp->file.dirty & fdread) {
;     offset = fp->file.bufr - fp->file.bufr;}
;
READBUFR SUB  AX,[SI][%FD$COUNT]
         SBB  DX,0
         RETSEG
;
ERROR    MOV  SI,SP
         PUSH [SI][%PARM1-2]
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         CWD
         RETSEG
NULL     MOV  AX,-1
         RETSEG
         END
