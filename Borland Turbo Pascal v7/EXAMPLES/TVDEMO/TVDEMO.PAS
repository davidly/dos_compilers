{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TVDemo;

{$X+,S-}
{$M 16384,8192,655360}

{ Turbo Vision demo program. This program uses many of the Turbo
  Vision standard and demo units, including:

    StdDlg    - Open file browser, change directory tree.
    MsgBox    - Simple dialog to display messages.
    ColorSel  - Color customization.
    Gadgets   - Shows system time and available heap space.
    AsciiTab  - ASCII table.
    Calendar  - View a month at a time
    Calc      - Desktop calculator.
    HelpFile  - Context sensitive help.
    MouseDlg  - Mouse options dialog.
    Puzzle    - Simple brain puzzle.
    Editors   - Text Editor object.

  And of course this program includes many standard Turbo Vision
  objects and behaviors (menubar, desktop, status line, dialog boxes,
  mouse support, window resize/move/tile/cascade).
}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, HistList,
  MsgBox, App, DemoCmds, Gadgets, Puzzle, Calendar, AsciiTab, Calc,
  HelpFile, DemoHelp, ColorSel, MouseDlg, Editors;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\DOS\TVDEMO directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

const
  HeapSize = 48 * (1024 div 16);  { Save 48k heap for main program }

  { Desktop file signature information }
  SignatureLen = 21;
  DSKSignature : string[SignatureLen] = 'TV Demo Desktop File'#26;

var
  ClipWindow: PEditWindow;

type

  { TTVDemo }

  PTVDemo = ^TTVDemo;
  TTVDemo = object(TApplication)
    Clock: PClockView;
    Heap: PHeapView;
    constructor Init;
    procedure FileOpen(WildCard: PathStr);
    function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure LoadDesktop(var S: TStream);
    procedure OutOfMemory; virtual;
    procedure StoreDesktop(var S: TStream);
  end;

{ CalcHelpName }

function CalcHelpName: PathStr;
var
  EXEName: PathStr;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  if Lo(DosVersion) >= 3 then EXEName := ParamStr(0)
  else EXEName := FSearch('TVDEMO.EXE', GetEnv('PATH'));
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  CalcHelpName := FSearch('DEMOHELP.HLP', Dir);
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
      DoEditDialog := Application^.ExecuteDialog(New(PFileDialog, Init('*.*',
        'Save file as', '~N~ame', fdOkButton, 101)), Info);
    edFind:
      DoEditDialog := Application^.ExecuteDialog(CreateFindDialog, Info);
    edSearchFailed:
      DoEditDialog := MessageBox('Search string not found.',
        nil, mfError + mfOkButton);
    edReplace:
      DoEditDialog := Application^.ExecuteDialog(CreateReplaceDialog, Info);
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

{ TTVDemo }
constructor TTVDemo.Init;
var
  R: TRect;
  I: Integer;
  FileName: PathStr;
begin
  MaxHeapSize := HeapSize;
  inherited Init;
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterHelpFile;
  RegisterPuzzle;
  RegisterCalendar;
  RegisterAsciiTab;
  RegisterCalc;
  RegisterEditors;

  { Initialize demo gadgets }

  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  GetExtent(R);
  Dec(R.B.X);
  R.A.X := R.B.X - 9; R.A.Y := R.B.Y - 1;
  Heap := New(PHeapView, Init(R));
  Insert(Heap);

  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain, cmCloseAll]);
  EditorDialog := DoEditDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;

  for I := 1 to ParamCount do
  begin
    FileName := ParamStr(I);
    if FileName[Length(FileName)] = '\' then
      FileName := FileName + '*.*';
    if (Pos('?', FileName) = 0) and (Pos('*', FileName) = 0) then
      OpenEditor(FExpand(FileName), True)
    else FileOpen(FileName);
  end;
end;

function TTVDemo.OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
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

procedure TTVDemo.FileOpen(WildCard: PathStr);
var
  FileName: FNameStr;
begin
  FileName := '*.*';
  if ExecuteDialog(New(PFileDialog, Init(WildCard, 'Open a file',
    '~N~ame', fdOpenButton + fdHelpButton, 100)), @FileName) <> cmCancel then
    OpenEditor(FileName, True);
end;

