(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*        Module 'Break' provides an interrupt handler                     *)
(*        for the control-break interrupt 1BH of MS-DOS                    *)
(*        and PC-DOS. The default routine stops the                        *)
(*        executing program with 'Terminate(stopped)'                      *)
(*        This produces a dump of the program. The user                    *)
(*        may install his own routine and he can enable                    *)
(*        and disable the reaction on the interrupt                        *)
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
(*$T-*)
(*$R-*)
IMPLEMENTATION MODULE Break; 

FROM SYSTEM   IMPORT ADDRESS, ADR , SIZE     , TSIZE,
                     WORD   , BYTE,
                     PROCESS, NEWPROCESS     , TRANSFER, IOTRANSFER, SWI;

FROM RTSMain  IMPORT curProcess     , ProcessDescriptor, 
                     Terminate      , Status           , RegisterBlock,
                     InstallTermProc, OverlayPtr        , overlayList;

CONST
  int27            = 01BH;     (* IBM-PC ROM-BIOS break interrupt number *)

  int1             = 1;        (* 8086 step by step vector       *)
  traceFlag        = 8;        (* 8086 step by step flag         *)

  instIRet         = 0CFH;     (* 8086  IRET                     *)
  
  sizeWorkspace27  = 1000; 
  maxWorkspace27   = sizeWorkspace27-1;

  maxTable         = 5;

TYPE 
  ProcessPtr = POINTER TO ProcessDescriptor;

  Ptr        = RECORD
                 CASE INTEGER OF
                   0: off,seg  : CARDINAL;
                 | 1: addr     : ADDRESS ;
                 | 2: paddr    : POINTER TO ADDRESS;
                 | 3: pbitset  : POINTER TO BITSET ;
                 | 4: pipcs    : POINTER TO RECORD
                                              ip, cs: CARDINAL;
                                            END;
                 | 5: pbyte    : POINTER TO BYTE;
                 END(*CASE*);
               END(*Ptr*);


  TableIndex = [ 0..maxTable ];
  TableProc  = ARRAY [ 0..maxTable-1 ] OF 
               RECORD
                  progId  : CARDINAL;
                  proc    : PROC;
               END (* TableProc *);
                 
  Workspace27= ARRAY [ 0 .. maxWorkspace27 ] OF BYTE; 

  State      = (unknown, m2program);
 
VAR
  workspace27     : Workspace27;
  processInt27    : PROCESS; 

  processInit     : PROCESS;   

  tableProc       : TableProc;
  tableIndex      : TableIndex;

  iof             : BOOLEAN;
  terminate       : BOOLEAN;

(*
PROCEDURE DisplayHex( h: CARDINAL );

  PROCEDURE HexDigit( h: CARDINAL );
  BEGIN
    IF h < 10 THEN
      Write( CHR(h + ORD('0')) );
    ELSE
      Write( CHR(h + ORD('A') - 10) );
    END;
  END HexDigit;

BEGIN
  HexDigit( (h DIV 1000H) MOD 0FH );
  HexDigit( (h DIV 100H) MOD 0FH );
  HexDigit( (h DIV 10H) MOD 0FH );
  HexDigit( h MOD 0FH );
END DisplayHex;
*)

PROCEDURE EnableBreak;
BEGIN
  iof := FALSE;
END EnableBreak;

PROCEDURE DisableBreak;
BEGIN
  iof := TRUE;
END DisableBreak;

PROCEDURE InstallBreak ( procedure: PROC );
BEGIN
  IF (tableIndex < maxTable) THEN
    WITH tableProc[tableIndex] DO
       proc   := procedure;
       progId := curProcess^^.programLevel;
    END(*WITH*);
    INC( tableIndex );
  END(*IF*);
END InstallBreak;

PROCEDURE UnInstallBreak;
BEGIN
  IF tableIndex > 1 THEN DEC(tableIndex); END;
END UnInstallBreak;

PROCEDURE TerminateBreak;
BEGIN
  WHILE (tableIndex>0) AND
        (tableProc[tableIndex-1].progId=curProcess^^.programLevel) DO 
    DEC( tableIndex );
  END(*WHILE*);

  IF (tableIndex = 0) THEN
    terminate := TRUE;
    SWI(int27);
  END(*IF*);
END TerminateBreak;

(* ***** ***** *)

PROCEDURE GetStack    (    processInit  : PROCESS   ;
                       VAR processPtr   : ProcessPtr;  
                       VAR spAddress    : Ptr       ;
                       VAR returnAddress: Ptr       );
BEGIN
  processPtr := ProcessPtr( processInit );
  WITH processPtr^ DO
    spAddress         := Ptr(topStack);
    returnAddress.off := topStack^.IP;
    returnAddress.seg := topStack^.CS;
  END(*WITH*);
END GetStack;

PROCEDURE StepMode (    spAddress    : Ptr; set: BOOLEAN      );
  (* set/reset trace (single step) flag in flags *)
  (* of return block of an interrupt             *)
  TYPE
      RegisterBlockPtr = POINTER TO RegisterBlock;
  VAR
      p : RegisterBlockPtr;
      w : Ptr;
BEGIN
  p := RegisterBlockPtr(spAddress);
  w := Ptr( ADR(p^.flag) );
  IF set THEN
    INCL( w.pbitset^, traceFlag );
  ELSE
    EXCL( w.pbitset^, traceFlag );
  END(*IF*);
END StepMode;

