
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCSheet;
{ Turbo Pascal 6.0 object-oriented example spreadsheet routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$N+,S-}

interface

uses Crt, Dos, Objects, TCUtil, TCInput, TCScreen, TCLStr, TCHash, TCCell,
     TCCellSp, TCParser;

const
  DefaultMaxCols = 65535;
  DefaultMaxRows = 65535;
  DefaultMaxDecimalPlaces = 8;
  DefaultDefaultDecimalPlaces = 4;
  DefaultDefaultColWidth = 10;
  EmptyRowsAtTop = 1;
  EmptyRowsAtBottom = 2;
  MinColWidth = 3;
  CurrentChar = #4;
  ChangedChar = '*';
  PrintNormalCols = 80;
  PrintCompressedCols = 132;
  PrintRows = 66;
  PrintTopMargin = 1;
  PrintBottomMargin = 1;
  PrinterCompressChar = #15;
  EditYes = True;
  EditNo = False;
  DisplayYes = True;
  DisplayNo = False;
  WasChanged = True;
  NotChanged = False;
  AutoCalcLetter = 'A';
  FormulaDisplayLetter = 'F';
  MemoryString = 'Memory: ';
  FileHeader = 'TurboCalc Spreadsheet'^Z;
  ErrorString = 'ERROR';
  TempFileName = 'TEMP.TMP';  { Temporary file used for rehashing }
  PrinterName = 'PRN';
  PromptFileSave = 'File to save';
  PromptFilePrint = 'File to print to (ENTER = Printer)';
  PromptOverwriteFile = 'The file exists.  Overwrite it';
  PromptCompressPrint = 'Compress the printing';
  PromptBorderPrint = 'Print the borders';
  PromptColumnWidth = 'Column to change';
  PromptNewWidth = 'New width';
  PromptColumnDelete = 'Column to delete';
  PromptColumnInsert = 'Insert new column before column';
  PromptRowDelete = 'Row to delete';
  PromptRowInsert = 'Insert new row before row';
  PromptSaveYN = 'Save spreadsheet';
  ErrNoOpen = 'Cannot open file';
  ErrDiskFull = 'Disk full';
  ErrPrinterError = 'Printer error';
  ErrNotSpreadsheet = 'Not a TurboCalc spreadsheet file';
  MsgRecalc = 'Recalculating cell values';
  MsgSave = 'Saving spreadsheet';
  MsgLoad = 'Loading spreadsheet';
  MsgBlockDelete = 'Deleting block';

type
  ColStartArray = array[0..ScreenCols] of Byte;
  ColStartPtr = ^ColStartArray;
  SpreadsheetPtr = ^Spreadsheet;
  Spreadsheet = object
    Number : Byte;
    MaxRows : Word;
    MaxCols : Word;
    MaxDecimalPlaces : Byte;
    MaxColWidth : Byte;
    MaxScreenCols : Byte;
    DefaultColWidth : Byte;
    DefaultDecimalPlaces : Byte;
    RowNumberSpace : Byte;
    ColSpace : Byte;
    Current : Boolean;
    Changed : Boolean;
    CurrPos : CellPos;
    LastPos : CellPos;
    ScreenBlock : Block;
    CurrBlock : Block;
    BlockOn : Boolean;
    FileName : PathStr;
    TotalRows : ScreenRowRange;
    DisplayArea : ScreenArea;
    ColArea : ScreenArea;
    RowArea : ScreenArea;
    InfoArea : ScreenArea;
    DataArea : ScreenArea;
    ContentsArea : ScreenArea;
    BlankArea : ScreenArea;
    NoBlankArea : Boolean;
    ColStart : ColStartPtr;
    DisplayFormulas : Boolean;
    AutoCalc : Boolean;
    CellHash : CellHashTable;
    OverwriteHash : OverwriteHashTable;
    WidthHash : WidthHashTable;
    FormatHash : FormatHashTable;
    Next : SpreadsheetPtr;
    constructor Init(InitCells : Longint; InitMaxCols, InitMaxRows : Word;
                     InitMaxDecimalPlaces, InitDefaultDecimalPlaces : Byte;
                     InitDefaultColWidth : Byte);
    destructor Done;
    function GetColStart(Col : Word) : Byte;
    procedure SetAreas(NewNumber : Word; X1 : ScreenColRange;
                       Y1 : ScreenRowRange; X2 : ScreenColRange;
                       Y2 : ScreenRowRange);
    procedure DisplayCols;
    procedure DisplayRows;
    procedure DisplayInfo;
    procedure DisplayAllCells;
    procedure Display;
    procedure DisplayCell(P : CellPos);
    procedure DisplayCellData;
    procedure DisplayCellBlock(C1 : Word; R1 : Word; C2 : Word;
                               R2 : Word);
    procedure DisplayBlock(B : Block);
    procedure DisplayBlockDiff(B1, B2 : Block);
    procedure DisplayCol(Col : Word);
    procedure DisplayRow(Row : Word);
    procedure DisplayMemory;
    procedure DisplayFileName;
    procedure SetChanged(IsChanged : Boolean);
    procedure MakeCurrent;
    procedure MakeNotCurrent;
    procedure Update(UDisplay : Boolean);
    procedure ToggleFormulaDisplay;
    procedure SetScreenColStart(NewCol : Word);
    procedure SetScreenColStop(NewCol: Word);
    procedure SetScreenRowStart(NewRow : Word);
    procedure SetScreenRowStop(NewRow : Word);
    procedure FindScreenColStart;
    procedure FindScreenColStop;
    procedure FindScreenRowStart;
    procedure FindScreenRowStop;
    procedure SetBlankArea;
    function AddCell(CellType : CellTypes; P : CellPos; E : Boolean;
                     V : Extended; I : LStringPtr) : Boolean;
    procedure DeleteCell(P : CellPos; var Deleted : Boolean);
    procedure DeleteBlock(B : Block; var Deleted : Boolean);
    function CellToFString(P : CellPos; var Color : Byte) : String;
    procedure SetLastPos(DPos : CellPos);
    function GetCurrCol : Word;
    function GetCurrRow : Word;
    function ColToX(Col : Word) : Byte;
    function RowToY(Row : Word) : Byte;
    function ColWidth(Col : Word) : Byte;
    function SameCellPos(P1, P2 : CellPos) : Boolean;
    procedure FixOverwrite;
    function FromFile(Name : PathStr) : Boolean;
    procedure ToFile(Name : PathStr);
    procedure CheckForSave;
    procedure ChangeWidth;
    function CellHashStart(TotalCells : Longint) : BucketRange;
    function WidthHashStart(TotalCells : Longint) : BucketRange;
    function OverwriteHashStart(TotalCells : Longint) : BucketRange;
    procedure Print;
    procedure DeleteColumn;
    procedure InsertColumn;
    procedure DeleteRow;
    procedure InsertRow;
  end;

function GetColWidth(var WHash : WidthHashTable; C : Word) : Byte;

implementation

function GetColWidth(var WHash : WidthHashTable; C : Word) : Byte;
{ Returns the width of a column }
var
  W : Word;
