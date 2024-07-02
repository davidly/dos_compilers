
{ Turbo Objects }
{ Copyright (c) 1989 by Borland International, Inc. }

unit Objects;
{ Turbo Pascal 5.5 object-oriented example.
  This unit defines some basic object types.
  Refer to OOPDEMOS.DOC for an overview of this unit.
}

{$S-}

interface

const

{ Stream access modes }

  SCreate    = $3C00;           { Create new file }
  SOpenRead  = $3D00;           { Read access only }
  SOpenWrite = $3D01;           { Write access only }
  SOpen      = $3D02;           { Read and write access }

{ SetPos positioning modes }

  PosAbs = 0;                   { Relative to beginning }
  PosCur = 1;                   { Relative to current position }
  PosEnd = 2;                   { Relative to end }

type

{ General conversion types }

  WordRec = record
    Lo, Hi: Byte;
  end;

  LongRec = record
    Lo, Hi: Word;
  end;

  PtrRec = record
    Ofs, Seg: Word;
  end;

{ Abstract base object type }

  BasePtr = ^Base;
  Base = object
    destructor Done; virtual;
  end;

{ Stream type list }

  STypeListPtr = ^STypeList;
  STypeList = array[1..256] of Word;

{ Stream I/O procedure record }

  SProc = object
    StoreProc: Pointer;
    LoadProc: Pointer;
  end;

{ Stream I/O procedure list }

  SProcListPtr = ^SProcList;
  SProcList = array[1..256] of SProc;

{ Abstract stream object type }

  StreamPtr = ^Stream;
  Stream = object(Base)
    TypeCount: Word;
    TypeList: STypeListPtr;
    ProcList: SProcListPtr;
    Status: Integer;
    constructor Init;
    destructor Done; virtual;
    procedure Error(Code: Integer); virtual;
    procedure Flush; virtual;
    function GetPos: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure RegisterTypes; virtual;
    procedure SetPos(Pos: Longint; Mode: Byte); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count: Word); virtual;
    function Get: BasePtr;
    function GetSize: Longint;
    procedure Put(B: BasePtr);
    procedure Register(TypePtr, StorePtr, LoadPtr: Pointer);
    procedure Seek(Pos: Longint);
  end;

{ DOS file name string }

  FNameStr = string[79];

{ Unbuffered DOS stream }

  DosStreamPtr = ^DosStream;
  DosStream = object(Stream)
    Handle: Word;
    constructor Init(FileName: FNameStr; Mode: Word);
    destructor Done; virtual;
    function GetPos: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure SetPos(Pos: Longint; Mode: Byte); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count: Word); virtual;
    procedure Close;
    procedure Open(var Name; Mode: Word);
  end;

{ Buffered DOS stream }

  BufStreamPtr = ^BufStream;
  BufStream = object(DosStream)
    Buffer: Pointer;
    BufSize: Word;
    BufPtr: Word;
    BufEnd: Word;
    constructor Init(FileName: FNameStr; Mode, Size: Word);
    destructor Done; virtual;
    procedure Flush; virtual;
    function GetPos: Longint; virtual;
    procedure Read(var Buf; Count: Word); virtual;
    procedure Write(var Buf; Count: Word); virtual;
  end;

{ Abstract linked list node type }

  NodePtr = ^Node;
  Node = object(Base)
    Next: NodePtr;
    function Prev: NodePtr;
  end;

{ Linked list type }

  ListPtr = ^List;
  List = object
    Last: NodePtr;
    procedure Append(N: NodePtr);
    procedure Clear;
    procedure Delete;
    function Empty: Boolean;
    function First: NodePtr;
    procedure Insert(N: NodePtr);
    procedure Load(var S: Stream);
    function Next(N: NodePtr): NodePtr;
    function Prev(N: NodePtr): NodePtr;
    procedure Remove(N: NodePtr);
    procedure Store(var S: Stream);
  end;

{ Abstract notification procedure }

procedure Abstract;

implementation

{$L STREAM}    { Stream externals }
{$L DOSSTM}    { DosStream externals }
{$L BUFSTM}    { BufStream externals }

procedure StreamError; external {STREAM};

{ Base }

destructor Base.Done;
begin
end;

{ Stream }

constructor Stream.Init;
begin
  TypeCount := 0;
  TypeList := nil;
  ProcList := nil;
  Status := 0;
  RegisterTypes;
  GetMem(TypeList, TypeCount * SizeOf(Word));
  if TypeList = nil then Fail;
  GetMem(ProcList, TypeCount * SizeOf(SProc));
  if ProcList = nil then
  begin
    FreeMem(TypeList, TypeCount * SizeOf(Word));
    Fail;
  end;
  TypeCount := 0;
  RegisterTypes;
end;

destructor Stream.Done;
begin
  FreeMem(ProcList, TypeCount * SizeOf(SProc));
  FreeMem(TypeList, TypeCount * SizeOf(Word));
end;

procedure Stream.Error(Code: Integer);
begin
  Status := Code;
end;

procedure Stream.Flush;
begin
end;

