(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *) 
(*    DOS3                    		         			   *)
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
IMPLEMENTATION MODULE DOS3;
(*$O-*)
  FROM SYSTEM IMPORT
    BYTE, WORD, ADDRESS,
    GETREG, SETREG, SWI, CODE,
    AX, BX, CX, DX, SI, DI, DS, ES, SP, BP, CS;

  CONST
    DOS = 21H; (* DOS interrupt vector for function calls     *)
    JNC = 73H; (* 8086 instruction code for jump if not carry *)

  TYPE
    Register = RECORD
                 CASE BOOLEAN OF
                   TRUE:  x: WORD;
                 | FALSE: l, h: BYTE;
                 END;
               END;

  (* DOS 3.0 function 59H *)
  PROCEDURE GetExtendedError(version: WORD;              (* BX *)
                             VAR extendedError: WORD;    (* AX *)
                             VAR errorClass: BYTE;       (* BH *)
                             VAR suggestedAction: BYTE;  (* BL *)
                             VAR locus: BYTE             (* CH *)
                            );
    VAR
      a: WORD;
      b, c: Register;
  BEGIN
    SETREG(BX, version); (* MOV BX, version *)
    SETREG(AX, 5900H);   (* MOV AH, 59H     *)
    SWI(DOS);
    GETREG(AX, a);       (* MOV a,   AX     *)
    GETREG(BX, b.x);     (* MOV b.x, BX     *)
    GETREG(CX, c.x);     (* MOV c.x, CX     *)
    extendedError := a;
    errorClass := b.h;
    suggestedAction := b.l;
    locus := c.h;
  END GetExtendedError;

  (* DOS 3.0 function 5AH *)
  PROCEDURE CreateTemporaryFile(path: ADDRESS;           (* DS:DX *)
                                attribute: WORD;         (* CX    *)
                                VAR errorCode: WORD;     (* AX,CF *)
                                VAR handle: WORD;        (* AX,CF *)
                                VAR pathAndName: ADDRESS (* DS:DX *)
                               );
    VAR
      error, file: WORD;
      ds, dx: CARDINAL;
  BEGIN
    error := WORD(0);    (* initialize to no error *)
    SETREG(DS, path.SEGMENT);
    SETREG(DX, path.OFFSET);
    SETREG(CX, attribute);
    SETREG(AX, 5A00H);
    SWI(DOS);
    CODE(JNC, 3);       (*   JNC noError *)
    GETREG(AX, error);
                        (* noError:      *)
    GETREG(AX, file);
    GETREG(DS, ds);
    GETREG(DX, dx);
    errorCode := error;
    handle := file;
    pathAndName.SEGMENT := ds;
    pathAndName.OFFSET := dx;
  END CreateTemporaryFile;
                                
  (* DOS 3.0 function 5BH *)
  PROCEDURE CreateNewFile(pathAndName: ADDRESS;          (* DS:BX *)
                          attribute: WORD;               (* CX    *)
                          VAR errorCode: WORD;           (* AX,CF *)
                          VAR handle: WORD               (* AX,CF *)
                         );
    VAR
      error, file: WORD;
  BEGIN
    error := WORD(0);    (* initialize to no error *)
    SETREG(DS, pathAndName.SEGMENT);
    SETREG(DX, pathAndName.OFFSET);
    SETREG(CX, attribute);
    SETREG(AX, 5B00H);
    SWI(DOS);
    CODE(JNC, 3);       (*   JNC noError *)
    GETREG(AX, error);
                        (* noError:      *)
    GETREG(AX, file);
    errorCode := error;
    handle := file;
  END CreateNewFile;

  (* DOS 3.0 function 5CH *)
  PROCEDURE LockUnlockFileAccess(lock: BYTE;             (* AL    *)
                                 handle: WORD;           (* BX    *)
                                 offsetHigh: WORD;       (* CX    *)
                                 offsetLow: WORD;        (* DX    *)
                                 lengthHigh: WORD;       (* SI    *)
                                 lengthLow: WORD;        (* DI    *)
                                 VAR errorCode: WORD     (* AX,CF *)
                                );
    VAR
      ax: CARDINAL;
      error: WORD;
  BEGIN
    error := WORD(0); (* initialize to noerror *)
    ax := 5C00H + ORD(lock);
    SETREG(BX, handle);
    SETREG(CX, offsetHigh);
    SETREG(DX, offsetLow);
    SETREG(SI, lengthHigh);
    SETREG(DI, lengthLow);
    SETREG(AX, ax);
    SWI(DOS);
    CODE(JNC, 3);       (*   JNC noError *)
    GETREG(AX, error);
                        (* noError:      *)
    errorCode := error;
  END LockUnlockFileAccess;

  (* DOS 3.0 function 62H *)
  PROCEDURE GetProgramSegmentPrefix(VAR PSPsegment: WORD (* BX *)
                                   );
    VAR
      bx: WORD;
  BEGIN
    SETREG(AX, 6200H);
    SWI(DOS);
    GETREG(BX, bx);
    PSPsegment := bx;
  END GetProgramSegmentPrefix;

(*$O=*)
END DOS3.
