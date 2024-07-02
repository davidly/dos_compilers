
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCCell;
{ Turbo Pascal 6.0 object-oriented example cell routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$N+,S-}

interface

uses Objects, TCUtil, TCLStr, TCScreen, TCHash;

const
  DollarString = ' $ ';
  RepeatFirstChar = '\';
  TextFirstChar = ' ';
  EmptyCellName = 'Empty';
  ValueCellName = 'Value';
  TextCellName = 'Text';
  FormulaCellName = 'Formula';
  RepeatCellName = 'Repeat';
  DecPlacesPart = $0F;
  JustShift = 4;
  JustPart = $03;
  DollarPart = $40;
  CommasPart = $80;
  NoMemory = 203;

type
  CellTypes = (ClEmpty, ClValue, ClText, ClFormula, ClRepeat);
  CellPos = record
    Col : Word;
    Row : Word;
  end;
  FormatType = Byte;
  Justification = (JLeft, JCenter, JRight);
  DollarStr = String[Length(DollarString)];
  Block = object
    Start, Stop : CellPos;
    constructor Init(InitStart : CellPos);
    function ExtendTo(NewLoc : CellPos) : Boolean;
    function CellInBlock(CheckCell : CellPos) : Boolean;
  end;
  CellHashTablePtr = ^CellHashTable;
  CellPtr = ^Cell;
  CellHashTable = object(HashTable)  { Keeps pointers to all cells }
    CurrCell : CellPtr;    { Information about the cell that is being }
    CurrLoc : CellPos;     { added, deleted, or searched for }
    constructor Init(InitBuckets : BucketRange);
    destructor Done;
    function Add(ACell : CellPtr) : Boolean;
    procedure Delete(DelLoc : CellPos; var DeletedCell : CellPtr);
                           { Removes a cell from the hash table }
    function Search(SPos : CellPos) : CellPtr;
                        { Searches for a cell in the hash table }
    function HashValue : Word; virtual;
                        { Computes the hash value of the cell }
    function Found(Item : HashItemPtr) : Boolean; virtual;
           { Returns True if the hash item being searched for is found }
    procedure CreateItem(var Item : HashItemPtr); virtual;
                        { Fills in the information for a new hash item }
    function ItemSize : HashItemSizeRange; virtual;
    procedure Load(var S : TDosStream; Total : Longint);
    procedure Store(var S : TDosStream);
    function FirstItem : CellPtr;
    function NextItem : CellPtr;
  end;
  FormatHashTable = object(HashTable)
    CurrStart, CurrStop : CellPos;
    CurrFormat : FormatType;
    constructor Init;
    destructor Done;
    function Overwrite(NewStart, NewStop : CellPos) : Boolean;
    function Add(NewStart, NewStop : CellPos;
                 NewFormat : FormatType) : Boolean;
    function Delete(DStart, DStop : CellPos) : Boolean;
    function Search(SPos : CellPos; var F : FormatType) : Boolean;
    function HashValue : Word; virtual;
    function Found(Item : HashItemPtr) : Boolean; virtual;
    procedure CreateItem(var Item : HashItemPtr); virtual;
    function ItemSize : HashItemSizeRange; virtual;
    procedure Load(var S : TDosStream; Total : Longint);
    procedure Store(var S : TDosStream);
  end;
  WidthHashTable = object(HashTable)
    CurrCol : Word;
    CurrWidth : Byte;
    DefaultColWidth : Byte;
    constructor Init(InitBuckets : BucketRange; InitDefaultColWidth : Byte);
    destructor Done;
    function Add(SCol : Word; NewWidth : Byte) : Boolean;
    procedure Delete(Col : Word);
    function Search(Col : Word) : Byte;
    function HashValue : Word; virtual;
    function Found(Item : HashItemPtr) : Boolean; virtual;
    procedure CreateItem(var Item : HashItemPtr); virtual;
    function ItemSize : HashItemSizeRange; virtual;
    function GetDefaultColWidth : Byte;
    procedure Load(var S : TDosStream; Total : Longint);
    procedure Store(var S : TDosStream);
  end;
  OverwriteHashTable = object(HashTable)
    CurrCell : CellPtr;
    CurrPos : CellPos;
    EndCol : Word;
    constructor Init(InitBuckets : BucketRange);
    destructor Done;
    function Add(SCell : CellPtr; Overwritten : Word) : Boolean;
    procedure Delete(SPos : CellPos);
    function Change(SCell : CellPtr; Overwritten : Word) : Boolean;
    function Search(SPos : CellPos) : CellPtr;
    function HashValue : Word; virtual;
    function Found(Item : HashItemPtr) : Boolean; virtual;
    procedure CreateItem(var Item : HashItemPtr); virtual;
    function ItemSize : HashItemSizeRange; virtual;
  end;
  GetColWidthFunc = function(var WHash : WidthHashTable;
                             C : Word) : Byte;
  Cell = object(TObject)
    Loc : CellPos;
    constructor Init(InitLoc : CellPos);
    destructor Done; virtual;
    function CellType : CellTypes; virtual;
    function LegalValue : Boolean; virtual;
    function Name : String; virtual;
    function Format(var FHash : FormatHashTable;
                    FormulasDisplayed : Boolean) : FormatType; virtual;
    function Width(var FHash : FormatHashTable;
                   FormulasDisplayed : Boolean) : Word; virtual;
    function Overwritten(var CHash : CellHashTable;
                         var FHash : FormatHashTable;
                         var WHash : WidthHashTable; var LastPos : CellPos;
                         MaxCols : Word; GetColWidth : GetColWidthFunc;
                         FormulasDisplayed : Boolean) : Word; virtual;
    function ShouldUpdate : Boolean; virtual;
    function HasError : Boolean; virtual;
    function CurrValue : Extended; virtual;
    function OverwriteStart(var FHash : FormatHashTable;
                            var WHash : WidthHashTable;
                            GetColWidth : GetColWidthFunc; EndCol : Word;
                            DisplayFormulas : Boolean) : Word; virtual;
    procedure EditString(MaxDecPlaces : Byte; var L : LStringPtr); virtual;
    function DisplayString(FormulasDisplayed : Boolean;
                           MaxDecPlaces : Byte) : String; virtual;
    function FormattedString(var OHash : OverwriteHashTable;
                             var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc;
                             CPos : CellPos; FormulasDisplayed : Boolean;
                             Start : Word; ColWidth : Byte;
                             var DString : DollarStr;
                             var Color : Byte) : String; virtual;
    function CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                        var L : LStringPtr) : LStringPtr; virtual;
  end;
  EmptyCellPtr = ^EmptyCell;
  EmptyCell = object(Cell)
    constructor Init;
    function CellType : CellTypes; virtual;
    function LegalValue : Boolean; virtual;
    function Name : String; virtual;
    function Format(var FHash : FormatHashTable;
                    FormulasDisplayed : Boolean) : FormatType; virtual;
    function Width(var FHash : FormatHashTable;
                   FormulasDisplayed : Boolean) : Word; virtual;
    function Overwritten(var CHash : CellHashTable;
                         var FHash : FormatHashTable;
                         var WHash : WidthHashTable; var LastPos : CellPos;
                         MaxCols : Word; GetColWidth : GetColWidthFunc;
                         FormulasDisplayed : Boolean) : Word; virtual;
    function ShouldUpdate : Boolean; virtual;
    function HasError : Boolean; virtual;
    function CurrValue : Extended; virtual;
    function OverwriteStart(var FHash : FormatHashTable;
                            var WHash : WidthHashTable;
                            GetColWidth : GetColWidthFunc; EndCol : Word;
                            DisplayFormulas : Boolean) : Word; virtual;
    procedure EditString(MaxDecPlaces : Byte; var L : LStringPtr); virtual;
    function DisplayString(FormulasDisplayed : Boolean;
                           MaxDecPlaces : Byte) : String; virtual;
    function FormattedString(var OHash : OverwriteHashTable;
                             var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc;
                             CPos : CellPos; FormulasDisplayed : Boolean;
                             Start : Word; ColWidth : Byte;
                             var DString : DollarStr;
                             var Color : Byte) : String; virtual;
    function CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                        var L : LStringPtr) : LStringPtr; virtual;
  end;
  ValueCellPtr = ^ValueCell;
  ValueCell = object(Cell)
    Error : Boolean;
    Value : Extended;      { A cell with a numeric value }
    constructor Init(InitLoc : CellPos; InitError : Boolean;
                     InitValue : Extended);
    function CellType : CellTypes; virtual;
    function LegalValue : Boolean; virtual;
    function Name : String; virtual;
    function Format(var FHash : FormatHashTable;
                    FormulasDisplayed : Boolean) : FormatType; virtual;
    function Width(var FHash : FormatHashTable;
                   FormulasDisplayed : Boolean) : Word; virtual;
    function Overwritten(var CHash : CellHashTable;
                         var FHash : FormatHashTable;
                         var WHash : WidthHashTable; var LastPos : CellPos;
                         MaxCols : Word; GetColWidth : GetColWidthFunc;
                         FormulasDisplayed : Boolean) : Word; virtual;
    function ShouldUpdate : Boolean; virtual;
    function HasError : Boolean; virtual;
    function CurrValue : Extended; virtual;
    function OverwriteStart(var FHash : FormatHashTable;
                            var WHash : WidthHashTable;
                            GetColWidth : GetColWidthFunc; EndCol : Word;
                            DisplayFormulas : Boolean) : Word; virtual;
    procedure EditString(MaxDecPlaces : Byte; var L : LStringPtr); virtual;
    function DisplayString(FormulasDisplayed : Boolean;
                           MaxDecPlaces : Byte) : String; virtual;
    function FormattedString(var OHash : OverwriteHashTable;
                             var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc;
                             CPos : CellPos; FormulasDisplayed : Boolean;
                             Start : Word; ColWidth : Byte;
                             var DString : DollarStr;
                             var Color : Byte) : String; virtual;
    function CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                        var L : LStringPtr) : LStringPtr; virtual;
    constructor Load(var S : TDosStream);
    procedure Store(var S : TDosStream);
  end;
  TextCellPtr = ^TextCell;
  TextCell = object(Cell)
    Txt : LStringPtr;       { A cell with text }
    constructor Init(InitLoc : CellPos; InitTxt : LStringPtr);
    destructor Done; virtual;
    function CellType : CellTypes; virtual;
    function LegalValue : Boolean; virtual;
    function Name : String; virtual;
    function Format(var FHash : FormatHashTable;
                    FormulasDisplayed : Boolean) : FormatType; virtual;
    function Width(var FHash : FormatHashTable;
                   FormulasDisplayed : Boolean) : Word; virtual;
    function Overwritten(var CHash : CellHashTable;
                         var FHash : FormatHashTable;
                         var WHash : WidthHashTable; var LastPos : CellPos;
                         MaxCols : Word; GetColWidth : GetColWidthFunc;
                         FormulasDisplayed : Boolean) : Word; virtual;
    function ShouldUpdate : Boolean; virtual;
    function HasError : Boolean; virtual;
    function CurrValue : Extended; virtual;
    function OverwriteStart(var FHash : FormatHashTable;
                            var WHash : WidthHashTable;
                            GetColWidth : GetColWidthFunc; EndCol : Word;
                            DisplayFormulas : Boolean) : Word; virtual;
    procedure EditString(MaxDecPlaces : Byte; var L : LStringPtr); virtual;
    function DisplayString(FormulasDisplayed : Boolean;
                           MaxDecPlaces : Byte) : String; virtual;
    function FormattedString(var OHash : OverwriteHashTable;
                             var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc;
                             CPos : CellPos; FormulasDisplayed : Boolean;
                             Start : Word; ColWidth : Byte;
                             var DString : DollarStr;
                             var Color : Byte) : String; virtual;
    function CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                        var L : LStringPtr) : LStringPtr; virtual;
    constructor Load(var S : TDosStream);
    procedure Store(var S : TDosStream);
  end;
  FormulaCellPtr = ^FormulaCell;
  FormulaCell = object(Cell)
    Error : Boolean;
    Value : Extended;
    Formula : LStringPtr;   { A cell with a formula }
    constructor Init(InitLoc : CellPos; InitError : Boolean;
                     InitValue : Extended; InitFormula : LStringPtr);
    destructor Done; virtual;
    function CellType : CellTypes; virtual;
    function LegalValue : Boolean; virtual;
    function Name : String; virtual;
    function Format(var FHash : FormatHashTable;
                    FormulasDisplayed : Boolean) : FormatType; virtual;
    function Width(var FHash : FormatHashTable;
                   FormulasDisplayed : Boolean) : Word; virtual;
    function Overwritten(var CHash : CellHashTable;
                         var FHash : FormatHashTable;
                         var WHash : WidthHashTable; var LastPos : CellPos;
                         MaxCols : Word; GetColWidth : GetColWidthFunc;
                         FormulasDisplayed : Boolean) : Word; virtual;
    function ShouldUpdate : Boolean; virtual;
    function HasError : Boolean; virtual;
    function CurrValue : Extended; virtual;
    function OverwriteStart(var FHash : FormatHashTable;
                            var WHash : WidthHashTable;
                            GetColWidth : GetColWidthFunc; EndCol : Word;
                            DisplayFormulas : Boolean) : Word; virtual;
    procedure EditString(MaxDecPlaces : Byte; var L : LStringPtr); virtual;
    function DisplayString(FormulasDisplayed : Boolean;
                           MaxDecPlaces : Byte) : String; virtual;
    function FormattedString(var OHash : OverwriteHashTable;
                             var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc;
                             CPos : CellPos; FormulasDisplayed : Boolean;
                             Start : Word; ColWidth : Byte;
                             var DString : DollarStr;
                             var Color : Byte) : String; virtual;
    function CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                        var L : LStringPtr) : LStringPtr; virtual;
    constructor Load(var S : TDosStream);
    procedure Store(var S : TDosStream);
    function GetFormula : LStringPtr;
  end;
  RepeatCellPtr = ^RepeatCell;
  RepeatCell = object(Cell)
    RepeatChar : Char;   { A cell with text that will repeat - used for
                           underlining, etc. }
    constructor Init(InitLoc : CellPos; InitChar : Char);
    function CellType : CellTypes; virtual;
    function LegalValue : Boolean; virtual;
    function Name : String; virtual;
    function Format(var FHash : FormatHashTable;
                    FormulasDisplayed : Boolean) : FormatType; virtual;
    function Width(var FHash : FormatHashTable;
                   FormulasDisplayed : Boolean) : Word; virtual;
    function Overwritten(var CHash : CellHashTable;
                         var FHash : FormatHashTable;
                         var WHash : WidthHashTable; var LastPos : CellPos;
                         MaxCols : Word; GetColWidth : GetColWidthFunc;
                         FormulasDisplayed : Boolean) : Word; virtual;
    function ShouldUpdate : Boolean; virtual;
    function HasError : Boolean; virtual;
    function CurrValue : Extended; virtual;
    function OverwriteStart(var FHash : FormatHashTable;
                            var WHash : WidthHashTable;
                            GetColWidth : GetColWidthFunc; EndCol : Word;
                            DisplayFormulas : Boolean) : Word; virtual;
    procedure EditString(MaxDecPlaces : Byte; var L : LStringPtr); virtual;
    function DisplayString(FormulasDisplayed : Boolean;
                           MaxDecPlaces : Byte) : String; virtual;
    function FormattedString(var OHash : OverwriteHashTable;
                             var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc;
                             CPos : CellPos; FormulasDisplayed : Boolean;
                             Start : Word; ColWidth : Byte;
                             var DString : DollarStr;
                             var Color : Byte) : String; virtual;
    function CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                        var L : LStringPtr) : LStringPtr; virtual;
    constructor Load(var S : TDosStream);
    procedure Store(var S : TDosStream);
  end;

