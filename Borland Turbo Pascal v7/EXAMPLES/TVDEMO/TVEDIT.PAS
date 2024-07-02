{************************************************}
{                                                }
{   Turbo Vision Editor Demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TVEdit;

{$M 8192,8192,655360}
{$X+,S-}

{ This program demonstrates the use of the Editors units.
  See EDITORS.DOC in the \DOC directory.
}

uses Dos, Objects, Drivers, Memory, Views, Menus, Dialogs,
  StdDlg, MsgBox, App, Calc, Editors;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\DOS\TVDEMO directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

const
  HeapSize = 32 * (1024 div 16);

const
  cmCalculator = 101;
  cmShowClip   = 102;

type
  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

var
  EditorApp: TEditorApp;
  ClipWindow: PEditWindow;

function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PWindow;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := New(PEditWindow, Init(R, FileName, wnNoNumber));
  if not Visible then P^.Hide;
  OpenEditor := PEditWindow(Application^.InsertWindow(P));
end;

constructor TEditorApp.Init;
var
  H: Word;
  R: TRect;
begin
  MaxHeapSize := HeapSize;
  inherited Init;
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := StdEditorDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

procedure TEditorApp.HandleEvent(var Event: TEvent);

procedure FileOpen;
var
  FileName: FNameStr;
begin
  FileName := '*.*';
  if ExecuteDialog(New(PFileDialog, Init('*.*', 'Open file',
    '~N~ame', fdOpenButton, 100)), @FileName) <> cmCancel then
    OpenEditor(FileName, True);
end;

procedure FileNew;
begin
  OpenEditor('', True);
end;

procedure ChangeDir;
begin
  ExecuteDialog(New(PChDirDialog, Init(cdNormal, 0)), nil);
end;

procedure ShowClip;
begin
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

procedure Calculator;
begin
  InsertWindow(New(PCalculator, Init));
end;

begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmOpen: FileOpen;
        cmNew: FileNew;
        cmChangeDir: ChangeDir;
        cmCalculator: Calculator;
        cmShowClip: ShowClip;
      else
        Exit;
      end;
  else
    Exit;
  end;
  ClearEvent(Event);
end;

procedure TEditorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      StdFileMenuItems(
      nil)),
    NewSubMenu('~E~dit', hcNoContext, NewMenu(
      StdEditMenuItems(
      nil)),
    NewSubMenu('~S~earch', hcNoContext, NewMenu(
      NewItem('~F~ind...', '', kbNoKey, cmFind, hcNoContext,
      NewItem('~R~eplace...', '', kbNoKey, cmReplace, hcNoContext,
      NewItem('~S~earch again', '', kbNoKey, cmSearchAgain, hcNoContext,
      nil)))),
    NewSubMenu('~W~indows', hcNoContext, NewMenu(
      StdWindowMenuItems(
      NewLine(
      NewItem('Ca~l~culator', '', kbNoKey, cmCalculator, hcNoContext,
      nil)))),
    nil)))))));
end;

procedure TEditorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F2~ Save', kbF2, cmSave,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('~F6~ Next', kbF6, cmNext,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize,
      nil))))))),
    nil)));
end;

procedure TEditorApp.OutOfMemory;
begin
  MessageBox('Not enough memory for this operation.',
    nil, mfError + mfOkButton);
end;

begin
  EditorApp.Init;
  EditorApp.Run;
  EditorApp.Done;
end.
