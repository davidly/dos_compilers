{************************************************}
{                                                }
{   Breakout Demo Program                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Bricks;

{
  See BREAKOUT.PAS.
  This unit contains the Ball object and the object types that
  end up as bricks on the screen.
}

interface

uses Screen, Count;

type
  Block = object(Location)
    Color : Integer;
    Width : Integer;
    BChar : Char;
    constructor Init(InitX, InitY, InitColor, InitWidth : Integer;
                     InitChr : Char);
    procedure Show; virtual;
    procedure Hide; virtual;
  end;

  Ball = object(Block)
    XVel : Integer;
    YVel : Integer;
    constructor Init(InitX, InitY, InitXVel, InitYVel, InitColor : Integer);
    function NextX : Integer;
    function NextY : Integer;
    procedure MoveX;
    procedure MoveY;
    procedure ReverseX;
    procedure ReverseY;
    procedure ChangeXVel(Delta : Integer);
  end;

  Brick = object(Block)
    Value : Integer;
    constructor Init(InitX, InitY, InitColor, InitValue : Integer);
    function GetValue : Integer;
  end;

implementation

uses Crt;

constructor Block.Init(InitX, InitY, InitColor, InitWidth : Integer;
                       InitChr : Char);
begin
  Location.Init(InitX, InitY);
  Color := InitColor;
  Width := InitWidth;
  BChar := InitChr;
end;

procedure Block.Show;
var
  Str : String[10];
begin
  FillChar(Str[1], Width, BChar);
  Str[0] := Chr(Width);
  Location.Show;
  TextColor(Color);
  GoToXY(X, Y);
  Write(Str);
end;

procedure Block.Hide;
begin
  Location.Hide;
  GoToXY(X, Y);
  Write('' : Width);
end;

constructor Brick.Init(InitX, InitY, InitColor, InitValue : Integer);
var
  BlockChar : Char;
begin
  BlockChar := Chr($B2);
  if (LastMode = Mono) and Odd(InitX + InitY) then
        BlockChar := Chr($B0);
  Block.Init(InitX, InitY, InitColor, 5, BlockChar);
  Value := InitValue;
end;

function Brick.GetValue : Integer;
begin
  GetValue := Value;
end;

constructor Ball.Init(InitX, InitY, InitXVel, InitYVel, InitColor : Integer);
begin
  Block.Init(InitX, InitY, InitColor, 1, Chr(15));
  XVel := InitXVel;
  YVel := InitYVel;
end;

function Ball.NextX : Integer;
begin
  NextX := X + XVel;
end;

function Ball.NextY : Integer;
begin
  NextY := Y + YVel;
end;

procedure Ball.MoveX;
begin
  Hide;
  X := NextX;
  Show;
end;

procedure Ball.MoveY;
begin
  Hide;
  Y := NextY;
  Show;
end;

procedure Ball.ReverseX;
begin
  XVel := -XVel;
end;

procedure Ball.ReverseY;
begin
  YVel := -YVel;
end;

{ This procedure introduces the variations in horizontal velocity for
  the ball.  Horizontal velocity ranges from -2 to 2.  If you hit the
  ball with the edge of the paddle, you'll get a large change in
  horizontal velocity. }

procedure Ball.ChangeXVel(Delta : Integer);
begin
  Inc(XVel, Delta);
  if XVel < -2 then
    XVel := -2
  else if XVel > 2 then
    XVel := 2
  else if XVel = 0 then
    XVel := Integer(Random(2))*2 - 1;
end;

end.
