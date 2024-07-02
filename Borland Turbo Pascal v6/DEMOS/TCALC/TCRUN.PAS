
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCRun;
{ Turbo Pascal 6.0 object-oriented example run module.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$N+,S-}

interface

uses Crt, Dos, TCUtil, TCLStr, TCScreen, TCHash, TCCell, TCCellSp, TCSheet,
     TCInput, TCParser, TCMenu;

const
  FreeListItems = 1000;
  MenuHeapSpace = 1000;
  MaxSpreadsheets = (MinScreenRows - EmptyRowsAtTop - EmptyRowsAtBottom) div
                    4;
  LegalJustification = ['L', 'C', 'R'];
  HelpLine = 'F2\Save\F3\Load\F7\Formula\F8\AutoCalc\F9\Recalc\F10\Menu\Ins\Block\Alt-X\Exit';
  TitleString = 'TurboCalc - Turbo Pascal Demo Program';
  MainMenuString = 'Spreadsheet, Block, Column, Row, Format, Goto, Edit, Options, Quit';
  SpreadsheetMenuString = 'Load, Save, Zap, Write, Open, Close, Next, Print';
  OpenMenuString = 'Load, New';
  BlockMenuString = 'Copy, Delete, Format, Restore default format';
  ColumnMenuString = 'Insert, Delete, Width';
  RowMenuString = 'Insert, Delete';
  UtilityMenuString1 = 'Screen lines, Recalc, Formula display, Autocalc';
  UtilityMenuString2 = 'Recalc, Formula display, Autocalc';
  PromptFileLoad = 'File to load';
  PromptGotoCell = 'Go to cell';
  PromptCopyCell = 'Copy to cell';
  PromptColLiteral = 'Copy formula columns literally';
  PromptRowLiteral = 'Copy formula rows literally';
  PromptCopySpreadsheet = 'Copy to spreadsheet number (0 = current)';
  PromptFormatPlaces = 'Number of decimal places';
  PromptFormatJustification = 'Justification - (L)eft, (C)enter, (R)ight';
  PromptFormatDollar = 'Dollar format';
  PromptFormatCommas = 'Put commas in numbers';
  ErrFreeList = 'The free list is full';
  MsgBlockCopy = 'Copying block';

type
  ProgramObject = object
    SSData, CurrSS : SpreadsheetPtr;
    TotalSheets : Byte;
    CellInput : InputField;
    MainMenu : Menu;
    SpreadsheetMenu : Menu;
    OpenMenu : Menu;
    BlockMenu : Menu;
    ColumnMenu : Menu;
    RowMenu : Menu;
    UtilityMenu : Menu;
    Stop : Boolean;
    constructor Init;
    destructor Done;
    procedure GetCommands;
    procedure SetDisplayAreas;
    procedure DisplayAll;
    function AddSheet(Name : PathStr) : Boolean;
    procedure DeleteSheet;
  end;

var
  Vars : ProgramObject;

procedure Run;

implementation

const
  RedrawYes = True;
  RedrawNo = False;

{$F+}

function RunHeapError(Size : Word) : Integer;
{ Prints an error if the heap runs out of memory }
begin
  if size > 0 then
    Scr.PrintError(ErrNoMemory);
  RunHeapError := 1;
end; { RunHeapError }

{$F-}

procedure InitMenus; forward;

constructor ProgramObject.Init;
{ Sets up the program }
var
  Counter : Word;
  Good : Boolean;
begin { ProgramObject.Init }
  if MaxAvail < MenuHeapSpace then
    Abort(ErrNoMemory);
  InitMenus;
  RegisterCellTypes;             { Register cell types for stream access }
  TotalSheets := 0;
  SSData := nil;
  CurrSS := nil;
  Stop := False;
  if ParamCount = 0 then         { Load spreadsheets named on command line }
  begin
    if not AddSheet('') then
      Abort(ErrNoMemory);
  end
  else begin
    Counter := 1;
    repeat
      Good := AddSheet(ParamStr(Counter));
      Inc(Counter);
    until (not Good) or (Counter > Min(ParamCount, MaxSpreadsheets));
  end;
  SetDisplayAreas;
  DisplayAll;
  with CurrSS^ do
  begin
    MakeCurrent;
    DisplayCell(CurrPos);
  end; { with }
end; { ProgramObject.Init }

destructor ProgramObject.Done;
{ Releases all memory used by the program }
begin
  CurrSS^.MakeNotCurrent;
  while SSData <> nil do
  begin
    CurrSS := SSData;
    SSData := SSData^.Next;
    with CurrSS^ do
    begin
      MakeCurrent;
      DisplayCell(CurrPos);
      CheckForSave;
      MakeNotCurrent;
      DisplayCell(CurrPos);
      Dispose(CurrSS, Done);
    end; { with }
  end;
  MainMenu.Done;
  SpreadsheetMenu.Done;
  OpenMenu.Done;
  BlockMenu.Done;
  ColumnMenu.Done;
  RowMenu.Done;
  UtilityMenu.Done;
