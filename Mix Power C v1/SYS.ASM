;
;   Copyright (c) Mix Software 1988
;
; -------------------------------------------------------
;    msdos call routines
; -------------------------------------------------------
;        _sys_acd(axval,cxval,dxval,axaddr)
;             axval = value to pass in ax
;             axaddr = address for result returned in ax
;             cxval = value to pass in cx
;             dxval = value to pass in dx
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sys_acd
         IF   UPPER
         DEF  _SYS_ACD
         ENDIF
         DEF  _sys_acd
         DREF _doserrno
;
_sys_acd equ  $
_SYS_ACD PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  CX,[BP][%PARM2]
         MOV  DX,[BP][%PARM3]
         INT  >21
         MOV  BX,[BP][%PARM4]
         MOV  [BX],AX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sysacdc(axval,cxval,dxval,cxaddr)
;             axval = value to pass in ax
;             cxaddr = address for result returned in cx
;             cxval = value to pass in cx
;             dxval = value to pass in dx
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sysacdc
         IF   UPPER
         DEF  _SYSACDC
         ENDIF
         DEF  _sysacdc
         DREF _doserrno
;
_sysacdc equ  $
_SYSACDC PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  CX,[BP][%PARM2]
         MOV  DX,[BP][%PARM3]
         INT  >21
         MOV  BX,[BP][%PARM4]
         MOV  [BX],CX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sys_ad(axval,dxval,axaddr)
;             axval = value to pass in ax
;             axaddr = address for result returned in ax
;             dxval = value to pass in dx
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sys_ad
         IF   UPPER
         DEF  _SYS_AD
         ENDIF
         DEF  _sys_ad
         DREF _doserrno
;
_sys_ad  equ  $
_SYS_AD  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         INT  >21
         MOV  BX,[BP][%PARM3]
         MOV  [BX],AX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sys_add(axval,dxval,dxaddr)
;             axval = value to pass in ax
;             dxaddr = address for result returned in dx
;             dxval = value to pass in dx
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sys_add
         IF   UPPER
         DEF  _SYS_ADD
         ENDIF
         DEF  _sys_add
         DREF _doserrno
;
_sys_add equ  $
_SYS_ADD PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         INT  >21
         MOV  BX,[BP][%PARM3]
         MOV  [BX],DX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sys_al(axval)
;             axval = value to pass in ah:al
;        returns result from al
; -------------------------------------------------------
;
         IDT  _sys_al
         IF   UPPER
         DEF  _SYS_AL
         ENDIF
         DEF  _sys_al
;
_sys_al  equ  $
_SYS_AL  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         INT  >21
         XOR  AH,AH
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sys_adx(axval,dxval)
;             axval = value to pass in ah:al
;             dxval = value to pass in dh:dl
;        returns zero
; -------------------------------------------------------
;
         IDT  _sys_adx
         IF   UPPER
         DEF  _SYS_ADX
         ENDIF
         DEF  _sys_adx
;
_sys_adx equ  $
_SYS_ADX PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         INT  >21
         XOR  AX,AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sys_abcd(axval,bxval,cxval,dxval,axaddr)
;             axval = value to pass in ax
;             axaddr = address for result returned in ax
;             bxval = value to pass in bx
;             cxval = value to pass in cx
;             dxval = value to pass in dx
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sysabcd
         IF   UPPER
         DEF  _SYSABCD
         ENDIF
         DEF  _sysabcd
         DREF _doserrno
;
_sysabcd equ  $
_SYSABCD PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  BX,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         MOV  DX,[BP][%PARM4]
         INT  >21
         MOV  BX,[BP][%PARM5]
         MOV  [BX],AX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sys_ab(axval,bxval,axaddr)
;             axval = value to pass in ax
;             axaddr = address for result returned in ax
;             bxval = value to pass in bx
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sys_ab
         IF   UPPER
         DEF  _SYS_AB
         ENDIF
         DEF  _sys_ab
         DREF _doserrno
