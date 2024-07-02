{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Create a collection of graphical objects: Points, Circles,
  and Rectangles. Use the ForEach iterator to display each
  object in the collection.

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

program Collect4;

uses
  Objects, Graph;

const
  PathToDrivers = '\TP\BGI';  { Default location of *.BGI files }

{ ********************************** }
{ ******  Graphical Objects  ******* }
{ ********************************** }

type
  PGraphObject = ^TGraphObject;
  TGraphObject = object(TObject)
    X,Y: Integer;
    constructor Init;
    procedure Draw; virtual;
  end;

  PGraphPoint = ^TGraphPoint;
  TGraphPoint = object(TGraphObject)
    procedure Draw; virtual;
  end;

  PGraphCircle = ^TGraphCircle;
  TGraphCircle = object(TGraphObject)
    Radius: Integer;
    constructor Init;
    procedure Draw; virtual;
  end;

  PGraphRect = ^TGraphRect;
  TGraphRect = object(TGraphObject)
    Width, Height: Integer;
    constructor Init;
    procedure Draw; virtual;
  end;

{ TGraphObject }
constructor TGraphObject.Init;
begin
  X := Random(GetMaxX);
  Y := Random(GetMaxY);
end;

procedure TGraphObject.Draw;
begin
  Abstract;     { Give error: This object should never be drawn }
end;

{ TGraphPoint }
procedure TGraphPoint.Draw;
var
  DX, DY: Integer;
begin
  { Make it a fat point so you can see it }
  for DX := x - 2 to x + 2 do
    for DY := y - 2 to y + 2 do
      PutPixel(DX, DY, 1);
end;

{ TGraphCircle }
constructor TGraphCircle.Init;
begin
  inherited Init;
  Radius := 20 + Random(20);
end;

procedure TGraphCircle.Draw;
begin
  Circle(X, Y, Radius);
end;

{ TGraphRect }
constructor TGraphRect.Init;
begin
  inherited Init;
  Width := 10 + Random(20) + X;
  Height := 6 + Random(15) + Y;
end;

procedure TGraphRect.Draw;
begin
  Rectangle(X, Y, X + Width, Y + Height);
end;


{ ********************************** }
{ ************  Globals ************ }
{ ********************************** }

{ Abort the program and give a message }

procedure Abort(Msg: String);
begin
  Writeln;
  Writeln(Msg);
  Writeln('Program aborting');
  Halt(1);
end;

{ Put the system into graphics mode }

procedure StartGraphics;
var
  Driver, Mode: Integer;
begin
  Driver := Detect;
  InitGraph(Driver, Mode, PathToDrivers);
  if GraphResult <> GrOK then
  begin
    Writeln(GraphErrorMsg(Driver));
    if Driver = grFileNotFound then
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
end;

{ Use the ForEach iterator to traverse and
  show all the collection of graphical objects.
}

procedure DrawAll(C: PCollection);

{ Nested, far procedure. Receives one
  collection element--a GraphObject, and
  calls that elements Draw method.
}

procedure CallDraw(P : PGraphObject); far;
begin
  P^.Draw;                            { Call Draw method }
end;

begin { DrawAll }
  C^.ForEach(@CallDraw);              { Draw each object }
end;

{ Instantiate and draw a collection of objects }

procedure MakeCollection(var List: PCollection);
var
  I: Integer;
  P: PGraphObject;
begin
  { Initialize collection to hold 10 elements first, then grow by 5's }
  List := New(PCollection, Init(10, 5));

  for I := 1 to 20 do
  begin
    case I mod 3 of                      { Create it }
      0: P := New(PGraphPoint, Init);
      1: P := New(PGraphCircle, Init);
      2: P := New(PGraphRect, Init);
    end;
    List^.Insert(P);                     { Add it to collection }
  end;
end;

{ ********************************** }
{ **********  Main Program ********* }
{ ********************************** }

var
  GraphicsList: PCollection;
begin
  StartGraphics;                       { Activate graphics }

  MakeCollection(GraphicsList);        { Generate and collect figures }
  DrawAll(GraphicsList);               { Use iterator to draw all }
  Readln;                              { Pause to view figures }

  { Clean up }
  Dispose(GraphicsList, Done);         { Delete collection }
  CloseGraph;                          { Shut down graphics }
end.
