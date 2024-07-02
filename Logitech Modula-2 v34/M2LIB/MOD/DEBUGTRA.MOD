(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    displays the stack upon abnormal termination	      		   *)
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
IMPLEMENTATION MODULE DebugTrace;

IMPORT SYSTEM, ASCII, Strings, RTSMain;

FROM SYSTEM  IMPORT ADR, ADDRESS, PROCESS, NEWPROCESS, TRANSFER;
FROM RTSMain IMPORT OverlayPtr, ProcedureKind, Process, ProcessDescriptor,
                    Status;

TYPE Help=  RECORD CASE CARDINAL OF
                     0: address: ADDRESS;
                   | 1: addrPtr: POINTER TO ADDRESS;
                   | 2: cardPtr: POINTER TO CARDINAL;
                   END;
             END;

VAR overlayList : OverlayPtr;
    basePointer: ADDRESS;

(**********************************************************************)

MODULE  Out;

FROM SYSTEM IMPORT DOSCALL;
FROM ASCII  IMPORT cr, lf, esc;

EXPORT Write, WriteLn, WriteCardinal, WriteString, WriteHex;


PROCEDURE Write (ch: CHAR);
BEGIN
  DOSCALL (6, ch);
END Write;

PROCEDURE WriteString   ( str : ARRAY OF CHAR;  len : CARDINAL);
VAR
  i     : CARDINAL;
BEGIN
  i := 0;
  WHILE (i <= HIGH(str)) & (str[i] <> 0C)  DO
    Write(str[i]);
    INC(i);
  END;
  WHILE  (i <= len)  DO
    Write(' ');
    INC(i);
  END;
END WriteString;

PROCEDURE WriteLn(VAR stopped: BOOLEAN);
VAR
  ch : CHAR;
BEGIN
  Write(cr); Write(lf);
  INC(lineCnt);
  IF  (lineCnt = 21)  THEN
    WriteString('hit any key to continue, <ESC> to stop',0);
    DOSCALL(8H,ch);
    stopped := (ch = esc);
    Write(cr); Write(lf);
    lineCnt := 1;
  END;
END WriteLn;


PROCEDURE WriteDigit (d: CARDINAL);
BEGIN
  IF d > 9 THEN
    Write(CHR((d - 10) + ORD('A')));
  ELSE
    Write(CHR(d + ORD('0')));
  END;
END WriteDigit;

PROCEDURE WriteCardinal (c : CARDINAL);
VAR i, base : CARDINAL;
BEGIN
  i := 0;
  base := 10000;
  LOOP
    IF (c >= base) OR (i > 0) THEN
      WriteDigit (c DIV base);
      INC (i);
    ELSE
      IF (i=0) AND (base=1)  THEN
        Write('0');
      ELSE
        Write(' ');
      END;
    END;
    IF base = 1 THEN EXIT END;
    c := c MOD base;
    base := base DIV 10;
  END;
END WriteCardinal;

PROCEDURE WriteHex (c: CARDINAL);
VAR i, base: CARDINAL;
BEGIN
  base := 1000H;
  FOR i:=1 TO 4 DO
    WriteDigit (c DIV base);
    c := c MOD base;
    base := base DIV 10H;
  END;
END WriteHex;

VAR lineCnt: CARDINAL;
BEGIN
  lineCnt := 0;
END Out;


(**********************************************************************)

MODULE File;

FROM SYSTEM  IMPORT DOSCALL, ADR;
FROM ASCII   IMPORT cr, EOL;

EXPORT  Open, Close, GetPos, SetPos, GetChar;

CONST
  CtrlZ         = 32C;

  close         = 3EH;
  open          = 3DH;
  read          = 3FH;
  setpos        = 42H;

  maxBuf        = 512;

TYPE File     = RECORD  
                  handle: CARDINAL;
                  highPos, lowPos: CARDINAL;
                  buffer :  ARRAY [1..maxBuf] OF CHAR;
                  curInd, lastInd: CARDINAL;
                  eof: BOOLEAN;
               END;

VAR file: File;


  PROCEDURE AddCard(VAR highRes, lowRes: CARDINAL; 
                        highPos,lowPos, offset: CARDINAL);
  BEGIN
    highRes := highPos;
    IF lowPos <= 0FFFFH - offset THEN
      lowRes := lowPos + offset;
    ELSE
      lowRes := offset - (0FFFFH - lowPos + 1);
      INC(highRes);
    END;
  END AddCard;

  PROCEDURE SetBufPos (high,low: CARDINAL);
  BEGIN
    WITH file DO
      highPos := high;
      lowPos  := low;
      curInd  := 0;
      lastInd := 0;
      eof := FALSE;
    END;
  END SetBufPos;