var
  Empty : CellPtr;   { This is a special cell.  It is used as the return
                       value if a cell cannot be found so that the EmptyCell
                       methods can be executed instead of having special
                       routines that act differently depending on whether a
                       cell is found ot not. }

const

  { Stream registration records for the object types that will be written
    to and read from the stream.  }

  RValueCell: TStreamRec = (
    ObjType: 1000;                   { an arbitrary, but unique number }
    VmtLink: Ofs(TypeOf(ValueCell)^);
    Load: @ValueCell.Load;
    Store: @ValueCell.Store
  );

  RTextCell: TStreamRec = (
    ObjType: 1001;
    VmtLink: Ofs(TypeOf(TextCell)^);
    Load: @TextCell.Load;
    Store: @TextCell.Store
  );

  RFormulaCell: TStreamRec = (
    ObjType: 1002;
    VmtLink: Ofs(TypeOf(FormulaCell)^);
    Load: @FormulaCell.Load;
    Store: @FormulaCell.Store
  );

  RRepeatCell: TStreamRec = (
    ObjType: 1003;
    VmtLink: Ofs(TypeOf(RepeatCell)^);
    Load: @RepeatCell.Load;
    Store: @RepeatCell.Store
  );



procedure RegisterCellTypes;



implementation

var
  SavedExitProc : Pointer;


