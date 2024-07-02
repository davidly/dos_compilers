(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*       Standard dynamic storage management			           *)
(*									   *)
(*	 Storage management for dynamic variables. Calls to the		   *)
(*	 Modula-2 standard procedures NEW and DISPOSE are		   *)
(*	 translated into calls to ALLOCATE and DEALLOCATE. The		   *)
(*	 standard way to provide these two procedures is to		   *)
(*	 import them from this module 'Storage'.			   *)
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


IMPLEMENTATION MODULE Storage;

(*
Storage description :
===================

87.02.18

blockList_RTSMain --->|-----------------|
                      | nextBlockSeg :  |  segment pointer to next block
                      |-----------------|
                      | prevBlockSeg :  |  segment pointer to previous block
                      |-----------------|
                      | BlockSize :     |  block size in paragraphs
                      |-----------------|
                      | dynamic :       |  boolean telling if used by Storage
                      |-----------------|
                      :                 :
                      :                 :
   blockList + 16 --> |-----------------|
                      |                 |
                      | usable area     |
                      :                 :
                      :                 :
                      :                 :
                      |-----------------|
*)

FROM SYSTEM    IMPORT ADDRESS, ADR, DOSCALL;
FROM RTSMain   IMPORT blockList, Terminate, Status;


FROM DynMem    IMPORT InstallDynMem, Alloc, DeAlloc, Avail;
FROM DOSMemory IMPORT DOSAlloc, DOSDeAlloc, DOSAvail;

CONST
    MinBlockSize = 1000;   (* in paragraphs *)
    DiffSize     =  100;
    MaxHeap      =    8;   (* number of heap available *)

TYPE
    BlockPtr    = RECORD
                    CASE BOOLEAN OF
                      TRUE  : ptr : POINTER TO DOSBlockHeader |
                      FALSE : adr : ADDRESS;
                    END;
                  END;

    DOSBlockHeader = RECORD
                       nextBlockSeg,
                       prevBlockSeg  : CARDINAL;
                       nextProceSeg,
                       prevProceSeg  : CARDINAL;
                       blockParaSize : CARDINAL;
                       dynamic       : BOOLEAN;
                       reserved      : ARRAY [0..4] OF CHAR;
                     END;

    HeapList    = ARRAY [1..MaxHeap] OF ADDRESS;


VAR
    heapList    : HeapList;
    prevHeap    : CARDINAL;


PROCEDURE ALLOCATE (VAR a: ADDRESS; size: CARDINAL);
(*
- Allocate some dynamic storage (contiguous memory area).

in:     size    number of bytes to allocate,

out:    a       ADDRESS of allocated storage.

The actual number of bytes allocated may be slightly
greater than 'size', due to administrative overhead.

Errors: If not enough space is available, or when
attempting to allocate more than 65520 (0FFF0H)
bytes at once, then the calling program is terminated
with the status 'heapovf'.
*)
  VAR
      paraSize : CARDINAL;
      adresse  : BlockPtr;
BEGIN
  (* get size in paragraphs *)

  paraSize := size DIV 16;
  IF (size MOD 16) > 0 THEN INC(paraSize) END;

  (* test for small or big block *)

  IF paraSize > (MinBlockSize - DiffSize) THEN

    DOSAlloc( a, paraSize );               (* allocate a big block for it *)
    IF a=NIL THEN Terminate( HeapOvf ) END;


  ELSE
    (* find a dynamicaly allocated block *)
    adresse.adr := blockList;
    a := NIL;
    WHILE a = NIL DO
      IF adresse.adr.SEGMENT = 0 THEN
        DOSAlloc( adresse.adr, MinBlockSize );


        IF adresse.adr=NIL THEN Terminate( HeapOvf ) END;
        DEC(adresse.adr.SEGMENT);

        adresse.ptr^.dynamic := TRUE;


        INC(adresse.adr.SEGMENT);

        InstallDynMem( adresse.adr, (MinBlockSize*16) );
        Alloc( adresse.adr, a, size );
      ELSIF adresse.ptr^.dynamic THEN


        INC( adresse.adr.SEGMENT );

        Alloc( adresse.adr, a, size );
        IF a=NIL THEN


          DEC( adresse.adr.SEGMENT );

          adresse.adr.SEGMENT := adresse.ptr^.nextBlockSeg
        END;
      ELSE
        adresse.adr.SEGMENT := adresse.ptr^.nextBlockSeg
      END;
    END;
  END;
