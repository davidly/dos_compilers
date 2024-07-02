(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    DateFormat, date formatting                                          *)
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

IMPLEMENTATION MODULE DateFormat;

  FROM Calendar IMPORT 
    Date; 

  FROM Strings  IMPORT 
    Copy, Assign, Insert, Concat, CompareStr;

  FROM NumberConversion IMPORT
    CardToString, StringToCard;

  FROM Storage  IMPORT 
    ALLOCATE, DEALLOCATE;

  TYPE FormatCell = RECORD
                      prec : Order;
                      date : DayFormat;
                      year : YearFormat;
                      month: MonthFormat;
                      names: MonthList;
                      hour : HourFormat;
                      sep  : SeparatorList;
                    END; (* Format *)

  TYPE Format = POINTER TO FormatCell;
  
  VAR
    defaultFormat : Format;
    currentFormat  : Format;
    monthNumbers   : MonthList;

  PROCEDURE Initialize;
    VAR
      s : ARRAY [0 .. 35] OF CHAR;
      i : CARDINAL;
    BEGIN
      s := "JanFebMarAprMayJunJulAugSepOctNovDec";
      NEW (defaultFormat);
      WITH defaultFormat^ DO
        prec := DateAndTime;
        date := European;
        year := Long;
        month:= InLetters;
        FOR i := 1 TO 12 DO
          Copy (s, (i - 1) * 3, 3, names [i]);
        END;
        hour := H24Sec;
        sep := "-- ::";
      END;

      NEW (currentFormat);
      currentFormat^ := defaultFormat^;

      s := "01-02-03-04-05-06-07-08-09-10-11-12-";
      FOR i := 1 TO 12 DO
        Copy (s, (i - 1) * 3, 2, monthNumbers [i]);
      END;
    END Initialize;


  PROCEDURE DefaultFormat (): Format;
    BEGIN
      RETURN defaultFormat;
    END DefaultFormat;

  PROCEDURE CurrentFormat (): Format;
    BEGIN
      RETURN currentFormat;
    END CurrentFormat;

  PROCEDURE SetFormat (f : Format);
    BEGIN
      currentFormat^ := f^;
    END SetFormat;

  PROCEDURE SetOrder (format : Order);
    BEGIN
      currentFormat^.prec := format;
    END SetOrder;

  PROCEDURE SetDayFormat (format : DayFormat);
    BEGIN
      currentFormat^.date := format;
    END SetDayFormat;

  PROCEDURE SetYearFormat (format : YearFormat);
    BEGIN
      currentFormat^.year := format;
    END SetYearFormat;

  PROCEDURE SetMonthFormat (format : MonthFormat);
    BEGIN
      currentFormat^.month := format;
      IF format = InDigits THEN
        SetMonthList (monthNumbers);
      END;
    END SetMonthFormat;

  PROCEDURE SetMonthList (list : MonthList);
    VAR
      i : CARDINAL;
    BEGIN
      FOR i := 1 TO 12 DO
        Assign (list[i], currentFormat^.names [i]);
      END;
    END SetMonthList;

  PROCEDURE SetHourFormat (format : HourFormat);
    BEGIN
      currentFormat^.hour := format;
    END SetHourFormat;

  PROCEDURE SetSeparator (separator : SeparatorList);
    BEGIN
      Assign (separator, currentFormat^.sep);
    END SetSeparator;


  PROCEDURE DateToString (date      : Date;
                          VAR image : ARRAY OF CHAR;
                          VAR done  : BOOLEAN);
    VAR
      nString    : ARRAY [0 .. 1] OF CHAR;
      yearString : ARRAY [0 .. 3] OF CHAR;
      timeString : ARRAY [0 .. 10] OF CHAR;
      dayString  : ARRAY [0 .. 30] OF CHAR;
      s1, s2, s3 : ARRAY [0 .. 0] OF CHAR;

    BEGIN
      Copy (currentFormat^.sep, 2, 1, s3);
      IF (currentFormat^.prec = TimeOnly) OR 
         (currentFormat^.prec = TimeAndDate) THEN
        Copy (currentFormat^.sep, 0, 1, s1);
        Copy (currentFormat^.sep, 1, 1, s2);
      ELSE
        Copy (currentFormat^.sep, 3, 1, s1);
        Copy (currentFormat^.sep, 4, 1, s2);
      END;
      
      timeString := "";
      IF ((currentFormat^.hour = PMNoSec) OR (currentFormat^.hour = PMSec)) THEN
        IF (date.hour = 0) THEN
          CardToString (12, nString, 2);
        ELSIF (date.hour > 12) THEN
          CardToString (date.hour - 12, nString, 2);
        ELSE
          CardToString (date.hour, nString, 2);
        END;
      ELSE
        CardToString (date.hour, nString, 2);
        IF (date.hour < 10) THEN
          nString [0] := '0';
        END;
      END;
      Insert (nString, timeString, 0);
      timeString [2] := s1 [0];
      timeString [3] := 0c;
      CardToString (date.minute, nString, 2);
      IF (date.minute < 10) THEN
        nString [0] := '0';
      END;
      Concat (timeString, nString, timeString);
      IF (currentFormat^.hour = PMSec) OR (currentFormat^.hour = H24Sec) THEN
        timeString [5] := s2 [0];
        timeString [6] := 0c;
        CardToString (date.second, nString, 2);
        IF (date.second < 10) THEN
          nString [0] := '0';
        END;
        Concat (timeString, nString, timeString);
      END;
      IF (currentFormat^.hour = PMSec) OR (currentFormat^.hour = PMNoSec) THEN
        IF (date.hour >= 0) AND (date.hour < 12) THEN
          Concat (timeString, " am", timeString);
        ELSE
          Concat (timeString, " pm", timeString);
        END;
      END;

      IF currentFormat^.prec = TimeOnly THEN
        Assign (timeString, image);
        done := TRUE;
        RETURN;
      END;

      IF currentFormat^.year = Long THEN
        CardToString (date.year, yearString, 4);
      ELSE
        CardToString (date.year MOD 100, yearString, 2);
        IF yearString [0] = ' ' THEN
          yearString [0] := '0';
        END;
      END;
      CardToString (date.day, nString, 2);
      IF (date.day < 10) THEN
        nString [0] := '0';
      END;

      IF (currentFormat^.prec = DateOnly) OR 
         (currentFormat^.prec = DateAndTime) THEN
        Copy (currentFormat^.sep, 0, 1, s1);
        Copy (currentFormat^.sep, 1, 1, s2);
      ELSE
        Copy (currentFormat^.sep, 3, 1, s1);
        Copy (currentFormat^.sep, 4, 1, s2);
      END;


      CASE currentFormat^.date OF
        European : Concat (nString, s1, dayString);
                   Concat (dayString, 
                           currentFormat^.names [date.month], 
                           dayString);
                   Concat (dayString, s2, dayString);
                   Concat (dayString, yearString, dayString);
      | US       : Concat (currentFormat^.names [date.month], s1, dayString);
                   Concat (dayString, nString, dayString);
                   Concat (dayString, s2, dayString);
                   Concat (dayString, yearString, dayString);
      | ISO      : Concat (yearString, s1, dayString);
                   Concat (dayString,
                           currentFormat^.names [date.month],
                           dayString);
                   Concat (dayString, s2, dayString);
                   Concat (dayString, nString, dayString);
      END;

      CASE currentFormat^.prec OF
        DateOnly    : Assign (dayString, image);
      | DateAndTime : Concat (dayString, s3, image);
                      Concat (image, timeString, image);
      | TimeAndDate : Concat (timeString, s3, image);
                      Concat (image, dayString, image);
      END;
      done := TRUE;
    END DateToString;

  PROCEDURE StringToDate (image        : ARRAY OF CHAR;
                          VAR date     : Date;
                          VAR done     : BOOLEAN;
                          VAR errorPos : CARDINAL);

    VAR 
      pos     : CARDINAL;
      sepInx  : CARDINAL;
      nextSep : CHAR;

    PROCEDURE SkipSeparator;
      BEGIN
        INC (sepInx);
        nextSep := currentFormat^.sep [sepInx];
        INC (pos);
      END SkipSeparator;

    PROCEDURE GetDate;

      PROCEDURE GetDay;
        VAR 
          dString : ARRAY [0 .. 1] OF CHAR;
          d       : CARDINAL;
        BEGIN
          Copy (image, pos, 2, dString);
          StringToCard (dString, d, done);
          IF NOT done THEN
            errorPos := pos;
          ELSIF (d < 1) OR (d > 31) THEN
            done := FALSE;
            errorPos := pos;
          ELSE
            date.day := d;
            INC (pos, 2);
          END;
        END GetDay;

      PROCEDURE GetMonth;
        VAR 
          name : ARRAY [0 .. 15] OF CHAR;
          i, j : CARDINAL;
          found: BOOLEAN;
        BEGIN
          i := 0;
          WHILE (image [pos + i] <> nextSep) AND (image [pos + i] <> 0c) DO
            name [i] := image [pos + i];
            INC (i);
          END;

          IF image [pos + i] <> nextSep THEN
            done := FALSE;
            errorPos := pos;
            RETURN;
          END;

          name [i] := 0c;
          j := 1;
          found := FALSE;
          WHILE (j <= 12) AND NOT found DO
            IF CompareStr (currentFormat^.names [j], name) = 0 THEN
              found := TRUE;
            ELSE
              INC (j);
            END;
          END;
          IF NOT found THEN
            errorPos := pos;
            done := FALSE;
          ELSE
            date.month := j;
            pos := pos + i;
          END;
        END GetMonth;

      PROCEDURE GetYear;
        VAR
          yString : ARRAY [0 .. 3] OF CHAR;
        BEGIN
          IF currentFormat^.year = Long THEN
            Copy (image, pos, 4, yString);
          ELSE
            Copy (image, pos, 2, yString);
          END;
          StringToCard (yString, date.year, done);
          IF NOT done THEN
            errorPos := pos;
          ELSIF currentFormat^.year = Long THEN
            INC (pos, 4);
          ELSE
            INC (pos, 2);
            INC (date.year, 1900);
          END;
        END GetYear;

      BEGIN
        CASE currentFormat^.date OF
          European : GetDay;
                     IF NOT done THEN RETURN END;
                     SkipSeparator;
                     GetMonth;
                     IF NOT done THEN RETURN END;
                     SkipSeparator;
                     GetYear;
                     IF NOT done THEN RETURN END;
        | US       : GetMonth;
                     IF NOT done THEN RETURN END;
                     SkipSeparator;
                     GetDay;
                     IF NOT done THEN RETURN END;
                     SkipSeparator;
                     GetYear;
                     IF NOT done THEN RETURN END;
        | ISO      : GetYear;
                     IF NOT done THEN RETURN END;
                     SkipSeparator;
                     GetMonth;
                     IF NOT done THEN RETURN END;
                     SkipSeparator;
                     GetDay;
                     IF NOT done THEN RETURN END;
        END;
      END GetDate;

      PROCEDURE GetTime;
        
        PROCEDURE GetHour;
          VAR
            hString : ARRAY [0 .. 1] OF CHAR;
            h       : CARDINAL;
          BEGIN
            Copy (image, pos, 2, hString);
            StringToCard (hString, h, done);
            IF NOT done THEN
              errorPos := pos;
            ELSIF (h > 23) OR 
                  ( (h > 12) AND 
                  ( (currentFormat^.hour = PMSec) OR 
                    (currentFormat^.hour = PMNoSec) ) ) THEN
              done := FALSE;
              errorPos := pos;
            ELSE
              date.hour := h;
              INC (pos, 2);
            END;
          END GetHour;

        PROCEDURE GetMinute;
          VAR
            mString : ARRAY [0 .. 1] OF CHAR;
            m       : CARDINAL;
          BEGIN
            Copy (image, pos, 2, mString);
            StringToCard (mString, m, done);
            IF NOT done THEN
              errorPos := pos;
            ELSIF (m > 59) THEN
              done := FALSE;
              errorPos := pos;
            ELSE
              date.minute := m;
              INC (pos, 2);
            END;
          END GetMinute;

        PROCEDURE GetSecond;
          VAR
            sString : ARRAY [0 .. 1] OF CHAR;
            s       : CARDINAL;
          BEGIN
            Copy (image, pos, 2, sString);
            StringToCard (sString, s, done);
            IF NOT done THEN
              errorPos := pos;
            ELSIF (s > 59) THEN
              done := FALSE;
              errorPos := pos;
            ELSE
              date.second := s;
              INC (pos, 2);
            END;
          END GetSecond;

        PROCEDURE GetHalf;
          VAR 
            hString : ARRAY [0 .. 1] OF CHAR;
          BEGIN
            IF (image [pos] = ' ') THEN
              INC (pos);
            END;
            Copy (image, pos, 2, hString);
            IF (CompareStr (hString, "PM") = 0) OR
               (CompareStr (hString, "pm") = 0) OR
               (CompareStr (hString, "Pm") = 0) THEN
              IF date.hour = 12 THEN
                date.hour := 0;
              ELSE
                INC (date.hour, 12); 
              END;
            ELSIF (CompareStr (hString, "AM") <> 0) AND
                  (CompareStr (hString, "am") <> 0) AND
                  (CompareStr (hString, "Am") <> 0) THEN
              done := FALSE;
              errorPos := pos;
            END;
            INC (pos, 2);
          END GetHalf;
                  
        BEGIN
          GetHour;
          IF NOT done THEN RETURN END;
          SkipSeparator;
          GetMinute;
          IF NOT done THEN RETURN END;
          IF (currentFormat^.hour = PMSec) OR 
             (currentFormat^.hour = H24Sec) THEN
            SkipSeparator;
            GetSecond;
            IF NOT done THEN RETURN END;
          ELSE
            INC (sepInx);
            nextSep := currentFormat^.sep [sepInx];
          END;
          IF (currentFormat^.hour = PMSec) OR 
             (currentFormat^.hour = PMNoSec) THEN
            GetHalf;
          END;
        END GetTime;

    BEGIN
      pos := 0;
      sepInx := 0;
      nextSep := currentFormat^.sep [sepInx];
      done := TRUE;

      CASE currentFormat^.prec OF
        DateOnly : GetDate;
                   date.hour := 0;
                   date.minute := 0;
                   date.second := 0;
                   date.thousandth := 0;
      | TimeOnly : GetTime;
                   date.year := 1963;
                   date.month := 6;
                   date.day := 13;
      | DateAndTime : GetDate;
                      IF NOT done THEN RETURN END;
                      SkipSeparator;
                      GetTime;
      | TimeAndDate : GetTime;
                      IF NOT done THEN RETURN END;
                      SkipSeparator;
                      GetDate;
      END;
    END StringToDate;


BEGIN
  Initialize;
END DateFormat.