end; { ProgramObject.Done }

function GetFormat(var Format : Byte) : Boolean;
{ Reads a format value from the keyboard }
var
  Places : Byte;
  J : Justification;
  ESCPressed, Good, Dollar, Commas : Boolean;
  Ch : Char;
begin
  GetFormat := False;
  Dollar := GetYesNo(PromptFormatDollar, ESCPressed);
  if ESCPressed then
    Exit;
  if Dollar then
  begin
    Places := 2;
    J := JRight;
  end
  else begin
    Places := GetNumber(PromptFormatPlaces, 0,
                        Vars.CurrSS^.MaxDecimalPlaces, Good);
    if not Good then
      Exit;
    Ch := GetLegalChar(PromptFormatJustification, LegalJustification,
                       ESCPressed);
    if ESCPressed then
      Exit;
    case Ch of
      'L' : J := JLeft;
      'C' : J := JCenter;
      'R' : J := JRight;
    end; { case }
  end;
  Commas := GetYesNo(PromptFormatCommas, ESCPressed);
  if ESCPressed then
    Exit;
  Format := Places + (Ord(J) shl 4) + (Ord(Dollar) shl 6) +
            (Ord(Commas) shl 7);
  GetFormat := True;
end; { GetFormat }

procedure EditInput(Ch : Word; Editing : Boolean);
{ Edits the data on the input line }
var
  Good, FirstEdit, Deleted : Boolean;
  P : CellPos;
begin
  with Vars, CurrSS^ do
  begin
    if not CellInput.Init(1, 0, -1, 0, NotUpper) then
      Exit;
    with CellInput.InputData^ do
    begin
      if Editing then
      begin
        Good := True;
        CellHash.Search(CurrPos)^.EditString(MaxDecimalPlaces,
                        CellInput.InputData)
      end
      else
        Good := FromString(Chr(Ch));
      if not Good then
      begin
        CellInput.Done;
        Exit;
      end;
      FirstEdit := True;
      Parser.Init(@CellHash, CellInput.InputData, MaxCols, MaxRows);
      repeat
        if FirstEdit then
          CellInput.Edit(0)
        else
          CellInput.Edit(Parser.Position);
        if Length > 0 then
        begin
          Parser.Parse;
          if Parser.TokenError = 0 then
          begin
            DeleteCell(CurrPos, Deleted);
            Good := AddCell(Parser.CType, CurrPos, Parser.ParseError,
                            Parser.ParseValue, CellInput.InputData);
          end;
        end;
        FirstEdit := False;
      until (Length = 0) or (Parser.TokenError = 0);
      if Length > 0 then
      begin
        SetChanged(WasChanged);
        if AutoCalc then
          Update(DisplayYes);
        P := CurrPos;
        for P.Col := CurrPos.Col to ScreenBlock.Stop.Col do
          DisplayCell(P);
      end;
      CellInput.InputArea.Clear;
    end; { with }
    CellInput.Done;
    DisplayMemory;
  end; { with }
end; { EditInput }

procedure OpenSpreadsheet(Name : String);
{ Opens a new spreadsheet }
begin
  with Vars do
  begin
    if not AddSheet(Name) then
      Exit;
    SetDisplayAreas;
    DisplayAll;
    with CurrSS^ do
    begin
      MakeCurrent;
      DisplayCell(CurrPos);
    end; { with }
  end; { with }
end; { OpenSpreadsheet }

procedure ClearCurrBlock;
{ Turns off the block and redisplays the cells in it }
begin
  with Vars.CurrSS^ do
  begin
    if BlockOn then
    begin
      BlockOn := False;
      DisplayBlock(CurrBlock);
    end;
  end;
end; { ClearCurrBlock }

{$F+}

procedure ReplaceSpreadsheet;
{ Load a spreadsheet over the current one }
var
  S : PathStr;
  ESCPressed : Boolean;
begin
  with Vars.CurrSS^ do
  begin
    S := ReadString(PromptFileLoad, Pred(SizeOf(PathStr)), ESCPressed);
    if S = '' then
      Exit;
    CheckForSave;
    Done;
    if FromFile(S) then
    begin
      SetChanged(NotChanged);
      SetScreenColStart(1);
      SetScreenRowStart(1);
      Display;
      MakeCurrent;
      DisplayCell(CurrPos);
    end;
  end; { with }
end; { ReplaceSpreadsheet }

