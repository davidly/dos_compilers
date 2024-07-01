;
; Far heap functions.
;
;   Copyright (c) Mix Software 1988
;
;  Extended memory heap
;
         GLOBAL
;
MINHEAP  EQU  4               ; Minimum size of a heap
;
;    Heap descriptor:
;
H$FREE   EQU  0
H$MIN    EQU  2
H$MAX    EQU  4
H$CURUSE EQU  6
H$MAXUSE EQU  8
;
;    Packet pointer points to previous paragraph
;    All packets have length at offset >0E
;    Allocated flag is at offset >0D
;    Free packets have pointer to prior and next in data area
;
H$LEN    EQU  >000E           ; Length of packet
H$AVAIL  EQU  >000D           ; 1 = available, 0=allocated
H$SUCC   EQU  >0010           ; Pointer to next packet
H$PRED   EQU  >0012           ; Pointer to previous packet
;
         ENDGLOBAL
;
;
; ----------------------------------------------------------
;
;   FALLOC
;        allocate a packet from extended heap
;        called as a C function:
;           char far *falloc(size)
;              unsigned size;       /* size in bytes */
;        returns address of packet or 0 if none available
;
         IDT  falloc
         IF   UPPER
         DEF  FALLOC
         ENDIF
         DEF  falloc
         FREF _FALLOC
         FREF fnewheap
         DREF $$FARHP
falloc   EQU  $
FALLOC   CMP  [$$FARHP],0
         JNZ  OK
         MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,-1
         PUSH AX
         CALLFAR fnewheap
         ADD  SP,%4
OK       MOV  AX,$$FARHP
         PUSH AX
         MOV  SI,SP
         MOV  AX,[SI][%PARM1]
         ADD  AX,2+1+15       ; Reserve two bytes for length,
;                             ;    one byte for available flag,
         AND  AL,%#F0         ;    and round up to paragraph boundary
         MOV  CL,4            ; Convert size to paragraphs
SHIFT    SHR  AX,CL
         PUSH AX
         CALLFAR _FALLOC
         ADD  SP,%4
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   FCALLOC
;        allocate a packet from extended heap
;        called as a C function:
;           char far *fcalloc(number,size)
;              unsigned number;     /* number of elements */
;              unsigned size;       /* size of an element in bytes */
;        returns address of packet or 0 if none available
;
         IDT  fcalloc
         IF   UPPER
         DEF  FCALLOC
         ENDIF
         DEF  fcalloc
         FREF _FALLOC
         FREF fnewheap
         DREF $$FARHP
fcalloc  equ  $
FCALLOC  CMP  [$$FARHP],0
         JNZ  OK
         MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,-1
         PUSH AX
         CALLFAR fnewheap
         ADD  SP,%4
OK       MOV  AX,$$FARHP
         PUSH AX
         MOV  SI,SP
         MOV  AX,[SI][%PARM1]
         MUL  [SI][%PARM2]
         ADD  AX,2+1+15       ; Reserve two bytes for length,
;                             ;    one byte for available flag,
         ADC  DX,%0
         AND  AL,%#F0         ;    and round up to paragraph boundary
         MOV  CX,4            ; Convert size to paragraphs
SHIFT    SHR  DX,1
         RCR  AX,1
         LOOP SHIFT
         PUSH AX
         CALLFAR _FALLOC
         ADD  SP,%4
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   farcalloc
;        allocate a packet from extended heap
;        called as a C function:
;           void far *farcalloc(number,size)
;              unsigned long number;     /* number of elements */
;              unsigned long size;       /* size of an element in bytes */
;        returns address of packet or 0 if none available
;
         IDT  farcallo
         IF   LONGNAME
         LDEF farcalloc
         ENDIF
         IF   SHORTNAM
         DEF  Fcalloc
         ENDIF
         FREF _FALLOC
         FREF fnewheap
         FREF $_LUMUL
         DREF $$FARHP
farcalloc equ $
Fcalloc  PUSH BP
         MOV  BP,SP
         CMP  [$$FARHP],0
         JNZ  OK
         MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,-1
         PUSH AX
         CALLFAR fnewheap
         ADD  SP,%4
OK       MOV  AX,$$FARHP
         PUSH AX
         PUSH [BP][%PARM4]
         PUSH [BP][%PARM3]
         PUSH [BP][%PARM2]
         PUSH [BP][%PARM1]
         CALLFAR $_LUMUL      ; Number of items * size
         ADD  SP,%8
         ADD  AX,2+1+15       ; Reserve two bytes for length,
;                             ;    one byte for available flag,
         ADC  DX,%0
         AND  AL,%#F0         ;    and round up to paragraph boundary
         MOV  CX,4            ; Convert size to paragraphs
