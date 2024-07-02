{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Tutor08b;

uses Memory, TutConst, Drivers, Objects, Views, Menus, App, Dialogs,
  Editors, StdDlg;

type
  POrderWindow = ^TOrderWindow;
  TOrderWindow = object(TDialog)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  TTutorApp = object(TApplication)
    ClipboardWindow: PEditWindow;
    OrderWindow: POrderWindow;
    constructor Init;
    destructor Done; virtual;
    procedure DoAboutBox;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure LoadDesktop;
    procedure NewWindow;
    procedure OpenOrderWindow;
    procedure OpenWindow;
    procedure SaveDesktop;
  end;

var
  ResFile: TResourceFile;

const
  ROrderWindow: TStreamRec = (
     ObjType: 15001;
     VmtLink: Ofs(TypeOf(TOrderWindow)^);
     Load:    @TOrderWindow.Load;
     Store:   @TOrderWindow.Store
  );

procedure TutorStreamError(var S: TStream); far;
var
  ErrorMessage: String;
begin
  case S.Status of
    stError: ErrorMessage := 'Stream access error';
    stInitError: ErrorMessage := 'Cannot initialize stream';
    stReadError: ErrorMessage := 'Read beyond end of stream';
    stWriteError: ErrorMessage := 'Cannot expand stream';
    stGetError: ErrorMessage := 'Unregistered type read from stream';
    stPutError: ErrorMessage := 'Unregistered type written to stream';
    end;
  DoneVideo;
  PrintStr('Error: ' + ErrorMessage);
  Halt(Abs(S.Status));
end;

constructor TOrderWindow.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 60, 17);
  inherited Init(R, 'Orders');
  Options := Options or ofCentered;
  HelpCtx := $F000;
end;

procedure TOrderWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and
    (Event.Command = cmFindOrderWindow) then
    ClearEvent(Event);
end;

constructor TTutorApp.Init;
var
  R: TRect;
begin
  MaxHeapSize := 8192;
  EditorDialog := StdEditorDialog;
  StreamError := @TutorStreamError;
  RegisterMenus;
  RegisterObjects;
  RegisterViews;
  RegisterApp;
  RegisterEditors;
  RegisterDialogs;
  RegisterType(ROrderWindow);
  ResFile.Init(New(PBufStream, Init('TUTORIAL.TVR', stOpenRead, 1024)));
  inherited Init;
  DisableCommands([cmStockWin, cmSupplierWin]);
  Desktop^.GetExtent(R);
  ClipboardWindow := New(PEditWindow, Init(R, '', wnNoNumber));
  if ValidView(ClipboardWindow) <> nil then
  begin
    ClipboardWindow^.Hide;
    InsertWindow(ClipboardWindow);
    Clipboard := ClipboardWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

destructor TTutorApp.Done;
begin
  ResFile.Done;
  inherited Done;
end;

procedure TTutorApp.DoAboutBox;
begin
  ExecuteDialog(PDialog(ResFile.Get('ABOUTBOX')), nil);
end;

procedure TTutorApp.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmOrderWin:
        begin
          OpenOrderWindow;
          ClearEvent(Event);
        end;
      cmOptionsLoad:
        begin
          LoadDesktop;
          ClearEvent(Event);
        end;
      cmOptionsSave:
        begin
          SaveDesktop;
          ClearEvent(Event);
        end;
      cmClipShow:
        with ClipboardWindow^ do
        begin
          Select;
          Show;
          ClearEvent(Event);
        end;
      cmNew:
        begin
          NewWindow;
          ClearEvent(Event);
        end;
      cmOpen:
        begin
          OpenWindow;
          ClearEvent(Event);
        end;
      cmOptionsVideo:
        begin
          SetScreenMode(ScreenMode xor smFont8x8);
          ClearEvent(Event);
        end;
      cmAbout:
        begin
          DoAboutBox;
          ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TTutorApp.InitMenuBar;
begin
  MenuBar := PMenuBar(ResFile.Get('MAINMENU'));
end;

procedure TTutorApp.InitStatusLine;
var
  R: TRect;
begin
  StatusLine := PStatusLine(ResFile.Get('STATUS'));
  GetExtent(R);
  StatusLine^.MoveTo(0, R.B.Y - 1);
end;

procedure TTutorApp.LoadDesktop;
var
  DesktopFile: TBufStream;
  TempDesktop: PDesktop;
  R: TRect;
begin
  DesktopFile.Init('DESKTOP.TUT', stOpenRead, 1024);
  TempDesktop := PDesktop(DesktopFile.Get);
  DesktopFile.Done;
  if ValidView(TempDesktop) <> nil then
  begin
    Desktop^.Delete(ClipboardWindow);
    Delete(Desktop);
    Dispose(Desktop, Done);
    Desktop := TempDesktop;
    Insert(Desktop);
    GetExtent(R);
    R.Grow(0, -1);
    Desktop^.Locate(R);
    InsertWindow(ClipboardWindow);
  end;
end;

procedure TTutorApp.NewWindow;
var
  R: TRect;
  TheWindow: PEditWindow;
begin
  R.Assign(0, 0, 60, 20);
  TheWindow := New(PEditWindow, Init(R, '', wnNoNumber));
  InsertWindow(TheWindow);
end;

procedure TTutorApp.OpenOrderWindow;
begin
  if Message(Desktop, evBroadcast, cmFindOrderWindow, nil) = nil then
  begin
    OrderWindow := New(POrderWindow, Init);
    InsertWindow(OrderWindow);
  end
  else
    if PView(OrderWindow) <> Desktop^.TopView then OrderWindow^.Select;
end;

procedure TTutorApp.OpenWindow;
var
  R: TRect;
  FileDialog: PFileDialog;
  TheFile: FNameStr;
const
  FDOptions: Word = fdOKButton or fdOpenButton;
begin
  TheFile := '*.*';
  New(FileDialog, Init(TheFile, 'Open file', '~F~ile name',
    FDOptions, 1));
  if ExecuteDialog(FileDialog, @TheFile) <> cmCancel then
  begin
    R.Assign(0, 0, 75, 20);
    InsertWindow(New(PEditWindow, Init(R, TheFile, wnNoNumber)));
  end;
end;

procedure TTutorApp.SaveDesktop;
var
  DesktopFile: TBufStream;
begin
  Desktop^.Delete(ClipboardWindow);
  DesktopFile.Init('DESKTOP.TUT', stCreate, 1024);
  DesktopFile.Put(Desktop);
  DesktopFile.Done;
  InsertWindow(ClipboardWindow);
end;

var
  TutorApp: TTutorApp;

begin
  TutorApp.Init;
  TutorApp.Run;
  TutorApp.Done;
end.
