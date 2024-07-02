
{           Copyright (c) 1985, 87 by Borland International, Inc.            }

unit MCOMMAND;

interface

uses Crt, Dos, MCVars, MCUtil, MCDisply, MCParser, MCLib, MCInput;

procedure CheckForSave;
{ If the spreadsheet has been changed, will ask the user if they want to
   save it.
}

procedure MoveRowUp;
{ Moves up 1 row }

procedure MoveRowDown;
{ Moves down one row }

procedure MoveColLeft;
{ Moves left one column }

procedure MoveColRight;
{ Moves right one column }

procedure EditCell(ECell : CellPtr);
{ Edits a selected cell }

procedure ClearSheet;
{ Clears the current spreadsheet }

procedure LoadSheet(FileName : IString);
{ Loads a new spreadsheet }

procedure SaveSheet;
{ Saves the current spreadsheet }

function PageRows(Row : Word; TopPage, Border : Boolean) : Word;
{ Returns the number of rows to print }

function PageCols(Col, Columns : Word; Border : Boolean) : Word;
{ Returns the number of columns to print starting at col }

procedure PrintSheet;
{ Prints a copy of the spreadsheet to a file or to the printer }

procedure SetColWidth(Col : Word);
{ Sets the new column width for a selected column }

procedure GotoCell;
{ Moves to a selected cell }

procedure FormatCells;
{ Prompts the user for a selected format and range of cells }

procedure DeleteCol(Col : Word);
{ Deletes a column }

procedure InsertCol(Col : Word);
{ Inserts a column }

procedure DeleteRow(Row : Word);
{ Deletes a row }

procedure InsertRow(Row : Word);
{ Inserts a row }

procedure SMenu;
{ Executes the commands in the spreadsheet menu }

procedure CMenu;
{ Executes the commands in the column menu }

procedure RMenu;
{ Executes the commands in the row menu }

procedure UMenu;
{ Executes the commands in the utility menu }

procedure MainMenu;
{ Executes the commands in the main menu }

implementation

const
  Name : String[80] = MSGNAME;

var
  Rec : CellRec;

procedure CheckForSave;
var
  Save : Char;
begin
  if Changed and GetYesNo(Save, MSGSAVESHEET) and (Save = 'Y') then
    SaveSheet;
end; { CheckForSave }

procedure MoveRowUp;
begin
  DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
  if CurRow > TopRow then
    Dec(CurRow)
  else if TopRow > 1 then
  begin
    Scroll(DOWN, 1, Succ(LEFTMARGIN), 3, 80, ScreenRows + 2, WHITE);
    Dec(TopRow);
    DisplayRow(TopRow, NOUPDATE);
    Dec(CurRow);
    SetBottomRow;
  end;
end; { MoveRowUp }

procedure MoveRowDown;
begin
  DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
  if CurRow < BottomRow then
    Inc(CurRow)
  else if BottomRow < MAXROWS then
  begin
    Scroll(UP, 1, Succ(LEFTMARGIN), 3, 80, ScreenRows + 2, WHITE);
    Inc(TopRow);
    Inc(CurRow);
    SetBottomRow;
    DisplayRow(BottomRow, NOUPDATE);
  end;
end; { MoveRowDown }

procedure MoveColLeft;
var
  Col, OldLeftCol : Word;
  OldColStart : array[1..SCREENCOLS] of Byte;
begin
  OldLeftCol := LeftCol;
  Move(ColStart, OldColStart, Sizeof(ColStart));
  DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
  if (CurCol > LeftCol) then
    Dec(CurCol)
  else if (LeftCol <> 1) then
  begin
    Dec(CurCol);
    Dec(LeftCol);
    SetRightCol;
    SetLeftCol;
    if OldLeftCol <= RightCol then
      Scroll(RIGHT, Pred(ColStart[Succ(OldLeftCol - LeftCol)] - LEFTMARGIN),
             Succ(LEFTMARGIN), 3, 80, ScreenRows + 2, WHITE);
    ClearLastCol;
    for Col := LeftCol to Pred(OldLeftCol) do
      DisplayCol(Col, NOUPDATE);
  end;
