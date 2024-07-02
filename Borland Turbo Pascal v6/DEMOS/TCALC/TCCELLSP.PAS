
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCCellSp;
{ Turbo Pascal 6.0 object-oriented example cell support routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$N+,S-}

interface

uses TCUtil, TCLStr, TCScreen, TCInput, TCCell;

function GetColumn(Prompt : String; MaxCols, ColSpace : Word) : Word;

function GetRow(Prompt : String; MaxRows : Word) : Word;

function GetCellPos(Prompt : String; MaxCols, MaxRows, ColSpace,
                    RowNumberSpace : Word; var P : CellPos) : Boolean;

function FormulaStart(Inp : LStringPtr; Start, MaxCols, MaxRows : Word;
                      var P : CellPos; var FormLen : Word) : Boolean;

procedure FixFormulaCol(CP : CellPtr; Diff : Longint;
                        MaxCols, MaxRows : Word);

procedure FixFormulaRow(CP : CellPtr; Diff : Longint;
                        MaxCols, MaxRows : Word);

implementation

function GetColumn(Prompt : String; MaxCols, ColSpace : Word) : Word;
{ Lets the user enter a column from the keyboard }
var
  I : InputField;
  S : String;
  C : Word;
begin
  with I do
  begin
    if not Init(Length(Prompt) + 3, 0, -1, ColSpace, AllUpper) then
    begin
      GetColumn := 0;
      Exit;
    end;
    WriteXY(Prompt + ': ', 1, Pred(Scr.CurrRows), Colors.PromptColor);
    repeat
      Edit(0);
      S := InputData^.ToString;
      if (not GetQuit) and (S <> '') then
      begin
        C := StringToCol(S, MaxCols);
        if C = 0 then
          Scr.PrintError(ErrColumnError1 + ColToString(1) +
                         ErrColumnError2 + ColToString(MaxCols));
      end
      else
        C := 0;
    until (C <> 0) or (S = '');
    InputArea.Clear;
    Done;
  end; { with }
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.BlankColor);
  GetColumn := C;
end; { GetColumn }

function GetRow(Prompt : String; MaxRows : Word) : Word;
{ Lets the user enter a row from the keyboard }
var
  R : Word;
  Good : Boolean;
begin
  R := GetNumber(Prompt, 1, MaxRows, Good);
  if Good then
    GetRow := R
  else
    GetRow := 0;
end; { GetRow }

function GetCellPos(Prompt : String; MaxCols, MaxRows, ColSpace,
                    RowNumberSpace : Word; var P : CellPos) : Boolean;
{ Lets the user enter a cell position from the keyboard }
var
  I : InputField;
  S : String;
  FormLen : Word;
begin
  GetCellPos := False;
  with I do
  begin
    if not Init(Length(Prompt) + 3, 0, -1, Pred(ColSpace + RowNumberSpace),
                AllUpper) then
      Exit;
    WriteXY(Prompt + ': ', 1, Pred(Scr.CurrRows), Colors.PromptColor);
    repeat
      Edit(0);
      S := InputData^.ToString;
      if (not GetQuit) and (S <> '') then
      begin
        if FormulaStart(InputData, 1, MaxCols, MaxRows, P, FormLen) then
          GetCellPos := True
        else
          Scr.PrintError(ErrCellError);
      end
      else
        FormLen := 0;
    until (FormLen <> 0) or (S = '');
    InputArea.Clear;
    Done;
  end; { with }
  ClrEOLXY(1, Pred(Scr.CurrRows), Colors.BlankColor);
end; { GetCellPos }

function FormulaStart(Inp : LStringPtr; Start, MaxCols, MaxRows : Word;
                      var P : CellPos; var FormLen : Word) : Boolean;
{ Checks to see if a place in a long string is the beginning of a formula }
var
  Col, Row : Word;
  CS : String[10];
  RS : String[10];
begin
  with Inp^ do
  begin
    FormulaStart := False;
    FormLen := 0;
    FillChar(P, SizeOf(P), 0);
    CS := '';
    while (Start <= Length) and (Data^[Start] in Letters) do
    begin
      CS := CS + Data^[Start];
      Inc(Start);
    end;
    Col := StringToCol(CS, MaxCols);
    if Col = 0 then
      Exit;
    RS := '';
    while (Start <= Length) and (Data^[Start] in Numbers) do
    begin
      RS := RS + Data^[Start];
      Inc(Start);
    end;
    Row := StringToRow(RS, MaxRows);
    if Row = 0 then
      Exit;
    P.Col := Col;
    P.Row := Row;
    FormLen := System.Length(CS) + System.Length(RS);
    FormulaStart := True;
  end; { with }
end; { FormulaStart }

procedure FixFormulaCol(CP : CellPtr; Diff : Longint;
                        MaxCols, MaxRows : Word);
{ Adjusts a formula for a new column }
var
  FormLen, Place, OldLen, NewLen : Word;
  P : CellPos;
  S : String[10];
  Good : Boolean;
begin
  with FormulaCellPtr(CP)^, GetFormula^ do
  begin
    Place := 1;
    Good := True;
    while Good and (Place <= Length) do
    begin
      if FormulaStart(GetFormula, Place, MaxCols, MaxRows, P, FormLen) then
      begin
        OldLen := System.Length(ColToString(P.Col));
        S := ColToString(Longint(P.Col) + Diff);
        NewLen := System.Length(S);
        if NewLen > OldLen then
          Good := Insert(FillString(NewLen - OldLen, ' '), Place)
        else if NewLen < OldLen then
          Delete(Place, OldLen - NewLen);
        if Good then
        begin
          Move(S[1], Data^[Place], System.Length(S));
          Inc(Place, FormLen + NewLen - OldLen);
        end;
      end
      else
        Inc(Place);
    end;
  end; { with }
end; { FixFormulaCol }

procedure FixFormulaRow(CP : CellPtr; Diff : Longint;
                        MaxCols, MaxRows : Word);
{ Adjusts a formula for a new row }
var
  ColLen, FormLen, Place, OldLen, NewLen : Word;
  P : CellPos;
  S : String[10];
  Good : Boolean;
begin
  with FormulaCellPtr(CP)^, GetFormula^ do
  begin
    Place := 1;
    Good := True;
    while Good and (Place <= Length) do
    begin
      if FormulaStart(GetFormula, Place, MaxCols, MaxRows, P, FormLen) then
      begin
        OldLen := System.Length(RowToString(P.Row));
        S := RowToString(P.Row + Diff);
        NewLen := System.Length(S);
        ColLen := System.Length(ColToString(P.Col));
        if NewLen > OldLen then
          Good := Insert(FillString(NewLen - OldLen, ' '), Place + ColLen)
        else if NewLen < OldLen then
          Delete(Place + ColLen, OldLen - NewLen);
        if Good then
        begin
          Move(S[1], Data^[Place + ColLen], System.Length(S));
          Inc(Place, FormLen + NewLen - OldLen);
        end;
      end
      else
        Inc(Place);
    end;
  end; { with }
end; { FixFormulaRow }

end.
