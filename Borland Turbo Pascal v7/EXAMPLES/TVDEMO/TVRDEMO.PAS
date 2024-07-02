{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
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

  Note: This program is designed for real-mode use only.
}

program TVRDemo;

{$X+,S-}
{$M 16384,8192,655360}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, HistList,
  MsgBox, App, DemoCmds, DemoStrs, Gadgets, Puzzle, Calendar, AsciiTab,
  Calc, HelpFile, DemoHelp, ColorSel, MouseDlg, Editors, Overlay;

{ If you get a FILE NOT FOUND error when compiling this program,
  use the MKRDEMO.BAT file described above.
}

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
{$O ColorSel}
{$O MouseDlg}
{$O Editors}

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

type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

var
  EXEName: PathStr;
  RezFile: TResourceFile;
  RezStream: PStream;
  Strings: PStringList;

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

{ Resource MessageBox wrappers }

function RMessageBox(StrNum: Word; Param: Pointer; Flags: Word): Word;
begin
  RMessageBox := MessageBox(Strings^.Get(StrNum), Param, Flags);
end;

function RMessageBoxRect(var Rect: TRect; StrNum: Word; Param: Pointer;
  Flags: Word): Word;
begin
  RMessageBoxRect := MessageBoxRect(Rect, Strings^.Get(StrNum), Param,
    Flags);
end;

{ Editor dialog call-back }

function DoEditDialog(Dialog: Integer; Info: Pointer): Word; far;
var
  R: TRect;
  T: TPoint;

  function ExecDialog(const Dialog: String; Param: Pointer): Word;
  begin
    ExecDialog := Application^.ExecuteDialog(PDialog(RezFile.Get(Dialog)),
      Param);
  end;

begin
  case Dialog of
    edOutOfMemory:
      DoEditDialog := RMessageBox(sNoMem, nil, mfError + mfOkButton);
    edReadError:
      DoEditDialog := RMessageBox(sErrorReading, @Info, mfError + mfOkButton);
    edWriteError:
      DoEditDialog := RMessageBox(sErrorWriting, @Info, mfError + mfOkButton);
    edCreateError:
      DoEditDialog := RMessageBox(sErrorCreating, @Info, mfError + mfOkButton);
    edSaveModify:
      DoEditDialog := RMessageBox(sModified, @Info,
        mfInformation + mfYesNoCancel);
    edSaveUntitled:
      DoEditDialog := RMessageBox(sSaveUntitled, nil,
        mfInformation + mfYesNoCancel);
    edSaveAs:
      DoEditDialog := ExecDialog('SaveAsDialog', Info);
    edFind:
      DoEditDialog := ExecDialog('FindDialog', Info);
    edSearchFailed:
      DoEditDialog := RMessageBox(sStrNotFound, nil, mfError + mfOkButton);
    edReplace:
      DoEditDialog := ExecDialog('ReplaceDialog', Info);
    edReplacePrompt:
      begin
        { Avoid placing the dialog on the same line as the cursor }
        R.Assign(0, 1, 40, 8);
        R.Move((Desktop^.Size.X - R.B.X) div 2, 0);
        Desktop^.MakeGlobal(R.B, T);
        Inc(T.Y);
        if TPoint(Info).Y <= T.Y then
          R.Move(0, Desktop^.Size.Y - R.B.Y - 2);
        DoEditDialog := RMessageBoxRect(R, sReplace, nil,
          mfYesNoCancel + mfInformation);
      end;
  end;
end;

{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  DoneHistory;
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;

  Writeln('Error in stream: Code = ', Code, ' Info = ', Info);
  Halt(1);
end;

{ TTVDemo }
constructor TTVDemo.Init;
var
  R: TRect;
  I: Integer;
  FileName: PathStr;
begin
  { Initalize editor heap }
  MaxHeapSize := HeapSize;

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
  RegisterEditors;

  RegisterType(RStringList);

  Strings := PStringList(RezFile.Get('Strings'));

  inherited Init;

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
  FileName: PathStr;
begin
  FileName := '*.*';
  if ExecuteDialog(PDialog(RezFile.Get('FileOpenDialog')),
      @FileName) <> cmCancel then
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
          RMessageBox(sErrorHelp, nil, mfError + mfOkButton);
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
begin
  ExecuteDialog(PDialog(RezFile.Get('ChDirDialog')), nil);
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
  ExecuteDialog(PDialog(RezFile.Get('AboutDialog')), nil);
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
begin
  if ExecuteDialog(PDialog(RezFile.Get('ColorSelectDialog')),
    Application^.GetPalette) <> cmCancel then
  begin
    DoneMemory;
    ReDraw;
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
  S := New(PBufStream, Init('TVRDEMO.DSK', stOpenRead, 1024));
  if LowMemory then OutOfMemory
  else if S^.Status <> stOk then
    RMessageBox(sErrorOpenDesk, nil, mfOkButton + mfError)
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
        RMessageBox(sErrorReadingDesk, nil, mfOkButton + mfError);
    end
    else
      RMessageBox(sDeskInvalid, nil, mfOkButton + mfError);
  end;
  Dispose(S, Done);
end;

procedure SaveDesktop;
var
  S: PStream;
  F: File;
begin
  S := New(PBufStream, Init('TVRDEMO.DSK', stCreate, 1024));
  if not LowMemory and (S^.Status = stOk) then
  begin
    S^.Write(DSKSignature[1], SignatureLen);
    StoreDesktop(S^);
    StoreIndexes(S^);
    StoreHistory(S^);
    if S^.Status <> stOk then
    begin
      RMessageBox(sErrorDeskCreate, nil, mfOkButton + mfError);
      {$I-}
      Dispose(S, Done);
      Assign(F, 'TVRDEMO.DSK');
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
var
  R: TRect;
begin
  StatusLine := PStatusLine(RezFile.Get('StatusLine'));
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine^.Locate(R);
end;

procedure TTVDemo.OutOfMemory;
begin
  RMessageBox(sNoMem, nil, mfError + mfOkButton);
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
  if Lo(DosVersion) >= 3 then EXEName := ParamStr(0)
  else
  begin
    EXEName := FSearch('TVRDEMO.EXE', GetEnv('PATH'));
    if EXEName = '' then PrintStr('TVRDEMO.EXE could not be found.'#13#10);
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

