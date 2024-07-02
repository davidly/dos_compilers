(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    handle return code to operating system.                              *)
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
IMPLEMENTATION MODULE ErrorCode ;
  FROM SYSTEM   IMPORT BYTE     ;


  FROM RTSMain IMPORT errorCode, Terminate, Status;


  PROCEDURE SetErrorCode(value: CARDINAL);
    (* this doesn't terminate the program immediatly, but *)
    (* sets the error return code that will be used on    *)
    (* normal termination                                 *)
  BEGIN
    errorCode := value;
  END SetErrorCode;

  PROCEDURE GetErrorCode(VAR value: CARDINAL);
    (* this procedure allows to inspect the set return code *)
  BEGIN


    value := ORD(errorCode);

  END GetErrorCode;

  PROCEDURE ExitToOS;
    (* terminate current program and return to operating system *)
    (* set the error code corresponding to value defined by a   *)
    (* previous call to SetErrorCode                            *)
  BEGIN
    Terminate(Normal);
      (* this implementation returns only to the OS, if the *)
      (* current program is not an overlay                  *)
  END ExitToOS;

END ErrorCode.
