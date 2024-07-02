(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    file sub-system for Logitech utilities;                              *)
(*    with minimum interface (for portability).                            *)
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
IMPLEMENTATION MODULE LogiFile;         (* Moe , alg *)
             
FROM SYSTEM   IMPORT ADR, ADDRESS, WORD, BYTE,

                     DOSCALL, SETREG, GETREG, SWI,

                     TSIZE, SIZE;



FROM RTSMain  IMPORT InstallTermProc, curProcess, Terminate, Status;

FROM TimeDate IMPORT Time;

FROM Storage  IMPORT ALLOCATE, DEALLOCATE;

IMPORT Terminal;

CONST
  MaxFile  = 100;  (* maximal number of files *)
  MaxName  = 128; (* length of filename      *)

  BuffSize = 512; (* number of bytes in buffer *)

  (* some ascii character codes *)
  EofC     = NUL;
  EofW     = 0;
  OSEOF    = 32C; (* = 1AH: end-of-file char of the operating system *)

  (* DOS 2.0 function calls *)
  CREAT    = 3CH;
  OPEN     = 3DH;
  CLOSE    = 3EH;
  READ     = 3FH;
  WRITE    = 40H;
  DELET    = 41H;
  LSEEK    = 42H;

TYPE
  Word = RECORD CASE BOOLEAN OF
           TRUE:  word:              WORD;
         | FALSE: highByte, lowByte: BYTE;
         END; END;

MODULE FilePosition;
  EXPORT
    FilePos, AddCard, Compare, CompareType;

  CONST
    maxCard = 0FFFFH;

  TYPE
    FilePos = RECORD high, low: CARDINAL; END; (* 32 bit value *)

    CompareType = (equal, less, greater);

  PROCEDURE AddCard(VAR res: FilePos; pos: FilePos; offset: CARDINAL);
  BEGIN
    res.high := pos.high;
    IF pos.low <= maxCard - offset THEN
      res.low := pos.low + offset;
    ELSE
      res.low := offset - (maxCard - pos.low + 1);
      INC(res.high);
    END;
  END AddCard;

  PROCEDURE Compare(pos1, pos2: FilePos; VAR comp: CompareType);
  BEGIN
    IF pos1.high = pos2.high THEN
      IF pos1.low = pos2.low THEN
        comp := equal;
      ELSIF pos1.low < pos2.low THEN
        comp := less;
      ELSE
        comp := greater;
      END;
    ELSIF pos1.high < pos2.high THEN
      comp := less;
    ELSE
      comp := greater;
    END;
  END Compare;

END FilePosition;



TYPE
  File       = POINTER TO FileDesc;  (* implementation of opaque type *)

  FileStatus = (NoFile, Reading, Writing);

  FileName   = ARRAY [0 .. MaxName-1] OF CHAR;
  FileDesc   = RECORD
                 status      : FileStatus;
                 textFile    : BOOLEAN;     (* alg Mar 16, 87 *)
                               (* init to FALSE, set TRUE by Read/WriteChar *)
                 logicalEof  : BOOLEAN;     (* alg Mar 16, 87 *)
                               (* init to FALSE, set TRUE when OSEOF found *)


                 handle      : WORD; (* DOS 2.0 handle *)

                 owner       : CARDINAL;
                               (* program level that is resource owner *)
                 buffPos     : FilePos; (* position of first buffer byte *)
                 buffer      : ARRAY [1..BuffSize] OF BYTE; (* buffer *)
                 index       : [0..BuffSize];  (* index into buffer    *)
                 validLength : [0..BuffSize];
                               (* valid number of bytes in buffer    *)
                 error       : CARDINAL; (* DOS 2.0 error code *)
                 catalogued  : BOOLEAN; (* Opened or Created file *)
                 fname       : FileName;  (* effectiv filename      *)
                 devlen      : CARDINAL;
                               (* number of characters for drive and path *)
               END;

  PoolIndex  = [0 .. MaxFile-1];

VAR
  pool   : ARRAY PoolIndex OF File;
  failed : FileDesc;
  pix    : PoolIndex;


PROCEDURE Error(f: File);
  VAR device: FileName;
