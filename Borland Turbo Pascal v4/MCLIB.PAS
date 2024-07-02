
{           Copyright (c) 1985, 87 by Borland International, Inc.            }

unit MCLIB;

interface

uses Crt, Dos, MCVars, MCUtil, MCDisply, MCParser;

procedure DisplayCell(Col, Row : Word; Highlighting, Updating : Boolean);
{ Displays the contents of a cell }

function SetOFlags(Col, Row : Word; Display : Boolean) : Word;
{ Sets the overwrite flag on cells starting at (col + 1, row) - returns
   the number of the column after the last column set.
}

procedure ClearOFlags(Col, Row : Word; Display : Boolean);
{ Clears the overwrite flag on cells starting at (col, row) }

procedure UpdateOFlags(Col, Row : Word; Display : Boolean);
{ Starting in col, moves back to the last TEXT cell and updates all flags }

procedure DeleteCell(Col, Row : Word; Display : Boolean);
{ Deletes a cell }

procedure SetLeftCol;
{ Sets the value of LeftCol based on the value of RightCol }

procedure SetRightCol;
{ Sets the value of rightcol based on the value of leftcol }

procedure SetTopRow;
{ Figures out the value of toprow based on the value of bottomrow }

procedure SetBottomRow;
{ Figures out the value of bottomrow based on the value of toprow }

procedure SetLastCol;
{ Sets the value of lastcol based on the current value }

procedure SetLastRow;
{ Sets the value of lastrow based on the current value }

procedure ClearLastCol;
{ Clears any data left in the last column }

procedure DisplayCol(Col : Word; Updating : Boolean);
{ Displays a column on the screen }

procedure DisplayRow(Row : Word; Updating : Boolean);
{ Displays a row on the screen }

procedure DisplayScreen(Updating : Boolean);
{ Displays the current screen of the spreadsheet }

procedure RedrawScreen;
{ Displays the entire screen }

procedure FixFormula(Col, Row, Action, Place : Word);
{ Modifies a formula when its column or row designations need to change }

procedure ChangeAutoCalc(NewMode : Boolean);
{ Changes and prints the current AutoCalc value on the screen }

procedure ChangeFormDisplay(NewMode : Boolean);
{ Changes and prints the current formula display value on the screen }

procedure Recalc;
{ Recalculates all of the numbers in the speadsheet }

procedure Act(S : String);
{ Acts on a particular input }

implementation

procedure DisplayCell;
var
  Color : Word;
  S : IString;
begin
  if Updating and
      ((Cell[Col, Row] = Nil) or (Cell[Col, Row]^.Attrib <> FORMULA)) then
    Exit;
  S := CellString(Col, Row, Color, DOFORMAT);
  if Highlighting then
  begin
    if Color = ERRORCOLOR then
      Color := HIGHLIGHTERRORCOLOR
    else
      Color := HIGHLIGHTCOLOR;
  end;
  SetColor(Color);
  WriteXY(S, ColStart[Succ(Col - LeftCol)], Row - TopRow + 3);
end; { DisplayCell }

function SetOFlags;
var
  Len : Integer;
begin
  Len := Length(Cell[Col, Row]^.T) - ColWidth[Col];
  Inc(Col);
  while (Col <= MAXCOLS) and (Len > 0) and (Cell[Col, Row] = nil) do
  begin
    Format[Col, Row] := Format[Col, Row] or OVERWRITE;
    Dec(Len, ColWidth[Col]);
    if Display and (Col >= LeftCol) and (Col <= RightCol) then
      DisplayCell(Col, Row, NOHIGHLIGHT, NOUPDATE);
    Inc(Col);
  end;
  SetOFlags := Col;
end; { SetOFlags }

procedure ClearOFlags;
begin
  while (Col <= MAXCOLS) and (Format[Col, Row] >= OVERWRITE) and
        (Cell[Col, Row] = nil) do
  begin
    Format[Col, Row] := Format[Col, Row] and (not OVERWRITE);
    if Display and (Col >= LeftCol) and (Col <= RightCol) then
      DisplayCell(Col, Row, NOHIGHLIGHT, NOUPDATE);
    Inc(Col);
  end;
end; { ClearOFlags }

procedure UpdateOFlags;
var
  Dummy : Word;
begin
  while (Cell[Col, Row] = nil) and (Col > 1) do
    Dec(Col);
  if (Cell[Col, Row]^.Attrib = TXT) and (Col >= 1) then
    Dummy := SetOFlags(Col, Row, Display);
end; { UpdateOFlags }

procedure DeleteCell;
var
  CPtr : CellPtr;
  Size : Word;
begin
  CPtr := Cell[Col, Row];
  if CPtr = nil then
    Exit;
  case CPtr^.Attrib of
    TXT : begin
      Size := Length(CPtr^.T) + 3;
      ClearOFlags(Succ(Col), Row, Display);
    end;
    VALUE : Size := SizeOf(Real) + 2;
    FORMULA : Size := SizeOf(Real) + Length(CPtr^.Formula) + 3;
  end; { case }
  Format[Col, Row] := Format[Col, Row] and (not OVERWRITE);
  FreeMem(CPtr, Size);
  Cell[Col, Row] := nil;
  if Col = LastCol then
    SetLastCol;
  if Row = LastRow then
    SetLastRow;
  UpdateOFlags(Col, Row, Display);
  Changed := True;
