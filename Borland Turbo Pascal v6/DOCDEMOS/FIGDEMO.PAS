
{ Copyright (c) 1989,90 by Borland International }

program FigureDemo;
{ From Chapter 4 the Turbo Pascal 6.0 User's Guide.
  Extending FIGURES.PAS with type Arc.

  If you are running this program in the IDE, be sure to enable
  the full graphics save option when you load TURBO.EXE:

    turbo -g

  This ensures that the IDE fully swaps video RAM and keeps
  "dustclouds" from appearing on the user screen when in
  graphics mode. You can enable this option permanently
  via the Options|Environment|Startup dialog.

  This program uses the Graph unit and its .BGI driver files to
  display graphics on your system. The "PathToDrivers"
  constant defined below is set to \TP\BGI, which is the default
  location of the BGI files as installed by the INSTALL program.
  If you have installed these files in a different location, make
  sure the .BGI file for your system (EGAVGA.BGI, etc.) is in the
  current directory or modify the "PathToDrivers" constant
  accordingly.
}

uses Crt, DOS, Graph, Figures;

const
  PathToDrivers = '\TP\BGI';  { Default location of *.BGI files }

type
  Arc = object (Circle)
    StartAngle, EndAngle : Integer;
    constructor Init(InitX, InitY: Integer; InitRadius: Integer;
      InitStartAngle, InitEndAngle: Integer);
    procedure Show; virtual;
    procedure Hide; virtual;
  end;

var
  GraphDriver: Integer;
  GraphMode: Integer;
  ErrorCode: Integer;
  AnArc: Arc;
  ACircle: Circle;


{--------------------------------------------------------}
{ Arc's method declarations:                             }
{--------------------------------------------------------}

constructor Arc.Init(InitX,InitY: Integer; InitRadius: Integer;
  InitStartAngle, InitEndAngle: Integer);
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
  TempColor: Word;
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
  GraphDriver := Detect; { Let BGI determine which board you're using }
  DetectGraph(GraphDriver, GraphMode);
  InitGraph(GraphDriver, GraphMode, PathToDrivers);
  if GraphResult <> GrOK then
  begin
    Writeln(GraphErrorMsg(GraphDriver));
    if GraphDriver = grFileNotFound then
    begin
      Writeln('in ', PathToDrivers,
        '. Modify this program''s "PathToDrivers"');
      Writeln('constant to specify the actual location of this file.');
      Writeln;
    end;
    Writeln('Press Enter...');
    Readln;
    Halt(1);
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
end.