procedure RegisterCellTypes;
{ Registers the different cell types so that they will be written out
  correctly to disk }
begin
  RegisterType(RValueCell);
  RegisterType(RTextCell);
  RegisterType(RFormulaCell);
  RegisterType(RRepeatCell);
end; { RegisterCellTypes }

constructor Block.Init(InitStart : CellPos);
{ Initializes a block of cells, setting the end to be the same as the start }
begin
  Start := InitStart;
  Stop := Start;
end; { Block.Init }

function Block.ExtendTo(NewLoc : CellPos) : Boolean;
{ Extends a block to a new position, as long as the new position is to the
  right and down from the old position }
begin
  if (NewLoc.Col >= Start.Col) and (NewLoc.Row >= Start.Row) then
  begin
    Stop := NewLoc;
    ExtendTo := True;
  end
  else
    ExtendTo := False;
end; { Block.ExtendTo }

function Block.CellInBlock(CheckCell : CellPos) : Boolean;
{ Checks to see if a cell is inside a particular block }
begin
  CellInBlock := (CheckCell.Col >= Start.Col) and
                 (CheckCell.Col <= Stop.Col) and
                 (CheckCell.Row >= Start.Row) and
                 (CheckCell.Row <= Stop.Row);
end; { Block.CellInBlock }

constructor CellHashTable.Init(InitBuckets : BucketRange);
{ Initializes a cell hash table, which stores pointers to the cells in a
  spreadsheet }
begin
  if not HashTable.Init(InitBuckets) then
    Fail;
end; { CellHashTable.Init }

destructor CellHashTable.Done;
{ Removes a cell hash table from memory }
var
  CP : CellPtr;
begin
  CP := FirstItem;
  while CP <> nil do
  begin
    Dispose(CP, Done);
    CP := NextItem;
  end;
  HashTable.Done;
end; { CellHashTable.Done }

function CellHashTable.Add(ACell : CellPtr) : Boolean;
{ Adds a cell to a cell hash table }
begin
  CurrCell := ACell;
  CurrLoc := CurrCell^.Loc;
  Add := HashTable.Add;
end; { CellHashTable.Add }

procedure CellHashTable.Delete(DelLoc : CellPos; var DeletedCell : CellPtr);
{ Deletes a cell from a cell hash table }
begin
  CurrLoc := DelLoc;
  HashTable.Delete(@DeletedCell);
end; { CellHashTable.Delete }

function CellHashTable.Search(SPos : CellPos) : CellPtr;
{ Searches for a cell in a cell hash table, returning the cell if found, or
  returning the Empty cell if not found }
var
  I : HashItemPtr;
  C : CellPtr;
begin
  CurrLoc := SPos;
  I := HashTable.Search;
  if I = nil then
    Search := Empty
  else begin
    Move(I^.Data, C, SizeOf(C));
    Search := C;
  end;
end; { CellHashTable.Search }

function CellHashTable.HashValue : Word;
{ Calculates the hash value of a cell }
begin
  HashValue := CurrLoc.Col + CurrLoc.Row;
end; { CellHashTable.HashValue }

function CellHashTable.Found(Item : HashItemPtr) : Boolean;
{ Checks to see if a hash item is the one searched for by comparing the
  location information in both }
var
  C : CellPtr;
begin
  Move(Item^.Data, C, SizeOf(C));
  Found := Compare(C^.Loc, CurrLoc, SizeOf(CurrLoc));
end; { CellHashTable.Found }

procedure CellHashTable.CreateItem(var Item : HashItemPtr);
{ Writes the cell poionter information out to the hash item }
begin
  Move(CurrCell, Item^.Data, SizeOf(CurrCell));
end; { CellHashTable.CreateItem }

function CellHashTable.ItemSize : HashItemSizeRange;
{ The hash item size is current - just cell pointers are stored }
begin
  ItemSize := SizeOf(CurrCell);
end; { CellHashTable.ItemSize }

procedure CellHashTable.Load(var S : TDosStream; Total : Longint);
{ Loads a cell hash table from disk }
var
  Counter : Longint;
begin
  for Counter := 1 to Total do
  begin
    if not Add(CellPtr(S.Get)) then
    begin
      S.Error(NoMemory, 0);
      Exit;
    end;
  end;
end; { CellHashTable.Load }

procedure CellHashTable.Store(var S : TDosStream);
{ Writes a cell hash table to disk }
var
  CP : CellPtr;
begin
  CP := FirstItem;
  while CP <> nil do
  begin
    S.Put(CP);
    CP := NextItem;
  end;
end; { CellHashTable.Store }

function HashItemPtrToCellPtr(H : HashItemPtr) : CellPtr;
{ Converts a hash item pointer to a cell pointer }
var
  CP : CellPtr;
begin
  if H = nil then
    HashItemPtrToCellPtr := nil
  else begin
    Move(H^.Data, CP, SizeOf(CP));
    HashItemPtrToCellPtr := CP;
  end;
end; { HashItemPtrToCellPtr }

function CellHashTable.FirstItem : CellPtr;
{ Returns the first hash item in a cell hash table }
begin
  FirstItem := HashItemPtrToCellPtr(HashTable.FirstItem);
end; { CellHashTable.FirstItem }

function CellHashTable.NextItem : CellPtr;
{ Returns the second and subsequent hash items in a cell hash table }
begin
  NextItem := HashItemPtrToCellPtr(HashTable.NextItem);
end; { CellHashTable.NextItem }

constructor WidthHashTable.Init(InitBuckets : BucketRange;
                                InitDefaultColWidth : Byte);
{ Initializes the width hash table, which stores column widths that are
  different than the default.  It stores the column and the width in the
  hash table }
begin
  if not HashTable.Init(InitBuckets) then
    Fail;
  DefaultColWidth := InitDefaultColWidth;
end; { WidthHashTable.Init }

destructor WidthHashTable.Done;
begin
  HashTable.Done;
end; { WidthHashTable.Done }

function WidthHashTable.Add(SCol : Word; NewWidth : Byte) : Boolean;
begin
  CurrCol := SCol;
  CurrWidth := NewWidth;
  Add := HashTable.Add;
end; { WidthHashTable }

procedure WidthHashTable.Delete(Col : Word);
begin
  CurrCol := Col;
  HashTable.Delete(nil);
end; { WidthHashTable.Delete }

function WidthHashTable.Search(Col : Word) : Byte;
var
  I : HashItemPtr;
  W : Byte;
begin
  CurrCol := Col;
  I := HashTable.Search;
  if I = nil then
    Search := 0
  else begin
    Move(I^.Data[SizeOf(CurrCol)], W, SizeOf(W));
    Search := W;
  end;
end; { WidthHashTable.Search }

function WidthHashTable.HashValue : Word;
begin
  HashValue := CurrCol;
end; { WidthHashTable.HashValue }

function WidthHashTable.Found(Item : HashItemPtr) : Boolean;
var
  C : Word;
begin
  Move(Item^.Data, C, SizeOf(C));
  Found := CurrCol = C;
end; { WidthHashTable.Found }

procedure WidthHashTable.CreateItem(var Item : HashItemPtr);
begin
  Move(CurrCol, Item^.Data, SizeOf(CurrCol));
  Move(CurrWidth, Item^.Data[SizeOf(CurrCol)], SizeOf(CurrWidth));