end; { MoveColLeft }

procedure MoveColRight;
var
  Col, OldLeftCol, OldRightCol : Word;
  OldColStart : array[1..SCREENCOLS] of Byte;
begin
  OldLeftCol := LeftCol;
  Move(ColStart, OldColStart, Sizeof(ColStart));
  OldRightCol := RightCol;
  DisplayCell(CurCol, CurRow, NOHIGHLIGHT, NOUPDATE);
  if CurCol < RightCol then
    Inc(CurCol)
  else if RightCol < MAXCOLS then
  begin
    Inc(CurCol);
    Inc(RightCol);
    SetLeftCol;
    SetRightCol;
    if OldRightCol >= LeftCol then
      Scroll(LEFT, Pred(OldColStart[Succ(LeftCol - OldLeftCol)] - LEFTMARGIN),
             Succ(LEFTMARGIN), 3, 80, ScreenRows + 2, WHITE);
    ClearLastCol;
    for Col := Succ(OldRightCol) to RightCol do
      DisplayCol(Col, NOUPDATE);
  end;
end; { MoveColRight }

procedure EditCell;
var
  S : IString;
begin
  if ECell = nil then
    Exit;
  case ECell^.Attrib of
    TXT : S := ECell^.T;
    VALUE : Str(ECell^.Value:1:MAXPLACES, S);
    FORMULA : S := ECell^.Formula;
  end; { case }
  if (not EditString(S, '', MAXINPUT)) or (S = '') then
    Exit;
  Act(S);
  Changed := True;
end; { EditCell }

procedure ClearSheet;
var
  Col, Row : Word;
begin
  for Row := 1 to LastRow do
  begin
    for Col := 1 to LastCol do
      DeleteCell(Col, Row, NOUPDATE);
  end;
  InitVars;
  SetRightCol;
  SetBottomRow;
  DisplayScreen(NOUPDATE);
  PrintFreeMem;
  Changed := False;
end; { ClearSheet }

procedure LoadSheet;
var
  Dummy, Size, RealLastCol, RealLastRow : Word;
  F : File;
  Check : String[80];
  Allocated : Boolean;
  Blocks : Word;
  RealSize : Byte;
