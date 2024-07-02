
{ Copyright (c) 1989 by Borland Interational, Inc. }

program FigureDemo;
{ From P-47 of the Object-Oriented Programming Guide.
  Extending FIGURES.PAS with type Arc.
}

uses Crt, DOS, Graph, Figures;

type
  Arc = object (Circle)
    StartAngle, EndAngle : Integer;
    constructor Init(InitX, InitY : Integer;
                     InitRadius : Integer;
                     InitStartAngle, InitEndAngle : Integer);
    procedure Show; virtual;
    procedure Hide; virtual;
  end;

var
  GraphDriver : Integer;
  GraphMode : Integer;
  ErrorCode : Integer;
  AnArc : Arc;
  ACircle : Circle;


{--------------------------------------------------------}
{ Arc's method declarations:                             }
{--------------------------------------------------------}

constructor Arc.Init(InitX,InitY : Integer;
                     InitRadius : Integer;
                     InitStartAngle, InitEndAngle : Integer);
begin
  Circle.Init(InitX, InitY, InitRadius);
  StartAngle := InitStartAngle;
  EndAngle   := InitEndAngle;
end;

procedure Arc.Show;
begin
  Visible := True;
  Graph.Arc(X, Y, StartAngle, EndAngle, Radius);
end;

procedure Arc.Hide;
var
  TempColor : Word;
begin
  TempColor := Graph.GetColor;
  Graph.SetColor(GetBkColor);
  Visible := False;
  { Draw the arc in the background color to hide it }
  Graph.Arc(X, Y, StartAngle, EndAngle, Radius);
  SetColor(TempColor);
end;


{--------------------------------------------------------}
{ Main program:                                          }
{--------------------------------------------------------}

begin
  GraphDriver := Detect; { Let the BGI determine what board
                           you're using }
  DetectGraph(GraphDriver, GraphMode);
  InitGraph(GraphDriver, GraphMode,'');
  if GraphResult <> GrOK then
    begin
      WriteLn('>>Halted on graphics error:',
              GraphErrorMsg(GraphDriver));
      Halt(1)
    end;

{ All descendents of type Point contain virtual methods and    }
{ *must* be initialized before use through a constructor call. }

  ACircle.Init(151, 82,      { Initial X,Y at 151,82 }
               50);          { Initial radius of 50 pixels }
  AnArc.Init(151, 82,        { Initial X,Y at 151,82 }
             25, 0, 90);     { Initial radius of 50 pixels }
                             { Start angle: 0; End angle: 90 }

{ Replace AnArc with ACircle to drag a circle instead of an }
{ arc. Press Enter to stop dragging and end the program.   }

  ACircle.Drag(5);       { Parameter is # of pixels to drag by }
  CloseGraph;
  RestoreCRTMode;
end.

