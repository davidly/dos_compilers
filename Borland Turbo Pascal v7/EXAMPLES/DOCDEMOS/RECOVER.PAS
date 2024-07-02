{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ RECOVER.PAS }
{ This program implements constructor-error recovery }

type
  LinePtr = ^Line;
  Line = string[79];

  BasePtr = ^Base;
  Base = object
    L1, L2: LinePtr;
    constructor Init(S1, S2: Line);
    destructor Done; virtual;
    procedure Dump; virtual;
  end;

  DerivedPtr = ^Derived;
  Derived = object(Base)
    L3, L4: LinePtr;
    constructor Init(S1, S2, S3, S4: Line);
    destructor Done; virtual;
    procedure Dump; virtual;
  end;

var
  BP: BasePtr;
  DP: DerivedPtr;

constructor Base.Init(S1, S2: Line);
begin
  New(L1);
  New(L2);
  if (L1 = nil) or (L2 = nil) then
  begin
    Base.Done;
    Fail;
  end;
  L1^ := S1;
  L2^ := S2;
end;

destructor Base.Done;
begin
  if L2 <> nil then Dispose(L2);
  if L1 <> nil then Dispose(L1);
end;

procedure Base.Dump;
begin
  WriteLn('B: ', L1^, ', ', L2^, '.');
end;

constructor Derived.Init(S1, S2, S3, S4: Line);
begin
  if not Base.Init(S1, S2) then Fail;
  New(L3);
  New(L4);
  if (L3 = nil) or (L4 = nil) then
  begin
    Derived.Done;
    Fail;
  end;
  L3^ := S3;
  L4^ := S4;
end;

destructor Derived.Done;
begin
  if L4 <> nil then Dispose(L4);
  if L3 <> nil then Dispose(L3);
  Base.Done;
end;

procedure Derived.Dump;
begin
  WriteLn('D: ', L1^, ', ', L2^, ', ', L3^, ', ', L4^, '.');
end;

{$F+}
function HeapFunc(Size: Word): Integer;
begin
  HeapFunc := 1;
end;
{$F-}

begin
  HeapError := @HeapFunc;               { Install heap error handler }
  New(BP, Init('Borland', 'International'));
  New(DP, Init('North', 'East', 'South', 'West'));
  if (BP = nil) or (DP = nil) then
    WriteLn('Allocation error')
  else
  begin
    BP^.Dump;
    DP^.Dump;
  end;
  if DP <> nil then Dispose(DP, Done);
  if BP <> nil then Dispose(BP, Done);
end.

