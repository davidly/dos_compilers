
{ Turbo Figures }
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit Figures;
{ From Chapter 4 the Turbo Pascal 6.0 User's Guide.
  Virtual methods & polymorphic objects.
}

interface

uses Graph, Crt;

type
  Location = object
    X,Y: Integer;
    procedure Init(InitX, InitY: Integer);
    function GetX: Integer;
    function GetY: Integer;
  end;

  PointPtr = ^Point;

  Point = object (Location)
    Visible: Boolean;
    constructor Init(InitX, InitY: Integer);
    destructor Done; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    function IsVisible: Boolean;
    procedure MoveTo(NewX, NewY: Integer);
    procedure Drag(DragBy: Integer); virtual;
  end;

  CirclePtr = ^Circle;

  Circle = object (Point)
    Radius: Integer;
    constructor Init(InitX, InitY: Integer; InitRadius: Integer);
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure Expand(ExpandBy: Integer); virtual;
    procedure Contract(ContractBy: Integer); virtual;
  end;

implementation

{--------------------------------------------------------}
{ Location's method implementations:                     }
{--------------------------------------------------------}

procedure Location.Init(InitX, InitY: Integer);

begin
  X := InitX;
  Y := InitY;
end;

function Location.GetX: Integer;
begin
  GetX := X;
end;

function Location.GetY: Integer;
begin
  GetY := Y;
end;


{--------------------------------------------------------}
{ Points's method implementations:                       }
{--------------------------------------------------------}

constructor Point.Init(InitX, InitY: Integer);
begin
  Location.Init(InitX, InitY);
  Visible := False;
end;

destructor Point.Done;
begin
  Hide;
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

function Point.IsVisible: Boolean;
begin
  IsVisible := Visible;
end;

procedure Point.MoveTo(NewX, NewY: Integer);
begin
  Hide;
  X := NewX;
  Y := NewY;
  Show;
end;

function GetDelta(var DeltaX: Integer; var DeltaY: Integer): Boolean;
var
  KeyChar: Char;
  Quit: Boolean;
begin
  DeltaX := 0; DeltaY := 0;      { 0 means no change in position;  }
  GetDelta := True;              { True means we return a delta    }
  repeat
    KeyChar := ReadKey;          { First, read the keystroke }
    Quit := True;                { Assume it's a useable key }
    case Ord(KeyChar) of
       0: begin                  { 0 means an extended, 2-byte code }
            KeyChar := ReadKey;  { Read second byte of code }
            case Ord(KeyChar) of
             72: DeltaY := -1;   { Up arrow; decrement Y }
             80: DeltaY := 1;    { Down arrow; increment Y }
             75: DeltaX := -1;   { Left arrow; decrement X }
             77: DeltaX := 1;    { Right arrow; increment X }
             else Quit := False; { Ignore any other code }
            end; { case }
          end;
      13: GetDelta := False;     { CR pressed means no delta  }
    else Quit := False;          { Ignore any other keystroke }
    end;  { case }
  until Quit;
end;

procedure Point.Drag(DragBy: Integer);
var
  DeltaX, DeltaY: Integer;
  FigureX, FigureY: Integer;
begin
  Show;                          { Display figure to be dragged }
  FigureX := GetX;               { Get the initial position of figure }
  FigureY := GetY;

  { This is the drag loop: }
  while GetDelta(DeltaX, DeltaY) do
  begin                          { Apply delta to figure X,Y: }
    FigureX := FigureX + (DeltaX * DragBy);
    FigureY := FigureY + (DeltaY * DragBy);
    MoveTo(FigureX, FigureY);    { And tell the figure to move }
  end;
end;

{--------------------------------------------------------}
{ Circle's method implementations:                       }
{--------------------------------------------------------}

constructor Circle.Init(InitX, InitY: Integer; InitRadius: Integer);
begin
  Point.Init(InitX, InitY);
  Radius := InitRadius;
end;

procedure Circle.Show;
begin
  Visible := True;
  Graph.Circle(X, Y, Radius);
end;

procedure Circle.Hide;
var
  TempColor: Word;
begin
  TempColor := Graph.GetColor;
  Graph.SetColor(GetBkColor);
  Visible := False;
  Graph.Circle(X, Y, Radius);
  Graph.SetColor(TempColor);
end;

procedure Circle.Expand(ExpandBy: Integer);
begin
  Hide;
  Radius := Radius + ExpandBy;
  if Radius < 0 then Radius := 0;
  Show;
end;

procedure Circle.Contract(ContractBy: Integer);
begin
  Expand(-ContractBy);
end;

{ No initialization section }

end.
