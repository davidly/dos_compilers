
{ Copyright (c) 1985, 88 by Borland International, Inc. }

unit MCINPUT;

interface

uses Crt, Dos, MCVars, MCUtil, MCDisply, MCParser, MCLib;

function GetKey : Char;
{ Reads the next keyboard character }

function EditString(var S : IString; Legal : IString;
                    MaxLength : Word) : Boolean;
{ Allows the user to edit a string with only certain characters allowed -
   Returns TRUE if ESC was not pressed, FALSE is ESC was pressed.
}

procedure GetInput(C : Char);
{ Reads and acts on an input string from the keyboard that started with C }

function GetWord(var Number : Word; Low, High : Word) : Boolean;
{ Reads in a positive word from low to high }

function GetCell(var Col, Row : Word) : Boolean;
{ Reads in a cell name that was typed in - Returns False if ESC was pressed }

function GetYesNo(var YesNo : Char; Prompt : String) : Boolean;
{ Prints a prompt and gets a yes or no answer - returns TRUE if ESC was
   pressed, FALSE if not.
}

function GetCommand(MsgStr, ComStr : String) : Word;
{ Reads in a command and acts on it }

implementation

function GetKey;
var
  C : Char;
begin
  C := ReadKey;
  repeat
    if C = NULL then
    begin
      C := ReadKey;
      if Ord(C) > 127 then
        C := NULL
      else
        GetKey := Chr(Ord(C) + 128);
    end
    else
      GetKey := C;
  until C <> NULL;
end; { GetKey }

function EditString;
var
  CPos : Word;
  Ins : Boolean;
  Ch : Char;
begin
  Ins := True;
  ChangeCursor(Ins);
  CPos := Succ(Length(S));
  SetColor(White);
  repeat
    GotoXY(1, ScreenRows + 5);
    Write(S, '':(79 - Length(S)));
    GotoXY(CPos, ScreenRows + 5);
    Ch := GetKey;
    case Ch of
      HOMEKEY : CPos := 1;
      ENDKEY : CPos := Succ(Length(S));
      INSKEY : begin
        Ins := not Ins;
        ChangeCursor(Ins);
      end;
      LEFTKEY : if CPos > 1 then
        Dec(CPos);
      RIGHTKEY : if CPos <= Length(S) then
        Inc(CPos);
      BS : if CPos > 1 then
      begin
        Delete(S, Pred(CPos), 1);
        Dec(CPos);
      end;
      DELKEY : if CPos <= Length(S) then
        Delete(S, CPos, 1);
      CR : ;
      UPKEY, DOWNKEY : Ch := CR;
      ESC : S := '';
      else begin
        if ((Legal = '') or (Pos(Ch, Legal) <> 0)) and
            ((Ch >= ' ') and (Ch <= '~')) and
             (Length(S) < MaxLength) then
        begin
          if Ins then
            Insert(Ch, S, CPos)
          else if CPos > Length(S) then
            S := S + Ch
          else
            S[CPos] := Ch;
          Inc(CPos);
        end;
      end;
    end; { case }
  until (Ch = CR) or (Ch = ESC);
  ClearInput;
  ChangeCursor(False);
  EditString := Ch <> ESC;
  SetCursor(NoCursor);
end; { EditString }

procedure GetInput;
var
  S : IString;
begin
  S := C;
  if (not EditString(S, '', MAXINPUT)) or (S = '') then
    Exit;
  Act(S);
  Changed := True;
end; { GetInput }

function GetWord;
var
  I, Error : Word;
  Good : Boolean;
  Num1, Num2 : String[5];
  Message : String[80];
  S : IString;
begin
  GetWord := False;
  S := '';
  Str(Low, Num1);
  Str(High, Num2);
  Message := MSGBADNUMBER + ' ' + Num1 + ' to ' + Num2 + '.';
  repeat
    if not EditString(S, '1234567890', 4) then
      Exit;
    Val(S, I, Error);
    Good := (Error = 0) and (I >= Low) and (I <= High);
    if not Good then
      ErrorMsg(Message);
  until Good;
  Number := I;
  GetWord := True;
end; { GetWord }

function GetCell;
var
  Len, NumLen, OldCol, OldRow, Posit, Error : Word;
  Data : IString;
  NumString : IString;
  First, Good : Boolean;
begin
  NumLen := RowWidth(MAXROWS);
  OldCol := Col;
  OldRow := Row;
  First := True;
  Good := False;
  Data := '';
  repeat
    if not First then
      ErrorMsg(MSGBADCELL);
    First := False;
    Posit := 1;
    if not EditString(Data, '', NumLen + 2) then
    begin
      Col := OldCol;
      Row := OldRow;
      GetCell := False;
      Exit;
    end;
    if (Data <> '') and (Data[1] in Letters) then
    begin
      Col := Succ(Ord(UpCase(Data[1])) - Ord('A'));
      Inc(Posit);
      if (Posit <= Length(Data)) and (Data[Posit] in LETTERS) then
      begin
        Col := Col * 26;
        Inc(Col, Succ(Ord(UpCase(Data[Posit])) - Ord('A')));
        Inc(Posit);
      end;
      if Col <= MAXCOLS then
      begin
        NumString := Copy(Data, Posit, Succ(Length(Data) - Posit));
        Val(NumString, Row, Error);
        if (Row <= MAXROWS) and (Error = 0) then
          Good := True;
      end;
    end;
  until Good;
  GetCell := True;
end; { GetCell }

function GetYesNo;
begin
  SetCursor(ULCursor);
  GetYesNo := False;
  WritePrompt(Prompt + ' ');
  repeat
    YesNo := UpCase(GetKey);
    if YesNo = ESC then
      Exit;
  until YesNo in ['Y', 'N'];
  SetCursor(NoCursor);
  GetYesNo := True;
end; { GetYesNo }

function GetCommand;
var
  Counter, Len : Word;
  Ch : Char;
begin
  Len := Length(MsgStr);
  GotoXY(1, ScreenRows + 4);
  ClrEol;
  for Counter := 1 to Len do
  begin
    if MsgStr[Counter] in ['A'..'Z'] then
      SetColor(COMMANDCOLOR)
    else
      SetColor(LOWCOMMANDCOLOR);
    Write(MsgStr[Counter]);
  end;
  GotoXY(1, ScreenRows + 5);
  repeat
    Ch := UpCase(GetKey);
  until (Pos(Ch, ComStr) <> 0) or (Ch = ESC);
  ClearInput;
  if Ch = ESC then
    GetCommand := 0
  else
    GetCommand := Pos(Ch, ComStr);
end; { GetCommand }

end.