end; { WidthHashTable.CreateItem }

function WidthHashTable.ItemSize : HashItemSizeRange;
begin
  ItemSize := SizeOf(CurrCol) + SizeOf(CurrWidth);
end; { WidthHashTable.ItemSize }

function WidthHashTable.GetDefaultColWidth : Byte;
begin
  GetDefaultColWidth := DefaultColWidth;
end; { WidthHashTable.GetDefaultColWidth }

procedure WidthHashTable.Load(var S : TDosStream; Total : Longint);
var
  Counter : Longint;
  Col : Word;
  Width : Byte;
begin
  for Counter := 1 to Total do
  begin
    S.Read(Col, SizeOf(Col));
    S.Read(Width, SizeOf(Width));
    if not Add(Col, Width) then
    begin
      S.Error(NoMemory, 0);
      Exit;
    end;
  end;
end; { WidthHashTable.Load }

procedure WidthHashTable.Store(var S : TDosStream);
var
  H : HashItemPtr;
  Col : Word;
  Width : Byte;
begin
  H := FirstItem;
  while H <> nil do
  begin
    Move(H^.Data, Col, SizeOf(Col));
    S.Write(Col, SizeOf(Col));
    Move(H^.Data[SizeOf(Col)], Width, SizeOf(Width));
    S.Write(Width, SizeOf(Width));
    H := NextItem;
  end;
end; { WidthHashTable.Store }

constructor FormatHashTable.Init;
{ Initializes a format hash table, which is used to store formatted areas
  that differ from the default.  The area and the format are stored in the
  hash table }
begin
  if not HashTable.Init(1) then   { Use a single bucket so that a search
    Fail;                           will be possible }
end; { FormatHashTable.Init }

destructor FormatHashTable.Done;
begin
  HashTable.Done;
end; { FormatHashTable.Done }

function FormatHashTable.Overwrite(NewStart, NewStop : CellPos) : Boolean;
{ Checks to see if a new format area has overwritten an old one, requiring
  the old area to be overwritten or broken into parts }
var
  H : HashItemPtr;
  AStart, AStop, BStart, BStop : CellPos;
  OldF, F : FormatType;
  P : CellPos;
  Added : Boolean;
begin
  Overwrite := False;
  H := HashData^[1];
  while H <> nil do
  begin
    Move(H^.Data, BStart, SizeOf(CellPos));
    Move(H^.Data[SizeOf(CellPos)], BStop, SizeOf(CellPos));
    if ((((NewStart.Col >= BStart.Col) and (NewStart.Col <= BStop.Col)) or
         ((NewStop.Col >= BStart.Col) and (NewStop.Col <= BStop.Col))) and
        (((NewStart.Row >= BStart.Row) and (NewStart.Row <= BStop.Row)) or
         ((NewStop.Row >= BStart.Row) and (NewStop.Row <= BStop.Row)))) or
       ((((BStart.Col >= NewStart.Col) and (BStart.Col <= NewStop.Col)) or
         ((BStop.Col >= NewStart.Col) and (BStop.Col <= NewStop.Col))) and
        (((BStart.Row >= NewStart.Row) and (BStart.Row <= NewStop.Row)) or
         ((BStop.Row >= NewStart.Row) and (BStop.Row <= NewStop.Row)))) then
    begin
      Move(H^.Data[SizeOf(CellPos) shl 1], F, SizeOf(F));
      CurrStart := BStart;
      CurrStop := BStop;
      HashTable.Delete(nil);
      if BStart.Row < NewStart.Row then
      begin
        AStart := BStart;
        AStop.Col := BStop.Col;
        AStop.Row := Pred(NewStart.Row);
        if not Add(AStart, AStop, F) then
          Exit;
      end;
      if BStop.Row > NewStop.Row then
      begin
        AStart.Col := BStart.Col;
        AStart.Row := Succ(NewStop.Row);
        AStop.Col := BStop.Col;
        AStop.Row := BStop.Row;
        if not Add(AStart, AStop, F) then
          Exit;
      end;
      if BStart.Col < NewStart.Col then
      begin
        AStart.Col := BStart.Col;
        AStart.Row := Max(BStart.Row, NewStart.Row);
        AStop.Col := Pred(NewStart.Col);
        AStop.Row := Min(BStop.Row, NewStop.Row);
        if not Add(AStart, AStop, F) then
          Exit;
      end;
      if BStop.Col > NewStop.Col then
      begin
        AStart.Col := Succ(NewStop.Col);
        AStart.Row := Max(BStart.Row, NewStart.Row);
        AStop.Col := BStop.Col;
        AStop.Row := Min(BStop.Row, NewStop.Row);
        if not Add(AStart, AStop, F) then
          Exit;
      end;
    end;
    H := H^.Next;
  end;
  Overwrite := True;
end; { FormatHashTable.Overwrite }

function FormatHashTable.Add(NewStart, NewStop : CellPos;
                             NewFormat : FormatType) : Boolean;
begin
  if not Overwrite(NewStart, NewStop) then
  begin
    Add := False;
    Exit;
  end;
  CurrStart := NewStart;
  CurrStop := NewStop;
  CurrFormat := NewFormat;
  Add := HashTable.Add;
end; { FormatHashTable.Add }

function FormatHashTable.Delete(DStart, DStop : CellPos) : Boolean;
begin
  Delete := Overwrite(DStart, DStop);
end; { FormatHashTable.Delete }

function FormatHashTable.Search(SPos : CellPos; var F : FormatType) :
                                Boolean;
var
  H : HashItemPtr;
begin
  CurrStart := SPos;
  H := HashTable.Search;
  if H = nil then
    Search := False
  else begin
    Move(H^.Data[SizeOf(CellPos) shl 1], F, SizeOf(F));
    Search := True;
  end;
end; { FormatHashTable.Search }

function FormatHashTable.HashValue : Word;
{ Since the hash table has only one bucket, the hash value is always 1 }
begin
  HashValue := 1;
end; { FormatHashTable.HashValue }

function FormatHashTable.Found(Item : HashItemPtr) : Boolean;
var
  P : CellPos;
  B : Block;
  Start, Stop : CellPos;
  Good : Boolean;
begin
  Move(Item^.Data, Start, SizeOf(CellPos));
  Move(Item^.Data[SizeOf(CellPos)], Stop, SizeOf(CellPos));
  B.Init(Start);
  B.Stop := Stop;
  Found := B.CellInBlock(CurrStart);
end; { FormatHashTable.Found }

procedure FormatHashTable.CreateItem(var Item : HashItemPtr);
begin
  with Item^ do
  begin
    Move(CurrStart, Data, SizeOf(CellPos));
    Move(CurrStop, Data[SizeOf(CellPos)], SizeOf(CellPos));
    Move(CurrFormat, Data[SizeOf(CellPos) shl 1], SizeOf(CurrFormat));
  end; { with }
end; { FormatHashTable.CreateItem }

function FormatHashTable.ItemSize : HashItemSizeRange;
begin
  ItemSize := (SizeOf(CellPos) shl 1) + SizeOf(FormatType);
end; { FormatHashTable.ItemSize }

procedure FormatHashTable.Load(var S : TDosStream; Total : Longint);
var
  Counter : Longint;
  C1, C2 : CellPos;
  Format : FormatType;
begin
  for Counter := 1 to Total do
  begin
    S.Read(C1, SizeOf(C1));
    S.Read(C2, SizeOf(C2));
    S.Read(Format, SizeOf(Format));
    if not Add(C1, C2, Format) then
    begin
      S.Error(NoMemory, 0);
      Exit;
    end;
  end;
end; { FormatHashTable.Load }

procedure FormatHashTable.Store(var S : TDosStream);
var
  H : HashItemPtr;
  C : CellPos;
  Format : Byte;
begin
  H := FirstItem;
  while H <> nil do
  begin
    Move(H^.Data, C, SizeOf(C));
    S.Write(C, SizeOf(C));
    Move(H^.Data[SizeOf(CellPos)], C, SizeOf(C));
    S.Write(C, SizeOf(C));
    Move(H^.Data[SizeOf(CellPos) shl 1], Format, SizeOf(Format));
    S.Write(Format, SizeOf(Format));
    H := NextItem;
  end;
