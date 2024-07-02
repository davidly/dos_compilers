{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision browser program                 }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

{$X+}

program FileView;

{$M 16384,16384,655360}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, MsgBox, App;

const
  cmFileOpen  = 100;
  cmChangeDir = 101;
  hlChangeDir = cmChangeDir;     { History list ID for change dir box }

type

  { TLineCollection }

  PLineCollection = ^TLineCollection;
  TLineCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

  { TFileViewer }

  PFileViewer = ^TFileViewer;
  TFileViewer = object(TScroller)
    FileLines: PCollection;
    IsValid: Boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      var FileName: PathStr);
    destructor Done; virtual;
    procedure Draw; virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;

  { TFileWindow }

  PFileWindow = ^TFileWindow;
  TFileWindow = object(TWindow)
    constructor Init(var FileName: PathStr);
  end;

  { TFileViewerApp }

  PFileViewerApp = ^TFileViewerApp;
  TFileViewerApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

{ TLineCollection }
procedure TLineCollection.FreeItem(P: Pointer);
begin
  DisposeStr(P);
end;

{ TFileViewer }
constructor TFileViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; var FileName: PathStr);
var
  FileToView: Text;
  Line: String;
  MaxWidth: Integer;

begin
  TScroller.Init(Bounds, AHScrollbar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  IsValid := True;
  FileLines := New(PLineCollection, Init(5,5));
  {$I-}
  Assign(FileToView, FileName);
  Reset(FileToView);
  if IOResult <> 0 then
  begin
    MessageBox('Cannot open file '+Filename+'.', nil, mfError + mfOkButton);
    IsValid := False;
  end
  else
  begin
    MaxWidth := 0;
    while not Eof(FileToView) and not LowMemory do
    begin
      Readln(FileToView, Line);
      if Length(Line) > MaxWidth then MaxWidth := Length(Line);
      FileLines^.Insert(NewStr(Line));
    end;
    Close(FileToView);
  end;
  {$I+}
  SetLimit(MaxWidth, FileLines^.Count);
end;

destructor TFileViewer.Done;
begin
  Dispose(FileLines, Done);
  TScroller.Done;
end;

procedure TFileViewer.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  S: String;
  P: PString;
begin
  C := GetColor(1);
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    if Delta.Y + I < FileLines^.Count then
    begin
      P := FileLines^.At(Delta.Y + I);
      if P <> nil then S := Copy(P^, Delta.X + 1, Size.X)
      else S := '';
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

function TFileViewer.Valid(Command: Word): Boolean;
begin
  Valid := IsValid;
end;

{ TFileWindow }
constructor TFileWindow.Init(var FileName: PathStr);
const
  WinNumber: Integer = 1;
var
  R: TRect;
begin
  Desktop^.GetExtent(R);
  TWindow.Init(R, Filename, WinNumber);
  Options := Options or ofTileable;
  Inc(WinNumber);
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PFileViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard), Filename)));
end;

{ TFileViewerApp }
procedure TFileViewerApp.HandleEvent(var Event: TEvent);

procedure FileOpen;
var
  D: PFileDialog;
  FileName: PathStr;
  W: PWindow;
begin
  D := PFileDialog(ValidView(New(PFileDialog, Init('*.*', 'Open a File',
    '~N~ame', fdOpenButton, 100))));
  if D <> nil then
  begin
    if Desktop^.ExecView(D) <> cmCancel then
    begin
      D^.GetFileName(FileName);
      W := PWindow(ValidView(New(PFileWindow,Init(FileName))));
      if W <> nil then Desktop^.Insert(W);
    end;
    Dispose(D, Done);
  end;
end;

procedure ChangeDir;
var
  D: PChDirDialog;
begin
  D := PChDirDialog(ValidView(New(PChDirDialog, Init(0, hlChangeDir))));
  if D <> nil then
  begin
    DeskTop^.ExecView(D);
    Dispose(D, Done);
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
      begin
        case Event.Command of
          cmFileOpen: FileOpen;
          cmChangeDir: ChangeDir;
          cmCascade: Cascade;
          cmTile: Tile;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TFileViewerApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', 100, NewMenu(
      NewItem('~O~pen...', 'F3', kbF3, cmFileOpen, hcNoContext,
      NewItem('~C~hange dir...', '', kbNoKey, cmChangeDir, hcNoContext,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil)))),
    NewSubMenu('~W~indows', hcNoContext, NewMenu(
      NewItem('~R~esize/move','Ctrl-F5', kbCtrlF5,cmResize, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcNoContext,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcNoContext, nil))))))), nil)))));
end;

procedure TFileViewerApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F3~ Open', kbF3, cmFileOpen,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose, nil))))), nil)));
end;

procedure TFileViewerApp.OutOfMemory;
var
  D: PDialog;
  R: TRect;
  C: Word;
begin
  MessageBox('Not enough memory available to complete operation.',
    nil, mfError + mfOkButton);
end;

var
  FileViewerApp: TFileViewerApp;

begin
  FileViewerApp.Init;
  FileViewerApp.Run;
  FileViewerApp.Done;
end.