PROCEDURE GetPos( VAR high, low: CARDINAL);
  (* Get current position of the file *)
BEGIN (* GetPos *)
   AddCard(high,low, file.highPos, file.lowPos, file.curInd);
END GetPos;

PROCEDURE SetPos( high, low : CARDINAL);
VAR  error : CARDINAL;
BEGIN
   DOSCALL(setpos,file.handle,0,high,low,high,low,error);
   SetBufPos(high,low);
END SetPos;

PROCEDURE GetChar(VAR ch: CHAR; VAR isEof: BOOLEAN);
   PROCEDURE NextChar;
   VAR  dummy : CARDINAL;
   BEGIN
     WITH file DO           
       IF NOT eof THEN  INC(curInd);  END;
       IF NOT eof AND (curInd>lastInd) THEN
          AddCard(highPos,lowPos,highPos,lowPos,lastInd);
          DOSCALL(read,handle,maxBuf,ADR(buffer),lastInd,dummy);
          eof := lastInd=0;
          curInd := 1;
       END;
       IF NOT eof THEN  ch := buffer[curInd];  END;
       eof   := eof OR (ch=CtrlZ);
       isEof := eof;
     END;
   END NextChar;
BEGIN
  NextChar;
  IF NOT isEof AND (ch=cr) THEN  NextChar;  ch := EOL  END;
END GetChar;

PROCEDURE Close;
VAR
  error : CARDINAL;
BEGIN
  DOSCALL(close,file.handle,error);
END Close;


PROCEDURE Open (VAR name        : ARRAY OF CHAR;
                VAR done        : BOOLEAN);
VAR
  error   : CARDINAL;
BEGIN
  DOSCALL(open,ADR(name),2,file.handle,error);
  done := (error = 0);
  SetBufPos(0,0);
END Open;

END File;


(**********************************************************************)

MODULE MapFile;

IMPORT Open, Close, SetPos, GetPos, GetChar, overlayList, WriteLn, WriteString;
FROM SYSTEM  IMPORT  ADDRESS;
FROM ASCII   IMPORT  EOL;
FROM Strings IMPORT  Concat, Assign, Pos, Delete, Length, CompareStr;
FROM RTSMain IMPORT  ProcedureKind, OverlayPtr;

EXPORT InitOverlayList, SearchMapInfo;


TYPE
  MapLineRecord = RECORD
                    address : ADDRESS;
                    text    : ARRAY [0..80] OF CHAR;
                  END;
 
  MapKind = (BeginData, 
             EndData,
             BeginCodeModule,  
             EndCodeModule,
             ProcRemoved,
             ProcCallLong,
             ProcCallShort,     
             ProcCallNested,   
             LocalModule,
             InitModule,  
             Unknow);



PROCEDURE InitOverlayList;
VAR curOverlay: OverlayPtr;
    i: CARDINAL;
BEGIN
   curOverlay := overlayList;
   LOOP
     WITH curOverlay^ DO
       i := 0;
       WHILE  (i<8) AND (overlayName[i] <> 0C)  DO  INC(i);  END;
       overlayName[i]   := '.';
       overlayName[i+1] := 'M';
       overlayName[i+2] := 'A';
       overlayName[i+3] := 'P';
       overlayName[i+4] := 0C;
       dummy[5]  := NIL;
       dummy[6]  := NIL;
     END;
     curOverlay := curOverlay^.prev;
     IF curOverlay=overlayList THEN  EXIT  END;
   END;
END InitOverlayList;

PROCEDURE SearchOverlay(instrCounter: ADDRESS; 
                       VAR overlay: OverlayPtr; VAR succ: BOOLEAN);
VAR help: CARDINAL;
    stopped: BOOLEAN;
BEGIN
   overlay := overlayList;
   succ   := TRUE;
(*   LOOP
     WITH overlay^ DO
       help := memoryAddr.SEGMENT+memorySize;
     END;
     IF (instrCounter>overlay^.memoryAddr) 
           AND (instrCounter.SEGMENT<=help) THEN
          succ:= TRUE;  EXIT
     END;
     overlay := overlay^.prev;
     IF overlay=overlayList THEN  succ:= FALSE; EXIT  END;
   END; *)
END SearchOverlay;


PROCEDURE ReadMapLine (VAR eof  : BOOLEAN;
                       VAR line : ARRAY OF CHAR);
VAR
  i  : CARDINAL;
  ch : CHAR;
