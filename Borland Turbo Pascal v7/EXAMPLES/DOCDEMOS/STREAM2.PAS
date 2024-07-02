{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Load and display a collection of graphical objects from a
  stream: Points, Circles, Rectangles. This collection was
  created and put on a stream by another program
  (STREAM1.PAS).

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

program STREAM2;

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
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

  PGraphPoint = ^TGraphPoint;
  TGraphPoint = object(TGraphObject)
    procedure Draw; virtual;
  end;

  PGraphCircle = ^TGraphCircle;
  TGraphCircle = object(TGraphObject)
    Radius: Integer;
    constructor Init;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

  PGraphRect = ^TGraphRect;
  TGraphRect = object(TGraphObject)
    Width, Height: Integer;
    constructor Init;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Store(var S: TStream); virtual;
  end;

{ TGraphObject }
constructor TGraphObject.Init;
begin
  X := Random(GetMaxX) div 2;
  Y := Random(GetMaxY) div 2;
end;

constructor TGraphObject.Load(var S: TStream);
begin
  S.Read(X, SizeOf(X));
  S.Read(Y, SizeOf(Y));
end;

procedure TGraphObject.Draw;
begin
  Abstract;     { Give error: This object should never be drawn }
end;

procedure TGraphObject.Store(var S: TStream);
begin
  S.Write(X, SizeOf(X));
  S.Write(Y, SizeOf(Y));
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
  Radius := 30 + Random(20);
end;

constructor TGraphCircle.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Radius, SizeOf(Radius));
end;

procedure TGraphCircle.Draw;
begin
  Circle(X, Y, Radius);
end;

procedure TGraphCircle.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Radius, SizeOf(Radius));
end;

{ TGraphRect }
constructor TGraphRect.Init;
begin
  inherited Init;
  Width := 5 + Random(10) + X;
  Height := 3 + Random(8) + Y;
end;

constructor TGraphRect.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Width, SizeOf(Width));
  S.Read(Height, SizeOf(Height));
end;

procedure TGraphRect.Draw;
begin
  Rectangle(X, Y, X + Width, Y + Height);
end;

procedure TGraphRect.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Width, SizeOf(Width));
  S.Write(Height, SizeOf(Height));
end;

{ ********************************** }
{ **  Stream Registration Records ** }
{ ********************************** }

const
  RGraphPoint: TStreamRec = (
    ObjType: 150;
    VmtLink: Ofs(TypeOf(TGraphPoint)^);
    Load: @TGraphPoint.Load;
    Store: @TGraphPoint.Store);

  RGraphCircle: TStreamRec = (
    ObjType: 151;
    VmtLink: Ofs(TypeOf(TGraphCircle)^);
    Load: @TGraphCircle.Load;
    Store: @TGraphCircle.Store);

  RGraphRect: TStreamRec = (
    ObjType: 152;
    VmtLink: Ofs(TypeOf(TGraphRect)^);
    Load: @TGraphRect.Load;
    Store: @TGraphRect.Store);


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

{ Register all object types that will be put onto the stream.
  This includes standard TVision types, like TCollection.
}

procedure StreamRegistration;
begin
  RegisterType(RCollection);
  RegisterType(RGraphPoint);
  RegisterType(RGraphCircle);
  RegisterType(RGraphRect);
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

procedure CallDraw(P: PGraphObject); far;
begin
  P^.Draw;                                   { Call Draw method }
end;

begin { DrawAll }
  C^.ForEach(@CallDraw);                     { Draw each object }
end;

{ ********************************** }
{ **********  Main Program ********* }
{ ********************************** }

var
  GraphicsList: PCollection;
  GraphicsStream: TBufStream;
begin
  StreamRegistration;                        { Register all streams }

  { Load collection from stream and draw it }
  with GraphicsStream do
  begin
    Init('GRAPHICS.STM', stOpen, 1024);      { Open stream }
    GraphicsList := PCollection(Get);        { Load collection }
    Done;                                    { Shut down stream }
    if Status <> 0 then                      { Check for error }
      Abort('Error loading GRAPHICS.STM (run STREAM1.PAS first)');
  end;

  StartGraphics;                             { Activate graphics }

  DrawAll(GraphicsList);                     { Use iterator to draw all }
  Readln;                                    { Pause to view figures }

  { Clean up }
  Dispose(GraphicsList, Done);               { Delete collection }
  CloseGraph;                                { Shut down graphics }
end.