BEGIN (* Error *)
  WITH f^ DO
    Terminal.WriteString(" ---- ");
    Terminal.WriteString(fname);
    Terminal.WriteString(": ");
    CASE error OF
       1: Terminal.WriteString("output disk full");
    |  5: Terminal.WriteString("access denied");
    |  6: Terminal.WriteString("invalid handle");
    ELSE
      Terminal.WriteString("illegal operation on file");
    END;
    Terminal.WriteLn;
    Terminate(Warning);
  END; (* WITH f^*)
END Error;


PROCEDURE OpenFile(VAR f: File; VAR name: ARRAY OF CHAR;
                   new: BOOLEAN; mode: OpenMode; VAR ok: BOOLEAN);
  (* Open a file *)

  VAR pix               : [0 .. MaxFile];
      i 		: CARDINAL;
      
BEGIN (* OpenFile *)
  pix           := 0;

  
  WHILE (pix < MaxFile) AND (pool[pix] <> NIL) DO
    INC(pix);
  END;
  IF  (pix < MaxFile)  THEN
    ok := TRUE;
    NEW(pool[pix]);
    WITH pool[pix]^ DO
      i := 0;
      WHILE    (i < HIGH(fname))
             & (i <= HIGH(name)) & (name[i] <> NUL)  DO
        fname[i] := name[i];
        INC(i);
      END(*while*);
      fname[i] := NUL;  (* separator for DOSCALL *)
      

      
      IF new THEN


        DOSCALL(CREAT, ADR(fname), 0, handle, error);

      ELSE


        DOSCALL(OPEN, ADR(fname), mode, handle, error);

      END;
      IF (error = 0)  THEN
        textFile := FALSE; (* alg *)
        logicalEof := FALSE; (* alg *)

        owner := curProcess^^.currOverlay^.programLevel;

        status := Reading;
        catalogued := NOT new;
        buffPos.high := 0;
        buffPos.low := 0;
        index := 0;       (* to indicate empty buffer *)
        validLength := 0;
      ELSE
        ok := FALSE;
      END;
    END; (* WITH *)
    IF ok THEN
      f := pool[pix];
    ELSE
      f := ADR(failed);
      DISPOSE(pool[pix]);
      pool[pix] := NIL;
    END;
  ELSE(* (pix >= MaxFile) *)
     f := ADR(failed);
     ok := FALSE;
  END(* IF (pix < MaxFile) *);
END OpenFile;

PROCEDURE CloseFile(VAR f: File; remove: BOOLEAN; VAR ok: BOOLEAN);
  VAR
    pix           :  [0 .. MaxFile];
    count         : CARDINAL;

    
BEGIN (* CloseFile *)
  ok := FALSE;

  IF (f <> NIL) AND (f^.status <> NoFile) THEN
    pix := 0;
    WHILE (pix < MaxFile) AND (pool[pix] <> f) DO
       INC(pix)
    END;
    IF pix < MaxFile THEN
      ok := TRUE;
    END;
  END;
  IF ok THEN
    WITH f^ DO
      IF status = Writing THEN


        DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

        IF (error = 0) AND (count <> index) THEN
          error := 1; (* disk full *)
        END;
        IF error <> 0 THEN Error( f) END;
      END;
      ok := TRUE;



      DOSCALL(CLOSE, handle, error); (* close file *)

      ok := error = 0;
      IF remove  THEN


        DOSCALL(DELET, ADR(fname), error);

      END;
      ok := ok AND (error = 0);
      IF ok THEN
        DISPOSE(pool[pix]);
        f := ADR(failed);
        pool[pix] := NIL;
      END;
    END; (* WITH *)
  END;
END CloseFile;

PROCEDURE Open(VAR f: File; name: ARRAY OF CHAR;
               mode: OpenMode; VAR done: BOOLEAN);
  (* Open a file already existing in directory *)
BEGIN (* Open *)
  OpenFile(f, name, FALSE, mode, done);
END Open;

PROCEDURE Create(VAR f: File; name: ARRAY OF CHAR; VAR done: BOOLEAN);
  (* Open a new file *)
BEGIN (* Create *)
  OpenFile(f, name, TRUE, ReadWrite, done);
END Create;

PROCEDURE Close(VAR f: File; VAR done: BOOLEAN);
  (* Close a file, enter a new name into directory *)
