{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Tutor05;

uses Memory, TutConst, Drivers, Objects, Views, Menus, App, MsgBox,
  Editors, StdDlg;

type
  TTutorApp = object(TApplication)
    ClipboardWindow: PEditWindow;
    constructor Init;
    procedure DoAboutBox;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure NewWindow;
    procedure OpenWindow;
  end;

constructor TTutorApp.Init;
var
  R: TRect;
begin
  MaxHeapSize := 8192;
  EditorDialog := StdEditorDialog;
  inherited Init;
  DisableCommands([cmOrderWin, cmStockWin, cmSupplierWin]);
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

procedure TTutorApp.DoAboutBox;
begin
  MessageBox(#3'Turbo Vision Tutorial Application'#13 +
    #3'Copyright 1992'#13#3'Borland International',
    nil, mfInformation or mfOKButton);
end;

procedure TTutorApp.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
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
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      StdFileMenuItems(nil)),
    NewSubMenu('~E~dit', hcNoContext, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmClipShow, hcNoContext,
      nil)))),
    NewSubMenu('~O~rders', hcNoContext, NewMenu(
      NewItem('~N~ew', 'F9', kbF9, cmOrderNew, hcNoContext,
      NewItem('~S~ave', '', kbNoKey, cmOrderSave, hcNoContext,
      NewLine(
      NewItem('Next', 'PgDn', kbPgDn, cmOrderNext, hcNoContext,
      NewItem('Prev', 'PgUp', kbPgUp, cmOrderPrev, hcNoContext,
      nil)))))),
    NewSubMenu('O~p~tions', hcNoContext, NewMenu(
      NewItem('~T~oggle video', '', kbNoKey, cmOptionsVideo, hcNoContext,
      NewItem('~S~ave desktop', '', kbNoKey, cmOptionsSave, hcNoContext,
      NewItem('~L~oad desktop', '', kbNoKey, cmOptionsLoad, hcNoContext,
      nil)))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('Orders', '', kbNoKey, cmOrderWin, hcNoContext,
      NewItem('Stock items', '', kbNoKey, cmStockWin, hcNoContext,
      NewItem('Suppliers', '', kbNoKey, cmSupplierWin, hcNoContext,
      NewLine(
      StdWindowMenuItems(nil)))))),
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout...', '', kbNoKey, cmAbout, hcNoContext,
      nil)),
    nil))))))
  )));
end;

procedure TTutorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $EFFF,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~F4~ New', kbF4, cmNew,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      StdStatusKeys(nil)))),
    NewStatusDef($F000, $FFFF,
      NewStatusKey('~F6~ Next', kbF6, cmOrderNext,
      NewStatusKey('~Shift+F6~ Prev', kbShiftF6, cmOrderPrev,
      StdStatusKeys(nil))), nil))));
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

var
  TutorApp: TTutorApp;

begin
  TutorApp.Init;
  TutorApp.Run;
  TutorApp.Done;
end.