end; { DeleteCell }

procedure SetLeftCol;
var
  Col : Word;
  Total : Integer;
begin
  Total := 81;
  Col := 0;
  while (Total > LEFTMARGIN) and (RightCol - Col > 0) do
  begin
    Dec(Total, ColWidth[RightCol - Col]);
    if Total > LEFTMARGIN then
      ColStart[SCREENCOLS - Col] := Total;
    Inc(Col);
  end;
  if Total > LEFTMARGIN then
    Inc(Col);
  Move(ColStart[SCREENCOLS - Col + 2], ColStart, Pred(Col));
  LeftCol := RightCol - Col + 2;
  Total := Pred(ColStart[1] - LEFTMARGIN);
  if Total <> 0 then
  begin
    for Col := LeftCol to RightCol do
      Dec(ColStart[Succ(Col - LeftCol)], Total);
  end;
  PrintCol;
end; { SetLeftCol }

procedure SetRightCol;
var
  Total, Col : Word;
begin
  Total := Succ(LEFTMARGIN);
  Col := 1;
  repeat
  begin
    ColStart[Col] := Total;
    Inc(Total, ColWidth[Pred(LeftCol + Col)]);
    Inc(Col);
  end;
  until (Total > 81) or (Pred(LeftCol + Col) > MAXCOLS);
  if Total > 81 then
    Dec(Col);
  RightCol := LeftCol + Col - 2;
  PrintCol;
end; { SetRightCol }

procedure SetTopRow;
begin
  if BottomRow < ScreenRows then
    BottomRow := ScreenRows;
  TopRow := Succ(BottomRow - ScreenRows);
  PrintRow;
end; { SetTopRow }

procedure SetBottomRow;
begin
  if TopRow + ScreenRows > Succ(MAXROWS) then
    TopRow := Succ(MAXROWS - ScreenRows);
  BottomRow := Pred(TopRow + ScreenRows);
  PrintRow;
end; { SetBottomRow }

procedure SetLastCol;
var
  Row, Col : Word;
begin
  for Col := LastCol downto 1 do
  begin
    for Row := 1 to LastRow do
    begin
      if Cell[Col, Row] <> nil then
      begin
        LastCol := Col;
        Exit;
      end;
    end;
  end;
  LastCol := 1;
end; { SetLastCol }

procedure SetLastRow;
var
  Row, Col : Word;
begin
  for Row := LastRow downto 1 do
  begin
    for Col := 1 to LastCol do
    begin
      if Cell[Col, Row] <> nil then
      begin
        LastRow := Row;
        Exit;
      end;
    end;
  end;
  LastRow := 1;
end; { SetLastRow }

procedure ClearLastCol;
var
  Col : Word;
begin
  Col := ColStart[Succ(RightCol - LeftCol)] + ColWidth[RightCol];
  if (Col < 80) then
    Scroll(UP, 0, Col, 3, 80, ScreenRows + 2, White);
end; { ClearLastCol }

procedure DisplayCol;
var
  Row : Word;
begin
  for Row := TopRow to BottomRow do
    DisplayCell(Col, Row, NOHIGHLIGHT, Updating);
end; { DisplayCol }

procedure DisplayRow;
var
  Col : Word;
begin
  for Col := LeftCol to RightCol do
    DisplayCell(Col, Row, NOHIGHLIGHT, Updating);
end; { DisplayRow }

procedure DisplayScreen;
var
  Row : Word;
begin
  for Row := TopRow to BottomRow do
    DisplayRow(Row, Updating);
  ClearLastCol;
end; { DisplayScreen }

procedure RedrawScreen;
begin
  CurRow := 1;
  CurCol := 1;
  LeftCol := 1;
  TopRow := 1;
  SetRightCol;
  SetBottomRow;
  GotoXY(1, 1);
  SetColor(MSGMEMORYCOLOR);
  Write(MSGMEMORY);
  GotoXY(29, 1);
  SetColor(PROMPTCOLOR);
  Write(MSGCOMMAND);
  ChangeAutocalc(Autocalc);
  ChangeFormDisplay(FormDisplay);
  PrintFreeMem;
  DisplayScreen(NOUPDATE);
end; { RedrawScreen }

procedure FixFormula;
var
  FormLen, ColStart, RowStart, CurPos, FCol, FRow : Word;
  CPtr : CellPtr;
  Value : Real;
  S : String[5];
  NewFormula : IString;
  Good : Boolean;
