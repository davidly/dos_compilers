{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Demo program from the Turbo Vision Guide     }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVGUID10;

uses Objects, Drivers, Views, Menus, App;

const
  FileToRead        = 'TVGUID10.PAS';
  MaxLines          = 100;
  WinCount: Integer =   0;
  cmFileOpen        = 100;
  cmNewWin          = 101;

var
  LineCount: Integer;
  Lines: array[0..MaxLines - 1] of PString;

type
  TMyApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewWindow;
  end;

  PInterior = ^TInterior;
  TInterior = object(TScroller)
    constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PScrollBar);
    procedure Draw; virtual;
  end;

  PDemoWindow = ^TDemoWindow;
  TDemoWindow = object(TWindow)
    RInterior, LInterior: PInterior;
    constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
    function MakeInterior(Bounds: TRect; Left: Boolean): PInterior;
    procedure SizeLimits(var Min, Max: TPoint); virtual;
  end;

procedure ReadFile;
var
  F: Text;
  S: String;
begin
  LineCount := 0;
  Assign(F, FileToRead);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    Writeln('Cannot open ', FileToRead);
    Halt(1);
  end;
  while not Eof(F) and (LineCount < MaxLines) do
  begin
    Readln(F, S);
    Lines[LineCount] := NewStr(S);
    Inc(LineCount);
  end;
  Close(F);
end;

procedure DoneFile;
var
  I: Integer;
begin
  for I := 0 to LineCount - 1 do
    if Lines[I] <> nil then DisposeStr(Lines[i]);
end;

{ TInterior }
constructor TInterior.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar);
begin
  TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  Options := Options or ofFramed;
  SetLimit(128, LineCount);
end;

procedure TInterior.Draw;
var
  Color: Byte;
  I, Y: Integer;
  B: TDrawBuffer;
begin
  Color := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', Color, Size.X);
    i := Delta.Y + Y;
    if (I < LineCount) and (Lines[I] <> nil) then
      MoveStr(B, Copy(Lines[I]^, Delta.X + 1, Size.X), Color);
    WriteLine(0, Y, Size.X, 1, B);
  end;
end;

{ TDemoWindow }
constructor TDemoWindow.Init(Bounds: TRect; WinTitle: String;
  WindowNo: Word);
var
  S: string[3];
  R: TRect;
begin
  Str(WindowNo, S);
  TWindow.Init(Bounds, WinTitle + ' ' + S, wnNoNumber);
  GetExtent(Bounds);
  R.Assign(Bounds.A.X, Bounds.A.Y, Bounds.B.X div 2 + 1, Bounds.B.Y);
  LInterior := MakeInterior(R, True);
  LInterior^.GrowMode := gfGrowHiY;
  Insert(Linterior);
  R.Assign(Bounds.B.X div 2, Bounds.A.Y, Bounds.B.X, Bounds.B.Y);
  RInterior := MakeInterior(R,False);
  RInterior^.GrowMode := gfGrowHiX + gfGrowHiY;
  Insert(RInterior);
end;

function TDemoWindow.MakeInterior(Bounds: TRect; Left: Boolean): PInterior;
var
  HScrollBar, VScrollBar: PScrollBar;
  R: TRect;
begin
  R.Assign(Bounds.B.X - 1, Bounds.A.Y + 1, Bounds.B.X, Bounds.B.Y - 1);
  VScrollBar := New(PScrollBar, Init(R));
  VScrollBar^.Options := VScrollBar^.Options or ofPostProcess;
  if Left then VScrollBar^.GrowMode := gfGrowHiY;
  Insert(VScrollBar);
  R.Assign(Bounds.A.X + 2, Bounds.B.Y - 1, Bounds.B.X - 2, Bounds.B.Y);
  HScrollBar := New(PScrollBar, Init(R));
  HScrollBar^.Options := HScrollBar^.Options or ofPostProcess;
  if Left then HScrollBar^.GrowMode := gfGrowHiY + gfGrowLoY;
  Insert(HScrollBar);
  Bounds.Grow(-1, -1);
  MakeInterior := New(PInterior, Init(Bounds, HScrollBar, VScrollBar));
end;

procedure TDemoWindow.SizeLimits(var Min, Max: TPoint);
var R: TRect;
begin
  TWindow.SizeLimits(Min, Max);
  Min.X := LInterior^.Size.X + 9;
end;

{ TMyApp }
procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewWin: NewWindow;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen', 'F3', kbF3, cmFileOpen, hcNoContext,
      NewItem('~N~ew', 'F4', kbF4, cmNewWin, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      nil))),
    nil))
  )));
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F4~ New', kbF4, cmNewWin,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)))),
    nil)
  ));
end;

procedure TMyApp.NewWindow;
var
  Window: PDemoWindow;
  R: TRect;
begin
  Inc(WinCount);
  R.Assign(0, 0, 45, 13);
  R.Move(Random(34), Random(11));
  Window := New(PDemoWindow, Init(R, 'Demo Window', WinCount));
  DeskTop^.Insert(Window);
end;

var
  MyApp: TMyApp;

begin
  ReadFile;
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
  DoneFile;
end.