begin
  RealLastCol := 1;
  RealLastRow := 1;
  if FileName = '' then
  begin
    WritePrompt(MSGFILENAME);
    if not EditString(FileName, '', MAXINPUT) then
      Exit;
  end;
  if not Exists(FileName) then
  begin
    ErrorMsg(MSGNOEXIST);
    Exit;
  end;
  Assign(F, FileName);
  Reset(F, 1);
  if IOResult <> 0 then
  begin
    ErrorMsg(MSGNOOPEN);
    Exit;
  end;
  BlockRead(F, Check[1], Length(Name), Blocks);
  Check[0] := Chr(Length(Name));
  if Check <> Name then
  begin
    ErrorMsg(MSGNOMICROCALC);
    Close(F);
    Exit;
  end;
  BlockRead(F, Size, 1, Blocks);
  BlockRead(F, RealSize, 1, Blocks);
  if RealSize <> SizeOf(Real) then
  begin
    ErrorMsg(MSGBADREALS);
    Close(F);
    Exit;
  end;
  SetColor(PROMPTCOLOR);
  GotoXY(1, ScreenRows + 5);
  Write(MSGLOADING);
  GotoXY(Succ(Length(MSGLOADING)), ScreenRows + 5);
  ClearSheet;
  BlockRead(F, LastCol, SizeOf(LastCol), Blocks);
  BlockRead(F, LastRow, SizeOf(LastRow), Blocks);
  BlockRead(F, Size, SizeOf(Size), Blocks);
  BlockRead(F, ColWidth, Sizeof(ColWidth), Blocks);
  repeat
    BlockRead(F, CurCol, SizeOf(CurCol), Blocks);
    BlockRead(F, CurRow, SizeOf(CurRow), Blocks);
    BlockRead(F, Format[CurCol, CurRow], 1, Blocks);
    BlockRead(F, Size, SizeOf(Size), Blocks);
    BlockRead(F, Rec, Size, Blocks);
    case Rec.Attrib of
      TXT : begin
        Allocated := AllocText(CurCol, CurRow, Rec.T);
        if Allocated then
          Dummy := SetOFlags(CurCol, CurRow, NOUPDATE);
      end;
      VALUE : Allocated := AllocValue(CurCol, CurRow, Rec.Value);
      FORMULA : Allocated := AllocFormula(CurCol, CurRow, Rec.Formula,
                                          Rec.Fvalue);
    end; { case }
    if not Allocated then
    begin
      ErrorMsg(MSGFILELOMEM);
      LastRow := RealLastRow;
      LastCol := RealLastCol;
      Format[CurCol, CurRow] := DEFAULTFORMAT;
    end
    else begin
      Cell[CurCol, CurRow]^.Error := Rec.Error;
      if CurCol > RealLastCol then
        RealLastCol := CurCol;
      if CurRow > RealLastRow then
        RealLastRow := CurRow;
    end;
  until (not Allocated) or (EOF(F));
  PrintFreeMem;
  Close(F);
  CurCol := 1;
  CurRow := 1;
  SetRightCol;
  DisplayScreen(NOUPDATE);
  SetColor(White);
  GotoXY(1, ScreenRows + 5);
  ClrEol;
  Changed := False;
end; { LoadSheet }

procedure SaveSheet;
var
  FileName : IString;
  EndOfFile, Overwrite : Char;
  Size, Col, Row : Word;
  F : File;
  CPtr : CellPtr;
  Blocks : Word;
  RealSize : Byte;
begin
  EndOfFile := #26;
  FileName := '';
  RealSize := SizeOf(Real);
  WritePrompt(MSGFILENAME);
  if not EditString(FileName, '', MAXINPUT) then
    Exit;
  Assign(F, FileName);
  if Exists(FileName) then
  begin
    if (not GetYesNo(Overwrite, MSGOVERWRITE)) or (Overwrite = 'N') then
      Exit;
    Reset(F, 1);
  end
  else
    Rewrite(F, 1);
  if IOResult <> 0 then
  begin
    ErrorMsg(MSGNOOPEN);
    Exit;
  end;
  SetColor(PROMPTCOLOR);
  GotoXY(1, ScreenRows + 5);
  Write(MSGSAVING);
  GotoXY(Length(MSGSAVING) + 1, ScreenRows + 5);
  BlockWrite(F, Name[1], Length(Name), Blocks);
  BlockWrite(F, EndOfFile, 1, Blocks);
  BlockWrite(F, RealSize, 1, Blocks);
  BlockWrite(F, LastCol, SizeOf(LastCol), Blocks);
  BlockWrite(F, LastRow, SizeOf(LastRow), Blocks);
  Size := MAXCOLS;
  BlockWrite(F, Size, SizeOf(Size), Blocks);
  BlockWrite(F, ColWidth, Sizeof(ColWidth), Blocks);
  for Row := 1 to LastRow do
  begin
    for Col := LastCol downto 1 do
    begin
      if Cell[Col, Row] <> nil then
      begin
        CPtr := Cell[Col, Row];
        case CPtr^.Attrib of
          TXT : Size := Length(CPtr^.T) + 3;
          VALUE : Size := Sizeof(Real) + 2;
          FORMULA : Size := Length(CPtr^.Formula) + Sizeof(Real) + 3;
        end; { case }
        BlockWrite(F, Col, SizeOf(Col), Blocks);
        BlockWrite(F, Row, SizeOf(Row), Blocks);
        BlockWrite(F, Format[Col, Row], 1, Blocks);
        BlockWrite(F, Size, SizeOf(Size), Blocks);
        BlockWrite(F, CPtr^, Size, Blocks);
      end;
    end;
  end;
  Close(F);
  SetColor(White);
  GotoXY(1, ScreenRows + 5);
  ClrEol;
  Changed := False;
