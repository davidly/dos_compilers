(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Calendar operations and utilities                                    *)
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

IMPLEMENTATION MODULE Calendar;


  FROM DurationOps IMPORT
    Unit, UnitSet, EmptyUnitSet, Duration,
    Clear, Format, FormatOf,
    Equal, Greater, GreaterOrEqual,
    Sum, Diff;
  
  FROM TimeDate IMPORT
    Time, GetTime, SetTime;

  IMPORT BitWordOps;

(* -----------------------------------------------------------------------
   This conversion function has no physical meaning, but will be useful 
   to use duration comparison functions 
 ------------------------------------------------------------------------- *)
 
  PROCEDURE DateToDuration (date         : Date;
                            VAR duration : Duration);
    BEGIN
      Clear (duration);
      WITH date DO
        duration [Year]       := FLOAT (year);
        duration [Month]      := FLOAT (month);
        duration [Day]        := FLOAT (day);
        duration [Hour]       := FLOAT (hour);
        duration [Minute]     := FLOAT (minute);
        duration [Second]     := FLOAT (second);
        duration [Thousandth] := FLOAT (thousandth);
      END;
    END DateToDuration;


(*------------------------------------------------------------------------
   Implementation of DEFINED routines.
 ------------------------------------------------------------------------*)
  
  PROCEDURE GetMachineDate (VAR date: Date);
    VAR 
      t : Time;
    BEGIN
      GetTime (t);
      TimeToDate (t, date);
    END GetMachineDate;

  PROCEDURE SetMachineDate (date : Date);
    VAR 
      t : Time;
    BEGIN
      DateToTime (date, t);
      SetTime (t);
    END SetMachineDate;


  PROCEDURE TimeToDate (time     : Time;
                        VAR date : Date);
    BEGIN
      date.thousandth := time.millisec MOD 1000;
      date.second   := time.millisec DIV 1000;
      date.minute   := time.minute MOD 60;
      date.hour     := time.minute DIV 60;
      date.day      := CARDINAL (BitWordOps.GetBits (time.day, 0, 4));
      date.month    := CARDINAL (BitWordOps.GetBits (time.day, 5, 8));
      date.year     := 1900 
                       + CARDINAL (BitWordOps.GetBits (time.day, 9, 15));
    END TimeToDate;

  PROCEDURE DateToTime (date     : Date;
                        VAR time : Time);
    BEGIN
      time.millisec := date.thousandth + 1000 * date.second;
      time.minute   := date.minute + 60 * date.hour;
      time.day      := 0;
      BitWordOps.SetBits (time.day, 0, 4, date.day);
      BitWordOps.SetBits (time.day, 5, 8, date.month);
      BitWordOps.SetBits (time.day, 9, 15, date.year - 1900);
    END DateToTime;


  PROCEDURE LeapYear (year : CARDINAL): BOOLEAN;
    (* Returns TRUE if year is a leap year.
       Leap years are divisible by 400, or by 4 and not by 100 *)
    BEGIN
      RETURN ( (year MOD 400) = 0) OR
               ( ( (year MOD 4) = 0) AND ( (year MOD 100) <> 0) ) ;
    END LeapYear;

  PROCEDURE IsValid (date : Date): BOOLEAN;
    (* Returns TRUE if date is valid, according to the Gregorian calendar *)
    BEGIN
      RETURN (date.year >= 1582) AND 
             (date.day <= DaysIn (date.month, date.year) );
    END IsValid;

  PROCEDURE DaysIn (month : CARDINAL;
                    year  : CARDINAL): CARDINAL;
    (* Returns the number of days in the month of the year, according to 
       the Gregorian calendar, 0 if month is out of range. Result may be
       wrong for years before 1582 *)
    BEGIN
      CASE month OF
        1, 3, 5, 7, 8, 10, 12 : RETURN 31;
      | 4, 6, 9, 11           : RETURN 30;
      | 2                     : IF LeapYear (year) THEN
                                                     RETURN 29;
                                                   ELSE
                                                     RETURN 28;
                                                   END;
      ELSE
        (* illegal month *)
        RETURN 0;
      END;
    END DaysIn;


  PROCEDURE TimeSince1582 (date         : Date;
                           VAR duration : Duration);
    VAR
      m, n : CARDINAL;
    BEGIN
      Clear (duration);
      WITH date DO
        duration [Hour]       := FLOAT (hour);
        duration [Minute]     := FLOAT (minute);
        duration [Second]     := FLOAT (second);
        duration [Thousandth] := FLOAT (thousandth);

        duration [Day] := FLOAT (day - 1);
        FOR m := 1 TO month - 1 DO
          duration [Day] := duration [Day] + FLOAT (DaysIn (m, year) );
        END;

        n := year - 1582;
        duration [Day] := duration [Day] + 365.0 * FLOAT (n) 
                                         + FLOAT (  (n +   1) DIV 4 
                                                  - (n +  81) DIV 100
                                                  + (n + 381) DIV 400);
      END; (* WITH date *)
    END TimeSince1582;


  PROCEDURE AddToDate (date           : Date;
                       duration       : Duration;
                       VAR resultDate : Date);
    (* Add a duration to a date, gives a new date *)
    CONST
      format = UnitSet {Day, Hour, Minute, Second, Thousandth};
    VAR
      temp : Duration;
      i    : Unit;
    BEGIN
      DateToDuration (date, temp);
      FOR i := Millenium TO Month DO
        temp [i] := 0.0;
      END;
      Format (duration, format);
      Sum (duration, temp, format, temp);
      WITH resultDate DO
        year     := date.year;
        month    := date.month;
        hour     := TRUNC (temp [Hour]);
        minute   := TRUNC (temp [Minute]);
        second   := TRUNC (temp [Second]);
        thousandth := TRUNC (temp [Thousandth]);

        WHILE temp [Day] > FLOAT (DaysIn (month, year) ) DO
          temp [Day] := temp [Day] - FLOAT (DaysIn (month, year) );
          IF month = 12 THEN
            INC (year);
            month := 1;
          ELSE
            INC (month);
          END;
        END;
        day := TRUNC (temp [Day]);
      END;
    END AddToDate;

  PROCEDURE SubToDate (date           : Date;
                       duration       : Duration;
                       VAR resultDate : Date);
    (* Subtract a duration from a date, gives a new date *)

  CONST format = UnitSet{Day, Hour, Minute, Second, Thousandth};

  VAR temp   : Duration;
      tdate  : Date;
    
  BEGIN  
    TimeSince1582(date,temp);
    Diff(temp,duration,format,temp);
    tdate.thousandth := 0;
    tdate.second := 0;
    tdate.minute := 0;
    tdate.hour := 0;
    tdate.day := 1;
    tdate.month := 1;
    tdate.year := 1582;
    AddToDate(tdate,temp,resultDate);
  END SubToDate;

  PROCEDURE DeltaDate (date1, date2 : Date;
                       format       : UnitSet;
                       VAR duration : Duration);
    (* Absolute value of the difference between two date, gives a duration *)
    
    VAR
      d1, d2 : Duration;
    BEGIN
      Clear (duration);
      TimeSince1582 (date1, d1);
      TimeSince1582 (date2, d2);
      IF GreaterOrEqual (d1, d2, Thousandth) THEN
        Diff (d1, d2, format, duration);
      ELSE
        Diff (d2, d1, format, duration);
      END;
    END DeltaDate;
    

  PROCEDURE SameDate (date1, date2 : Date;
                      precision   : Unit) : BOOLEAN;
    (* Returns TRUE if date1 and date2 are the same date, within precision *)
    VAR
      t1, t2 : Duration;
    BEGIN
      DateToDuration (date1, t1);
      DateToDuration (date2, t2);
      RETURN Equal (t1, t2, precision);
    END SameDate;

  PROCEDURE Later (date1, date2 : Date;
                   precision   : Unit) : BOOLEAN;
    (* Returns TRUE if date1 is after date2, within precision *)
    VAR
      t1, t2 : Duration;
    BEGIN
      DateToDuration (date1, t1);
      DateToDuration (date2, t2);
      RETURN Greater (t1, t2, precision);
    END Later;

  PROCEDURE LaterOrSameDate (date1, date2 : Date;
                             precision   : Unit) : BOOLEAN;
    (* Returns TRUE if date2 is after date1 or if date1 and date2 are the same
       date, within precision *)
    VAR
      t1, t2 : Duration;
    BEGIN
      DateToDuration (date1, t1);
      DateToDuration (date2, t2);
      RETURN GreaterOrEqual (t2, t1, precision);
    END LaterOrSameDate;

END Calendar.