;
_sys_ab  equ  $
_SYS_AB  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  BX,[BP][%PARM2]
         INT  >21
         MOV  BX,[BP][%PARM3]
         MOV  [BX],AX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sysdxdi(axval,dxval,dival,axaddr)
;             axval = value to pass in ax
;             axaddr = address for result returned in ax
;             dxval = value to pass in dx
;             dival = value to pass in di
;             es set to ds before call
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sysdxdi
         IF   UPPER
         DEF  _SYSDXDI
         ENDIF
         DEF  _sysdxdi
         DREF _doserrno
;
_sysdxdi equ  $
_SYSDXDI PUSH BP
         MOV  BP,SP
         MOV  AX,DS
         MOV  ES,AX
         MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         MOV  DI,[BP][%PARM3]
         INT  >21
         MOV  BX,[BP][%PARM4]
         MOV  [BX],AX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        _sysdxsi(axval,dxval,sival,axaddr)
;             axval = value to pass in ax
;             axaddr = address for result returned in ax
;             dxval = value to pass in dx
;             sival = value to pass in si
;             es set to ds before call
;        returns zero if successful, non-zero on error
; -------------------------------------------------------
;
         IDT  _sysdxsi
         IF   UPPER
         DEF  _SYSDXSI
         ENDIF
         DEF  _sysdxsi
         DREF _doserrno
;
_sysdxsi equ  $
_SYSDXSI PUSH BP
         MOV  BP,SP
         MOV  AX,DS
         MOV  ES,AX
         MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         MOV  SI,[BP][%PARM3]
         INT  >21
         MOV  BX,[BP][%PARM4]
         MOV  [BX],AX
         JB   ERROR
         XOR  AX,AX
         POP  BP
         RETSEG
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        asm(address,bx)
;             char *addresss; /* address in data segment */
;             int *bx;        /* bx value */
;        returns AX
; -------------------------------------------------------
;
         IDT  asm
         IF   UPPER
         DEF  ASM
         ENDIF
         DEF  asm
;
asm      equ  $
ASM      PUSH BP
         MOV  BP,SP
         MOV  AX,CS
         PUSH AX              ; place far return address on stack
         JMP  SETUP
DO       MOV  AX,DSRETURN     ; near return address
         PUSH AX
         PUSH DS              ; far call address
         PUSH [BP][%PARM1]    ; offset
         MOV  BX,[BP][%PARM2]
         RETSEG               ; do the subroutine
SETUP    CALL DO              ; places return address on stack
         POP  BP
         CLD
         RETSEG
         DORG 0
DSRETURN RETSEG
         END
;
; ============================================================
;
; typedef union {
;   struct {
;      char al, ah, bl, bh, cl, ch, dl, dh;
;   } byte;
;   struct {
;      int ax, bx, cx, dx, si, di, bp, es, ds, cs;
;   } word;
;  } REGS;
;
; -------------------------------------------------------
;        asmx(address,reg)
;             char *addresss; /* address in data segment */
;             REGS *reg;      /* registers */
;        returns 8086 flags register
; -------------------------------------------------------
;
         IDT  asmx
         IF   UPPER
         DEF  ASMX
         ENDIF
         DEF  asmx
;
asmx     equ  $
ASMX     PUSH BP
         MOV  BP,SP
         MOV  AX,CS
         PUSH AX              ; place far return address on stack
         JMP  SETUP
DO       MOV  AX,[BP][%PARM1] ; offset
         MOV  BP,[BP][%PARM2]
         MOV  BX,[BP][%18]    ; CS for call
         PUSH BX
         PUSH AX
         MOV  BX,[BP][%14]
         MOV  ES,BX
         MOV  BX,DS
         XCHG BX,[BP][%16]
         MOV  DS,BX
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         MOV  BP,[BP][%12]
         RETSEG               ; do the subroutine
