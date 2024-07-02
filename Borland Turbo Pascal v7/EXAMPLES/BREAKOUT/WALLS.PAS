{************************************************}
{                                                }
{   Breakout Demo Program                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Walls;

{
  See BREAKOUT.PAS.
  This unit defines the Wall object type.
  It's a fairly complex object, because it plays such a
  pivotal role in the game.
}

interface

uses Screen, Bricks, Bounds, Crt;

type
  BrickPtr = ^Brick;
  BW = array[1..1000] of Brick;
  WallPtr = ^BW;

  Wall = object(Obstacle)
    BrickWall : WallPtr;
    Height : Integer;
    NumLeft : Integer;
    Value : Integer;
    NCells : Integer;
    constructor Init(InitX, InitY, InitWidth, InitHeight : Integer);
    destructor Done; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    function Collide(var B : Ball) : Boolean; virtual;
    function GetValue : Integer; virtual;
    procedure Reset;
  end;

implementation

function RandomColor(MaxColors : Integer) : Integer;
var
  C : Integer;
begin
  C := Random(MaxColors);
  while C = (TextAttr SHR 4) do
    C := Random(MaxColors);
  RandomColor := C;
end;

procedure Beep;
begin
  Sound(100);
  Delay(20);
  NoSound;
end;

{ A wall is an array of bricks.  Its constructor actually builds a
  conformant array, so we don't have to hardcode the size of the
  wall. }

constructor Wall.Init(InitX, InitY, InitWidth, InitHeight : Integer);
begin
  Obstacle.Init(InitX, InitY, InitWidth, False);
  Height := InitHeight;
  NCells := Width*5;
  GetMem(BrickWall, Width*Height*SizeOf(Brick));
  Reset;
end;

destructor Wall.Done;
begin
  FreeMem(BrickWall, Width*Height*SizeOf(Block));
end;

{ This procedure could be made simpler, but you wouldn't get the slick
  effect you see when the wall is built. }

procedure Wall.Show;
var
  CurCol : Integer;
  Count : Integer;
  CurBlock : Integer;
begin
  Visible := True;
  NumLeft := Width*Height;
  for CurCol := 1 to Width + Height - 1 do
    for Count := 0 to Height - 1 do
    begin
      CurBlock := CurCol + Count*(Width-1);
      if (CurCol - Count >= 1) and (CurCol - Count <= Width) then
      begin
        BrickWall^[CurBlock].Show;
        Delay(5);
      end;
    end;
  GoToXY(X + (5*Width DIV 2) - 7, Y);
  TextColor(WHITE);
  Write('Turbo Breakout');
end;

procedure Wall.Hide;
var
  CurCol : Integer;
  Count : Integer;
  CurBlock : Integer;
begin
  Visible := False;
  for CurCol := 1 to Width + Height - 1 do
    for Count := 0 to Height - 1 do
    begin
      CurBlock := CurCol + Count*(Width-1);
      if (CurCol - Count >= 1) and (CurCol - Count <= Width) then
      begin
        if BrickWall^[CurBlock].IsVisible then
        begin
          BrickWall^[CurBlock].Hide;
          Delay(5);
        end;
      end;
    end;
end;

function Wall.Collide(var B : Ball) : Boolean;
var
  CollideV, CollideH : Boolean;

{ To check for a collision with a brick, first we check if the ball is in
  the area where the wall is located, then we see if there's a brick that's
  still visible at the ball's position.  If so, we destroy the brick, grab
  its value, and beep. }

function CheckCollide(XPos, YPos : Integer) : Boolean;
var
  ThisBrick : BrickPtr;
begin
  CheckCollide := False;
  if (YPos < Y) or (YPos > Y + Height - 1) or
     (XPos < X) or (XPos > X + NCells - 1) then
    Exit;
  ThisBrick := @BrickWall^[1 + ((XPos-1) DIV 5) + Width*(YPos - 1)];
  if ThisBrick^.IsVisible then
  begin
    CheckCollide := True;
    Inc(Value, ThisBrick^.GetValue);
    ThisBrick^.Hide;
    Dec(NumLeft);
    Beep;
    if NumLeft = 0 then
      Show;
  end
end;

{ When checking for a collision with the wall, we have to watch out
  for special cases involving corners. }

begin
  Collide := False;
  Value := 0;
  CollideV := CheckCollide(B.X, B.NextY);
  CollideH := CheckCollide(B.NextX, B.Y);
  if CollideV then
  begin
    Collide := True;
    B.ReverseY;
  end;
  if CollideH then
  begin
    Collide := True;
    B.ReverseX;
  end;
  if not CollideV and not CollideH then
    if CheckCollide(B.NextX, B.NextY) then
    begin
      Collide := True;
      B.ReverseX;
      B.ReverseY;
    end;
end;

function Wall.GetValue : Integer;
begin
    GetValue := Value;
end;

procedure Wall.Reset;
var
  CurRow : Integer;
  CurCol : Integer;
  MaxColors : Integer;
begin
  if LastMode = Mono then
    MaxColors := 4
  else
    MaxColors := 16;
  NumLeft := Width*Height;
  for CurRow := 0 to Height - 1 do
    for CurCol := 0 to Width - 1 do
      BrickWall^[CurRow*Width+CurCol+1].Init(X + CurCol*5,
                                             Y + CurRow,
                                             RandomColor(MaxColors),
                                             Height - Y - CurRow + 1);
  if Visible then
    Show;
end;

end.
