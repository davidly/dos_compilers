{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+,V-}

Unit TutTypes;

interface

uses Memory, Objects;

type

  TSupplierID = String[6];

  PSupplier = ^TSupplier;
  TSupplier = record
    AccountNo: TSupplierID;
    CompanyName: String[45];
    Address1: String[60];
    Address2: String[60];
    Address3: String[60];
    Phone: String[20];
  end;

  PStockItem = ^TStockItem;
  TStockItem = record
    StockNo: String[8];
    Description: String[80];
    QtyOnHand: String[12];
    UnitCost: String[12];
    Supplier: TSupplierID;
  end;

  POrder = ^TOrder;
  TOrder = record
    OrderNum: String[8];
    OrderDate: String[8];
    StockNum: String[8];
    Quantity: string[5];
    Payment, Received, MemoLen: Word;
    MemoText: array[0..255] of Char;
  end;

  POrderObj = ^TOrderObj;
  TOrderObj = object(TObject)
    TransferRecord: TOrder;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

  PSupplierObj = ^TSupplierObj;
  TSupplierObj = object(TObject)
    TransferRecord: TSupplier;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

  PStockItemObj = ^TStockItemObj;
  TStockItemObj = object(TObject)
    TransferRecord: TStockItem;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

procedure RegisterGlobals;

implementation

const
  ROrderObj: TStreamRec = (
     ObjType: 15000;
     VmtLink: Ofs(TypeOf(TOrderObj)^);
     Load:    @TOrderObj.Load;
     Store:   @TOrderObj.Store
  );

  RSupplierObj: TStreamRec = (
     ObjType: 15001;
     VmtLink: Ofs(TypeOf(TSupplierObj)^);
     Load:    @TSupplierObj.Load;
     Store:   @TSupplierObj.Store
  );

  RStockItemObj: TStreamRec = (
     ObjType: 15002;
     VmtLink: Ofs(TypeOf(TStockItemObj)^);
     Load:    @TStockItemObj.Load;
     Store:   @TStockItemObj.Store
  );

{ TDataCollection }
constructor TOrderObj.Load(var S: TStream);
begin
  inherited Init;
  S.Read(TransferRecord, SizeOf(TransferRecord));
end;

procedure TOrderObj.Store(var S: TStream);
begin
  S.Write(TransferRecord, SizeOf(TransferRecord));
end;

constructor TSupplierObj.Load(var S: TStream);
begin
  inherited Init;
  S.Read(TransferRecord, SizeOf(TransferRecord));
end;

procedure TSupplierObj.Store(var S: TStream);
begin
  S.Write(TransferRecord, SizeOf(TransferRecord));
end;

constructor TStockItemObj.Load(var S: TStream);
begin
  inherited Init;
  S.Read(TransferRecord, SizeOf(TransferRecord));
end;

procedure TStockItemObj.Store(var S: TStream);
begin
  S.Write(TransferRecord, SizeOf(TransferRecord));
end;

procedure RegisterGlobals;
begin
  RegisterType(ROrderObj);
  RegisterType(RSupplierObj);
  RegisterType(RStockItemObj);
end;

end.