procedure NameSaveSpreadsheet;
{ Save a spreadsheet to a file other that its default }
var
  St : PathStr;
  ESCPressed : Boolean;
begin
  with Vars.CurrSS^ do
  begin
    St := ReadString(PromptFileSave, Pred(SizeOf(PathStr)), ESCPressed);
    if St = '' then
      Exit;
    if FileExists(St) then
    begin
      if not GetYesNo(PromptOverwriteFile, ESCPressed) then
        Exit;
    end;
    ToFile(St);
    DisplayFileName;
  end; { with }
end; { NameSaveSpreadsheet }

procedure SaveCurrSpreadsheet;
{ Save a spreadsheet to its default file }
begin
  with Vars.CurrSS^ do
  begin
    if FileName = '' then
      NameSaveSpreadsheet
    else
      ToFile(FileName);
  end; { with }
end; { SaveCurrSpreadsheet }

procedure ZapSpreadsheet;
{ Clear the current spreadsheet from memory }
var
  S : PathStr;
begin
  with Vars.CurrSS^ do
  begin
    CheckForSave;
    S := FileName;
    Done;
    Init(0, DefaultMaxCols, DefaultMaxRows, DefaultMaxDecimalPlaces,
         DefaultDefaultDecimalPlaces, DefaultDefaultColWidth);
    MakeCurrent;
    FileName := S;
    SetScreenColStart(1);
    SetScreenRowStart(1);
    Display;
  end; { with }
end; { ZapSpreadsheet }

procedure CloseSpreadsheet;
{ Delete a spreadsheet, closing the window that it is in }
begin
  with Vars, CurrSS^ do
  begin
    if TotalSheets = 1 then
      Exit;
    DeleteSheet;
  end; { with }
end; { CloseSpreadsheet }

procedure NextSpreadsheet;
{ Move to the next spreadsheet }
begin
  with Vars do
  begin
    if TotalSheets = 1 then
      Exit;
    with CurrSS^ do
    begin
      MakeNotCurrent;
      DisplayCell(CurrPos);
    end; { with }
    CurrSS := CurrSS^.Next;
    if CurrSS = nil then
      CurrSS := SSData;
    with CurrSS^ do
    begin
      MakeCurrent;
      DisplayCell(CurrPos);
    end; { with }
  end; { with }
end; { NextSpreadsheet }

procedure NewSpreadsheet;
{ Create a new spreadsheet, opening a window for it and loading it }
var
  S : PathStr;
  ESCPressed : Boolean;
begin
  with Vars do
  begin
    if TotalSheets >= MaxSpreadsheets then
      Exit;
    S := ReadString(PromptFileLoad, Pred(SizeOf(PathStr)), ESCPressed);
    if S = '' then
      Exit;
    OpenSpreadsheet(S);
  end; { with }
end; { NewSpreadsheet }

procedure NewBlankSpreadsheet;
{ Create a new blank spreadsheet, opening a window for it }
begin
  with Vars do
  begin
    if TotalSheets >= MaxSpreadsheets then
      Exit;
    OpenSpreadsheet('');
  end; { with }
end; { NewBlankSpreadsheet }

procedure PrintSpreadsheet;
{ Print a spreadsheet to a file or a printer }
begin
  Vars.CurrSS^.Print;
end; { PrintSpreadsheet }

procedure CopyBlock;
{ Copy a block of cells from one spreadsheet to the same or a different
  spreadsheet }
var
  P, N, C : CellPos;
  Good, ESCPressed, ColLit, RowLit, AnyChanged, Deleted : Boolean;
  CP : CellPtr;
  L : LStringPtr;
  CopyTo : SpreadsheetPtr;
  CopySheet : Byte;
  Counter : Word;
