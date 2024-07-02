(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Overlay, SubPrograms and ResidentOverlay manager 			   *)
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
(* 20-Aug-87		Original version.				*)
(* 10-Nov-89/akg	"OpenFile", "AddPath", "Open", and "HasPath"	*)
(*			corrected and simplified.			*)
(*			Unnecessary "CurrentDrive" removed.		*)
(*			"RelocatePass": Comment added, code simplified.	*)
(************************************************************************)

IMPLEMENTATION MODULE Overlay; (* BZ *) (* AR *)

  FROM LoadPath IMPORT    (*02-Jan-89/yp*)
    GetLoadDir;

  FROM RTSMain IMPORT
    Execute, Status, OverlayPtr, OverlayDescriptor, overlayList, activProcess,
    ProcPtr, ProcDescriptor, debuggerRecord, DebuggerRecord, InstallTermProc,
    ProcessDescriptor, Terminate, RTDProc, overlayTermProc, overlayInitProc,
    PSPAddress, Process, dyingOverlay;

  FROM RTSCoroutine IMPORT
    addProcess;

  FROM SYSTEM IMPORT
    ADDRESS, ADR, DOSCALL, SETREG, ES, DI, TSIZE, PROCESS;


  MODULE BlockManager;

    IMPORT
      ADDRESS, DOSCALL;

    EXPORT
      GetBlock, FreeBlock, NewLayer, DisposeLayer, LayerId;

    CONST
      Nil     = 0FFFFH;
      ALLOC   = 48H;
      DEALLOC = 49H;

    TYPE
      LayerId   = POINTER TO LayerDesc;
      LayerDesc = RECORD
                    size  : CARDINAL;
                    free  : CARDINAL;
                    local : BOOLEAN;
                  END;
      Block     = POINTER TO BlockDesc;
      BlockDesc = RECORD
                    next : CARDINAL;
                    size : CARDINAL;
                  END;


    PROCEDURE DOSAlloc ( VAR base : ADDRESS;
                             size : CARDINAL );

    VAR
      err : CARDINAL;
      s   : CARDINAL;

    BEGIN
      s := size;
      DOSCALL (ALLOC, s, base.SEGMENT, err);
      IF (s <> size) OR (err > 0) THEN
        base := NIL;
      ELSE
        base.OFFSET := 0;
      END;
    END DOSAlloc;


    PROCEDURE DOSDeAlloc ( VAR adr  : ADDRESS;
                               size : CARDINAL );

    VAR
      err : CARDINAL;

    BEGIN
      DOSCALL (DEALLOC, adr, err);
    END DOSDeAlloc;


    PROCEDURE Base ( block : ADDRESS ) : CARDINAL;

    BEGIN
      RETURN block.SEGMENT;
    END Base;


    PROCEDURE NextBlock ( VAR block : Block );

    VAR
      a : ADDRESS;

    BEGIN
      a.SEGMENT := block^.next;
      a.OFFSET := 0;
      block := a;
    END NextBlock;


    PROCEDURE FirstBlock ( layer : LayerId ) : Block;

    VAR
      a : ADDRESS;

    BEGIN
      a.SEGMENT := layer^.free;
      a.OFFSET := 0;
      RETURN a;
    END FirstBlock;


    PROCEDURE NillBlock ( block : ADDRESS ) : BOOLEAN;

    BEGIN
      RETURN block.SEGMENT = Nil;
    END NillBlock;


    PROCEDURE GetBlock ( VAR adr   : ADDRESS;
                             size  : CARDINAL;
                         VAR layer : LayerId  ) : BOOLEAN;

    VAR
      b1,
      b2   : Block;
      a    : ADDRESS;
      done : BOOLEAN;

    BEGIN
      IF layer = NIL THEN
        NewLayer (layer, size + 1, done);
        IF NOT done THEN        (* 17-Feb-88/?, this statement is *)
          RETURN FALSE
        END;   
        layer^.local := TRUE;   (* now before this one *)
      END;
      b1 := NIL;
      b2 := FirstBlock (layer);
      LOOP
        IF NillBlock (b2) THEN
          adr := NIL;
          RETURN FALSE;
        END;
        IF b2^.size < size THEN
          b1 := b2;
          NextBlock (b2);
        ELSE
          EXIT;
        END;
      END;
      adr := b2;
      IF b2^.size = size THEN
        IF b1 = NIL THEN
          layer^.free := b2^.next;
        ELSE
          b1^.next := b2^.next;
        END;
      ELSE
        a.SEGMENT := adr.SEGMENT + size;
        a.OFFSET := 0;
        IF b1 = NIL THEN
          layer^.free := a.SEGMENT;
        ELSE
          b1^.next := a.SEGMENT;
        END;
        b1 := a;
        b1^.next := b2^.next;
        b1^.size := b2^.size - size;
      END;
      RETURN TRUE;
    END GetBlock;


    PROCEDURE Adjacent ( b1,
                         b2 : Block ) : BOOLEAN;

    VAR
      a1,
      a2 : ADDRESS;

    BEGIN
      a1 := b1;
      a2 := b2;
      RETURN (a1.SEGMENT + b1^.size) = a2.SEGMENT;
    END Adjacent;


    PROCEDURE FreeBlock ( layer : LayerId;
                          addr  : ADDRESS;
                          size  : CARDINAL );

    VAR
      b1,
      b2,
      b3 : Block;

    BEGIN
      IF layer^.local THEN
        DisposeLayer (layer);
      ELSE
        b2 := FirstBlock (layer);
        b1 := NIL;
        WHILE Base (b2) < addr.SEGMENT DO
          b1 := b2;
          NextBlock (b2);
        END;
        b3 := addr;
        b3^.next := Base (b2);
        b3^.size := size;
        IF b1 = NIL THEN
          layer^.free := Base (b3);
        ELSE
          b1^.next := Base (b3);
        END;
        b1 := FirstBlock (layer);
        b2 := b1;
        NextBlock (b2);
        WHILE NOT NillBlock (b2) DO
          IF Adjacent (b1, b2) THEN
            INC (b1^.size, b2^.size);
            NextBlock (b2);
            b1^.next := Base (b2);
          ELSE
            b1 := b2;
            NextBlock (b2);
          END;
        END;
      END;
    END FreeBlock;


    PROCEDURE NewLayer ( VAR layer : LayerId;
                             size  : CARDINAL;
                         VAR done  : BOOLEAN  );

    VAR
      base  : ADDRESS;
      block : Block;

    BEGIN
      IF (size > 1) THEN
        DOSAlloc (base, size);
        IF base <> NIL THEN
          layer := base;
          layer^.size := size;
          layer^.local := FALSE;
          INC (base.SEGMENT);
          layer^.free := base.SEGMENT;
          block := base;
          block^.next := Nil;
          block^.size := size - 1;
          done := TRUE;
        ELSE
          done := FALSE;
        END;
      ELSE
        done := FALSE;
      END;
    END NewLayer;


    PROCEDURE DisposeLayer ( layer : LayerId );

    BEGIN
      DOSDeAlloc (layer, layer^.size);
    END DisposeLayer;


  END BlockManager;

  MODULE Loader;

    IMPORT
      OverlayPtr, ErrorCode, LayerId, ADDRESS, ProcPtr, activProcess, DOSCALL,
      FreeBlock, GetBlock, ADR, TSIZE, ProcDescriptor, GetLoadDir, PSPAddress;

    EXPORT
      Load;

    CONST
      KeySize    = 4;  (* for instance, check not milli-seconds *)
      MaxCard    = 0FFFFH;
      HeaderSize = 28;
      OVLCode    = 4DH + 256 * 5BH;  (* signature of .OVL *)
      EXECode    = 4DH + 256 * 5AH;  (* signature of .EXE *)
      BufLen     = 512;
      OPEN       = 3DH;
      CLOSE      = 3EH;
      READ       = 3FH;
      SEEK       = 42H;
      NbProc     = 16;  (* number of init/term procedures allowed *)

    TYPE
      ModuleKey = ARRAY [0 .. 5] OF CHAR;


    PROCEDURE AddCard ( VAR n : CARDINAL;
                            m : CARDINAL );

    BEGIN
      IF n > MaxCard - m THEN
        n := MaxCard
      ELSE
        n := n + m;
      END;
    END AddCard;


    PROCEDURE FindOvlDesc ( VAR name : ARRAY OF CHAR ) : OverlayPtr;

    VAR
      desc : OverlayPtr;
      driv : OverlayPtr;


      PROCEDURE NoMatch ( VAR nom : ARRAY OF CHAR ) : BOOLEAN;

      VAR
        i : CARDINAL;

      BEGIN
        i := 0;
        WHILE (CAP (nom[i]) = CAP (name[i])) & (nom[i] <> 0C) DO
          INC (i);
        END;
        RETURN (nom[i] <> 0C) OR (name[i] <> 0C);
      END NoMatch;

    BEGIN
      desc := activProcess^.currOverlay;
      LOOP
        IF desc = NIL THEN
          RETURN NIL
        END;
        driv := desc^.parent;
        WHILE (driv <> NIL) & NoMatch (driv^.overlayName) DO
          driv := driv^.parent;
        END;
        IF driv = NIL THEN
          IF NoMatch (desc^.overlayName) THEN
            desc := desc^.father;
          ELSE
            RETURN desc;
          END;
        ELSE
          RETURN driv;
        END;
      END;
    END FindOvlDesc;


    PROCEDURE Load (     fileName    : ARRAY OF CHAR;
                     VAR overlayDesc : OverlayPtr;
                     VAR error       : ErrorCode;
                     VAR entryPoint  : ADDRESS;
                         loadLayer   : LayerId       );

    VAR
      header           : ARRAY [0 .. HeaderSize + 1] OF CHAR;
      buffer           : ARRAY [1 .. BufLen] OF CHAR;
      pos              : CARDINAL;
      loadFile         : CARDINAL;
      err              : CARDINAL;
      signature,
      fileLengthLow,
      fileLengthHigh,
      relocationCount,
      headerSize,
      minMemory,
      maxMemory,
      stackDisp,
      stackSP,
      checksum,
      entryOffset,
      entryBase,
      relocationOffset,
      overlayNumber    : CARDINAL;
      codeSize         : CARDINAL;
      startCode        : ADDRESS;
      startMem         : ADDRESS;
      topMem           : ADDRESS;
      sizeMem          : CARDINAL;
      epAddr           : ADDRESS;
      memAllocated     : BOOLEAN;
      done             : BOOLEAN;


      PROCEDURE Error ( n : ErrorCode );

      BEGIN
        error := n;
        DOSCALL (CLOSE, loadFile, err);
        IF memAllocated THEN
          FreeBlock (loadLayer, startMem, minMemory);
        END;
      END Error;


      PROCEDURE OpenFile;

      VAR
        name : ARRAY [0 .. 127] OF CHAR;


        PROCEDURE AddPath ( VAR s : ARRAY OF CHAR );

        VAR
          i,
          j : CARDINAL;

        BEGIN
          i := 1;
          WHILE (i <= HIGH (buffer)) & (buffer[i] <> 0C) DO
            INC (i);
          END;
          j := 0;
          WHILE (j <= HIGH (s)) & (s[j] <> 0C) DO
            INC (j);
          END;
          IF (i + j + 3) < HIGH (buffer) THEN
            j := 0;
            WHILE (j <= HIGH (s)) & (s[j] <> 0C) DO
              IF s[j] <> ' ' THEN
                buffer[i] := s[j];
                INC (i);
              END;
              INC (j);
            END;
