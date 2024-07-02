(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Prints a message to the screen with				   *)
(*    an explanation of a file's status.				   *)
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
(*$T- *)
(*$R- *)

IMPLEMENTATION MODULE FileMessage;

  FROM FileSystem IMPORT Response;
  FROM Terminal IMPORT Write, WriteString;
  FROM CardinalIO IMPORT WriteHex;

(*
    Response = (done, notdone, notsupported, callerror, unknownmedium,
                unknownfile, paramerror, toomanyfiles, eom,
                userdeverror);
*)


  PROCEDURE WriteResponse (r: Response);
  BEGIN
    Write (' ');
    CASE r OF
        done:          WriteString ('done');
      | notdone:       WriteString ('not done');
      | notsupported:  WriteString ('not supported');
      | callerror:     WriteString ('calling error');
      | unknownmedium: WriteString ('unknown medium');
      | unknownfile:   WriteString ('unknown File');
      | paramerror:    WriteString ('parameter error');
      | toomanyfiles:  WriteString ('too many files');
      | eom:           WriteString ('end of medium');
      | userdeverror:  WriteString ('error on private device');
      ELSE
        WriteString ('FileSystem.Response: ');
        WriteHex (ORD(r), 4);
    END;
  END WriteResponse;


END FileMessage.