end; { SaveSheet }

function PageRows;
var
  Rows : Word;
begin
  if TopPage then
    Rows := 66 - TOPMARGIN
  else
    Rows := 66;
  if Border then
    Dec(Rows);
  if Pred(Row + Rows) > LastRow then
    PageRows := Succ(LastRow - Row)
  else
    PageRows := Rows;
end; { PageRows }

function PageCols;
var
  Len : Integer;
  FirstCol : Word;
begin
  if (Col = 1) and Border then
    Len := Columns - LEFTMARGIN
  else
    Len := Columns;
  FirstCol := Col;
  while (Len > 0) and (Col <= LastCol) do
  begin
    Dec(Len, ColWidth[Col]);
    Inc(Col);
  end;
  if Len < 0 then
    Dec(Col);
  PageCols := Col - FirstCol;
end; { PageCols }

procedure PrintSheet;
var
  FileName : IString;
  S : String[132];
  ColStr : String[MAXCOLWIDTH];
  F : Text;
  Columns, Counter1, Counter2, Counter3, Col, Row, LCol, LRow, Dummy,
    Printed, OldLastCol : Word;
  Answer : Char;
  Border, TopPage : Boolean;
begin
  Col := 1;
  WritePrompt(MSGPRINT);
  FileName := '';
  if not EditString(FileName, '', MAXINPUT) then
    Exit;
  if FileName = '' then
    FileName := 'PRN';
  Assign(F, FileName);
{$I-}
  Rewrite(F);
  if IOResult <> 0 then
  begin
    ErrorMsg(MSGNOOPEN);
    Exit;
  end;
{$I+}
  OldLastCol := LastCol;
  for Counter1 := 1 to LastRow do
  begin
    for Counter2 := LastCol to MAXCOLS do
    begin
      if Format[Counter2, Counter1] >= OVERWRITE then
        LastCol := Counter2;
    end;
  end;
  if not GetYesNo(Answer, MSGCOLUMNS) then
    Exit;
  if Answer = 'Y' then
    Columns := 132
  else
    Columns := 80;
  if not GetYesNo(Answer, MSGBORDER) then
    Exit;
  Border := Answer = 'Y';
  while Col <= LastCol do
  begin
    Row := 1;
    TopPage := True;
    LCol := PageCols(Col, Columns, Border) + Col;
    while Row <= LastRow do
    begin
      LRow := PageRows(Row, TopPage, Border) + Row;
      Printed := 0;
      if TopPage then
      begin
        for Counter1 := 1 to TOPMARGIN do
        begin
          Writeln(F);
          Inc(Printed);
        end;
      end;
      for Counter1 := Row to Pred(LRow) do
      begin
        if Border and (Counter1 = Row) and (TopPage) then
        begin
          if (Col = 1) and Border then
          begin
            S[0] := Chr(LEFTMARGIN);
            FillChar(S[1], LEFTMARGIN, ' ');
          end
          else
            S := '';
          for Counter3 := Col to Pred(LCol) do
          begin
            ColStr := CenterColString(Counter3);
            S := S + ColStr;
          end;
          Writeln(F, S);
          Printed := Succ(Printed);
        end;
        if (Col = 1) and Border then
          S := Pad(WordToString(Counter1, 1), LEFTMARGIN)
        else
          S := '';
        for Counter2 := Col to Pred(LCol) do
          S := S + CellString(Counter2, Counter1, Dummy, DOFORMAT);
        Writeln(F, S);
        Inc(Printed);
      end;
      Row := LRow;
      TopPage := False;
      if Printed < 66 then
        Write(F, FORMFEED);
    end;
    Col := LCol;
  end;
  Close(F);
  LastCol := OldLastCol;