SHIFT    SHR  DX,1
         RCR  AX,1
         LOOP SHIFT
         PUSH AX
         CALLFAR _FALLOC
         ADD  SP,%4
         POP  BP
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   void far *farrealloc(void far *block, newsize)
;        void far *block  -  previous pointer to block
;        unsigned long newsize - requested size
;        return the new pointer
;
         IDT  farreall
         IF   LONGNAME
         LDEF farrealloc
         LFREF farmalloc
         ENDIF
         IF   SHORTNAM
         DEF  Frealloc
         FREF Fmalloc
         ENDIF
         FREF _FFREE
         FREF _FALLOC
         DREF $$FARHP
farrealloc EQU $
Frealloc PUSH BP
         MOV  BP,SP
         MOV  AX,[BP][%PARM1]
         OR   AX,[BP][%PARM2]
         JZ   MALLOC
         CMP  [$$FARHP],0
         JZ   NULL1
         MOV  AX,[BP][%PARM3]        ; New size
         MOV  DX,[BP][%PARM4]
         ADD  AX,2+1+15       ; allow extra for length, flag
         ADC  DX,%0
         AND  AL,%#F0         ; round up to paragraph boundary
         MOV  CX,4            ; Convert size to paragraphs
SHIFT    SHR  DX,1
         RCR  AX,1
         LOOP SHIFT
         MOV  BX,[BP][%PARM2] ; segment part of old pointer
         DEC  BX              ; point to block header
         MOV  ES,BX
         SEGES
         CMP  %[H$AVAIL],0
         JNZ  NULL1           ; This is not a valid block
         SEGES
         MOV  DX,[H$LEN]      ; Old length
         CMP  AX,DX
         JZ   SAME1
         JA   EXPAND
         JMP  SHRINK          ; Make smaller
NULL1    JMP  NULL
MALLOC   PUSH [BP][%PARM4]
         PUSH [BP][%PARM3]
         IF   LONGNAME
         CALLFAR farmalloc
         ENDIF
         IF   ~LONGNAME
         callfar Fmalloc
         ENDIF
         ADD  SP,%4
         POP  BP
         RETFAR
EXPAND   MOV  SI,BX
         ADD  SI,DX           ; Next block header
         MOV  ES,SI
         SEGES
         CMP  %[H$AVAIL],0
         JZ   MOVE
         MOV  CX,AX
         SUB  CX,DX           ; additional space needed
         SEGES
         CMP  CX,[H$LEN]
         JA   MOVE            ; Not enough space in next block
;
;  Expand in place
;        CX = size needed, ES is next block, AX = new size
;
         SEGES                ; Allocate entire next block
         MOV  AX,[H$PRED]
         SEGES
         MOV  BX,[H$SUCC]
         JNZ  PARTIAL
         SEGES
         MOV  CX,[H$LEN]
         MOV  ES,AX
         SEGES
         MOV  [H$SUCC],BX
         MOV  ES,BX
         SEGES
         MOV  [H$PRED],AX
ADJUST   MOV  AX,[BP][%PARM2]
         DEC  AX
         MOV  ES,AX
         SEGES
         ADD  [H$LEN],CX      ; adjust size
         MOV  SI,[$$FARHP]
         MOV  AX,[SI][%H$CURUSE]
         MOV  [SI][%H$CURUSE],CX
         CMP  AX,[SI][%H$MAXUSE]
         JBE  ADJDONE
         MOV  [SI][%H$MAXUSE],CX
SAME1    EQU  $
ADJDONE  JMP  SAME
;
;  Allocate a part of the next block
;     ES = next block, AX = predecessor, BX = successor
;
PARTIAL  SEGES
         MOV  DX,[H$LEN]
         SUB  DX,CX           ; New length
         MOV  SI,ES
         ADD  SI,CX
         MOV  ES,SI           ; address of reduced block
         SEGES
         MOV  [H$LEN],DX
         SEGES
         MOV  [H$PRED],AX
         SEGES
         MOV  [H$SUCC],BX
         SEGES
         MOV  %[H$AVAIL],%1
         MOV  ES,AX
         SEGES
         MOV  [H$SUCC],SI
         MOV  ES,BX
         SEGES
         MOV  [H$PRED],SI
         JMPS ADJUST
;
;  relocate the block - ES points to the old block
;     AX is the new size (in paragraphs)
;
MOVE     PUSH ES
         PUSH [$$FARHP]
         PUSH AX
         CALLFAR _FALLOC      ; allocate a new block
         ADD  SP,%4
         POP  BX              ; recover original segment
         TEST AX,AX
         JZ   NULL            ; Not enough space
         MOV  ES,BX
         SEGES
         MOV  DX,[H$LEN]      ; Length of old data
         INC  BX              ; Segment address of old data
         PUSH AX
         PUSH DS