begin
  with Vars, CurrSS^, CurrBlock do
  begin
    if not BlockOn then
      Exit;
    if TotalSheets > 1 then
      CopySheet := GetNumber(PromptCopySpreadsheet, 0, TotalSheets, Good)
    else
      CopySheet := 1;
    if not Good then
      Exit;
    if not GetCellPos(PromptCopyCell, MaxCols, MaxRows, ColSpace,
                      RowNumberSpace, P) then
      Exit;
    ColLit := GetYesNo(PromptColLiteral, ESCPressed);
    if ESCPressed then
      Exit;
    RowLit := GetYesNo(PromptRowLiteral, ESCPressed);
    if ESCPressed then
      Exit;
    Scr.PrintMessage(MsgBlockCopy);
    if CopySheet = 0 then
      CopyTo := CurrSS
    else begin
      CopyTo := SSData;
      for Counter := 2 to CopySheet do
        CopyTo := CopyTo^.Next;
    end;
    AnyChanged := False;
    C.Row := P.Row;
    N.Row := Start.Row;
    L := New(LStringPtr, Init);
    Good := L <> nil;
    while Good and (N.Row <= Stop.Row) do
    begin
      C.Col := P.Col;
      N.Col := Start.Col;
      while Good and (N.Col <= Stop.Col) do
      begin
        if (Longint(P.Col) + N.Col - Start.Col <= MaxCols) and
           (Longint(P.Row) + N.Row - Start.Row <= MaxRows) then
        begin
          CopyTo^.DeleteCell(C, Deleted);
          if Deleted then
            AnyChanged := True;
          CP := CellHash.Search(N);
          if CP <> Empty then
          begin
            AnyChanged := True;
            with CP^ do
              Good := CopyTo^.AddCell(CellType, C, HasError, CurrValue,
                                      CopyString(ColLit, RowLit,
                                      Longint(C.Col) - N.Col, L));
            if Good and ((not ColLit) or (not RowLit)) then
            begin
              CP := CopyTo^.CellHash.Search(C);
              if CP^.ShouldUpdate then
              begin
                if not ColLit then
                  FixFormulaCol(CP, Longint(C.Col) - N.Col, MaxCols,
                                MaxRows);
                if not RowLit then
                  FixFormulaRow(CP, Longint(C.Row) - N.Row, MaxCols,
                                MaxRows);
              end;
            end;
          end;
        end;
        Inc(C.Col);
        Inc(N.Col);
      end;
      Inc(C.Row);
      Inc(N.Row);
    end;
    if AnyChanged then
    begin
      if CopySheet = 0 then
        BlockOn := False;
      with CopyTo^ do
      begin
        SetLastPos(LastPos);
        SetChanged(WasChanged);
        if AutoCalc then
          Update(DisplayNo);
        DisplayAllCells;
        DisplayMemory;
      end; { with }
      if CopySheet <> 0 then
        ClearCurrBlock;
    end
    else
      ClearCurrBlock;
    Scr.ClearMessage;
  end; { with }
  if L <> nil then
    Dispose(L, Done);
end; { CopyBlock }

procedure DeleteBlock;
{ Delete a block of cells }
var
  Deleted : Boolean;
begin
  with Vars.CurrSS^, CurrBlock do
  begin
    if not BlockOn then
      Exit;
    DeleteBlock(CurrBlock, Deleted);
    if Deleted then
    begin
      BlockOn := False;
      SetLastPos(LastPos);
      SetChanged(WasChanged);
      if AutoCalc then
        Update(DisplayNo);
      DisplayMemory;
      DisplayAllCells;
    end
    else
      ClearCurrBlock;
  end; { with }
end; { DeleteBlock }

procedure FormatBlock;
{ Format a block of cells }
var
  Format : Byte;
begin
  with Vars.CurrSS^ do
  begin
    if not BlockOn then
      Exit;
    if not GetFormat(Format) then
      Exit;
    with CurrBlock do
    begin
      if not FormatHash.Add(Start, Stop, Format) then
        Exit;
      SetChanged(WasChanged);
      DisplayAllCells;
      DisplayMemory;
    end; { with }
  end; { with }
end; { FormatBlock }

procedure FormatDefault;
{ Change the format of a block of cells to the default }
begin
  with Vars.CurrSS^ do
  begin
    if not BlockOn then
      Exit;
    with CurrBlock do
    begin
      if not FormatHash.Delete(Start, Stop) then
        Exit;
      SetChanged(WasChanged);
      DisplayAllCells;
      DisplayMemory;
    end; { with }
  end; { with }
end; { FormatDefault }

procedure ColInsert;
{ Insert a column into the spreadsheet }
begin
  Vars.CurrSS^.InsertColumn;
end; { ColInsert }

procedure ColDelete;
{ Delete a column from the spreadsheet }
begin
  Vars.CurrSS^.DeleteColumn;
end; { ColDelete }

procedure ChangeColWidth;
{ Change the width of a column }
begin
  Vars.CurrSS^.ChangeWidth;
end; { ChangeColWidth }

procedure RowInsert;
{ Insert a row into the spreadsheet }
begin
  Vars.CurrSS^.InsertRow;
end; { RowInsert }

procedure RowDelete;
{ Delete a row from the spreadsheet }
begin
  Vars.CurrSS^.DeleteRow;
end; { RowDelete }

procedure ToggleMaxLines;
{ Toggle 43/50-line mode }
begin
  with Vars do
  begin
    Scr.ToggleMaxLinesMode;
    SetCursor(NoCursor);
    SetDisplayAreas;
    DisplayAll;
  end; { with }
end; { ToggleMaxLines }

procedure Recalc;
{ Recalculate all of the cells }
begin
  Vars.CurrSS^.Update(DisplayYes);
end; { Recalc }

