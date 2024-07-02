
{ Turbo Cards }
{ Copyright (c) 1989 by Borland International, Inc. }

unit Cards;
{ Turbo Pascal 5.5 object-oriented example.
  This unit defines a Rolodex-like database of cards.
  Refer to OOPDEMOS.DOC for an overview of this unit.
}

{$S-}

interface

uses Objects;

type

  CardNodePtr = ^CardNode;
  CardNode = record
    Next: CardNodePtr;
    Prev: CardNodePtr;
    Data: record end;
  end;

  CardListPtr = ^CardList;
  CardList = object(Base)
    Current: CardNodePtr;
    Count, DataSize: Integer;
    constructor Init(PDataSize: Integer);
    constructor Load(var S: Stream);
    destructor Done; virtual;
    function CardData: Pointer;
    procedure Delete;
    procedure Insert;
    procedure Next;
    procedure Prev;
    procedure Store(var S: Stream);
  end;

implementation

constructor CardList.Init(PDataSize: Integer);
begin
  Current := nil;
  Count := 0;
  DataSize := PDataSize;
end;

constructor CardList.Load(var S: Stream);
var
  I, N: Integer;
begin
  Current := nil;
  Count := 0;
  S.Read(N, SizeOf(Integer));
  S.Read(DataSize, SizeOf(Integer));
  for I := 1 to N do
  begin
    Insert;
    S.Read(Current^.Data, DataSize);
  end;
  Next;
end;

destructor CardList.Done;
var
  I: Integer;
begin
  for I := 1 to Count do Delete;
end;

function CardList.CardData: Pointer;
begin
  CardData := @Current^.Data;
end;

procedure CardList.Delete;
var
  N: CardNodePtr;
begin
  Dec(Count);
  N := Current;
  if Count = 0 then Current := nil else
  begin
    Current := N^.Prev;
    Current^.Next := N^.Next;
    N^.Next^.Prev := Current;
  end;
  FreeMem(N, DataSize + SizeOf(CardNode));
end;

procedure CardList.Insert;
var
  N: CardNodePtr;
begin
  GetMem(N, DataSize + SizeOf(CardNode));
  if Count = 0 then
  begin
    N^.Next := N;
    N^.Prev := N;
  end else
  begin
    N^.Next := Current^.Next;
    Current^.Next^.Prev := N;
    N^.Prev := Current;
    Current^.Next := N;
  end;
  Current := N;
  Inc(Count);
end;

procedure CardList.Next;
begin
  if Current <> nil then Current := Current^.Next;
end;

procedure CardList.Prev;
begin
  if Current <> nil then Current := Current^.Prev;
end;

procedure CardList.Store(var S: Stream);
var
  I: Integer;
begin
  S.Write(Count, SizeOf(Integer) * 2);
  for I := 1 to Count do
  begin
    S.Write(Current^.Data, DataSize);
    Next;
  end;
end;

end.
