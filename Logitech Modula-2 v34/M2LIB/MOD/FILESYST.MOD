(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    File manipulation routines.          		                   *)
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

(* T-*)
(* R-*)
(****************************************************************)
(*                                                              *)
(*      MODULA-2/86 Library                                     *)
(*                                                              *)
(*        LOGITECH SA.,  CH-1143 Apples   (Switzerland)         *)
(*                                                              *)
(*      Module: FileSystem                                      *)
(*        File manipulation routines.                           *)
(*                                                              *)
(*      Version  1.14  (May ' 85)  for MS-DOS 2.0               *)
(*      Version  3.00  (June '87)  for MS-DOS 2.0               *)
(*                                                              *)
(*      (C) Copyright 1983, 1984 Logitech,  All Rights Reserved *)
(*                                                              *)
(*      This program is a trade secret of Logitech, and it is   *)
(*      not to be reproduced, published, disclosed to others,   *)
(*      copied, adapted, distributed or displayed without the   *)
(*      prior authorization of Logitech.                        *)
(*                                                              *)
(*      Licensee agrees to attach or embed this notice on all   *)
(*      copies of the program, including partial copies or      *)
(*      modified versions thereof.                              *)
(****************************************************************)


(* Version 3.0: File attribute and open mode *)

IMPLEMENTATION MODULE FileSystem;               (* WS, opje *)

  IMPORT SYSTEM;

  IMPORT RTSMain;
  FROM RTSMain IMPORT InstallTermProc;
 

  FROM ASCII IMPORT cr, lf, EOL;
  FROM DiskFiles IMPORT InitDiskSystem;

  CONST
    OSEOF = 32C; (* = 1AH; that's the eof code of the
                    underlying operating system. *)

  PROCEDURE PutEOFChar (VAR f: File);
  BEGIN
    WITH f DO
      IF (flags * FlagSet{wr,txt,ef}) = FlagSet{wr,txt,ef} THEN
      (* In a TEXT-FILE, when leaving the write-state
         we have to put an eof character at the current
         position:
      *)
        com := getpos;
        FileCommand (f);
        WriteByte (f,OSEOF);
        INCL (flags, txt);
        com := setpos;
        FileCommand (f);
      END;
    END;
  END PutEOFChar;

  
  PROCEDURE Create (VAR f: File; mediumName: ARRAY OF CHAR); 
  BEGIN
    f.com := create;
    f.fileCreationAttribute := NormalAttribute;
    DirectoryCommand (f, mediumName);
  END Create;


  PROCEDURE CreateFile (VAR f: File; fileName  : ARRAY OF CHAR; 
                                     fileAttrib: CARDINAL     );
  BEGIN
    f.com := createfile;
    f.fileCreationAttribute := fileAttrib;
    DirectoryCommand (f, fileName);
  END CreateFile;

  
  PROCEDURE Close (VAR f: File);
  BEGIN
    IF (f.flags * FlagSet{wr,txt,ef}) = FlagSet{wr,txt,ef} THEN
      (* We are closing a TEXT-FILE after writing at the eof-position *)
      WriteByte (f,OSEOF);
    END;
    f.com := close;
    DirectoryCommand (f, "");
    (* the name is not used *)
  END Close;

  
  PROCEDURE Lookup (VAR f: File; fileName: ARRAY OF CHAR; newFile: BOOLEAN);
  BEGIN
    f.com := lookup;
    f.new := newFile;
    DirectoryCommand (f, fileName);
  END Lookup;


  PROCEDURE OpenFile (VAR f: File; fileName: ARRAY OF CHAR; fileMode: CARDINAL);
  BEGIN
    f.com := openfile;
    f.fileMode := fileMode;
    DirectoryCommand (f, fileName);
  END OpenFile;

  
  PROCEDURE Rename (VAR f: File; newName: ARRAY OF CHAR);
  BEGIN
    f.com := rename;
    DirectoryCommand (f, newName);
  END Rename;


  PROCEDURE Delete (name: ARRAY OF CHAR; VAR f: File);
    (* The file must not be opened before deletion.
       'f' is used as workspace only. *)
  BEGIN
    f.com := delete;
    DirectoryCommand (f, name);
  END Delete;


  PROCEDURE GetAttribute(     fileName  : ARRAY OF CHAR; 
                          VAR fileAttrib: CARDINAL     ;
                          VAR f         : File         );
  BEGIN
    f.com := getattrib;
    DirectoryCommand (f, fileName);
    fileAttrib := f.fileAttribute;
  END GetAttribute;

  
  PROCEDURE SetAttribute(     fileName  : ARRAY OF CHAR;
                              fileAttrib: CARDINAL     ;
                          VAR f         : File         );
  BEGIN
    f.com := setattrib;
    f.fileAttribute := fileAttrib; 
    DirectoryCommand (f, fileName);
  END SetAttribute;

  
  PROCEDURE SetRead (VAR f: File);
  BEGIN
    PutEOFChar (f);
    f.com := setread;
    FileCommand (f);
  END SetRead;

  
  PROCEDURE SetWrite (VAR f: File);
  BEGIN
    f.com := setwrite;
    FileCommand (f);
  END SetWrite;
  

  PROCEDURE SetModify (VAR f: File);
  BEGIN
    PutEOFChar (f);
    f.com := setmodify;
    FileCommand (f);
  END SetModify;

  
  PROCEDURE SetOpen (VAR f: File);
  BEGIN
    PutEOFChar (f);
    f.com := setopen;
    FileCommand (f);
  END SetOpen;

  
  PROCEDURE Doio (VAR f: File);
  BEGIN
    f.com := doio;
    FileCommand (f);
  END Doio;


  PROCEDURE SetPos (VAR f: File; high, low: CARDINAL);
  BEGIN
    WITH f DO
      com := setpos;
      highpos := high;
      lowpos := low;
    END;
    FileCommand (f);
  END SetPos;

  PROCEDURE GetPos (VAR f: File; VAR high, low: CARDINAL);
  BEGIN
    WITH f DO
      com := getpos;
      FileCommand (f);
      high := highpos;
      low := lowpos;
    END;
  END GetPos;

  PROCEDURE Length (VAR f: File; VAR high, low: CARDINAL);
  BEGIN
    WITH f DO
      com := length;
      FileCommand (f);
      high := highpos;
      low := lowpos;
    END;
  END Length;


  PROCEDURE Reset(VAR f: File);
  BEGIN 
    SetOpen(f);
    SetPos(f, 0, 0)
  END Reset;


  PROCEDURE SetResponse(VAR f: File; resp: Response);
  BEGIN 
    WITH f DO 
      res := resp;
      IF resp <> done THEN  
        eof := TRUE; 
        flags := flags + FlagSet{er, ef} 
      END
    END   
  END SetResponse; 
 

(**************************************************************)

  MODULE Streams;

    IMPORT
      File, Response, Flag, FlagSet, 
      SetRead, SetWrite, SetModify, Doio,
      SetPos, GetPos,
      SetResponse,
      OSEOF, cr, lf, EOL;

    FROM SYSTEM IMPORT WORD, BYTE, TSIZE, ADDRESS, ADR, SETREG, CX, CODE;

      
    EXPORT
      Again,
      ReadWord, WriteWord,
      ReadByte, WriteByte,
      ReadChar, WriteChar,
      ReadNBytes, WriteNBytes;

 
    TYPE
      ResponseSet = SET OF Response; (* an auxiliary type *)

    CONST
      eofc = 0C;
      REPNZ = 0F2H;
      MOVSB = 0A4H;
      LDS   = 0C5H;
      LES   = 0C4H;
      SIviaBP = 76H;
      DIviaBP = 7EH;



    PROCEDURE MoveBlock (src, dest: ADDRESS; count: CARDINAL);
    BEGIN
      CODE (LDS, SIviaBP,10);
      CODE (LES, DIviaBP,6);
      SETREG (CX, count);
      CODE (REPNZ, MOVSB);
    END MoveBlock;


    PROCEDURE Again(VAR f: File);
    BEGIN
      WITH f DO
        IF rd IN flags THEN
          IF bufind > 0 THEN
            INCL(flags, ag);
          END;
        END;
      END;
    END Again;
   
  
    PROCEDURE ReadByte (VAR f: File; VAR b: BYTE);
    BEGIN
      WITH f DO
        IF buflength = 0 THEN (* invalid file *)
          res := callerror;
          INCL(flags, er);
          RETURN;
        END;
        LOOP
          IF flags*FlagSet{rd, ag, ef} <> FlagSet{rd} THEN
            IF NOT (rd IN flags) THEN 
              IF wr IN flags THEN
                SetResponse(f, callerror);
              ELSE
                SetRead(f);
              END;
            END;
            IF eof THEN  (* reading past eof *)
              res := notdone;
              INCL (flags, er);
              b := BYTE (eofc);
              lastRead := ORD (eofc);
              EXIT;
            END;
            IF ag IN flags THEN
              EXCL(flags, ag);
              b := BYTE (CHR (lastRead));
              EXIT;
            END;
          ELSIF (bufind >= buflength) THEN
            (* load the next buffer: *)
            Doio(f);
            IF eof THEN
              res := done;  (* not considered an error *)
              EXCL (flags, er);
              b := BYTE (eofc);
              lastRead := ORD(eofc);
              EXIT;
            END;
          ELSIF bufind >= validlength THEN
            (* eof reached: *)
            eof := TRUE;
            INCL (flags, ef);
            b := BYTE (eofc);
            lastRead := ORD(eofc);
            EXIT;
          ELSE
            b := BYTE (bufa^ [bufind]);
            INC (bufind);
            lastRead := ORD (b);
            EXIT;
          END;
        END; (* LOOP *)  
      END; (* WITH *)
    END ReadByte;

    PROCEDURE ReadChar (VAR f: File; VAR ch: CHAR);

      PROCEDURE SetBack;
        VAR high, low: CARDINAL;
      BEGIN
        GetPos(f, high, low);
        IF low = 0 THEN (* decrement fileposition by 1 in long arith *)
          DEC(high);
          low := 0FFFFH;
        ELSE
          DEC(low);
        END;
        SetPos(f, high, low);
      END SetBack;
   
    BEGIN
      IF f.eof THEN
        ch := eofc;
        SetResponse (f, notdone);
        RETURN;
      END;
      ReadByte (f, ch);
      IF ch = cr THEN
        ReadByte (f, ch); (* look ahead for a <lf> *)
        IF f.eof THEN (* physical end of file, reset end of file state *)
          EXCL(f.flags, ef);
          f.eof := FALSE;
          f.lastRead := ORD(cr);
        ELSIF ch <> lf THEN (* too bad, no <lf>, so reset look ahead *)
          SetBack;
          f.lastRead := ORD(cr);
        END;
        ch := EOL; (* map single <cr> or <cr><lf> into EOL *)
      ELSIF ch = lf THEN (* single <lf> mapped into EOL *)
        ch := EOL;
(* just for documentation
      ELSE
        it was not an end of line indicator, so don't handle it
*)
      END;
      INCL (f.flags, txt);
      IF f.eof OR (ch=OSEOF) THEN
        IF ch = OSEOF THEN SetBack END;
        f.eof := TRUE;
        ch := eofc;
        f.lastRead := ORD(eofc);
        INCL (f.flags, ef);
      END;
    END ReadChar;

   
    PROCEDURE ReadWord(VAR f: File; VAR w: WORD);
      VAR c: CHAR;
    BEGIN
      IF (ag IN f.flags) THEN
        w := WORD(f.lastRead);
        EXCL (f.flags,ag);
      ELSE
        ReadByte (f, c);
        w := WORD(ORD (c));
        IF NOT f.eof THEN
          ReadByte (f, c);
          w := WORD(CARDINAL(w) + ORD(c)*256);
          (* Note: a WORD is stored with lower byte first *)
          IF f.eof THEN
            f.res := notdone; INCL(f.flags, er);
            w := WORD(0);
          END;
        END;
      END;
      f.lastRead := CARDINAL(w);
    END ReadWord;


    PROCEDURE ReadNBytes (VAR f: File; bufPtr: ADDRESS;
                requestedBytes: CARDINAL; VAR read: CARDINAL);
    (* July 84:  the 'ag'-bit in 'flags' is also treated.
       Return conditions:
         'callerror' is returned, if in 'writing' mode.
         'notdone' is returned, if zero bytes could be read.
         No error is returned, if some but not all requested
         bytes could be read ('eof' becomes TRUE and 'read'
         gives actually transfered bytes).
    *)
      VAR
        oldbufa, sourcePtr : ADDRESS;
        bPtr : POINTER TO CHAR;
        modifyMode : BOOLEAN;
        i, available, reqBytes, temp : CARDINAL;
    BEGIN
      WITH f DO
        IF buflength = 0 THEN (* invalid file *)
          res := callerror;
          INCL(flags, er);
          RETURN;
        END;
        read := 0;
        IF (wr IN flags) AND NOT (rd IN flags) THEN
          SetResponse(f, callerror);
          RETURN;
        END;
        IF requestedBytes = 0 THEN
          res:= done;  EXCL (flags, er);
          RETURN;
        END;
        IF eof THEN  (* reading past eof *)
          res:=notdone;  INCL (flags, er);
          RETURN;
        END;
        reqBytes := requestedBytes;
        IF (ag IN flags) THEN
          EXCL (flags, ag);
          bPtr := bufPtr;  bPtr^ := CHR(lastRead);
          read := 1;  DEC (reqBytes);
          IF requestedBytes = 1 THEN
            res:= done;  EXCL (flags, er);
            RETURN;
          END;
          INC (bufPtr);
        END;
        modifyMode := FALSE;
        IF NOT (rd IN flags) THEN
          (* state is 'opened' *)
          IF bufind = 0 THEN
            IF reqBytes >= buflength THEN
              oldbufa := bufa;
              bufa := bufPtr;
              SetRead (f);  (* this reads the first buffer *)
              temp:=validlength;
              INC (bufPtr, temp);
              bufa := oldbufa;
              INC (read, validlength); (* already transfered *)
              bufind := validlength; (* we simulate reading *)
            ELSE
              SetRead (f);
              (* 'bufind' is 0, so we can use 'validlength' bytes *)
              IF validlength < reqBytes THEN
                reqBytes := validlength;
                eof := TRUE; (* file is too short *)
                INCL (flags, ef);
              END;
              MoveBlock (bufa, bufPtr, reqBytes);
              INC (read, reqBytes);
              res := done;
              EXCL (flags, er);
              bufind := reqBytes;
              RETURN;
            END;
          ELSE  (* bufind <> 0 *)
            SetRead (f);
            available := validlength - bufind;
            sourcePtr := ADR(bufa^[bufind]);
            IF available >= reqBytes THEN
              (* the requested bytes are all in current buffer *)
              INC (read, reqBytes);
              MoveBlock (sourcePtr, bufPtr, reqBytes);
              INC (bufind, reqBytes);
              res := done;
              EXCL (flags, er);
              RETURN;
            ELSE
              (* We want to transfer more bytes than are available in
                 current buffer. First we transfer the remaining bytes:
              *)
              INC (read, available);
              MoveBlock (sourcePtr, bufPtr, available);
              bufind := validlength;
              INC (bufPtr, available);
            END;
          END (* IF bufind <> 0 *)
        ELSE (* rd IN flags *)
          (* state = 'reading' or 'modifying' *)
          IF bufind > validlength THEN
            (* this should not happen, but let's be save: *)
            bufind := validlength;
          END;
          available := validlength - bufind;
          sourcePtr := ADR(bufa^[bufind]);
          IF available >= reqBytes THEN
            (* the requested bytes are all in current buffer *)
            INC (read, reqBytes);
            res := done;
            EXCL (flags, er);
            MoveBlock (sourcePtr, bufPtr, reqBytes);
            INC (bufind, reqBytes);
            RETURN;
          ELSE
            (* We want to transfer more bytes than are available in
               current buffer. First we transfer the remaining bytes:
            *)
            INC (read, available);
            MoveBlock (sourcePtr, bufPtr, available);
            INC (bufPtr, available);
            IF validlength < buflength THEN
              res := done;
              EXCL (flags, er);
              eof := TRUE; (* file is too short *)
              INCL (flags, ef);
              INC (bufind, available);
              RETURN;
            END;
            IF wr IN flags THEN
              modifyMode := TRUE;
              IF bufind >= buflength THEN
                bufind := buflength - 1;
                (* index should point somewhere inside buffer *)
              END;
              SetRead (f);
              (* to avoid writing of the buffer before reading
                 the next one.
              *)
            END;
            bufind := validlength; (* current buffer is emptied *)
          END;
        END; (* rd IN flags *)
        (* Now, the remaining bytes in current buffer are read.
           'bufind' is updated to point to 'validlength';
           state is pure read (not modify);
           'read' is number of already read bytes;
           'bufPtr' is updated to point behind the read bytes.
        *)
        reqBytes := requestedBytes - read;
        IF reqBytes = 0 THEN
          RETURN;  (* return values are already updated *)
        END;
        IF reqBytes >= buflength THEN
          oldbufa := bufa;
          bufa := bufPtr;
          FOR i := 1 TO (reqBytes DIV buflength) DO
            Doio (f);
            bufind := buflength;
            INC (read, validlength);
            bufa := ADDRESS(bufa) + validlength;
          END;
          bufPtr := bufa;
          bufa := oldbufa;
          reqBytes := reqBytes MOD buflength;
        END;
        (* Now, we have to read the bytes from the last buffer,
           which we read only partially:
        *)
(* May 28'85 *)
        Doio (f); (* load the buffer; 'bufind' = 0 *)
        IF reqBytes <> 0 THEN
          IF res <> done THEN reqBytes := 0;
          ELSIF validlength < reqBytes THEN reqBytes := validlength; END;
          MoveBlock (bufa, bufPtr, reqBytes);
          INC (read, reqBytes);
          bufind := reqBytes;
        END;
        IF modifyMode THEN SetModify (f); END;
        res := done;
        EXCL (flags, er); (* the 'doio' above might have set it *)
        IF read < requestedBytes THEN
          eof := TRUE; (* file is too short *)
          INCL (flags, ef);
        END;
      END; (* WITH *)
    END ReadNBytes;


    PROCEDURE WriteByte(VAR f: File; b: BYTE);
    BEGIN
      WITH f DO
        IF buflength = 0 THEN (* invalid file *)
          res := callerror;
          INCL(flags, er);
          RETURN;
        END;
        LOOP
          IF er IN flags THEN
            RETURN;  (* don't modify 'flags' and 'res' *)
          END;
          IF NOT (wr IN flags) THEN
            IF rd IN flags THEN
              SetResponse(f, callerror);
            ELSE SetWrite(f); END;
          ELSIF bufind >= buflength THEN Doio(f)
          ELSE
            bufa^ [bufind] := CHAR (b);
            INC (bufind);
            IF bufind > validlength THEN
              validlength := bufind;
              eof := TRUE;     (* we reached end-of-file: update *)
              INCL (flags, ef);(* the descr, if in modify-mode.  *)
            END;
            EXCL (flags, txt);
            RETURN;
          END;
        END; (* LOOP *)
      END; (* WITH *)
    END WriteByte;


    PROCEDURE WriteChar(VAR f: File; ch: CHAR);
    BEGIN
      IF ch = EOL THEN
        WriteByte (f,cr);
        ch := lf;
      END;
      WriteByte (f, ch);
      INCL (f.flags, txt);
    END WriteChar;


    PROCEDURE WriteWord(VAR f: File; w: WORD);
    BEGIN
      WriteByte (f, CHR (CARDINAL(w) MOD 256));
      WriteByte (f, CHR (CARDINAL(w) DIV 256));
    END WriteWord;
   

    PROCEDURE WriteNBytes (VAR f: File; bufPtr: ADDRESS;
                requestedBytes: CARDINAL; VAR written: CARDINAL);
      VAR
        oldbufa, destPtr : ADDRESS;
        modifyMode : BOOLEAN;
        i, w : CARDINAL;
    BEGIN
      WITH f DO
        IF buflength = 0 THEN (* invalid file *)
          res := callerror;
          INCL(flags, er);
          RETURN;
        END;
        IF (rd IN flags) AND NOT (wr IN flags) THEN
          SetResponse (f, callerror); (* no writing in reading state *)
          RETURN;
        END;
        IF NOT (wr IN flags) THEN SetWrite (f) END;
        w := buflength - bufind;
        IF w > requestedBytes THEN w := requestedBytes END;
        destPtr := ADR(bufa^[bufind]);
        IF w <> 0 THEN
          MoveBlock (bufPtr, destPtr, w);
          INC (bufPtr, w);
          INC (bufind, w);
        END;
        IF bufind > validlength THEN
          validlength := bufind;
          eof := TRUE;     (* we reached end-of-file: update *)
          INCL (flags, ef);(* the descr, if in modify-mode.  *)
        END;
        written := w;
        IF written = requestedBytes THEN
          RETURN;  (* all bytes fit in current buffer *)
        END;
        w := requestedBytes - written;
        IF w >= buflength THEN
          modifyMode := FALSE;
          IF rd IN flags THEN
            modifyMode := TRUE;
            SetWrite (f);
          END;
          Doio (f); (* write the just filled buffer *)
          oldbufa := bufa;
          bufa := bufPtr;
          FOR i := 1 TO (w DIV buflength) DO
            validlength := buflength;
            bufind := validlength;
            Doio (f);
            IF res = done THEN
              INC (written, buflength);
              bufa := ADDRESS(bufa) + buflength;
            END;
          END; (* FOR *)
          bufPtr := bufa;
          bufa := oldbufa;
          IF res <> done THEN RETURN (* usually eom *) END;
          bufind := 0;
          validlength := 0;
          IF modifyMode THEN  SetModify (f);  END;
        END; (* IF w >= buflength *)
        Doio (f);  (* force the writing of the filled buffer *)
                   (* and read the next one, if in modify state *)
        IF res <> done THEN  RETURN  (*usually eom *) END;
        w := w MOD buflength;
        MoveBlock (bufPtr, bufa, w);
        INC (written, w);
        INC (bufind, w);
        IF bufind > validlength THEN
          validlength := bufind;
          eof := TRUE;     (* we reached end-of-file: update *)
          INCL (flags, ef);(* the descr, if in modify-mode.  *)
        END;
      END; (* WITH *)
    END WriteNBytes;


  END Streams;

(**************************************************************)

  
  MODULE Mediums;

    FROM SYSTEM IMPORT WORD;

    IMPORT RTSMain;
    
    IMPORT InstallTermProc;

    IMPORT
      File, MediumType, MediumHint,
      Response, Command,
      Flag, FlagSet,
      FileProc, DirectoryProc,
      SetResponse,

      InitDiskSystem;


    EXPORT 
      CreateMedium, RemoveMedium,
      FileCommand, DirectoryCommand;

     
    CONST
      mediums   = 30;       (* maximal number of mediums *)
      mnlength  = 3;        (* maximal length of medium names
                               (name and volume, if implemented) *)

    TYPE
      MediumName = ARRAY [0..mnlength-1] OF CHAR;
                   (* it is not necessarily equal to MediumType, since
                      MediumName could in another impl. contain an additional
                      "volume-number". *)

      MediumKind = (free, original);

      MediumDesc = RECORD 
                     medtyp: MediumType;
                     progId: CARDINAL; (* program identifier of owner *)
                     CASE mk: MediumKind OF
                       free: | 
                       original:
                         fp: FileProc;
                         dp: DirectoryProc      
                     END;  
                   END;  


    VAR 
      mtab: ARRAY [0..mediums-1] OF MediumDesc; 
      auxMed: MediumHint; (* used as index in mtab *)


    PROCEDURE Equal(mt1, mt2: MediumType): BOOLEAN; 
    BEGIN   
      RETURN (mt1[0] = mt2[0]) AND (mt1[1] = mt2[1]) AND (mt1[2] = mt2[2]) 
    END Equal; 


    PROCEDURE GoodChar (c: CHAR): BOOLEAN;
      VAR cch: CHAR;
    BEGIN
      cch := CAP(c);
      RETURN ('A' <= cch) AND (cch <= 'Z') OR
             ('0' <= c) AND (c <= '9') OR
             (c = ' ');
    END GoodChar;


    PROCEDURE LookupMedium(mn: MediumName; VAR found: BOOLEAN;
                           VAR mt: MediumType);
      (* Splits the MediumType from the MediumName (in the current impl. they
         are identical). Verifies the syntax of MediumName. "found" says, if
         the syntax is correct. The resulting MediumName is "normalised",
         i.e. the string is filled with spaces, if needed.
      *)

      VAR
        ch, cch: CHAR;

    BEGIN
      mt := '   ';
      ch := mn[0]; cch := CAP(ch);
      found := ('A' <= cch) AND (cch <= 'Z');
      IF found THEN
        mt[0] := cch;
        ch := mn[1];
        IF GoodChar (ch) THEN
          mt[1] := CAP(ch);
          ch := mn[2];
          IF GoodChar (ch) THEN
            mt[2] := CAP(ch);
          ELSIF (ch <> 0C) THEN
            found := FALSE;
          END;
        ELSIF (ch <> 0C) THEN
          found := FALSE;
        END;
      END;
    END LookupMedium;

 
    PROCEDURE Check(mt: MediumType): BOOLEAN;  
      (* Checks syntax of "mt", given that the length is ok
         (filled with spaces if needed).
      *)
      VAR ch, cch: CHAR;

    BEGIN 
      ch := mt[0]; cch := CAP(ch); 
      IF ('A' <= cch) AND (cch <= 'Z') THEN 
        ch := mt[1];
        IF GoodChar(ch) THEN
          ch := mt[2];
          RETURN GoodChar(ch);
        ELSE RETURN FALSE; END;
      ELSE RETURN FALSE; END;
    END Check; 


    PROCEDURE Search(mt: MediumType): MediumHint; 
      (* Searches the array "mtab" for the medium "mt". If it exists, its
         index is returned. If not found, HIGH+1 is returned.
      *)
      VAR m: MediumHint;
 
    BEGIN 
      FOR m := 0 TO mediums-1 DO
        WITH mtab[m] DO 
          IF (mk <> free) AND Equal(medtyp, mt) THEN
            RETURN m;
          END; 
        END; 
      END; 
      RETURN mediums
    END Search;


    PROCEDURE TerminateLevel;
      (* Returns the mediums, belonging to one program. Called upon
         termination of a program.
      *)
      VAR
        m: MediumHint;

        curProg: CARDINAL;

    BEGIN

      curProg := RTSMain.curProcess^^.currOverlay^.programLevel;

      FOR m := 0 TO mediums - 1 DO
        WITH mtab[m] DO
          IF (mk <> free) (*AND (progId >= curProg)*) THEN
            mk := free;
          END;
        END;
      END;
    END TerminateLevel;


    PROCEDURE CreateMedium(mt: MediumType;
                           fproc: FileProc; dproc: DirectoryProc;
                           VAR done: BOOLEAN);
      (* Through this routine, a driver can announce a new medium. It has
         to give a name of that medium (mt), a procedure to perform directory
         operations (dproc) and a procedure for operations on a file (fproc).
         "done" tells, if the new medium has been accepted or not.
      *)
      VAR m: MediumHint;
         
    BEGIN 
      done := FALSE; 
      IF Check(mt) THEN 
        IF Search(mt) >= mediums THEN 
          (* This condition means, the same medium does not yet exist *)
          m := 0;
          WHILE (m<mediums) AND (mtab[m].mk<>free) DO INC(m) END;
          (* m is the index of a free entry *)  
          IF m < mediums THEN 
            done := TRUE; 
            WITH mtab[m] DO
              medtyp := mt;
              progId := 1;   (* 2.05 System.curProcess^^.sharedId;*)
              mk := original;
              fp := fproc;
              dp := dproc;
            END;
          END;
        END;
      END;
    END CreateMedium; 


    PROCEDURE RemoveMedium(mt: MediumType; VAR done: BOOLEAN);
      (* Removes the medium "mt" from the table of existing mediums.
         "done" returns TRUE if the medium could be removed, otherwise FALSE,
         which means, the medium does not exist or it belongs to another
         program than the current one (and its successors that share resources).
      *)
      VAR m: MediumHint; 

    BEGIN
      m := Search(mt); 
      done := (m < mediums) AND
              (mtab[m].progId = 1 (*2.05 System.curProcess^^.sharedId*)  );
       (* don't use 'System.curProcess^^.programId',
          which would be too restrictif *)
      IF done THEN mtab[m].mk := free END  
    END RemoveMedium; 


    PROCEDURE FileCommand(VAR f: File); 
    BEGIN
      WITH f DO 
        IF buflength = 0 THEN (* invalid file *)
          res := callerror;
          INCL(flags, er);
          RETURN;
        END;
        LOOP
          (* the file descriptor contains a MediumHint, to speed up: *)
          IF mHint < mediums THEN
            WITH mtab[mHint] DO
              IF (mk = original) AND Equal(medtyp, mt)
              (* This is to check, if mHint is still valid *)
              THEN
                fp(f); (* this is the actual call of the FileProcedure *)
                RETURN;
              END;
            END;
          END;
          IF Check(mt) THEN 
            mHint := Search(mt); (* adjust mHint *)
            IF mHint >= mediums THEN
              SetResponse(f, unknownmedium); 
              RETURN;
            END;
          ELSE
            (* the syntax of the medium type is wrong *)
            SetResponse(f, paramerror);
            RETURN;
          END;
        END;
      END;
    END FileCommand; 


    PROCEDURE DirectoryCommand(VAR f: File; fn: ARRAY OF CHAR);
      (* for the commands: create, close, lookup, rename, delete *)
      VAR
        mn: MediumName; empty, found: BOOLEAN;
        mt1: MediumType;
        ch: CHAR;
        c, d: CARDINAL;

    BEGIN
      WITH f DO
        (* allow rename only with f.res = done and er not in flags *)
        IF (com = rename) AND (buflength = 0) THEN (* invalid file *)
          res := callerror;
          INCL(flags, er);
          RETURN;
        END;

        (* initialise file as invalid *)
        IF (com = create) OR (com = lookup) OR (com = createfile) OR 
           (com = openfile) THEN
          buflength := 0;
        END;

        (* split mediumname from the filename *)
        c := 0; empty := TRUE;
        LOOP
          IF c > HIGH(fn) THEN EXIT END;
          ch := fn[c];
          IF ch = ':' THEN
            empty := FALSE; (* medium name specified *)
            EXIT
          END;
          IF c >= mnlength THEN EXIT END;
          mn[c] := ch; INC(c);
        END;
        IF c < mnlength THEN mn[c] := 0C END;
           (* terminate the medium name, if too short *)
        IF empty THEN
          mn := "DK";
          (* set default medium name, if none specified *)
(*
        ELSE (* fn[c] = ':' *)
           INC(c);
           (* skip the separator of mediumname *)
           d := c;
           WHILE c <= HIGH(fn) DO
             fn[c-d] := fn[c]; INC(c);
             (* move the name to the beginning of the string *)
           END;
           fn[c-d] := 0C; (* and terminate it *)

removed for dos 2.0 
*)
        END;

        IF com <> close THEN
          (* Note that no (medium) name is specified for some
             directory operations on open files (command close).
          *)
          LookupMedium(mn, found, mt1); (* convert mn to mt *)
          IF found THEN
            IF com = rename THEN 
              IF NOT Equal(mt, mt1) THEN
                SetResponse(f, paramerror); RETURN;
              END;
            ELSE (* com is create, lookup, createfile, openfile or delete *)
              mt := mt1;
              mHint := mediums;
            END;
          ELSE SetResponse(f, unknownmedium); RETURN;
          END;
        END;

        LOOP 
          IF mHint < mediums THEN
            WITH mtab[mHint] DO
              IF (mk = original) AND Equal(medtyp, mt)
              (* check if file descriptor is still consistent *)
              THEN
                dp(f, fn); (* That's the actual call of the directory proc *)
                           (* fn does not contain the mediumname anymore *)

                (* initialise file as invalid *)
                IF (com = close) OR (com = delete) OR 
                   (com = getattrib) OR (com = setattrib) THEN
                  buflength := 0;
                END;

                RETURN;
              END;
            END;
          END;
          IF Check(mt) THEN 
            mHint := Search(mt); (* adjust mHint *)
            IF mHint >= mediums THEN 
              SetResponse(f, unknownmedium); 
              RETURN;
            END 
          ELSE 
            SetResponse(f, paramerror); 
            RETURN;
          END; 
        END; (* LOOP *)

      END; (* WITH *)
    END DirectoryCommand;   


  BEGIN 
    FOR auxMed := 0 TO mediums-1 DO mtab[auxMed].mk := free END;
    InstallTermProc(TerminateLevel); 
    InitDiskSystem;
  END Mediums;
(**********************************************************)

 
  PROCEDURE FileNameChar (c: CHAR) : CHAR;
    (* Checks if 'c' is legal character for DOS-2.0 filename. *)
    (* Lowercase characters are transformed in uppercase.     *)
    (* Returns 0C if illegal                                  *)
  BEGIN
    CASE c OF
      'A'..'Z', '0'..'9'  : RETURN (c);
    | 'a'..'z'            : RETURN (CAP(c));
    | '$', '&', '#', '@', '!', '%', "'", '`', '(', ')',
      '-', '_', '^', '~'  : RETURN (c);
    | '.', ':', '\'       : RETURN (c); (* for complete pathname *)
    ELSE                    RETURN (0C);
    END;
  END FileNameChar;
  
END FileSystem.