procedure ToggleFormulas;
{ Toggle formula display on and off }
begin
  with Vars.CurrSS^ do
    ToggleFormulaDisplay;
end; { ToggleFormulas }

procedure ToggleAutoCalc;
{ Toggle AutoCalc on and off }
begin
  with Vars.CurrSS^ do
  begin
    if AutoCalc then
    begin
      AutoCalc := False;
      DisplayInfo;
    end
    else begin
      AutoCalc := True;
      DisplayInfo;
      Update(DisplayYes);
    end;
  end;
end; { ToggleAutoCalc }

procedure FormatCell;
{ Format a single cell }
var
  Format : Byte;
  P : CellPos;
  CP : CellPtr;
  Good : Boolean;
begin
  with Vars.CurrSS^ do
  begin
    if not GetFormat(Format) then
      Exit;
    if not FormatHash.Add(CurrPos, CurrPos, Format) then
      Exit;
    CP := CellHash.Search(CurrPos);
    SetChanged(WasChanged);
    OverwriteHash.Delete(CurrPos);
    if CP <> Empty then
      Good := OverwriteHash.Add(CP, CP^.Overwritten(CellHash, FormatHash,
                                WidthHash, LastPos, MaxCols, GetColWidth,
                                DisplayFormulas));
    P := CurrPos;
    for P.Col := CurrPos.Col to ScreenBlock.Stop.Col do
      DisplayCell(P);
    DisplayMemory;
  end; { with }
end; { FormatCell }

procedure GotoCell;
{ Go to a selected cell }
var
  P, OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if not GetCellPos(PromptGotoCell, MaxCols, MaxRows, ColSpace,
                      RowNumberSpace, P) then
      Exit;
    if not ScreenBlock.CellInBlock(P) then
    begin
      CurrPos := P;
      SetScreenColStart(CurrPos.Col);
      SetScreenRowStart(CurrPos.Row);
      Display;
    end
    else begin
      OldPos := CurrPos;
      CurrPos := P;
      DisplayCell(OldPos);
      DisplayCell(CurrPos);
    end;
  end; { with }
end; { GotoCell }

procedure EditCell;
{ Edit the current cell }
begin
  EditInput(0, EditYes);
end; { EditCell }

procedure Quit;
{ Exit from the program }
begin
  Vars.Stop := True;
end; { Quit }

{$F-}

procedure ExtendCurrBlock(Redraw : Boolean);
{ Extend the current block and redraw any cells that are affected }
var
  OldBlock : Block;
begin
  with Vars.CurrSS^ do
  begin
    if BlockOn then
    begin
      Move(CurrBlock, OldBlock, SizeOf(CurrBlock));
      if CurrBlock.ExtendTo(CurrPos) then
      begin
        if Redraw then
          DisplayBlockDiff(OldBlock, CurrBlock);
      end
      else
        ClearCurrBlock;
    end;
  end; { with }
end; { ExtendCurrBlock }

procedure ToggleCurrBlock;
{ Turn the block on and off }
begin
  with Vars.CurrSS^ do
  begin
    if not BlockOn then
    begin
      BlockOn := True;
      CurrBlock.Init(CurrPos);
    end
    else
      ClearCurrBlock;
  end; { with }
end; { ToggleCurrBlock }

procedure RemoveCell;
{ Delete a cell }
var
  P : CellPos;
  Deleted : Boolean;
begin
  with Vars.CurrSS^ do
  begin
    DeleteCell(CurrPos, Deleted);
    if Deleted then
    begin
      SetLastPos(CurrPos);
      SetChanged(WasChanged);
      if AutoCalc then
        Update(DisplayYes);
      P.Row := CurrPos.Row;
      for P.Col := CurrPos.Col to ScreenBlock.Stop.Col do
        DisplayCell(P);
      DisplayMemory;
    end;
  end; { with }
end; { RemoveCell }

procedure MoveHome;
{ Move to the home position (1, 1) }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    OldPos := CurrPos;
    CurrPos.Col := 1;
    CurrPos.Row := 1;
    if not ScreenBlock.CellInBlock(CurrPos) then
    begin
      ExtendCurrBlock(RedrawNo);
      SetScreenColStart(1);
      SetScreenRowStart(1);
      SetBlankArea;
      Display;
    end
    else begin
      ExtendCurrBlock(RedrawYes);
      DisplayCell(OldPos);
      DisplayCell(CurrPos);
    end;
  end; { with }
end; { MoveHome }

procedure MoveEnd;
{ Move to the last position used }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    OldPos := CurrPos;
    CurrPos := LastPos;
    if not ScreenBlock.CellInBlock(CurrPos) then
    begin
      ExtendCurrBlock(RedrawNo);
      SetScreenColStop(CurrPos.Col);
      SetScreenRowStop(CurrPos.Row);
      SetBlankArea;
      Display;
    end
    else begin
      ExtendCurrBlock(RedrawYes);
      DisplayCell(OldPos);
      DisplayCell(CurrPos);
    end;
  end; { with }
