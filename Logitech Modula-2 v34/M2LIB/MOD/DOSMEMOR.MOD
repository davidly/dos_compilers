(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *) 
(*    DOSMemory - DOS memory management compatible with M-2                *)
(*                                                                         *)
(*    Release :    Dec 89                                                  *)
(*                                                                         *)
(*    Copyright (C)  1987, 1989 Logitech, All rights reserved              *)
(*                                                                         *)
(*    Permission is hereby granted to registered users to use or abstract  *)
(*    the following program in the implementation of customized versions.  *)
(*    This permission does not include the right to redistribute the       *)
(*    source code of this program.                                         *)
(*                                                                         *)
(***************************************************************************)


IMPLEMENTATION MODULE DOSMemory;

(* IMPLEMENTATION NOTES :                                                  *)
(*                                                                         *)
(*    - We assume here that NIL is represented by 0:FFFF ( segment is 0 )  *)
(*    - We assume too that DOS will never allocate memory at address 0:0   *)
(*    - We assume that DOS allocates only paragraph aligned memory blocks  *)
(*                                                                         *)
(* Under these assumptions, we build the list of the allocated blocks      *)
(* using the segment only and assuming that segment 0 is NIL segment.      *)

(* In the future it is probably better to declare a NIL segment in RTSMain *)
(* for example in order to be sure that in protected mode the segment used *)
(* for NIL is actually valid.                                              *)





FROM SYSTEM  IMPORT ADDRESS, DOSCALL;
FROM RTSMain IMPORT ProcessDescriptor, blockList, activProcess;



TYPE
    DOSBlockHeader = RECORD
                       nextBlockSeg,
                       prevBlockSeg  : CARDINAL;
                       nextProceSeg,
                       prevProceSeg  : CARDINAL;
                       blockParaSize : CARDINAL;
                       reserved      : ARRAY [0..2] OF CARDINAL;
                     END;
    Ptr = RECORD
            CASE BOOLEAN OF
              TRUE  : adr : ADDRESS |
              FALSE : ptr : POINTER TO DOSBlockHeader;
            END;
          END;


PROCEDURE DOSAlloc( VAR a: ADDRESS; paraSize: CARDINAL );
(* Allocates a block of paraSize paragraphs :                      *)
(*   a is the address of the block returned or NIL if the size     *)
(*   is not available or an error occured                          *)
  VAR
      error,
      blockSize       : CARDINAL;
      p, next         : Ptr;


BEGIN
  blockSize    := paraSize + 1;
  p.adr.OFFSET := 0;



  DOSCALL( 48H, blockSize, p.adr.SEGMENT, error );


  IF error=0 THEN
    p.ptr^.blockParaSize := blockSize;
    p.ptr^.reserved[0]   := 0;

    next.adr := blockList;
    blockList := p.adr;
    p.ptr^.prevBlockSeg := 0;
    p.ptr^.nextBlockSeg := next.adr.SEGMENT;
    IF next.adr.SEGMENT # 0 THEN
      next.ptr^.prevBlockSeg  := p.adr.SEGMENT
    END;


    next.adr := activProcess^.heapDesc;
    activProcess^.heapDesc := p.adr;
    p.ptr^.prevProceSeg := 0;
    p.ptr^.nextProceSeg := next.adr.SEGMENT;
    IF next.adr.SEGMENT # 0 THEN
      next.ptr^.prevProceSeg  := p.adr.SEGMENT
    END;




    a := p.adr;
    INC( a.SEGMENT );

  ELSE
    a := NIL;
  END;
END DOSAlloc;


PROCEDURE DOSDeAlloc( VAR a: ADDRESS; paraSize: CARDINAL );
(* DeAllocates a block previously allocated with DOSAlloc. The     *)
(* paraSize passed must be the size given for allocate or setsize  *)
(*   a is set to the NIL value if DeAlloc succeds, not modified    *)
(*   an error occured.                                             *)
(* NOTE: the address passed MUST BE the address returned by        *)
(*       DOSAlloc                                                  *)
  VAR
      error,
      blockSize : CARDINAL;
      p, next, prev   : Ptr;
BEGIN


  p.adr := a;
  DEC( p.adr.SEGMENT );

  prev.adr.OFFSET := 0;
  next.adr.OFFSET := 0;

  prev.adr.SEGMENT := p.ptr^.prevBlockSeg;
  next.adr.SEGMENT := p.ptr^.nextBlockSeg;
  IF prev.adr.SEGMENT=0 THEN
    blockList := next.adr
  ELSE
    prev.ptr^.nextBlockSeg := next.adr.SEGMENT;
  END;
  IF next.adr.SEGMENT # 0 THEN
    next.ptr^.prevBlockSeg := prev.adr.SEGMENT;
  END;


  prev.adr.SEGMENT := p.ptr^.prevProceSeg;
  next.adr.SEGMENT := p.ptr^.nextProceSeg;
  IF prev.adr.SEGMENT=0 THEN
    activProcess^.heapDesc := next.adr
  ELSE
    prev.ptr^.nextProceSeg := next.adr.SEGMENT;
  END;
  IF next.adr.SEGMENT # 0 THEN
    next.ptr^.prevProceSeg := prev.adr.SEGMENT;
  END;


  blockSize := p.ptr^.blockParaSize;


  DOSCALL( 49H, p.adr, error );


  a := NIL;
END DOSDeAlloc;


PROCEDURE DOSAvail(): CARDINAL;
(* Function that returns the size ( in paragraphs ) of the largest *)
(* space available.                                                *)
(* The size returned by the call to OS/2 is in a double word !     *)
(* This procedure returns only the value up to 16 * 64K anyway ... *)
  VAR
      error : CARDINAL;

      a    : CARDINAL;
      size : CARDINAL;


BEGIN


  size := 0FFFFH;
  DOSCALL( 48H, size, a, error );
  IF (error=8)AND(size>1) THEN
    RETURN size-1
  ELSE
    RETURN 0
  END;

END DOSAvail;


PROCEDURE DOSSetSize( a: ADDRESS; paraSize: CARDINAL; VAR errorCode: CARDINAL );
(* Sets the size of the block given to the new size given in       *)
(* paraSize.                                                       *)
(* NOTE: the address passed MUST BE the address returned by        *)
(*       DOSAlloc                                                  *)
  VAR

      blockSize      : CARDINAL;
      p              : Ptr;
BEGIN
  blockSize     := paraSize + 1;


  p.adr := a;
  DEC(p.adr.SEGMENT);
  DOSCALL( 4AH, p.adr, blockSize, errorCode );
  IF errorCode=0 THEN
    p.ptr^.blockParaSize := blockSize;
  END;

END DOSSetSize;

PROCEDURE DOSGetMaxSize( a: ADDRESS ): CARDINAL;
(* Gets the maximal paragraph size to which the block given as     *)
(* parameter can be extended                                       *)
(* NOTE: the address passed MUST BE the address returned by        *)
(*       DOSAlloc                                                  *)
  VAR
      error,

      blockSize     : CARDINAL;
      p             : Ptr;
BEGIN


  blockSize := 0FFFFH;
  p.adr := a;
  DEC(p.adr.SEGMENT);
  DOSCALL( 4AH, p.adr, blockSize, error );
  IF error=8 THEN
    RETURN blockSize-1
  ELSE
    RETURN 0
  END;

END DOSGetMaxSize;
END DOSMemory.
