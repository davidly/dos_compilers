UNIT Storage;
(*$//CODE:L//DATA:M*)

(* Converted from the Modula-2 heap manager used in all StonyBrook programs *)
(* Multiple operating system version support removed, DOS only *)
(* Multitasking support removed, Pascal doesn't support multitasking *)

INTERFACE

TYPE
    HeapErrorCodes	= (DoRuntimeError, ReturnNIL, TryAgain);
    HeapErrorProc	= FUNCTION(a:WORD) : HeapErrorCodes;
TYPE
    FreeBlockPtr	= ^FreeBlock;
    FreeBlock		= RECORD
			    size : WORD;
			    next : FreeBlockPtr;
			    prev : FreeBlockPtr;
			  END;
TYPE
    HeapInfoPointer = ^HeapInfo;
    HeapInfo =
	RECORD
	    freeBlocks		: WORD;
	    freeList		: FreeBlockPtr;
	    segmentList		: FreeBlockPtr;
	    memoryInUse		: LONGINT;
	    maxMemoryUsed	: LONGINT;
	    heapError		: HeapErrorProc;
	    debug		: BOOLEAN;
	    locked		: BOOLEAN;
	    combine		: BOOLEAN;
	    strategy		: WORD;
	END;

(* this will initialize/reinitialize the heap manager *)

PROCEDURE StorageInit;

(* set the heap manager to use the specified heap *)

PROCEDURE UseHeap(heap : HeapInfoPointer);

(* returns the current heap system *)

FUNCTION GetHeap() : HeapInfoPointer;

(* swaps the specified heap with the current heap *)
(* the specified heap becomes the current heap *)

PROCEDURE SwapHeaps(VAR heap : HeapInfoPointer);

(* initalizes/reinitializes the current heap *)

PROCEDURE InitHeap;

(* allocate memory from the current heap *)
(* the system has a 10 byte minimum allocation to maintain internal *)
(* overhead when the block is in a deallocated state. *)
(* also any size requested is rounded up to an even number and *)
(* a WORD of storage is added to the allocation, for block overhead *)
(* this WORD stores the size of the allocated block *)
(* and the blocks allocated/deallocated state *)
(* do not try to access this WORD *)
(* examples. 12 -> 14, 13 -> 16, 4 -> 10 *)
(* if SetDebug = TRUE then the block will be initialied with NIL *)

PROCEDURE GetMem(VAR adr : POINTER; size : WORD);

(* deallocate memory to the current heap *)
(* the pointer passed with be set with NIL upon return *)
(* verifies that the block has not already been deallocated *)
(* SetDebug = TRUE will make sure that the block *)
(* being deallocated is "owned" by this heap, and the block will *)
(* initialized with NIL *)

PROCEDURE FreeMem(VAR adr : POINTER; size : WORD);

(* returns TRUE if the requested amount of memory can be allocated *)

FUNCTION Available(size : WORD) : BOOLEAN;

(* largest block of memory available in the current heap *)

FUNCTION MaxAvail() : LONGINT;

(* total amount of memory available from the current heap *)

FUNCTION MemAvail() : LONGINT;

(* amount of memory currently used by the current heap *)

FUNCTION MemoryInUse() : LONGINT;

(* the high water mark of memory used for the current heap *)

FUNCTION MaxMemoryUsed() : LONGINT;

(* install a HeapError handler *)

PROCEDURE SetHeapError(err : HeapErrorProc);

(* set debug mode of heap system *)
(* Default is FALSE *)
(* when TRUE all allocated blocks will be initialized with NIL *)
(* also upon deallocation, a check is made that the memory being *)
(* deallocated is "owned" by the heap *)

PROCEDURE SetDebug(debug : BOOLEAN);

(* freeze the current heap to it present size *)
(* no more allocations from the OS allowed *)

PROCEDURE FreezeHeap(fix : BOOLEAN);

(* return all memory blocks back to the OS *)

PROCEDURE FreeHeap;

(* an instant DEALLOCATE everything, while not returning memory to the OS *)
(* extremely fast way to deallocate a bunch of stuff *)

PROCEDURE ClearHeap;

(* set block combining on or off *)
(* default is TRUE *)
(* do not set to FALSE unless the heap always allocates blocks of the same *)
(* size, or even multiples. Remember the two byte block overhead *)
(* thus even multiples should have two bytes extra per multiple *)
(* example 256, 512+2, 768+2+2, etc... *)

(* nothing will break if you use this improperly, memory will just run out *)
(* fast and things will run real sloooooooooooow *)

PROCEDURE SetCombine(comb : BOOLEAN);

CONST
    FirstFit	= 0;
    LastFit	= 2;

(* set the DOS allocation strategy for the current heap *)
(* default is FirstFit *)
    
PROCEDURE SetStrategy(s : WORD);

IMPLEMENTATION
(*$//INLINE:N*)

USES Dos;

CONST
    MaxSegmentSize	= 65536;
    BlockOverhead	= 2;
    SegOverhead		= 8;
    MinBlockSize	= 10;
    MaxBlockSize	= MaxSegmentSize - SegOverhead - BlockOverhead;
    AllocSegmentSize	= 8 * 1024 + 16;

VAR
    StdHeap		: HeapInfo;
    CurHeap		: HeapInfoPointer;

CONST
    ErrDisposeOfFree= 204;
    ErrStorageError = 204;
    OutOfStorage    = 203;

FUNCTION StdHeapError(size : WORD) : HeapErrorCodes; FAR;
BEGIN
    StdHeapError := DoRuntimeError;
END;

PROCEDURE RuntimeError(code : WORD; str : STRING);
BEGIN
    RunError(code);
END;

PROCEDURE FillBlock(adr : POINTER);
TYPE
    WordPtr	= ^WORD;
VAR
    size	: WORD;
BEGIN
    size := WordPtr(adr)^ - 2;
    WORD(adr) := WORD(adr) + 2;
    FillChar(adr^, size, 0);
END;

FUNCTION OSALLOC(VAR size : WORD) : POINTER;
VAR
    adr		: POINTER;
    r		: REGISTERS;
    save1	: WORD;
    save2	: WORD;
BEGIN
    (* compute size in 16 byte segments *)

    size := size + SegOverhead;
    save1 := size;
    size := size DIV 16;
    IF size = 0 THEN
	size := 4096
    ELSE IF (save1 MOD 16) <> 0 THEN
	INC(size);
    
    (* if size less than Granularity then, alloc Granularity *)
    
    IF size < AllocSegmentSize DIV 16 THEN
	size := AllocSegmentSize DIV 16;
    
    r.AX := $5800;
    INTR($21, r);
    save1 := r.AX;

    r.AX := $5801;
    r.BX := CurHeap^.strategy;
    INTR($21, r);

    (* get a block of memory, size*16 bytes, from DOS *)
    
    r.AH := $48;
    r.BX := size;
    INTR($21, r);
    
    IF (FCarry AND r.FLAGS) = 1 THEN BEGIN
    
	(* error, if there is some available then grab it *)

	IF (r.AX = 8) AND (r.BX <> 0) THEN BEGIN
	    r.AH := $48;
	    INTR($21, r);
	END ELSE
	    r.AX := 0;
    END;
    
    adr := NIL;
    IF r.AX <> 0 THEN BEGIN
	size := r.BX * 16;
	adr := Ptr(r.AX, 0);
    END;

    r.AX := $5801;
    r.BX := save1;
    INTR($21, r);
    
    OSALLOC := adr;
END;

PROCEDURE OSDEALLOC(adr : POINTER);
VAR
    r : REGISTERS;
BEGIN
    r.AH := $49;
    r.ES := Seg(adr^);
    INTR($21, r);
END;

FUNCTION OSAVAIL() : LONGINT;
VAR
    R : REGISTERS;
BEGIN
    R.AX := $4800;
    R.BX := $0FFFF;
    INTR($21, R);
    OSAVAIL := LONGINT(R.BX) * 16;
END;

PROCEDURE InsertBlock(block : FreeBlockPtr);
BEGIN
    INC(CurHeap^.freeBlocks);
    IF CurHeap^.freeList <> NIL THEN BEGIN
	block^.next := CurHeap^.freeList;
	block^.prev := CurHeap^.freeList^.prev;
	block^.prev^.next := block;
	CurHeap^.freeList^.prev := block;
	CurHeap^.freeList := block;
    END ELSE BEGIN
	block^.next := block;
	block^.prev := block;
	CurHeap^.freeList := block;
    END;
END;

PROCEDURE RemoveBlock(block : FreeBlockPtr);
BEGIN
    DEC(CurHeap^.freeBlocks);
    IF CurHeap^.freeBlocks <> 0 THEN BEGIN
	block^.prev^.next := block^.next;
	block^.next^.prev := block^.prev;
	
	IF CurHeap^.freeList = block THEN
	    CurHeap^.freeList := CurHeap^.freeList^.next;
    END ELSE
	CurHeap^.freeList := NIL;
END;

PROCEDURE AddBlock(VAR list : FreeBlockPtr;
		 	ptr : FreeBlockPtr;
		       size : WORD);
BEGIN
    (* build our list of allocated blocks from the OS *)
    
    ptr^.size := size;
    ptr^.next := list;
    list := ptr;
    
    WORD(ptr) := WORD(ptr) + 6;

    (* set the allocatable size of this block *)

    ptr^.size := size-SegOverhead;
    
    (* put it in the FreeList *)

    InsertBlock(ptr);
    
    (* put an allocated block at the end of this *)
    (* so that block combining will not go ballistic *)

    WORD(ptr) := WORD(ptr) + ptr^.size;
    ptr^.size := 3;
END;

FUNCTION GetMore(size : WORD) : BOOLEAN;
VAR
    block : POINTER;
BEGIN
    GetMore := FALSE;
    IF NOT CurHeap^.locked THEN BEGIN
	block := OSALLOC(size);
	IF block = NIL THEN
	    EXIT;
	AddBlock(CurHeap^.segmentList, block, size);
	GetMore := TRUE;
    END;
END;

FUNCTION FindBlockC(size : WORD) : POINTER;
VAR
    i		: WORD;
    testblock	: FreeBlockPtr;
    combblock	: FreeBlockPtr;
BEGIN
    FindBlockC := NIL;
    
    REPEAT
	i := CurHeap^.freeBlocks;
	testblock := CurHeap^.freeList;
	
	IF i <> 0 THEN BEGIN
	    REPEAT
		DEC(i);
    
		combblock := testblock;
		WORD(combblock) := WORD(combblock) + testblock^.size;
		
		IF (combblock^.size AND 1) = 1 THEN BEGIN
		    IF testblock^.size < size THEN
			testblock := testblock^.next
		    ELSE BEGIN
			FindBlockC := testblock;
			EXIT;
		    END;
		END ELSE BEGIN
		    (* combine the blocks *)
		    
		    INC(testblock^.size, combblock^.size);
		    RemoveBlock(combblock);
		    INC(i);
		END;
	    UNTIL i = 0;
	END;
    UNTIL NOT GetMore(size);
END;

FUNCTION FindBlockNC(size : WORD) : POINTER;
VAR
    i		: WORD;
    testblock	: FreeBlockPtr;
BEGIN
    FindBlockNC := NIL;
    
    REPEAT
	i := CurHeap^.freeBlocks;
	testblock := CurHeap^.freeList;
	
	WHILE (i <> 0) AND (testblock^.size < size) DO BEGIN
	    testblock := testblock^.next;
	    DEC(i);
	END;
	
	IF i <> 0 THEN BEGIN
	    FindBlockNC := testblock;
	    EXIT;
	END;
    UNTIL NOT GetMore(size);
END;

PROCEDURE GetMem(VAR adr : POINTER; size : WORD);
VAR
    i		: WORD;
    lSize	: WORD;
    testblock	: FreeBlockPtr;
BEGIN
    IF size <= MaxBlockSize THEN BEGIN
    
	(* adjust size for overhead and minimum *)
    
	lSize := size + 3;
	lSize := lSize AND $0FFFE;
	IF lSize < MinBlockSize THEN
	    lSize := MinBlockSize;
	
	IF CurHeap^.combine THEN
	    testblock := FindBlockC(lSize)
	ELSE
	    testblock := FindBlockNC(lSize);
	    
	IF testblock <> NIL THEN BEGIN

	    (* make the freeList be a rover by .next *)
	    (* try to evenly distribute allocations across all freeblocks *)

	    CurHeap^.freeList := testblock^.next;

	    IF testblock^.size - lSize <= MinBlockSize THEN
		RemoveBlock(testblock)
	    ELSE BEGIN
		testblock^.size := testblock^.size - lSize;
		WORD(testblock) := WORD(testblock) + testblock^.size;
		testblock^.size := lSize;
	    END;
	    
	    INC(CurHeap^.memoryInUse, testblock^.size);
	    IF CurHeap^.memoryInUse > CurHeap^.maxMemoryUsed THEN
		CurHeap^.maxMemoryUsed := CurHeap^.memoryInUse;
	    
	    IF CurHeap^.debug THEN
		FillBlock(testblock);
	    
	    (* make the blocksize odd, so we can find it in a combine operation *)
	    
	    INC(testblock^.size);
    
	    (* inc POINTER past our blocksize field *)
	    
	    adr := testblock;
	    WORD(adr) := WORD(adr) + BlockOverhead;
	    
	    EXIT;
	END;
    END;
    CASE CurHeap^.heapError(size) OF
	DoRuntimeError:
	    RuntimeError(OutOfStorage, 'Out of storage');
	ReturnNIL:
	    adr := NIL;
	TryAgain:
	    GetMem(adr, size);
    END;
END;

PROCEDURE FreeMem(VAR adr : POINTER; size : WORD);
VAR
    ladr	: FreeBlockPtr;
    ptr		: FreeBlockPtr;
BEGIN
    ladr := adr;
    WORD(ladr) := WORD(ladr) - BlockOverhead;    
    
    IF CurHeap^.debug THEN BEGIN
	
	(* check to see if this is a block we are managing *)
	
	ptr := CurHeap^.segmentList;
	WHILE (ptr <> NIL) AND (Seg(ptr^) <> Seg(ladr^)) DO
	    ptr := ptr^.next;

	IF ptr = NIL THEN
	    RuntimeError(ErrStorageError, 'deallocate of unowned memory')
	ELSE
	    FillBlock(ladr);
    END;
    
    IF (ladr^.size AND 1) <> 1 THEN BEGIN
	RuntimeError(ErrDisposeOfFree, 'Dispose of Free Block');
	EXIT;
    END;
    
    DEC(ladr^.size);
    DEC(CurHeap^.memoryInUse, ladr^.size);
    
    InsertBlock(ladr);
    
    adr := NIL;
END;

FUNCTION Available(size : WORD) : BOOLEAN;
BEGIN
    (* adjust size for overhead and minimum *)
    
    size := size + 3;
    size := size AND $0FFFE;
    IF size < MinBlockSize THEN
	size := MinBlockSize;
    
    IF CurHeap^.combine THEN
	Available := FindBlockC(size) <> NIL
    ELSE
	Available := FindBlockNC(size) <> NIL;
END;

FUNCTION MaxAvail() : LONGINT;
VAR
    i		: WORD;
    size	: LONGINT;
    testblock	: FreeBlockPtr;
BEGIN
    size := OSAVAIL() - SegOverhead;
    
    IF size < MaxBlockSize THEN BEGIN
	i := CurHeap^.freeBlocks;
	testblock := CurHeap^.freeList;
    
	WHILE i <> 0 DO BEGIN
	    IF testblock^.size-BlockOverhead > WORD(size) THEN
		size := testblock^.size-BlockOverhead;
	    DEC(i);
	    testblock := testblock^.next;
	END;
    END;
    MaxAvail := size;
END;

FUNCTION MemAvail() : LONGINT;
VAR
    i		: WORD;
    size	: LONGINT;
    testblock	: FreeBlockPtr;
BEGIN
    size := OSAVAIL() - SegOverhead;
    
    i := CurHeap^.freeBlocks;
    testblock := CurHeap^.freeList;

    WHILE i <> 0 DO BEGIN
	size := size + LONGINT(testblock^.size) - BlockOverhead;
	DEC(i);
	testblock := testblock^.next;
    END;
    MemAvail := size;
END;

FUNCTION MemoryInUse() : LONGINT;
BEGIN
    MemoryInUse := CurHeap^.memoryInUse;
END;

FUNCTION MaxMemoryUsed() : LONGINT;
BEGIN
    MaxMemoryUsed := CurHeap^.maxMemoryUsed;
END;

PROCEDURE SetHeapError(err : HeapErrorProc);
BEGIN
    CurHeap^.heapError := err;
END;

PROCEDURE UseHeap(heap : HeapInfoPointer);
BEGIN
    CurHeap := heap;
END;

FUNCTION GetHeap() : HeapInfoPointer;
BEGIN
    GetHeap := CurHeap;
END;

PROCEDURE SwapHeaps(VAR heap : HeapInfoPointer);
VAR
    temp : HeapInfoPointer;
BEGIN
    temp := CurHeap;
    CurHeap := heap;
    heap := temp;
END;

PROCEDURE InitHeap;
BEGIN
    CurHeap^.locked := FALSE;
    CurHeap^.debug := FALSE;
    CurHeap^.combine := TRUE;
    CurHeap^.strategy := 0;
    
    CurHeap^.freeBlocks := 0;
    CurHeap^.memoryInUse := 0;
    CurHeap^.maxMemoryUsed := 0;
    CurHeap^.freeList := NIL;
    CurHeap^.segmentList := NIL;
    CurHeap^.heapError := StdHeapError;
END;

PROCEDURE FreeHeap;
VAR
    save : POINTER;
BEGIN
    WHILE CurHeap^.segmentList <> NIL DO BEGIN
	save := CurHeap^.segmentList^.next;
	OSDEALLOC(CurHeap^.segmentList);
	CurHeap^.segmentList := save;
    END;
    
    CurHeap^.freeBlocks := 0;
    CurHeap^.memoryInUse := 0;
    CurHeap^.freeList := NIL;
    CurHeap^.segmentList := NIL;
END;

PROCEDURE ClearHeap;
VAR
    ptr		: FreeBlockPtr;
    save	: POINTER;
BEGIN
    ptr := CurHeap^.segmentList;
    CurHeap^.freeList := NIL;
    CurHeap^.segmentList := NIL;
    
    (* build the new segment list *)

    WHILE ptr <> NIL DO BEGIN
	save := ptr^.next;
	AddBlock(CurHeap^.segmentList, ptr, ptr^.size);
	ptr := save;
    END;
    
    CurHeap^.memoryInUse := 0;
END;

PROCEDURE SetCombine(comb : BOOLEAN);
BEGIN
    CurHeap^.combine := comb;
END;

PROCEDURE SetDebug(debug : BOOLEAN);
BEGIN
    CurHeap^.debug := debug;
END;

PROCEDURE FreezeHeap(fix : BOOLEAN);
BEGIN
    CurHeap^.locked := fix;
END;

PROCEDURE SetStrategy(s : WORD);
BEGIN
    CurHeap^.strategy := s;
END;

PROCEDURE StorageInit;
VAR
    R : REGISTERS;
BEGIN
    CurHeap := @StdHeap;
    InitHeap;
END;

END.