BEGIN
  i:=0;
  LOOP
    GetChar (ch,eof);   (* Read all the line ! *)
    IF eof OR (ch = EOL) THEN 
      IF i <= HIGH (line) THEN line [i] := 0C END;  (* teminator if possible *)
      EXIT;
    END;
    IF i <= HIGH (line) THEN  (* Get only n chars *)
      line [i] := ch;
      INC (i);
    END;
  END;
END ReadMapLine;


PROCEDURE FoundMapBlocks ( VAR valuePos, linePos: ADDRESS);
VAR
    line       : ARRAY [0..80] OF CHAR;
    eofMapFile : BOOLEAN;
    lastPos    : ADDRESS;
BEGIN
  LOOP
    ReadMapLine (eofMapFile, line);
    IF eofMapFile THEN  RETURN  END;
    IF Pos('  Address         Publics by Value',line)<HIGH(line) THEN
      GetPos(valuePos.SEGMENT,valuePos.OFFSET);
      EXIT;
    END;
  END;
  LOOP
    GetPos(lastPos.SEGMENT,lastPos.OFFSET);
    ReadMapLine (eofMapFile, line);
    IF eofMapFile THEN  RETURN  END;
    IF Pos('Line numbers for',line)<HIGH(line) THEN
      linePos := lastPos;
      EXIT;
    END;
  END;
END FoundMapBlocks;

PROCEDURE OpenMap(overlay: OverlayPtr; VAR succ: BOOLEAN);
BEGIN
   WITH overlay^ DO
     IF CompareStr(openName,overlayName)<>0 THEN
        openName := '';
        Open(overlayName,succ);
        IF NOT succ THEN  RETURN  END;
        IF dummy[6]=NIL THEN
          FoundMapBlocks (dummy[6],dummy[5]);
          IF dummy[6]=NIL THEN  Close;  succ:= FALSE; RETURN  END;
        END;
        Assign(overlayName,openName);
     END;
     SetPos(dummy[6].SEGMENT,dummy[6].OFFSET);
     succ := TRUE
   END;
END OpenMap;

  PROCEDURE NumDigit (c : CHAR) : BOOLEAN;
  BEGIN
    RETURN (c >= "0") AND (c <= "9") 
  END NumDigit;

  PROCEDURE AlphabDigit (c : CHAR) : BOOLEAN;
  BEGIN
    RETURN ((c >= "A") AND (c <= "F")) 
  END AlphabDigit;

  PROCEDURE ReadCard (VAR line: ARRAY OF CHAR; VAR c:CARDINAL;
                      VAR done: BOOLEAN);
  VAR i:CARDINAL;
  BEGIN
    done := FALSE;
    i    := 0;
    WHILE (line[i]=' ') DO  INC(i);  END; 
    IF line[i]=0C THEN  RETURN  END;
    c := 0;
    LOOP
      IF NumDigit (line [i]) THEN
        c := c * 10 + ORD (line [i]) - ORD ("0");
      ELSE  EXIT
      END;
      INC (i);
    END;
    IF i=0 THEN  RETURN  END;
    Delete(line,0,i);
    done := TRUE;
  END ReadCard;

  PROCEDURE ReadAddress (VAR line: ARRAY OF CHAR; VAR addr : ADDRESS;
                         VAR done: BOOLEAN);
    PROCEDURE ReadHex(VAR val: CARDINAL);
    BEGIN
      val := 0;
      LOOP
        IF NumDigit (line [i]) THEN
          val := val * 16 + ORD (line [i]) - ORD ("0");
        ELSIF AlphabDigit(line[i]) THEN
          val := val * 16 + 10 + ORD (line [i]) - ORD ("A");
        ELSE  EXIT
        END;
        INC (i);
      END;
    END ReadHex;
  VAR i:CARDINAL;
  BEGIN
    done := FALSE;
    i    := 0;
    WHILE (line[i]=' ') DO  INC(i);  END; 
    IF line[i]=0C THEN  RETURN  END;
    ReadHex(addr.SEGMENT);
    IF line[i]<>':' THEN  RETURN  END;
    INC (i);
    ReadHex (addr.OFFSET);
    Delete(line,0,i);
    done := TRUE;
  END ReadAddress;


PROCEDURE GetRecordMapLine ( VAR rec     : MapLineRecord; 
                             VAR eof, ok : BOOLEAN );
  (* Get record line of map file : 
     Format  =>  Address   Text 
     Address = SSSS:OOOO
  *)
VAR
  line : ARRAY [0..80] OF CHAR;