COPYBLK  MOV  DS,BX
         MOV  ES,AX
         CMP  DX,>0800        ; Is size > 32k
         JB   COPYLAST
         MOV  CX,>4000        ; Move a 32k block
         REP
         MOVSW
         ADD  BX,>0800
         ADD  AX,>0800
         SUB  DX,>0800
         JMPS COPYBLK
COPYLAST CMP  DX,%0           ; Move partial block
         JZ   COPYDONE
         SHL  DX,1
         SHL  DX,1
         SHL  DX,1
         MOV  CX,DX
         REP
         MOVSW
COPYDONE POP  AX
         MOV  DS,AX
         PUSH [$$FARHP]       ; Release old block
         PUSH [BX][%PARM2]
         CALLFAR _FFREE
         ADD  SP,%4
         POP  DX              ; Segment of new block
         XOR  AX,AX
         POP  BP
         RETFAR
;
;  decrease size of block
;        DX = old length, AX = new length
;
SHRINK   SEGES
         MOV  [H$LEN],AX      ; Adjust length
         MOV  BX,ES
         ADD  BX,AX           ; Part to be released
         MOV  ES,BX
         SEGES                ; Make new allocated block
         MOV  %[H$AVAIL],%0   ;    from excess memory
         SUB  DX,AX
         SEGES
         MOV  [H$LEN],DX
         PUSH [$$FARHP]       ; heap descriptor
         PUSH ES              ; block to be released
         CALLFAR _FFREE       ; release the excess space
         ADD  SP,%4
;   return pointer to original block
SAME     MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         POP  BP
         RETFAR
NULL     XOR  AX,AX
         XOR  DX,DX
         POP  BP
         RETFAR
         END
;
; ----------------------------------------------------------
;
;   farmalloc
;        allocate a packet from extended heap
;        called as a C function:
;           void far *farmalloc(size)
;              unsigned long size;
;        returns address of packet or 0 if none available
;
         IDT  farmalloc
         IF   LONGNAME
         LDEF farmalloc
         ENDIF
         IF   SHORTNAM
         DEF  Fmalloc
         ENDIF
         FREF _FALLOC
         FREF fnewheap
         DREF $$FARHP
farmalloc equ $
Fmalloc  PUSH BP
         MOV  BP,SP
         CMP  [$$FARHP],0
         JNZ  OK
         MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,-1
         PUSH AX
         CALLFAR fnewheap
         ADD  SP,%4
OK       MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,[BP][%PARM1]
         MOV  DX,[BP][%PARM2]
         ADD  AX,2+1+15       ; Reserve two bytes for length,
;                             ;    one byte for available flag,
         ADC  DX,%0
         AND  AL,%#F0         ;    and round up to paragraph boundary
         MOV  CX,4            ; Convert size to paragraphs
SHIFT    SHR  DX,1
         RCR  AX,1
         LOOP SHIFT
         PUSH AX
         CALLFAR _FALLOC
         ADD  SP,%4
         POP  BP
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   HALLOC
;        allocate a packet from extended heap
;        called as a C function:
;           char far *halloc(number,size)
;              long number;     /* number of elements */
;              unsigned size;   /* size of an element in bytes */
;        returns address of packet or 0 if none available
;
         IDT  halloc
         IF   UPPER
         DEF  HALLOC
         ENDIF
         DEF  halloc
         FREF _FALLOC
         FREF fnewheap
         DREF $$FARHP
halloc   equ  $
HALLOC   CMP  [$$FARHP],0
         JNZ  OK
         MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,-1
         PUSH AX
         CALLFAR fnewheap
         ADD  SP,%4
OK       MOV  AX,$$FARHP
         PUSH AX
         MOV  SI,SP
         MOV  AX,[SI][%PARM2]
         MUL  [SI][%PARM3]
         MOV  CX,AX
         MOV  AX,[SI][%PARM1]
         MUL  [SI][%PARM3]
         ADD  DX,CX
         ADD  AX,2+1+15       ; Reserve two bytes for length,
;                             ;    one byte for available flag,
         ADC  DX,%0
         AND  AL,%#F0         ;    and round up to paragraph boundary
         MOV  CX,4            ; Convert size to paragraphs
SHIFT    SHR  DX,1
         RCR  AX,1
         LOOP SHIFT
         PUSH AX
         CALLFAR _FALLOC
         ADD  SP,%4
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   _fmsize(ptr) return size of the block
;      char far *ptr;
;
         IDT  _fmsize
         DEF  _fmsize