function Stream.GetPos: Longint;
begin
  Abstract;
end;

procedure Stream.Read(var Buf; Count: Word);
begin
  Abstract;
end;

procedure Stream.RegisterTypes;
begin
end;

procedure Stream.SetPos(Pos: Longint; Mode: Byte);
begin
  Abstract;
end;

procedure Stream.Truncate;
begin
  Abstract;
end;

procedure Stream.Write(var Buf; Count: Word);
begin
  Abstract;
end;

function Stream.Get: BasePtr;
external {STREAM};

function Stream.GetSize: Longint;
var
  P: Longint;
begin
  P := GetPos;
  SetPos(0, PosEnd);
  GetSize := GetPos;
  SetPos(P, PosAbs);
end;

procedure Stream.Put(B: BasePtr);
external {STREAM};

procedure Stream.Register(TypePtr, StorePtr, LoadPtr: Pointer);
begin
  Inc(TypeCount);
  if TypeList <> nil then
  begin
    TypeList^[TypeCount] := PtrRec(TypePtr).Ofs;
    with ProcList^[TypeCount] do
    begin
      StoreProc := StorePtr;
      LoadProc := LoadPtr;
    end;
  end;
end;

procedure Stream.Seek(Pos: Longint);
begin
  SetPos(Pos, PosAbs);
end;

{ DosStream }

constructor DosStream.Init(FileName: FNameStr; Mode: Word);
var
  L: Integer;
begin
  if not Stream.Init then Fail;
  L := Length(FileName);
  Move(FileName[1], FileName[0], L);
  FileName[L] := #0;
  Open(FileName, Mode);
end;

destructor DosStream.Done;
begin
  Close;
  Stream.Done;
end;

function DosStream.GetPos: Longint;
external {DOSSTM};

procedure DosStream.Read(var Buf; Count: Word);
external {DOSSTM};

procedure DosStream.SetPos(Pos: Longint; Mode: Byte);
external {DOSSTM};

procedure DosStream.Truncate;
external {DOSSTM};

procedure DosStream.Write(var Buf; Count: Word);
external {DOSSTM};

procedure DosStream.Close;
external {DOSSTM};

procedure DosStream.Open(var Name; Mode: Word);
external {DOSSTM};

{ BufStream }

constructor BufStream.Init(FileName: FNameStr; Mode, Size: Word);
begin
  GetMem(Buffer, Size);
  if Buffer = nil then Fail;
  if not DosStream.Init(FileName, Mode) then
  begin
    FreeMem(Buffer, Size);
    Fail;
  end;
  BufSize := Size;
  BufPtr := 0;
  BufEnd := 0;
end;

destructor BufStream.Done;
begin
  DosStream.Done;
  FreeMem(Buffer, BufSize);
end;

procedure BufStream.Flush;
external {BUFSTM};

function BufStream.GetPos: Longint;
external {BUFSTM};

procedure BufStream.Read(var Buf; Count: Word);
external {BUFSTM};

procedure BufStream.Write(var Buf; Count: Word);
external {BUFSTM};

{ Node }

function Node.Prev: NodePtr;
var
  P: NodePtr;
begin
  P := @Self;
  while P^.Next <> @Self do P := P^.Next;
  Prev := P;
end;

{ List }

procedure List.Append(N: NodePtr);
begin
  Insert(N);
  Last := N;
end;

procedure List.Clear;
begin
  Last := nil;
end;

procedure List.Delete;
var
  P: NodePtr;
begin
  while not Empty do
  begin
    P := First;
    Remove(P);
    Dispose(P, Done);
  end;
end;

function List.Empty: Boolean;
begin
  Empty := Last = nil;
end;

function List.First: NodePtr;
begin
  if Last = nil then First := nil else First := Last^.Next;
end;

procedure List.Insert(N: NodePtr);
begin
  if Last = nil then Last := N else N^.Next := Last^.Next;
  Last^.Next := N;
end;

procedure List.Load(var S: Stream);
var
  P: NodePtr;
begin
  Clear;
  P := NodePtr(S.Get);
  while P <> nil do
  begin
    Append(P);
    P := NodePtr(S.Get);
  end;
end;

function List.Next(N: NodePtr): NodePtr;
begin
  if N = Last then Next := nil else Next := N^.Next;
end;

function List.Prev(N: NodePtr): NodePtr;
begin
  if N = First then Prev := nil else Prev := N^.Prev;
end;

procedure List.Remove(N: NodePtr);
var
  P: NodePtr;
begin
  if Last <> nil then
  begin
    P := Last;
    while (P^.Next <> N) and (P^.Next <> Last) do P := P^.Next;
    if P^.Next = N then
    begin
      P^.Next := N^.Next;
      if Last = N then if P = N then Last := nil else Last := P;
    end;
  end;
end;

procedure List.Store(var S: Stream);
var
  P: NodePtr;
begin
  P := First;
  while P <> nil do
  begin
    S.Put(P);
    P := Next(P);
  end;
  S.Put(nil);
end;

procedure Abstract;
begin
  RunError(211);
end;

end.
