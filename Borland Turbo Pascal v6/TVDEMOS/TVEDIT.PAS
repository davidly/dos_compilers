{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Editor Demo                     }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVEdit;

{$M 8192,8192,655360}
{$X+,S-}

{ This program demonstrates the use of the Buffers and Editors
  units. See also BUFFERS.DOC and EDITORS.DOC in the \TP\DOC
  directory.
}

uses Dos, Objects, Drivers, Memory, Views, Menus, Dialogs,
  StdDlg, MsgBox, App, Calc, Buffers, Editors;

const
  HeapSize = 32 * (1024 div 16);

const
  cmOpen       = 100;
  cmNew        = 101;
  cmChangeDir  = 102;
  cmDosShell   = 103;
  cmCalculator = 104;
  cmShowClip   = 105;

type
  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
    constructor Init;
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

var
  EditorApp: TEditorApp;
  ClipWindow: PEditWindow;

function ExecDialog(P: PDialog; Data: Pointer): Word;
var
  Result: Word;
begin
  Result := cmCancel;
  P := PDialog(Application^.ValidView(P));
  if P <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    Result := DeskTop^.ExecView(P);
    if (Result <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
  end;
  ExecDialog := Result;
end;

function CreateFindDialog: PDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 38, 12);
  D := New(PDialog, Init(R, 'Find'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3, 3, 32, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(32, 3, 35, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 5, 35, 7);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only', nil)))));

    R.Assign(14, 9, 24, 11);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  CreateFindDialog := D;
end;

function CreateReplaceDialog: PDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 16);
  D := New(PDialog, Init(R, 'Replace'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3, 3, 34, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(34, 3, 37, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 6, 34, 7);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 5, 12, 6);
    Insert(New(PLabel, Init(R, '~N~ew text', Control)));
    R.Assign(34, 6, 37, 7);
    Insert(New(PHistory, Init(R, PInputLine(Control), 11)));

    R.Assign(3, 8, 37, 12);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only',
      NewSItem('~P~rompt on replace',
      NewSItem('~R~eplace all', nil)))))));

    R.Assign(17, 13, 27, 15);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    R.Assign(28, 13, 38, 15);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  CreateReplaceDialog := D;
end;

function DoEditDialog(Dialog: Integer; Info: Pointer): Word; far;
var
  R: TRect;
  T: TPoint;
begin
  case Dialog of
    edOutOfMemory:
      DoEditDialog := MessageBox('Not enough memory for this operation.',
        nil, mfError + mfOkButton);
    edReadError:
      DoEditDialog := MessageBox('Error reading file %s.',
        @Info, mfError + mfOkButton);
    edWriteError:
      DoEditDialog := MessageBox('Error writing file %s.',
        @Info, mfError + mfOkButton);
    edCreateError:
      DoEditDialog := MessageBox('Error creating file %s.',
        @Info, mfError + mfOkButton);
    edSaveModify:
      DoEditDialog := MessageBox('%s has been modified. Save?',
        @Info, mfInformation + mfYesNoCancel);
    edSaveUntitled:
      DoEditDialog := MessageBox('Save untitled file?',
        nil, mfInformation + mfYesNoCancel);
    edSaveAs:
      DoEditDialog := ExecDialog(New(PFileDialog, Init('*.*',
        'Save file as', '~N~ame', fdOkButton, 101)), Info);
    edFind:
      DoEditDialog := ExecDialog(CreateFindDialog, Info);
    edSearchFailed:
      DoEditDialog := MessageBox('Search string not found.',
        nil, mfError + mfOkButton);
    edReplace:
      DoEditDialog := ExecDialog(CreateReplaceDialog, Info);
    edReplacePrompt:
      begin
        { Avoid placing the dialog on the same line as the cursor }
        R.Assign(0, 1, 40, 8);
        R.Move((Desktop^.Size.X - R.B.X) div 2, 0);
        Desktop^.MakeGlobal(R.B, T);
        Inc(T.Y);
        if TPoint(Info).Y <= T.Y then
          R.Move(0, Desktop^.Size.Y - R.B.Y - 2);
        DoEditDialog := MessageBoxRect(R, 'Replace this occurence?',
          nil, mfYesNoCancel + mfInformation);
      end;
  end;