SETUP    CALL DO              ; places return address on stack
         PUSH BP
         MOV  BP,SP
         MOV  BP,[BP][%PARM2+2]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         POP  AX
         MOV  [BP][%12],AX
         MOV  AX,ES
         MOV  [BP][%14],AX
         MOV  AX,DS
         XCHG AX,[BP][%16]
         MOV  DS,AX
         MOV  AX,CS
         MOV  [BP][%18],AX
         PUSHF
         POP  AX
         POP  BP
         CLD
         RETSEG
         END
;
; -------------------------------------------------------
;        bdos(fn,dx, al);
;             int fn;      /* function number */
;             unsigned dx; /* register contents for dx */
;             unsigned al; /* value to pass in al */
;        returns 8086 ax register
; -------------------------------------------------------
;
         IDT  bdos
         IF   UPPER
         DEF  BDOS
         ENDIF
         DEF  bdos
;
bdos     equ  $
BDOS     PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  AH,AL
         MOV  DX,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         MOV  AL,CL
         INT  >21
         JB   CARRY
         POP  BP
         RETSEG
CARRY    MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        bdosptr(fn,dx, al);
;             int fn;      /* function number */
;             void *dsdx;  /* pegister contents for dx */
;             unsigned al; /* value to pass in al */
;        returns 8086 ax register
; -------------------------------------------------------
;
         IDT  bdosptr
         IF   UPPER
         DEF  BDOSPTR
         ENDIF
         DEF  bdosptr
;
bdosptr  equ  $
BDOSPTR  PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  AH,AL
         MOV  DX,[BP][%PARM2]
         MOV  CX,[BP][%PARM3]
         MOV  AL,CL
         INT  >21
         JB   CARRY
         POP  BP
         RETSEG
CARRY    MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        bdosx(fn,reg);
;             int fn;      /* function number */
;             REGS *reg;   /* register contents */
;        returns 8086 flags register
; -------------------------------------------------------
;
         IDT  bdosx
         IF   UPPER
         DEF  BDOSX
         ENDIF
         DEF  bdosx
;
bdosx    equ  $
BDOSX    PUSH BP
         MOV  BP,SP
         MOV  CX,[BP][%PARM1]
         MOV  BP,[BP][%PARM2]
         MOV  AX,[BP][%0]
         MOV  AH,CL
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         INT  >21
         MOV  BP,SP
         MOV  BP,[BP][%PARM2]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         PUSHF
         POP  AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        bios(intn, reg);
;             int intn;    /* software interrupt number */
;             REGS *reg;   /* register contents */
;        returns 8086 flags register
;        passes ax,bx,cx,dx only
; -------------------------------------------------------
;
         IDT  bios
         IF   UPPER
         DEF  BIOS
         ENDIF
         DEF  bios
;
bios     equ  $
BIOS     PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  SI,INSTRINT
         MOV  [SI][%1],AL                      ; set interrupt no
         MOV  BX,CS
         PUSH BX
         JMPS SETUP
DO       PUSH DS
         MOV  AX,INSTRINT
         PUSH AX
         MOV  BP,[BP][%PARM2]
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         RETSEG
SETUP    CALL DO
         MOV  BP,SP
         MOV  BP,[BP][%PARM2]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         PUSHF
         POP  AX
         POP  BP
         CLD
         RETSEG
         DORG 0
INSTRINT INT  >21
INSTRRET RETSEG
         END
;
; -------------------------------------------------------
;        biosx(intn, reg);
;             int intn;    /* software interrupt number */
;             REGS *reg;   /* register contents */
;        returns 8086 flags register
;        passes all registers
; -------------------------------------------------------
;
         IDT  biosx
         IF   UPPER
         DEF  BIOSX
         ENDIF
         DEF  biosx
;
biosx    equ  $
BIOSX    PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  SI,INSTRINT
         MOV  [SI][%1],AL                      ; set interrupt no
         MOV  BX,CS
         PUSH BX
         JMPS SETUP
