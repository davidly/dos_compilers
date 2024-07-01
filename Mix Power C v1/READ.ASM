;
;    Copyright (c) Mix Software 1988
;
; fread(buffer,itemsize,no_of_items,fp)
;    char *buffer;
;    int itemsize;
;    int no_of_items;
;    FILE *fp;
; { return (read(fp->fd,buffer,itemsize*no_of_items) / itemsize); }
;
         IDT  fread
         DEF  fread
         FREF read
fread    MOV  BX,SP
         MOV  SI,[BX][%PARM4-2]
         MOV  AX,[BX][%PARM2-2]
         MOV  CX,[BX][%PARM3-2]
         CMP  AX,1
         JZ   FREAD1SZ
         CMP  CX,%1
         JZ   FREAD1I
         MUL  CX
         PUSH AX
         PUSH [BX][%PARM1-2]
         PUSH [SI][FD$SIZE]
         CALLFAR read
         ADD  SP,%6
         MOV  BX,SP
         MOV  CX,[BX][%PARM2-2]
         CWD
         DIV  CX
         RETSEG
;
;  Item size is 1
;
FREAD1SZ PUSH CX
         PUSH [BX][%PARM1-2]
         PUSH [SI][FD$SIZE]
         CALLFAR read
         ADD  SP,%6
         RETSEG
;
;  Number of items is 1
;
FREAD1I  PUSH AX
         PUSH [BX][%PARM1-2]
         PUSH [SI][FD$SIZE]
         CALLFAR read
         ADD  SP,%6
         MOV  BX,SP
         CMP  AX,[BX][%PARM2-2]
         JZ   ONE
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
;  read(fd, buffer, n)
;      int n;
;      int fd;
;      char *buffer;
;
         IDT  read
         DEF  read
         FREF _fflush
         FREF _getc
         REF  _iob
         REF  _fileerr
read     PUSH BP
         MOV  BP,SP
;
;   FILE *fp = _iob[fd];
;
         MOV  SI,[BP][%PARM1]
         ADD  SI,SI
         ADD  SI,_iob
         MOV  SI,[SI]
;
; if (fp == NULL || !fp->file.init || !fp->file.openflg) return 0;
;
;        TEST SI,SI                            ; File ok?
;        JZ   ENDFL
;        CMP  %[SI][%FD$INIT],%0
;        JZ   ENDFL
;        CMP  %[SI][%FD$OPEN],%0
;        JZ   ENDFL
;
;   if (fp->file.dirty & fdwrite) {
;       if (_fflush(fp) != 0) return 0;
;       }
;
         TEST %[SI][%FD$DIRTY],%FL$WRITE
         JZ   NOFLUSH
         PUSH SI
         CALLFAR _fflush
         POP  SI
         TEST AX,AX
         JNZ  ENDFL
