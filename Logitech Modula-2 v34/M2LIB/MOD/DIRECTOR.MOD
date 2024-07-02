(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Directories                                     	    		   *)
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


IMPLEMENTATION MODULE Directories;


FROM SYSTEM IMPORT DOSCALL,ADR;



CONST  (* The elements of the DTArea *)
  DTASize     = 43;
  PathSize    = 63;
  DriveSize   =  2; (* Drive letter + ":" *)
  FileSize    = 13; (* filename + "." + extension + 0C *)
  FileField   = 30; (* position in DTArea of beginning of filename *)
       (* DOS function numbers *)
  SetDTAddr   = 1AH;
  FindFirst   = 4EH; 
  FindNext    = 4FH;      
  DELETE      = 41H;
  RENAME      = 56H;


TYPE
  DTAType      = ARRAY [0..DTASize-1] OF CHAR;
  FileSpecType = ARRAY [0..DriveSize+PathSize+FileSize] OF CHAR;

   (* one char longer than needed to introduce 0C for DOSCALLs *)


PROCEDURE DirQuery(    WildFileName : ARRAY OF CHAR;
                       DirProc      : DirQueryProc;
                   VAR res          : DirResult);
VAR
  DTArea        : DTAType;
  FileSpec      : FileSpecType;
  LastBackSlash : CARDINAL;
  i,j           : CARDINAL;
  result        : CARDINAL;
  foundOne      : BOOLEAN;
  GoOn          : BOOLEAN;   


BEGIN
  LastBackSlash:=255;
  i:=0;
  WHILE (i< HIGH(WildFileName)) AND (WildFileName[i]#0C) DO
    IF (WildFileName[i]="\") OR (WildFileName[i]=":") THEN LastBackSlash:=i END;
    INC(i)
  END;
  IF LastBackSlash#255 THEN
    FOR i:=0 TO LastBackSlash DO FileSpec[i]:=WildFileName[i] END;
    INC(LastBackSlash)
  ELSE
    LastBackSlash:=0;
  END;
  foundOne := FALSE;


  DOSCALL(SetDTAddr,ADR(DTArea));
  DOSCALL(FindFirst,ADR(WildFileName),0,result);
  GoOn := TRUE;
  WHILE (result#18) AND (result#2) AND (result#3) (* see DOS 2.0/3.x Manual ! *)
        AND GoOn DO
    foundOne := TRUE;
    i:=LastBackSlash; j:= FileField;
    WHILE DTArea[j]#0C DO
      FileSpec[i] := DTArea[j]; 
      INC(i); INC(j)
    END;

    FileSpec[i]:=0C;
    DirProc(FileSpec,GoOn);
    IF GoOn THEN (* DOSCALL only after TRUE return from DirProc *)


      DOSCALL(FindNext,result);

    END;
  END; 
  IF foundOne  THEN res := OK ELSE res := NoFile END;
END DirQuery;

PROCEDURE CopyName(VAR from,to : ARRAY OF CHAR);
(*
  "to" has to be one char longer than "from", i.e., there has to be 
  enough space in "to" to insert the 0C, required by the DOSCALLs.
*) 
VAR
  i : CARDINAL;
BEGIN
  i := 0;
  WHILE (i<=HIGH(from)) AND (from[i]<>0C) DO
    to[i] := from[i]; INC(i);
  END;
  to[i] := 0C; 
END CopyName;

PROCEDURE Rename(    FromName : ARRAY OF CHAR;
                     ToName   : ARRAY OF CHAR;
                 VAR res      : DirResult);
VAR
 result  : CARDINAL;
 From,To : FileSpecType;
BEGIN
 CopyName(FromName,From);
 CopyName(ToName,To);


 DOSCALL(RENAME,ADR(From),ADR(To),result);

 IF    (result=0)                THEN res := OK
 ELSIF (result=5) OR (result=17) THEN res := ExistingFile
 ELSIF (result=2) OR (result=3)  THEN res := NoFile
 ELSE                                 res := OtherError    END;
END Rename;

PROCEDURE Delete(    FileName : ARRAY OF CHAR;
                 VAR res      : DirResult);
VAR
 result : CARDINAL;
 File   : FileSpecType;
BEGIN
 CopyName(FileName,File);


 DOSCALL(DELETE,ADR(File),result);

 IF    result=0                 THEN  res := OK
 ELSIF (result=2) OR (result=3) THEN  res := NoFile
 ELSE                                 res := OtherError END;
END Delete;

END Directories.
