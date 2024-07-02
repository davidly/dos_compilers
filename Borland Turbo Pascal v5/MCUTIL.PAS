
{ Copyright (c) 1985, 88 by Borland International, Inc. }

unit MCUTIL;

interface

uses Crt, Dos, MCVars;

function Pad(S : String; Len : Word) : String;
{ Pads a string on the right with spaces to a specified length }

function Spaces(Num : Word) : String;
{ Returns a string of the specified number of spaces }

function UpperCase(S : String) : String;
{ Returns a string of all upper case letters }

function WordToString(Num, Len : Word) : String;
{ Changes a word to a string }

function RealToString(Num : Real; Len, Places : Word) : String;
{ Changes a real to a string }

function AllocText(Col, Row : Word; S : String) : Boolean;
{ Allocates space for a text cell }

function AllocValue(Col, Row : Word; Amt : Real) : Boolean;
{ Allocates space for a value cell }

function AllocFormula(Col, Row : Word; S : String; Amt : Real) : Boolean;
{ Allocates space for a formula cell }

function RowWidth(Row : Word) : Word;
{ Returns the width in spaces of row }

function FormulaStart(Input : String; Place : Word;
                      var Col, Row, FormLen : Word) : Boolean;
{ Returns TRUE if the string is the start of a formula, FALSE otherwise.
   Also returns the column, row, and length of the formula.
}

function ColString(Col : Word) : String;
{ Changes a column number to a string }

function CenterColString(Col : Word) : String;
{ Changes a column to a centered string }

function TextString(InString : String; Col, FValue : Word;
                    Formatting : Boolean) : String;
{ Sets the string representation of text }

function ValueString(CPtr : CellPtr; Value : Real; Col, FValue : Word;
                     var Color : Word; Formatting : Boolean) : String;
{ Sets the string representation of a value }

function CellString(Col, Row : Word; var Color : Word;
                    Formatting : Boolean) : String;
{ Creates an output string for the data in the cell in (col, row), and
   also returns the color of the cell }

procedure Switch(var Val1, Val2 : Word);
{ Swaps the first and second values }

procedure InitVars;
{ Initializes various global variables }

function Exists(FileName : String) : Boolean;
{ Returns True if the file FileName exists, False otherwise }

implementation

{$F+}

function HeapFunc(Size : Word) : Word;
{ Used to handle heap errors }
begin
  HeapFunc := 1;       { Forces New or GetMem to return a nil pointer }
end; { HeapFunc }

{$F-}

function Pad;
begin
  if Length(S) < Len then
    FillChar(S[Succ(Length(S))], Len - Length(S), ' ');
  S[0] := Chr(Len);
  Pad := S;
end; { Pad }

function Spaces;
var
  S : String;
begin
  S[0] := Chr(Num);
  FillChar(S[1], Num, ' ');
  Spaces := S;
end; { Spaces }

function UpperCase;
var
  Counter : Word;
begin
  for Counter := 1 to Length(S) do
    S[Counter] := UpCase(S[Counter]);
  UpperCase := S;
end; { UpperCase }

function WordToString;
var
  S : String[5];
begin
  Str(Num:Len, S);
  WordToString := S;
end; { WordToString }

function RealToString;
var
  S : String[80];
begin
  Str(Num:Len:Places, S);
  RealToString := S;
end; { RealToString }

function AllocText;
var
  CPtr : CellPtr;
begin
  AllocText := False;
  GetMem(CPtr, Length(S) + 3);
  if CPtr = nil then
    Exit;
  CPtr^.Attrib := TXT;
  CPtr^.Error := False;
  CPtr^.T := S;
  Cell[Col, Row] := CPtr;
  AllocText := True;
end; { AllocText }

function AllocValue;
var
  CPtr : CellPtr;
begin
  AllocValue := False;
  GetMem(CPtr, SizeOf(Real) + 2);
  if CPtr = nil then
    Exit;
  CPtr^.Attrib := VALUE;
  CPtr^.Error := False;
  CPtr^.Value := Amt;
  Cell[Col, Row] := CPtr;
  AllocValue := True;
end; { AllocValue }

function AllocFormula;
var
  CPtr : CellPtr;
begin
  AllocFormula := False;
  GetMem(CPtr, Length(S) + SizeOf(Real) + 3);
  if CPtr = nil then
    Exit;
  CPtr^.Attrib := FORMULA;
  CPtr^.Error := False;
  CPtr^.Formula := S;
  CPtr^.FValue := Amt;
  Cell[Col, Row] := CPtr;
  AllocFormula := True;
end; { AllocFormula }

function RowWidth;
begin
  RowWidth := Succ(Trunc(Ln(Row) / Ln(10)));
end; { RowWidth }

function FormulaStart;
var
  OldPlace, Len, MaxLen : Word;
  Start : IString;
  NumString : String[10];
begin
  FormulaStart := False;
  OldPlace := Place;
  MaxLen := RowWidth(MAXROWS);
  if not (Input[Place] in LETTERS) then
    Exit;
  Col := Succ(Ord(Input[Place]) - Ord('A'));
  Inc(Place);
  if Input[Place] in LETTERS then
  begin
    Col := Col * 26;
    Col := Succ(Col + Ord(Input[Place]) - Ord('A'));
    Inc(Place);
  end;
  if Col > MAXCOLS then
    Exit;
  Start := Copy(Input, Place, MaxLen);
  Len := 0;
  while (Place <= Length(Input)) and
        (Input[Place] in ['0'..'9']) and (Len < MaxLen) do
  begin
    Inc(Len);
    Inc(Place);
  end;
  if Len = 0 then
    Exit;
  NumString := Copy(Start, 1, Len);
  Val(NumString, Row, Len);
  if Row > MAXROWS then
    Exit;
  FormLen := Place - OldPlace;
  FormulaStart := True;
