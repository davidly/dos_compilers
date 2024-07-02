{************************************************}
{                                                }
{   Breakout Demo Program                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Bounds;

{
  See BREAKOUT.PAS.
  Contains the Paddle object type and the object types that
  define the boundaries of the playfield.
  This unit is part of the BREAKOUT.PAS example.
}

interface

uses Screen, Bricks, Count, Crt;

type
  ObstaclePtr = ^Obstacle;

  { An ObstacleList is a list of instances of objects derived from the
  object Obstacle.  In order to use all these instances polymorphically,
  All their virtual functions have to have corresponding virtual functions
  in Obstacle, even if they are never used. }

  Obstacle = object(Location)
    Width   : Integer;
    Trap    : Boolean;
    NextPtr : ObstaclePtr;
    constructor Init(InitX, InitY, InitWidth : Integer; SetTrap : Boolean);
    destructor Done; virtual;
    function Collide(var B : Ball) : Boolean; virtual;
    function IsTrap : Boolean; virtual;
    function GetValue : Integer; virtual;
  end;

  ObstacleList = object
    Head : Obstacle;
    Tail : ObstaclePtr;
    constructor Init;
    destructor Done; virtual;
    procedure Append(NewObstacle : ObstaclePtr);
    procedure Show;
    procedure Hide;
    function CheckCollisions(var B : Ball; var Score : Counter) : Boolean;
  end;

  Paddle = object(Obstacle)
    Color : Integer;
    constructor Init(InitX, InitY, InitColor : Integer);
    destructor Done; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure MoveTo(NewX, NewY : Integer); virtual;
    function Collide(var B : Ball) : Boolean; virtual;
  end;

  { There are no instances of the object Boundary.  It's here to provide
    a common basis for the next four objects. }
  Boundary = object(Obstacle)
    constructor Init(InitX, InitY, InitWidth : Integer; SetTrap : Boolean);
  end;

  LeftBound = object(Boundary)
    constructor Init(InitX, InitY, InitWidth : Integer; SetTrap : Boolean);
    function Collide(var B : Ball) : Boolean; virtual;
  end;

  UpperBound = object(Boundary)
    constructor Init(InitX, InitY, InitWidth : Integer; SetTrap : Boolean);
    function Collide(var B : Ball) : Boolean; virtual;
  end;

  RightBound = object(Boundary)
    constructor Init(InitX, InitY, InitWidth : Integer; SetTrap : Boolean);
    function Collide(var B : Ball) : Boolean; virtual;
  end;

  LowerBound = object(Boundary)
    constructor Init(InitX, InitY, InitWidth : Integer; SetTrap : Boolean);
    function Collide(var B : Ball) : Boolean; virtual;
  end;

implementation

constructor Obstacle.Init(InitX, InitY, InitWidth : Integer;
                          SetTrap : Boolean);
begin
  Location.Init(InitX, InitY);
  Width := InitWidth;
  Trap := SetTrap;
  NextPtr := nil;
end;

destructor Obstacle.Done;
begin
end;

function Obstacle.Collide(var B : Ball) : Boolean;
begin
  Collide := True;
end;

function Obstacle.IsTrap : Boolean;
begin
  IsTrap := Trap;
end;

function Obstacle.GetValue : Integer;
begin
  GetValue := 0;
end;

constructor ObstacleList.Init;
begin
  Head.Init(0, 0, 0, False);
  Tail := @Head;
end;

destructor ObstacleList.Done;
var
  Temp1, Temp2 : ObstaclePtr;
begin
  Temp1 := Head.NextPtr;
  while Temp1 <> nil do
  begin
    Temp2 := Temp1;
    Temp1 := Temp1^.NextPtr;
    Temp2^.Done;
  end;
end;

procedure ObstacleList.Append(NewObstacle : ObstaclePtr);
begin
  Tail^.NextPtr := NewObstacle;
  Tail := NewObstacle;
end;

procedure ObstacleList.Show;
var
  Current : ObstaclePtr;
begin
  Current := Head.NextPtr;
  while Current <> nil do
  begin
    Current^.Show;
    Current := Current^.NextPtr;
  end;
end;

procedure ObstacleList.Hide;
var
  Current : ObstaclePtr;
begin
  Current := Head.NextPtr;
  while Current <> nil do
  begin
    Current^.Hide;
    Current := Current^.NextPtr;
  end;
end;


{ This function is a little more complex than I like.  It checks
whether a collision occurs, and updates the score if one does. }

function ObstacleList.CheckCollisions(var B : Ball;
                                      var Score : Counter) : Boolean;
var
  Current : ObstaclePtr;
begin
  CheckCollisions := False;
  Current := Head.NextPtr;
  while Current <> nil do
  begin
    if Current^.Collide(B) then
    begin
      Score.Add(Current^.GetValue);
      if Current^.IsTrap then
        CheckCollisions := True;
    end;
    Current := Current^.NextPtr;
  end;
end;

constructor Paddle.Init(InitX, InitY, InitColor : Integer);
begin
  Obstacle.Init(InitX, InitY, 5, False);
  Color := InitColor;
end;

destructor Paddle.Done;
begin
  Obstacle.Done;
end;

procedure Paddle.Show;
var
  Str : String[10];
begin
  FillChar(Str[1], Width, Chr(223));
  Str[0] := Chr(Width);
  Location.Show;
  TextColor(Color);
  GoToXY(X, Y);
  Write(Str);
end;

procedure Paddle.Hide;
begin
  Location.Hide;
  GoToXY(X, Y);
  Write('' : Width);
end;

{ The motion of Paddle is restricted to the 80-character screen }

procedure Paddle.MoveTo(NewX, NewY : Integer);
begin
  Hide;
  if NewX < 1 then
    X := 1
  else if NewX > 81 - Width then
    X := 81 - Width
  else
    X := NewX;
  Y := NewY;
  Show;
end;

{ If the ball hits the paddle we have to change the ball's direction.
  Also, to keep the overall logic simpler, if the paddle is at the
  edge of the screen and the ball would miss the paddle and go off the
  edge, we call it a hit.  If we don't do this here, we get into some
  complications with bouncing off the sides of the screen }

function Paddle.Collide(var B : Ball) : Boolean;
var
  NewX, NewY : Integer;
begin
  NewX := B.NextX;
  NewY := B.NextY;
  Collide := False;
  if (NewY = Y) then
    if ((NewX >= X) and (NewX < X + Width)) or
      ((NewX < 1) and (X = 1)) or
      ((NewX > 80) and (X + Width = 81)) then
    begin
      B.ReverseY;
{$IFDEF Test}  { If the paddle is following the ball, we have to put
                 in some random behavior so it doesn't get boring. }
      B.ChangeXVel(Integer(Random(2))*2-1);
{$ELSE}
      B.ChangeXVel(B.GetX - X - 2);
{$ENDIF}
      Collide := True;
    end;
end;

constructor Boundary.Init(InitX, InitY, InitWidth : Integer;
                          SetTrap : Boolean);
begin
  Obstacle.Init(InitX, InitY, InitWidth, SetTrap);
end;

constructor LeftBound.Init(InitX, InitY, InitWidth : Integer;
                           SetTrap : Boolean);
begin
  Boundary.Init(InitX, InitY, InitWidth, SetTrap);
end;

function LeftBound.Collide(var B : Ball) : Boolean;
begin
  Collide := False;
  if (B.NextX <= X) and (B.NextY >= Y) and (B.NextY <= Y + Width) then
  begin
    B.ReverseX;
    Collide := True;
  end;
end;

constructor UpperBound.Init(InitX, InitY, InitWidth : Integer;
                            SetTrap : Boolean);
begin
  Boundary.Init(InitX, InitY, InitWidth, SetTrap);
end;

function UpperBound.Collide(var B : Ball) : Boolean;
begin
  Collide := False;
  if (B.NextY <= Y) and (B.NextX >= X) and (B.NextX <= X + Width) then
  begin
    B.ReverseY;
    Collide := True;
  end;
end;

constructor RightBound.Init(InitX, InitY, InitWidth : Integer;
                            SetTrap : Boolean);
begin
  Boundary.Init(InitX, InitY, InitWidth, SetTrap);
end;

function RightBound.Collide(var B : Ball) : Boolean;
begin
  Collide := False;
  if (B.NextX >= X) and (B.NextY >= Y) and (B.NextY <= Y + Width) then
  begin
    B.ReverseX;
    Collide := True;
  end;
end;

constructor LowerBound.Init(InitX, InitY, InitWidth : Integer;
                            SetTrap : Boolean);
begin
  Boundary.Init(InitX, InitY, InitWidth, SetTrap);
end;

function LowerBound.Collide(var B : Ball) : Boolean;
begin
  Collide := False;
  if (B.NextY >= Y) and (B.NextX >= X) and (B.NextX <= X + Width) then
  begin
    B.ReverseY;
    Collide := True;
  end;
end;

end.