_fmsize  MOV  SI,SP
         MOV  BX,[SI][%PARM1-2]
         MOV  AX,[SI][%PARM2-2]
         DEC  AX
         MOV  ES,AX
         SEGES
         MOV  AX,[BX][H$LEN]
         MOV  CL,4
         SHL  AX,CL
         SUB  AX,3
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   long farcoreleft
;        return the amount of memory left in far heap
;
         IDT  farcorel
         IF   LONGNAME
         LDEF farcoreleft
         ENDIF
         IF   SHORTNAM
         DEF  farcorel
         ENDIF
         FREF fnewheap
         DREF $$FARHP
farcorel CMP  [$$FARHP],0
         JNZ  OK
         MOV  AX,$$FARHP
         PUSH AX
         MOV  AX,-1
         PUSH AX
         CALLFAR fnewheap
         ADD  SP,%4
OK       XOR  DX,DX
         MOV  SI,$$FARHP
         MOV  AX,[SI][H$MAX]
         SUB  AX,[SI][H$MIN]
         SUB  AX,[SI][H$CURUSE]
         MOV  CX,4
SHIFT    SHL  AX,1
         RCL  DX,1
         LOOP SHIFT
DONE     RETFAR
         END
;
; ----------------------------------------------------------
;
;   _FALLOC
;        allocate a packet from extended heap
;        called as a C function:
;           int _falloc(size,desc)
;              int size; /* size in paragraphs */
;              heapdesc *desc;  /* address of heap descriptor */
;        returns address of packet or 0 if none available
;                address is a 16 bit segment value
;
         IDT  _FALLOC
         DEF  _FALLOC
_FALLOC  PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM2] ; SI = Address of descriptor
         CMP  [SI],0
         JZ   NOSPACE
         MOV  DX,[BP][%PARM1] ; Size requested
         TEST DX,DX           ; Check for zero
         JNZ  FALLOC01
         INC  DX              ; Minimum size is one paragraph
;
;  Set BX to point to the current free list
;
FALLOC01 MOV  BX,[%H$FREE][SI]
;
;  Search free list for a packet of sufficient size
;
NEWLOOP  MOV  ES,BX
         SEGES
         CMP  DX,[H$LEN]      ; COMPARE LENGTHS
         JBE  FALLOC02
;
;   The current packet in the free list is not large enough
;   move to the next packet
;      ES contains the address of the current packet
;      DX contains the required size
;
FALLOC03 SEGES
         MOV  BX,[H$SUCC]     ; BX = next packet
         CMP  BX,[SI][%H$FREE]   ; All packets checked?
         JNZ  NEWLOOP         ; No packet is large enough
NOSPACE  XOR  BX,BX
         JMP  FALLOC08
;
;  The current packet is large enough
;    remove needed space & check result for > 0
;
FALLOC02 SEGES
         MOV  AX,[H$LEN]      ; GET PACKET SIZE
         SUB  AX,DX           ; SUBTRACT NEEDED SPACE
         JNZ  FALLOC04
;
;  Allocate entire packet
;     length is in DX, location is in BX,ES
;
         SEGES
         MOV  AX,[H$SUCC]     ; GET SUCCESSOR FIELD
         MOV  [SI][%H$FREE],AX ; NEW FREE LIST
         SEGES
         MOV  CX,[H$PRED]     ; CX = PREDECESSOR
;
;   LAST+2 := NEXT
;
         MOV  ES,CX
         SEGES
         MOV  [H$SUCC],AX
;
;   NEXT+4 := LAST
;
         MOV  ES,AX           ; Point to successor
         SEGES
         MOV  [H$PRED],CX     ; set next@.lat to cur@.last
         JMPS FALLOC05
;
;  Reduce the size of the packet
;    AX Contains the new length
;    DX Contains the length of the new packet
;    BX, ES point to the packet
;
;
FALLOC04 PUSH BX              ; SAVE CURRENT PACKET ADDR
         SEGES
         MOV  CX,[H$PRED]     ; Get links
         PUSH CX
         SEGES
         MOV  CX,[H$SUCC]
         ADD  BX,DX           ; BX <-- ADDR OF NEW FREE PKT
         MOV  ES,BX
         SEGES
         MOV  [H$LEN],AX      ; SET NEW LENGTH
         SEGES
         MOV  %[H$AVAIL],%1   ; MARK NOT ALLOCATED
;
;  SET SUCCESSOR OF NEW FREE PACKET TO SUCCESSOR OF OLD
;  FREE PACKET & PREDECESSOR OF NEW TO PREDECESSOR OF OLD
;
         SEGES
         MOV  [H$SUCC],CX
         POP  AX
         SEGES
         MOV  [H$PRED],AX
;
;  Link around newly allocated space
;     last@.next := newsp
;     next@.last := newsp
;
         MOV  ES,AX
         SEGES
         MOV  [H$SUCC],BX
         MOV  ES,CX
         SEGES
         MOV  [H$PRED],BX     ; NEXT@.PRED = NEW FREE PKT
         MOV  [SI][%H$FREE],CX
         POP  BX
