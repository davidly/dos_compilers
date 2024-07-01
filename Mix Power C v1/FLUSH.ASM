;
;    Copyright (c) Mix Software 1988
;
;  flush output buffer
;
;  _fflush(fp)     /* write any remaining data from buffer to file */
;     fdb *fp;
;
         IDT  _fflush
         DEF  _fflush
         FREF _seekend
         REF  _fileerr
_fflush  MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         TEST %[SI][%FD$DIRTY],%FL$WRITE
         JNZ  DOWRITE
         XOR  AX,AX
         RETSEG
;
;   fp->dirty = 0;
;   count = fp->bufsize - fp->count;
;
DOWRITE  AND  %[SI][%FD$DIRTY],%>FF-FL$WRITE
         MOV  CX,[SI][%FD$BUFSZ]
         SUB  CX,[SI][%FD$COUNT]
;
;   if (count > 0) {
;
         JCXZ DONE
;
;       if (_sysabcd(0x4000,fp->handle,count,fp->bufr,&status) != 0)
;           (*_fileerr)(status,fp);
;
;  Seek to end of file if append mode
         TEST [SI][%FD$FLAGS],FL$APPEN
         JZ   W1
         PUSH DI
         PUSH CX
         PUSH SI
         CALLFAR _seekend
         POP  SI
         POP  CX
         POP  DI
W1       MOV  AX,>4000
         MOV  BX,[SI][%FD$HNDL]
         MOV  DX,[SI][%FD$BUFR]
         PUSH CX
         INT  >21
         POP  CX
         JNB  OK
FILEERR  PUSH SI
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         MOV  AL,[SI][%FD$ERR]
         XOR  AH,AH
         RETSEG
;
;       else {
;           if (status != count) (*_fileerr)(0x9a,fp);
;           else fp->error = 0;
;
OK       CMP  AX,CX
         JNZ  DISKFULL
         MOV  [SI][%FD$COUNT],0
DONE     MOV  AX,[SI][%FD$BUFR]
         MOV  [SI][%FD$PTR],AX
         XOR  AX,AX
         RETSEG
;
DISKFULL MOV  AX,E$NOSPAC
         JMPS FILEERR
         END
;
;
;  _rflush(fp)     /* postion a read file for writing */
;      FILE *fp;
;
         IDT  _rflush
         DEF  _rflush
         REF  _fileerr
_rflush  MOV  BX,SP
         MOV  SI,[BX][%PARM1-2]
         TEST %[SI][%FD$DIRTY],%FL$READ
         JNZ  DOREAD
         XOR  AX,AX
         RETSEG
;
;   fp->dirty = 0;
;   count = fp->ptr - fp->bufr;
;
DOREAD   AND  %[SI][%FD$DIRTY],%>FF-FL$READ
         MOV  CX,[SI][%FD$PTR]
         SUB  CX,[SI][%FD$BUFR]
         MOV  [SI][%FD$COUNT],0
;
;   if (count > 0) {
;
         JCXZ DONE
;
;       if (_sysabcd(0x4201,handle,0,count,&status) != 0)
;           return (*_fileerr)(status,fp); }
;      return 0;
;
         MOV  AX,>4201
         MOV  BX,[SI][%FD$HNDL]
         MOV  DX,CX
         XOR  CX,CX
         INT  >21
         JB   FILEERR
DONE     MOV  AX,[SI][%FD$BUFR]
         MOV  [SI][%FD$PTR],AX
         XOR  AX,AX
         RETSEG
FILEERR  PUSH SI
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         RETSEG
         END
;
;  Seek to end of file
;        _seekend(fdbptr)
;
         IDT  _seekend
         DEF  _seekend
;
_seekend PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1]
         MOV  AX,>4202
         XOR  CX,CX
         XOR  DX,DX
         MOV  BX,[SI][%FD$HNDL]
         INT  >21
         POP  BP
         RETSEG
         END
