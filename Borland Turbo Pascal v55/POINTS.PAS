
{ Turbo Points }
{ Copyright (c) 1989 by Borland Interational, Inc. }

unit Points;
{ From P-20 of the Object-Oriented Programming Guide.
}

interface

uses Graph;

type
  Location = object
    X,Y : Integer;
    procedure Init(InitX, InitY : Integer);
    function GetX : Integer;
    function GetY : Integer;
  end;

  Point = object (Location)
    Visible : Boolean;
    procedure Init(InitX, InitY : Integer);
    procedure Show;
    procedure Hide;
    function IsVisible : Boolean;
    procedure MoveTo(NewX, NewY : Integer);
  end;

implementation

{--------------------------------------------------------}
{ Location's method implementations:                     }
{--------------------------------------------------------}

procedure Location.Init(InitX, InitY : Integer);
begin
  X := InitX;
  Y := InitY;
end;

function Location.GetX : Integer;
begin
  GetX := X;
end;

function Location.GetY : Integer;
begin
  GetY := Y;
end;


{--------------------------------------------------------}
{ Points's method implementations:                       }
{--------------------------------------------------------}

procedure Point.Init(InitX, InitY : Integer);
begin
  Location.Init(InitX, InitY);
  Visible := False;
end;

procedure Point.Show;
begin
  Visible := True;
  PutPixel(X, Y, GetColor);
end;

procedure Point.Hide;
begin
  Visible := False;
  PutPixel(X, Y, GetBkColor);
end;

function Point.IsVisible : Boolean;
begin
  IsVisible := Visible;
end;

procedure Point.MoveTo(NewX, NewY : Integer);
begin
  Hide;
  Location.Init(NewX, NewY);
  Show;
end;

end.
