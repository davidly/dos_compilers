{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

{ Turbo Vision demo program. This program demonstrates the use of
  resource files and overlays to build a Turbo Vision application.
  This program duplicates the functionality of TVDEMO but gets the
  definition of menus, status line, and various dialogs off of a
  resource file. GENRDEMO.PAS generates the resource file that is used
  by this program.  To build this program, execute the batch file,
  MKRDEMO.BAT which will create the resource file and overlay file
  and copy them into the TVRDEMO.EXE file where this program looks
  for them.
}

program TVRDemo;

{$X+,S-}
{$M 16384,8192,655360}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, MsgBox, App,
  DemoCmds, Gadgets, Puzzle, Calendar, AsciiTab, Calc, FViewer, HelpFile,
  DemoHelp, ColorSel, MouseDlg, Overlay;

{$O Views}
{$O Menus}
{$O Dialogs}
{$O StdDlg}
{$O MsgBox}
{$O App}
{$O HelpFile}
{$O Gadgets}
{$O Puzzle}
{$O Calendar}
{$O AsciiTab}
{$O Calc}
{$O FViewer}
{$O ColorSel}
{$O MouseDlg}

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

type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

var
  EXEName: PathStr;
  RezFile: TResourceFile;
  RezStream: PStream;

{ CalcHelpName }

function CalcHelpName: String;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  CalcHelpName := FSearch('DEMOHELP.HLP', Dir);
end;

{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  RunError(255);
end;

{ TTVDemo }
constructor TTVDemo.Init;
var
  R: TRect;
  I: Integer;
  FileName: PathStr;
begin
  { Initialize resource file }

  RezStream := New(PProtectedStream, Init(EXEName, stOpenRead, 4096));
  RezFile.Init(RezStream);

  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterStdDlg;
  RegisterColorSel;

  RegisterHelpFile;
  RegisterPuzzle;
  RegisterCalendar;
  RegisterAsciiTab;
  RegisterCalc;
  RegisterFViewer;

  TApplication.Init;

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
  D := PFileDialog(RezFile.Get('FileOpenDialog'));
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
  D := PChDirDialog(RezFile.Get('ChDirDialog'));
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
  D := PDialog(RezFile.Get('AboutDialog'));
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
  D := PColorDialog(RezFile.Get('ColorSelectDialog'));
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
begin
  MenuBar := PMenuBar(RezFile.Get('MenuBar'));
end;

procedure TTVDemo.InitStatusLine;
begin
  StatusLine := PStatusLine(RezFile.Get('StatusLine'));
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
  if Lo(DosVersion) >= 3 then EXEName := ParamStr(0)
  else
  begin
    EXEName := FSearch('TVDEMO.EXE', GetEnv('PATH'));
    if EXEName = '' then PrintStr('TVDEMO.EXE could not be found.'#13#10);
  end;
  OvrInit(EXEName);
  OvrSetBuf(58 * 1024);
  if OvrResult <> ovrOk then
  begin
    PrintStr('No overlays found in .EXE file.  Must use MKRDEMO.BAT to build.'#13#10);
    Halt(1);
  end;
  Demo.Init;
  Demo.Run;
  Demo.Done;
end.
