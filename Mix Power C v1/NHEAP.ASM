;
;   Copyright (c) Mix Software 1988
;
;  --------------------------------------------------
;     _fmalloc - allocate from far heap
;        if no memory available, allocate from near heap
;        char far *_fmalloc(size)
;           unsigned size;
;  --------------------------------------------------
;
         IDT  _fmalloc
         DEF  _fmalloc
         FREF falloc
         FREF malloc
;
_fmalloc MOV  SI,SP
         PUSH [SI][%PARM1-2]
         CALLFAR falloc
         ADD  SP,%2
         MOV  CX,DX
         OR   CX,AX
         JNZ  OK
         MOV  SI,SP
         PUSH [SI][%PARM1-2]
         CALLFAR malloc
         ADD  SP,%2
         TEST AX,AX
         JZ   NULL
         MOV  DX,DS
OK       RETSEG
NULL     XOR  DX,DX
         RETSEG
         END
;
;  --------------------------------------------------
;     _ffree - release from near or far heap
;        void _ffree(ptr)
;           char far *ptr;
;  --------------------------------------------------
;
         IDT  _ffree
         DEF  _ffree
         FREF ffree
         FREF free
;
_ffree   MOV  SI,SP
         MOV  AX,[SI][%PARM2-2]
         MOV  CX,DS
         CMP  AX,CX
         JZ   NEAR
         PUSH AX
         PUSH [SI][%PARM1-2]
         CALLFAR ffree
         ADD  SP,%4
         RETSEG
NEAR     PUSH [SI][%PARM1-2]
         CALLFAR free
         ADD  SP,%2
         RETSEG
         END
;
;  --------------------------------------------------
;     _nmsize - return the size of a memory block
;        unsigned _nmsize(ptr)
;        char near *ptr;
;  --------------------------------------------------
;
         IDT  _nmsize
         DEF  _nmsize
         DEF  _msize
;
_msize   EQU  $
_nmsize  MOV  SI,SP
         MOV  BX,[SI][%PARM1-2]
         MOV  AX,[BX][%-2]    ; get size and allocated flag
         AND  AX,>FFFE
         SUB  AX,%2
         RETSEG
         END
;
;  --------------------------------------------------
;     _memavl - return the byte count of available memory
;        unsigned _memavl()
;  --------------------------------------------------
;
         IDT  _memavl
         REF  $$CURH
         REF  $$HMIN
         REF  $$HMAX
         DEF  _memavl
;
_memavl  MOV  AX,[$$HMAX]
         SUB  AX,[$$HMIN]
         SUB  AX,[$$CURH]
         SUB  AX,6
         RETSEG
         END
;
;  --------------------------------------------------
;     coreleft - return the byte count of available memory
;        unsigned coreleft()
;  --------------------------------------------------
;
         IDT  coreleft
         REF  $$CURH
         REF  $$HMIN
         REF  $$HMAX
         DEF  coreleft
;
coreleft MOV  AX,[$$HMAX]
         SUB  AX,[$$HMIN]
         SUB  AX,[$$CURH]
         SUB  AX,6
         RETSEG
         END
;
;  --------------------------------------------------
;     _freect - return the number of items in heap
;        unsigned _freect(size)
;             unsigned size;
;  --------------------------------------------------
;
         IDT  _freect
         REF  $$CURH
         REF  $$HMIN
         REF  $$HMAX
         DEF  _freect
;
_freect  MOV  AX,[$$HMAX]
         SUB  AX,[$$HMIN]
         SUB  AX,[$$CURH]
         SUB  AX,6
         MOV  BX,SP
         MOV  BX,[BX][%PARM1-2]
         XOR  DX,DX
         TEST BX,BX
         JZ   EXIT
         DIV  BX
EXIT     RETSEG
         END
;
;  --------------------------------------------------
;     _expand - expand a block of memory without moving it
;        _expand(ptr,size)
;        char *ptr;
;        unsigned size;   /* requested new size */
;  --------------------------------------------------
;
         IDT  _expand
         DEF  _expand
         IF   UPPER
         DEF  _EXPAND
         ENDIF
         REF  $$FREE
         REF  $$CURH
         REF  $$MAXH
         FREF free
;
_EXPAND  EQU  $
_expand  PUSH BP
         MOV  BP,SP
         MOV  BX,[BP][%PARM1]
         MOV  CX,[BX][%-2]    ; get size and allocated flag
         TEST CX,>0001
         JZ   AVAIL
         SUB  CX,%3           ; remove flag and overhead
         CMP  CX,[BP][%PARM2]
         JB   EXPAND          ; Make larger
;
;  Try to shrink the block
;        If shrink is by at least 6 bytes, create a new pointer
;        and use free to release it.
;
SHRINK   SUB  CX,[BP][%PARM2]
         NEG  CX
         AND  CX,>FFFE        ; Must be an even number
         CMP  CX,%6
         JB   FREEOK          ; Not enough to free
         SUB  [BX][%-2],CX    ; Remove from this block count
         ADD  BX,[BX][%-2]    ; Point to end of block
         DEC  BX              ;   remove allocated flag
         INC  CX
         MOV  [BX][%-2],CX    ; create allocated block header
         PUSH BX
         CALLFAR free
         POP  BX
         MOV  AX,[BP][%PARM1]
         POP  BP
         RETSEG
;
;  Try to expand the block.
;    the next higher block must be free
;
EXPAND   MOV  SI,[$$FREE]     ; Start of free list
         MOV  DX,SI
         ADD  BX,CX           ; Point to next block header
SEARCH   CMP  SI,BX           ; Found next block?
         JZ   FOUND
         MOV  SI,[SI][%2]     ; Move to next free block
         CMP  SI,DX           ; Full circuit?
         JNZ  SEARCH
         JMPS NULLEXIT        ; unable to expand
FOUND    CMP  [SI],6
         JBE  NULLEXIT        ; protect anchor
         MOV  DI,[SI][%4]     ; predecessor
         MOV  BX,[SI][%2]     ; successor
         MOV  [DI][%2],BX
         MOV  [BX][%4],DI     ; block linked out
         MOV  CX,[SI]         ; length of the free block
         ADD  [$$CURH],CX
         MOV  AX,[$$CURH]
         CMP  AX,[$$MAXH]
         JBE  ADJUST
         MOV  [$$MAXH],AX
ADJUST   MOV  BX,[BP][%PARM1] ; merge block
         ADD  CX,[BX][%-2]
         MOV  [BX][%-2],CX    ; Blocks are merged
         SUB  CX,%3
         JMPS SHRINK          ; Return the excess
;
;  Block is free - it has therefore already become as large as
;     possible.  Check size to generate return value
;
AVAIL    SUB  CX,%2
         CMP  CX,[BP][%PARM2]
         JAE  FREEOK          ; Large enough
NULLEXIT XOR  AX,AX
         POP  BP
         RETSEG
FREEOK   MOV  AX,BX
         POP  BP
         RETSEG
         END
;
;  --------------------------------------------------
;     heapsiz - return the byte count of available memory
;        unsigned heapsiz()
;  --------------------------------------------------
;
         IDT  heapsiz
         REF  $$CURH
         REF  $$HMIN
         REF  $$HMAX
         DEF  heapsiz
;
heapsiz  MOV  AX,[$$HMAX]
         SUB  AX,[$$HMIN]
         SUB  AX,[$$CURH]
         SUB  AX,6
         RETSEG
         END
