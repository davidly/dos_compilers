
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCHash;
{ Turbo Pascal 6.0 object-oriented example hash tables.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$S-}

interface

uses TCUtil;

{ This unit allows you to implement hash tables.  Each hash table is composed
  of a number of "buckets", each of which points to a linked list of data
  entries.  The bucket that a particular data entry goes into is determined
  by the HashValue function. }

const
  MaxBuckets = 1000;
  MaxHashItemSize = 256;

type
  BucketRange = 1..MaxBuckets;
  HashItemSizeRange = 1..MaxHashItemSize;
  HashItemData = array[0..Pred(MaxHashItemSize)] of Byte;
  HashItemDataPtr = ^HashItemData;
  HashItemPtr = ^HashItem;
  HashItem = record
    Next : HashItemPtr;
    Data : HashItemData;
  end;
  HashItemArray = array[BucketRange] of HashItemPtr;
  HashTable = object
    Buckets : BucketRange;
    Items : Longint;
    CurrItem : HashItemPtr;
    CurrBucket : BucketRange;
    HashData : ^HashItemArray;
    constructor Init(InitBuckets : BucketRange);
    destructor Done;
    function Add : Boolean;
    procedure Delete(Deleted : Pointer);
    function FirstItem : HashItemPtr;
    function NextItem : HashItemPtr;
    function Change : Boolean;
    function Search : HashItemPtr;
    function HashValue : Word; virtual;
    function Found(Item : HashItemPtr) : Boolean; virtual;
    procedure CreateItem(var Item : HashItemPtr); virtual;
    function ItemSize : HashItemSizeRange; virtual;
    function CurrItemSize(Item : HashItemPtr) : HashItemSizeRange; virtual;
  end;

implementation

constructor HashTable.Init(InitBuckets : BucketRange);
{ Initialize a new hash table with a certain number of buckets }
begin
  GetMem(HashData, InitBuckets * SizeOf(HashItemPtr));
  if HashData = nil then
    Fail;
  Buckets := InitBuckets;
  FillChar(HashData^, Buckets * SizeOf(HashItemPtr), 0);
  Items := 0;
end; { HashTable.Init }

destructor HashTable.Done;
{ Removes a hash table from memory }
var
  P, D : HashItemPtr;
  Counter : Word;
begin
  for Counter := 1 to Buckets do
  begin
    P := HashData^[Counter];
    while P <> nil do
    begin
      D := P;
      P := P^.Next;
      FreeMem(D, CurrItemSize(D) + SizeOf(HashItemPtr));
    end;
  end;
  FreeMem(HashData, Buckets * SizeOf(HashItemPtr));
end; { HashTable.Done }

function HashTable.Add : Boolean;
{ Adds a new item to a hash table }
var
  H, A : HashItemPtr;
  V : BucketRange;
begin
  Add := False;
  V := Succ(HashValue mod Buckets);
  H := HashData^[V];
  A := H;
  while H <> nil do
  begin
    H := H^.Next;
    if H <> nil then
      A := H;
  end;
  if A = nil then    { Item will be the first element in the list }
  begin
    GetMem(HashData^[V], ItemSize + SizeOf(HashItemPtr));
    A := HashData^[V];
    if A = nil then
      Exit;
  end
  else begin         { Add item and end of list }
    GetMem(A^.Next, ItemSize + SizeOf(HashItemPtr));
    if A^.Next = nil then
      Exit;
    A := A^.Next;
  end;
  CreateItem(A);
  A^.Next := nil;
  Inc(Items);
  Add := True;
end; { HashTable.Add }

procedure HashTable.Delete(Deleted : Pointer);
{ Deletes an item from a hash table, and returns the deleted item }
var
  H, D : HashItemPtr;
  V : BucketRange;
begin
  V := Succ(HashValue mod Buckets);
  H := HashData^[V];
  D := H;
  while (H <> nil) and (not Found(H)) do
  begin
    H := H^.Next;
    if not Found(H) then
      D := H;
  end;
  if H = nil then        { The item was not found }
  begin
    if Deleted <> nil then
      FillChar(Deleted^, ItemSize, 0);
    Exit;
  end
  else begin
    if H = HashData^[V] then
      HashData^[V] := HashData^[V]^.Next
    else
      D^.Next := H^.Next;
    if Deleted <> nil then   { Fill Deleted with the item's data }
      Move(H^.Data, Deleted^, ItemSize);
    FreeMem(H, CurrItemSize(H) + SizeOf(HashItemPtr));
  end;
  Dec(Items);
end; { HashTable.Delete }

function HashTable.FirstItem : HashItemPtr;
{ Returns the first item in a hash table.  to find all of the items in a
  hash table, call FirstItem to get the first one and then call NextItem to
  get the rest }
var
  Counter : Word;
begin
  for Counter := 1 to Buckets do
  begin
    CurrBucket := Counter;
    CurrItem := HashData^[Counter];
    if CurrItem <> nil then
    begin
      FirstItem := CurrItem;
      Exit;
    end;
  end;
  FirstItem := nil;
end; { HashTable.FirstItem }

function HashTable.NextItem : HashItemPtr;
{ Returns the next item in a hash table - called after FirstItem }
begin
  CurrItem := CurrItem^.Next;
  if CurrItem <> nil then
  begin
    NextItem := CurrItem;
    Exit;
  end;
  while CurrBucket < Buckets do
  begin
    Inc(CurrBucket);
    CurrItem := HashData^[CurrBucket];
    if CurrItem <> nil then
    begin
      NextItem := CurrItem;
      Exit;
    end;
  end;
  NextItem := nil;
end; { HashTable.NextItem }

function HashTable.Change : Boolean;
{ Changes the data of a hash item }
var
  H : HashItemPtr;
begin
  H := HashData^[Succ(HashValue mod Buckets)];
  while (H <> nil) and (not Found(H)) do
    H := H^.Next;
  if H <> nil then
  begin
    CreateItem(H);
    Change := True;
  end
  else
    Change := Add;
end; { HashTable.Change }

function HashTable.Search : HashItemPtr;
{ Searches for a particular hash item }
var
  H : HashItemPtr;
begin
  H := HashData^[Succ(HashValue mod Buckets)];
  while (H <> nil) and (not Found(H)) do
    H := H^.Next;
  Search := H;
end; { HashTable.Search }

function HashTable.HashValue : Word;
{ Returns a hash value - must be written by the user }
begin
  Abstract('HashTable.HashValue');
end; { HashTable.HashValue }

function HashTable.Found(Item : HashItemPtr) : Boolean;
{ Returns a boolean value indicating whether the current hash item is the
  one being searched for - must be written by the user }
begin
  Abstract('HashTable.Found');
end; { HashTable.Found }

procedure HashTable.CreateItem(var Item : HashItemPtr);
{ Creates a hash item - must be written by the user }
begin
  Abstract('HashTable.CreateItem');
end; { HashTable.CreateItem }

function HashTable.ItemSize : HashItemSizeRange;
{ Returns the size of a hash item.  If the hash item size is variable, this
  is based on whatever the item being searched for, added, or deleted is - 
  must be written by the user }
begin
  Abstract('HashTable.ItemSize');
end; { HashTable.ItemSize }

function HashTable.CurrItemSize(Item : HashItemPtr) : HashItemSizeRange;
{ Returns the size of a particular item.  This needs to be written only if
  the size of hash items is variable (strings, etc.) }
begin
  CurrItemSize := ItemSize;
end; { HashTable.CurrItemSize }

end.