end;

function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PView;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := Application^.ValidView(New(PEditWindow,
    Init(R, FileName, wnNoNumber)));
  if not Visible then P^.Hide;
  DeskTop^.Insert(P);
  OpenEditor := PEditWindow(P);
end;

constructor TEditorApp.Init;
var
  H: Word;
  R: TRect;
begin
  H := PtrRec(HeapEnd).Seg - PtrRec(HeapPtr).Seg;
  if H > HeapSize then BufHeapSize := H - HeapSize else BufHeapSize := 0;
  InitBuffers;
  TApplication.Init;
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := DoEditDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

destructor TEditorApp.Done;
begin
  TApplication.Done;
  DoneBuffers;
end;

procedure TEditorApp.HandleEvent(var Event: TEvent);

procedure FileOpen;
var
  FileName: FNameStr;
begin
  FileName := '*.*';
  if ExecDialog(New(PFileDialog, Init('*.*', 'Open file',
    '~N~ame', fdOpenButton, 100)), @FileName) <> cmCancel then
    OpenEditor(FileName, True);
end;

procedure FileNew;
begin
  OpenEditor('', True);
end;

procedure ChangeDir;
begin
  ExecDialog(New(PChDirDialog, Init(cdNormal, 0)), nil);
end;

procedure DosShell;
begin
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;
  SetMemTop(Ptr(BufHeapPtr, 0));
  PrintStr('Type EXIT to return to TVEDIT...');
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  SetMemTop(Ptr(BufHeapEnd, 0));
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  Redraw;
end;

procedure ShowClip;
begin
  ClipWindow^.Select;
  ClipWindow^.Show;
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

procedure Calculator;
begin
  DeskTop^.Insert(ValidView(New(PCalculator, Init)));
end;

begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmOpen: FileOpen;
        cmNew: FileNew;
        cmChangeDir: ChangeDir;
        cmDosShell: DosShell;
        cmCalculator: Calculator;
        cmShowClip: ShowClip;
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

procedure TEditorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen...', 'F3', kbF3, cmOpen, hcNoContext,
      NewItem('~N~ew', '', kbNoKey, cmNew, hcNoContext,
      NewItem('~S~ave', 'F2', kbF2, cmSave, hcNoContext,
      NewItem('S~a~ve as...', '', kbNoKey, cmSaveAs, hcNoContext,
      NewLine(
      NewItem('~C~hange dir...', '', kbNoKey, cmChangeDir, hcNoContext,
      NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcNoContext,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))))))),
    NewSubMenu('~E~dit', hcNoContext, NewMenu(
      NewItem('~U~ndo', '', kbNoKey, cmUndo, hcNoContext,
      NewLine(
      NewItem('Cu~t~', 'Shift-Del', kbShiftDel, cmCut, hcNoContext,
      NewItem('~C~opy', 'Ctrl-Ins', kbCtrlIns, cmCopy, hcNoContext,
      NewItem('~P~aste', 'Shift-Ins', kbShiftIns, cmPaste, hcNoContext,
      NewItem('~S~how clipboard', '', kbNoKey, cmShowClip, hcNoContext,
      NewLine(
      NewItem('~C~lear', 'Ctrl-Del', kbCtrlDel, cmClear, hcNoContext,
      nil))))))))),
    NewSubMenu('~S~earch', hcNoContext, NewMenu(
      NewItem('~F~ind...', '', kbNoKey, cmFind, hcNoContext,
      NewItem('~R~eplace...', '', kbNoKey, cmReplace, hcNoContext,
      NewItem('~S~earch again', '', kbNoKey, cmSearchAgain, hcNoContext,
      nil)))),
    NewSubMenu('~W~indows', hcNoContext, NewMenu(
      NewItem('~S~ize/move','Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcNoContext,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcNoContext,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcNoContext,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcNoContext,
      NewItem('~P~revious', 'Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
      NewLine(
      NewItem('Ca~l~culator', '', kbNoKey, cmCalculator, hcNoContext,
      nil)))))))))),
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