end; { MoveEnd }

procedure MoveUp;
{ Move up a row }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Row > 1 then
    begin
      OldPos := CurrPos;
      Dec(CurrPos.Row);
      ExtendCurrBlock(RedrawYes);
      if CurrPos.Row < ScreenBlock.Start.Row then
      begin
        DisplayCell(OldPos);
        SetScreenRowStart(CurrPos.Row);
        DisplayRows;
        DisplayArea.Scroll(Down, 1);
        DisplayRow(CurrPos.Row);
      end
      else begin
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MoveUp }

procedure MoveDown;
{ Move down a row }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Row < MaxRows then
    begin
      OldPos := CurrPos;
      Inc(CurrPos.Row);
      if CurrPos.Row > ScreenBlock.Stop.Row then
      begin
        ExtendCurrBlock(RedrawNo);
        DisplayCell(OldPos);
        SetScreenRowStop(CurrPos.Row);
        DisplayRows;
        DisplayArea.Scroll(Up, 1);
        DisplayRow(CurrPos.Row);
      end
      else begin
        ExtendCurrBlock(RedrawYes);
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MoveDown }

procedure MovePgUp;
{ Move up a page }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Row > 1 then
    begin
      OldPos := CurrPos;
      CurrPos.Row := Max(1, Longint(CurrPos.Row) - TotalRows);
      ExtendCurrBlock(RedrawNo);
      if CurrPos.Row < ScreenBlock.Start.Row then
      begin
        SetScreenRowStart(CurrPos.Row);
        DisplayRows;
        DisplayAllCells;
      end
      else begin
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MovePgUp }

procedure MovePgDn;
{ Move down a page }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Row < MaxRows then
    begin
      OldPos := CurrPos;
      CurrPos.Row := Min(MaxRows, Longint(CurrPos.Row) + TotalRows);
      ExtendCurrBlock(RedrawNo);
      if CurrPos.Row > ScreenBlock.Start.Row then
      begin
        SetScreenRowStart(CurrPos.Row);
        DisplayRows;
        DisplayAllCells;
      end
      else begin
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MovePgDn }

procedure MoveLeft;
{ Move left a column }
var
  C : Word;
  OldPos : CellPos;
  OldSCol : Word;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Col > 1 then
    begin
      OldPos := CurrPos;
      Dec(CurrPos.Col);
      ExtendCurrBlock(RedrawYes);
      if CurrPos.Col < ScreenBlock.Start.Col then
      begin
        OldSCol := ScreenBlock.Start.Col;
        C := GetColStart(1);
        DisplayCell(OldPos);
        SetScreenColStart(CurrPos.Col);
        SetBlankArea;
        DisplayCols;
        DisplayArea.Scroll(Right,
          GetColStart(OldSCol - ScreenBlock.Start.Col) - GetColStart(0));
        if not NoBlankArea then
          BlankArea.Clear;
        for C := ScreenBlock.Start.Col to CurrPos.Col do
          DisplayCol(C);
      end
      else begin
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MoveLeft }

procedure MoveRight;
{ Move right a column }
var
  C : Word;
  OldPos : CellPos;
  SaveColStart : array[0..79] of Byte;
  OldSCol : Word;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Col < MaxCols then
    begin
      OldPos := CurrPos;
      Inc(CurrPos.Col);
      if CurrPos.Col > ScreenBlock.Stop.Col then
      begin
        ExtendCurrBlock(RedrawNo);
        for C := 0 to Pred(MaxScreenCols) do
          SaveColStart[C] := GetColStart(C);
        OldSCol := ScreenBlock.Start.Col;
        DisplayCell(OldPos);
        C := ColWidth(ScreenBlock.Start.Col);
        SetScreenColStop(CurrPos.Col);
        SetBlankArea;
        DisplayCols;
        DisplayArea.Scroll(Left,
          SaveColStart[ScreenBlock.Start.Col - OldSCol] - ColStart^[0]);
        if not NoBlankArea then
          BlankArea.Clear;
        for C := CurrPos.Col to ScreenBlock.Stop.Col do
          DisplayCol(C);
      end
      else begin
        ExtendCurrBlock(RedrawYes);
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MoveRight }

procedure MovePgLeft;
{ Move left a page }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Col > 1 then
    begin
      OldPos := CurrPos;
      CurrPos.Col := Max(1, Pred(ScreenBlock.Start.Col));
      ExtendCurrBlock(RedrawNo);
      if CurrPos.Col < ScreenBlock.Start.Col then
      begin
        SetScreenColStop(CurrPos.Col);
        SetBlankArea;
        DisplayCols;
        if not NoBlankArea then
          BlankArea.Clear;
        DisplayAllCells;
      end
      else begin
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MovePgLeft }

