{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Demo program from the Turbo Vision Guide     }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVGUID07;

uses Objects, Drivers, Views, Menus, App;

const
  FileToRead        = 'TVGUID07.PAS';
  MaxLines          = 100;
  WinCount: Integer =   0;
  cmFileOpen        = 100;
  cmNewWin          = 101;

var
  LineCount: Integer;
  Lines: array[0..MaxLines - 1] of PString;
   
type
  TMyApp = object(TApplication)
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
    procedure NewWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PDemoWindow = ^TDemoWindow;
  TDemoWindow = object(TWindow)
    constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
  end;

  PInterior = ^TInterior;
  TInterior = object(TView)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
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
constructor TInterior.Init(var Bounds: TRect);
begin
  TView.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofFramed;
end;

procedure TInterior.Draw;
var
  Color: Byte;
  Y: Integer;
  B: TDrawBuffer;
begin
  TView.Draw;
  Color := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', Color, Size.X);
    if (Y < LineCount) and (Lines[Y] <> nil) then
      MoveStr(B, Copy(Lines[Y]^, 1, Size.X), Color);
    WriteLine(0, Y, Size.X, 1, B);
  end;
end;

{ TDemoWindow }
constructor TDemoWindow.Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
var
  S: string[3];
  Interior: PInterior;
begin
  Str(WindowNo, S);
  TWindow.Init(Bounds, WinTitle + ' ' + S, wnNoNumber);
  GetClipRect(Bounds);
  Bounds.Grow(-1, -1);
  Interior := New(PInterior, Init(Bounds));
  Insert(Interior);
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
  R.Assign(0, 0, 24, 7);
  R.Move(Random(55), Random(16));
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
