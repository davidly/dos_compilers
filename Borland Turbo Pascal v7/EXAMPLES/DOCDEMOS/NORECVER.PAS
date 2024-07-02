{************************************************}
{                                                }
{   Demo program                                 }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ NORECVER.PAS }
{ This example doesn't implement constructor-error recovery }

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
  L1^ := S1;
  L2^ := S2;
end;

destructor Base.Done;
begin
  Dispose(L2);
  Dispose(L1);
end;

procedure Base.Dump;
begin
  WriteLn('B: ', L1^, ', ', L2^, '.');
end;

constructor Derived.Init(S1, S2, S3, S4: Line);
begin
  Base.Init(S1, S2);
  New(L3);
  New(L4);
  L3^ := S3;
  L4^ := S4;
end;

destructor Derived.Done;
begin
  Dispose(L4);
  Dispose(L3);
  Base.Done;
end;

procedure Derived.Dump;
begin
  WriteLn('D: ', L1^, ', ', L2^, ', ', L3^, ', ', L4^, '.');
end;

begin
  New(BP, Init('Borland', 'International'));
  New(DP, Init('North', 'East', 'South', 'West'));
  BP^.Dump;
  DP^.Dump;
  Dispose(DP, Done);
  Dispose(BP, Done);
end.