DO       PUSH DS
         MOV  AX,INSTRINT
         PUSH AX
         MOV  BP,[BP][%PARM2]
         MOV  BX,[BP][%14]
         MOV  ES,BX
         MOV  BX,DS
         XCHG BX,[BP][%16]
         MOV  DS,BX
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         MOV  BP,[BP][%12]
         RETSEG
SETUP    CALL DO
         PUSH BP
         MOV  BP,SP
         MOV  BP,[BP][%PARM2+2]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         POP  AX
         MOV  [BP][%12],AX
         MOV  AX,ES
         MOV  [BP][%14],AX
         MOV  AX,DS
         XCHG AX,[BP][%16]
         MOV  DS,AX
         MOV  AX,CS
         MOV  [BP][%18],AX
         PUSHF
         POP  AX
         POP  BP
         CLD
         RETSEG
         DORG 0
INSTRINT INT  >21
         RETSEG
         END
;
;
; ============================================================
;
;  Microsoft C compatable dos call routines
;
;  struct WORDREGS {
;       unsigned int ax;
;       unsigned int bx;
;       unsigned int cx;
;       unsigned int dx;
;       unsigned int si;
;       unsigned int di;
;       unsigned int cflag;
;       };
;  struct BYTEREGS {
;       unsigned char al, ah;
;       unsigned char bl, bh;
;       unsigned char cl, ch;
;       unsigned char dl, dh;
;       };
;  union REGS {
;       struct WORDREGS x;
;       struct BYTEREGS h;
;       };
;
;  struct SREGS {
;       unsigned int es;
;       unsigned int cs;
;       unsigned int ss;
;       unsigned int ds;
;       };
;
; -------------------------------------------------------
;     int intdos(inreg, outregs);
;        union REGS *inregs;
;        union REGS *outregs;
;     returns the value of ax as result
;     if carry set, doserrno also contains error code
; -------------------------------------------------------
;
         IDT  intdos
         IF   UPPER
         DEF  INTDOS
         ENDIF
         DEF  intdos
         DREF _doserrno
;
intdos   equ  $
INTDOS   PUSH BP
         MOV  BP,SP
         MOV  BP,[BP][%PARM1]
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         INT  >21
         MOV  BP,SP
         MOV  BP,[BP][%PARM2]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         MOV  [BP][%12],0
         JNB  DONE
         MOV  [_doserrno],AX
         MOV  [BP][%12],1
DONE     POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;     int intdosx(inreg, outregs, segregs);
;        union REGS *inregs;
;        union REGS *outregs;
;        struct SREGS *segregs;
;     returns the value of ax as result
;     if carry set, doserrno also contains error code
; -------------------------------------------------------
;
         IDT  intdosx
         IF   UPPER
         DEF  INTDOSX
         ENDIF
         DEF  intdosx
         DREF _doserrno
;
intdosx  equ  $
INTDOSX  PUSH BP
         MOV  BP,SP
         MOV  BP,[BP][%PARM3]                  ; Segments
         MOV  AX,ES
         XCHG AX,[BP][%0]
         MOV  ES,AX
         MOV  AX,DS
         XCHG AX,[BP][%6]
         MOV  DS,AX
         MOV  BP,SP
         MOV  BP,[BP][%PARM1]
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         INT  >21
         MOV  BP,SP
         MOV  BP,[BP][%PARM2]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         MOV  [BP][%12],0
         MOV  BP,SP
         MOV  BP,[BP][%PARM3]                  ; Restore segments
         MOV  DX,DS
         XCHG DX,[BP][%6]
         MOV  DS,DX
         MOV  DX,ES
         XCHG DX,[BP][%0]
         MOV  ES,DX
         MOV  BP,SP
         MOV  BP,[BP][%PARM2]
         JNB  DONE                             ; flags still set from int21
         MOV  [_doserrno],AX
         MOV  [BP][%12],1
