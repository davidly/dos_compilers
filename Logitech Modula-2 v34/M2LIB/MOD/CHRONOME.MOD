(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Chronometer                                                          *)
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

IMPLEMENTATION MODULE Chronometer;

  FROM Storage IMPORT
    ALLOCATE, DEALLOCATE;

  FROM DurationOps IMPORT 
    Unit, UnitSet, EmptyUnitSet, Duration,
    Format, Sum, Clear;

  FROM Calendar IMPORT
    Date, TimeToDate, DeltaDate;

  FROM TimeDate IMPORT
    Time, GetTime;

  CONST
    Active    = 31415;
    Created   = 61363;
    Destroyed = 11111;

  TYPE 
    Chrono = POINTER TO RECORD
                          control     : CARDINAL;
                          start       : Time;
                          elapsedTime : Duration;
                        END; (* Chrono *)

  PROCEDURE NewChrono (VAR chrono : Chrono);
    BEGIN
      NEW (chrono);
      chrono^.control := Created;
      ResetChrono (chrono);
    END NewChrono;

  PROCEDURE DisposeChrono (VAR chrono : Chrono);
    BEGIN
      IF (chrono^.control = Active) OR (chrono^.control = Created) THEN
        chrono^.control := Destroyed;
        DISPOSE (chrono);
      ELSE
        HALT;
      END;
    END DisposeChrono;

  PROCEDURE ResetChrono (chrono : Chrono);
    BEGIN
      IF (chrono^.control = Active) OR (chrono^.control = Created) THEN
        Clear (chrono^.elapsedTime);
        chrono^.control := Created;
      ELSE
        HALT;
      END;
    END ResetChrono;

  PROCEDURE StartChrono (chrono : Chrono);
    BEGIN
      IF (chrono^.control = Active) OR (chrono^.control = Created) THEN
        chrono^.control := Active;
        GetTime (chrono^.start);
      ELSE
        HALT;
      END;
    END StartChrono;

  PROCEDURE StopChrono (chrono : Chrono);
    VAR
      t      : Time;
      t1, t2 : Date;
      dur    : Duration;
    BEGIN
      IF (chrono^.control = Active) THEN
        GetTime (t);
        TimeToDate (t, t2);
        TimeToDate (chrono^.start, t1);
        DeltaDate (t1, t2, UnitSet {Second}, dur);
        Sum (dur, chrono^.elapsedTime, UnitSet {Second}, chrono^.elapsedTime);
        chrono^.control := Created;
      ELSIF (chrono^.control = Created) THEN
        (* nothing *)
      ELSE
        HALT;
      END;
  END StopChrono;

  PROCEDURE ReadChrono (chrono          : Chrono;
                        format          : UnitSet;
                        VAR elapsedTime : Duration);
    (* If format is empty then elapsedTime will be in seconds.
       A chrono can be read several times, elapsedTime holds the
       time elapsed since the last StartChrono of this chrono. *)

    VAR
      t      : Time;
      t1, t2 : Date;
      dur    : Duration;
    BEGIN
      GetTime (t);
      IF (chrono^.control = Active) THEN
        TimeToDate (t, t2);
        TimeToDate (chrono^.start, t1);
        IF format = EmptyUnitSet THEN
          format := UnitSet {Second};
        END;
        DeltaDate (t1, t2, format, dur);
        Sum (dur, chrono^.elapsedTime, format, elapsedTime);
      ELSIF (chrono^.control = Created) THEN
        elapsedTime := chrono^.elapsedTime;
        Format (elapsedTime, format);
      ELSE
        HALT;
      END;
    END ReadChrono;

  END Chronometer.

