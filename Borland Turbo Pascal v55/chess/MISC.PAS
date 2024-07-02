{****************************************************************************}
{*  MISC.PAS:  This file contains functions which do miscellaneous things.  *}
{*  Many of them return the output string representation of some variable.  *}
{****************************************************************************}

{****************************************************************************}
{*  Sq Str:  Returns the string representation of the square for the given  *}
{*  row and column (eg.  row = 3, col = 5 would return "C5").               *}
{****************************************************************************}
  function SqStr (row, col : RowColType) : string2;
    begin
      SqStr := copy(COL_NAMES,col,1) + copy(ROW_NAMES,row,1);
    end; {SqStr}

{****************************************************************************}
{*  Move Str: Returns the string representation of the given move.  The     *}
{*  general format is the algebraic notation <from_square>-<to_square>      *}
{*  (eg. "A5-C7").  A take (capture) is represented using an "x" instead    *}
{*  of the "-" (eg. "A5xC7").  Castling to the left (queen's) side is       *}
{*  "O-O-O" and to the right is "O-O".  En passent is represented "PxP EP". *}
{*  The NULL_MOVE is represented "<none>".                                  *}
{****************************************************************************}
  function MoveStr (Movement : MoveType) : string10;
    var bstr : string10;
    begin
      if Movement.FromRow = NULL_MOVE then
          MoveStr := '<None>'
      else begin
          if (Movement.PieceMoved.image = KING) and (abs (Movement.FromCol - Movement.ToCol) > 1) then begin
              {*** handle castling ***}
              if (Movement.FromCol > Movement.ToCol) then
                  MoveStr := 'O-O-O'
              else
                  MoveStr := 'O-O';
          end else begin
              {*** check if en passent ***}
              if (Movement.PieceMoved.image = PAWN) and (Movement.FromCol <> Movement.ToCol)
                        and (Movement.PieceTaken.image = BLANK) then
                  MoveStr := 'PxP EP'
              else begin
                  {*** regular move, push or take ***}
                  bstr := SqStr (Movement.FromRow, Movement.FromCol);
                  if Movement.PieceTaken.image = BLANK then
                      bstr := bstr + '-'
                  else
                      bstr := bstr + 'x';
                  MoveStr := bstr + SqStr (Movement.ToRow, Movement.ToCol);
              end;
          end;
      end;
    end; {MoveStr}

{****************************************************************************}
{*  Time String:  Returns the "HH:MM:SS" representation of the given time   *}
{*  (a 32-bit integer telling giving the number of seconds from zero).      *}
{****************************************************************************}
  function TimeString (InTime : longint) : string80;
    const TIME_BASE : longint = 60; {*** 60 sec/min, 60 min/hr; force constant to be longint ***}
    var Hours, Min, Sec: integer;
        Time: longint;

{----------------------------------------------------------------------------}
{  Pad Str:  Returns the two-digit zero-padded string representation of the  }
{  given number.  (Used to make the HH, MM, and SS components of the time    }
{  string two digits each.                                                   }
{----------------------------------------------------------------------------}
    function PadStr (Num : integer) : string2;
      var Temp: string2;

      begin
        Str (Num, Temp);
        if (length (Temp) = 1) then Temp := '0' + Temp;
        PadStr := Temp;
      end; {PadStr}

{----------------------------------------------------------------------------}
    begin {TimeString}
      {*** assign given time to destructable local variable ***}
      Time := InTime;
      {*** extract number of seconds ***}
      Sec := Time mod TIME_BASE;
      {*** extract number of minutes ***}
      Time := Time div TIME_BASE;
      Min := Time mod TIME_BASE;
      {*** extract number of hours ***}
      Hours := Time div TIME_BASE;
      {*** convert to string ***}
      TimeString := PadStr (Hours) + ':' + PadStr (Min) + ':' + PadStr (Sec);
    end; {TimeString}

{****************************************************************************}
{*  String To Time:  Returns the number of seconds past zero of the given   *}
{*  string of format "HH:MM:SS".  Also checks for conversion errors.  This  *}
{*  routine is the complement of TimeString.                                *}
{****************************************************************************}
  function StringToTime (Str : string80) : longint;
    const SECS_IN_HOUR : longint = 3600;
          SECS_IN_MIN : longint = 60;
    var Hour, Min, Sec, ValError : integer;
        TimeError : boolean;

    begin
      TimeError := true;
      {*** extract the Hour, Min, and Sec variables from the string ***}
      if length(Str) = 8 then begin
          Val (copy (Str, 1, 2), Hour, ValError);
          if ValError = 0 then begin
              Val (copy (Str, 4, 2), Min, ValError);
              if ValError = 0 then begin
                  Val (copy (Str, 7, 2), Sec, ValError);
                  if ValError = 0 then TimeError := false;
              end;
          end;
      end;

      if TimeError then
          {*** if error, return zero seconds ***}
          StringToTime := 0
      else
          {*** return number of seconds ***}
          StringToTime := (Hour * SECS_IN_HOUR) + (Min * SECS_IN_MIN) + Sec
    end; {StringToTime}

{****************************************************************************}
{*  Elapsed Time:  Return number of seconds according to the internal DOS   *}
{*  time of day clock since this routine was last called.  Used to update   *}
{*  the elapsed time for each player.                                       *}
{****************************************************************************}
  function ElapsedTime: longint;
    const SECONDS_IN_DAY : longint = 86400;  {*** interestingly, this is also Mr. Phillips' student number ***}
          SECONDS_IN_HOUR : longint = 3600;
          SECONDS_IN_MINUTE : longint = 60;
    var Hours, Min, Sec, Hundredths: word;
        CurrentTime: longint;
        {*** LastTime is a global variable which tells the last time this routine was called ***}

    begin
      {*** read DOS clock time ***}
      GetTime (Hours, Min, Sec, Hundredths);
      {*** convert to seconds ***}
      CurrentTime := Sec + (SECONDS_IN_MINUTE * Min) + (SECONDS_IN_HOUR * Hours);

      {*** get elapsed time from last reading ***}
      if (CurrentTime < LastTime) then
          {*** handle if 24-hour DOS clock roll-around has occured ***}
          ElapsedTime := CurrentTime + (SECONDS_IN_DAY - LastTime)
      else
          ElapsedTime := CurrentTime - LastTime;
      {*** re-set the global variable ***}
      LastTime := CurrentTime;
    end; {ElapsedTime}

{*** end of MISC.PAS include file ***}