;
;  AT THIS POINT DX CONTAINS THE LENGTH OF THE NEWLY ALLOCATED
;  PACKET, AND BX CONTAINS ITS ADDRESS
;
;  SET THE LENGTH OF THE NEWLY ALLOCATED PACKET.
;
FALLOC05 MOV  ES,BX
         SEGES
         MOV  [H$LEN],DX
         SEGES
         MOV  %[H$AVAIL],%0
         INC  BX              ; POINT TO DATA AREA
;
;  ADD SIZE OF CURRENT PACKET TO CURRENT HEAP ALLOCATED
;
         ADD  [SI][%H$CURUSE],DX ; ADD TO CURRENT ALLOCATION
         MOV  AX,[SI][%H$CURUSE] ; LARGER THAN MAX USED?
         CMP  AX,[SI][%H$MAXUSE]
         JB   FALLOC09
         MOV  [SI][%H$MAXUSE],AX ; SET MAXIMUM HEAP USED
;
;  Zero the memory, BX = segment, DX = length
;
FALLOC09 MOV  ES,BX
FALLOC11 TEST DX,>F800
         JZ   FALLOC10
         MOV  CX,>4000        ; zero 32k bytes (16k words)
         XOR  DI,DI
         XOR  AX,AX
         REP
         STOSW
         MOV  AX,ES
         ADD  AX,>0800
         MOV  ES,AX
         SUB  DX,>0800
         JMPS FALLOC11
FALLOC10 MOV  CL,4
         SHL  DX,CL
         SUB  DX,2+1          ; linkage for next packet
         MOV  CX,DX
         XOR  DI,DI
         XOR  AX,AX
         REP
         STOSB
FALLOC08 MOV  DX,BX
         XOR  AX,AX
         POP  BP
         RETSEG
;
         END
;
; ------------------------------------------------------------
;
;   FFREE
;        Release a packet in extended heap
;        called as a C function:
;           int ffree(ptr)
;              char far *ptr;   /* pointer value */
;        returns 0 if successful, -1 on error
;
;
         IDT  ffree
         IF   UPPER
         DEF  FFREE
         ENDIF
         DEF  ffree
         DEF  hfree
         DEF  farfree
         DREF $$FARHP
         FREF _FFREE
;
ffree    EQU  $
hfree    EQU  $
farfree  EQU  $
FFREE    MOV  SI,SP
         MOV  AX,[SI][%PARM2-2] ; segment value
         MOV  BX,[SI][%PARM1-2] ; Offset
         MOV  CX,AX
         OR   CX,BX
         JZ   NIL
;        TEST BX,BX
;        JNZ  INVALID         ; offset must be zero
         CMP  [$$FARHP],0
         JZ   INVALID         ; no far heap available
         MOV  BX,$$FARHP
         PUSH BX
         PUSH AX
         CALLFAR _FFREE
         ADD  SP,%4
         RETSEG
INVALID  MOV  AX,-1
         RETSEG
NIL      XOR  AX,AX
         RETSEG
         END
;
;
; ------------------------------------------------------------
;
;   _FFREE
;        Release a packet in extended heap
;        called as a C function:
;           int _ffree(ptr,desc)
;              int ptr;         /* pointer value (segment only) */
;              heapdesc *desc;  /* address of heap descriptor */
;        returns 0 if successful, -1 on error
;
;
         IDT  _FFREE
         DEF  _FFREE
;
_FFREE   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM2] ; SI = Address of descriptor
         MOV  BX,[BP][%PARM1] ; Pointer value
         TEST BX,BX
         JNZ  FREE01
         XOR  AX,AX
         POP  BP
         RETFAR
FREE01   DEC  BX              ; POINT TO LENGTH FIELD
;
;  CHECK POINTER AGAINST LOWER BOUND OF HEAP - ERROR IF LESS
;
         CMP  BX,[SI][%H$MIN]
         JBE  INVPKT1
;
;  GET LENGTH OF THE PACKET
;
FR01     MOV  ES,BX
         SEGES
         MOV  CX,[H$LEN]      ; Get length
         SEGES
         TEST %[H$AVAIL],%1
         JNZ  INVPKT1         ; NOT ALLOCATED
         MOV  AX,BX
         ADD  AX,CX           ; AX POINTS TO NEXT PACKET
;
;  CHECK PTR + SIZE OF PACKET AGAINST HEAP UPPER BOUND
;
         CMP  AX,[SI][%H$MAX]
         JBE  FR02
