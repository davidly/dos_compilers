{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
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
    FViewer   - Scroll through text files.
    HelpFile  - Context sensitive help.
    MouseDlg  - Mouse options dialog.
    Puzzle    - Simple brain puzzle.

  And of course this program includes many standard Turbo Vision
  objects and behaviors (menubar, desktop, status line, dialog boxes,
  mouse support, window resize/move/tile/cascade).
}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, MsgBox, App,
  DemoCmds, Gadgets, Puzzle, Calendar, AsciiTab, Calc, FViewer, HelpFile,
  DemoHelp, ColorSel, MouseDlg;

type

  { TTVDemo }

  PTVDemo = ^TTVDemo;
  TTVDemo = object(TApplication)
    Clock: PClockView;
    Heap: PHeapView;
    constructor Init;
    procedure FileOpen(WildCard: PathStr);
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure LoadDesktop(var S: TStream);
    procedure OutOfMemory; virtual;
    procedure StoreDesktop(var S: TStream);
    procedure ViewFile(FileName: PathStr);
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


{ TTVDemo }
constructor TTVDemo.Init;
var
  R: TRect;
  I: Integer;
  FileName: PathStr;
begin
  TApplication.Init;
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
  RegisterFViewer;

  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  GetExtent(R);
  Dec(R.B.X);
  R.A.X := R.B.X - 9; R.A.Y := R.B.Y - 1;
  Heap := New(PHeapView, Init(R));
  Insert(Heap);

  for I := 1 to ParamCount do
  begin
    FileName := ParamStr(I);
    if FileName[Length(FileName)] = '\' then
      FileName := FileName + '*.*';
    if (Pos('?', FileName) = 0) and (Pos('*', FileName) = 0) then
      ViewFile(FExpand(FileName))
    else FileOpen(FileName);
  end;
end;

procedure TTVDemo.FileOpen(WildCard: PathStr);
var
  D: PFileDialog;
  FileName: PathStr;
begin
  D := New(PFileDialog, Init(WildCard, 'Open a File',
    '~N~ame', fdOpenButton + fdHelpButton, 100));
  D^.HelpCtx := hcFOFileOpenDBox;
  if ValidView(D) <> nil then
  begin
    if Desktop^.ExecView(D) <> cmCancel then
    begin
      D^.GetFileName(FileName);
      ViewFile(FileName);
    end;
    Dispose(D, Done);
  end;
end;

procedure TTVDemo.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  TApplication.GetEvent(Event);
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
  CNewColor = CColor + CHelpColor;
  CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CMonochrome + CHelpMonochrome;
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
  if ValidView(D) <> nil then
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

procedure Puzzle;
var
  P: PPuzzleWindow;
begin
  P := New(PPuzzleWindow, Init);
  P^.HelpCtx := hcPuzzle;
  Desktop^.Insert(ValidView(P));
end;

procedure Calendar;
var
  P: PCalendarWindow;
begin
  P := New(PCalendarWindow, Init);
  P^.HelpCtx := hcCalendar;
  Desktop^.Insert(ValidView(P));
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
      ^C'Copyright (c) 1990'#13 +
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
  Desktop^.Insert(ValidView(P));
end;

procedure Calculator;
var
  P: PCalculator;
begin
  P := New(PCalculator, Init);
  P^.HelpCtx := hcCalculator;
  if ValidView(P) <> nil then
    Desktop^.Insert(P);
end;

