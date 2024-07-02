{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision BGI Support Demo                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVBGI;

{$M 8192,8192,655360}
{$S-}

{ This simple Vision program shows how to use GRAPHAPP unit
  to control switching back and forth to BGI routines from
  inside a Turbo Vision application.

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

{$X+}

uses
  Dos, Graph, Objects, Drivers, Memory, Views, Menus, Dialogs,
  StdDlg, MsgBox, App, GraphApp;

const
  PathToDrivers = '\TP\BGI';  { Default location of *.BGI files }

  cmTile       = 100;
  cmCascade    = 101;
  cmNewWin     = 1000;
  cmChangeDir  = 1001;
  cmSetBGIPath = 1002;
  cmDoGraphics = 1003;

  hlChangeDir  = cmChangeDir;        { History list ID }
  hlSetBGIPath = cmSetBGIPath;       { History list ID }

type
  PBGIApp = ^TBGIApp;
  TBGIApp = object(TApplication)
    AppDriver: Integer;
    AppMode: Integer;
    BGIPath: PString;
    constructor Init;
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

constructor TBGIApp.Init;
begin
  TApplication.Init;
  BGIPath := NewStr(FExpand(PathToDrivers));
  AppDriver := Detect;
  AppMode := 0;
  if not GraphAppInit(AppDriver, AppMode, BGIPath, True) then
    MessageBox('Cannot load graphics driver.',
      nil, mfError or mfOkButton);
end;

destructor TBGIApp.Done;
begin
  GraphAppDone;
  if BGIPath <> nil then DisposeStr(BGIPath);
  TApplication.Done;
end;

procedure TBGIApp.HandleEvent(var Event: TEvent);

procedure NewWin;
const
  WinNum: Word = 0;
var
  R: TRect;
  S: string[3];
  P: PWindow;
begin
  Str(WinNum, S);
  DeskTop^.GetExtent(R);
  with DeskTop^.Size do
    R.Assign(WinNum mod Pred(Y), WinNum mod Pred(Y), X, Y);
  Inc(WinNum);
  P := New(PWindow, Init(R, 'Window ' + S, 0));
  P^.Options := P^.Options or ofTileable;
  DeskTop^.Insert(ValidView(P));
end;

{ Draw random polygons with random fill styles on the screen }
procedure DoGraphics;
const
  MaxPts = 5;
type
  PolygonType = array[1..MaxPts] of PointType;
var
  Event: TEvent;
  Poly: PolygonType;
  I, Color: Word;
  MaxX, MaxY: Word;
begin
  if not GraphicsStart then
    MessageBox(GraphErrorMsg(GraphResult) + '.',
      nil, mfError or mfOkButton)
  else
  begin
    MaxX := GetMaxX;
    MaxY := GetMaxY;
    OutTextXY(0, MaxY - TextHeight('M'),
      'Press any key to return...');
    SetViewPort(0, 0, MaxX - 1, MaxY - (TextHeight('M') + 5), ClipOn);
    repeat
      Color := Random(GetMaxColor) + 1;
      SetFillStyle(Random(11) + 1, Color);
      SetColor(Color);
      for I := 1 to MaxPts do
        with Poly[I] do
        begin
          X := Random(MaxX);
          Y := Random(MaxY);
        end;
      FillPoly(MaxPts, Poly);
      GetKeyEvent(Event);
    until Event.What <> evNothing;
    GraphicsStop;
  end;
end;

procedure SetBGIPath;
var
  D: PDialog;
  R: TRect;
  Control: PView;
  PathInput: PInputLine;
  S: PathStr;
begin
  R.Assign(0, 0, 35, 8);
  D := New(PDialog, Init(R, 'Path to BGI Files'));
  D^.Options := D^.Options or ofCentered;

  { Buttons }
  R.Assign(23, 5, 33, 7);
  D^.Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  R.Assign(12, 5, 22, 7);
  D^.Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));

  { Input line, history list and label }
  R.Assign(3, 3, 30, 4);
  PathInput := New(PInputLine, Init(R, 68));
  D^.Insert(PathInput);
  R.Assign(30, 3, 33, 4);
  Control := New(PHistory, Init(R, PathInput, hlSetBGIPath));
  D^.Insert(Control);

  S := FExpand(BGIPath^);
  D^.SetData(S);
  D := PDialog(ValidView(D));
  if D <> nil then
  begin
    if Desktop^.ExecView(D) = cmOk then
    begin
      D^.GetData(S);
      DisposeStr(BGIPath);
      S := FExpand(S);
      if (Length(S) > 0) and (S[Length(S)] <> '\') then
        S := S + '\';
      BGIPath := NewStr(S);
      if not GraphAppInit(AppDriver, AppMode, BGIPath, True) then
        MessageBox('Cannot load graphics driver.', nil,
          mfError or mfOkButton);
    end;
    Dispose(D, Done);
  end;
end;

procedure ChangeDir;
var
  P: PView;
begin
  P := ValidView(New(PChDirDialog, Init(0, hlChangeDir)));
  if P <> nil then
  begin
    DeskTop^.ExecView(P);
    Dispose(P, Done);
  end;
end;

procedure Tile;
var
  R: TRect;
begin
  Desktop^.GetExtent(R);
  Desktop^.Tile(R);
end;

procedure Cascade;
var
  R: TRect;
begin
  Desktop^.GetExtent(R);
  Desktop^.Cascade(R);
end;

begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmNewWin: NewWin;
        cmChangeDir: ChangeDir;
        cmSetBGIPath: SetBGIPath;
        cmDoGraphics: DoGraphics;
        cmTile: Tile;
        cmCascade: Cascade;
      else
        Exit;
      end;
  else
    Exit;
  end;
  ClearEvent(Event);
end;

procedure TBGIApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~T~est', hcNoContext, NewMenu(
      NewItem('~B~GI settings...', '', kbNoKey, 0, hcNoContext,
      NewItem('~G~raph', 'Alt-F5', kbAltF5, cmDoGraphics, hcNoContext,
      NewItem('~S~et BGI path...', '', kbNoKey, cmSetBGIPath, hcNoContext,
      NewLine(
      NewItem('~C~hange dir...', '', kbNoKey, cmChangeDir, hcNoContext,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))))),
    NewSubMenu('~W~indows', hcNoContext, NewMenu(
        NewItem('~S~ize/move','Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcNoContext,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcNoContext,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
      NewLine(
    NewItem('Add ~w~indow','F4', kbF4, cmNewWin, hcNoContext,
      nil)))))))))),
    nil)))));
end;

procedure TBGIApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~Alt-F5~ Graph', kbAltF5, cmDoGraphics,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbAltF3, cmClose,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbF6, cmNext,
      nil))))))),
    nil)));
end;

procedure TBGIApp.OutOfMemory;
begin
  MessageBox('Out of memory.', nil, mfError or mfOkButton);
end;

var
  BGIApp: TBGIApp;

begin
  BGIApp.Init;
  BGIApp.Run;
  BGIApp.Done;
end.