end; { FormatHashTable.Store }

constructor OverwriteHashTable.Init(InitBuckets : BucketRange);
{ Initializes an overwrite hash table, which keeps track of which cells are
  overwritten by other cells }
begin
  if not HashTable.Init(InitBuckets) then
    Fail;
end; { OverwriteHashTable.Init }

destructor OverwriteHashTable.Done;
begin
  HashTable.Done;
end; { OverwriteHashTable.Done }

function OverwriteHashTable.Add(SCell : CellPtr;
                                Overwritten : Word) : Boolean;
var
  CP : CellPtr;
begin
  if Overwritten = 0 then
  begin
    Add := True;
    Exit;
  end;
  CP := Search(SCell^.Loc);
  if CP <> Empty then
  begin
    if not Change(CP, Pred(SCell^.Loc.Col)) then
    begin
      Add := False;
      Exit;
    end;
  end;
  CurrCell := SCell;
  CurrPos := SCell^.Loc;
  EndCol := CurrPos.Col + Overwritten;
  Add := HashTable.Add;
end; { OverwriteHashTable.Add }

procedure OverwriteHashTable.Delete(SPos : CellPos);
begin
  CurrPos := SPos;
  HashTable.Delete(nil);
end; { OverwriteHashTable.Delete }

function OverwriteHashTable.Change(SCell : CellPtr;
                                   Overwritten : Word) : Boolean;
begin
  if Overwritten = 0 then
  begin
    Delete(SCell^.Loc);
    Change := True;
  end
  else begin
    CurrCell := SCell;
    CurrPos := CurrCell^.Loc;
    EndCol := SCell^.Loc.Col + Overwritten;
    Change := HashTable.Change;
  end;
end; { OverwriteHashTable.Change }

function OverwriteHashTable.Search(SPos : CellPos) : CellPtr;
var
  I : HashItemPtr;
  C : CellPtr;
begin
  CurrPos := SPos;
  I := HashTable.Search;
  if I = nil then
    Search := Empty
  else begin
    Move(I^.Data, C, SizeOf(C));
    Search := C;
  end;
end; { OverwriteHashTable.Search }

function OverwriteHashTable.HashValue : Word;
begin
  HashValue := CurrPos.Row;
end; { OverwriteHashTable.HashValue }

function OverwriteHashTable.Found(Item : HashItemPtr) : Boolean;
var
  C : CellPtr;
  E : Word;
begin
  Move(Item^.Data, C, SizeOf(C));
  Move(Item^.Data[SizeOf(C)], E, SizeOf(E));
  with CurrPos do
    Found := (Row = C^.Loc.Row) and (Col >= C^.Loc.Col) and
             (Col <= E);
end; { OverwriteHashTable.Found }

procedure OverwriteHashTable.CreateItem(var Item : HashItemPtr);
begin
  Move(CurrCell, Item^.Data, SizeOf(CurrCell));
  Move(EndCol, Item^.Data[SizeOf(CurrCell)], SizeOf(EndCol));
end; { OverwriteHashTable.CreateItem }

function OverwriteHashTable.ItemSize : HashItemSizeRange;
begin
  ItemSize := SizeOf(CurrCell) + SizeOf(EndCol);
end; { OverwriteHashTable.ItemSize }

constructor Cell.Init(InitLoc : CellPos);
{ Initializes a cell's location }
begin
  Loc := InitLoc;
end; { Cell.Init }

destructor Cell.Done;
{ Frees memory used by the cell }
begin
end; { Cell.Done }

function Cell.CellType : CellTypes;
{ Returns the type of a cell - used in copying cells }
begin
  Abstract('Cell.CellType');
end; { Cell.CellType }

function Cell.LegalValue : Boolean;
{ Returns True if the cell has a legal numeric value }
begin
  Abstract('Cell.LegalValue');
end; { Cell.LegalValue }

function Cell.Name : String;
{ Returns the name of the cell type }
begin
  Abstract('Cell.Name');
end; { Cell.Name }

function Cell.Format(var FHash : FormatHashTable; FormulasDisplayed : Boolean) :
                         FormatType;
{ Returns the format of a cell }
begin
  Abstract('Cell.Format');
end; { Cell.Format }

function Cell.Width(var FHash : FormatHashTable; FormulasDisplayed : Boolean) :
                        Word;
{ Returns the width of a cell (including the cells that it will overwrite) }
begin
  Abstract('Cell.Width');
end; { Cell.Width }

function Cell.Overwritten(var CHash : CellHashTable;
                               var FHash : FormatHashTable;
                               var WHash : WidthHashTable;
                               var LastPos : CellPos;
                               MaxCols : Word;
                               GetColWidth : GetColWidthFunc;
                               FormulasDisplayed : Boolean) : Word;
{ Calculates how many cells a cell will overwrite }
begin
  Abstract('Cell.Overwritten');
end; { Cell.Overwritten }

function Cell.ShouldUpdate : Boolean;
{ Returns True if the cell needs to be updated when the spreadsheet changes }
begin
  Abstract('Cell.ShouldUpdate');
end; { Cell.ShouldUpdate }

function Cell.HasError : Boolean;
{ Returns True if the cell has a numeric error in it }
begin
  Abstract('Cell.HasError');
end; { Cell.HasError }

function Cell.CurrValue : Extended;
{ Returns the current numeric value of a cell }
begin
  Abstract('Cell.CurrValue');
end; { Cell.CurrValue }

function Cell.OverwriteStart(var FHash : FormatHashTable;
                             var WHash : WidthHashTable;
                             GetColWidth : GetColWidthFunc; EndCol : Word;
                             DisplayFormulas : Boolean) : Word;
{ Determines, for overwritten cells, where in the overwriting data they will
  Start to display a value }
begin
  Abstract('Cell.OverwriteStart');
end; { Cell.OverwriteStart }

procedure Cell.EditString(MaxDecPlaces : Byte;
                          var L : LStringPtr);
{ Sets up a long string with the cell's value that can be edited }
begin
  Abstract('Cell.EditString');
end; { Cell.EditString }

function Cell.DisplayString(FormulasDisplayed : Boolean;
                            MaxDecPlaces : Byte) : String;
{ Returns the string that will be displayed just above the input line }
begin
  Abstract('Cell.DisplayString');
end; { Cell.DisplayString }

function Cell.FormattedString(var OHash : OverwriteHashTable;
                              var FHash : FormatHashTable;
                              var WHash : WidthHashTable;
                              GetColWidth : GetColWidthFunc;
                              CPos : CellPos; FormulasDisplayed : Boolean;
                              Start : Word; ColWidth : Byte;
                              var DString : DollarStr;
                              var Color : Byte) : String;
{ Returns the string that will be printed in a cell }
begin
  Abstract('Cell.FormattedString');
end; { Cell.FormattedString }

function Cell.CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                         var L : LStringPtr) : LStringPtr;
{ Copies a cell's string information to another cell's }
begin
  Abstract('Cell.CopyString');
end; { Cell.CopyString }

constructor EmptyCell.Init;
var
  NewLoc : CellPos;
begin
  NewLoc.Col := 0;
  NewLoc.Row := 0;
  Cell.Init(NewLoc);
end; { EmptyCell.Init }

function EmptyCell.CellType : CellTypes;
begin
  CellType := ClEmpty;
end; { EmptyCell.CellType }

function EmptyCell.LegalValue : Boolean;
begin
  LegalValue := True;
end; { EmptyCell.LegalValue }

function EmptyCell.Name : String;
begin
  Name := EmptyCellName;
end; { EmptyCell.Name }

function EmptyCell.Format(var FHash : FormatHashTable;
                              FormulasDisplayed : Boolean) : FormatType;
begin
  Format := 0;
end; { EmptyCell.Format }

function EmptyCell.Width(var FHash : FormatHashTable;
                             FormulasDisplayed : Boolean) : Word;
begin
  Width := 0;
end; { EmptyCell.Width }

function EmptyCell.Overwritten(var CHash : CellHashTable;
                                    var FHash : FormatHashTable;
                                    var WHash : WidthHashTable;
                                    var LastPos : CellPos;
                                    MaxCols : Word;
                                    GetColWidth : GetColWidthFunc;
                                    FormulasDisplayed : Boolean) : Word;
begin
  Overwritten := 0;
end; { EmptyCell.Overwritten }

function EmptyCell.ShouldUpdate : Boolean;
begin
  ShouldUpdate := False;
end; { EmptyCell.ShouldUpdate }

function EmptyCell.HasError : Boolean;
begin
  HasError := False;
end; { Cell.HasError }

function EmptyCell.CurrValue : Extended;
begin
  CurrValue := 0;
end; { EmptyCell.CurrValue }

function EmptyCell.OverwriteStart(var FHash : FormatHashTable;
                                  var WHash : WidthHashTable;
                                  GetColWidth : GetColWidthFunc;
                                  EndCol : Word;
                                  DisplayFormulas : Boolean) : Word;
begin
  OverwriteStart := 1;
end; { EmptyCell.OverwriteStart }

procedure EmptyCell.EditString(MaxDecPlaces : Byte;
                                     var L : LStringPtr);
var
  Good : Boolean;
begin
  Good := L^.FromString('');
end; { EmptyCell.EditString }

function EmptyCell.DisplayString(FormulasDisplayed : Boolean;
                                       MaxDecPlaces : Byte) : String;
begin
  DisplayString := '';
end; { EmptyCell.DisplayString }

function EmptyCell.FormattedString(var OHash : OverwriteHashTable;
                                   var FHash : FormatHashTable;
                                   var WHash : WidthHashTable;
                                   GetColWidth : GetColWidthFunc;
                                   CPos : CellPos;
                                   FormulasDisplayed : Boolean;
                                   Start : Word; ColWidth : Byte;
                                   var DString : DollarStr;
                                   var Color : Byte) : String;
var
  CP : CellPtr;
begin
  CP := OHash.Search(CPos);
  if CP <> Empty then
    FormattedString := CP^.FormattedString(OHash, FHash, WHash, GetColWidth,
                                           Loc, FormulasDisplayed,
                                           CP^.OverWriteStart(FHash, WHash,
                                           GetColWidth, CPos.Col,
                                           FormulasDisplayed), ColWidth,
                                           DString, Color)
  else begin
    FormattedString := '';
    DString := '';
    Color := Colors.BlankColor;
  end;
end; { EmptyCell.FormattedString }

function EmptyCell.CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                              var L : LStringPtr) : LStringPtr;
begin
  CopyString := L;