BEGIN (* Close *)
  CloseFile(f, FALSE, done);
END Close;

PROCEDURE Delete(VAR f: File; VAR done: BOOLEAN);
  (* Close a file, remove from directory *)
BEGIN (* Delete *)
  CloseFile(f, TRUE, done);
END Delete;

PROCEDURE GetFileDate( f: File; VAR datetime: Time);

  VAR
    date, time: CARDINAL;
    hour, min, sec: CARDINAL;

                 
BEGIN
  WITH f^ DO


    DOSCALL(57H, handle, 0, date, time, error);

    datetime.day := date + 80 * 512;
    sec := 2 * (time MOD 32);
    time := time DIV 32;
    min := time MOD 64;
    hour := time DIV 64;
    datetime.minute := hour * 60 + min;
    datetime.millisec := sec * 1000;
  END; (* WITH *)
END GetFileDate;

PROCEDURE GetPos( f: File; VAR highpos, lowpos: CARDINAL);
  (* Get current position of the file *)

  VAR
    currentPos: FilePos;
BEGIN (* GetPos *)
  WITH f^ DO
    AddCard(currentPos, buffPos, index);
    highpos := currentPos.high;
    lowpos := currentPos.low;
  END; (* WITH *)
END GetPos;

PROCEDURE SetPos( f: File; highpos, lowpos: CARDINAL);
  (* Set file to indicated position *)

  VAR
    count   : CARDINAL;

BEGIN (* SetPos *)
  WITH f^ DO
    IF status = Writing THEN



      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);


      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
    END;



    DOSCALL(LSEEK, handle, 0, highpos, lowpos, highpos, lowpos, error);
 

    IF error <> 0 THEN Error( f) END;
    buffPos.high := highpos;
    buffPos.low := lowpos;
    index := 0;
    validLength := 0;
    status := Reading;
    logicalEof := FALSE;
  END; (* WITH *)
END SetPos;

PROCEDURE Reset(f: File);
  (* Position the file at the beginning and set to idle mode *)
BEGIN (* Reset *)
  SetPos(f, 0, 0);
END Reset;

PROCEDURE ReadChar(f: File; VAR ch: CHAR);
  (* Read a character from file *)
BEGIN (* ReadChar *)
  WITH f^ DO
    textFile := TRUE;
    status := Reading;
    IF  logicalEof THEN
      ch := EofC;
      RETURN;
    ELSIF index >= validLength THEN (* at end of buffer *)
      IF (validLength = BuffSize) OR (validLength = 0) THEN 
        AddCard(buffPos, buffPos, validLength);
   


        DOSCALL(READ, handle, BuffSize, ADR(buffer), validLength, error);

                              
        IF error <> 0 THEN Error( f) END;
        index := 0;
        IF validLength = 0 THEN (* at end of file *)
          ch := EofC;
          RETURN;
        END;
      ELSE (* at end of file *)
        ch := EofC;
        RETURN;
      END;
    END;
    INC(index);
    ch := CHAR(buffer[index]);
    IF ch = OSEOF THEN
      logicalEof := TRUE;
      ch := EofC;
    ELSIF ch = CR THEN
      IF index >= validLength THEN (* at end of buffer *)
        IF (validLength = BuffSize) OR (validLength = 0) THEN 
          AddCard(buffPos, buffPos, validLength);


          DOSCALL(READ, handle, BuffSize, ADR(buffer), validLength, error);
                              
          IF error <> 0 THEN Error( f) END;
          index := 0;
          IF validLength = 0 THEN (* at end of file *)
            ch := EofC;
            RETURN;
          END;
        ELSE (* at end of file *)
          ch := EofC;
          RETURN;
        END;
      END;
      INC(index); (* skip character after <cr>; should be a <lf> *)
      ch := EOL;
    END;
  END; (* WITH *)
END ReadChar;

PROCEDURE WriteChar(f: File; ch: CHAR);
  (* Write a character to file *)
  VAR count: CARDINAL;