END ALLOCATE;


PROCEDURE DEALLOCATE (VAR a: ADDRESS; size: CARDINAL);
(*
- Release some dynamic storage (contiguous memory area).

in:     a       ADDRESS of the area to release,
        size    number of bytes to be released,

out:    a       set to NIL.

The storage area released is made available for subsequent
calls to ALLOCATE.
*)
  VAR
      adr      : BlockPtr;
      done     : BOOLEAN;
BEGIN
  (* find the right block *)
  adr.adr := blockList;
  done := FALSE;
  REPEAT
    IF adr.adr.SEGMENT # 0 THEN

      IF (adr.adr.SEGMENT <= a.SEGMENT) AND
         (a.SEGMENT < (adr.adr.SEGMENT + adr.ptr^.blockParaSize)) THEN


        (* we find in the right block *)
        IF adr.ptr^.dynamic THEN

          INC( adr.adr.SEGMENT );


          IF DeAlloc( adr.adr, a, size ) THEN
            DOSDeAlloc( adr.adr, 0 );
          END;
        ELSE
          DOSDeAlloc( a, 0 )
        END;
        done := TRUE;
      ELSE
        adr.adr.SEGMENT := adr.ptr^.nextBlockSeg;
      END;
    ELSE
      (* error, the block is not found *)
      Terminate( BadOperand );
    END;
  UNTIL done;
END DEALLOCATE;


PROCEDURE Available (size: CARDINAL) : BOOLEAN;
(*
- Test whether some number of bytes could be allocated.

in:     size    number of bytes

out:    TRUE if ALLOCATE (p, size) would succeed.
*)
  VAR
      paraSize,
      availSize : CARDINAL;
      errCode   : CARDINAL;
      a         : BlockPtr;
BEGIN
  paraSize := size DIV 16;
  IF (size MOD 16) > 0 THEN INC(paraSize) END;    (* get size in paragraphs *)

  (* get max number of paragraphs available *)

  availSize := DOSAvail();
  IF paraSize > (MinBlockSize - DiffSize) THEN
    (* we allocate a full block to user *)
    RETURN availSize >= paraSize;
  ELSE
    (* we allocate in a dynblock *)
    IF availSize >= MinBlockSize THEN
      (* we can create a new dynamic allocated block *)
      RETURN TRUE
    ELSE
      (* at least search a small space in a dyn block *)
      a.adr := blockList;
      WHILE a.adr.SEGMENT # 0 DO
        IF a.ptr^.dynamic THEN

          INC( a.adr.SEGMENT );


          IF Avail( a.adr, size ) THEN RETURN TRUE END;

          DEC( a.adr.SEGMENT );


        END;
        a.adr.SEGMENT := a.ptr^.nextBlockSeg
      END; (* while a # NIL *)
      (* we have not found any space in dynamic blocks *)
      RETURN FALSE
    END;
  END;
END Available;

(****************************************************************************)
(* The following procedures implement a stack of heaps. There is only one   *)
(* active at a moment. DEALLOCATE of a block not belonging to the current   *)
(* heap will result in a BadOperand error. This scheme cannot implement     *)
(* separate heap for processes.                                             *)

PROCEDURE InstallHeap;
(*
- Used internally by the loader
*)
BEGIN
  IF prevHeap < MaxHeap THEN
    INC( prevHeap );
    heapList[prevHeap] := blockList;
    blockList := NIL
  ELSE

    Terminate( HeapOvf )


  END;
END InstallHeap;


PROCEDURE RemoveHeap;
(*
- Used internally by the loader
*)
  VAR
      cur, next : BlockPtr;
BEGIN
  WHILE blockList.SEGMENT <> 0 DO
    cur.adr := blockList;

    INC (cur.adr.SEGMENT);


    DOSDeAlloc( cur.adr, 0 );
  END;
  IF prevHeap > 0 THEN
    blockList := heapList[prevHeap];
    DEC( prevHeap )
  END;
END RemoveHeap;

BEGIN
  prevHeap := 0;
END Storage.
