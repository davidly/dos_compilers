{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Stocks;

interface

uses TutConst, Drivers, Objects, TutTypes, Dialogs, Count, Validate;

type
  PStockDialog = ^TStockDialog;
  TStockDialog = object(TDialog)
    StockNum, Descrip, Quant, UCost, Supplier: PInputLine;
    Counter: PCountView;
    constructor Init;
    procedure CancelStock;
    procedure EnterNewStock;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SaveStockData;
    procedure ShowStock(AStockNum: Integer);
    function Valid(Command: Word): Boolean; virtual;
  end;
  PStockNumValidator = ^TStockNumValidator;
  TStockNumValidator = object(TLookupValidator)
    procedure Error; virtual;
    function Lookup(const S: string): Boolean; virtual;
  end;

var
  StockColl: PCollection;
  StockInfo: PStockItem;
  TempStockItem: PStockItemObj;

procedure LoadStock;
procedure SaveStock;
procedure RegisterStocks;

const
  RStockNumValidator: TStreamRec = (
    ObjType: 994;
    VmtLink: Ofs(TypeOf(TStockNumValidator)^);
    Load: @TStockNumValidator.Load;
    Store: @TStockNumValidator.Store
  );


implementation

uses Views, MsgBox;

const
  CurrentStock: Integer = 0;

constructor TStockDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 60, 11);
  inherited Init(R, 'Stock Items');
  Options := Options or ofCentered;
  HelpCtx := $E000;

  R.Assign(12, 2, 22, 3);
  StockNum := New(PInputLine, Init(R, 8));
  StockNum^.SetValidator(New(PPXPictureValidator, Init('&&&-####', True)));
  Insert(StockNum);
  R.Assign(2, 2, 12, 3);
  Insert(New(PLabel, Init(R, 'Stock #:', StockNum)));

  R.Assign(9, 4, 57, 5);
  Descrip := New(PInputLine, Init(R, 80));
  Insert(Descrip);
  R.Assign(2, 4, 9, 5);
  Insert(New(PLabel, Init(R, 'Item:', Descrip)));

  R.Assign(14, 6, 21, 7);
  Quant := New(PInputLine, Init(R, 12));
  Quant^.SetValidator(New(PRangeValidator, Init(1, 99999)));
  Insert(Quant);
  R.Assign(2, 6, 14, 7);
  Insert(New(PLabel, Init(R, '# on hand:', Quant)));

  R.Assign(43, 6, 50, 7);
  UCost := New(PInputLine, Init(R, 12));
  Insert(UCost);
  R.Assign(31, 6, 43, 7);
  Insert(New(PLabel, Init(R, 'Unit cost:', UCost)));

  R.Assign(2, 8, 12, 10);
  Insert(New(PButton, Init(R, '~N~ew', cmStockNew, bfNormal)));
  R.Assign(13, 8, 23, 10);
  Insert(New(PButton, Init(R, '~S~ave', cmStockSave, bfDefault)));
  R.Assign(24, 8, 34, 10);
  Insert(New(PButton, Init(R, 'Re~v~ert', cmStockCancel, bfNormal)));
  R.Assign(35, 8, 45, 10);
  Insert(New(PButton, Init(R, 'Next', cmStockNext, bfNormal)));
  R.Assign(46, 8, 56, 10);
  Insert(New(PButton, Init(R, 'Prev', cmStockPrev, bfNormal)));

  R.Assign(5, 10, 20, 11);
  Counter := New(PCountView, Init(R));
  with Counter^ do
  begin
    SetCount(StockColl^.Count);
    SetCurrent(CurrentStock + 1);
  end;
  Insert(Counter);
  DisableCommands([cmStockPrev]);
  SelectNext(False);
end;

procedure TStockDialog.CancelStock;
begin
  if CurrentStock = StockColl^.Count then
  begin
    Dispose(TempStockItem, Done);
    ShowStock(CurrentStock - 1)
  end
  else ShowStock(CurrentStock);
end;

procedure TStockDialog.EnterNewStock;
begin
  CurrentStock := StockColl^.Count;
  TempStockItem := New(PStockItemObj, Init);
  StockInfo := @(TempStockItem^.TransferRecord);
  SetData(StockInfo^);
  Counter^.SetCurrent(CurrentStock + 1);
  DisableCommands([cmStockNew, cmStockNext, cmStockPrev]);
  EnableCommands([cmStockCancel, cmStockSave]);
end;

procedure TStockDialog.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
    case Event.Command of
      cmStockNext:
        begin
          ShowStock(CurrentStock + 1);
          ClearEvent(Event);
        end;
      cmStockPrev:
        begin
          ShowStock(CurrentStock - 1);
          ClearEvent(Event);
        end;
      cmStockNew:
        begin
          EnterNewStock;
          ClearEvent(Event);
        end;
      cmStockCancel:
        begin
          CancelStock;
          ClearEvent(Event);
        end;
      cmStockSave:
        begin
          SaveStockData;
          ClearEvent(Event);
        end;
    end;
end;

procedure TStockDialog.SaveStockData;
begin
  if Valid(cmClose) then
  begin
    if CurrentStock = StockColl^.Count then StockColl^.Insert(TempStockItem);
    GetData(StockInfo^);
    SaveStock;
  end;
  EnableCommands([cmStockPrev, cmStockNew]);
end;

procedure TStockDialog.ShowStock(AStockNum: Integer);
begin
  CurrentStock := AStockNum;
  StockInfo := @PStockItemObj(StockColl^.At(CurrentStock))^.TransferRecord;
  SetData(StockInfo^);
  Counter^.SetCurrent(CurrentStock + 1);
  if CurrentStock > 0 then EnableCommands([cmStockPrev])
  else DisableCommands([cmStockPrev]);
  if StockColl^.Count > 0 then EnableCommands([cmStockNext]);
  if CurrentStock >= StockColl^.Count - 1 then DisableCommands([cmStockNext]);
  EnableCommands([cmStockSave, cmStockNew]);
end;

function TStockDialog.Valid(Command: Word): Boolean;
begin
  if Command = cmStockCancel then
    Valid := True
  else Valid := inherited Valid(Command);
end;

procedure TStockNumValidator.Error;
begin
  MessageBox('Not a valid stock item number', nil, mfOKButton);
end;

function TStockNumValidator.Lookup(const S: string): Boolean;
var
  LookOrder: POrderObj;

  function IsInList(P: Pointer): Boolean; far;
  begin
    IsInList := PStockItemObj(P)^.TransferRecord.StockNo = S;
  end;

begin
  Lookup := (StockColl^.FirstThat(@IsInList) <> nil);
end;

procedure LoadStock;
var
  StockFile: TBufStream;
begin
  StockFile.Init('ITEMS.DAT', stOpenRead, 1024);
  StockColl := PCollection(StockFile.Get);
  StockFile.Done;
  StockInfo := @(PStockItemObj(StockColl^.At(0))^.TransferRecord);
end;

procedure SaveStock;
var
  StockFile: TBufStream;
begin
  StockFile.Init('ITEMS.DAT', stOpenWrite, 1024);
  StockFile.Put(StockColl);
  StockFile.Done;
end;

procedure RegisterStocks;
begin
  RegisterType(RStockNumValidator);
end;

end.