end; { EmptyCell.CopyString }

constructor ValueCell.Init(InitLoc : CellPos; InitError : Boolean;
                           InitValue : Extended);
begin
  Cell.Init(InitLoc);
  Error := InitError;
  Value := InitValue;
end; { ValueCell.Init }

function ValueCell.CellType : CellTypes;
begin
  CellType := ClValue;
end; { ValueCell.CellType }

function ValueCell.LegalValue : Boolean;
begin
  LegalValue := True;
end; { ValueCell.LegalValue }

function ValueCell.Name : String;
begin
  Name := ValueCellName;
end; { ValueCell.Name }

function ValueCell.Format(var FHash : FormatHashTable;
                              FormulasDisplayed : Boolean) : FormatType;
var
  F : FormatType;
begin
  if FHash.Search(Loc, F) then
    Format := F
  else
    Format := (Ord(JRight) shl 4) + 4;
end; { ValueCell.Format }

function ValueCell.Width(var FHash : FormatHashTable;
                             FormulasDisplayed : Boolean) : Word;
var
  S : String;
  F : FormatType;
  P, W : Word;
begin
  F := Format(FHash, FormulasDisplayed);
  Str(Value:1:(F and DecPlacesPart), S);
  W := Length(S);
  if (F and DollarPart) <> 0 then
    Inc(W, Length(DollarString));
  if (F and CommasPart) <> 0 then
  begin
    P := Pos('.', S);
    if P = 0 then
      P := Length(S);
    Inc(W, (P - 2) div 3);
  end;
  Width := W;
end; { ValueCell.Width }

function ValueCell.Overwritten(var CHash : CellHashTable;
                               var FHash : FormatHashTable;
                               var WHash : WidthHashTable;
                               var LastPos : CellPos;
                               MaxCols : Word;
                               GetColWidth : GetColWidthFunc;
                               FormulasDisplayed : Boolean) : Word;
var
  CellWidth : Longint;
  Total : Word;
  P : CellPos;
begin
  P := Loc;
  CellWidth := Width(FHash, FormulasDisplayed);
  Total := 0;
  repeat
    Inc(Total);
    Dec(CellWidth, GetColWidth(WHash, P.Col));
    Inc(P.Col);
  until (CellWidth <= 0) or (P.Col = MaxCols) or (CHash.Search(P) <> Empty);
  Dec(Total);
  Overwritten := Total;
end; { ValueCell.Overwritten }

function ValueCell.ShouldUpdate : Boolean;
begin
  ShouldUpdate := False;
end; { ValueCell.ShouldUpdate }

function ValueCell.HasError : Boolean;
begin
  HasError := Error;
end; { ValueCell.HasError }

function ValueCell.CurrValue : Extended;
begin
  CurrValue := Value;
end; { ValueCell.CurrValue }

function ValueCell.OverwriteStart(var FHash : FormatHashTable;
                                  var WHash : WidthHashTable;
                                  GetColWidth : GetColWidthFunc;
                                  EndCol : Word;
                                  DisplayFormulas : Boolean) : Word;
var
  F : FormatType;
  C, Place : Word;
begin
  F := Format(FHash, DisplayFormulas);
  Place := 1;
  C := Loc.Col;
  repeat
    Inc(Place, GetColWidth(WHash, C));
    Inc(C);
  until C = EndCol;
  if (F and DollarPart) <> 0 then
    Dec(Place, Length(DollarString));
  OverwriteStart := Place;
end; { ValueCell.OverwriteStart }

procedure ValueCell.EditString(MaxDecPlaces : Byte;
                                     var L : LStringPtr);
var
  S : String;
  Good : Boolean;
begin
  Str(Value:1:MaxDecPlaces, S);
  Good := L^.FromString(S);
end; { ValueCell.EditString }

function ValueCell.DisplayString(FormulasDisplayed : Boolean;
                                       MaxDecPlaces : Byte) : String;
var
  S : String;
begin
  Str(Value:1:MaxDecPlaces, S);
  DisplayString := S;
end; { ValueCell.DisplayString }

function ValueCell.FormattedString(var OHash : OverwriteHashTable;
                                   var FHash : FormatHashTable;
                                   var WHash : WidthHashTable;
                                   GetColWidth : GetColWidthFunc;
                                   CPos : CellPos;
                                   FormulasDisplayed : Boolean;
                                   Start : Word; ColWidth : Byte;
                                   var DString : DollarStr;
                                   var Color : Byte) : String;
var
  Counter : Word;
  S : String;
  F : FormatType;
begin
  F := Format(FHash, FormulasDisplayed);
  Str(Value:1:F and DecPlacesPart, S);
  if (Start = 1) and ((F and DollarPart) <> 0) then
    DString := ' $ '
  else
    DString := '';
  if (F and CommasPart) <> 0 then
  begin
    Counter := Pos('.', S);
    if Counter = 0 then
      Counter := System.Length(S);
    while Counter > 4 do
    begin
      System.Insert(',', S, Counter - 3);
      Dec(Counter, 3);
    end;
  end;
  Color := Colors.ValueCellColor;
  FormattedString := Copy(S, Start, ColWidth);
end; { ValueCell.FormattedString }

function ValueCell.CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                              var L : LStringPtr) : LStringPtr;
begin
  CopyString := L;
end; { ValueCell.CopyString }

constructor ValueCell.Load(var S : TDosStream);
begin
  S.Read(Loc, SizeOf(Loc));
  S.Read(Error, SizeOf(Error));
  S.Read(Value, SizeOf(Value));
end; { ValueCell.Load }

procedure ValueCell.Store(var S : TDosStream);
begin
  S.Write(Loc, SizeOf(Loc));
  S.Write(Error, SizeOf(Error));
  S.Write(Value, SizeOf(Value));