(* 10-Nov-89/akg *)
            buffer[i] := ';';
            INC (i);
            buffer[i] := 0C;
          END;
        END AddPath;


        PROCEDURE ScannEnviron;

        VAR
          PSPPtr : RECORD
                     CASE CARDINAL OF
                       0 :
                         addr   : ADDRESS;
                     | 1 :
                         offset,
                         base   : CARDINAL;
                     END;
                   END;
          env    : POINTER TO ARRAY [0 .. 10000] OF CHAR;
          pos    : CARDINAL;
          var    : ARRAY [0 .. 255] OF CHAR;
          val    : ARRAY [0 .. 255] OF CHAR;
          k      : CARDINAL;
          temp   : ARRAY [0 .. 6] OF CHAR;


          PROCEDURE Match ( v : ARRAY OF CHAR ) : BOOLEAN;

          VAR
            i : CARDINAL;

          BEGIN
            i := 0;
            LOOP
              IF i > HIGH (temp) THEN
                EXIT
              END;
              IF (CAP (v[i]) <> CAP (temp[i])) & (temp[i] <> '?') THEN
                EXIT
              END;
              IF v[i] = 0C THEN
                EXIT
              END;
              INC (i);
            END;
            IF (i > HIGH (temp)) & (v[i] = 0C) THEN
              RETURN TRUE
            ELSIF temp[i] = '*' THEN
              RETURN TRUE
            ELSIF (v[i] = 0C) & (temp[i] = 0C) THEN
              RETURN TRUE
            ELSE
              RETURN FALSE
            END;
          END Match;

        BEGIN
          temp := 'M2OVL';
          PSPPtr.addr := PSPAddress;
          INC (PSPPtr.addr, 44);   (* now we point to the address of the
                                   environment*)
          PSPPtr.base := CARDINAL (PSPPtr.addr^);
          PSPPtr.offset := 0;   (* now, we are pointing to the environment*)
          env := PSPPtr.addr;
          pos := 0;
          WHILE env^[pos] <> 0C DO
            k := 0;
            WHILE (env^[pos] <> 0C) & (env^[pos] <> '=') DO
              IF env^[pos] <> ' ' THEN
                var[k] := env^[pos];
                INC (k);
              END;
              INC (pos);
            END;
            var[k] := 0C;
            IF env^[pos] = '=' THEN
              k := 0;
              INC (pos);
              WHILE (env^[pos] <> 0C) & (env^[pos] <> '=') DO
                IF env^[pos] <> ' ' THEN
                  val[k] := env^[pos];
                  INC (k);
                END;
                INC (pos);
              END;
              val[k] := 0C;
              IF Match (var) THEN
                AddPath (val);
              END;
            END;
            INC (pos);
          END;
        END ScannEnviron;


        PROCEDURE DeFext ( VAR name,
                               out  : ARRAY OF CHAR );

        VAR
          i,
          j : CARDINAL;

        BEGIN
          i := 0;
          j := 0;
          WHILE (i <= HIGH (name)) & (name[i] <> 0C) DO
            out[i] := name[i];
            IF name[i] = '.' THEN
              j := i + 1;
            END;
            INC (i);
          END;
          out[i] := 0C;
          IF j > 0 THEN
            RETURN
          ELSE
            IF i < HIGH (out) - 3 THEN
              out[i] := '.';
              out[i + 1] := 'O';
              out[i + 2] := 'V';
              out[i + 3] := 'L';
              out[i + 4] := 0C;
            END;
          END;
        END DeFext;


        PROCEDURE Open ( VAR name : ARRAY OF CHAR ) : BOOLEAN;

        VAR
          i,
          j,
          k : CARDINAL;
          s : ARRAY [0 .. 127] OF CHAR;

        BEGIN
          i := 1;
          LOOP