;
;       if (fp->file.flags & fdfilter) {
;          if (!(fp->file.flags & fdctlz)) {
;
NOFLUSH  MOV  AL,[SI][%FD$FLAGS]
         TEST AL,%FL$LFEED
         JZ   NOCR
;
; Read and filter carriage return (but not ctlz)
;
;             while (n-- != 0) {
;                 c = _getc(fp);
;                 while (c == RETURN) c = _getc(fp);
;                 if (c==EOF) {
;                     readcount = readcount-n-1;
;                     n = 0;
;                     }
;                 else *buffer++ = c;
;                 }
;
;  bx = file
;  si = file buffer
;  di = buffer address
;  dx = count remaining
;  cx = buffer count
;
         MOV  BX,SI
         MOV  DI,[BP][%PARM2]
         MOV  DX,[BP][%PARM3] ; Requested count
         TEST DX,DX
         JZ   DONE1
         MOV  SI,[BX][%FD$PTR]
         MOV  CX,[BX][%FD$COUNT]
         TEST AL,%FL$CTLZ
         JNZ  CR_CTLZ
         JCXZ MORE1
         MOV  AX,DS
         MOV  ES,AX
COPY1    LODSB                ; Get a byte
NEXTCH1  CMP  AL,>0D
         JZ   SKIPCR1
         STOSB                ; Store in read buffer
         DEC  DX              ; count character read
         JZ   DONE1A          ; read complete
SKIPCR1  LOOP COPY1
MORE1    MOV  [BX][%FD$COUNT],CX      ; Use _getc to get more
         MOV  [BX][%FD$PTR],SI        ;    into buffer
         PUSH DX              ; Save context
         PUSH DI
         PUSH BX              ; Pass fp to _getc
         CALLFAR _getc
         MOV  BX,DS
         MOV  BX,BX
         POP  BX
         POP  DI
         POP  DX
         MOV  SI,[BX][%FD$PTR]
         MOV  CX,[BX][%FD$COUNT]
         INC  CX
         CMP  AX,-1
         JNZ  NEXTCH1
DONE1    MOV  AX,[BP][%PARM3]
         SUB  AX,DX
         POP  BP
         RETSEG
DONE1A   DEC  CX
DONE1B   MOV  [BX][%FD$COUNT],CX
         MOV  [BX][%FD$PTR],SI
         JCXZ DONE1
         MOV  %[BX][%FD$DIRTY],%FL$READ
         JMPS DONE1
ENDFL    XOR  AX,AX
         POP  BP
         RETSEG
;
;  No filtering for end of line characters
;
NOCR     TEST %[SI][%FD$FLAGS],%FL$CTLZ
         JZ   BINMODE
;
;             while (n-- != 0) {
;                 c = _getc(fp);
;                 if ((c==EOF) || (c == 0x1a) {
;                     readcount = readcount-n-1;
;                     n = 0; }
;                 else *buffer++ = c;
;
         MOV  CX,[BP][%PARM3]
         MOV  DI,[BP][%PARM2]
         JCXZ ENDFL3
CPYCTLZ  PUSH CX
         PUSH DI
         PUSH SI
         CALLFAR _getc
         POP  SI
         POP  DI
         POP  CX
         CMP  AX,-1
         JZ   ENDFL3
         CMP  AX,>001A
         JZ   ENDFL3
         MOV  %[DI],AL
         INC  DI
         LOOP CPYCTLZ
ENDFL3   MOV  AX,[BP][%PARM3]
         SUB  AX,CX
         POP  BP
         RETSEG
;
;
CR_CTLZ  JCXZ MORE2
COPY2    LODSB                ; Get a byte
NEXTCH2  CMP  AL,>0D
         JZ   SKIPCR2
         CMP  AL,>1A
         JZ   DONE1B
         MOV  %[DI],AL        ; Store in read buffer
         INC  DI
         DEC  DX              ; count character read
         JZ   DONE1A          ; read complete
SKIPCR2  LOOP COPY2
MORE2    MOV  [BX][%FD$COUNT],CX      ; Use _getc to get more
         MOV  [BX][%FD$PTR],SI        ;    into buffer
         PUSH DX              ; Save context
         PUSH DI
         PUSH BX              ; Pass fp to _getc
         CALLFAR _getc
         POP  BX
         POP  DI
         POP  DX
         MOV  SI,[BX][%FD$PTR]
         MOV  CX,[BX][%FD$COUNT]
         INC  CX
         CMP  AX,-1
         JNZ  NEXTCH2
         JMPS DONE1
;
;       if (movcount = fp->file.count) {
;           if (movcount > n) movcount = n;
;           movmem(fp->file.ptr,buffer,movcount);
;           buffer += movcount;
;           fp->file.ptr += movcount;
;           fp->file.count -= movcount;
;           n -= movcount;
;           }
;
BINMODE  TEST [SI][%FD$FLAGS],%FL$UNBUF
         JZ   BUFR
         JMP  NOBUFR
BUFR     XOR  DX,DX           ; already read is 0
         MOV  DI,[BP][%PARM2] ; buffer pointer
BINMOVE  MOV  CX,[SI][%FD$COUNT]
         JCXZ NOMOVE
         MOV  AX,[BP][%PARM3]
         SUB  AX,DX           ; Additional needed
         CMP  CX,AX
         JB   MOVEALL
         MOV  CX,AX           ; Use only part of buffer
MOVEALL  PUSH CX
         MOV  AX,DS
         MOV  ES,AX
         PUSH SI
         MOV  SI,[SI][%FD$PTR]
         CLD
         REP
         MOVSB
         MOV  BX,SI
         POP  SI
         POP  CX
         SUB  [SI][%FD$COUNT],CX
         MOV  [SI][%FD$PTR],BX
;
;  CX contains count of moved characters
;
;       if (n) {
;           if (_sysabcd(0x3f00,fp->file.handle,n,buffer,&readcount) != 0) {
;               (*_fileerr)(readcount,fp);
;               return 0;
;               }
;           else {
;               if (readcount==0) fp->file.eofflag = 1;
;               return movcount+readcount;
;               }
;           }
;
NOMOVE   ADD  DX,CX
         MOV  CX,[BP][%PARM3]
         SUB  CX,DX           ; Characters left
         JCXZ DONE4
         CMP  CX,[SI][%FD$BUFSZ]
         JA   READDIR
         MOV  BX,[SI][%FD$HNDL]
         MOV  AX,>3F00
         PUSH DX
         MOV  DX,[SI][%FD$BUFR]
         MOV  [SI][%FD$PTR],DX
         MOV  CX,[SI][%FD$BUFSZ]
         INT  >21
         JNB  READOK1
FLERROR  PUSH SI
         PUSH AX
         MOV  BX,[_fileerr]
         CALLSEG [BX]
         ADD  SP,%4
         POP  DX
         MOV  [SI][%FD$COUNT],0
DONE4    MOV  AX,DX
         POP  BP
         RETSEG
READOK1  POP  DX
         MOV  [SI][%FD$COUNT],AX
         TEST AX,AX
         JZ   DONE4
         JMPS BINMOVE
;
READDIR  MOV  AX,[SI][%FD$BUFR]
         MOV  [SI][%FD$PTR],AX
         MOV  [SI][%FD$COUNT],0
         MOV  AX,>3F00
         MOV  BX,[SI][%FD$HNDL]
         MOV  CX,[BP][%PARM3]
         SUB  CX,DX
         PUSH DX
         MOV  DX,DI
         INT  >21
         JB   FLERROR
         POP  DX
         ADD  AX,DX
         POP  BP
         RETSEG
;
NOBUFR   MOV  DI,[BP][%PARM2]
         TEST [SI][%FD$FLAGS],FL$BIN
         JZ   NOBUFR0
         XOR  DX,DX
         JMPS READDIR
NOBUFR0  MOV  CX,[BP][%PARM3]
         JCXZ ENDFL5
UNBUF    PUSH CX
         PUSH DI
         PUSH SI
         CALLFAR _getc
         POP  SI
         POP  DI
         POP  CX
         CMP  AX,-1
         JZ   ENDFL5
;        CMP  AX,>001A
;        JZ   ENDFL5
         MOV  %[DI],AL
         INC  DI
         LOOP UNBUF
ENDFL5   MOV  AX,[BP][%PARM3]
         SUB  AX,CX
         POP  BP
         RETSEG
         END
