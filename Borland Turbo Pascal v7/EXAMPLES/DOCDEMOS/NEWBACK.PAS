{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program NewBack;

uses Objects, Drivers, Views, App;

type
  PMyBackground = ^TMyBackground;
  TMyBackground = object(TBackground)
    Text: TTitleStr;
    constructor Init(var Bounds: TRect; AText: TTitleStr);
    procedure Draw; virtual;
  end;

  PMyDesktop = ^TMyDesktop;
  TMyDesktop = object(TDesktop)
    procedure InitBackground; virtual;
  end;

  TMyApplication = object(TApplication)
    procedure InitDesktop; virtual;
  end;

constructor TMyBackground.Init(var Bounds: TRect; AText: TTitleStr);
begin
  inherited Init(Bounds, ' ');
  Text := AText;
  while Length(Text) < SizeOf(TTitleStr) - 1 do
    Text := Text + AText;
end;

procedure TMyBackground.Draw;
var
  DrawBuffer: TDrawBuffer;
begin
  MoveStr(DrawBuffer, Text, GetColor(1));
  WriteLine(0, 0, Size.X, Size.Y, DrawBuffer);
end;

procedure TMyDesktop.InitBackground;
var
  R: TRect;
begin
  GetExtent(R);
  Background := New(PMyBackground, Init(R, 'I Love Pascal! '));
end;

procedure TMyApplication.InitDesktop;
var
  R: TRect;
begin
  GetExtent(R);
  R.Grow(0, -1);
  Desktop := New(PMyDesktop, Init(R));
end;

var
  MyApp: TMyApplication;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