DONE     POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;     int int86(intno, inreg, outregs);
;        int intno;
;        union REGS *inregs;
;        union REGS *outregs;
;     returns the value of ax as result
;     if carry set, doserrno also contains error code
; -------------------------------------------------------
;
         IDT  int86
         IF   UPPER
         DEF  INT86
         ENDIF
         DEF  int86
         DREF _doserrno
;
int86    equ  $
INT86    PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  SI,INSTRINT
         MOV  [SI][%1],AL
         MOV  AX,CS
         PUSH AX
         MOV  BP,[BP][%PARM2]
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         CALL DOINT
         MOV  BP,SP
         MOV  BP,[BP][%PARM3]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         MOV  [BP][%12],0
         JNB  DONE
         MOV  [_doserrno],AX
         MOV  [BP][%12],1
DONE     POP  BP
         RETSEG
DOINT    PUSH DS
         MOV  BP,INSTRINT
         PUSH BP
         RETSEG
         DORG 0
INSTRINT INT  >21
         RETSEG
         END
;
; -------------------------------------------------------
;     int intdosx(intno, inreg, outregs, segregs);
;        int intno;
;        union REGS *inregs;
;        union REGS *outregs;
;        struct SREGS *segregs;
;     returns the value of ax as result
;     if carry set, doserrno also contains error code
; -------------------------------------------------------
;
         IDT  int86x
         IF   UPPER
         DEF  INT86X
         ENDIF
         DEF  int86x
         DREF _doserrno
;
int86x   equ  $
INT86X   PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         MOV  SI,INSTRINT
         MOV  [SI][%1],AL
         MOV  BX,CS
         PUSH BX
         JMPS SETUP
DOINT    PUSH DS
         MOV  AX,INSTRINT
         PUSH AX
         MOV  SI,[BP][%PARM4]                  ; Segments
         MOV  AX,ES
         XCHG AX,[SI][%0]
         MOV  ES,AX
         MOV  AX,DS
         XCHG AX,[SI][%6]
         MOV  DS,AX
         MOV  BP,[BP][%PARM2]
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         RETSEG
SETUP    CALL DOINT
         MOV  BP,SP
         MOV  BP,[BP][%PARM3]
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         MOV  [BP][%12],0
         MOV  BP,SP
         MOV  BP,[BP][%PARM4]                  ; Restore segments
         MOV  DX,DS
         XCHG DX,[BP][%6]
         MOV  DS,DX
         MOV  DX,ES
         XCHG DX,[BP][%0]
         MOV  ES,DX
         MOV  BP,SP
         MOV  BP,[BP][%PARM3]
         JNB  DONE                             ; flags still set from int21
         MOV  [_doserrno],AX
         MOV  [BP][%12],1
DONE     POP  BP
         RETSEG
         DORG 0
INSTRINT INT  >21
         RETSEG
         END
;
; -------------------------------------------------------
;     void segread(segregs)
;        struct SREGS *segregs;
;     returns the contents of the segment registers
; -------------------------------------------------------
;
         IDT  segread
         DEF  segread
         IF   UPPER
         DEF  SEGREAD
         ENDIF
;
segread  equ  $
SEGREAD  MOV  SI,SP
         MOV  SI,[SI][%PARM1-2]
         MOV  [SI],ES
         MOV  [SI][%2],CS
         MOV  [SI][%4],SS
         MOV  [SI][%6],DS
         RETSEG
         END
;
; -------------------------------------------------------
;     int getdseg()
;     returns the contents of the data segment register
; -------------------------------------------------------
;
         IDT  getdseg
         DEF  getdseg
         IF   UPPER
         DEF  GETDSEG
         ENDIF
;
getdseg  equ  $
GETDSEG  MOV  AX,DS
         RETSEG
         END
;
; -------------------------------------------------------
;     int getcseg()
;     returns the contents of the data segment register
; -------------------------------------------------------
;
         IDT  getcseg
         DEF  getcseg
         IF   UPPER
         DEF  GETCSEG
         ENDIF
;
getcseg  equ  $
GETCSEG  MOV  SI,SP
         MOV  AX,[SI][%2]
         RETSEG
         END