begin
  W := WHash.Search(C);
  if W = 0 then
    GetColWidth := WHash.GetDefaultColWidth
  else
    GetColWidth := W;
end; { GetColWidth }

constructor Spreadsheet.Init(InitCells : Longint; InitMaxCols,
                             InitMaxRows : Word; InitMaxDecimalPlaces,
                             InitDefaultDecimalPlaces : Byte;
                             InitDefaultColWidth : Byte);
{ Sets up a new spreadsheet }
begin
  if not CellHash.Init(CellHashStart(InitCells)) then
    Fail;
  if not WidthHash.Init(WidthHashStart(InitCells), InitDefaultColWidth) then
  begin
    CellHash.Done;
    Fail;
  end;
  if not OverwriteHash.Init(OverwriteHashStart(InitCells)) then
  begin
    CellHash.Done;
    WidthHash.Done;
    Fail;
  end;
  if not FormatHash.Init then
  begin
    CellHash.Done;
    WidthHash.Done;
    OverwriteHash.Done;
    Fail;
  end;
  MaxCols := InitMaxCols;
  MaxRows := InitMaxRows;
  RowNumberSpace := Ord(MaxRows >= 10000) + Ord(MaxRows >= 1000) +
                    Ord(MaxRows >= 100) + Ord(MaxRows >= 10) + 2;
  MaxColWidth := ScreenCols - RowNumberSpace;
  MaxScreenCols := MaxColWidth div MinColWidth;
  GetMem(ColStart, MaxScreenCols);
  if ColStart = nil then
  begin
    CellHash.Done;
    WidthHash.Done;
    OverwriteHash.Done;
    FormatHash.Done;
    Fail;
  end;
  CurrPos.Col := 1;
  CurrPos.Row := 1;
  LastPos := CurrPos;
  BlockOn := False;
  FileName := '';
  DisplayFormulas := False;
  AutoCalc := False;
  Current := False;
  Changed := False;
  ScreenBlock.Start.Col := 1;
  ScreenBlock.Start.Row := 1;
  ColSpace := Succ(Ord(MaxCols >= 18279) + Ord(MaxCols >= 703) +
                   Ord(MaxCols >= 27));
  MaxDecimalPlaces := InitMaxDecimalPlaces;
  DefaultColWidth := InitDefaultColWidth;
  DefaultDecimalPlaces := InitDefaultDecimalPlaces;
end; { Spreadsheet.Init }

destructor Spreadsheet.Done;
{ Removes a spreadsheet from memory }
begin
  CellHash.Done;
  WidthHash.Done;
  OverwriteHash.Done;
  FormatHash.Done;
  FreeMem(ColStart, MaxScreenCols);
end; { Spreadsheet.Done }

function Spreadsheet.GetColStart(Col : Word) : Byte;
begin
  GetColStart := ColStart^[Col];
end; { Spreadsheet.GetColStart }

