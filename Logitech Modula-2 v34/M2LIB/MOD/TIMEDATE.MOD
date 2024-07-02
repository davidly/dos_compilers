(***************************************************************************)
(*                                                                         *)
(*  MODULA-2    Library                                                    *)
(*                                                                         *)
(*           LOGITECH Inc,   Fremont,   CA 94555  (USA)                    *)
(*                                                                         *)
(*  Module  :                            				   *)
(*    Module 'TimeDate' provides routines for reading and 	    	   *)
(*    writing the system's date and time.                 	   	   *)
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
IMPLEMENTATION MODULE TimeDate;         (* WS, McL *)

  FROM Strings IMPORT Assign;


  FROM SYSTEM IMPORT  SETREG, GETREG, AX, CX, DX, SWI;


  PROCEDURE GetTime (VAR curTime: Time);
  VAR cx, dx: CARDINAL;
  BEGIN
    SETREG(AX,2A00H);
    SWI(21H);
    GETREG(CX,cx);   (* CX = year 1980..2099  *)
    GETREG(DX,dx);   (* DH = month  1..12     *)
                     (* DL = day    1..31     *)
    curTime.day := (cx-1900)*512 + (dx DIV 256)*32 + (dx MOD 256);
    SETREG(AX,2C00H);
    SWI(21H);        (* get time -> CX:DX     *)
    GETREG(CX,cx);   (* CH = hour 0..23       *)
                     (* CL = min  0..59       *)
    GETREG(DX,dx);   (* DH = sec  0..59       *)
                     (* DL = sec/100  0..99   *)
    curTime.minute := (cx DIV 256)*60 + (cx MOD 256);
    curTime.millisec := (dx DIV 256)*1000 + (dx MOD 256)*10;
  END GetTime;


  PROCEDURE SetTime (newTime: Time);
  VAR cx,dx: CARDINAL;
  BEGIN
    cx := (newTime.day DIV 512) +1900;
    dx := (newTime.day MOD 32) + 256*((newTime.day DIV 32) MOD 16);
    SETREG(CX,cx); SETREG(DX,dx);
    SETREG(AX,2B00H);
    SWI(21H);           (* set date             *)
    cx := 256*(newTime.minute DIV 60) + (newTime.minute MOD 60);
    dx := (newTime.millisec DIV 1000)*256 +
          ((newTime.millisec MOD 1000) DIV 10);
    SETREG(CX,cx); SETREG(DX,dx);
    SETREG(AX,2D00H);
    SWI(21H);           (* set time             *)
  END SetTime;





  PROCEDURE CompareTime(t1, t2: Time): INTEGER;
  BEGIN
    IF t1.day < t2.day THEN
      RETURN -1;
    ELSIF t1.day > t2.day THEN
      RETURN 1;
    ELSIF t1.minute < t2.minute THEN
      RETURN -1;
    ELSIF t1.minute > t2.minute THEN
      RETURN 1;
    ELSIF t1.millisec < t2.millisec THEN
      RETURN -1;
    ELSIF t1.millisec > t2.millisec THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END;
  END CompareTime;

  PROCEDURE TimeToZero(VAR t: Time);
  BEGIN
    t.day      := 0;
    t.minute   := 0;
    t.millisec := 0;
  END TimeToZero;

  PROCEDURE TimeToString(t: Time; VAR s: ARRAY OF CHAR);

    VAR
      year, month, day, hour, minute, second: CARDINAL;
      str : ARRAY [0..17] OF CHAR;

    PROCEDURE NumToStr(a, n : CARDINAL);
    BEGIN
      str[a]   := CHR(n DIV 10 + ORD('0'));
      str[a+1] := CHR(n MOD 10 + ORD('0'));
    END NumToStr;

  BEGIN
    day := t.day MOD 32;
    t.day := t.day DIV 32;
    month := t.day MOD 16;
    year := t.day DIV 16;    (* MOD 100 ? *)
    second := t.millisec DIV 1000;
    minute := t.minute MOD 60;
    hour := t.minute DIV 60;

    NumToStr(15, second);
    str[14] := ':';
    NumToStr(12, minute);
    str[11] := ':';
    NumToStr(9, hour);
    str[ 8] := ' ';
    NumToStr(6, day);
    str[ 5] := '-';
    NumToStr(3, month);
    str[ 2] := '-';
    NumToStr(0, year);

    str[17] := 0c;
    Assign(str, s);

  END TimeToString;

END TimeDate.