begin
  CPtr := Cell[Col, Row];
  CurPos := 1;
  NewFormula := CPtr^.Formula;
  while CurPos < Length(NewFormula) do
  begin
    if FormulaStart(NewFormula, CurPos, FCol, FRow, FormLen) then
    begin
      if FCol > 26 then
      begin
        RowStart := CurPos + 2;
        ColStart := RowStart - 2;
      end
      else begin
        RowStart := Succ(CurPos);
        ColStart := Pred(RowStart);
      end;
      case Action of
        COLADD : begin
          if FCol >= Place then
          begin
            if FCol = 26 then
            begin
              if Length(NewFormula) = MAXINPUT then
              begin
                DeleteCell(Col, Row, NOUPDATE);
                Good := AllocText(Col, Row, NewFormula);
                Exit;
              end;
            end;
            S := ColString(FCol);
            Delete(NewFormula, ColStart, Length(S));
            S := ColString(Succ(FCol));
            Insert(S, NewFormula, ColStart);
          end;
        end;
        ROWADD : begin
          if FRow >= Place then
          begin
            if RowWidth(Succ(FRow)) <> RowWidth(FRow) then
            begin
              if Length(NewFormula) = MAXINPUT then
              begin
                DeleteCell(Col, Row, NOUPDATE);
                Good := AllocText(Col, Row, NewFormula);
                Exit;
              end;
            end;
            S := WordToString(FRow, 1);
            Delete(NewFormula, RowStart, Length(S));
            S := WordToString(Succ(FRow), 1);
            Insert(S, NewFormula, RowStart);
          end;
        end;
        COLDEL : begin
          if FCol > Place then
          begin
            S := ColString(FCol);
            Delete(NewFormula, ColStart, Length(S));
            S := ColString(Pred(FCol));
            Insert(S, NewFormula, ColStart);
          end;
        end;
        ROWDEL : begin
          if FRow > Place then
          begin
            S := WordToString(FRow, 1);
            Delete(NewFormula, RowStart, Length(S));
            S := WordToString(Pred(FRow), 1);
            Insert(S, NewFormula, RowStart);
          end;
        end;
      end; { case }
      Inc(CurPos, FormLen);
    end
    else
      Inc(CurPos);
  end;
  if Length(NewFormula) <> Length(CPtr^.Formula) then
  begin
    Value := CPtr^.FValue;
    DeleteCell(Col, Row, NOUPDATE);
    Good := AllocFormula(Col, Row, NewFormula, Value);
  end
  else
    CPtr^.Formula := NewFormula;
end; { FixFormula }

procedure ChangeAutoCalc;
var
  S : String[15];
begin
  if (not AutoCalc) and NewMode then
    Recalc;
  AutoCalc := NewMode;
  if AutoCalc then
    S := MSGAUTOCALC
  else
    S := '';
  SetColor(MSGAUTOCALCCOLOR);
  GotoXY(73, 1);
  Write(S:Length(MSGAUTOCALC));
end; { ChangeAutoCalc }

procedure ChangeFormDisplay;
var
  S : String[15];
begin
  FormDisplay := NewMode;
  if FormDisplay then
    S := MSGFORMDISPLAY
  else
    S := '';
  SetColor(MSGFORMDISPLAYCOLOR);
  GotoXY(65, 1);
  Write(S:Length(MSGFORMDISPLAY));
end; { ChangeFormDisplay }

procedure Recalc;
var
  Col, Row, Attrib : Word;
begin
  for Col := 1 to LastCol do
  begin
    for Row := 1 to LastRow do
    begin
      if ((Cell[Col, Row] <> nil) and (Cell[Col, Row]^.Attrib = FORMULA)) then
      begin
        Cell[Col, Row]^.FValue := Parse(Cell[Col, Row]^.Formula, Attrib);
        Cell[Col, Row]^.Error := Attrib >= 4;
      end;
    end;
  end;
  DisplayScreen(UPDATE);
end; { Recalc }

procedure Act;
var
  Attrib, Dummy : Word;
  Allocated : Boolean;
  V : Real;
begin
  DeleteCell(CurCol, CurRow, UPDATE);
  V := Parse(S, Attrib);
  case (Attrib and 3) of
    TXT : begin
      Allocated := AllocText(CurCol, CurRow, S);
      if Allocated then
        DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
    end;
    VALUE : Allocated := AllocValue(CurCol, CurRow, V);
    FORMULA : Allocated := AllocFormula(CurCol, CurRow, UpperCase(S), V);
  end; { case }
  if Allocated then
  begin
    if Attrib >= 4 then
    begin
      Cell[CurCol, CurRow]^.Error := True;
      Dec(Attrib, 4);
    end
    else
      Cell[CurCol, CurRow]^.Error := False;
    Format[CurCol, CurRow] := Format[CurCol, CurRow] and (not OVERWRITE);
    ClearOFlags(Succ(CurCol), CurRow, UPDATE);
    if Attrib = TXT then
      Dummy := SetOFlags(CurCol, CurRow, UPDATE);
    if CurCol > LastCol then
      LastCol := CurCol;
    if CurRow > LastRow then
      LastRow := CurRow;
    if AutoCalc then
      Recalc;
  end
  else
    ErrorMsg(MSGLOMEM);
  PrintFreeMem;
end; { Act }

begin
end.
