{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+,V-}

unit Count;

interface

uses Objects, Drivers, Views;


type
  PCountView = ^TCountView;
  TCountView = object(TView)
    Current: Longint;
    Count: Longint;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure SetCount(NewCount: Longint);
    procedure IncCount;
    procedure DecCount;
    procedure SetCurrent(NewCurrent: Longint);
    procedure IncCurrent;
    procedure DecCurrent;
    procedure Store(var S: TStream); virtual;
  end;

procedure RegisterCount;

const
  CCountView = #1#2#3#8#9;

  RCountView: TStreamRec = (
    ObjType: 992;
    VmtLink: Ofs(TypeOf(TCountView)^);
    Load: @TCountView.Load;
    Store: @TCountView.Store
  );

implementation

{ TCountView  }
constructor TCountView.Init(var Bounds:TRect);
begin
  inherited Init(Bounds);
  SetCount(0);
  SetCurrent(1);
end;

constructor TCountView.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Current, SizeOf(Current));
  S.Read(Count, SizeOf(Count));
end;

procedure TCountView.Draw;
var
  B: TDrawBuffer;
  C: Word;
  Params: array[0..1] of Longint;
  Start: Word;
  First: String[10];
  Display: String[20];
begin
  C := GetColor(2);  { Uses same color as frame }
  MoveChar(B, 'Í', C, Size.X);

  Params[0] := Current;
  Params[1] := Count;
  FormatStr(Display, ' ~%d~ of %d ', Params);

  { If Current is greater than Count, display Current as highlighted }
  if Current > Count then C := GetColor($0504)
  else C := GetColor($0202);

  MoveCStr(B, Display, C);
  WriteLine(0, 0, Size.X, Length(Display), B);
end;

function TCountView.GetPalette: PPalette;
const
  P: string[Length(CCountView)] = CCountView;
begin
  GetPalette := @P;
end;

procedure TCountView.SetCount(NewCount:Longint);
begin
  Count := NewCount;
  DrawView;
end;

procedure TCountView.IncCount;
begin
  SetCount(Count + 1);
end;

procedure TCountView.DecCount;
begin
  SetCount(Count - 1);
end;

procedure TCountView.SetCurrent(NewCurrent:Longint);
begin
  Current := NewCurrent;
  DrawView;
end;

procedure TCountView.IncCurrent;
begin
  SetCurrent(Current + 1);
end;

procedure TCountView.DecCurrent;
begin
  SetCurrent(Current - 1);
end;

procedure TCountView.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Current, SizeOf(Current));
  S.Write(Count, SizeOf(Count));
end;

procedure RegisterCount;
begin
  RegisterType(RCountView);
end;

end.