BEGIN (* WriteChar *)
  WITH f^ DO
    textFile := TRUE;
    status := Writing;
    IF ch = EOL THEN
      IF index >= BuffSize THEN (* at end of buffer *)



        DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

 
        IF (error = 0) AND (count <> index) THEN
          error := 1; (* disk full *)
        END;
        IF error <> 0 THEN Error( f) END;
        index := 0;
      END;
      INC(index);
      buffer[index] := BYTE(CR);
      ch := LF;
    END;
    IF index >= BuffSize THEN (* at end of buffer *)



      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);


      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, count);
      index := 0;
    END;
    INC(index);
    buffer[index] := BYTE(ch);
  END; (* WITH *)
END WriteChar;


PROCEDURE ReadNBytes(f: File; buffPtr: ADDRESS;
                     requestedBytes: CARDINAL;
                     VAR read: CARDINAL);
  (* Read requested bytes into buffer at address *)
  (* 'buffPtr', number of effectiv read bytes is *)
  (* returned in 'read'                          *)
  VAR i, rest, copy, count: CARDINAL;
      bytePtr: RECORD
                 CASE BOOLEAN OF
                   TRUE:  p: POINTER TO BYTE;
                 | FALSE: a: ADDRESS;
                 END;
               END;
BEGIN
  WITH f^ DO
    status := Reading;
    textFile := FALSE; (* alg *)
    bytePtr.a := buffPtr;
    rest := validLength - index;
    IF requestedBytes < rest THEN
      read := requestedBytes;
    ELSE
      read := rest;
    END;
    FOR i := 1 TO read DO (* copy rest of buffer into user buffer *)
      INC(index);
      bytePtr.p^ := buffer[index];
      INC(bytePtr.a);
    END;
    copy := requestedBytes - read;
    IF copy <> 0 THEN (* read directly into user buffer *)
   


      DOSCALL(READ, handle, copy, bytePtr.a, count, error);
                              
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, validLength + count);
      validLength := 0;
      index := 0;
      INC(read, count);
    END;
  END; (* WITH f^ *)
END ReadNBytes;


PROCEDURE WriteNBytes(f: File;  buffPtr: ADDRESS;
                     requestedBytes: CARDINAL;
                     VAR written: CARDINAL);
  (* Write requested bytes into buffer at address    *)
  (* 'buffPtr', number of effectiv writtten bytes is *)
  (* returned in 'written'                           *)
  VAR count: CARDINAL;
BEGIN
  WITH f^ DO
    status := Writing;
    textFile := FALSE; (* alg *)
    (* write rest of buffer *)
    IF index <> 0 THEN


      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, count);
      index := 0;
    END;
    IF requestedBytes <> 0 THEN (* write directly from user buffer *)



      DOSCALL(WRITE, handle, requestedBytes, buffPtr, written, error);

      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, written);
    ELSE
      written := 0
    END;
  END; (* WITH f^ DO *)
END WriteNBytes;

PROCEDURE ReadByte(f: File; VAR b: BYTE);
  (* Read a byte from file *)
BEGIN
  WITH f^ DO
    textFile := FALSE; (* alg *)
    status := Reading;
    IF index >= validLength THEN (* at end of buffer *)
      IF (validLength = BuffSize) OR (validLength = 0) THEN 
        AddCard(buffPos, buffPos, validLength);


        DOSCALL(READ, handle, BuffSize, ADR(buffer), validLength, error);
                              
        IF error <> 0 THEN Error( f) END;
        index := 0;
        IF validLength = 0 THEN (* at end of file *)
          b := BYTE(EofC);
          RETURN;
        END;
      ELSE (* at end of file *)
        b := BYTE(EofC);
        RETURN;
      END;
    END;
    INC(index);
    b := buffer[index];
  END; (* WITH *)
END ReadByte;

PROCEDURE WriteByte(f: File; b: BYTE);
  (* Write a byte to file *)
  VAR count: CARDINAL;
BEGIN
  WITH f^ DO
    textFile := FALSE; (* alg *)
    status := Writing;
    IF index >= BuffSize THEN (* at end of buffer *)



      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, count);
      index := 0;
    END;
    INC(index);
    buffer[index] := b;
  END; (* WITH *)
END WriteByte;