procedure Colors;
var
  D: PColorDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup('Desktop',
      ColorItem('Color',             32, nil),
    ColorGroup('Menus',
      ColorItem('Normal',            2,
      ColorItem('Disabled',          3,
      ColorItem('Shortcut',          4,
      ColorItem('Selected',          5,
      ColorItem('Selected disabled', 6,
      ColorItem('Shortcut selected', 7, nil)))))),
    ColorGroup('Dialogs/Calc',
      ColorItem('Frame/background',  33,
      ColorItem('Frame icons',       34,
      ColorItem('Scroll bar page',   35,
      ColorItem('Scroll bar icons',  36,
      ColorItem('Static text',       37,

      ColorItem('Label normal',      38,
      ColorItem('Label selected',    39,
      ColorItem('Label shortcut',    40,

      ColorItem('Button normal',     41,
      ColorItem('Button default',    42,
      ColorItem('Button selected',   43,
      ColorItem('Button disabled',   44,
      ColorItem('Button shortcut',   45,
      ColorItem('Button shadow',     46,

      ColorItem('Cluster normal',    47,
      ColorItem('Cluster selected',  48,
      ColorItem('Cluster shortcut',  49,

      ColorItem('Input normal',      50,
      ColorItem('Input selected',    51,
      ColorItem('Input arrow',       52,

      ColorItem('History button',    53,
      ColorItem('History sides',     54,
      ColorItem('History bar page',  55,
      ColorItem('History bar icons', 56,

      ColorItem('List normal',       57,
      ColorItem('List focused',      58,
      ColorItem('List selected',     59,
      ColorItem('List divider',      60,

      ColorItem('Information pane',  61, nil))))))))))))))))))))))))))))),
    ColorGroup('Viewer',
      ColorItem('Frame passive',      8,
      ColorItem('Frame active',       9,
      ColorItem('Frame icons',       10,
      ColorItem('Scroll bar page',   11,
      ColorItem('Scroll bar icons',  12,
      ColorItem('Text',              13, nil)))))),
    ColorGroup('Puzzle',
      ColorItem('Frame passive',      8,
      ColorItem('Frame active',       9,
      ColorItem('Frame icons',       10,
      ColorItem('Scroll bar page',   11,
      ColorItem('Scroll bar icons',  12,
      ColorItem('Normal text',       13,
      ColorItem('Highlighted text',  14, nil))))))),
    ColorGroup('Calendar',
      ColorItem('Frame passive',     16,
      ColorItem('Frame active',      17,
      ColorItem('Frame icons',       18,
      ColorItem('Scroll bar page',   19,
      ColorItem('Scroll bar icons',  20,
      ColorItem('Normal text',       21,
      ColorItem('Current day',       22, nil))))))),
    ColorGroup('Ascii table',
      ColorItem('Frame passive',     24,
      ColorItem('Frame active',      25,
      ColorItem('Frame icons',       26,
      ColorItem('Scroll bar page',   27,
      ColorItem('Scroll bar icons',  28,
      ColorItem('Text',              29, nil)))))), nil)))))))));

  D^.HelpCtx := hcOCColorsDBox;
  if ValidView(D) <> nil then
  begin
    D^.SetData(Application^.GetPalette^);
    if Desktop^.ExecView(D) <> cmCancel then
    begin
      Application^.GetPalette^ := D^.Pal;
      DoneMemory;  { Dispose all group buffers }
      ReDraw;      { Redraw application with new palette }
    end;
    Dispose(D, Done);
  end;
end;

procedure Mouse;
var
  D: PDialog;
begin
  D := New(PMouseDialog, Init);
  D^.HelpCtx := hcOMMouseDBox;
  if ValidView(D) <> nil then
  begin
    D^.SetData(MouseReverse);
    if Desktop^.ExecView(D) <> cmCancel then
      D^.GetData(MouseReverse);
  end;
end;

procedure DosShell;
begin
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;
  SetMemTop(HeapPtr);
  PrintStr('Type EXIT to return...');
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  SetMemTop(HeapEnd);
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  Redraw;
end;

procedure RetrieveDesktop;
var
  S: PStream;
begin
  S := New(PBufStream, Init('TVDEMO.DSK', stOpenRead, 1024));
  if LowMemory then OutOfMemory
  else if S^.Status <> stOk then
    MessageBox('Could not open desktop file', nil, mfOkButton + mfError)
  else
  begin
    LoadDesktop(S^);
    if S^.Status <> stOk then
      MessageBox('Error reading desktop file', nil, mfOkButton + mfError);
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
    StoreDesktop(S^);
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


begin
  TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmFOpen: FileOpen('*.*');
          cmChDir: ChangeDir;
          cmCascade: Cascade;
          cmTile: Tile;
          cmAbout: About;
          cmPuzzle: Puzzle;
          cmCalendar: Calendar;
          cmAsciiTab: AsciiTab;
          cmCalculator: Calculator;
          cmColors: Colors;
          cmMouse: Mouse;
          cmDosShell: DosShell;
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
  IsTileable := P^.Options and ofTileable <> 0;
end;

begin
  TApplication.Idle;
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
      NewItem('~O~pen...', 'F3', kbF3, cmFOpen, hcFOpen,
      NewItem('~C~hange dir...', '', kbNoKey, cmChDir, hcFChangeDir,
      NewLine(
      NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcFDosShell,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcFExit, nil)))))),
    NewSubMenu('~W~indows', hcWindows, NewMenu(
      NewItem('~R~esize/move','Ctrl-F5', kbCtrlF5, cmResize, hcWSizeMove,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcWZoom,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcWNext,
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcWClose,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcWTile,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcWCascade, nil))))))),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewItem('~M~ouse...', '', kbNoKey, cmMouse, hcOMouse,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcOColors,
      NewLine(
      NewItem('~S~ave desktop', '', kbNoKey, cmSaveDesktop, hcOSaveDesktop,
      NewItem('~R~etrieve desktop', '', kbNoKey, cmRetrieveDesktop, hcORestoreDesktop, nil)))))), nil)))))));
end;

procedure TTVDemo.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F3~ Open', kbF3, cmFOpen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize, nil)))))), nil)));
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
  end;
end;

procedure TTVDemo.StoreDesktop(var S: TStream);

procedure WriteView(P: PView); far;
begin
  if P <> Desktop^.Last then S.Put(P);
end;

begin
  Desktop^.ForEach(@WriteView);
  S.Put(nil);
end;

procedure TTVDemo.ViewFile(FileName: PathStr);
var
  W: PWindow;
begin
  W := New(PFileWindow,Init(FileName));
  W^.HelpCtx := hcViewer;
  if ValidView(W) <> nil then
    Desktop^.Insert(W);
end;

var
  Demo: TTVDemo;

begin
  Demo.Init;
  Demo.Run;
  Demo.Done;
end.
