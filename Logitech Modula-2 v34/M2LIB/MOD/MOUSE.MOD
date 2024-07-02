(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(* 	 The functions implemented in this module provide a		   *)	
(*	 Modula-2 interface for the LOGITECH Mouse Driver.		   *)
(*	 This driver interface is compatible with the Microsoft		   *)
(*	 Mouse Driver interface, so this module can be used with	   *)
(*	 all the compatible mouse drivers.			      	   *)
(*	 For detailed description of these functions, please		   *)
(*	 refer to your mouse documentation:				   *)
(*									   *)
(*	 e.g. LOGITECH Mouse Driver Programmer's Reference Manual	   *)
(*       Microsoft Mouse, Installation and Operation Manual		   *)
(*									   *)
(*									   *)
(*	 Microsoft is a registered trademark of				   *)
(*	 Microsoft Corporation						   *)
(*									   *)
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

IMPLEMENTATION MODULE Mouse;

  FROM SYSTEM IMPORT
    BYTE, ADDRESS, ADR,
    SETREG, GETREG, SWI, CODE,
    AX, BX, CX, DX, SI, DI, ES;

  PROCEDURE FlagReset(VAR mouseStatus: INTEGER;
                      VAR numberOfButtons: CARDINAL);
    VAR temp: CARDINAL;
  BEGIN
    SETREG(AX,0);
    SWI(33H);
    GETREG(BX,temp);
    GETREG(AX,mouseStatus);
    numberOfButtons := temp;
  END FlagReset;

  PROCEDURE ShowCursor;                                 
  BEGIN
    SETREG(AX,1);
    SWI(33H);
  END ShowCursor;

  PROCEDURE HideCursor;                                 
  BEGIN
    SETREG(AX,2);
    SWI(33H);
  END HideCursor;

  PROCEDURE GetPosBut(VAR buttonStatus: ButtonSet;
                      VAR horizontal, vertical:INTEGER);
    VAR temp: ButtonSet;
  BEGIN
    SETREG(AX, 3);
    SWI(33H);
    GETREG(BX, temp);
    GETREG(CX, horizontal);
    GETREG(DX, vertical);
    buttonStatus:= temp;
  END GetPosBut;

  PROCEDURE SetCursorPos(horizontal, vertical: INTEGER);
  BEGIN
    SETREG(AX,4);
    SETREG(CX, horizontal);
    SETREG(DX, vertical);
    SWI(33H);
  END SetCursorPos;

  PROCEDURE GetButPres(button: Button;
                       VAR buttonStatus: ButtonSet;
                       VAR buttonPressCount: CARDINAL;
                       VAR horizontal, vertical: INTEGER);
    VAR temp: CARDINAL;
  BEGIN
    SETREG(BX, ORD(button));
    SETREG(AX, 5);
    SWI(33H);
    GETREG(BX, temp);
    GETREG(AX, buttonStatus);
    GETREG(CX, horizontal);
    GETREG(DX, vertical);
    buttonPressCount:= temp;
  END GetButPres;

  PROCEDURE GetButRel(button: Button;
                      VAR buttonStatus: ButtonSet;
                      VAR buttonReleaseCount: CARDINAL;
                      VAR horizontal ,vertical: INTEGER);
    VAR temp: CARDINAL;
  BEGIN
    SETREG(BX, ORD(button));
    SETREG(AX, 6);
    SWI(33H);
    GETREG(BX, temp);
    GETREG(AX, buttonStatus);
    GETREG(CX, horizontal);
    GETREG(DX, vertical);
    buttonReleaseCount:= temp;
  END GetButRel;

  PROCEDURE SetHorizontalLimits(minPos, maxPos: INTEGER);
  BEGIN
    SETREG(AX, 7);
    SETREG(CX, minPos);
    SETREG(DX, maxPos);
    SWI(33H);
  END SetHorizontalLimits;

  PROCEDURE SetVerticalLimits(minPos, maxPos: INTEGER);                   
  BEGIN
    SETREG(AX, 8);
    SETREG(CX, minPos);
    SETREG(DX, maxPos);
    SWI(33H);
  END SetVerticalLimits;


  PROCEDURE SetGraphicCursor(VAR cursor: GraphicCursor);
    VAR a: ADDRESS;
        x,y: INTEGER;
  BEGIN
    WITH cursor DO
      x := hotX; y := hotY;
      a := ADR(screenMask);
    END;
    SETREG(DX,a.OFFSET);
    SETREG(ES,a.SEGMENT);
    SETREG(CX,y);
    SETREG(BX,x);
    SETREG(AX,9);
    SWI(33H);
  END SetGraphicCursor;

  PROCEDURE SetTextCursor(selectedCursor,
                          screenMaskORscanStart,
                          cursorMaskORscanStop: CARDINAL);
  BEGIN
    SETREG(AX, 10);
    SETREG(BX, selectedCursor);
    SETREG(CX, screenMaskORscanStart);
    SETREG(DX, cursorMaskORscanStop);
    SWI(33H);
  END SetTextCursor;

  PROCEDURE ReadMotionCounters(VAR horizontal,
                                   vertical:INTEGER);
  BEGIN
    SETREG(AX, 11);
    SWI(33H);
    GETREG(CX, horizontal);
    GETREG(DX, vertical);
  END ReadMotionCounters;


(*$A-*)
(* alignment off, in order to avoid *)
(* dummy byte after field FarCall   *)

  VAR
    PrivateHandler: RECORD
                      PushAX, PushBX, PushCX, PushDX: BYTE;
                      FarCall: BYTE;
                      handlerProc: EventHandler;
                      FarRet: BYTE;
                    END;

(*$A=*)
(* reset alignment to previous state *)


(*$S-*)(*$T-*)(*$R-*)
  PROCEDURE SetEventHandler(mask: EventSet;
                            handler: EventHandler);
    VAR subr: ADDRESS;
  BEGIN
    PrivateHandler.handlerProc := handler;
    subr := ADR(PrivateHandler);
    SETREG(CX, mask);
    SETREG(DX, subr.OFFSET);
    SETREG(ES, subr.SEGMENT);
    SETREG(AX, 12);
    SWI(33H);
  END SetEventHandler;

(*$S=*)(*$T=*)(*$R=*)

  PROCEDURE LightPenOn;                              
  BEGIN
    SETREG(AX,13);
    SWI(33H);
  END LightPenOn;

  PROCEDURE LightPenOff;                             
  BEGIN
    SETREG(AX,14);
    SWI(33H);
  END LightPenOff;

  PROCEDURE SetMickeysPerPixel(horPix, verPix: CARDINAL);
  BEGIN
    SETREG(AX, 15);
    SETREG(CX, horPix);
    SETREG(DX, verPix);
    SWI(33H);
  END SetMickeysPerPixel;

  PROCEDURE ConditionalOff(left, top,
                           right, bottom: INTEGER);
  BEGIN
    SETREG(AX, 16);
    SETREG(CX, left);
    SETREG(DX, top);
    SETREG(SI, right);
    SETREG(DI, bottom);
    SWI(33H);
  END ConditionalOff;

  PROCEDURE SetSpeedThreshold(threshold: CARDINAL);
  BEGIN
    SETREG(AX, 19);
    SETREG(DX, threshold);
    SWI(33H);
  END SetSpeedThreshold;



  PROCEDURE Terminator;
  BEGIN
    SETREG(AX, 2);
    SWI(33H);      (* hide cursor *)
    SETREG(AX, 0);
    SWI(33H);      (* reset mouse, disable user defined event handler, etc. *)
    TerminateProc := OldTermProc;
    SWI(22H);
  END Terminator;

  CONST
    IRET = 0CFH;
  VAR
    MouseVector[0:204]: ADDRESS;
    TerminateProc[0:88H]: PROC;
    OldTermProc: PROC;

BEGIN
  DriverInstalled := (MouseVector.OFFSET <> 0) AND
                     (MouseVector.SEGMENT <> 0) AND
                     (CARDINAL(MouseVector^) MOD 256 <> IRET);
  IF DriverInstalled THEN
    OldTermProc := TerminateProc;
    TerminateProc := Terminator;
    WITH PrivateHandler DO
      PushAX := BYTE(50H);
      PushBX := BYTE(53H);
      PushCX := BYTE(51H);
      PushDX := BYTE(52H);
      FarCall := BYTE(9AH);
      FarRet := BYTE(0CBH);
    END; (* WITH *)
  END;
END Mouse.