end; { PrintSheet }

procedure SetColWidth;
var
  Width, Row : Word;
begin
  WritePrompt(MSGCOLWIDTH);
  if not GetWord(Width, MINCOLWIDTH, MAXCOLWIDTH) then
    Exit;
  ColWidth[Col] := Width;
  SetRightCol;
  if RightCol < Col then
  begin
    RightCol := Col;
    SetLeftCol;
    SetRightCol;
  end;
  for Row := 1 to LastRow do
  begin
    if (Cell[Col, Row] <> nil) and (Cell[Col, Row]^.Attrib = TXT) then
      ClearOFlags(Succ(Col), Row, NOUPDATE)
    else
      ClearOFlags(Col, Row, NOUPDATE);
    UpdateOFlags(Col, Row, NOUPDATE);
  end;
  DisplayScreen(NOUPDATE);
  Changed := True;
end; { SetColWidth }

procedure GotoCell;
begin
  WritePrompt(MSGGOTO);
  if not GetCell(CurCol, CurRow) then
    Exit;
  LeftCol := CurCol;
  TopRow := CurRow;
  SetBottomRow;
  SetRightCol;
  SetLeftCol;
  DisplayScreen(NOUPDATE);
end; { GotoCell }

procedure FormatCells;
var
  Col, Row, Col1, Col2, Row1, Row2, NewFormat, ITemp : Word;
  Temp : Char;
begin
  NewFormat := 0;
  WritePrompt(MSGCELL1);
  if not GetCell(Col1, Row1) then
    Exit;
  WritePrompt(MSGCELL2);
  if not GetCell(Col2, Row2) then
    Exit;
  if (Col1 <> Col2) and (Row1 <> Row2) then
    ErrorMsg(MSGDIFFCOLROW)
  else begin
    if Col1 > Col2 then
      Switch(Col1, Col2);
    if Row1 > Row2 then
      Switch(Row1, Row2);
    if not GetYesNo(Temp, MSGRIGHTJUST) then
      Exit;
    NewFormat := NewFormat + (Ord(Temp = 'Y') * RJUSTIFY);
    if not GetYesNo(Temp, MSGDOLLAR) then
      Exit;
    NewFormat := NewFormat + (Ord(Temp = 'Y') * DOLLAR);
    if not GetYesNo(Temp, MSGCOMMAS) then
      Exit;
    NewFormat := NewFormat + (Ord(Temp = 'Y') * COMMAS);
    if (NewFormat and DOLLAR) <> 0 then
      NewFormat := NewFormat + 2
    else begin
      WritePrompt(MSGPLACES);
      if not GetWord(ITemp, 0, MAXPLACES) then
        Exit;
      NewFormat := NewFormat + ITemp;
    end;
    for Col := Col1 to Col2 do
    begin
      for Row := Row1 to Row2 do
      begin
        Format[Col, Row] := (Format[Col, Row] and OVERWRITE) or NewFormat;
        if (Col >= LeftCol) and (Col <= RightCol) and
           (Row >= TopRow) and (Row <= BottomRow) then
        DisplayCell(Col, Row, NOHIGHLIGHT, NOUPDATE);
      end;
    end;
  end;
  Changed := True;
end; { FormatCells }

procedure DeleteCol;
var
  OldLastCol, Counter, Row : Word;