procedure Spreadsheet.SetAreas(NewNumber : Word; X1 : ScreenColRange;
                               Y1 : ScreenRowRange; X2 : ScreenColRange;
                               Y2 : ScreenRowRange);
{ Sets up a spreadsheet's display areas }
begin
  Number := NewNumber;
  TotalRows := Y2 - Y1 - 2;
  ColArea.Init(X1 + RowNumberSpace, Y1, X2, Y1, Colors.ColColor);
  RowArea.Init(X1, Succ(Y1), Pred(X1 + RowNumberSpace), Y2 - 2,
               Colors.RowColor);
  InfoArea.Init(X1, Y1, Pred(X1 + RowNumberSpace), Y1, Colors.InfoColor);
  DisplayArea.Init(X1 + RowNumberSpace, Succ(Y1), X2, Y2 - 2,
                   Colors.BlankColor);
  DataArea.Init(X1, Pred(Y2), X2, Pred(Y2), Colors.BlankColor);
  ContentsArea.Init(X1, Y2, X2, Y2, Colors.ContentsColor);
  SetScreenColStart(ScreenBlock.Start.Col);
  SetScreenRowStart(ScreenBlock.Start.Row);
  SetBlankArea;
end; { Spreadsheet.SetAreas }

procedure Spreadsheet.DisplayCols;
{ Shows the column headings }
var
  C : Word;
begin
  ColArea.Clear;
  with ScreenBlock do
  begin
    for C := Start.Col to Stop.Col do
      WriteXY(CenterStr(ColToString(C), ColWidth(C)),
              ColStart^[C - Start.Col], ColArea.UpperLeft.Row,
              Colors.ColColor);
  end; { with }
end; { Spreadsheet.DisplayCols }

procedure Spreadsheet.DisplayRows;
{ Shows the row headings }
var
  R : Word;
begin
  RowArea.Clear;
  with ScreenBlock do
  begin
    for R := Start.Row to Stop.Row do
      with RowArea do
        WriteXY(LeftJustStr(RowToString(R), RowNumberSpace),
                UpperLeft.Col, R - Start.Row + UpperLeft.Row,
                Colors.RowColor);
  end; { with }
end; { Spreadsheet.DisplayRows }

procedure Spreadsheet.DisplayInfo;
{ Shows the spreadsheet number, current dot, and state of AutoCalc and
  formula display }
begin
  InfoArea.Clear;
  with InfoArea do
    WriteXY(NumToString(Number), UpperLeft.Col, UpperLeft.Row,
                Colors.InfoColor);
  if Current then
    Write(CurrentChar)
  else
    Write(' ');
  if AutoCalc then
    Write(AutoCalcLetter)
  else
    Write(' ');
  if DisplayFormulas then
    Write(FormulaDisplayLetter)
  else
    Write(' ');
end; { Spreadsheet.DisplayRows }

procedure Spreadsheet.DisplayAllCells;
{ Displays all of the cells on the screen }
begin
  DisplayArea.Clear;
  DisplayBlock(ScreenBlock);
end; { Spreadsheet.DisplayAllCells }

procedure Spreadsheet.DisplayCell(P : CellPos);
{ Displays a single cell }
var
  S : String[ScreenCols];
  Color : Byte;
begin
  S := CellToFString(P, Color);
  WriteXY(S, ColToX(P.Col), RowToY(P.Row), Color);
end; { Spreadsheet.DisplayCell }

procedure Spreadsheet.DisplayCellData;
{ Displays information about a cell - its type and its contents }
var
  CP : CellPtr;
begin
  CP := CellHash.Search(CurrPos);
  with DataArea do
    WriteXY(LeftJustStr(ColToString(CurrPos.Col) +
                RowToString(CurrPos.Row) + ' ' + CP^.Name, 19),
                UpperLeft.Col, UpperLeft.Row, Colors.CellDataColor);
  with ContentsArea do
  begin
    Clear;
    WriteXY(LeftJustStr(CP^.DisplayString(DisplayFormulas,
                MaxDecimalPlaces), Scr.CurrCols), UpperLeft.Col,
                UpperLeft.Row, Colors.ContentsColor);
  end; { with }
end; { Spreadsheet.DisplayCellData }

procedure Spreadsheet.DisplayCellBlock(C1 : Word; R1 : Word;
                                       C2 : Word; R2 : Word);
{ Displays all cells within a range of rows and columns }
var
  P : CellPos;
begin
  with ScreenBlock do
  begin
    for P.Row := Max(R1, Start.Row) to Min(R2, Stop.Row) do
    begin
      for P.Col := Max(C1, Start.Col) to Min(C2, Stop.Col) do
        DisplayCell(P);
    end;
  end; { with }
end; { Spreadsheet.DisplayCellBlock }

procedure Spreadsheet.DisplayBlock(B : Block);
{ Displays all cells within a certain block }
begin
  with B do
    DisplayCellBlock(Start.Col, Start.Row, Stop.Col, Stop.Row);
end; { Spreadsheet.DisplayBlock }

procedure Spreadsheet.DisplayBlockDiff(B1, B2 : Block);
{ When a block is extended, this will update the screen to show the new
  block }
var
  B : Block;
  DisplayMiddle : Boolean;
begin
  if Compare(B1, B2, SizeOf(Block)) then
    Exit;
  with B do
  begin
    DisplayMiddle := False;
    if B1.Stop.Col <> B2.Stop.Col then
    begin
      B.Start.Row := B1.Start.Row;
      B.Start.Col := Min(Succ(B1.Stop.Col), Succ(B2.Stop.Col));
      B.Stop.Row := Min(B1.Stop.Row, B2.Stop.Row);
      B.Stop.Col := Max(B1.Stop.Col, B2.Stop.Col);
      DisplayBlock(B);
      DisplayMiddle := True;
    end;
    if B1.Stop.Row <> B2.Stop.Row then
    begin
      B.Start.Row := Min(Succ(B1.Stop.Row), Succ(B2.Stop.Row));
      B.Start.Col := B1.Start.Col;
      B.Stop.Row := Max(B1.Stop.Row, B2.Stop.Row);
      B.Stop.Col := Min(B1.Stop.Col, B2.Stop.Col);
      DisplayBlock(B);
      DisplayMiddle := True;
    end;
    if DisplayMiddle then
    begin
      B.Start.Row := Min(Succ(B1.Stop.Row), Succ(B2.Stop.Row));
      B.Start.Col := Min(Succ(B1.Stop.Col), Succ(B2.Stop.Col));
      B.Stop.Row := Max(B1.Stop.Row, B2.Stop.Row);
      B.Stop.Col := Max(B1.Stop.Col, B2.Stop.Col);
      DisplayBlock(B);
    end;
  end; { with }
end; { Spreadsheet.DisplayBlockDiff }

procedure Spreadsheet.DisplayCol(Col : Word);
{ Display a column of cells }
begin
  with ScreenBlock do
    DisplayCellBlock(Col, Start.Row, Col, Stop.Row);
end; { Spreadsheet.DisplayCol }

procedure Spreadsheet.DisplayRow(Row : Word);
{ Display a row of cells }
begin
  with ScreenBlock do
    DisplayCellBlock(Start.Col, Row, Stop.Col, Row);
end; { Spreadsheet.DisplayRow }

procedure Spreadsheet.DisplayMemory;
{ Display the amount of free memory }
begin
  WriteXY(RightJustStr(NumToString(MemAvail), 6), Scr.CurrCols - 5, 1,
          Colors.MemoryColor);
end; { Spreadsheet.DisplayMemory }

procedure Spreadsheet.DisplayFileName;
{ Display the spreadsheet's file name, and whether or not it has been
  updated }
var
  S : PathStr;
begin
  with DataArea do
  begin
    if FileName = '' then
      S := 'No file'
    else
      S := FExpand(FileName);
    WriteXY(LeftJustStr(S, LowerRight.Col - UpperLeft.Col - 20),
            UpperLeft.Col + 21, UpperLeft.Row, Colors.FileNameColor);
  end; { with }
end; { Spreadsheet.DisplayFileName }

procedure Spreadsheet.Display;
{ Display the entire spreadsheet }
begin
  DisplayCols;
  DisplayRows;
  DisplayInfo;
  DisplayAllCells;
  DisplayMemory;
  DisplayCellData;
  DisplayFileName;
  SetChanged(Changed);
end; { Spreadsheet.Display }

procedure Spreadsheet.SetChanged(IsChanged : Boolean);
{ Sets a spreadsheet as being changed or not changed }
var
  C : Char;
begin
  Changed := IsChanged;
  if Changed then
    C := ChangedChar
  else
    C := ' ';
  with DataArea.UpperLeft do
    WriteXY(C, Col + 19, Row, Colors.ChangedColor);
end; { Spreadsheet.SetChanged }

procedure Spreadsheet.MakeCurrent;
{ Make a spreadsheet the current one }
begin
  Current := True;
  DisplayInfo;
end; { Spreadsheet.MakeCurrent }

procedure Spreadsheet.MakeNotCurrent;
{ Make a spreadsheet not the current one }
begin
  Current := False;
  DisplayInfo;
end; { Spreadsheet.MakeNotCurrent }

procedure Spreadsheet.Update(UDisplay : Boolean);
{ Update any cells in the spreadsheet that need updating }
var
  P, U : CellPos;
  CP : CellPtr;
  O : Word;
begin
  Scr.PrintMessage(MsgRecalc);
  with CellHash do
  begin
    for P.Row := 1 to LastPos.Row do
    begin
      for P.Col := 1 to LastPos.Col do
      begin
        CP := Search(P);
        if CP^.ShouldUpdate then
        begin
          with FormulaCellPtr(CP)^ do
          begin
            Parser.Init(@CellHash, Formula, MaxCols, MaxRows);
            Parser.Parse;
            Value := Parser.ParseValue;
            Error := Parser.ParseError;
            O := CP^.Overwritten(CellHash, FormatHash, WidthHash,
                 LastPos, MaxCols, GetColWidth, DisplayFormulas);
            if (OverwriteHash.Change(CP, O)) and UDisplay and
               (CP^.Loc.Col + O >= ScreenBlock.Start.Col) then
            begin
              U := CP^.Loc;
              for U.Col := CP^.Loc.Col to ScreenBlock.Stop.Col do
              begin
                if ScreenBlock.CellInBlock(U) then
                DisplayCell(U);
              end;
            end;
          end; { with }
        end;
      end;
    end;
  end; { with }
  if UDisplay then
    DisplayMemory;
  Scr.ClearMessage;
end; { Spreadsheet.Update }

procedure Spreadsheet.ToggleFormulaDisplay;
{ Change from showing formulas to showing values and vice versa }
var
  CP : CellPtr;
  OChanged : Boolean;
begin
  DisplayFormulas := not DisplayFormulas;
  DisplayInfo;
  OChanged := True;
  with CellHash do
  begin
    CP := FirstItem;
    while (CP <> nil) and OChanged do
    begin
      if CP^.ShouldUpdate then
        OChanged := OverwriteHash.Change(CP, CP^.Overwritten(CellHash,
                                         FormatHash, WidthHash, LastPos,
                                         MaxCols, GetColWidth,
                                         DisplayFormulas));
      CP := NextItem;
    end;
  end; { with }
  DisplayAllCells;
  DisplayMemory;
end; { Spreadsheet.ToggleFormulaDisplay }

procedure Spreadsheet.SetScreenColStart(NewCol : Word);
{ Find the starting screen column }
begin
  ScreenBlock.Start.Col := NewCol;
  FindScreenColStop;
  FindScreenColStart;
end; { Spreadsheet.SetScreenColStart }

procedure Spreadsheet.SetScreenColStop(NewCol : Word);
{ Find the ending screen column }
begin
  ScreenBlock.Stop.Col := NewCol;
  FindScreenColStart;
  FindScreenColStop;
end; { Spreadsheet.SetScreenColStop }

procedure Spreadsheet.SetScreenRowStart(NewRow : Word);
{ Find the starting screen row }
begin
  ScreenBlock.Start.Row := NewRow;
  FindScreenRowStop;
end; { Spreadsheet.SetScreenRowStart }

procedure Spreadsheet.SetScreenRowStop(NewRow : Word);
{ Find the ending screen row }
begin
  ScreenBlock.Stop.Row := NewRow;
  FindScreenRowStart;
end; { Spreadsheet.SetScreenRowStop }

procedure Spreadsheet.FindScreenColStart;
{ Find the starting screen column when the ending column is known }
var
  Index, Place : Integer;
  Temp, Width : Byte;
begin
  with ScreenBlock do
  begin
    Index := 0;
    Place := Succ(DisplayArea.LowerRight.Col);
    Width := ColWidth(Stop.Col);
    repeat
      ColStart^[Index] := Place - Width;
      Dec(Place, Width);
      Inc(Index);
      if Stop.Col - Index = 0 then
        Width := 0
      else
        Width := ColWidth(Stop.Col - Index);
    until (Width = 0) or (Place - Width < DisplayArea.UpperLeft.Col);
    Start.Col := Succ(Stop.Col - Index);
    Dec(Index);
    if ColStart^[Index] <> DisplayArea.UpperLeft.Col then
    begin
      Temp := ColStart^[Index] - DisplayArea.UpperLeft.Col;
      for Place := 0 to Index do
        Dec(ColStart^[Place], Temp);
    end;
    if Index > 0 then
    begin
      for Place := 0 to (Pred(Index) shr 1) do
      begin
        Temp := ColStart^[Index - Place];
        ColStart^[Index - Place] := ColStart^[Place];
        ColStart^[Place] := Temp;
      end;
    end;
  end; { with }
end; { Spreadsheet.FindScreenColStart }

procedure Spreadsheet.FindScreenColStop;
{ Find the ending screen column when the starting column is known }
var
  Index, Place : Byte;
  Width : Byte;
begin
  with ScreenBlock do
  begin
    Index := 0;
    Place := DisplayArea.UpperLeft.Col;
    Width := ColWidth(Start.Col);
    repeat
      ColStart^[Index] := Place;
      Inc(Place, Width);
      Inc(Index);
      if Longint(Index) + Start.Col > MaxCols then
        Width := 0
      else
        Width := ColWidth(Index + Start.Col);
    until (Width = 0) or (Place + Width > Succ(DisplayArea.LowerRight.Col));
    Stop.Col := Pred(Start.Col + Index);
  end; { with }
end; { Spreadsheet.FindScreenColStop }

procedure Spreadsheet.FindScreenRowStart;
{ Find the starting screen row when the ending row is known }
begin
  with ScreenBlock do
  begin
    if Longint(Stop.Row) - TotalRows < 0 then
    begin
      Start.Row := 1;
      FindScreenRowStop;
    end
    else
      Start.Row := Succ(Stop.Row - TotalRows);
  end; { with }
end; { Spreadsheet.FindScreenRowStart }

procedure Spreadsheet.FindScreenRowStop;
{ Find the ending screen row when the starting row is known }
begin
  with ScreenBlock do
  begin
    if Longint(Start.Row) + TotalRows > Succ(LongInt(MaxRows)) then
    begin
      Stop.Row := MaxRows;
      FindScreenRowStart;
    end
    else
      Stop.Row := Pred(Start.Row + TotalRows);
  end; { with }
end; { Spreadsheet.FindScreenRowStop }

procedure Spreadsheet.SetBlankArea;
{ Find the size of the blank area (the area at the right edge of the
  spreadsheet that is not used }
var
  C : Word;
begin
  with BlankArea do
  begin
    Move(DisplayArea, BlankArea, SizeOf(DisplayArea));
    with ScreenBlock do
      C := ColStart^[Stop.Col - Start.Col] + ColWidth(Stop.Col);
    if C > DisplayArea.LowerRight.Col then
      NoBlankArea := True
    else begin
      NoBlankArea := False;
      UpperLeft.Col := C;
    end;
  end; { with }
end; { Spreadsheet.SetBlankArea }

function Spreadsheet.AddCell(CellType : CellTypes; P : CellPos; E : Boolean;
                             V : Extended; I : LStringPtr) : Boolean;
{ Add a new cell to the spreadsheet }
var
  CP, S : CellPtr;
  OldLastPos : CellPos;
  Good : Boolean;
begin
  AddCell := False;
  case CellType of
    ClValue : CP := New(ValueCellPtr, Init(P, E, V));
    ClFormula : CP := New(FormulaCellPtr, Init(P, E, V, I));
    ClText : CP := New(TextCellPtr, Init(P, I));
    ClRepeat : CP := New(RepeatCellPtr, Init(P, I^.Data^[2]));
  end; { case }
  if CP = nil then
    Exit;
  if not CellHash.Add(CP) then
  begin
    Dispose(CP, Done);
    Exit;
  end;
  OldLastPos := LastPos;
  LastPos.Col := Max(P.Col, LastPos.Col);
  LastPos.Row := Max(P.Row, LastPos.Row);
  if not OverwriteHash.Add(CP, CP^.Overwritten(CellHash, FormatHash,
                           WidthHash, LastPos, MaxCols, GetColWidth,
                           DisplayFormulas)) then
  begin
    LastPos := OldLastPos;
    CellHash.Delete(CP^.Loc, S);
    Dispose(CP, Done);
    Exit;
  end;
  S := OverwriteHash.Search(CP^.Loc);
  if S <> Empty then
    Good := OverwriteHash.Change(S, S^.Overwritten(CellHash, FormatHash,
                                 WidthHash, LastPos, MaxCols, GetColWidth,
                                 DisplayFormulas));
  AddCell := True;
end; { Spreadsheet.AddCell }

procedure Spreadsheet.DeleteCell(P : CellPos; var Deleted : Boolean);
{ Delete a cell from the spreadsheet }
var
  CP : CellPtr;
  Good : Boolean;
begin
  CellHash.Delete(P, CP);
  if CP <> nil then
  begin
    Dispose(CP, Done);
    OverwriteHash.Delete(P);
    if P.Col > 1 then
    begin
      Dec(P.Col);
      CP := OverwriteHash.Search(P);
      if CP = Empty then
        CP := CellHash.Search(P);
      if CP <> Empty then
        Good := OverwriteHash.Change(CP, CP^.Overwritten(CellHash,
                                     FormatHash, WidthHash, LastPos, MaxCols,
                                     GetColWidth, DisplayFormulas));
    end;
    Deleted := True;
  end
  else
    Deleted := False;
end; { Spreadsheet.DeleteCell }

procedure Spreadsheet.DeleteBlock(B : Block; var Deleted : Boolean);
{ Delete a block of cells from the spreadsheet }
var
  P : CellPos;
  H, D : HashItemPtr;
  Counter : Word;
  CP : CellPtr;
begin
  Scr.PrintMessage(MsgBlockDelete);
  Deleted := False;
  with CellHash, B do
  begin
    for Counter := 1 to Buckets do
    begin
      H := HashData^[Counter];
      while H <> nil do
      begin
        D := H;
        H := H^.Next;
        Move(D^.Data, CP, SizeOf(CP));
        with CP^ do
        begin
          if CellInBlock(Loc) then
            DeleteCell(Loc, Deleted);
        end; { with }
      end;
    end;
  end; { with }
  Scr.ClearMessage;
end; { DeleteBlock }

function Spreadsheet.CellToFString(P : CellPos; var Color : Byte) : String;
{ Create a formatted string from a cell }
var
  CP : CellPtr;
  S : String;
  S1 : DollarStr;
  F : FormatType;
  ColorFound : Boolean;
  Colr : Byte;
begin
  ColorFound := True;
  if Current and (SameCellPos(P, CurrPos)) then
    Color := Colors.HighlightColor
  else if BlockOn and (CurrBlock.CellInBlock(P)) then
    Color := Colors.BlockColor
  else
    ColorFound := False;
  CP := CellHash.Search(P);
  if (CP^.HasError) then
  begin
    S := ErrorString;
    S1 := '';
    if ColorFound then
      Inc(Color, Blink)
    else
      Color := Colors.CellErrorColor;
    F := Ord(JCenter) shl JustShift;
  end
  else begin
    S := CP^.FormattedString(OverwriteHash, FormatHash, WidthHash,
                             GetColWidth, P, DisplayFormulas, 1,
                             ColWidth(P.Col), S1, Colr);
    if not ColorFound then
      Color := Colr;
    F := CP^.Format(FormatHash, DisplayFormulas);
  end;
  case Justification((F shr JustShift) and JustPart) of
    JLeft : CellToFString := S1 + LeftJustStr(S, ColWidth(P.Col) -
                                             Length(S1));
    JCenter : CellToFString := S1 + CenterStr(S, ColWidth(P.Col) -
                                              Length(S1));
    JRight : CellToFString := S1 + RightJustStr(S, ColWidth(P.Col) -
                                                Length(S1));
  end; { case }
end; { Spreadsheet.CellToFString }

procedure Spreadsheet.SetLastPos(DPos : CellPos);
{ Find the last position used in a spreadsheet }
var
  CP : CellPtr;
  Counter : Word;
  ColFound, RowFound : Boolean;
begin
  with CellHash do
  begin
    ColFound := DPos.Col < LastPos.Col;
    RowFound := DPos.Row < LastPos.Row;
    if (not ColFound) or (not RowFound) then
    begin
      if not ColFound then
        LastPos.Col := 1;
      if not RowFound then
        LastPos.Row := 1;
      CP := FirstItem;
      while CP <> nil do
      begin
        if not ColFound then
        begin
          if CP^.Loc.Col > LastPos.Col then
          begin
            LastPos.Col := CP^.Loc.Col;
            ColFound := LastPos.Col = DPos.Col;
            if ColFound and RowFound then
              Exit;
          end;
        end;
        if not RowFound then
        begin
          if CP^.Loc.Row > LastPos.Row then
          begin
            LastPos.Row := CP^.Loc.Row;
            RowFound := LastPos.Row = DPos.Row;
            if ColFound and RowFound then
              Exit;
          end;
        end;
        CP := NextItem;
      end;
    end;
  end; { with }
end; { Spreadsheet.SetLastPos }

function Spreadsheet.GetCurrCol : Word;
{ Find the current column }
begin
  GetCurrCol := CurrPos.Col;
end; { Spreadsheet.GetCurrCol }

function Spreadsheet.GetCurrRow : Word;
{ Find the current row }
begin
  GetCurrRow := CurrPos.Row;
end; { Spreadsheet.GetCurrRow }

function Spreadsheet.ColToX(Col : Word) : Byte;
{ Find where on the screen a column starts }
begin
  ColToX := ColStart^[Col - ScreenBlock.Start.Col];
end; { Spreadsheet.ColToX }

function Spreadsheet.RowToY(Row : Word) : Byte;
{ Find where on the screen a row starts }
begin
  RowToY := Row + DisplayArea.UpperLeft.Row - ScreenBlock.Start.Row;
end; { Spreadsheet.RowToY }

{$F+}

function Spreadsheet.ColWidth(Col : Word) : Byte;
{ Returns the width of a column }
var
  Width : Word;
begin
  Width := WidthHash.Search(Col);
  if Width = 0 then
    ColWidth := DefaultColWidth
  else
    ColWidth := Width;
end; { Spreadsheet.ColWidth }

{$F-}

function Spreadsheet.SameCellPos(P1, P2 : CellPos) : Boolean;
{ Returns True if two cells are at the same position }
begin
  SameCellPos := Compare(P1, P2, SizeOf(CellPos));
end; { Spreadsheet.SameCellPos }

procedure Spreadsheet.FixOverwrite;
{ Fixes the overwrite hash table when the formats have been changed }
var
  CP, D : CellPtr;
  Counter : Word;
  Good : Boolean;
begin
  with CellHash do
  begin
    CP := FirstItem;
    while CP <> nil do
    begin
      if not OverwriteHash.Add(CP, CP^.Overwritten(CellHash, FormatHash,
                               WidthHash, LastPos, MaxCols, GetColWidth,
                               DisplayFormulas)) then
      begin
        CellHash.Delete(CP^.Loc, D);
        Dispose(CP, Done);
        Exit;
      end;
      CP := OverwriteHash.Search(CP^.Loc);
      if CP <> Empty then
        Good := OverwriteHash.Change(CP, CP^.Overwritten(CellHash,
                                     FormatHash, WidthHash, LastPos,
                                     MaxCols, GetColWidth,
                                     DisplayFormulas));
      CP := NextItem;
    end;
  end; { with }
end; { Spreadsheet.FixOverwrite }

function Spreadsheet.FromFile(Name : PathStr) : Boolean;
{ Reads a spreadsheet from disk }
var
  Header : String[Length(FileHeader)];
  TotalC : Longint;
  TotalW : Word;
  TotalF : Longint;
  S : TDosStream;
  NewLastPos : CellPos;
begin
  FromFile := True;
  Name := UpperCase(Name);
  S.Init(Name, stOpen);
  if S.Status <> 0 then
  begin
    Scr.PrintError(ErrNoOpen);
    Init(0, DefaultMaxCols, DefaultMaxRows, DefaultMaxDecimalPlaces,
         DefaultDefaultDecimalPlaces, DefaultDefaultColWidth);
    Exit;
  end
  else begin
    Header[0] := Chr(Length(FileHeader));
    S.Read(Header[1], Length(FileHeader));
    if (S.Status <> 0) or (Header <> FileHeader) then
    begin
      Scr.PrintError(ErrNotSpreadsheet);
      S.Done;
      Init(0, DefaultMaxCols, DefaultMaxRows, DefaultMaxDecimalPlaces,
           DefaultDefaultDecimalPlaces, DefaultDefaultColWidth);
      Exit;
    end;
    FileName := Name;
    S.Read(NewLastPos, SizeOf(NewLastPos));
    S.Read(TotalW, SizeOf(TotalW));
    S.Read(TotalF, SizeOf(TotalF));
    S.Read(TotalC, SizeOf(TotalC));
    if not Init(TotalC, DefaultMaxCols, DefaultMaxRows,
                DefaultMaxDecimalPlaces, DefaultDefaultDecimalPlaces,
                DefaultDefaultColWidth) then
    begin
      S.Done;
      FromFile := False;
      Exit;
    end;
    LastPos := NewLastPos;
    Scr.PrintMessage(MsgLoad);
    FileName := Name;
    WidthHash.Load(S, TotalW);
    FormatHash.Load(S, TotalF);
    CellHash.Load(S, TotalC);
    S.Done;
    FixOverwrite;
    Update(DisplayNo);
    Scr.ClearMessage;
  end;
  FromFile := True;
end; { Spreadsheet.FromFile }

procedure Spreadsheet.ToFile(Name : PathStr);
{ Writes a spreadsheet to disk }
var
  Header : String[Length(FileHeader)];
  S : TDosStream;
begin
  S.Init(Name, stCreate);
  if S.Status <> 0 then
  begin
    Scr.PrintError(ErrNoOpen);
    Exit;
  end;
  Scr.PrintMessage(MsgSave);
  FileName := Name;
  Header := FileHeader;
  S.Write(Header[1], Length(Header));
  S.Write(LastPos, SizeOf(LastPos));
  S.Write(WidthHash.Items, 2);
  S.Write(FormatHash.Items, SizeOf(FormatHash.Items));
  S.Write(CellHash.Items, SizeOf(CellHash.Items));
  WidthHash.Store(S);
  FormatHash.Store(S);
  CellHash.Store(S);
  Scr.ClearMessage;
  S.Done;
  if S.Status <> 0 then
    Scr.PrintError(ErrDiskFull)
  else
    SetChanged(NotChanged);
end; { Spreadsheet.ToFile }

procedure Spreadsheet.CheckForSave;
{ Before prompting for a file name, this will check to see if you want to
  save the spreadsheet }
var
  S : PathStr;
  GoodFile, ESCPressed : Boolean;
begin
  if Changed and (GetYesNo(PromptSaveYN, ESCPressed)) then
  begin
    S := FileName;
    repeat
      GoodFile := True;
      if S = '' then
      begin
        S := ReadString(PromptFileSave, Pred(SizeOf(PathStr)), ESCPressed);
        if S = '' then
          Exit;
      end;
      if FileExists(S) then
      begin
        GoodFile := GetYesNo(PromptOverwriteFile, ESCPressed);
        if ESCPressed then
          Exit;
        if not GoodFile then
          S := '';
      end;
    until GoodFile;
    ToFile(S);
  end;
end; { Spreadsheet.CheckForSave }

procedure Spreadsheet.ChangeWidth;
{ Changes the width of a column }
var
  W, C : Word;
  Good : Boolean;
  P : CellPos;
  O : Word;
  CP : CellPtr;
begin
  C := GetColumn(PromptColumnWidth, MaxCols, ColSpace);
  if C = 0 then
    Exit;
  W := GetNumber(PromptNewWidth, MinColWidth, MaxColWidth, Good);
  if not Good then
    Exit;
  with WidthHash do
  begin
    Delete(C);
                if W <> DefaultColWidth then
                        Good := Add(C, W);
  end; { with }
  if not Good then
    Exit;
  SetScreenColStart(ScreenBlock.Start.Col);
  SetChanged(WasChanged);
  with OverwriteHash do
  begin
    Done;
    Init(OverwriteHashStart(CellHash.Items));
  end;
  with CellHash do
  begin
    CP := FirstItem;
    while CP <> nil do
    begin
      O := CP^.Overwritten(CellHash, FormatHash, WidthHash, LastPos,
                           MaxCols, GetColWidth, DisplayFormulas);
      if O <> 0 then
        Good := OverwriteHash.Add(CP, O);
      CP := NextItem;
    end;
  end; { with }
  if CurrPos.Col > ScreenBlock.Stop.Col then
    SetScreenColStart(CurrPos.Col);
  Display;
end; { Spreadsheet.ChangeWidth }

function Spreadsheet.CellHashStart(TotalCells : Longint) : BucketRange;
{ Formula that determines the number of cell hash table buckets }
begin
  CellHashStart := Max(100, Min(MaxBuckets, TotalCells div 10));
end; { Spreadsheet.CellHashStart }

function Spreadsheet.WidthHashStart(TotalCells : Longint) : BucketRange;
{ Formula that determines the number of width hash table buckets }
begin
  WidthHashStart := 10;
end; { Spreadsheet.WidthHashStart }

function Spreadsheet.OverwriteHashStart(TotalCells : Longint) : BucketRange;
{ Formula that determines the number of overwrite hash table buckets }
begin
  OverwriteHashStart := 10;
end; { Spreadsheet.OverwriteHashStart }

procedure Spreadsheet.Print;
{ Prints a spreadsheet to a file or a printer }
var
  S : PathStr;
  F : Text;
  PageCols : Byte;
  PageV, PageH : Word;
  Finished, GoodFile, Error, Compress, Border, ESCPressed : Boolean;
  StartCol : Word;
  StartRow : Word;

  procedure WString(S : String);
  begin
    Writeln(F, S);
    if IOResult <> 0 then
    begin
      if S = PrinterName then
        Scr.PrintError(ErrPrinterError)
      else
        Scr.PrintError(ErrDiskFull);
      Error := True;
      Finished := True;
    end;
  end; { WString }

  function RowStartString(Row : Word) : String;
  begin
    if (PageH = 1) and Border then
      RowStartString := LeftJustStr(RowToString(Row), RowNumberSpace)
    else
      RowStartString := '';
  end; { RowStartString }

  procedure PrintPage;
  var
    Counter : Word;
    S : String;
    Color, Cols, Rows : Byte;
    P : CellPos;
  begin
    for Counter := 1 to PrintTopMargin do
    begin
      WString('');
      if Error then
        Exit;
    end;
    Rows := Min(PrintRows - PrintTopMargin - PrintBottomMargin,
                Succ(MaxRows - StartRow));
    if Border then
      Dec(Rows);
    Cols := 0;
    Counter := Length(RowStartString(StartRow));
    while Counter <= PageCols do
    begin
      Inc(Counter, ColWidth(Cols + StartCol));
      Inc(Cols);
    end;
    Dec(Cols);
    Cols := Min(Cols, Succ(MaxCols - StartCol));
    if Border and (PageV = 1) then
    begin
      S := FillString(Length(RowStartString(StartRow)), ' ');
      for Counter := StartCol to Pred(StartCol + Cols) do
        S := S + CenterStr(ColToString(Counter), ColWidth(Counter));
      WString(S);
      if Error then
        Exit;
    end;
    for P.Row := StartRow to Pred(StartRow + Rows) do
    begin
      S := RowStartString(P.Row);
      for P.Col := StartCol to Pred(StartCol + Cols) do
        S := S + CellToFString(P, Color);
      WString(S);
      if Error then
        Exit;
    end;
    Inc(StartCol, Cols);
    if (StartCol > LastPos.Col) or (StartCol = 0) then
    begin
      Inc(StartRow, Rows);
      if (StartRow > LastPos.Row) or (StartRow = 0) then
        Finished := True
      else begin
        Inc(PageV);
        PageH := 1;
        StartCol := 1;
      end;
    end
    else
      Inc(PageH);
    Write(F, Chr(FF));
  end; { PrintPage }

begin { Spreadsheet.Print }
  repeat
    GoodFile := True;
    S := ReadString(PromptFilePrint, Pred(SizeOf(PathStr)), ESCPressed);
    if ESCPressed then
      Exit;
    if S = '' then
      S := PrinterName
    else begin
      if FileExists(S) then
      begin
        GoodFile := GetYesNo(PromptOverwriteFile, ESCPressed);
        if ESCPressed then
          Exit;
      end;
    end;
  until GoodFile;
  Compress := GetYesNo(PromptCompressPrint, ESCPressed);
  if ESCPressed then
    Exit;
  Border := GetYesNo(PromptBorderPrint, ESCPressed);
  if ESCPressed then
    Exit;
  Error := False;
{$I-}
  Assign(F, S);
  Rewrite(F);
  if IOResult <> 0 then
  begin
    Scr.PrintError(ErrNoOpen);
    Exit;
  end;
  if Compress then
  begin
    PageCols := PrintCompressedCols;
    Write(F, PrinterCompressChar);
  end
  else
    PageCols := PrintNormalCols;
  PageV := 1;
  PageH := 1;
  StartCol := 1;
  StartRow := 1;
  Finished := False;
  repeat
    PrintPage;
  until Finished;
  Close(F);
{$I+}
end; { Spreadsheet.Print }

procedure Spreadsheet.DeleteColumn;
{ Deletes a column from the spreadsheet }
var
  C : Word;
  Start, Stop, P, OldPos, OldSPos : CellPos;
  Deleted : Boolean;
  OldName : PathStr;
  CP : CellPtr;
  H : HashItemPtr;
  B : Block;
  F : File;
  Good : Boolean;
begin
  C := GetColumn(PromptColumnDelete, MaxCols, ColSpace);
  if C = 0 then
    Exit;
  OldPos := CurrPos;
  OldSPos := ScreenBlock.Start;
  P.Col := C;
  Deleted := False;
  if P.Col <= LastPos.Col then
  begin
    with B do
    begin
      Start.Col := P.Col;
      Start.Row := 1;
      Stop.Col := P.Col;
      Stop.Row := LastPos.Row;
      Good := FormatHash.Delete(Start, Stop);
    end; { with }
    DeleteBlock(B, Deleted);
  end;
  Dec(LastPos.Col);
  WidthHash.Delete(C);
  with CellHash do
  begin
    CP := FirstItem;
    while CP <> nil do
    begin
      with CP^ do
      begin
        if Loc.Col > C then
          Dec(Loc.Col);
        if (CP^.ShouldUpdate) and (Loc.Col > C) then
          FixFormulaCol(CP, -1, MaxCols, MaxRows);
      end; { with }
      CP := NextItem;
    end;
  end; { with }
  with WidthHash do
  begin
    H := FirstItem;
    while H <> nil do
    begin
      if WordPtr(@H^.Data)^ > C then
        Dec(WordPtr(@H^.Data)^);
      H := NextItem;
    end;
  end; { with }
  with FormatHash do
  begin
    H := FirstItem;
    while H <> nil do
    begin
      Move(H^.Data, Start, SizeOf(Start));
      Move(H^.Data[SizeOf(CellPos)], Stop, SizeOf(Stop));
      if (Start.Col = C) and (Stop.Col = C) then
        Good := Delete(Start, Stop)
      else begin
        if Start.Col > C then
        begin
          Dec(Start.Col);
          Move(Start, H^.Data, SizeOf(Start));
        end;
        if Stop.Col > C then
        begin
          Dec(Stop.Col);
          Move(Stop, H^.Data[SizeOf(CellPos)], SizeOf(Stop));
        end;
      end;
      H := NextItem;
    end;
  end; { with }
  OldName := FileName;
  ToFile(TempFileName);
  Done;
  Good := FromFile(TempFileName);
  Assign(F, TempFileName);
  Erase(F);
  FileName := OldName;
  if Deleted then
    P.Row := LastPos.Row
  else
    P.Row := 1;
  Dec(P.Col);
  SetLastPos(P);
  MakeCurrent;
  SetChanged(WasChanged);
  CurrPos := OldPos;
  SetScreenColStart(OldSPos.Col);
  SetScreenRowStart(OldSPos.Row);
  Display;
end; { Spreadsheet.DeleteColumn }

procedure Spreadsheet.InsertColumn;
{ Inserts a column into the spreadsheet }
var
  C : Word;
  Start, Stop, P, OldPos, OldSPos : CellPos;
  Deleted : Boolean;
  H : HashItemPtr;
  OldName : PathStr;
  CP : CellPtr;
  B : Block;
  F : File;
  Good : Boolean;
begin
  C := GetColumn(PromptColumnInsert, MaxCols, ColSpace);
  if C = 0 then
    Exit;
  OldPos := CurrPos;
  OldSPos := ScreenBlock.Start;
  Deleted := False;
  if LastPos.Col = MaxCols then
  begin
    with B do
    begin
      Start.Col := MaxCols;
      Start.Row := 1;
      Stop.Col := MaxCols;
      Stop.Row := LastPos.Row;
      Good := FormatHash.Delete(Start, Stop);
    end; { with }
    DeleteBlock(B, Deleted);
  end
  else
    Inc(LastPos.Col);
  P.Col := C;
  WidthHash.Delete(MaxCols);
  with CellHash do
  begin
    CP := FirstItem;
    while CP <> nil do
    begin
      with CP^ do
      begin
        if Loc.Col >= C then
          Inc(Loc.Col);
        if (CP^.ShouldUpdate) and (Loc.Col >= C) then
          FixFormulaCol(CP, 1, MaxCols, MaxRows);
      end; { with }
      CP := NextItem;
    end;
  end; { with }
  with WidthHash do
  begin
    H := FirstItem;
    while H <> nil do
    begin
      if WordPtr(@H^.Data)^ >= C then
        Inc(WordPtr(@H^.Data)^);
      H := NextItem;
    end;
  end; { with }
  with FormatHash do
  begin
    H := FirstItem;
    while H <> nil do
    begin
      Move(H^.Data, Start, SizeOf(Start));
      Move(H^.Data[SizeOf(CellPos)], Stop, SizeOf(Stop));
      if Start.Col >= C then
      begin
        Inc(Start.Col);
        Move(Start, H^.Data, SizeOf(Start));
      end;
      if Stop.Col >= C then
      begin
        Inc(Stop.Col);
        Move(Stop, H^.Data[SizeOf(CellPos)], SizeOf(Stop));
      end;
      H := NextItem;
    end;
  end; { with }
  OldName := FileName;
  ToFile(TempFileName);
  Done;
  Good := FromFile(TempFileName);
  Assign(F, TempFileName);
  Erase(F);
  FileName := OldName;
  if Deleted then
    P.Row := LastPos.Row
  else
    P.Row := 1;
  if LastPos.Col = MaxCols then
    P.Col := MaxCols
  else
    Inc(P.Col);
  SetLastPos(P);
  MakeCurrent;
  SetChanged(WasChanged);
  CurrPos := OldPos;
  SetScreenColStart(OldSPos.Col);
  SetScreenRowStart(OldSPos.Row);
  Display;
end; { Spreadsheet.InsertColumn }

procedure Spreadsheet.DeleteRow;
{ Deletes a row from the spreadsheet }
var
  R : Word;
  Start, Stop, P, OldPos, OldSPos : CellPos;
  Deleted : Boolean;
  OldName : PathStr;
  CP : CellPtr;
  B : Block;
  F : File;
  Good : Boolean;
  H : HashItemPtr;
begin
  R := GetRow(PromptRowDelete, MaxRows);
  if (R = 0) or (R > LastPos.Row) then
    Exit;
  OldPos := CurrPos;
  OldSPos := ScreenBlock.Start;
  P.Row := R;
  if P.Row <= LastPos.Row then
  begin
    with B do
    begin
      Start.Col := 1;
      Start.Row := P.Row;
      Stop.Col := LastPos.Col;
      Stop.Row := P.Row;
      Good := FormatHash.Delete(Start, Stop);
    end; { with }
    DeleteBlock(B, Deleted);
  end;
  Dec(LastPos.Row);
  with CellHash do
  begin
    CP := FirstItem;
    while CP <> nil do
    begin
      with CP^ do
      begin
        if Loc.Row > R then
          Dec(Loc.Row);
        if (CP^.ShouldUpdate) and (Loc.Row > R) then
          FixFormulaRow(CP, -1, MaxCols, MaxRows);
      end; { with }
      CP := NextItem;
    end;
  end; { with }
  with FormatHash do
  begin
    H := FirstItem;
    while H <> nil do
    begin
      Move(H^.Data, Start, SizeOf(Start));
      Move(H^.Data[SizeOf(CellPos)], Stop, SizeOf(Stop));
      if (Start.Row = R) and (Stop.Row = R) then
        Good := Delete(Start, Stop)
      else begin
        if Start.Row > R then
        begin
          Dec(Start.Row);
          Move(Start, H^.Data, SizeOf(Start));
        end;
        if Stop.Row > R then
        begin
          Dec(Stop.Row);
          Move(Stop, H^.Data[SizeOf(CellPos)], SizeOf(Stop));
        end;
      end;
      H := NextItem;
    end;
  end; { with }
  OldName := FileName;
  ToFile(TempFileName);
  Done;
  Good := FromFile(TempFileName);
  Assign(F, TempFileName);
  Erase(F);
  FileName := OldName;
  if Deleted then
    P.Col := LastPos.Col
  else
    P.Col := 1;
  Dec(P.Row);
  SetLastPos(P);
  MakeCurrent;
  SetChanged(WasChanged);
  CurrPos := OldPos;
  SetScreenColStart(OldSPos.Col);
  SetScreenRowStart(OldSPos.Row);
  Display;
end; { Spreadsheet.DeleteRow }

procedure Spreadsheet.InsertRow;
{ Inserts a row into the spreadsheet }
var
  R : Word;
  Start, Stop, P, OldPos, OldSPos : CellPos;
  Deleted : Boolean;
  OldName : PathStr;
  CP : CellPtr;
  B : Block;
  F : File;
  Good : Boolean;
  H : HashItemPtr;
begin
  R := GetRow(PromptRowInsert, MaxRows);
  if (R = 0) or (R > LastPos.Row) then
    Exit;
  OldPos := CurrPos;
  OldSPos := ScreenBlock.Start;
  if LastPos.Row = MaxRows then
  begin
    with B do
    begin
      Start.Col := 1;
      Start.Row := MaxRows;
      Stop.Col := LastPos.Col;
      Stop.Row := MaxRows;
      Good := FormatHash.Delete(Start, Stop);
    end; { with }
    DeleteBlock(B, Deleted);
  end
  else
    Inc(LastPos.Row);
  P.Row := R;
  with CellHash do
  begin
    CP := FirstItem;
    while CP <> nil do
    begin
      with CP^ do
      begin
        if Loc.Row >= R then
          Inc(Loc.Row);
        if (CP^.ShouldUpdate) and (Loc.Row >= R) then
          FixFormulaRow(CP, 1, MaxCols, MaxRows);
      end; { with }
      CP := NextItem;
    end;
  end; { with }
  with FormatHash do
  begin
    H := FirstItem;
    while H <> nil do
    begin
      Move(H^.Data, Start, SizeOf(Start));
      Move(H^.Data[SizeOf(CellPos)], Stop, SizeOf(Stop));
      if Start.Row >= R then
      begin
        Inc(Start.Row);
        Move(Start, H^.Data, SizeOf(Start));
      end;
      if Stop.Row >= R then
      begin
        Inc(Stop.Row);
        Move(Stop, H^.Data[SizeOf(CellPos)], SizeOf(Stop));
      end;
      H := NextItem;
    end;
  end; { with }
  OldName := FileName;
  ToFile(TempFileName);
  Done;
  Good := FromFile(TempFileName);
  Assign(F, TempFileName);
  Erase(F);
  FileName := OldName;
  if Deleted then
    P.Col := LastPos.Col
  else
    P.Col := 1;
  if LastPos.Row = MaxRows then
    P.Row := MaxRows
  else
    Inc(P.Row);
  SetLastPos(P);
  MakeCurrent;
  SetChanged(WasChanged);
  CurrPos := OldPos;
  SetScreenColStart(OldSPos.Col);
  SetScreenRowStart(OldSPos.Row);
  Display;
end; { Spreadsheet.InsertRow }

end.