BEGIN (*GetRecordMapLine*)
  LOOP    (* Skip blank line *)
    ReadMapLine (eof, line);
    IF eof THEN RETURN END;
    IF Length (line) > 9 THEN EXIT END;
  END;
  WITH rec DO
    ReadAddress (line, address,ok);
    Delete(line,0,7);
    Assign(line,text);
  END;   
END GetRecordMapLine;

PROCEDURE SearchNames(    instrCounter: ADDRESS; 
                      VAR moduleName, procName: ARRAY OF CHAR;
                      VAR procKind : ProcedureKind;
                      VAR succ     : BOOLEAN);
  PROCEDURE whichInfo (text : ARRAY OF CHAR) : MapKind;
  VAR
    kind : MapKind;
  BEGIN
    CASE text [0] OF
      "$" : CASE text [1] OF
              "B" : CASE text [2] OF
                      "D" : kind := BeginData;
                    | "M" : kind := BeginCodeModule;
                    | "O" : RETURN( LocalModule );
                    ELSE    kind := Unknow;
                    END;
            | "E" : CASE text [2] OF
                      "D" : kind := EndData;
                    | "M" : kind := EndCodeModule;
                    ELSE    kind := Unknow;
                    END;
            | "I" : RETURN InitModule;
            ELSE kind := Unknow;
            END;
            IF text [3] <> "_" THEN kind := Unknow END;
            RETURN (kind);
    | "R" : kind := ProcRemoved;
    | "L" : kind := ProcCallLong;
    | "S" : kind := ProcCallShort;
    | "N" : kind := ProcCallNested;
    ELSE kind := Unknow;
    END;
    IF (text [1] <> "_" )AND(text [2] <> "_" ) THEN kind := Unknow END;
    RETURN (kind);
  END whichInfo;

VAR  done, eof : BOOLEAN;
     lastRecord, record : MapLineRecord;
     lastKind, kind     : MapKind;
    
BEGIN
   succ := FALSE;
   LOOP
     GetRecordMapLine (record, eof, done);
     IF eof OR NOT done THEN  RETURN  END;  
     kind := whichInfo (record.text);
     IF (kind=BeginCodeModule) AND 
                         (instrCounter.SEGMENT=record.address.SEGMENT) THEN
       Delete(record.text, 0, Pos ( '__', record.text )+2 );
       Assign(record.text,moduleName);
       LOOP
         GetRecordMapLine (record, eof, done);
         kind := whichInfo (record.text);
         CASE kind OF
            EndCodeModule  :  Concat('initialisation',procName,procName);  
                              EXIT
         |  ProcCallLong,
            ProcCallShort,     
            ProcCallNested,
            LocalModule,
            InitModule     : IF record.address.OFFSET>instrCounter.OFFSET THEN
                               Delete(lastRecord.text,0,
                                               Pos ( '__', lastRecord.text )+2 );
                               lastRecord.text[Pos('__', lastRecord.text)] := 0C;
                               Assign(lastRecord.text,procName);
                               EXIT;
                             ELSE
                               lastRecord := record;
                               IF kind=ProcCallNested THEN
                                  procKind := NestedProcedure;
                               ELSIF (kind=ProcCallShort) OR (kind=LocalModule) THEN
                                  procKind := NearProcedure;
                               ELSE
                                  procKind := FarProcedure;
                               END;
                             END;

         ELSE 
         END(*case*);
       END(*loop*);
       succ := TRUE;
       EXIT
     END(*if*);
   END(*loop*);
END SearchNames;


PROCEDURE SearchLine(overlay: OverlayPtr; instrCounter: ADDRESS; 
                     VAR modName: ARRAY OF CHAR;
                     VAR lineNum: CARDINAL);
    PROCEDURE FindLineNum;
    VAR lastNb, nb: CARDINAL;
        address: ADDRESS;
        done   : BOOLEAN;
    BEGIN
      LOOP
        ReadMapLine(eof,line);
        IF eof THEN  RETURN  END;
        LOOP
          IF line[0]=0C THEN EXIT  END;
          ReadCard(line,nb,done); 
          IF NOT done THEN  RETURN  END;
          ReadAddress(line,address,done);
          IF NOT done THEN  RETURN  END;
          IF address>instrCounter THEN  lineNum:= lastNb;  RETURN  END;
          IF address=instrCounter THEN  lineNum:= nb;      RETURN  END;
          lastNb := nb;
        END;
      END;
    END FindLineNum;

VAR
  line : ARRAY [0..80] OF CHAR;
  i    : CARDINAL;
  eof  : BOOLEAN;