begin
  if Col > LastCol then
    Exit;
  OldLastCol := LastCol;
  for Counter := 1 to LastRow do
    DeleteCell(Col, Counter, NOUPDATE);
  PrintFreeMem;
  if Col <> OldLastCol then
  begin
    Move(Cell[Succ(Col), 1], Cell[Col, 1], MAXROWS * Sizeof(CellPtr) *
         (OldLastCol - Col));
    Move(Format[Succ(Col), 1], Format[Col, 1], MAXROWS * (OldLastCol - Col));
    Move(ColWidth[Succ(Col)], ColWidth[Col], OldLastCol - Col);
  end;
  FillChar(Cell[OldLastCol, 1], MAXROWS * Sizeof(CellPtr), 0);
  FillChar(Format[OldLastCol, 1], MAXROWS, DEFAULTFORMAT);
  ColWidth[OldLastCol] := DEFAULTWIDTH;
  SetRightCol;
  if CurCol > RightCol then
  begin
    Inc(RightCol);
    SetLeftCol;
  end;
  ClearLastCol;
  if OldLastCol = LastCol then
    Dec(LastCol);
  for Counter := 1 to LastCol do
  begin
    for Row := 1 to LastRow do
    begin
      if (Cell[Counter, Row] <> nil) and
         (Cell[Counter, Row]^.Attrib = FORMULA) then
        FixFormula(Counter, Row, COLDEL, Col);
      UpdateOFlags(Col, Row, NOUPDATE);
    end;
  end;
  for Counter := Col to RightCol do
    DisplayCol(Counter, NOUPDATE);
  LastCol := MAXCOLS;
  SetLastCol;
  Changed := True;
  Recalc;
end; { DeleteCol }

procedure InsertCol;
var
  Counter, Row : Word;
begin
  if (LastCol = MAXCOLS) or (Col > LastCol) then
    Exit;
  if Col <> LastCol then
  begin
    Move(Cell[Col, 1], Cell[Col + 1, 1], MAXROWS * Sizeof(CellPtr) *
           Succ(LastCol - Col));
    Move(Format[Col, 1], Format[Col + 1, 1], MAXROWS * Succ(LastCol - Col));
    Move(ColWidth[Col], ColWidth[Col + 1], Succ(LastCol - Col));
  end;
  if LastCol < MAXCOLS then
    Inc(LastCol);
  FillChar(Cell[Col, 1], MAXROWS * Sizeof(CellPtr), 0);
  FillChar(Format[Col, 1], MAXROWS, DEFAULTFORMAT);
  ColWidth[Col] := DEFAULTWIDTH;
  SetRightCol;
  if CurCol > RightCol then
  begin
    Inc(RightCol);
    SetLeftCol;
  end;
  for Counter := 1 to LastCol do
  begin
    for Row := 1 to LastRow do
    begin
      if (Cell[Counter, Row] <> nil) and
         (Cell[Counter, Row]^.Attrib = FORMULA) then
        FixFormula(Counter, Row, COLADD, Col);
      UpdateOFlags(Col, Row, NOUPDATE);
    end;
  end;
  for Counter := Col to RightCol do
    DisplayCol(Counter, NOUPDATE);
  LastCol := MAXCOLS;
  SetLastCol;
  Changed := True;
  Recalc;
end; { InsertCol }

procedure DeleteRow;
var
  OldLastRow, Counter, RowC : Word;
begin
  if Row > LastRow then
    Exit;
  OldLastRow := LastRow;
  for Counter := 1 to LastCol do
    DeleteCell(Counter, Row, NOUPDATE);
  PrintFreeMem;
  if Row <> OldLastRow then
  begin
    for Counter := 1 to MAXCOLS do
    begin
      Move(Cell[Counter, Succ(Row)], Cell[Counter, Row],
           Sizeof(CellPtr) * (OldLastRow - Row));
      Move(Format[Counter, Succ(Row)], Format[Counter, Row],
           OldLastRow - Row);
    end;
  end;
  for Counter := 1 to LastCol do
  begin
    Cell[Counter, OldLastRow] := nil;
    Format[Counter, OldLastRow] := DEFAULTFORMAT;
  end;
  if OldLastRow = LastRow then
    Dec(LastRow);
  for Counter := 1 to LastCol do
  begin
    for RowC := 1 to LastRow do
    begin
      if (Cell[Counter, RowC] <> nil) and
         (Cell[Counter, RowC]^.Attrib = FORMULA) then
        FixFormula(Counter, RowC, ROWDEL, Row);
    end;
  end;
  for Counter := Row to BottomRow do
    DisplayRow(Counter, NOUPDATE);
  LastRow := MAXROWS;
  SetLastRow;
  Changed := True;
  Recalc;