PROCEDURE ModifyByte(f: File; b: BYTE);
  (* Modify a byte on file *)

  VAR count: CARDINAL;

  PROCEDURE FillBuffer;

  BEGIN
    WITH f^ DO
      IF (validLength = BuffSize) OR (validLength = 0)  THEN
   


        DOSCALL(READ, handle, BuffSize, ADR(buffer), validLength, error);
                              
        IF error <> 0 THEN Error( f) END;
        IF validLength <> 0 THEN
          WITH buffPos DO
 

            DOSCALL(LSEEK, handle, 0, high, low, high, low, error);

          END;
          IF error <> 0 THEN Error( f) END;
        END;
      ELSE
        validLength := 0;
      END;
      index := 0;
    END;
  END FillBuffer;

  PROCEDURE EmptyBuffer;
  BEGIN
    WITH f^ DO


      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, count);
      index := 0;
      validLength := 0;
    END;
  END EmptyBuffer;

BEGIN
  WITH f^ DO
    textFile := FALSE; (* alg *)
    status := Writing;
    IF index >= validLength THEN (* at end of buffer *)
      FillBuffer;
    END;
    INC(index);
    buffer[index] := b;
    IF index >= BuffSize THEN (* at end of buffer *)
      EmptyBuffer;
    END;
    IF index >= validLength THEN (* at end of buffer *)
      EmptyBuffer;
    END;
    IF index >= BuffSize THEN (* at end of buffer *)
      FillBuffer;
    END;
  END; (* WITH *)
END ModifyByte;

PROCEDURE ReadWord(f: File; VAR w: WORD);
  (* Read a word from file *)
  VAR count: CARDINAL;
      temp: Word;

  PROCEDURE FillBuffer(): BOOLEAN;
  BEGIN
    WITH f^ DO
      IF (validLength = BuffSize) OR (validLength = 0) THEN
        AddCard(buffPos, buffPos, validLength);


        DOSCALL(READ, handle, BuffSize, ADR(buffer), validLength, error);
 
        IF error <> 0 THEN Error( f) END;
        index := 0;
        IF validLength = 0 THEN (* at end of file *)
          w := WORD(EofW);
          RETURN FALSE;
        END;
      ELSE (* at end of file *)
        w := WORD(EofW);
        RETURN FALSE;
      END;
    END; (* WITH *)
    RETURN TRUE;
  END FillBuffer;

BEGIN (* ReadWord *)
  WITH f^ DO
    textFile := FALSE; (* alg *)
    status := Reading;
    IF index >= validLength THEN (* at end of buffer *)
      IF NOT FillBuffer() THEN RETURN END;
    END;
    INC(index);
    temp.highByte := buffer[index];
    IF index >= validLength THEN (* at end of buffer *)
      IF NOT FillBuffer() THEN RETURN END;
    END;
    INC(index);
    temp.lowByte := buffer[index];
    w := temp.word;
  END; (* WITH *)
END ReadWord;

PROCEDURE WriteWord(f: File; w: WORD);
  (* Write a word to file *)
  VAR count: CARDINAL;
      temp: Word;

  PROCEDURE EmptyBuffer;
  BEGIN
    WITH f^ DO


      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, count);
      index := 0;
    END; (* WITH *)
  END EmptyBuffer;

BEGIN (* WriteWord *)
  WITH f^ DO
    textFile := FALSE; (* alg *)
    status := Writing;
    temp.word := w;
    IF index >= BuffSize THEN (* at end of buffer *)
      EmptyBuffer;
    END;
    INC(index);
    buffer[index] := temp.highByte;
    IF index >= BuffSize THEN (* at end of buffer *)
      EmptyBuffer;
    END;
    INC(index);
    buffer[index] := temp.lowByte;
  END; (* WITH *)
END WriteWord;

PROCEDURE ModifyWord(f: File; w: WORD);
  (* Modify a word on file *)

  VAR count        : CARDINAL;
      temp         : Word;

      
  PROCEDURE FillBuffer;

   BEGIN
    WITH f^ DO
      IF (validLength = BuffSize) OR (validLength = 0)  THEN


        DOSCALL(READ, handle, BuffSize, ADR(buffer), validLength, error);
                              
        IF error <> 0 THEN Error( f) END;
        IF validLength <> 0 THEN
          WITH buffPos DO

            DOSCALL(LSEEK, handle, 0, high, low, high, low, error);

 
          END;
          IF error <> 0 THEN Error( f) END;
        END;
      ELSE
        validLength := 0;
      END;
      index := 0;
    END;
  END FillBuffer;

  PROCEDURE EmptyBuffer;
  BEGIN
    WITH f^ DO


      DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

      IF (error = 0) AND (count <> index) THEN
        error := 1; (* disk full *)
      END;
      IF error <> 0 THEN Error( f) END;
      AddCard(buffPos, buffPos, count);
      index := 0;
      validLength := 0;
    END;
  END EmptyBuffer;