procedure TTVDemo.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  inherited GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init(CalcHelpName, stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
          Dispose(HFile, Done);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end;

function TTVDemo.GetPalette: PPalette;
const
  CNewColor = CAppColor + CHelpColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TTVDemo.HandleEvent(var Event: TEvent);

procedure ChangeDir;
var
  D: PChDirDialog;
begin
  D := New(PChDirDialog, Init(cdNormal + cdHelpButton, 101));
  D^.HelpCtx := hcFCChDirDBox;
  ExecuteDialog(D, nil);
end;

procedure Puzzle;
var
  P: PPuzzleWindow;
begin
  P := New(PPuzzleWindow, Init);
  P^.HelpCtx := hcPuzzle;
  InsertWindow(P);
end;

procedure Calendar;
var
  P: PCalendarWindow;
begin
  P := New(PCalendarWindow, Init);
  P^.HelpCtx := hcCalendar;
  InsertWindow(P);
end;

procedure About;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 11);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'Turbo Vision Demo'#13 +
      #13 +
      ^C'Copyright (c) 1992'#13 +
      #13 +
      ^C'Borland International')));

    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  if ValidView(D) <> nil then
  begin
    Desktop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

procedure AsciiTab;
var
  P: PAsciiChart;
begin
  P := New(PAsciiChart, Init);
  P^.HelpCtx := hcAsciiTable;
  InsertWindow(P);
end;

procedure Calculator;
var
  P: PCalculator;
begin
  P := New(PCalculator, Init);
  P^.HelpCtx := hcCalculator;
  InsertWindow(P);
end;

procedure Colors;
var
  D: PColorDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup('Desktop',       DesktopColorItems(nil),
    ColorGroup('Menus',         MenuColorItems(nil),
    ColorGroup('Dialogs/Calc',  DialogColorItems(dpGrayDialog, nil),
    ColorGroup('Editor/Puzzle', WindowColorItems(wpBlueWindow, nil),
    ColorGroup('Ascii table',   WindowColorItems(wpGrayWindow, nil),
    ColorGroup('Calendar',
      WindowColorItems(wpCyanWindow,
      ColorItem('Current day',       22, nil)),
      nil))))))));

  D^.HelpCtx := hcOCColorsDBox;

  if ExecuteDialog(D, Application^.GetPalette) <> cmCancel then
  begin
    DoneMemory;    { Dispose all group buffers }
    ReDraw;        { Redraw application with new palette }
  end;
end;

procedure Mouse;
var
  D: PDialog;
begin
  D := New(PMouseDialog, Init);
  D^.HelpCtx := hcOMMouseDBox;
  ExecuteDialog(D, @MouseReverse);
end;

procedure RetrieveDesktop;
var
  S: PStream;
  Signature: string[SignatureLen];
begin
  S := New(PBufStream, Init('TVDEMO.DSK', stOpenRead, 1024));
  if LowMemory then OutOfMemory
  else if S^.Status <> stOk then
    MessageBox('Could not open desktop file', nil, mfOkButton + mfError)
  else
  begin
    Signature[0] := Char(SignatureLen);
    S^.Read(Signature[1], SignatureLen);
    if Signature = DSKSignature then
    begin
      LoadDesktop(S^);
      LoadIndexes(S^);
      LoadHistory(S^);
      if S^.Status <> stOk then
        MessageBox('Error reading desktop file', nil, mfOkButton + mfError);
    end
    else
      MessageBox('Error: Invalid Desktop file.', nil, mfOkButton + mfError);
  end;
  Dispose(S, Done);
end;

procedure SaveDesktop;
var
  S: PStream;
  F: File;
begin
  S := New(PBufStream, Init('TVDEMO.DSK', stCreate, 1024));
  if not LowMemory and (S^.Status = stOk) then
  begin
    S^.Write(DSKSignature[1], SignatureLen);
    StoreDesktop(S^);
    StoreIndexes(S^);
    StoreHistory(S^);
    if S^.Status <> stOk then
    begin
      MessageBox('Could not create TVDEMO.DSK.', nil, mfOkButton + mfError);
      {$I-}
      Dispose(S, Done);
      Assign(F, 'TVDEMO.DSK');
      Erase(F);
      Exit;
    end;
  end;
  Dispose(S, Done);
end;

