
{ Turbo Streams }
{ Copyright (c) 1989 by Borland International, Inc. }

program ODemo;
{ Turbo Pascal 5.5 object-oriented example.
  Demonstrates use of the OBJECTS unit's Stream, List and Node
  object types. See OOPDEMOS.DOC for an overview of this program.
}

uses Objects;

type

  TestNodePtr = ^TestNode;
  TestNode = object(Node)
    procedure Dump; virtual;
  end;

  IntNodePtr = ^IntNode;
  IntNode = object(TestNode)
    Value: Longint;
    constructor Init(V: Longint);
    constructor Load(var S: Stream);
    procedure Dump; virtual;
    procedure Store(var S: Stream);
  end;

  StringPtr = ^String;

  StrNodePtr = ^StrNode;
  StrNode = object(TestNode)
    Value: StringPtr;
    constructor Init(V: String);
    destructor Done; virtual;
    constructor Load(var S: Stream);
    procedure Dump; virtual;
    procedure Store(var S: Stream);
  end;

  TestList = object(List)
    procedure Dump;
  end;

  TestStream = object(BufStream)
    procedure RegisterTypes; virtual;
  end;

var
  S: TestStream;
  L: TestList;

procedure TestNode.Dump;
begin
  Abstract;
end;

constructor IntNode.Init(V: Longint);
begin
  Value := V;
end;

constructor IntNode.Load(var S: Stream);
begin
  S.Read(Value, SizeOf(Longint));
  if S.Status <> 0 then Fail;
end;

procedure IntNode.Dump;
begin
  WriteLn('Int: ', Value);
end;

procedure IntNode.Store(var S: Stream);
begin
  S.Write(Value, SizeOf(Longint));
end;

constructor StrNode.Init(V: String);
begin
  GetMem(Value, Length(V) + 1);
  Value^ := V;
end;

destructor StrNode.Done;
begin
  FreeMem(Value, Length(Value^) + 1);
end;

constructor StrNode.Load(var S: Stream);
var
  L: Byte;
begin
  S.Read(L, 1);
  GetMem(Value, L + 1);
  Value^[0] := Chr(L);
  S.Read(Value^[1], L);
  if S.Status <> 0 then Fail;
end;

procedure StrNode.Dump;
begin
  WriteLn('Str: ', Value^);
end;

procedure StrNode.Store(var S: Stream);
begin
  S.Write(Value^, Length(Value^) + 1);
end;

procedure TestList.Dump;
var
  P: TestNodePtr;
begin
  P := TestNodePtr(First);
  while P <> nil do
  begin
    P^.Dump;
    P := TestNodePtr(Next(P));
  end;
end;

procedure TestStream.RegisterTypes;
begin
  DosStream.RegisterTypes;
  Register(TypeOf(IntNode), @IntNode.Store, @IntNode.Load);
  Register(TypeOf(StrNode), @StrNode.Store, @StrNode.Load);
end;

begin
  WriteLn('Creating list.');
  L.Clear;
  L.Append(New(IntNodePtr, Init(1)));
  L.Append(New(IntNodePtr, Init(10)));
  L.Append(New(IntNodePtr, Init(100)));
  L.Append(New(IntNodePtr, Init(1000)));
  L.Append(New(StrNodePtr, Init('Hello world')));
  L.Append(New(StrNodePtr, Init('Turbo Pascal version 5.5')));
  L.Append(New(IntNodePtr, Init(-1)));
  L.Append(New(IntNodePtr, Init(-2)));

  WriteLn('List to be saved:');
  L.Dump;

  WriteLn('Saving list in TEST.DTA.');
  S.Init('TEST.DTA', SCreate, 1024);
  L.Store(S);
  S.Done;

  WriteLn('Deleting list.');
  L.Delete;

  WriteLn('Loading list from TEST.DTA.');
  S.Init('TEST.DTA', SOpen, 1024);
  L.Load(S);
  S.Done;

  WriteLn('List that was loaded:');
  L.Dump;
end.
