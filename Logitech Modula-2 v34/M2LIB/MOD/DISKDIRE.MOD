(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*	  Provides an interface to the directory and disk	      	   *)
(*        functions of the underlying operating system,		      	   *)
(*        which are not dealing with specific files.			   *)
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
IMPLEMENTATION MODULE DiskDirectory;		(* WS, opje *)



  FROM SYSTEM IMPORT  DOSCALL, ADR, ADDRESS;


  CONST


    PathLength = 80;
    LastDrive = 'P';

                        
  TYPE
    FileName = ARRAY [0..PathLength] OF CHAR;
      (* longest possible pathname *)

  CONST


    (* the MSDOS function-calls: *)
    ResetSystem = 13;
    SelDisk = 14;
    GetCurrDisk = 25;
(*    ResetDr = 37; *)


PROCEDURE CurrentDrive (VAR drive: CHAR);

BEGIN


  DOSCALL (GetCurrDisk, drive);
  INC (drive,ORD('A'));

END CurrentDrive;


PROCEDURE SelectDrive (drive: CHAR; VAR done: BOOLEAN);
  VAR 
      cch             : CHAR;


      result: BOOLEAN;

BEGIN
  cch := CAP(drive);
  done := FALSE;
  IF ('A'<=cch) AND (cch<=LastDrive) THEN


    DOSCALL (SelDisk, ORD(cch)-ORD('A'), result);
    done := TRUE;

  END;
END SelectDrive;


PROCEDURE CurrentDirectory (drive: CHAR; VAR dir: ARRAY OF CHAR);
VAR result : CARDINAL;


    dirAdr:ADDRESS; 
    
BEGIN

  dirAdr:=ADR(dir);

  drive := CAP(drive);
  IF (drive = ' ') OR (drive = 0C) THEN
    drive := 0C;
  ELSIF (drive >= 'A') AND (drive <= LastDrive) THEN


    drive := CHR(ORD(drive)-ORD('A')+1);

  ELSE
    dir[0] := 0C;
    RETURN;
  END;


  DOSCALL(47H,drive,dirAdr,result);

  IF result=15 THEN
    dir[0] := 0C;
  END;
END CurrentDirectory;


PROCEDURE ChangeDirectory (dir: ARRAY OF CHAR; VAR done: BOOLEAN);
  VAR
    result:CARDINAL;

    dirAdr : ADDRESS;

    dircopy: FileName;
    i: CARDINAL;
BEGIN
  i := 0;
  WHILE (i <= HIGH(dir)) AND (i <= HIGH(dircopy)) AND (dir[i] <> 0C) DO
    dircopy[i] := dir[i];
    INC(i);
  END;
  IF i <= HIGH(dircopy) THEN dircopy[i] := 0C END;


  dirAdr:=ADR(dircopy);
  DOSCALL(3BH,dirAdr,result);

  IF result=0 THEN
    done:=TRUE
  ELSE
    done := FALSE;
  END;
END ChangeDirectory;


PROCEDURE MakeDir (dir: ARRAY OF CHAR; VAR done: BOOLEAN);
VAR result:CARDINAL;
    dircopy: FileName;

    dirAdr : ADDRESS;

    i: CARDINAL;
BEGIN
  i := 0;
  WHILE (i <= HIGH(dir)) AND (i <= HIGH(dircopy)) AND (dir[i] <> 0C) DO
    dircopy[i] := dir[i];
    INC(i);
  END;
  IF i <= HIGH(dircopy) THEN dircopy[i] := 0C END;


  dirAdr:=ADR(dircopy);
  DOSCALL(39H,dirAdr,result);

  IF result=0 THEN
    done:=TRUE
  ELSE
    done := FALSE;
  END;
END MakeDir;


PROCEDURE RemoveDir (dir: ARRAY OF CHAR; VAR done: BOOLEAN);
VAR result:CARDINAL;
    dircopy: FileName;

    dirAdr:ADDRESS; 

    i: CARDINAL;
BEGIN
  i := 0;
  WHILE (i <= HIGH(dir)) AND (i <= HIGH(dircopy)) AND (dir[i] <> 0C) DO
    dircopy[i] := dir[i];
    INC(i);
  END;
  IF i <= HIGH(dircopy) THEN dircopy[i] := 0C END;


  dirAdr:=ADR(dircopy);
  DOSCALL(3AH,dirAdr,result);

  IF result=0 THEN
    done:=TRUE
  ELSE
    done := FALSE;
  END;
END RemoveDir;



PROCEDURE ResetDiskSys;

BEGIN


  DOSCALL (ResetSystem);

END ResetDiskSys;


PROCEDURE ResetDrive (d: CHAR): CARDINAL;
  VAR drives: BITSET; i: CARDINAL;
BEGIN
(*
  IF (d > 'P') OR (d < 'A') THEN RETURN (255); END;
  i := ORD (d) - ORD ('A');
  drives := {};
  INCL (drives, i);
  CPMCALL (ResetDr, drives, i);
  RETURN (i);
*)
  RETURN (255);
END ResetDrive;


END DiskDirectory.