procedure FileNew;
begin
  OpenEditor('', True);
end;

procedure ShowClip;
begin
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmOpen: FileOpen('*.*');
          cmNew: FileNew;
          cmShowClip: ShowClip;
          cmChangeDir: ChangeDir;
          cmAbout: About;
          cmPuzzle: Puzzle;
          cmCalendar: Calendar;
          cmAsciiTab: AsciiTab;
          cmCalculator: Calculator;
          cmColors: Colors;
          cmMouse: Mouse;
          cmSaveDesktop: SaveDesktop;
          cmRetrieveDesktop: RetrieveDesktop;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TTVDemo.Idle;

function IsTileable(P: PView): Boolean; far;
begin
  IsTileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;

begin
  inherited Idle;
  Clock^.Update;
  Heap^.Update;
  if Desktop^.FirstThat(@IsTileable) <> nil then
    EnableCommands([cmTile, cmCascade])
  else
    DisableCommands([cmTile, cmCascade]);
end;

procedure TTVDemo.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~'#240'~', hcSystem, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcSAbout,
      NewLine(
      NewItem('~P~uzzle', '', kbNoKey, cmPuzzle, hcSPuzzle,
      NewItem('Ca~l~endar', '', kbNoKey, cmCalendar, hcSCalendar,
      NewItem('Ascii ~t~able', '', kbNoKey, cmAsciiTab, hcSAsciiTable,
      NewItem('~C~alculator', '', kbNoKey, cmCalculator, hcCalculator, nil))))))),
    NewSubMenu('~F~ile', hcFile, NewMenu(
      StdFileMenuItems(nil)),
    NewSubMenu('~E~dit', hcEdit, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmShowClip, hcShowClip,
      nil)))),
    NewSubMenu('~S~earch', hcSearch, NewMenu(
      NewItem('~F~ind...', '', kbNoKey, cmFind, hcFind,
      NewItem('~R~eplace...', '', kbNoKey, cmReplace, hcReplace,
      NewItem('~S~earch again', '', kbNoKey, cmSearchAgain, hcSearchAgain,
      nil)))),
    NewSubMenu('~W~indow', hcWindows, NewMenu(
      StdWindowMenuItems(nil)),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewItem('~M~ouse...', '', kbNoKey, cmMouse, hcOMouse,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcOColors,
      NewLine(
      NewItem('~S~ave desktop', '', kbNoKey, cmSaveDesktop, hcOSaveDesktop,
      NewItem('~R~etrieve desktop', '', kbNoKey, cmRetrieveDesktop, hcORestoreDesktop, nil)))))),
      nil)))))))));
end;

procedure TTVDemo.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize,
      nil))))))),
    nil)));
end;

procedure TTVDemo.OutOfMemory;
begin
  MessageBox('Not enough memory available to complete operation.',
    nil, mfError + mfOkButton);
end;

{ Since the safety pool is only large enough to guarantee that allocating
  a window will not run out of memory, loading the entire desktop without
  checking LowMemory could cause a heap error.  This means that each
  window should be read individually, instead of using Desktop's Load.
}

procedure TTVDemo.LoadDesktop(var S: TStream);
var
  P: PView;
  Pal: PString;

procedure CloseView(P: PView); far;
begin
  Message(P, evCommand, cmClose, nil);
end;

begin
  if Desktop^.Valid(cmClose) then
  begin
    Desktop^.ForEach(@CloseView); { Clear the desktop }
    repeat
      P := PView(S.Get);
      Desktop^.InsertBefore(ValidView(P), Desktop^.Last);
    until P = nil;
    Pal := S.ReadStr;
    if Pal <> nil then
    begin
      Application^.GetPalette^ := Pal^;
      DoneMemory;
      Application^.ReDraw;
      DisposeStr(Pal);
    end;
  end;
end;

procedure TTVDemo.StoreDesktop(var S: TStream);
var
  Pal: PString;

procedure WriteView(P: PView); far;
begin
  if P <> Desktop^.Last then S.Put(P);
end;

begin
  Desktop^.ForEach(@WriteView);
  S.Put(nil);
  Pal := @Application^.GetPalette^;
  S.WriteStr(Pal);
end;


var
  Demo: TTVDemo;

begin
  Demo.Init;
  Demo.Run;
  Demo.Done;
end.
