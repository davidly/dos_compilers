(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Delay, stop execution for a given time.     			   *)
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


IMPLEMENTATION MODULE Delay;

(*$O-*)
(*$R-*)
(*$T-*)
(*$S-*)


FROM RTSIntPROC IMPORT SetIntPROC, RemoveIntPROC;

  VAR
    interruptCount, 
    delayFactor, 
    milliSec,
    i, zero, loopcount          : LONGINT;

PROCEDURE Delay(limit: INTEGER);
VAR oneMillisec : INTEGER;
BEGIN 
  oneMillisec := VAL(INTEGER,delayFactor);
  milliSec := 0L;
  LOOP  
    IF milliSec >= VAL(LONGINT,limit) THEN RETURN END;
    i    := 0L;
    zero := 0L;
    zero := 0L;
    LOOP
      IF i >= VAL(LONGINT,oneMillisec) THEN EXIT END;
      zero := 0L;
      zero := 0L;
      zero := 0L;
      INC (i);
    END;
    INC (milliSec); 
  END;
END Delay;

PROCEDURE TimerInterrupt;
BEGIN
  INC(interruptCount);
END TimerInterrupt;

PROCEDURE InitDelayFactor;
  CONST
    TimerVector      = 8H;
    missedloops      = 30L; (* missed during interrupt handling *)
  VAR local3 : INTEGER;
BEGIN
  local3 := 3;
  loopcount := 0L;

  interruptCount := -1L;
  SetIntPROC(TimerInterrupt,TimerVector);
  WHILE interruptCount < 0L DO END;
  LOOP
      (* LOOP with the same code as the loops in procedure 'Delay'.      *)
      (* The execution time 'looptime' of the loop can be disregarded.   *)
      (* The delayFactor corresponds to the number of loops required     *)
      (* to last 1 millisec.                                             *)
      (* The delayFactor is calculated with 18.2 timer interrupts / sec  *)
      (* and with 3 effective interrupts :                               *)
      (* LOOP in InitDelayFactor :                                       *)
      (*   (loopcount+missedloops) * looptime   = 3 int * 1000/18.2 ms   *)
      (* LOOP in Delay :                                                 *)
      (*   limit * (1 + oneMillisec) * looptime = limit             ms   *)

    IF interruptCount >= VAL(LONGINT,local3) THEN EXIT END; 
                            (* until 3 interrupts occured *)
    zero := 0L;  (* used to stretch the loop *)
    zero := 0L;
    zero := 0L;
    INC (loopcount);
  END;
  RemoveIntPROC(TimerVector);
  delayFactor := ((((loopcount+missedloops) * 182L) DIV 3L) DIV 10000L) -1L ;  
END InitDelayFactor;

BEGIN
  InitDelayFactor;




END Delay.
