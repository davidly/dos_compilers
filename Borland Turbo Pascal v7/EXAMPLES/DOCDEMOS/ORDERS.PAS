{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Orders;

interface

uses TutConst, Drivers, Objects, TutTypes, Dialogs, Editors, Count;

type
  POrderDialog = ^TOrderDialog;
  TOrderDialog = object(TDialog)
    OrderNum, QtyOrdered, StockNum, DateOrdered: PInputLine;
    Memo: PMemo;
    Received: PCheckBoxes;
    PayMethod: PRadioButtons;
    Counter: PCountView;
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream); virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;

var
  OrderColl: PCollection;
  CurrentOrder: Integer;
  OrderInfo: TOrder;
  TempOrder: POrderObj;

procedure LoadOrders;
procedure SaveOrders;
procedure RegisterOrders;

const
  ROrderDialog: TStreamRec = (
    ObjType: 993;
    VmtLink: Ofs(TypeOf(TOrderDialog)^);
    Load: @TOrderDialog.Load;
    Store: @TOrderDialog.Store
  );


implementation

uses Views, Validate, Stocks;

constructor TOrderDialog.Init;
var
  R: TRect;
  ALabel: PLabel;
begin
  R.Assign(0, 0, 60, 17);
  inherited Init(R, 'Orders');
  Options := Options or ofCentered;
  HelpCtx := $F000;

  R.Assign(13, 2, 23, 3);
  OrderNum := New(PInputLine, Init(R, 8));
  OrderNum^.SetValidator(New(PRangeValidator, Init(1, 99999)));
  Insert(OrderNum);
  R.Assign(2, 2, 12, 3);
  Insert(New(PLabel, Init(R, '~O~rder #:', OrderNum)));

  R.Assign(43, 2, 53, 3);
  DateOrdered := New(PInputLine, Init(R, 8));
  DateOrdered^.SetValidator(New(PPXPictureValidator, Init('{#[#]}/{#[#]}/{##[##]}', True)));
  Insert(DateOrdered);
  R.Assign(26, 2, 41, 3);
  Insert(New(PLabel, Init(R, '~D~ate of order:', DateOrdered)));

  R.Assign(13, 4, 23, 5);
  StockNum := New(PInputLine, Init(R, 8));
  StockNum^.SetValidator(New(PStockNumValidator, Init));
  Insert(StockNum);
  R.Assign(2, 4, 12, 5);
  Insert(New(PLabel, Init(R, '~S~tock #:', StockNum)));

  R.Assign(46, 4, 53, 5);
  QtyOrdered := New(PInputLine, Init(R, 5));
  QtyOrdered^.SetValidator(New(PRangeValidator, Init(1, 99999)));
  Insert(QtyOrdered);
  R.Assign(26, 4, 44, 5);
  Insert(New(PLabel, Init(R, '~Q~uantity ordered:', QtyOrdered)));

  R.Assign(3, 7, 57, 8);
  PayMethod := New(PRadioButtons, Init(R,
    NewSItem('Cash   ',
    NewSItem('Check  ',
    NewSItem('P.O.   ',
    NewSItem('Account', nil))))));
  Insert(PayMethod);
  R.Assign(2, 6, 21, 7);
  Insert(New(PLabel, Init(R, 'Method of ~p~ayment:', PayMethod)));

  R.Assign(22, 8, 37, 9);
  Received := New(PCheckBoxes, Init(R, NewSItem('~R~eceived', nil)));
  Insert(Received);

  R.Assign(3, 10, 57, 13);
  Memo := New(PMemo, Init(R, nil, nil, nil, 255));
  Insert(Memo);
  R.Assign(2, 9, 9, 10);
  Insert(New(PLabel, Init(R, 'Notes:', Memo)));

  R.Assign(2, 14, 12, 16);
  Insert(New(PButton, Init(R, '~N~ew', cmOrderNew, bfNormal)));
  R.Assign(13, 14, 23, 16);
  Insert(New(PButton, Init(R, '~S~ave', cmOrderSave, bfDefault)));
  R.Assign(24, 14, 34, 16);
  Insert(New(PButton, Init(R, 'Re~v~ert', cmOrderCancel, bfNormal)));
  R.Assign(35, 14, 45, 16);
  Insert(New(PButton, Init(R, 'Next', cmOrderNext, bfNormal)));
  R.Assign(46, 14, 56, 16);
  Insert(New(PButton, Init(R, 'Prev', cmOrderPrev, bfNormal)));

  R.Assign(5, 16, 20, 17);
  Counter := New(PCountView, Init(R));
  with Counter^ do
  begin
    SetCount(OrderColl^.Count);
  end;
  Insert(Counter);

  SelectNext(False);
  EnableCommands([cmOrderSave]);
end;

constructor TOrderDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubviewPtr(S, OrderNum);
  GetSubviewPtr(S, QtyOrdered);
  GetSubviewPtr(S, StockNum);
  GetSubviewPtr(S, DateOrdered);
  GetSubviewPtr(S, Memo);
  GetSubviewPtr(S, Received);
  GetSubviewPtr(S, PayMethod);
  GetSubviewPtr(S, Counter);
end;

destructor TOrderDialog.Done;
begin
  DisableCommands([cmOrderSave, cmOrderNext, cmOrderPrev]);
  inherited Done;
end;

procedure TOrderDialog.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmFindOrderWindow) then
    ClearEvent(Event);
end;

procedure TOrderDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubviewPtr(S, OrderNum);
  PutSubviewPtr(S, QtyOrdered);
  PutSubviewPtr(S, StockNum);
  PutSubviewPtr(S, DateOrdered);
  PutSubviewPtr(S, Memo);
  PutSubviewPtr(S, Received);
  PutSubviewPtr(S, PayMethod);
  PutSubviewPtr(S, Counter);
end;

function TOrderDialog.Valid(Command: Word): Boolean;
begin
  case Command of
    cmOrderCancel, cmCancel: Valid := True;
  else Valid := inherited Valid(Command);
  end;
end;

procedure LoadOrders;
var
  OrderFile: TBufStream;
begin
  OrderFile.Init('ORDERS.DAT', stOpenRead, 1024);
  OrderColl := PCollection(OrderFile.Get);
  OrderFile.Done;
end;

procedure SaveOrders;
var
  OrderFile: TBufStream;
begin
  OrderFile.Init('ORDERS.DAT', stOpenWrite, 1024);
  OrderFile.Put(OrderColl);
  OrderFile.Done;
end;

procedure RegisterOrders;
begin
  RegisterType(ROrderDialog);
end;

end.