INVPKT1  JMP  INVPKT
;
;  BX = ADDRESS OF RELEASED PACKET
;  CX = SIZE OF RELEASED PACKET
;  AX = ADDRESS OF NEXT PACKET
;
;  PACKET IS VALID, RELEASE IT
;
FR02     SUB  [SI][%H$CURUSE],CX ; SUBTRACT FROM CURRENT
;
;  Is next packet allocated?
;
         CMP  AX,[SI][%H$MAX]
         JAE  FR04            ; Next packet is anchor
         MOV  ES,AX
         SEGES
         TEST %[H$AVAIL],%1   ; Check allocation flag
         JZ   FR03            ; Not available
;
;  Next packet is available, merge current and next packets
;
         SEGES
         MOV  DX,[H$LEN]      ; Get size of packet
         TEST DX,DX           ; CHECK FOR ZERO
         JZ   FR03            ; DON'T MERGE WITH ANCHOR
         ADD  CX,DX           ; CX = SIZE OF COMBINATION
;
;  ASSIGN FREELIST TO NEW PACKET
;
         MOV  [SI][%H$FREE],BX
;
;  Find the previous packet that is free and closest
;  to the packet being released
;
         SEGES
         MOV  AX,[H$SUCC]     ; GET NEXT FIELD FOR CURRENT
         SEGES
         MOV  DX,[H$PRED]     ; PREV LINK OF NEXT FREE PKT
;
;   AT THIS POINT:
;        BX = CURRENT PACKET
;        AX = NEXT PACKET
;        DX = PREVIOUS PACKET
;        CX = NEW LENGTH OF CURRENT
;
         JMPS FR06            ; CHECK FOR LAST PACKET FREE
;
;    Next packet is not available
;    find the next packet that is available to get
;    its last packet pointer
;        AX = NEXT PACKET
;        CX = PACKET SIZE
;        BX = CURRENT PACKET
;
FR03     SEGES
         MOV  DX,[H$LEN]      ; GET SIZE OF NEXT PACKET
         ADD  AX,DX
         CMP  AX,[SI][H$MAX]  ; Top of heap?
         JB   FR05
FR04     MOV  AX,[SI][%H$MIN] ; Wrap around to anchor
FR05     MOV  ES,AX
         SEGES
         TEST %[H$AVAIL],%1   ; CHECK FOR ALLOCATED
         JZ   FR03            ; LOOP UNTIL FREE
;
;  AX and SI now point to the next free packet
;  get the last pointer from the next packet
;
         SEGES
         MOV  DX,[H$PRED]
;
;   At this point:
;        AX = next free packet
;        BX = current packet
;        CX = current packet length
;        DX = last packet
;
;  Check last packet.  If the last free packet is contiguous
;  with the current packet, they can be merged into a single
;  packet.
;
FR06     PUSH AX              ; SAVE
         MOV  ES,DX
         SEGES
         MOV  AX,[H$LEN]      ; Length of previous pkt
         ADD  AX,DX           ; AX <-- LAST+SIZE(LAST)
         CMP  AX,BX
         JNZ  FR07            ; CAN NOT JOIN
;
;  The last packet is contiguous with the current packet,
;  merge them.
;
         SEGES
         ADD  [H$LEN],CX      ; Add lengths
         POP  AX
         SEGES
         MOV  [H$SUCC],AX     ; Set pointer to next
         MOV  ES,AX
         SEGES
         MOV  [H$PRED],DX     ; Set Next@.last to merged pkt
;
;      Set free list to merged packet
;
         MOV  [SI][%H$FREE],DX
         XOR  AX,AX
         POP  BP
         RETFAR
;
;
;  The last packet is not contiguous with the current packet
;  a new packet is created for the packet being released.
;
;    TOS = NEXT
;    BX  = CURRENT
;    DX  = PREVIOUS
;    CX  = LENGTH
;
FR07     MOV  ES,BX
         SEGES
         MOV  [H$LEN],CX      ; SET SIZE
         SEGES
         MOV  %[H$AVAIL],%1
         POP  AX
         SEGES
         MOV  [H$SUCC],AX     ; SET NEXT POINTER
         SEGES
         MOV  [H$PRED],DX     ; SET PREVIOUS
         MOV  ES,DX
         SEGES
         MOV  [H$SUCC],BX     ; SET PREV@.NEXT
         MOV  ES,AX
         SEGES
         MOV  [H$PRED],BX     ; SET NEXT@.LAST
         XOR  AX,AX
         POP  BP
         RETSEG
