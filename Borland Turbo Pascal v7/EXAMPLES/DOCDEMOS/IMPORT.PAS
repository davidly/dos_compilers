{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Import;

uses Objects, TutTypes, Dos;

var
  InFile: Text;
  OutFile: TBufStream;
  C: TCollection;
  S: String;
  Supplier: PSupplierObj;
  StockItem: PStockItemObj;
  Order: POrderObj;
  w: Word;

begin

  if ParamCount <> 1 then
  begin
    writeln('Enter "1", "2", or "3"');
    Halt(1);
  end;

  RegisterGlobals;
  RegisterType(RCollection);


  if ParamStr(1) = '1' then
  begin

    { Convert SUPPLIER.TXT to SUPPLIER.DAT }

    C.Init(10, 1);
    OutFile.Init('SUPPLIER.DAT', stCreate, 1024);
    Assign(InFile, 'Supplier.txt');
    Reset(InFile);

    while not eof(InFile) do
    begin
      New(Supplier, Init);
      with Supplier^.TransferRecord do
      begin
        Readln(InFile, S); AccountNo := S;
        ReadLn(InFile, S); CompanyName := S;
        Readln(infile, s); Address1 := S;
        Readln(infile, s); Address2 := S;
        Readln(infile, s); Address3 := S;
        Readln(infile, s); Phone := S;
      end;
      C.Insert(Supplier);
    end;

    OutFile.Put(@C);

    Close(InFile);
    OutFile.Done;
    C.Done;
  end;

  if ParamStr(1) = '2' then
  begin
    { Convert ITEMS.TXT to ITEMS.DAT }

    C.Init(10, 1);
    OutFile.Init('ITEMS.DAT', stCreate, 1024);
    Assign(InFile, 'Items.txt');
    Reset(InFile);

    while not eof(InFile) do
    begin
      New(StockItem, Init);
      with StockItem^.TransferRecord do
      begin
        Readln(InFile, S); StockNo := S;
        Readln(InFile, S); Description := S;
        Readln(InFile, S); QtyOnHand := S;
        Readln(InFile, S); UnitCost := S;
        Readln(InFile, S); Supplier := S;
      end;
      C.Insert(StockItem);
    end;

    OutFile.Put(@C);

    Close(InFile);
    OutFile.Done;
    C.Done;
  end;

  if ParamStr(1) = '3' then
  begin
    { Convert ORDERS.TXT to ORDERS.DAT }

    C.Init(10, 1);
    OutFile.Init('ORDERS.DAT', stCreate, 1024);
    Assign(InFile, 'Orders.txt');
    Reset(InFile);

    while not eof(InFile) do
    begin
      New(Order, Init);
      with Order^.TransferRecord do
      begin
        Readln(InFile, S); OrderNum := S;
        Readln(InFile, S); StockNum := S;
        Readln(InFile, S); OrderDate := S;
        Readln(InFile, S); Quantity := S;
        Readln(InFile, w); Payment := W;
        Readln(InFile, w); Received := W;
        Readln(InFile, w); MemoLen := W;
      end;
      C.Insert(Order);
    end;

    OutFile.Put(@C);

    Close(InFile);
    OutFile.Done;
    C.Done;
  end;

end.