end; { FormulaStart }

function ColString;
begin
  if Col <= 26 then
    ColString := Chr(Pred(Col) + Ord('A'))
  else
    ColString := Chr((Pred(Col) div 26) + Pred(Ord('A'))) +
              Chr((Pred(Col) mod 26) + Ord('A'));
end; { ColString }

function CenterColString;
var
  S : String[2];
  Spaces1, Spaces2 : Word;
begin
  S := ColString(Col);
  Spaces1 := (ColWidth[Col] - Length(S)) shr 1;
  Spaces2 := ColWidth[Col] - Length(S) - Spaces1;
  CenterColString := Spaces(Spaces1) + S + Spaces(Spaces2);
end; { CenterColString }

function TextString;
var
  OutString : String[80];
begin
  if ((FValue and RJUSTIFY) <> 0) and Formatting then
  begin
    OutString := InString;
    if Length(OutString) < ColWidth[Col] then
    begin
      while Length(OutString) < ColWidth[Col] do
        OutString := ' ' + OutString;
    end
    else
      OutString[0] := Chr(ColWidth[Col]);
  end
  else begin
    if Formatting then
      OutString := Pad(InString, ColWidth[Col])
    else
      OutString := InString;
  end;
  TextString := OutString;
end; { TextString }

function ValueString;
var
  VString : String[MAXCOLWIDTH];
  FString : String[3];
  Width, P : Word;
begin
  if Formatting then
  begin
    Str(CPtr^.Value:1:(FValue and 15), VString);
    if (FValue and COMMAS) <> 0 then
    begin
      P := Pos('.', VString);
      if P = 0 then
        P := Succ(Length(VString));
      while P > 4 do
      begin
        P := P - 3;
        if VString[Pred(P)] <> '-' then
          Insert(',', VString, P);
      end;
    end;
    if (FValue and DOLLAR) <> 0 then
    begin
      if VString[1] = '-' then
      begin
        FString := ' $';
        Width := ColWidth[Col] - 2;
      end
      else begin
        FString := ' $ ';
        Width := ColWidth[Col] - 3;
      end;
    end
    else begin
      Width := ColWidth[Col];
      FString := '';
    end;
    if (FValue and RJUSTIFY) <> 0 then
    begin
      if Length(VString) > Width then
        Delete(VString, Succ(Width), Length(VString) - Width)
      else begin
        while Length(VString) < Width do
          VString := ' ' + VString;
      end;
    end
    else
      VString := Pad(VString, Width);
    VString := FString + VString;
  end
  else
    Str(Value:1:MAXPLACES, VString);
  Color := VALUECOLOR;
  ValueString := VString;
end; { ValueString }

function CellString;
var
  CPtr : CellPtr;
  OldCol, P, NewCol, FormatValue : Word;
  S : String[80];
  V : Real;
begin
  CPtr := Cell[Col, Row];
  if CPtr = nil then
  begin
    if (not Formatting) or (Format[Col, Row] < OVERWRITE) then
    begin
      S := Spaces(ColWidth[Col]);
      Color := BLANKCOLOR;
    end
    else begin
      NewCol := Col;
      Dec(NewCol);
      while Cell[NewCol, Row] = nil do
        Dec(NewCol);
      OldCol := NewCol;
      P := 1;
      while (NewCol < Col) do
      begin
        Inc(P, ColWidth[NewCol]);
        Inc(NewCol);
      end;
      S := Copy(Cell[OldCol, Row]^.T, P, ColWidth[Col]);
      S := S + Spaces(ColWidth[Col] - Length(S));
      Color := TXTCOLOR;
    end;
  end
  else begin
    FormatValue := Format[Col, Row];
    if CPtr^.Error and (Formatting or (CPtr^.Attrib = VALUE)) then
    begin
      S := Pad(MSGERRORTXT, ColWidth[Col]);
      Color := ERRORCOLOR;
    end
    else begin
      case CPtr^.Attrib of
        TXT : begin
          S := TextString(CPtr^.T, Col, FormatValue, Formatting);
          Color := TXTCOLOR;
        end;
        FORMULA : begin
          if FormDisplay then
          begin
            S := TextString(CPtr^.Formula, Col, FormatValue, Formatting);
            Color := FORMULACOLOR;
          end
          else begin
            V := CPtr^.FValue;
            S := ValueString(CPtr, V, Col, FormatValue, Color, Formatting);
          end;
        end;
        VALUE : begin
          V := CPtr^.Value;
          S := ValueString(CPtr, V, Col, FormatValue, Color, Formatting);
        end;
      end; { case }
    end;
  end;
  CellString := S;
end; { CellString }

procedure Switch;
var
  Temp : Word;
begin
  Temp := Val1;
  Val1 := Val2;
  Val2 := Temp;
end; { Switch }

procedure InitVars;
begin
  LeftCol := 1;
  TopRow := 1;
  CurCol := 1;
  Currow := 1;
  LastCol := 1;
  LastRow := 1;
  AutoCalc := True;
  FormDisplay := False;
  FillChar(ColWidth, SizeOf(ColWidth), DEFAULTWIDTH);
  FillChar(Cell, SizeOf(Cell), 0);
  FillChar(Format, SizeOf(Format), DEFAULTFORMAT);
end; { InitVars }

function Exists;
var
  SR : SearchRec;
begin
  FindFirst(FileName, ReadOnly + Hidden + SysFile, SR);
  Exists := (DosError = 0) and (Pos('?', FileName) = 0) and
            (Pos('*', FileName) = 0);
end; { Exists }

begin
  HeapError := @HeapFunc;
end.