(* 10-Nov-89/akg: Must not skip empty paths here! *)
            j := 0;
            WHILE buffer[i] <> ';' DO
              s[j] := buffer[i];
              INC (i);
              INC (j);
            END;
(* 10-Nov-89/akg: Must check for both, ':' and '\'. *)
            IF (j > 0) AND (s[j - 1] <> ':') AND (s[j - 1] <> '\') THEN
              s[j] := '\';
              INC (j);
            END;
            k := 0;
            WHILE name[k] <> 0C DO
              s[j] := name[k];
              INC (j);
              INC (k);
            END;
            s[j] := 0C;
            DOSCALL (OPEN, ADR (s), 0, loadFile, err);
            IF (loadFile > 4) & (err = 0) THEN
              RETURN TRUE;
            END;
(* 10-Nov-89/akg *)
            INC (i); (* skip ';' *)
            IF buffer[i] = 0C THEN
              RETURN FALSE;
            END;
          END;
        END Open;


        PROCEDURE HasPath ( VAR s : ARRAY OF CHAR ) : BOOLEAN;

        VAR
          i  : CARDINAL;

        BEGIN
(* 10-Nov-89/akg: Simplified, no need to call "AddPath". *)
          i := 0;
          WHILE (i <= HIGH (s)) & (s[i] <> 0C) DO
            IF (s[i] = ':') OR (s[i] = '\') THEN
              RETURN TRUE;
            END;
            INC (i);
          END;
          RETURN FALSE;
        END HasPath;

      BEGIN
(* 10-Nov-89/akg *)
        IF HasPath (fileName) THEN
          buffer[1] := ';';  (* add an empty path *)
          buffer[2] := 0C;
        ELSE
          buffer[1] := 0C;
          GetLoadDir (name);
          AddPath (name);
          ScannEnviron;
        END;
        DeFext (fileName, name);
        IF NOT Open (name) THEN
          error := FileNotFound;
        END;
      END OpenFile;


      PROCEDURE ReadHeader;

      VAR
        read : CARDINAL;
        pos  : CARDINAL;


        PROCEDURE GetHeader ( VAR pos,
                                  value : CARDINAL );

        BEGIN
          value := ORD (header[pos]) + 256 * ORD (header[pos + 1]);
          INC (pos, 2);
        END GetHeader;

      BEGIN
        DOSCALL (READ, loadFile, HeaderSize, ADR (header), read, err);
        IF (read = HeaderSize) & (err = 0) THEN
          pos := 0;
          GetHeader (pos, signature);
          GetHeader (pos, fileLengthLow);
          GetHeader (pos, fileLengthHigh);
          GetHeader (pos, relocationCount);
          GetHeader (pos, headerSize);
          GetHeader (pos, minMemory);
          GetHeader (pos, maxMemory);
          GetHeader (pos, stackDisp);
          GetHeader (pos, stackSP);
          GetHeader (pos, checksum);
          GetHeader (pos, entryOffset);
          GetHeader (pos, entryBase);
          GetHeader (pos, relocationOffset);
          GetHeader (pos, overlayNumber);
          IF signature <> OVLCode THEN
            Error (BadFormat);
          END;
        ELSE
          Error (BadFormat);
        END;
      END ReadHeader;


      PROCEDURE AllocateMemory;

      VAR
        actual : ADDRESS;
        base   : CARDINAL;

      BEGIN
        sizeMem := minMemory;
        IF GetBlock (startMem, minMemory, loadLayer) THEN
          memAllocated := TRUE;
        ELSE
          Error (InsufMemory);
        END;
        IF error = Done THEN
          topMem := startMem;
          topMem.SEGMENT := topMem.SEGMENT + sizeMem;
          actual := startMem;
          startCode := actual;
          INC (startCode.SEGMENT, (NbProc * TSIZE (ProcDescriptor) + 15) DIV
               16);
        END;
      END AllocateMemory;


      PROCEDURE LoadFile;

      CONST
        BlockSize = 4096;

      VAR
        read : CARDINAL;
        h,
        l    : CARDINAL;
        addr : ADDRESS;


        PROCEDURE IncAdr ( VAR adr  : ADDRESS;
                               size : CARDINAL );

        BEGIN
          INC (adr.SEGMENT, size DIV 16);
          INC (adr.OFFSET, size MOD 16);
          IF adr.OFFSET > 15 THEN
            INC (adr.SEGMENT, adr.OFFSET DIV 16);
            adr.OFFSET := adr.OFFSET MOD 16;
          END;
        END IncAdr;

      BEGIN
        DOSCALL (SEEK, loadFile, 0, HeaderSize DIV BlockSize, 16 *
                 (headerSize MOD BlockSize), h, l, err);
        read := 1;
        addr := startCode;
        WHILE (read > 0) & (err = 0) DO
        (* 19-Nov-87/?, use of 0FFF0H instead of MaxCard *)
          DOSCALL (READ, loadFile, 0FFF0H, addr, read, err);
          IncAdr (addr, read);
        END;
      END LoadFile;


      PROCEDURE InitBuf;

      VAR
        read : CARDINAL;
        h,
        l    : CARDINAL;

      BEGIN
        DOSCALL (SEEK, loadFile, 0, 0, relocationOffset, h, l, err);
        DOSCALL (READ, loadFile, BufLen, ADR (buffer), read, err);
        pos := 0;
      END InitBuf;


      PROCEDURE ReadByte () : CARDINAL;

      VAR
        read : CARDINAL;

      BEGIN
        INC (pos);
        IF pos > BufLen THEN
          DOSCALL (READ, loadFile, BufLen, ADR (buffer), read, err);
          pos := 1;
        END;
        RETURN ORD (buffer[pos]);
      END ReadByte;


      PROCEDURE ReadWord () : CARDINAL;
      (* Intel order : low / high *)

      BEGIN
        RETURN ReadByte () + 256 * ReadByte ();
      END ReadWord;


      PROCEDURE RelocatePass ( baseAddress : CARDINAL );

      CONST
        Size = 4;

      VAR
        reloc   : ADDRESS;
        segment : CARDINAL;
        ptrWord : POINTER TO CARDINAL;
        code    : CARDINAL;


        PROCEDURE GetReloc ( VAR reloc : ADDRESS );

        BEGIN
          reloc.OFFSET := ReadWord ();
          reloc.SEGMENT := ReadWord ();
        END GetReloc;

      BEGIN
        segment := startCode.SEGMENT;
        code := ReadByte ();
        WHILE code = 255 DO
          GetReloc (reloc);
          reloc.SEGMENT := reloc.SEGMENT + segment;
          ptrWord := reloc;
          ptrWord^ := ptrWord^ + baseAddress;
          code := ReadByte ();
          WHILE (code > 0) & (code < 255) DO
(* 10-Nov-89/akg:  code simplified. *)
            IF reloc.OFFSET >= MaxCard - 255 THEN
              reloc.SEGMENT := reloc.SEGMENT + reloc.OFFSET DIV 16;
              reloc.OFFSET := reloc.OFFSET MOD 16;
            END;
            INC (reloc.OFFSET, code);
            ptrWord := reloc;
            ptrWord^ := ptrWord^ + baseAddress;
            code := ReadByte ();
          END;
        END;
      END RelocatePass;


      PROCEDURE Relocate;

      VAR
        i,
        j           : CARDINAL;
        level       : CARDINAL;
        name        : ARRAY [0 .. 40] OF CHAR;
        importedMod : CARDINAL;
        moduleKey   : ModuleKey;
        ovlDesc     : OverlayPtr;
        addr        : ADDRESS;
        procPtr     : ProcPtr;


        PROCEDURE Name;

        VAR
          i,
          j : CARDINAL;

        BEGIN
          j := ReadByte ();
          i := 0;
          WHILE j > 0 DO
            name[i] := CHR (ReadByte ());
            INC (i);
            DEC (j);
          END;
          name[i] := 0C;
        END Name;


        PROCEDURE Reloc;

        BEGIN
          RelocatePass (ovlDesc^.codeSegment);
        END Reloc;


        PROCEDURE Key;

        VAR
          i,
          j   : CARDINAL;
          adr : ADDRESS;
          ptr : POINTER TO ModuleKey;

        BEGIN
          importedMod := ReadWord ();
          i := importedMod;
          WHILE i > 0 DO
            FOR j := 0 TO 5 DO
              moduleKey[j] := CHR (ReadByte ());
            END;
            adr.OFFSET := ReadWord ();
            adr.SEGMENT := ReadWord () + ovlDesc^.codeSegment;
            ptr := adr;
            j := 0;
            WHILE (j < KeySize) & (moduleKey[j] = ptr^[j]) DO
              INC (j);
            END;
            IF j < KeySize THEN
              Error (VersionConflict);
              RETURN;
            END;
            DEC (i);
          END;
        END Key;


        PROCEDURE OwnDesc;

        VAR
          addr : ADDRESS;

        BEGIN
          addr.OFFSET := ReadWord ();
          addr.SEGMENT := ReadWord () + startCode.SEGMENT;
          overlayDesc := addr;
        END OwnDesc;

      BEGIN
        InitBuf;
        RelocatePass (startCode.SEGMENT);
        level := ReadByte ();
        WHILE (error = Done) & (level <> 0FFH) DO
          Name;
          ovlDesc := FindOvlDesc (name);
          IF ovlDesc = NIL THEN
            Error (VersionConflict);
          ELSE
            Key;
            IF error = Done THEN
              Reloc;
              level := ReadByte ();
            END;
          END;
        END;
        IF error = Done THEN
          OwnDesc;
          Name;
          (* 11-Apr-88/yp, no key present in OVL file for own descr *)
          (* Key; *)
          WITH overlayDesc^ DO
            memoryAddr := startMem;
            memorySize := sizeMem;
            codeSegment := startCode.SEGMENT;
            freeList := startMem;
            termProc := NIL;
            initProc := NIL;
            layer := loadLayer;
            checkWord := 0FA50H;
          END;
          addr := startMem;
          FOR i := 1 TO NbProc - 1 DO
            procPtr := addr;
            INC (addr, TSIZE (ProcDescriptor));
            procPtr^.next := addr;
          END;
          procPtr := addr;
          procPtr^.next := NIL;
        END;
      END Relocate;

    BEGIN
      error := Done;
      memAllocated := FALSE;
      OpenFile;
      IF error <> Done THEN
        RETURN
      END;
      ReadHeader;
      IF error <> Done THEN
        RETURN
      END;
(*23-Dec-88/akg *)
      codeSize := 32 * (fileLengthHigh - 1) + fileLengthLow DIV 16 - 
                  headerSize;
      IF fileLengthLow MOD 16 > 0 THEN
        INC (codeSize);
      END;
      AddCard (minMemory, codeSize);
      AddCard (minMemory, (NbProc * TSIZE (ProcDescriptor) + 15) DIV 16);
      AddCard (maxMemory, codeSize);
      AddCard (maxMemory, (NbProc * TSIZE (ProcDescriptor) + 15) DIV 16);
      AllocateMemory;
      IF error <> Done THEN
        RETURN
      END;
      LoadFile;
      IF error <> Done THEN
        RETURN
      END;
      Relocate;
      IF error <> Done THEN
        RETURN
      END;
      DOSCALL (CLOSE, loadFile, err);
      entryPoint.SEGMENT := entryBase + startCode.SEGMENT;
      entryPoint.OFFSET := entryOffset;
    END Load;


  END Loader;


  PROCEDURE NilProc;

  BEGIN
  END NilProc;

  CONST
    MaxCard = 0FFFFH;

  VAR
    curProgLevel : CARDINAL;


  PROCEDURE Assign (     s  : ARRAY OF CHAR;
                     VAR ss : ARRAY OF CHAR );

  VAR
    i : CARDINAL;

  BEGIN
    FOR i := 0 TO HIGH (s) DO
      ss[i] := s[i];
    END;
    ss[HIGH (s) + 1] := 0C;
  END Assign;


  PROCEDURE Call ( ep : ADDRESS );

  VAR
    addr : ADDRESS;

  BEGIN
    addr := ADR (ep);
    SETREG (ES, addr.SEGMENT);
    SETREG (DI, addr.OFFSET);
    Execute;
  END Call;


  PROCEDURE InsertOverlayInList ( overlay : OverlayPtr );

  BEGIN
    overlay^.next := overlayList^.next;
    overlay^.prev := overlayList;
    overlay^.prev^.next := overlay;
    overlay^.next^.prev := overlay;
  END InsertOverlayInList;


  PROCEDURE DeleteOverlayInList ( overlay : OverlayPtr );

  BEGIN
    IF overlayList = overlay THEN
      overlayList := overlay^.next;
    END;
    overlay^.next^.prev := overlay^.prev;
    overlay^.prev^.next := overlay^.next;
    overlay^.next := NIL;
    overlay^.prev := NIL;
  END DeleteOverlayInList;


  PROCEDURE ExistOverlay ( overlay : OverlayId ) : BOOLEAN;

  VAR
    dd : OverlayPtr;

  BEGIN
    dd := overlayList^.next;
    WHILE (dd <> overlayList) & (dd <> OverlayPtr (overlay)) DO
      dd := dd^.next;
    END;
    RETURN dd = OverlayPtr (overlay);
  END ExistOverlay;


  PROCEDURE FreeMemory ( overlay : OverlayPtr );

  BEGIN
    FreeBlock (LayerId (overlay^.layer), overlay^.memoryAddr, overlay^.
               memorySize);
    overlay^.checkWord := 0;
  END FreeMemory;


  PROCEDURE NewLevel;

  BEGIN
    IF curProgLevel = MaxCard THEN
      curProgLevel := 0;   (* ! wrap around, should not occure *)
    ELSE
      INC (curProgLevel);
    END;
  END NewLevel;


  PROCEDURE TermProc ( overlay : OverlayPtr );

  VAR
    pp : ProcPtr;
    p  : PROC;

  BEGIN
    activProcess^.termOverlay := overlay;
    pp := overlay^.termProc;
    WHILE pp <> NIL DO
      p := pp^.termProc;
      pp^.termProc := NilProc;
      pp := pp^.next;
      p;
    END;
  END TermProc;

  (* ==================== exported procedures ======================= *)


  PROCEDURE GetErrorCode (     error : ErrorCode;
                           VAR str   : ARRAY OF CHAR );

  BEGIN
    CASE error OF
      Done :
        Assign ('done', str);
    | NotDone :
        Assign ('not done', str);
    | FileNotFound :
        Assign ('file not found', str);
    | BadFormat :
        Assign ('bad format', str);
    | InsufMemory :
        Assign ('insufficient memory', str);
    | VersionConflict :
        Assign ('version conflict', str);
    END;
  END GetErrorCode;


  PROCEDURE DeInstallOverlay ( overlayId : OverlayId );

  VAR
    parent : OverlayPtr;

  BEGIN
    IF ExistOverlay (overlayId) THEN
      overlayId^.overlay := 1;   (* AR, patch for debugger, 87.07.27 *)
      debuggerRecord.beforeTermProc (PROCESS (activProcess), overlayId);
      overlayId^.overlay := 2;   (* AR, patch for debugger, 87.07.27 *)
      TermProc (overlayId);
      overlayId^.overlay := 1;   (* AR, patch for debugger, 87.07.27 *)
      debuggerRecord.beforeExit (PROCESS (activProcess), overlayId);
      overlayId^.overlay := 2;   (* AR, patch for debugger, 87.07.27 *)
      parent := overlayId^.father;
      WHILE parent^.parent <> overlayId DO
        parent := parent^.parent;
      END;
      parent^.parent := overlayId^.parent;
      DeleteOverlayInList (overlayId);
      FreeMemory (overlayId);
    END;
  END DeInstallOverlay;


  PROCEDURE InstallOverlayInLayer (     fileName : ARRAY OF CHAR;
                                        layer    : LayerId;
                                    VAR done     : ErrorCode;
                                    VAR status   : Status        ) : OverlayId;

  VAR
    currentOverlay : OverlayPtr;
    currentLevel   : CARDINAL;
    newOverlay     : OverlayPtr;
    entryPoint     : ADDRESS;
    processList    : Process;
    parent         : OverlayPtr;

  BEGIN
    Load (fileName, newOverlay, done, entryPoint, layer);
    IF done = Done THEN
      currentOverlay := activProcess^.currOverlay;
      currentLevel := activProcess^.programLevel;
      newOverlay^.overlay := 2;
      newOverlay^.father := currentOverlay;
      newOverlay^.loaderProcess := activProcess;
      newOverlay^.parent := NIL;
      newOverlay^.processList := NIL;
      InsertOverlayInList (newOverlay);
      activProcess^.currOverlay := newOverlay;
      Call (entryPoint);
      status := newOverlay^.overlayStatus;
      activProcess^.currOverlay := currentOverlay;
      activProcess^.progStatus := Normal;
      IF status = Normal THEN
        parent := currentOverlay;
        WHILE parent^.parent <> NIL DO
          parent := parent^.parent;
        END;
        parent^.parent := newOverlay;
        parent := newOverlay;
        WHILE parent <> NIL DO
          parent^.father := currentOverlay;
          parent := parent^.parent;
        END;
        RETURN newOverlay;
      ELSE
        WHILE newOverlay <> NIL DO
          currentOverlay := newOverlay;
          newOverlay := newOverlay^.parent;
          DeleteOverlayInList (currentOverlay);
          FreeMemory (currentOverlay);
        END;
        RETURN NIL;
      END;
    ELSE
      RETURN NIL;
    END;
  END InstallOverlayInLayer;


  PROCEDURE CallOverlayInLayer (     fileName : ARRAY OF CHAR;
                                     layer    : LayerId;
                                 VAR done     : ErrorCode;
                                 VAR status   : Status        );

  VAR
    currentLevel   : CARDINAL;
    currentOverlay : OverlayPtr;
    newOverlay     : OverlayPtr;
    entryPoint     : ADDRESS;

  BEGIN
    Load (fileName, newOverlay, done, entryPoint, layer);
    IF done = Done THEN
      currentLevel := activProcess^.programLevel;
      currentOverlay := activProcess^.currOverlay;
      NewLevel;
      newOverlay^.overlay := 1;
      newOverlay^.programLevel := curProgLevel;
      newOverlay^.father := currentOverlay;
      newOverlay^.loaderProcess := activProcess;
      newOverlay^.parent := NIL;
      newOverlay^.processList := NIL;
      InsertOverlayInList (newOverlay);
      activProcess^.currOverlay := newOverlay;
      activProcess^.programLevel := curProgLevel;
      Call (entryPoint);
      status := newOverlay^.overlayStatus;
      activProcess^.currOverlay := currentOverlay;
      activProcess^.progStatus := Normal;
      activProcess^.programLevel := currentLevel;
      WHILE newOverlay <> NIL DO
        currentOverlay := newOverlay;
        newOverlay := newOverlay^.parent;
        DeleteOverlayInList (currentOverlay);
        FreeMemory (currentOverlay);
      END;
    END;
  END CallOverlayInLayer;


  PROCEDURE CallOverlay (     fileName : ARRAY OF CHAR;
                          VAR done     : ErrorCode;
                          VAR status   : Status        );

  BEGIN
    CallOverlayInLayer (fileName, NIL, done, status);
  END CallOverlay;


  PROCEDURE InstallOverlay (     fileName : ARRAY OF CHAR;
                             VAR done     : ErrorCode;
                             VAR status   : Status        ) : OverlayId;

  BEGIN
    RETURN InstallOverlayInLayer (fileName, NIL, done, status);
  END InstallOverlay;


  PROCEDURE TermProcess ( currentProcess : Process );

  VAR
    currentOverlay : OverlayPtr;
    parent         : OverlayPtr;
    dd             : OverlayPtr;
    loader         : Process;
    processList    : Process;

  BEGIN
    currentOverlay := currentProcess^.currOverlay;
    IF currentOverlay = NIL THEN
      RETURN
    END;   (* AR 87.07.28 a process may have no overlay loaded *)
    loader := currentOverlay^.loaderProcess;
    WHILE loader = currentProcess DO
      processList := currentOverlay^.processList;
      WHILE processList <> NIL DO
        TermProcess (processList);
        processList := processList^.processList;
      END;
      parent := currentOverlay;
      WHILE parent <> NIL DO
        TermProc (parent);
        debuggerRecord.beforeExit (PROCESS (loader), parent);
        parent := parent^.parent;
      END;
      parent := currentOverlay;
      currentOverlay := currentOverlay^.father;
      loader := currentOverlay^.loaderProcess;
      WHILE parent <> NIL DO
        dd := parent;
        parent := parent^.parent;
        DeleteOverlayInList (dd);
        FreeMemory (dd);
      END;
    END;
    currentProcess^.currOverlay := NIL;
  END TermProcess;


  PROCEDURE CallTermProc;

  VAR
    currentOverlay : OverlayPtr;
    ovlList        : OverlayPtr;
    dyingOvl       : OverlayPtr;
    processList    : Process;

  BEGIN
    dyingOvl := dyingOverlay;
    currentOverlay := activProcess^.currOverlay;
    IF (dyingOvl^.overlay = 1) OR (dyingOvl^.overlayStatus <> Normal) THEN
      WHILE dyingOvl <> currentOverlay DO
        processList := currentOverlay^.processList;
        WHILE processList <> NIL DO
          TermProcess (processList);
          processList := processList^.processList;
        END;
        ovlList := currentOverlay;
        WHILE ovlList <> NIL DO
          TermProc (ovlList);
          debuggerRecord.beforeExit (PROCESS (activProcess), ovlList);
          ovlList := ovlList^.parent;
        END;
        currentOverlay := currentOverlay^.father;
        activProcess^.currOverlay := currentOverlay;
      END;
      ovlList := currentOverlay^.parent;
      WHILE ovlList <> NIL DO
        TermProc (ovlList);
        debuggerRecord.beforeExit (PROCESS (activProcess), ovlList);
        ovlList := ovlList^.parent;
      END;
      TermProc (dyingOvl);   (* the RTD has already been called for it *)
    END;
  END CallTermProc;


  PROCEDURE CallInitProc;

  VAR
    currentOverlay : OverlayPtr;
    pp             : ProcPtr;
    stop           : OverlayPtr;

  BEGIN
    currentOverlay := activProcess^.currOverlay;
    stop := currentOverlay;
    REPEAT
      pp := currentOverlay^.initProc;
      activProcess^.termOverlay := currentOverlay;
      WHILE pp <> NIL DO
        pp^.termProc;
        pp := pp^.next;
      END;
      currentOverlay := currentOverlay^.next;
    UNTIL currentOverlay = stop;
  END CallInitProc;


  PROCEDURE NewProcess ( P : PROCESS );

  VAR
    currentOverlay : OverlayPtr;
    process        : Process;

  BEGIN
    currentOverlay := activProcess^.currOverlay;
    IF currentOverlay^.overlay = 2 THEN
      Terminate (BadOperand);
    ELSE
      process := Process (P);
      process^.processList := currentOverlay^.processList;
      currentOverlay^.processList := process;
    END;
  END NewProcess;

BEGIN
  curProgLevel := activProcess^.programLevel;
  overlayList^.next := overlayList;
  overlayList^.prev := overlayList;
  overlayList^.parent := NIL;
  overlayList^.processList := NIL;
  overlayList^.father := NIL;
  overlayList^.loaderProcess := activProcess;
  overlayList^.overlay := 1;
  overlayList^.programLevel := curProgLevel;
  overlayList^.layer := NIL;
  activProcess^.currOverlay := overlayList;
  overlayTermProc := CallTermProc;
  overlayInitProc := CallInitProc;
  addProcess := NewProcess;
END Overlay.
