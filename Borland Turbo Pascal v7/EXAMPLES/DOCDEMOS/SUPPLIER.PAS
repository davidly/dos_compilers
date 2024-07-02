{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Supplier;

interface

uses TutConst, Drivers, Objects, TutTypes, Dialogs, Count;

type
  PSupplierDialog = ^TSupplierDialog;
  TSupplierDialog = object(TDialog)
    SupplierNum, Company, Addr1, Addr2, Addr3, Phone: PInputLine;
    Counter: PCountView;
    constructor Init;
    procedure CancelSupplier;
    procedure EnterNewSupplier;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SaveSupplierData;
    procedure ShowSupplier(ASupplierNum: Integer);
    function Valid(Command: Word): Boolean; virtual;
  end;

var
  SupplierColl: PCollection;
  SupplierInfo: PSupplier;
  TempSupplier: PSupplierObj;

procedure LoadSuppliers;
procedure SaveSuppliers;


implementation

uses Views, Validate;

const
  CurrentSupplier: Integer = 0;

constructor TSupplierDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 60, 15);
  inherited Init(R, 'Suppliers');
  Options := Options or ofCentered;
  HelpCtx := $D000;

  R.Assign(15, 2, 23, 3);
  SupplierNum := New(PInputLine, Init(R, 6));
  SupplierNum^.SetValidator(New(PPXPictureValidator, Init('&&####', True)));
  Insert(SupplierNum);
  R.Assign(2, 2, 15, 3);
  Insert(New(PLabel, Init(R, 'Supplier #:', SupplierNum)));

  R.Assign(12, 4, 57, 5);
  Company := New(PInputLine, Init(R, 45));
  Insert(Company);
  R.Assign(2, 4, 12, 5);
  Insert(New(PLabel, Init(R, 'Company:', Company)));

  R.Assign(12, 6, 57, 7);
  Addr1 := New(PInputLine, Init(R, 60));
  Insert(Addr1);
  R.Assign(2, 6, 12, 7);
  Insert(New(PLabel, Init(R, 'Address:', Addr1)));

  R.Assign(12, 7, 57, 8);
  Addr2 := New(PInputLine, Init(R, 60));
  Insert(Addr2);

  R.Assign(12, 8, 57, 9);
  Addr3 := New(PInputLine, Init(R, 60));
  Insert(Addr3);

  R.Assign(12, 10, 34, 11);
  Phone := New(PInputLine, Init(R, 20));
  Phone^.SetValidator(New(PPXPictureValidator, Init('[(###) ]###-####', False)));
  Insert(Phone);
  R.Assign(2, 10, 12, 11);
  Insert(New(PLabel, Init(R, 'Phone:', Phone)));

  R.Assign(2, 12, 12, 14);
  Insert(New(PButton, Init(R, '~N~ew', cmSupplierNew, bfNormal)));
  R.Assign(13, 12, 23, 14);
  Insert(New(PButton, Init(R, '~S~ave', cmSupplierSave, bfDefault)));
  R.Assign(24, 12, 34, 14);
  Insert(New(PButton, Init(R, 'Re~v~ert', cmSupplierCancel, bfNormal)));
  R.Assign(35, 12, 45, 14);
  Insert(New(PButton, Init(R, 'Next', cmSupplierNext, bfNormal)));
  R.Assign(46, 12, 56, 14);
  Insert(New(PButton, Init(R, 'Prev', cmSupplierPrev, bfNormal)));

  R.Assign(5, 14, 20, 15);
  Counter := New(PCountView, Init(R));
  with Counter^ do
  begin
    SetCount(SupplierColl^.Count);
    SetCurrent(CurrentSupplier + 1);
  end;
  Insert(Counter);

  DisableCommands([cmSupplierPrev]);

  SelectNext(False);
end;

procedure TSupplierDialog.CancelSupplier;
begin
  if CurrentSupplier = SupplierColl^.Count then
  begin
    Dispose(TempSupplier, Done);
    ShowSupplier(CurrentSupplier - 1)
  end
  else ShowSupplier(CurrentSupplier);
end;

procedure TSupplierDialog.EnterNewSupplier;
begin
  CurrentSupplier := SupplierColl^.Count;
  TempSupplier := New(PSupplierObj, Init);
  SupplierInfo := @(TempSupplier^.TransferRecord);
  SetData(SupplierInfo^);
  Counter^.SetCurrent(CurrentSupplier + 1);
  DisableCommands([cmSupplierNew, cmSupplierNext, cmSupplierPrev]);
  EnableCommands([cmSupplierCancel, cmSupplierSave]);
end;

procedure TSupplierDialog.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
    case Event.Command of
      cmSupplierNext:
        begin
          ShowSupplier(CurrentSupplier + 1);
          ClearEvent(Event);
        end;
      cmSupplierPrev:
        begin
          ShowSupplier(CurrentSupplier - 1);
          ClearEvent(Event);
        end;
      cmSupplierNew:
        begin
          EnterNewSupplier;
          ClearEvent(Event);
        end;
      cmSupplierCancel:
        begin
          CancelSupplier;
          ClearEvent(Event);
        end;
      cmSupplierSave:
        begin
          SaveSupplierData;
          ClearEvent(Event);
        end;
    end;
end;

procedure TSupplierDialog.SaveSupplierData;
begin
  if Valid(cmClose) then
  begin
    if CurrentSupplier = SupplierColl^.Count then
      SupplierColl^.Insert(TempSupplier);
    GetData(SupplierInfo^);
    SaveSuppliers;
  end;
  EnableCommands([cmSupplierPrev, cmSupplierNew]);
end;

procedure TSupplierDialog.ShowSupplier(ASupplierNum: Integer);
begin
  CurrentSupplier := ASupplierNum;
  SupplierInfo := @PSupplierObj(SupplierColl^.At(CurrentSupplier))^.TransferRecord;
  SetData(SupplierInfo^);
  Counter^.SetCurrent(CurrentSupplier + 1);
  if CurrentSupplier > 0 then EnableCommands([cmSupplierPrev])
  else DisableCommands([cmSupplierPrev]);
  if SupplierColl^.Count > 0 then
    EnableCommands([cmSupplierNext]);
  if CurrentSupplier >= SupplierColl^.Count - 1 then
    DisableCommands([cmSupplierNext]);
end;

function TSupplierDialog.Valid(Command: Word): Boolean;
begin
  if Command = cmSupplierCancel then
    Valid := True
  else Valid := inherited Valid(Command);
end;

procedure LoadSuppliers;
var
  SupplierFile: TBufStream;
begin
  SupplierFile.Init('SUPPLIER.DAT', stOpenRead, 1024);
  SupplierColl := PCollection(SupplierFile.Get);
  SupplierFile.Done;
  SupplierInfo := @(PSupplierObj(SupplierColl^.At(0))^.TransferRecord);
end;

procedure SaveSuppliers;
var
  SupplierFile: TBufStream;
begin
  SupplierFile.Init('SUPPLIER.DAT', stOpenWrite, 1024);
  SupplierFile.Put(SupplierColl);
  SupplierFile.Done;
end;

end.