PROCEDURE TestStepMode( spAddress    : Ptr ): BOOLEAN;
  (* check if we are in single step mode *)
  VAR bug : BOOLEAN; bs : BITSET;
  TYPE
      RegisterBlockPtr = POINTER TO RegisterBlock;
  VAR
      p : RegisterBlockPtr;
BEGIN
  p   := RegisterBlockPtr(spAddress);
  bs  := BITSET( p^.flag );
  bug := (traceFlag IN bs);
  RETURN bug;
END TestStepMode;

PROCEDURE ApplicationModule( processPtr: ProcessPtr; addr: Ptr ): BOOLEAN; 
  (* compare segment of 'addr' with the code-segments of the *)
  (* resident overlays in the overlayList                     *)
  (* return TRUE if such 'addr' is the code-segment of such  *)
  (* a module                                                *)
VAR
  examinedOverlay : OverlayPtr;
  found : BOOLEAN;
BEGIN
  examinedOverlay := overlayList;
  found := FALSE;
  REPEAT
    WITH examinedOverlay^ DO
(*
      DisplayHex(addr.seg); Write(':'); DisplayHex(addr.off);
      Write('<');
      DisplayHex(codeSegment); Write('|'); DisplayHex(codeSegment+memorySize);
      Write('>'); WriteLn;
*)
      found := (codeSegment <= addr.seg) AND
               ((codeSegment + memorySize) > addr.seg );
    END;
    examinedOverlay := examinedOverlay^.next;
  UNTIL (examinedOverlay = overlayList) OR found;
  RETURN( found );
END ApplicationModule;

(* ***** ***** *)

PROCEDURE DriverInt27; (* Break *)

VAR
  processPtr   : ProcessPtr  ;
  spAddress    : Ptr         ;
  returnAddress: Ptr         ;

  state        : State       ;

        PROCEDURE WhereAreWe;
          (* sets 'state' to 'm2program' if we are on a instruction *)
          (* of a Modula-2 module                                   *)
        BEGIN
          (* state = unknown *)
          IF ApplicationModule( ProcessPtr(processInit), returnAddress ) THEN
            tableProc[tableIndex-1].proc;
            StepMode( spAddress, FALSE );
            (* stop single step mode: we found a Modula-2 instruction *)
            state := m2program;
          ELSE 
            IF (returnAddress.pbyte^=BYTE(instIRet)) THEN 
              INC ( spAddress.off, 6 (* bytes *) );
              StepMode( spAddress, TRUE );
              (* if the next instruction to execute is a IRET, *)
              (* we have to renew the single step mode for the *)
              (* interrupted instruction                       *)
            END;
          END;
        END WhereAreWe;

BEGIN
  LOOP
    (* handle interrupt 27 for a ^ Break, typed by the user *)

    IOTRANSFER( processInt27, processInit, int27 );

    IF (*iof OR*) terminate THEN
      TRANSFER( processInt27, processInit );

    ELSIF NOT iof THEN
 
      GetStack   ( processInit, processPtr, spAddress, returnAddress );
      StepMode   ( spAddress, TRUE  );
        (* set to single step mode                         *)
        (* we step through the next instructions, until we *)
        (* encounter an instruction, which belongs to a    *)
        (* Modula-2 program                                *)

      state := unknown;
        (* at the beginning, we don't know where we are *)
      REPEAT
        (* handle interrupt 1 for each single step *)

        IOTRANSFER( processInt27, processInit, int1 );
        GetStack  ( processInit , processPtr , spAddress, returnAddress );

        IF TestStepMode ( spAddress ) THEN 
          WhereAreWe;
        END(*IF*); 
      UNTIL (state = m2program);

    END(*IF*);  
  END(*LOOP*);
END DriverInt27;

(* ***** *)

PROCEDURE StandardBreak;
  TYPE
      (* ARRAY [0..((TSIZE(RegisterBlock) DIV 2)-1)+4] *)
      StackPtr = POINTER TO ARRAY [0..12+4] OF CARDINAL;
      RegPtr   = POINTER TO RegisterBlock;
      ProcAdr  = RECORD
                   CASE BOOLEAN OF
                     TRUE  : adr : ADDRESS |
                     FALSE : pro : PROCEDURE( Status );
                   END;
                 END;
  VAR
      i     : CARDINAL;
      rSize : CARDINAL;
      stack : StackPtr;
      termA : ProcAdr;
      procA : ProcessPtr;
BEGIN
  (* insert a call to terminate on top of stack, before the process desc.  *)
  procA := ProcessPtr(processInit);
  WITH procA^ DO
    stack     := StackPtr(ADDRESS(topStack) - 6); (* get 3 words more on stack *)
    topStack  := RegPtr(stack);
    rSize     := TSIZE(RegisterBlock) DIV 2;
    termA.pro := Terminate;
    FOR i:=0 TO rSize-1 DO
      stack^[i] := stack^[i+3];               (* move RegisterBlock        *)
    END;
    stack^[rSize-3] := termA.adr.OFFSET;
    stack^[rSize-2] := termA.adr.SEGMENT;
    stack^[rSize+2] := ORD(Stopped);
  END;
(*  TRANSFER( processInt27, processInit );*)
END StandardBreak;

BEGIN
  tableIndex   := 1;

  WITH tableProc[0] DO
    proc := StandardBreak;
    progId  := curProcess^^.programLevel;
  END;

  iof := FALSE;
  terminate := FALSE;

  InstallTermProc( TerminateBreak );

  NEWPROCESS(  DriverInt27 , ADR ( workspace27),
                             SIZE( workspace27),
               processInt27
            );
  TRANSFER  (  processInit , processInt27 ); 
END Break.