BEGIN (* ModifyWord *)
  WITH f^ DO
    textFile := FALSE; (* alg *)
    status := Writing;
    temp.word := w;
    IF index >= validLength THEN (* at end of buffer *)
      FillBuffer;
    END;
    INC(index);
    buffer[index] := temp.highByte;
    IF index >= BuffSize THEN (* at end of buffer *)
      EmptyBuffer;
    END;
    IF index >= validLength THEN (* at end of buffer *)
      EmptyBuffer;
    END;
    INC(index);
    buffer[index] := temp.lowByte;
    IF index >= BuffSize THEN (* at end of buffer *)
      FillBuffer;
    END;
  END; (* WITH *)
END ModifyWord;

PROCEDURE EndFile(f: File): BOOLEAN;
  (* End of file reached *)

VAR
    eofPos, currentPos, filePos: FilePos;
    size, offset  : CARDINAL;

    comp: CompareType;
BEGIN (* EndFile *)
  WITH f^ DO
    IF  textFile  AND  logicalEof  THEN  (* alg *)
      RETURN TRUE;
    ELSIF index < validLength THEN
      RETURN FALSE;
    ELSIF      ((index > validLength) OR (index <> BuffSize))
          AND  (validLength <> 0)    (* alg Mar 16, 87 *)
    THEN
      RETURN TRUE;
    ELSE
      size := validLength;
      offset := index;
    END;

    (* get current position *)
    WITH filePos DO

      DOSCALL(LSEEK, handle, 1, 0, 0, high, low, error);


    END;
    IF error <> 0 THEN Error( f); END;

    (* set at end of file   *)

    DOSCALL(LSEEK, handle, 2, 0, 0, eofPos.high, eofPos.low, error);

 
    IF error <> 0 THEN Error( f); END;

    (* set current DOS 2.0 file position *)
    WITH filePos DO

      DOSCALL(LSEEK, handle, 0, high, low, high, low, error);

       
    END;
    IF error <> 0 THEN Error( f); END;

    (* current position *)
    AddCard(currentPos, buffPos, offset);

    Compare(currentPos, eofPos, comp);
(*        IF (comp = greater) (* OR (comp = equal) *) THEN  alg Mar 16,87 *)
    IF  (comp = greater) OR (comp = equal)  THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END;
  END; (* WITH *)
END EndFile;

PROCEDURE TerminateLevel;

    
  VAR
    pix :  [0 .. MaxFile];

    currProg: CARDINAL;

    count: CARDINAL;
BEGIN

  currProg := curProcess^^.currOverlay^.programLevel;

  FOR pix := 0 TO MaxFile - 1 DO
    IF pool[pix] <> NIL THEN
      WITH pool[pix]^ DO
      (*
        IF owner = currProg THEN
      *)
          IF status = Writing THEN


            DOSCALL(WRITE, handle, index, ADR(buffer), count, error);

          END;


          DOSCALL(CLOSE, handle, error); (* close file *)
 
          IF NOT catalogued THEN (* remove temporary file *)


            DOSCALL(DELET, ADR(fname), error);
            
           END;
          pool[pix] := NIL;
      (*
        END; (* IF owner = currProg THEN *)
      *)
      END; (* WITH pool[pix] *)
    END; (* IF pool[pix] <> NIL THEN *)
  END; (* FOR pix := 0 TO MaxFile -1 DO *)
END TerminateLevel;

BEGIN (* LogiFile *)
  FOR pix := 0 TO MaxFile - 1 DO pool[pix] := NIL END;
  WITH failed DO
    status := NoFile;


    handle := WORD(0FFFFH);

    error := 6;
  END(*with*);
  InstallTermProc(TerminateLevel);
END LogiFile.
