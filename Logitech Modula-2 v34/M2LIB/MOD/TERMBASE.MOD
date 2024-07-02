(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Base of the terminal I/O subsystem, with              	  	   *)
(*    redirection hooks.                                    	  	   *)
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
IMPLEMENTATION MODULE Termbase;         (* SEK, WS *)

  IMPORT RTSMain, Keyboard, Display;



  CONST
    levels = 6;

  VAR
    readStack: ARRAY [0..levels-1] OF
                 RECORD rp: ReadProcedure;
                        sp: StatusProcedure;
                        progId: CARDINAL
                 END;
    readTop, rt : CARDINAL;

    writeStack: ARRAY [0..levels-1] OF
                 RECORD wp: WriteProcedure; progId: CARDINAL END;
    writeTop, wt : CARDINAL;

    dummy: BOOLEAN;


  PROCEDURE AssignRead (rp: ReadProcedure; sp: StatusProcedure;
                        VAR done: BOOLEAN);
    VAR curProg: CARDINAL;
  BEGIN
    done := FALSE;

    curProg := RTSMain.curProcess^^.programLevel;


    IF readTop = rt THEN
      IF readTop < levels THEN
        readStack[readTop].rp := rp;
        readStack[readTop].sp := sp;
        readStack[readTop].progId := curProg;
        INC (readTop);
        rt := readTop;
        done := TRUE;
      END;
    END;
  END AssignRead;


  PROCEDURE Read (VAR ch: CHAR);
    VAR decremented: BOOLEAN;
  BEGIN
    IF rt > 0 THEN
      DEC (rt); (* allow for recursion, except at lowest level *)
      decremented := TRUE;
    ELSE
      decremented := FALSE;
    END;
    readStack[rt].rp (ch); (* this ReadProcedure may itself call Read *)
    IF decremented THEN
      INC (rt);
    END;
  END Read;


  PROCEDURE KeyPressed (): BOOLEAN;
    VAR decremented, b : BOOLEAN;
  BEGIN
    IF rt > 0 THEN
      DEC (rt); (* allow for recursion, except at lowest level *)
      decremented := TRUE;
    ELSE
      decremented := FALSE;
    END;
    b := readStack[rt].sp ();
      (* this StatusProcedure may itself call KeyPressed *)
    IF decremented THEN
      INC (rt);
    END;
    RETURN (b);
  END KeyPressed;


  PROCEDURE UnAssignRead (VAR done: BOOLEAN);
    VAR curProg: CARDINAL;
  BEGIN
    done := FALSE;

    curProg := RTSMain.curProcess^^.programLevel;


    IF (readTop > 0) AND (readStack[readTop-1].progId = curProg) THEN
      (* it's not the one at the lowest level and it belongs
         to the current program:
      *)
      DEC (readTop);
      rt := readTop;
      done := TRUE;
    END;
  END UnAssignRead;



  PROCEDURE AssignWrite (wp: WriteProcedure; VAR done: BOOLEAN);
  BEGIN
    done := FALSE;
    IF writeTop = wt THEN
      IF writeTop < levels THEN
        writeStack[writeTop].wp := wp;

        writeStack[writeTop].progId := RTSMain.curProcess^^.programLevel;


        INC (writeTop);
        wt := writeTop;
        done := TRUE;
      END;
    END;
  END AssignWrite;


  PROCEDURE Write (ch: CHAR);
    VAR decremented : BOOLEAN;
  BEGIN
    IF wt > 0 THEN
      DEC (wt); (* allow for recursion, except at lowest level *)
      decremented := TRUE;
    ELSE
      decremented := FALSE;
    END;
    writeStack[wt].wp (ch); (* this WriteProcedure may itself call Write *)
    IF decremented THEN
      INC (wt);
    END;
  END Write;


  PROCEDURE UnAssignWrite (VAR done: BOOLEAN);
    VAR curProg: CARDINAL;
  BEGIN
    done := FALSE;

    curProg := RTSMain.curProcess^^.programLevel;


    IF (writeTop > 0) AND (writeStack[writeTop-1].progId = curProg) THEN
      (* it's not the one at the lowest level and it belongs
         to the current program:
      *)
      DEC (writeTop);
      wt := writeTop;
      done := TRUE;
    END;
  END UnAssignWrite;



  CONST
    maxOverlay = 10;

  TYPE
    OverlayIndex = [0..maxOverlay-1];

  VAR
    overlay: OverlayIndex;
    save: ARRAY OverlayIndex OF RECORD
                                  rt: CARDINAL;
                                  wt: CARDINAL;
                                END;

  PROCEDURE Save;
  BEGIN
    IF overlay <= HIGH(save) THEN
      save[overlay].rt := rt;
      save[overlay].wt := wt;
    END;
    INC(overlay);

    RTSMain.InstallTermProc (Reset);


  END Save;

  PROCEDURE Reset;
    VAR more: BOOLEAN;
  BEGIN
    more := TRUE;
    WHILE more DO UnAssignRead (more); END;
    more := TRUE;
    WHILE more DO UnAssignWrite (more); END;

    IF overlay <> 0 THEN
      DEC(overlay);
      IF overlay <= HIGH(save) THEN
        rt := save[overlay].rt;
        wt := save[overlay].wt;
      END;
    END;
  END Reset;


BEGIN
  readTop := 0;
  rt := 0;
  writeTop := 0;
  wt := 0;
  overlay := 0;

  RTSMain.InstallInitProc(Save);
  RTSMain.InstallTermProc(Reset);


  AssignRead (Keyboard.Read, Keyboard.KeyPressed, dummy);
  AssignWrite (Display.Write, dummy);
END Termbase.
