{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit DataColl;

{$F+,O+,S-,D-}

interface

uses Objects;

type
  KeyTypes = (StringKey, LongIntKey);

  PDataCollection = ^TDataCollection;
  TDataCollection = object(TStringCollection)
    ItemSize: Word;
    KeyType: KeyTypes;
    Status: Integer;
    constructor Init(ALimit, ADelta, AnItemSize: Integer; AKeyType: KeyTypes);
    constructor Load(var S: TStream);
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure Error(Code, Info: Integer); virtual;
    procedure FreeItem(Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    procedure SetLimit(ALimit: Integer); virtual;
    procedure Store(var S: TStream); virtual;
  end;

const
  RDataCollection: TStreamRec = (
    ObjType: 10050;
    VmtLink: Ofs(TypeOf(TDataCollection)^);
    Load: @TDataCollection.Load;
    Store: @TDataCollection.Store);

procedure RegisterDataColl;

implementation

uses Memory;

procedure RegisterDataColl;
begin
  RegisterType(RDataCollection);
end;

constructor TDataCollection.Init(ALimit, ADelta, AnItemSize: Integer;
  AKeyType: KeyTypes);
begin
  TStringCollection.Init(ALimit, ADelta);
  ItemSize := AnItemSize;
  KeyTYpe := AKeyType;
end;

constructor TDataCollection.Load(var S: TStream);
begin
  S.Read(ItemSize, SizeOf(ItemSize));
  TStringCollection.Load(S);
  S.Read(KeyType, SizeOf(KeyType));
  Status := 0;
end;

function TDataCollection.Compare(Key1, Key2: Pointer): Integer;
var
  SK1, SK2: String;
  i: Integer;
begin
  if KeyType = StringKey then
  begin
    SK1 := PString(Key1)^;
    for i := 1 to Length(SK1) do SK1[i] := UpCase(SK1[i]);
    SK2 := PString(Key2)^;
    for i := 1 to Length(SK2) do SK2[i] := UpCase(SK2[i]);
    Compare := TStringCollection.Compare(@SK1, @SK2);
  end
  else if KeyType = LongIntKey then
  begin
    if LongInt(Key1^) < LongInt(Key2^) then
      Compare := -1
    else if LongInt(Key1^) = LongInt(Key2^) then
      Compare := 0
    else
      Compare := 1;
  end;
end;

procedure TDataCollection.Error(Code, Info: Integer);
{ Save error status instead of giving a runtime error }
begin
  Status := Code;
end;

procedure TDataCollection.FreeItem(Item: Pointer);
begin
  if Item <> nil then FreeMem(Item, ItemSize);
end;

function TDataCollection.GetItem(var S: TStream): Pointer;
var
  Item: Pointer;
begin
  GetMem(Item, ItemSize);
  S.Read(Item^, ItemSize);
  GetItem := Item;
end;

procedure TDataCollection.PutItem(var S: TStream; Item: Pointer);
begin
  S.Write(Item^, ItemSize);
end;

procedure TDataCollection.SetLimit(ALimit: Integer);
var
  AItems: PItemList;
begin
  if ALimit < Count then ALimit := Count;
  if ALimit > MaxCollectionSize then ALimit := MaxCollectionSize;
  if ALimit <> Limit then
  begin
    if ALimit = 0 then AItems := nil else
    begin
      { Restrict collection: don't allow it to eat into safety pool.
        Requires careful checking for success at point of insertion.
      }
      AItems := MemAlloc(ALimit * SizeOf(Pointer));
      if AItems = nil then Exit;
      if Count <> 0 then Move(Items^, AItems^, Count * SizeOf(Pointer));
    end;
    if Limit <> 0 then FreeMem(Items, Limit * SizeOf(Pointer));
    Items := AItems;
    Limit := ALimit;
  end;
end;

procedure TDataCollection.Store(var S: TStream);
begin
  S.Write(ItemSize, SizeOf(ItemSize));
  TStringCollection.Store(S);
  S.Write(KeyType, SizeOf(KeyType));
end;

end.
