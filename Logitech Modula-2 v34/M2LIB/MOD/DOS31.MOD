(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *) 
(*    DOS31         				              		   *)
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
IMPLEMENTATION MODULE DOS31;
(*

   Additional DOS 3.1 functions

*)

  FROM SYSTEM IMPORT
    BYTE, WORD, ADDRESS,
    GETREG, SETREG, SWI, CODE,
    AX, BX, CX, DX, SI, DI, SP, BP, DS, ES, CS;

  CONST
    DOS    = 21H; (* DOS interrupt vector for function calls     *)
    JNC    = 73H; (* 8086 instruction code for jump if not carry *)
    PushBP = 55H; (* 8086 instruction code for push BP register  *)
    PopBP  = 5DH; (* 8086 instruction code for pop BP register   *)

  TYPE
    Register = RECORD
                 CASE BOOLEAN OF
                   TRUE:  x: WORD;
                 | FALSE: l, h: BYTE;
                 END;
               END;

    (* DOS 3.1 function 5E00H *)
    PROCEDURE GetMachineName(computerName: ADDRESS;             (* DS:DX *)
                             VAR nameNumberIndicatorFlag: BYTE; (* CH    *)
                             VAR nameNumber: BYTE;              (* CL    *)
                             VAR errorCode: WORD);              (* AX,CF *)
      VAR
        error: WORD;
        c: Register;
    BEGIN
      error := WORD(0);                 (*   initialize to no error *)
      SETREG(DX, computerName.OFFSET);
      SETREG(DS, computerName.SEGMENT);
      SETREG(AX, 5E00H);
      SWI(DOS);
      CODE(JNC, 3);                     (*   JNC noError *)
      GETREG(AX, error);
                                        (* noError:      *)
      GETREG(CX, c.x);
      nameNumberIndicatorFlag := c.h;
      nameNumber := c.l;
      errorCode := error;
    END GetMachineName;

    (* DOS 3.1 function 5E02H *)
    PROCEDURE SetPrinterSetup(redirectionListIndex: WORD; (* BX    *)
                              setupStringLength: WORD;    (* CX    *)
                              setupBuffer: ADDRESS;       (* DS:SI *)
                              VAR errorCode: WORD);       (* AX,CF *)
      VAR
        error: WORD;
    BEGIN
      error := WORD(0);                 (*   initialize to no error *)
      SETREG(CX, setupStringLength);
      SETREG(BX, redirectionListIndex);
      SETREG(SI, setupBuffer.OFFSET);
      SETREG(DS, setupBuffer.SEGMENT);
      SETREG(AX, 5E02H);
      SWI(DOS);
      CODE(JNC, 3);                     (*   JNC noError *)
      GETREG(AX, error);
                                        (* noError:      *)
      errorCode := error;
    END SetPrinterSetup;

    (* DOS 3.1 function 5E03H *)
    PROCEDURE GetPrinterSetup(redirectionListIndex: WORD;  (* BX    *)
                              setupBuffer: ADDRESS;        (* ES:DI *)
                              VAR setupStringLength: WORD; (* CX    *)
                              VAR errorCode: WORD);        (* AX,CF *)
      VAR
        error: WORD;
        cx: WORD;
    BEGIN
      error := WORD(0);                 (*   initialize to no error *)
      SETREG(BX, redirectionListIndex);
      SETREG(DI, setupBuffer.OFFSET);
      SETREG(ES, setupBuffer.SEGMENT);
      SETREG(AX, 5E03H);
      SWI(DOS);
      CODE(JNC, 3);                     (*   JNC noError *)
      GETREG(AX, error);
                                        (* noError:      *)
      GETREG(CX, cx);
      setupStringLength := cx;
      errorCode := error;
    END GetPrinterSetup;

    (* DOS 3.1 function 5F02H *)
    PROCEDURE GetRedirectionListEntry(redirectionIndex: WORD;     (* BX    *)
                                      localDeviceName: ADDRESS;   (* DS:SI *)
                                      networkName: ADDRESS;       (* ES:DI *)
                                      VAR deviceStatusFlag: BYTE; (* BH    *)
                                      VAR deviceType: BYTE;       (* BL    *)
                                      VAR storedParmValue: WORD;  (* CX    *)
                                      VAR errorCode: WORD);       (* AX,CF *)
      VAR
        error: WORD;
        b: Register;
        cx: WORD;
    BEGIN
      error := WORD(0);                 (*   initialize to no error *)
      SETREG(BX, redirectionIndex);
      SETREG(SI, localDeviceName.OFFSET);
      SETREG(DI, networkName.OFFSET);
      SETREG(DS, localDeviceName.SEGMENT);
      SETREG(ES, networkName.SEGMENT);
      SETREG(AX, 5F02H);
      CODE(PushBP); (* save register    *)
      SWI(DOS);
      CODE(PopBP);  (* restore register *)
      CODE(JNC, 3);                     (*   JNC noError *)
      GETREG(AX, error);
                                        (* noError:      *)
      GETREG(BX, b.x);
      GETREG(CX, cx);
      deviceStatusFlag := b.h;
      deviceType := b.l;
      storedParmValue := cx;
      errorCode := error;
    END GetRedirectionListEntry;

    (* DOS 3.1 function 5F03H *)
    PROCEDURE RedirectDevice(deviceType: BYTE;           (* BL    *)
                             valueToSaveForCaller: WORD; (* CX    *)
                             deviceName: ADDRESS;        (* DS:SI *)
                             networkPath: ADDRESS;       (* ES:DI *)
                             VAR errorCode: WORD);       (* AX,CF *)
      VAR
        error: WORD;
    BEGIN
      error := WORD(0);                 (*   initialize to no error *)
      SETREG(BX, deviceType);
      SETREG(CX, valueToSaveForCaller);
      SETREG(SI, deviceName.OFFSET);
      SETREG(DI, networkPath.OFFSET);
      SETREG(DS, deviceName.SEGMENT);
      SETREG(ES, networkPath.SEGMENT);
      SETREG(AX, 5F03H);
      SWI(DOS);
      CODE(JNC, 3);                     (*   JNC noError *)
      GETREG(AX, error);
                                        (* noError:      *)
      errorCode := error;
    END RedirectDevice;

    (* DOS 3.1 function 5F04H *)
    PROCEDURE CancelRedirection(deviceName: ADDRESS;  (* DS:SI *)
                                VAR errorCode: WORD); (* AX,CF *)
      VAR
        error: WORD;
    BEGIN
      error := WORD(0);                 (*   initialize to no error *)
      SETREG(SI, deviceName.OFFSET);
      SETREG(DS, deviceName.SEGMENT);
      SETREG(AX, 5F04H);
      SWI(DOS);
      CODE(JNC, 3);                     (*   JNC noError *)
      GETREG(AX, error);
                                        (* noError:      *)
      errorCode := error;
    END CancelRedirection;


END DOS31.