;
;  INVALID PACKET POINTER
;
INVPKT   MOV  AX,-1           ; Return -1 to indicate error
         POP  BP
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   FNEWHEAP
;        Allocate a new heap from the pool of extended memory
;        called as a C function:
;           int fnewheap(size, desc);
;              int size; /* size in paragraphs */
;              descriptor *desc; /* address of descriptor */
;        Fills in descriptor with heap parameters.
;        A size of >FFFF indicates allocate as much as possible.
;        Returns the size allocated, 0 if none.
;
         IDT  fnewheap
         IF   UPPER
         DEF  FNEWHEAP
         ENDIF
         DEF  fnewheap
         DREF $$MAXSEG        ; First unavailable paragraph
         DREF $$TOPSEG        ; First unused paragraph
fnewheap EQU  $
FNEWHEAP PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM2] ; SI = Address of descriptor
         MOV  CX,[BP][%PARM1] ; CX = requested size
         CMP  CX,MINHEAP
         JAE  SIZESET
         MOV  CX,MINHEAP           ; Set minimum size
SIZESET  CMP  CX,-1                ; Allow for anchor & final blk
         JZ   MAXSIZE
         ADD  CX,%2                ; Allow for anchor & final blk
MAXSIZE  MOV  AX,[$$TOPSEG]        ; First unused data
         MOV  DX,[$$MAXSEG]        ; Top of all memory
         CMP  AX,DX
         JAE  NOSPACE
         SUB  DX,AX           ; Total size available
         CMP  CX,DX
         JBE  ENOUGH          ; requested size is available
         CMP  DX,MINHEAP
         JB   NOSPACE
         MOV  CX,DX           ; Supply all remaining
ENOUGH   ADD  [$$TOPSEG],CX   ; Add size to top segment
         MOV  [SI][%H$MIN],AX ; Set heap bounds
         MOV  DX,[$$TOPSEG]
         DEC  DX
         MOV  [SI][%H$MAX],DX
         MOV  [SI][%H$CURUSE],0
         MOV  [SI][%H$MAXUSE],0
         MOV  DX,AX           ; Point to heap origin
         INC  AX              ; AX points to free space area
         MOV  [SI][%H$FREE],AX
;
;  Create the heap anchor
;
         MOV  BX,DS
         MOV  DS,DX           ; Point to anchor
         MOV  %[H$AVAIL],%1   ; Anchor is available
         MOV  [H$LEN],0       ; Length of packet is 0
         MOV  [H$SUCC],AX     ; Cicrular link to 2nd packet
         MOV  [H$PRED],AX     ; Cicrular link to 2nd packet
         MOV  DS,AX
         MOV  %[H$AVAIL],%1
         SUB  CX,%2           ; Remove size of anchor
         MOV  [H$LEN],CX
         MOV  [H$SUCC],DX     ; Cicrular link to anchor packet
         MOV  [H$PRED],DX     ; Cicrular link to anchor packet
         MOV  DS,BX
EXIT     POP  BP
         MOV  AX,CX
         RETSEG
NOSPACE  XOR  AX,AX           ; Return 0 for none available
         JMPS EXIT
         END
;
; ----------------------------------------------------------
;
;   FRELHEAP
;        Release a heap to the pool of extended memory
;        called as a C function:
;           int frelheap(desc);
;              descriptor *desc; /* address of descriptor */
;        Releases heap if it is the last item in extended memory.
;        Returns 0 if released, -1 if not at end of memory.
;
         IDT  frelheap
         IF   UPPER
         DEF  FRELHEAP
         ENDIF
         DEF  frelheap
         DREF $$MAXSEG        ; First unavailable paragraph
         DREF $$TOPSEG        ; First unused paragraph
frelheap EQU  $
FRELHEAP PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1] ; SI = Address of descriptor
         MOV  CX,[SI][H$MAX]  ; Top of this heap
         INC  CX              ; Address expected in $$TOPSEG
         CMP  CX,[$$TOPSEG]   ; Is this the top item?
         JNZ  NOTLAST
         MOV  CX,[SI][%H$MIN] ; Release to minimum
         MOV  [$$TOPSEG],CX
         XOR  AX,AX
         MOV  [SI],AX
         POP  BP
         RETSEG
NOTLAST  MOV  AX,-1
         POP  BP
         RETSEG
         END
;
; ----------------------------------------------------------
;
;  Shrink memory to allow loading other programs and
;  for memory resident programs.
;
;  int farsetsize(int farheap_needed)
;      one argument, amount of far heap requested
;      in paragraphs
;  Returns address of top of memory (segment)
;
         IDT  farsetsz
         IF   LONGNAME
         LDEF farsetsize
         ENDIF
         IF   SHORTNAM
         def  Fsetsize
         ENDIF
         REF  $$PSP
         REF  $$TOPSEG
         REF  $$ENDDS
         REF  $$MAXSEG
         REF  $$FARHP
         REF  _doserrno
         FREF _FHIGH