BEGIN
  IF overlay^.dummy[5]=NIL THEN  RETURN  END;
  i := 0;  
  WHILE (i<HIGH(modName)) AND (modName[i]<>0C) DO
    IF ('a'<=modName[i]) AND (modName[i]<='z') THEN  
       modName[i] := CAP(modName[i]);
    END;
    INC(i);
  END;
  SetPos(overlay^.dummy[5].SEGMENT,overlay^.dummy[5].OFFSET);
  LOOP
    ReadMapLine(eof,line);
    IF eof THEN  RETURN  END;
    IF Pos('Line numbers for',line)<HIGH(line) THEN
        IF Pos(modName,line)<HIGH(line) THEN  FindLineNum;  RETURN  END;
    END;
  END;
END SearchLine;


PROCEDURE SearchMapInfo (     instrCounter: ADDRESS; 
                           VAR moduleName, procName: ARRAY OF CHAR;
                           VAR procKind : ProcedureKind;
                           VAR lineNum  : CARDINAL;
                           VAR succ     : BOOLEAN);

VAR  overlay : OverlayPtr;
BEGIN
   moduleName[0] := 0C;
   procName[0]   := 0C;
   lineNum       := 0;
   SearchOverlay(instrCounter,overlay,succ);
   IF NOT succ THEN  RETURN  END;
   OpenMap(overlay,succ);
   IF NOT succ THEN  RETURN  END;
   DEC(instrCounter.SEGMENT,overlay^.codeSegment);
   SearchNames(instrCounter,moduleName,procName,procKind,succ);
   IF NOT succ THEN  RETURN  END;
   SearchLine(overlay,instrCounter,moduleName,lineNum);
END SearchMapInfo;

VAR openName : ARRAY [0..12] OF CHAR;
BEGIN
  openName := '';
END MapFile;


(**********************************************************************)


PROCEDURE WriteDump;
CONST
  ProcNameLen   = 20;
  ModuleNameLen = 12;
VAR help        : Help;
    first, succ ,
    stopped     : BOOLEAN;
    instrCounter: ADDRESS;
    procKind    : ProcedureKind;
    lineNum     : CARDINAL;
    moduleName  : ARRAY [0..ModuleNameLen-1] OF CHAR;
    procName    : ARRAY [0..ProcNameLen-1] OF CHAR;
BEGIN

    InitOverlayList;

    WriteLn(stopped);
    stopped := FALSE;
    first   := TRUE;
    LOOP
       help.address := basePointer;
       IF first THEN
         INC(help.address,8);
         basePointer.OFFSET := help.cardPtr^;
         INC(help.address,12);
         instrCounter := help.addrPtr^;
         DEC(instrCounter,1);
         first := FALSE;
       ELSE
         IF help.cardPtr^=0 THEN  EXIT  END;
         basePointer.OFFSET := help.cardPtr^;
         INC(help.address,2);
         IF  (procKind = FarProcedure)  THEN
           instrCounter := help.addrPtr^;
         ELSE
           instrCounter.OFFSET := help.cardPtr^;
         END;
       END;
       SearchMapInfo(instrCounter,moduleName,procName,procKind,lineNum,succ);
       IF succ THEN        
         WriteString('MODULE : ',0);
         WriteString(moduleName,ModuleNameLen);
         WriteString(' PROCEDURE : ',0);
         WriteString(procName,ProcNameLen);
         IF lineNum<>0 THEN
           WriteString( ' LINE : ',0);
           WriteCardinal(lineNum);
         END;
       ELSE
         WriteString('CS:IP  :   ',0);
         WriteHex(instrCounter.SEGMENT);
         WriteString(':',0);
         WriteHex(instrCounter.OFFSET);
       END;
       WriteLn(stopped);
       IF stopped THEN  EXIT  END;
     END;
     WriteLn(stopped);
     Close;
     TRANSFER(dumpProcess,mainProcess);
END WriteDump;

PROCEDURE Dump(process : PROCESS; overlay: ADDRESS);
VAR help: Help;
    st: BOOLEAN;
    prcs : Process;
BEGIN
  help.address := process;
  basePointer  := help.addrPtr^;
  overlayList := OverlayPtr(overlay);
  prcs := Process(process);
  IF prcs^.progStatus > Warning THEN
    TRANSFER(mainProcess,dumpProcess);
  END;
END Dump;

CONST sizeWorkspace = 1024;
VAR  workspace : ARRAY [1..sizeWorkspace] OF CHAR;
     mainProcess, dumpProcess: PROCESS;
BEGIN
  RTSMain.debuggerRecord.beforeTermProc := Dump;
  NEWPROCESS(WriteDump,ADR(workspace),sizeWorkspace,dumpProcess);
END DebugTrace.