;
; -------------------------------------------------------
;  #define FP_SEG(farptr) (*((unsigned *)&(farptr) + 1))
;     return the segment part of a far pointer
; -------------------------------------------------------
;
         IDT  FP_SEG
         DEF  FP_SEG
;
FP_SEG   MOV  SI,SP
         MOV  AX,[SI][%PARM1-2+2]
         RETSEG
         END
;
; -------------------------------------------------------
;  #define FP_OFF(farptr) (*((unsigned *)&(farptr)))
;     return the offset part of a far pointer
; -------------------------------------------------------
;
         IDT  FP_OFF
         DEF  FP_OFF
;
FP_OFF   MOV  SI,SP
         MOV  AX,[SI][%PARM1-2]
         RETSEG
         END
;
; -------------------------------------------------------
;  char far *FP_SET(segment, offset)
;     create a far pointer from segment and offset
; -------------------------------------------------------
;
         IDT  FP_SET
         DEF  FP_SET
;
FP_SET   MOV  SI,SP
         MOV  DX,[SI][%PARM1-2]
         MOV  AX,[SI][%PARM2-2]
         RETSEG
         END
;
; -------------------------------------------------------
;  char far *MK_FP(segment, offset)
;     create a far pointer from segment and offset
; -------------------------------------------------------
;
         IDT  MK_FP
         DEF  MK_FP
;
MK_FP    MOV  SI,SP
         MOV  DX,[SI][%PARM1-2]
         MOV  AX,[SI][%PARM2-2]
         RETSEG
         END
;
;
; ============================================================
;
;  Aztec C compatable dos call routines
;
;       static struct regval {
;          int ax, bx, cx, dx;
;          int si, di, ds, es;
;
; -------------------------------------------------------
;     int sysint(interrupt, inreg, outregs);
;        struct regval *inregs;
;        struct regval *outregs;
;     returns the value of ax as result
; -------------------------------------------------------
;
         IDT  sysint
         IF   UPPER
         DEF  SYSINT
         ENDIF
         DEF  sysint
;
sysint   equ  $
SYSINT   PUSH BP
         MOV  BP,SP
         PUSH DS
         MOV  AX,[BP][%14]
         MOV  ES,AX
         MOV  AX,[BP][%12]
         MOV  DS,AX
         MOV  AX,[BP][%PARM2]
         PUSH AX
         MOV  BP,[BP][%PARM1]
         MOV  AX,[BP][%0]
         MOV  BX,[BP][%2]
         MOV  CX,[BP][%4]
         MOV  DX,[BP][%6]
         MOV  SI,[BP][%8]
         MOV  DI,[BP][%10]
         INT  >21
         POP  BP
         MOV  [BP][%0],AX
         MOV  [BP][%2],BX
         MOV  [BP][%4],CX
         MOV  [BP][%6],DX
         MOV  [BP][%8],SI
         MOV  [BP][%10],DI
         MOV  DX,DS
         MOV  [BP][%12],DX
         MOV  DX,ES
         MOV  [BP][%14],DX
         POP  DX
         MOV  DS,DX
         PUSHF
         POP  AX
         POP  BP
         RETSEG
         END
;
; -------------------------------------------------------
;        $_stkchk check for stack overflow
; -------------------------------------------------------
;
         IDT  $_STKCHK
         DEF  $_STKCHK
         DREF $$MAXS
         DREF $$LIMIT
         FREF exit
;
$_STKCHK MOV  [$$MAXS],SP
         CMP  SP,[$$LIMIT]
         JNB  OK
         MOV  AX,>4000        ; Write message to stderr
         MOV  BX,2
         MOV  CX,MSGLEN
         MOV  DX,STKMSG
         INT  >21
         MOV  AX,>0081
         CALLFAR exit
OK       RETSEG
         DORG $
STKMSG   DB   'Out of stack',>0D,>0A
MSGLEN   EQU  $-STKMSG
         END