;
farsetsize EQU $
Fsetsize PUSH BP
         MOV  BP,SP
         MOV  DX,[BP][%PARM1]
         ADD  DX,[$$ENDDS]    ; Requested top of memory
         CMP  DX,[$$MAXSEG]   ; More than available?
         JAE  DONE
         CMP  DX,[$$TOPSEG]   ; More than allocated?
         JAE  SHRINK          ; Shrink to size
         CMP  [$$FARHP],0     ; Far heap in use?
         JZ   DONE            ; No, unable to shrink
         MOV  SI,$$FARHP
         MOV  CX,[SI][H$MAX]  ; Top of this heap
         INC  CX              ; Address expected in $$TOPSEG
         CMP  CX,[$$TOPSEG]   ; Is this the top item?
         JNZ  DONE            ; Far heap is not top item
         PUSH SI
         CALLFAR _FHIGH       ; find top packet
         POP  SI
         TEST AX,AX
         JZ   DONE            ; No free space in far heap
         SUB  AX,2            ; header of last free block
         MOV  DX,AX
         MOV  ES,AX
         MOV  CX,[BP][%PARM1]
         ADD  CX,[$$ENDDS]    ; Requested top of memory
         CMP  CX,DX
         JBE  MINIMUM         ; shrink to minimum size
         SUB  CX,AX           ; space to keep
         ADD  DX,CX
         MOV  [SI][%H$MAX],DX
         SEGES
         MOV  [H$LEN],CX
         INC  DX
         JMPS SHRINK
MINIMUM  INC  DX
         MOV  [SI][%H$MAX],DX
         INC  DX
         SEGES
         MOV  [H$LEN],1
;
;  Shrink memory and update system parameters
;  DX = top segment
;
SHRINK   MOV  [$$MAXSEG],DX
         CMP  DX,[$$TOPSEG]
         JAE  K1
         MOV  [$$TOPSEG],DX
K1       MOV  BX,DX
         SUB  BX,[$$PSP]      ; Size in use
         MOV  ES,[$$PSP]      ; Shrink memory
         SEGES
         MOV  [2],DX
         MOV  AX,>4A00
         INT  >21
         JB   ERROR
DONE     MOV  AX,[$$MAXSEG]   ; Total program size
         SUB  AX,[$$PSP]
         POP  BP
         RETFAR
ERROR    MOV  [_doserrno],AX
         MOV  AX,-1
         POP  BP
         RETFAR
         END
;
; ----------------------------------------------------------
;
;   _FMAX
;        find the address of free memory
;           int _FMAX()
;        returns segment address of first usable paragraph
;        in extended memory.  If the default far heap is at
;        the top of memory, any unused part of it is available.
;
         IDT  _FMAX
         DEF  _FMAX
         DREF $$FARHP
         DREF $$TOPSEG
         FREF _FHIGH
_FMAX    MOV  SI,$$FARHP
         CMP  [SI],0
         JZ   USEMEM
         MOV  CX,[SI][H$MAX]  ; Top of this heap
         INC  CX              ; Address expected in $$TOPSEG
         CMP  CX,[$$TOPSEG]   ; Is this the top item?
         JNZ  USEMEM
         PUSH SI
         CALLFAR _FHIGH
         POP  SI
         TEST AX,AX
         JZ   USEMEM
         ADD  AX,2            ; Preserve packet header
         RETSEG
USEMEM   MOV  AX,[$$TOPSEG]
         RETSEG
         END
;
; ----------------------------------------------------------
;
;   _FHIGH
;        find highest address currently in use
;        called as a C function:
;           int _FHIGH(desc)
;              int size; /* size in bytes */
;        returns address of highest packet or 0 if none
;
         IDT  _FHIGH
         DEF  _FHIGH
_FHIGH   PUSH BP
         MOV  BP,SP
         MOV  SI,[BP][%PARM1] ; SI = Address of descriptor
         MOV  BX,[SI][%H$FREE]  ; Search free space list
SRCH     MOV  ES,BX
         SEGES
         MOV  AX,[H$LEN]      ; Length of packet
         ADD  AX,BX           ; End of packet
         CMP  AX,[SI][%H$MAX] ; Does it go to end?
         JAE  FOUND
         SEGES
         MOV  BX,[H$SUCC]     ; Try next packet
         CMP  BX,[SI][%H$FREE]    ; full circle?
         JNZ  SRCH
         XOR  AX,AX           ; Return 0 for none available
         POP  BP
         RETSEG
;
;  Highest block has been found
;        return its address
;        First available paragraph is two greater
;
FOUND    ADD  BX,%2
         MOV  AX,BX
         POP  BP
         RETSEG
         END
;
; ----------------------------------------------------------
;
;  Default far heap data area
;     contains descriptor for far heap
;
         IDT  $$FARHP
         DDEF $$FARHP
         DORG $
$$FARHP  DW   0,0,0,0,0
         END
