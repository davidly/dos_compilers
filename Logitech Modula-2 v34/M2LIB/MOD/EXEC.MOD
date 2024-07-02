(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Exec, provides access to the DOS shell.   	                   *)
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
(*$S-*)
(*$T-*)
(*$R-*)
(*$O-*)
IMPLEMENTATION MODULE Exec;
  FROM Storage IMPORT
    ALLOCATE, DEALLOCATE;

  FROM RTSMain IMPORT
    PSPAddress;

  FROM SYSTEM IMPORT
    DOSCALL,
    ADR, ADDRESS,
    ENABLE, DISABLE,
    CODE, SETREG, GETREG, SS, SP, BP, AX;

  CONST 
    EXEC   = 4BH;
    movSeg = 8EH;
    movReg = 8BH;
    AXtoSS = 0D0H;
    AXtoSP = 0E0H;
    AXtoBP = 0E8H;
  
  TYPE
    ParamBlock = RECORD
                   environmentSegment: CARDINAL;
                   commandLinePtr: ADDRESS;
                   fcb1Ptr, fcb2Ptr: ADDRESS;
                 END;
    ParamBlockPtr = POINTER TO ParamBlock;
 
  VAR
    paramBlockPtr: ParamBlockPtr;
    programNameAdr: ADDRESS;
    saveSS, saveSP, saveBP: CARDINAL;
    error : CARDINAL; (* this variable must be global ! *)
    
  PROCEDURE Execute(programName: ADDRESS;
                    environment: CARDINAL;
                    commandLineAdr: ADDRESS;
                    FCB1Adr, FCB2Adr: ADDRESS;
                    VAR errorReturn: CARDINAL);

  BEGIN
    NEW(paramBlockPtr);
    WITH paramBlockPtr^ DO
      environmentSegment := environment;
      commandLinePtr := commandLineAdr;
      fcb1Ptr := FCB1Adr;
      fcb2Ptr := FCB2Adr;
    END;
    programNameAdr := programName;

    GETREG(SS, saveSS);
    GETREG(SP, saveSP);
    GETREG(BP, saveBP);
    DOSCALL (EXEC, programNameAdr, paramBlockPtr, 0, error);
    DISABLE;
    SETREG(AX, saveSS);
    CODE(movSeg, AXtoSS);
    SETREG(AX, saveSP);
    CODE(movReg, AXtoSP);
    SETREG(AX, saveBP);
    CODE(movReg, AXtoBP);
    ENABLE;

    DISPOSE(paramBlockPtr);
    errorReturn := error;
  END Execute;

  VAR
    commandLine: ARRAY [0..127] OF CHAR;
    fcb1, fcb2: ARRAY [0..31] OF CHAR;
    prg, shell: ARRAY [0..127] OF CHAR;
    comspec: RECORD
                CASE BOOLEAN OF
                  FALSE: a: ADDRESS;
                | TRUE : charPtr: POINTER TO CHAR;
                END;
              END;

  PROCEDURE DosShell(VAR done: BOOLEAN);
    VAR err: CARDINAL;
  BEGIN
    commandLine[0] := CHR(0);
    Execute(ADR(shell), 0, ADR(commandLine), ADR(fcb1), ADR(fcb2), err);
    done := err = 0;
  END DosShell;

  PROCEDURE DosCommand(command, parameters: ARRAY OF CHAR; VAR done: BOOLEAN);
    VAR err, charCount, j: CARDINAL;
  BEGIN
    commandLine := "  /C ";
    charCount := 5;
    j := 0;
    WHILE (j <= HIGH(command)) AND (command[j] <> 0C) AND
          (charCount <= HIGH(commandLine))
    DO
      commandLine[charCount] := command[j];
      INC(j);
      INC(charCount);
    END;
    IF charCount <= HIGH(commandLine) THEN
      commandLine[charCount] := ' ';
      INC(charCount);
    END;
    j := 0;
    WHILE (j <= HIGH(parameters)) AND (parameters[j] <> 0C) AND
          (charCount <= HIGH(commandLine))
    DO
      commandLine[charCount] := parameters[j];
      INC(j);
      INC(charCount);
    END;
    IF charCount <= HIGH(commandLine) THEN
      commandLine[charCount] := 15C; (* some applications require a CR *)
      INC(charCount);
    END;
    commandLine[0] := CHR(charCount-1);
  
    Execute(ADR(shell), 0, ADR(commandLine), ADR(fcb1), ADR(fcb2), err);
    done := err = 0;
  END DosCommand;

  PROCEDURE Run(program, parameters: ARRAY OF CHAR; VAR done: BOOLEAN);
    VAR err, charCount, j: CARDINAL;
  BEGIN
    j := 0;
    WHILE (j <= HIGH(program)) AND (program[j] <> 0C) AND (j <= HIGH(prg)) DO
      prg[j] := program[j];
      INC(j);
    END;
    IF j <= HIGH(prg) THEN
      prg[j] := 0C;
    END;

    IF parameters[0] = 0C THEN (* no paramters *)
      FOR j := 0 TO HIGH(commandLine) DO
        commandLine[j] := ' ';
      END;
      commandLine[0] := CHR(0);
    ELSE
      commandLine := "  "; (* counter and leading space *)
      charCount := 2;
      j := 0;
      WHILE (j <= HIGH(parameters)) AND (parameters[j] <> 0C) AND
            (charCount <= HIGH(commandLine))
      DO
        commandLine[charCount] := parameters[j];
        INC(j);
        INC(charCount);
      END;
      IF charCount <= HIGH(commandLine) THEN
        commandLine[charCount] := 15C; (* some applications require a CR *)
        INC(charCount);
      END;
      commandLine[0] := CHR(charCount-1);
    END;

    Execute(ADR(prg), 0, ADR(commandLine), ADR(fcb1), ADR(fcb2), err);
    done := err = 0;
  END Run;

  VAR
    i: CARDINAL;
    searched: ARRAY [0..6] OF CHAR;
    found: BOOLEAN;

BEGIN
  (* initialize dummy default FCB's *)
  fcb1 := "                                ";
  fcb1[0] := 0C;
  fcb2 := fcb1;
  
  (* find COMSPEC=drive:\path\COMMAND.COM in environment variable *)
  comspec.a := PSPAddress;
  INC (comspec.a, 44);
  comspec.a.SEGMENT := CARDINAL(comspec.a^); (* para. address of Environment *)
  comspec.a.OFFSET := 0;

  searched := "COMSPEC";
  found := FALSE;

  WHILE NOT found AND (comspec.charPtr^ <> 0C) DO
    i := 0;
    WHILE (i <= HIGH(searched)) AND (CAP(comspec.charPtr^) = searched[i]) DO
      INC(i);
      INC(comspec.a);
    END;
    IF i > HIGH(searched) THEN
      found := TRUE;
      WHILE comspec.charPtr^ <> '=' DO (* skip to = *)
        INC(comspec.a);
      END;
      INC(comspec.a); (* skip = *)
      WHILE comspec.charPtr^ = ' ' DO (* skip leading spaces *)
        INC(comspec.a);
      END;
    ELSE
      WHILE comspec.charPtr^ <> 0C DO (* skip this set definition *)
        INC(comspec.a);
      END;
      INC(comspec.a);
    END;
  END;

  IF found THEN
    i := 0;
    WHILE comspec.charPtr^ <> 0C DO (* copy comspec *)
      shell[i] := comspec.charPtr^;
      INC(comspec.a);
      INC(i);
    END;
    shell[i] := 0C;
  ELSE
    shell := "COMMAND.COM";
  END;
END Exec.
