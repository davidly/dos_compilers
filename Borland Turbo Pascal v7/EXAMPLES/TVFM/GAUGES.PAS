{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Gauges;

{$V-}

interface

uses Drivers, Objects, Views;

const
  cmUpdateGauge = 12000;
  cmResetGauge = 12001;
  cmAddGauge   = 12002;

type
  PPercentGauge = ^TPercentGauge;
  TPercentGauge = object(TView)
    MaxValue: Longint;
    CurValue: Longint;
    constructor Init(var Bounds: TRect; AMaxValue: Longint);
    procedure Draw; virtual;
    procedure Update(Progress: Longint); virtual;
    procedure AddProgress(Progress: Longint);
    procedure HandleEvent(var Event: TEvent); virtual;
    function SolveForX(Y, Z: Longint): Integer;
    function SolveForY(X, Z: Longint): Integer;
  end;

  PBarGauge = ^TBarGauge;
  TBarGauge = object(TPercentGauge)
    procedure Draw; virtual;
  end;

implementation

constructor TPercentGauge.Init(var Bounds: TRect; AMaxValue: Longint);
begin
  inherited Init(Bounds);
  EventMask := EventMask or evBroadcast;
  MaxValue := AMaxValue;
  CurValue := 0;
end;

procedure TPercentGauge.Draw;
var
  B: TDrawBuffer;
  C: Word;
  S: string[10];
  PercentDone: Longint;
begin
  C := GetColor(1);
  MoveChar(B, ' ', C, Size.X);
  PercentDone := SolveForY(CurValue, MaxValue);
  FormatStr(S, '%-3d%%', PercentDone);
  MoveStr(B, S, C);
  WriteLine(0,0,Size.X,Size.Y,B);
end;

procedure TPercentGauge.Update(Progress: Longint);
begin
  CurValue := Progress;
  DrawView;
end;

procedure TPercentGauge.AddProgress(Progress: Longint);
begin
  Update(Progress + CurValue);
end;

procedure TPercentGauge.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
  begin
    case Event.Command of
      cmUpdateGauge :
        begin
          Update(Event.InfoLong);
        end;
      cmResetGauge:
        begin
          MaxValue := Event.InfoLong;
          Update(0);
        end;
      cmAddGauge:
        begin
          AddProgress(Event.InfoLong);
        end;
    end;
  end;
end;

{ This function solves for x in the equation "x is y% of z". }
function TPercentGauge.SolveForX(Y, Z: Longint): Integer;
begin
  SolveForX := Trunc( Z * (Y * 0.01) );
end;

{ This function solves for y in the equation "x is y% of z". }
function TPercentGauge.SolveForY(X, Z: Longint): Integer;
begin
  if Z = 0 then SolveForY := 0
  else SolveForY := Trunc( (X * 100) / Z );
end;


{ TBarGauge }
procedure TBarGauge.Draw;
var
  B: TDrawBuffer;
  C: Word;
  PercentDone: Longint;
  FillSize: Integer;
begin
  C := GetColor(1);
  MoveChar(B, #176, C, Size.X);
  PercentDone := SolveForY(CurValue, MaxValue);
  FillSize := SolveForX(PercentDone, Size.X);
  if FillSize > Size.X then FillSize := Size.X;
  MoveChar(B, #178, C, FillSize);
  WriteLine(0,0,Size.X,Size.Y,B);
end;

end.