end; { ValueCell.Store }

constructor TextCell.Init(InitLoc : CellPos; InitTxt : LStringPtr);
begin
  Cell.Init(InitLoc);
  Txt := New(LStringPtr, Init);
  if Txt = nil then
    Fail;
  if not Txt^.Assign(InitTxt^) then
  begin
    Done;
    Fail;
  end;
end; { TextCell.Init }

destructor TextCell.Done;
begin
  Dispose(Txt, Done);
end; { TextCell.Done }

function TextCell.CellType : CellTypes;
begin
  CellType := ClText;
end; { TextCell.CellType }

function TextCell.LegalValue : Boolean;
begin
  LegalValue := False;
end; { TextCell.LegalValue }

function TextCell.Name : String;
begin
  Name := TextCellName;
end; { TextCell.Name }

function TextCell.Format(var FHash : FormatHashTable;
                             FormulasDisplayed : Boolean) : FormatType;
var
  F : FormatType;
begin
  if FHash.Search(Loc, F) then
    Format := F
  else
    Format := 0;
end; { TextCell.Format }

function TextCell.Width(var FHash : FormatHashTable;
                            FormulasDisplayed : Boolean) : Word;
begin
  Width := Txt^.Length;
end; { TextCell.Width }

function TextCell.Overwritten(var CHash : CellHashTable;
                                   var FHash : FormatHashTable;
                                   var WHash : WidthHashTable;
                                   var LastPos : CellPos;
                                   MaxCols : Word;
                                   GetColWidth : GetColWidthFunc;
                                   FormulasDisplayed : Boolean) : Word;
var
  CellWidth : Longint;
  Total : Word;
  P : CellPos;
begin
  P := Loc;
  CellWidth := Width(FHash, FormulasDisplayed);
  Total := 0;
  repeat
    Inc(Total);
    Dec(CellWidth, GetColWidth(WHash, P.Col));
    Inc(P.Col);
  until (CellWidth <= 0) or (P.Col = MaxCols) or (CHash.Search(P) <> Empty);
  Dec(Total);
  Overwritten := Total;
end; { TextCell.Overwritten }

function TextCell.ShouldUpdate : Boolean;
begin
  ShouldUpdate := False;
end; { TextCell.ShouldUpdate }

function TextCell.HasError : Boolean;
begin
  HasError := False;
end; { TextCell.HasError }

function TextCell.CurrValue : Extended;
begin
  CurrValue := 0;
end; { TextCell.CurrValue }

function TextCell.OverwriteStart(var FHash : FormatHashTable;
                                 var WHash : WidthHashTable;
                                 GetColWidth : GetColWidthFunc;
                                 EndCol : Word;
                                 DisplayFormulas : Boolean) : Word;
var
  F : FormatType;
  C, Place : Word;
begin
  F := Format(FHash, DisplayFormulas);
  Place := 1;
  C := Loc.Col;
  repeat
    Inc(Place, GetColWidth(WHash, C));
    Inc(C);
  until C = EndCol;
  OverwriteStart := Place;
end; { TextCell.OverwriteStart }

procedure TextCell.EditString(MaxDecPlaces : Byte;
                              var L : LStringPtr);
var
  Good : Boolean;
begin
  Good := L^.Assign(Txt^);
end; { TextCell.EditString }

function TextCell.DisplayString(FormulasDisplayed : Boolean;
                                      MaxDecPlaces : Byte) : String;
begin
  DisplayString := Txt^.Copy(2, Scr.CurrCols);
end; { TextCell.DisplayString }

function TextCell.FormattedString(var OHash : OverwriteHashTable;
                                  var FHash : FormatHashTable;
                                  var WHash : WidthHashTable;
                                  GetColWidth : GetColWidthFunc;
                                  CPos : CellPos;
                                  FormulasDisplayed : Boolean;
                                  Start : Word; ColWidth : Byte;
                                  var DString : DollarStr;
                                  var Color : Byte) : String;
begin
  DString := '';
  Color := Colors.TextCellColor;
  FormattedString := Txt^.Copy(Succ(Start), ColWidth);
end; { TextCell.FormattedString }

function TextCell.CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                             var L : LStringPtr) : LStringPtr;
var
  Good : Boolean;
begin
  Good := L^.Assign(Txt^);
  CopyString := L;
end; { TextCell.CopyString }

constructor TextCell.Load(var S : TDosStream);
begin
  S.Read(Loc, SizeOf(Loc));
  Txt := New(LStringPtr, Init);
  if Txt = nil then
  begin
    S.Error(NoMemory, 0);
    Exit;
  end;
  if not Txt^.FromStream(S) then
  begin
    Dispose(Txt, Done);
    S.Error(NoMemory, 0);
  end;
end; { TextCell.Load }

procedure TextCell.Store(var S : TDosStream);
begin
  S.Write(Loc, SizeOf(Loc));
  Txt^.ToStream(S);
end; { TextCell.Store }

constructor FormulaCell.Init(InitLoc : CellPos; InitError : Boolean;
                             InitValue : Extended; InitFormula : LStringPtr);
begin
  Cell.Init(InitLoc);
  Formula := New(LStringPtr, Init);
  if Formula = nil then
    Fail;
  if not Formula^.Assign(InitFormula^) then
  begin
    Done;
    Fail;
  end;
  Error := InitError;
  Value := InitValue;
end; { FormulaCell.Init }

destructor FormulaCell.Done;
begin
  Dispose(Formula, Done);
end; { FormulaCell.Done }

function FormulaCell.CellType : CellTypes;
begin
  CellType := ClFormula;
end; { FormulaCell.CellType }

function FormulaCell.LegalValue : Boolean;
begin
  LegalValue := True;
end; { FormulaCell.LegalValue }

function FormulaCell.Name : String;
begin
  Name := FormulaCellName;
end; { FormulaCell.Name }

function FormulaCell.Format(var FHash : FormatHashTable;
                                FormulasDisplayed : Boolean) : FormatType;
var
  F : FormatType;
begin
  if FHash.Search(Loc, F) then
    Format := F
  else if FormulasDisplayed then
    Format := 0
  else
    Format := (Ord(JRight) shl 4) + 4;
end; { FormulaCell.Format }

function FormulaCell.Width(var FHash : FormatHashTable;
                               FormulasDisplayed : Boolean) : Word;
var
  S : String;
  F : Byte;
  P, W : Word;
begin
  if FormulasDisplayed then
    Width := Formula^.Length
  else begin
    F := Format(FHash, FormulasDisplayed);
    Str(Value:1:(F and DecPlacesPart), S);
    W := Length(S);
    if (F and DollarPart) <> 0 then
      Inc(W, Length(DollarString));
    if (F and CommasPart) <> 0 then
    begin
      P := Pos('.', S);
      if P = 0 then
        P := Length(S);
      Inc(W, (P - 2) div 3);
    end;
    Width := W;
  end;
end; { FormulaCell.Width }

function FormulaCell.Overwritten(var CHash : CellHashTable;
                                      var FHash : FormatHashTable;
                                      var WHash : WidthHashTable;
                                      var LastPos : CellPos;
                                      MaxCols : Word;
                                      GetColWidth : GetColWidthFunc;
                                      FormulasDisplayed : Boolean) : Word;
var
  CellWidth : Longint;
  Total : Word;
  P : CellPos;
begin
  P := Loc;
  CellWidth := Width(FHash, FormulasDisplayed);
  Total := 0;
  repeat
    Inc(Total);
    Dec(CellWidth, GetColWidth(WHash, P.Col));
    Inc(P.Col);
  until (CellWidth <= 0) or (P.Col = MaxCols) or (CHash.Search(P) <> Empty);
  Dec(Total);
  Overwritten := Total;
end; { FormulaCell.Overwritten }

function FormulaCell.ShouldUpdate : Boolean;
begin
  ShouldUpdate := True;
end; { FormulaCell.ShouldUpdate }

function FormulaCell.HasError : Boolean;
begin
  HasError := Error;
end; { FormulaCell.HasError }

function FormulaCell.CurrValue : Extended;
begin
  CurrValue := Value;
end; { FormulaCell.CurrValue }