procedure MovePgRight;
{ Move right a page }
var
  OldPos : CellPos;
begin
  with Vars.CurrSS^ do
  begin
    if CurrPos.Col < MaxCols then
    begin
      OldPos := CurrPos;
      CurrPos.Col := Min(MaxCols, Succ(ScreenBlock.Stop.Col));
      ExtendCurrBlock(RedrawNo);
      if CurrPos.Col > ScreenBlock.Start.Col then
      begin
        SetScreenColStart(CurrPos.Col);
        SetBlankArea;
        DisplayCols;
        if not NoBlankArea then
          BlankArea.Clear;
        DisplayAllCells;
      end
      else begin
        DisplayCell(OldPos);
        DisplayCell(CurrPos);
      end;
    end;
  end; { with }
end; { MovePgRight }

procedure HandleInput(Ch : Word);
{ Process the initial input from the keyboard }
begin
  EditInput(Ch, EditNo);
end; { HandleInput }

procedure ProgramObject.GetCommands;
{ Read the keyboard and process the next command }
var
  Ch : Word;
begin 
  repeat
    CurrSS^.DisplayCellData;
    ClearInputBuffer;
    Ch := GetKey;
    case Ch of
      F2 : SaveCurrSpreadsheet;
      AltF2 : NameSaveSpreadsheet;
      F3 : ReplaceSpreadsheet;
      AltF3 : NewSpreadsheet;
      F4 : DeleteSheet;
      F6 : NextSpreadsheet;
      F7 : ToggleFormulas;
      F8 : ToggleAutoCalc;
      F9 : Recalc;
      F10 : MainMenu.RunMenu;
      AltX : Stop := True;
      InsKey : ToggleCurrBlock;
      DelKey : RemoveCell;
      HomeKey : MoveHome;
      EndKey : MoveEnd;
      UpKey : MoveUp;
      DownKey : MoveDown;
      LeftKey : MoveLeft;
      RightKey : MoveRight;
      PgUpKey : MovePgUp;
      PgDnKey : MovePgDn;
      CtrlLeftKey : MovePgLeft;
      CtrlRightKey : MovePgRight;
      Ord(' ')..Ord('~') : HandleInput(Ch);
    end;
  until Stop;
end; { ProgramObject.GetCommands }

procedure ProgramObject.SetDisplayAreas;
{ Set the display areas of the various spreadsheets }
var
  S : SpreadsheetPtr;
  Total, StartRow, Amt : Word;
begin
  S := SSData;
  StartRow := Succ(EmptyRowsAtTop);
  Amt := (Scr.CurrRows - EmptyRowsAtTop - EmptyRowsAtBottom) div
         TotalSheets;
  Total := 1;
  repeat
    if S^.Next = nil then
      Amt := Succ(Scr.CurrRows - EmptyRowsAtBottom - StartRow);
    S^.SetAreas(Total, 1, StartRow, Scr.CurrCols, Pred(StartRow + Amt));
    Inc(StartRow, Amt);
    S := S^.Next;
    Inc(Total);
  until S = nil;
end; { ProgramObject.SetDisplayAreas }

procedure ProgramObject.DisplayAll;
{ Display all of the spreadsheets }
var
  S : SpreadsheetPtr;
begin
  TextAttr := Colors.BlankColor;
  ClrScr;
  WriteColor(TitleString, Colors.TitleColor);
  Scr.PrintHelpLine(HelpLine);
  WriteXY(MemoryString, Scr.CurrCols - Length(MemoryString) - 5, 1,
          Colors.PromptColor);
  S := SSData;
  repeat
    S^.Display;
    S := S^.Next;
  until S = nil;
end; { ProgramObject.DisplayAll }

function ProgramObject.AddSheet(Name : PathStr) : Boolean;
{ Add a new spreadsheet }
var
  A, S : SpreadsheetPtr;
  Good, AllocatingNext : Boolean;
begin
  AddSheet := False;
  if TotalSheets = MaxSpreadsheets then
    Exit;
  S := SSData;
  while (S <> nil) and (S^.Next <> nil) do
    S := S^.Next;
  if SSData <> nil then
  begin
    A := S;
    New(S^.Next);
    S := S^.Next;
    AllocatingNext := True;
  end
  else begin
    New(S);
    AllocatingNext := False;
  end;
  if S = nil then
    Exit;
  if Name = '' then
    Good := S^.Init(0, DefaultMaxCols, DefaultMaxRows,
                    DefaultMaxDecimalPlaces, DefaultDefaultDecimalPlaces,
                    DefaultDefaultColWidth)
  else
    Good := S^.FromFile(Name);
  if not Good then
  begin
    Dispose(S);
    if AllocatingNext then
      A^.Next := nil;
    Exit;
  end;
  if SSData = nil then
    SSData := S;
  if CurrSS <> nil then
    CurrSS^.Current := False;
  CurrSS := S;
  Inc(TotalSheets);
  S^.Next := nil;
  AddSheet := True;
