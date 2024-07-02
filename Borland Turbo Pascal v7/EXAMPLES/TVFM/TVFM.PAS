{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$M 16384,8192,655360}
{$X+,V-}

program TVFM;

uses Objects, Drivers, Memory, App, Views, Menus, Dialogs, StdDlg, Globals,
  Dos, MsgBox, Equ, Tools, TreeWin, Colors, Assoc, Trash, FileFind;

{ If you get a FILE NOT FOUND error when compiling this program
  from a DOS IDE, change to the \BP\EXAMPLES\DOS\TVFM directory
  (use File|Change dir).

  This will enable the compiler to find all of the units used by
  this program.
}

const
{$IFDEF SingleExe}
  RezExt = '.EXE';
{$ELSE}
  RezExt = '.TVR';
{$ENDIF}

type

  TMyApp = object(TApplication)
    TrashCan: PTrashCan;
    ExitDir: String;
    constructor Init;
    destructor Done; virtual;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure ToggleVideoMode;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure OutOfMemory; virtual;
  end;


{ TMyApp implementation }

constructor TMyApp.Init;
var
  R: TRect;
  H: Word;
  CurDir: PathStr;
begin
  { Initialize resource file }

  RezStream := New(PProtectedStream, Init(GetExeBaseName + RezExt, stOpenRead, 4096));
  if RezStream^.Status <> stOK then
  begin
    PrintStr('Unable to open resource file.');
    Halt(1);
  end;
  RezFile.Init(RezStream);

  { Standard Turbo Vision objects }
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterStdDlg;

  { Objects specific to this app }
  RegisterGlobals;
  RegisterType(RStringList);
  RegisterAssociations;

  RezStrings := PStringList(RezFile.Get('Strings'));

  if RezStrings = nil then
  begin
    PrintStr('Unable to read resources from resource file.');
    Halt(1);
  end;

  inherited Init;
  InitAssociations;

  Desktop^.GetExtent(R);
  Dec(R.B.Y); Inc(R.A.X);
  R.A.Y := R.B.Y - 3;
  R.B.X := R.A.X + 5;
  TrashCan := New(PTrashCan, Init(R));
  Desktop^.Insert(TrashCan);

  ConfigRec.Video := ScreenMode and smFont8x8;
  ReadConfig;
  if ConfigRec.Video <> (ScreenMode and smFont8x8) then
    ToggleVideoMode;

  { by defaut, open a directory window to the current drive }
  GetDir(0, CurDir);
  InsertTreeWindow(CurDir[1]);
end;

destructor TMyApp.Done;
begin
  DoneAssociations;
  Dispose(TrashCan, Done);
{$I-}
  if ExitDir <> '' then
  begin
    if ExitDir[Length(ExitDir)] = ':' then ExitDir := ExitDir + '\';
    ChDir(ExitDir);
  end;
{$I+}
  inherited Done;
  DoneMemory;
end;

procedure TMyApp.Idle;
const
  FileListCmds : TCommandSet =
    [cmExecute, cmViewAsHex, cmViewAsText, cmViewCustom, cmCopy, cmDelete,
     cmRename, cmChangeAttr, cmReverseTags, cmClearTags, cmTagPerCard,
     cmAssociate];
var
  TopWindow: PWindow;
begin
  inherited Idle;

  TopWindow := Message(Desktop, evBroadcast, cmTopWindow, nil);
  if TopWindow = nil then
  begin
    DisableCommands(FileListCmds);
    DisableCommands([cmExitHere]);
  end
  else
  begin
    EnableCommands([cmExitHere]);
    if Message(TopWindow, evBroadcast, cmFileListFocused, nil) <> nil then
      EnableCommands(FileListCmds)
    else
      DisableCommands(FileListCmds);
  end;

  { This app defines a new type of event, evIdle.  This event type is }
  { generated once every idle cycle.                                  }
  Message(Desktop, evIdle, 0, nil);
end;

procedure TMyApp.InitMenuBar;
begin
  MenuBar := PMenuBar(RezFile.Get('MainMenu'));
end;

procedure TMyApp.InitStatusLine;
var
  R: TRect;
begin
  StatusLine := PHCStatusLine(RezFile.Get('StatusLine'));
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine^.Locate(R);
end;

procedure TMyApp.ToggleVideoMode;
var
  NewMode: Word;
  R: TRect;
begin
  NewMode := ScreenMode xor smFont8x8;
  if NewMode and smFont8x8 <> 0 then ShadowSize.X := 1
  else ShadowSize.X := 2;
  SetScreenMode(NewMode);
  Desktop^.GetExtent(R);
  TrashCan^.Reposition(R);
  ConfigRec.Video := ScreenMode and smFont8x8;
end;

procedure TMyApp.HandleEvent(var Event: TEvent);
var
  NewDrive: Char;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewWindow:
        begin
          NewDrive := SelectDrive;
          if NewDrive <> ' ' then InsertTreeWindow(NewDrive);
          ClearEvent(Event);
        end;
      cmBeginSearch: BeginSearch;
      cmInstallViewer : InstallViewer;
      cmDisplayOptions : SetDisplayPrefs;
      cmSaveConfig : SaveConfig;
      cmTile : Tile;
      cmCascade : Cascade;
      cmCloseAll: Message(Desktop, evBroadcast, cmCloseAll, nil);
      cmDosShell : DosShell;
      cmRun : RunDosCommand('');
      cmVideoMode: ToggleVideoMode;
      cmExitHere:
        begin
          Message(Desktop, evBroadcast, cmGetCurrentDir, @ExitDir);
          EndModal(cmQuit);
          ClearEvent(Event);
        end;
      cmColorChange: SelectNewColors;
    end;
  end;
end;

procedure TMyApp.OutOfMemory;
begin
  MessageBox('There is not enough memory to complete this operation.',
    nil, mfError+mfOKButton);
end;

var
  MyApp : TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