function FormulaCell.OverwriteStart(var FHash : FormatHashTable;
                                    var WHash : WidthHashTable;
                                    GetColWidth : GetColWidthFunc;
                                    EndCol : Word;
                                    DisplayFormulas : Boolean) : Word;
var
  F : FormatType;
  C, Place : Word;
begin
  F := Format(FHash, DisplayFormulas);
  Place := 1;
  C := Loc.Col;
  repeat
    Inc(Place, GetColWidth(WHash, C));
    Inc(C);
  until C = EndCol;
  if (not DisplayFormulas) and ((F and DollarPart) <> 0) then
    Dec(Place, Length(DollarString));
  OverwriteStart := Place;
end; { FormulaCell.OverwriteStart }

procedure FormulaCell.EditString(MaxDecPlaces : Byte;
                                       var L : LStringPtr);
var
  Good : Boolean;
begin
  Good := L^.Assign(Formula^);
end; { FormulaCell.EditString }

function FormulaCell.DisplayString(FormulasDisplayed : Boolean;
                                         MaxDecPlaces : Byte) : String;
var
  S : String;
begin
  if not FormulasDisplayed then
    DisplayString := Formula^.ToString
  else begin
    Str(Value:1:MaxDecPlaces, S);
    DisplayString := S;
  end;
end; { FormulaCell.DisplayString }

function FormulaCell.FormattedString(var OHash : OverwriteHashTable;
                                     var FHash : FormatHashTable;
                                     var WHash : WidthHashTable;
                                     GetColWidth : GetColWidthFunc;
                                     CPos : CellPos;
                                     FormulasDisplayed : Boolean;
                                     Start : Word; ColWidth : Byte;
                                     var DString : DollarStr;
                                     var Color : Byte) : String;
var
  S : String;
  Counter : Word;
  F : FormatType;
begin
  if FormulasDisplayed then
  begin
    DString := '';
    Color := Colors.FormulaCellColor;
    FormattedString := Formula^.Copy(1, ColWidth);
  end
  else begin
    F := Format(FHash, FormulasDisplayed);
    Str(Value:1:F and DecPlacesPart, S);
    if (Start = 1) and ((F and DollarPart) <> 0) then
      DString := ' $ '
    else
      DString := '';
    if (F and CommasPart) <> 0 then
    begin
      Counter := Pos('.', S);
      if Counter = 0 then
        Counter := Length(S);
      while Counter > 4 do
      begin
        Insert(',', S, Counter - 3);
        Dec(Counter, 3);
      end;
    end;
    Color := Colors.ValueCellColor;
    FormattedString := Copy(S, Start, ColWidth);
  end;
end; { FormulaCell.FormattedString }

function FormulaCell.CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                                var L : LStringPtr) : LStringPtr;
var
  Good : Boolean;
begin
  Good := L^.Assign(Formula^);
  CopyString := L;
end; { FormulaCell.CopyString }

constructor FormulaCell.Load(var S : TDosStream);
begin
  S.Read(Loc, SizeOf(Loc));
  Formula := New(LStringPtr, Init);
  if Formula = nil then
  begin
    S.Error(NoMemory, 0);
    Exit;
  end;
  if not Formula^.FromStream(S) then
  begin
    Dispose(Formula, Done);
    S.Error(NoMemory, 0);
  end;
end; { FormulaCell.Load }

procedure FormulaCell.Store(var S : TDosStream);
begin
  S.Write(Loc, SizeOf(Loc));
  Formula^.ToStream(S);
end; { FormulaCell.Store }

function FormulaCell.GetFormula : LStringPtr;
begin
  GetFormula := Formula;
end; { FormulaCell.GetFormula }

constructor RepeatCell.Init(InitLoc : CellPos; InitChar : Char);
begin
  Cell.Init(InitLoc);
  RepeatChar := InitChar;
end; { RepeatCell.Init }

function RepeatCell.CellType : CellTypes;
begin
  CellType := ClRepeat;
end; { RepeatCell.CellType }

function RepeatCell.LegalValue : Boolean;
begin
  LegalValue := False;
end; { RepeatCell.LegalValue }

function RepeatCell.Name : String;
begin
  Name := RepeatCellName;
end; { RepeatCell.Name }

function RepeatCell.Format(var FHash : FormatHashTable;
                               FormulasDisplayed : Boolean) : FormatType;
begin
  Format := 0;
end; { RepeatCell.Format }

function RepeatCell.Width(var FHash : FormatHashTable;
                              FormulasDisplayed : Boolean) : Word;
begin
  Width := 2;
end; { RepeatCell.Width }

function RepeatCell.Overwritten(var CHash : CellHashTable;
                                var FHash : FormatHashTable;
                                var WHash : WidthHashTable;
                                var LastPos : CellPos;
                                MaxCols : Word;
                                GetColWidth : GetColWidthFunc;
                                FormulasDisplayed : Boolean) : Word;
var
  Total : Word;
  P : CellPos;
begin
  P := Loc;
  Total := 0;
  repeat
    Inc(Total);
    Inc(P.Col);
  until (P.Col > LastPos.Col) or (CHash.Search(P) <> Empty) or
        (P.Col = 0);
  Dec(Total);
  if (P.Col > LastPos.Col) or (P.Col = 0) then
    Total := MaxCols - Loc.Col;
  Overwritten := Total;
end; { RepeatCell.Overwritten }

function RepeatCell.ShouldUpdate : Boolean;
begin
  ShouldUpdate := False;
end; { RepeatCell.ShouldUpdate }

function RepeatCell.HasError : Boolean;
begin
  HasError := False;
end; { RepeatCell.HasError }

function RepeatCell.CurrValue : Extended;
begin
  CurrValue := 0;
end; { RepeatCell.CurrValue }

function RepeatCell.OverwriteStart(var FHash : FormatHashTable;
                                   var WHash : WidthHashTable;
                                   GetColWidth : GetColWidthFunc;
                                   EndCol : Word;
                                   DisplayFormulas : Boolean) : Word;
begin
  OverwriteStart := 1;
end; { RepeatCell.OverwriteStart }

procedure RepeatCell.EditString(MaxDecPlaces : Byte;
                                var L : LStringPtr);
var
  Good : Boolean;
begin
  Good := L^.FromString(RepeatFirstChar + RepeatChar);
end; { RepeatCell.EditString }

function RepeatCell.DisplayString(FormulasDisplayed : Boolean;
                                        MaxDecPlaces : Byte) : String;
begin
  DisplayString := FillString(Scr.CurrCols, RepeatChar);
end; { RepeatCell.DisplayString }

function RepeatCell.FormattedString(var OHash : OverwriteHashTable;
                                    var FHash : FormatHashTable;
                                    var WHash : WidthHashTable;
                                    GetColWidth : GetColWidthFunc;
                                    CPos : CellPos;
                                    FormulasDisplayed : Boolean;
                                    Start : Word; ColWidth : Byte;
                                    var DString : DollarStr;
                                    var Color : Byte) : String;
begin
  DString := '';
  Color := Colors.RepeatCellColor;
  FormattedString := PadChar('', RepeatChar, ColWidth);
end; { RepeatCell.FormattedString }

function RepeatCell.CopyString(ColLit, RowLit : Boolean; Diff : Longint;
                               var L : LStringPtr) : LStringPtr;
begin
  EditString(0, L);
  CopyString := L;
end; { RepeatCell.CopyString }

constructor RepeatCell.Load(var S : TDosStream);
begin
  S.Read(Loc, SizeOf(Loc));
  S.Read(RepeatChar, SizeOf(RepeatChar));
end; { RepeatCell.Load }

procedure RepeatCell.Store(var S : TDosStream);
begin
  S.Write(Loc, SizeOf(Loc));
  S.Write(RepeatChar, SizeOf(RepeatChar));
end; { RepeatCell.Store }

{$F+}

procedure CellExit;
{ Removes Empty cell from memory, restores ExitProc }
begin
  Dispose(Empty, Done);
  ExitProc := SavedExitProc;
end; { CellExit }

{$F-}

begin
  SavedExitProc := ExitProc;
  ExitProc := @CellExit;
  Empty := New(EmptyCellPtr, Init);
end.