end; { ProgramObject.AddSheet }

procedure ProgramObject.DeleteSheet;
{ Delete a spreadsheet }
var
  S : SpreadsheetPtr;
begin
  if TotalSheets > 1 then
  begin
    S := SSData;
    if S = CurrSS then
      SSData := S^.Next
    else begin
      while S^.Next <> CurrSS do
        S := S^.Next;
      S^.Next := S^.Next^.Next;
    end;
  end;
  with CurrSS^ do
  begin
    CheckForSave;
    Done;
  end; { with }
  if TotalSheets > 1 then
  begin
    FreeMem(CurrSS, SizeOf(Spreadsheet));
    Dec(TotalSheets);
    CurrSS := SSData;
  end
  else
    CurrSS^.Init(0, DefaultMaxCols, DefaultMaxRows,
                 DefaultMaxDecimalPlaces, DefaultDefaultDecimalPlaces,
                 DefaultDefaultColWidth);
  SetDisplayAreas;
  DisplayAll;
  with CurrSS^ do
  begin
    MakeCurrent;
    DisplayCell(CurrPos);
  end; { with }
end; { ProgramObject.DeleteSheet }

procedure InitMenus;
{ Initialize the menu items }
var
  Good : Boolean;
  P : Word;
begin
  with Vars do
  begin
    with MainMenu do
    begin
      Init(MainMenuString, nil);
      Good := AddItemMenu(@SpreadsheetMenu);
      Good := AddItemMenu(@BlockMenu);
      Good := AddItemMenu(@ColumnMenu);
      Good := AddItemMenu(@RowMenu);
      Good := AddItemProc(FormatCell);
      Good := AddItemProc(GotoCell);
      Good := AddItemProc(EditCell);
      Good := AddItemMenu(@UtilityMenu);
      Good := AddItemProc(Quit);
    end; { with }
    with SpreadsheetMenu do
    begin
      Init(SpreadsheetMenuString, @MainMenu);
      Good := AddItemProc(Replacespreadsheet);
      Good := AddItemProc(SaveCurrSpreadsheet);
      Good := AddItemProc(ZapSpreadsheet);
      Good := AddItemProc(NameSaveSpreadsheet);
      Good := AddItemMenu(@OpenMenu);
      Good := AddItemProc(CloseSpreadsheet);
      Good := AddItemProc(NextSpreadsheet);
      Good := AddItemProc(PrintSpreadsheet);
    end; { with }
    with OpenMenu do
    begin
      Init(OpenMenuString, @SpreadsheetMenu);
      Good := AddItemProc(NewSpreadsheet);
      Good := AddItemProc(NewBlankSpreadsheet);
    end; { with }
    with BlockMenu do
    begin
      Init(BlockMenuString, @MainMenu);
      Good := AddItemProc(CopyBlock);
      Good := AddItemProc(DeleteBlock);
      Good := AddItemProc(FormatBlock);
      Good := AddItemProc(FormatDefault);
    end; { with }
    with ColumnMenu do
    begin
      Init(ColumnMenuString, @MainMenu);
      Good := AddItemProc(ColInsert);
      Good := AddItemProc(ColDelete);
      Good := AddItemProc(ChangeColWidth);
    end; { with }
    with RowMenu do
    begin
      Init(RowMenuString, @MainMenu);
      Good := AddItemProc(RowInsert);
      Good := AddItemProc(RowDelete);
    end; { with }
    with UtilityMenu do
    begin
      if Scr.VideoType >= MCGA then
      begin
        Init(UtilityMenuString1, @MainMenu);
        Good := AddItemProc(ToggleMaxLines);
      end
      else
        Init(UtilityMenuString2, @MainMenu);
      Good := AddItemProc(Recalc);
      Good := AddItemProc(ToggleFormulas);
      Good := AddItemProc(ToggleAutoCalc);
    end; { with }
  end; { with }
end; { InitMenus }

procedure Run;
{ The main part of the program - it sets up the spreadsheets, reads commands,
  and them releases all of the memory that it used }
begin
  SetCursor(NoCursor);
  with Vars do
  begin
    Init;
    GetCommands;
    Done;
  end;
end; { Run }

begin
  CheckBreak := False;
  HeapError := @RunHeapError;
end.
