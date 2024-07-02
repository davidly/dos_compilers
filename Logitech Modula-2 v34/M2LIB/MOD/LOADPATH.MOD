(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    LoadPath, path and name of the running .EXE       		   *)
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


IMPLEMENTATION MODULE LoadPath;


(*
 The procedures "GetLoad"/"GetLoadDir" return the filename/path found
 at the end of the DOS environment strings passed to the program. This
 DOS feature is only available for DOS versions 3.1 and later.

 Note that the path found there (and returned) depends on how the
 program has been started:

   - If the program has been started from the DOS command interpreter,
     then it seems always to contain the full directory specification.

   - If the program has been started from an other program by means of
     the DOS EXEC function (function code 4BH), then the filename found
     seems to be exactly as specified to EXEC, i.e. it does not necessarily
     contain a drive and/or directory specification!
*)
FROM SYSTEM IMPORT ADDRESS, DOSCALL;
FROM RTSMain IMPORT PSPAddress;

CONST VERSION = 30H;

PROCEDURE CheckVersion():BOOLEAN;
 VAR major, minor : CHAR;
BEGIN
 DOSCALL (VERSION, major, minor);
 RETURN ((ORD(major) = 3) & (ORD(minor) > 0)) OR (ORD(major) >= 4);
END CheckVersion;

PROCEDURE GetLoad(VAR str: ARRAY OF CHAR);
  (* Get the complete filename of the file loaded by MSDOS
          In the environnement:
          - Look for the sequence 0,0
          - Skip two bytes ( meaning unknown, often 1,0 )
          - Take next characters until a 0 
          Return empty string if:
          - DOS Version <= 3.0
          - Doesn't find 0,0
          - filename > HIGH(str)
  *)

  CONST maxEnv=MAX(CARDINAL)-4; (* maximum length of environnement *)
                                (* stop research after that *)
  VAR ptr : POINTER TO ARRAY [0..maxEnv] OF CHAR;
    addr1 : ADDRESS;
    i, j : CARDINAL;
BEGIN
  str[0] := 0C;
  IF NOT CheckVersion() THEN
    RETURN;
  END;
  addr1:=PSPAddress;
  INC(addr1,44);
  addr1.SEGMENT:=CARDINAL(addr1^);
  addr1.OFFSET:=0;
  ptr:=addr1;
  i:=0;
  WHILE ((ptr^[i]<>0c) OR (ptr^[i+1]<>0c)) AND (i<maxEnv) DO INC(i) END;
  IF (i<maxEnv) THEN 
    INC(i,4);
    j:=0;
    WHILE (j<=HIGH(str)) AND (ptr^[i]<>0c) DO
      str[j]:=ptr^[i];
      INC(j);
      INC(i);
    END;
    IF ptr^[i]=0c THEN
      IF j<=HIGH(str) THEN str[j]:=0c END;
    ELSE
      str[0]:=0c;
    END;
  END;
END GetLoad;





PROCEDURE GetLoadDir(VAR str: ARRAY OF CHAR);
  (* Return the directory of the loaded file or empty string
       if problems
  *)
VAR i,last: CARDINAL;
BEGIN
  GetLoad(str);
  i:=0;
  last := HIGH(str)+1;
  WHILE (i<=HIGH(str)) AND (str[i]<>0c) DO
(* 09-Nov-89/akg *)
    IF (str[i] = "\") OR (str[i] =":") THEN last := i END;
    INC(i);
  END;
  IF last > HIGH(str) THEN
    str[0]:=0c;
  ELSE
    str[last+1]:=0c;
  END;
END GetLoadDir;

END LoadPath.