end; { DeleteRow }

procedure InsertRow;
var
  Counter, RowC : Word;
begin
  if (LastRow = MAXROWS) or (Row > LastRow) then
    Exit;
  if Row <> LastRow then
  begin
    for Counter := 1 to MAXCOLS do
    begin
      Move(Cell[Counter, Row], Cell[Counter, Succ(Row)],
           Sizeof(CellPtr) * Succ(LastRow - Row));
      Move(Format[Counter, Row], Format[Counter, Succ(Row)],
           Succ(LastRow - Row));
    end;
  end;
  Inc(LastRow);
  for Counter := 1 to LastCol do
  begin
    Cell[Counter, Row] := nil;
    Format[Counter, Row] := DEFAULTFORMAT;
  end;
  for Counter := 1 to LastCol do
  begin
    for RowC := 1 to LastRow do
    begin
      if (Cell[Counter, RowC] <> nil) and
         (Cell[Counter, RowC]^.Attrib = FORMULA) then
        FixFormula(Counter, RowC, ROWADD, Row);
    end;
  end;
  for Counter := Row to BottomRow do
    DisplayRow(Counter, NOUPDATE);
  LastRow := MAXROWS;
  SetLastRow;
  Changed := True;
  Recalc;
end; { InsertRow }

procedure SMenu;
var
  FileName : IString;
  X : Word;
begin
  FileName := '';
  case GetCommand(SMNU, SCOMMAND) of
    1 : begin
      CheckForSave;
      LoadSheet(FileName);
    end;
    2 : SaveSheet;
    3 : PrintSheet;
    4 : begin
      CheckForSave;
      ClearSheet;
    end;
  end; { case }
end; { SMenu }

procedure CMenu;
begin
  case GetCommand(CMNU, CCOMMAND) of
    1 : InsertCol(CurCol);
    2 : DeleteCol(CurCol);
    3 : SetColWidth(CurCol);
  end; { case }
end; { CMenu }

procedure RMenu;
begin
  case GetCommand(RMNU, RCOMMAND) of
    1 : InsertRow(CurRow);
    2 : DeleteRow(CurRow);
  end; { case }
end; { CMenu }

procedure UMenu;
begin
  case GetCommand(UMenuString, UCommandString) of
    1 : Recalc;
    2 : begin
      ChangeFormDisplay(not FormDisplay);
      DisplayScreen(UPDATE);
    end;
    3 : begin
      if ScreenRows = 38 then
      begin
        ScreenRows := 20;
        TextMode(Lo(LastMode));
        SetCursor(NoCursor);
        RedrawScreen;
      end
      else begin
        TextMode(Lo(LastMode) + Font8x8);
        if (LastMode and Font8x8) <> 0 then
        begin
          ScreenRows := 38;
          SetCursor(NoCursor);
          RedrawScreen;
        end;
      end;
    end;
  end; { case }
end; { UMenu }

procedure MainMenu;
begin
  case GetCommand(MNU, COMMAND) of
    1 : SMenu;
    2 : FormatCells;
    3 : begin
      DeleteCell(CurCol, CurRow, UPDATE);
      PrintFreeMem;
      if AutoCalc then
        Recalc;
    end;
    4 : GotoCell;
    5 : CMenu;
    6 : RMenu;
    7 : EditCell(CurCell);
    8 : UMenu;
    9 : ChangeAutoCalc(not AutoCalc);
    10 : begin
      CheckForSave;
      Stop := True;
    end;
  end; { case }
  GotoXY(1, ScreenRows + 4);
  ClrEol;
end; { MainMenu }

begin
end.
