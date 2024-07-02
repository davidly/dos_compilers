{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Tools;

{$X+,V-}

interface

uses Drivers, Objects, Views, Dialogs, Memory, App, MsgBox,
  Globals, FileCopy, Gauges, Dos;

type
  String2 = String[2];
  String4 = String[4];
  TConfigHeader = String[24];

  { Used to display status messages }
  PStatusBox = ^TStatusBox;
  TStatusBox = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  { buffered file copy object }
  PCopier = ^TCopier;
  TCopier = object(TFileCopy)
    procedure ReadMsg(const FName: FNameStr; Progress: Longint); virtual;
    procedure WriteMsg(const FName: FNameStr; Progress: Longint); virtual;
    function IOError(const FName: FNameStr; ECode:Integer) : erAction; virtual;
  end;

  { generate a cmOK if double clicked }
  POkListBox = ^TOkListBox;
  TOkListBox = object(TListBox)
    procedure SelectItem(Item: Integer); virtual;
  end;

{ ShowStatusBox displays a status dialog, using StatusMsg as the string }
{ to display. The status box responds to the cmStatusUpdate command by  }
{ redrawing the text.                                                   }
procedure ShowStatusBox;

{ KillStatusBox removes the status box from the screen }
procedure KillStatusBox;

{ Return True if the passed list contains any tagged files }
function HasTaggedFiles(P: PFileList) : Boolean;

{ Return the path and filename (no extension) of the exe }
function GetExeBaseName: String;

{ Convert strings to upper and lower case }
procedure UpperCase(var s: String);
procedure LowerCase(var s: String);

{ Return a right justified number (in an 8 character field) }
function RJustNum(L: Longint): String;

{ Pad right end of string to Len bytes }
function Pad(s: String; Len: Byte): String;

{ Return a fully trimmed copy of Original }
function FullTrim(const Original: String): String;

{ Return string value of W, optionally with leading zero if Pad=True }
function TwoDigit(W: Word; Pad: Boolean): String2;

{ Return 4 digit string representation of W }
function FourDigit(W: Word): String4;

{ Return a string version of the Date/Time longint. Opts=$01 adds the }
{ date portion. Opts=$02 adds time, Opts=$03 adds both                }
function FormatDateTime(DT: Longint; Opts: Word): String;

{ Return the 4 character string representation of the attribute word }
function FormatAttr(Attr: Word): String4;

{ Return True if file is a .BAT, .COM, or .EXE }
function IsExecutable(const FileName: FNameStr): Boolean;

{ Execute the passed file, asks for parameters }
procedure ExecuteFile(FileName: FNameStr);

{ View passed file as Hex, Text, or with Custom Viewer }
procedure ViewAsHex(const FileName: FNameStr);
procedure ViewAsText(const FileName: FNameStr);
procedure ViewCustom(const FileName: FNameStr);

{ Return True if the passed drive letter is valid }
function DriveValid(Drive: Char): Boolean;

{ Return a selected drive letter from listbox of valid drives }
function SelectDrive: Char;

{ Invalidate the passed directory by issuing a cmInvalidDir broadcast }
procedure InvalidateDir(Path: FNameStr);

{ Copy either tagged or current file to a destination path }
procedure HandleFileCopy(const Path: FNameStr; P: PFileList; Current: Integer);

{ Delete file if user confirms the deletion, return error code }
function SafeDelete(FileName: FNameStr): Integer;

{ Handle deleting one or multiple files from a file list }
procedure HandleFileDelete(const Path: FNameStr; List: PFileList;
  Current: Integer);

{ Present the Rename file dialog }
procedure RenameFile(const Path: FNameStr; F: PFileRec);

{ Present the Change Attribute dialog }
procedure ChangeAttr(const Path: FNameStr; F:PFileRec);

{ Allow user to specify what viewer program to use }
procedure InstallViewer;

{ Allow user to specify the display options }
procedure SetDisplayPrefs;

{ Save and load the configuration file }
procedure SaveConfig;
procedure ReadConfig;

{ Execute the passed string literally }
procedure RunDosCommand(Command: String);

{ Return a TFileNameRec built from the passed filespec. This structure }
{ allows for easier comparisons by other procedures                    }
function NewFileNameRec(const Path: FNameStr): PFileNameRec;

{ Perform a drag & drop copy }
procedure DragDropCopy(Mover: PFileMover; Dest: PathStr);

{ return true if this name matches the wildcard }
function WildCardMatch(const Name, Card: FNameStr): Boolean;

const
  StatusMsg : String = '';

implementation

uses ViewHex, ViewText, Strings, Equ, Assoc;

const
  StatusBox : PStatusBox = nil;
  StatusPMsg : PString = @StatusMsg;

  ConfigHeader : TConfigHeader = 'TVFM Configuration File'#26;

{ General utility procedures }

procedure ShowStatusBox;
var
  R: TRect;
  P: PView;
begin
  if StatusBox <> nil then exit;
  R.Assign(0,0,40,5);
  StatusBox := New(PStatusBox, Init(R, 'Status'));
  with StatusBox^ do
  begin
    Options := Options or ofCentered;
    Options := Options and (not ofBuffered);
    Flags := Flags and (not wfClose) and (not wfMove);
    R.Assign(2,2,38,3);
    P := New(PParamText, Init(R, ^C'%s', 1));
    Insert(P);
  end;
  StatusMsg := '';
  StatusPMsg := @StatusMsg;
  StatusBox^.SetData(StatusPMsg);
  Desktop^.Insert(StatusBox);
end;

procedure ShowCopyStatusBox(MaxSize: Longint);
var
  R: TRect;
  P: PView;
begin
  if StatusBox <> nil then exit;
  R.Assign(0,0,40,7);
  StatusBox := New(PStatusBox, Init(R, 'Status'));
  with StatusBox^ do
  begin
    Options := Options or ofCentered;
    Options := Options and (not ofBuffered);
    Flags := Flags and (not wfClose) and (not wfMove);
    R.Assign(2,2,38,3);
    P := New(PParamText, Init(R, ^C'%s', 1));
    Insert(P);
    R.Assign(5,4,34,5);
    Insert(New(PBarGauge, Init(R, MaxSize)));
    R.Assign(2,4,4,5);
    Insert(New(PStaticText, Init(R, '0%')));
    R.Assign(35,4,39,5);
    Insert(New(PStaticText, Init(R, '100%')));
  end;
  StatusMsg := '';
  StatusPMsg := @StatusMsg;
  StatusBox^.SetData(StatusPMsg);
  Desktop^.Insert(StatusBox);
end;

procedure KillStatusBox;
begin
  if StatusBox <> nil then
  begin
    Dispose(StatusBox, Done);
    StatusBox := nil;
  end;
end;

{ Return TRUE if the passed list has tagged files in it }
function HasTaggedFiles(P: PFileList) : Boolean;
var
  Has: Boolean;
  i: Integer;
begin
  Has := False;
  i := 0;
  while (i < P^.Count) and (not Has) do
  begin
    Has := PFileRec(P^.At(i))^.Tagged;
    Inc(i);
  end;
  HasTaggedFiles := Has;
end;

function GetExeBaseName : String;
var
  ExeFileName: FNameStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  ExeFileName := ParamStr(0);
  if ExeFileName = '' then
    ExeFileName := FSearch(EXEName, GetEnv('PATH'));
  ExeFileName := FExpand(ExeFileName);
  FSplit(ExeFileName, D, N, E);
  GetExeBaseName := D + N;
end;

procedure UpperCase(var s:string);
var
  i : Integer;
begin
  for i := 1 to Length(s) do
    s[i] := Upcase(s[i]);
end;

procedure LowerCase(var s:string);
var
  i : Integer;
begin
  for i := 1 to Length(s) do
    if s[i] in ['A'..'Z'] then Inc(s[i], 32);
end;

function RJustNum(L: Longint): String;
var
  s: String;
begin
  FormatStr(s, '%8d', L);
  RJustNum := s;
end;

function Pad(s: String; Len: Byte): String;
begin
  if Length(s) < Len then
    FillChar(s[Succ(Length(s))], Len-Length(s), ' ');
  s[0] := Char(Len);
  Pad := s;
end;

function FullTrim(const Original: String): String;
var
  S: String;
begin
  S := Original;
  while (S[0] > #0) and (S[Length(S)] = #32) do Dec(S[0]);  { trim left }
  while (S[0] > #0) and (S[1] = #32) do
  begin
    Move(S[2], S[1], Pred(Length(S)));
    Dec(S[0]);
  end;
  FullTrim := S;
end;

function TwoDigit(W: Word; Pad: Boolean) : String2;
var
  s: String2;
begin
  Str(W:2, s);
  if Pad and (s[1] = ' ') then s[1] := '0';
  TwoDigit := s;
end;

function FourDigit(W: Word) : String4;
var
  s: String4;
begin
  Str(W:4, s);
  FourDigit := s;
end;

function FormatDateTime(DT: Longint; Opts: Word): String;
var
  s: String;
  t: DateTime;
begin
  UnpackTime(DT, t);
  s := '';
  if (Opts and 1) <> 0 then  { add the date }
  begin
    s := s + TwoDigit(t.Month, False) + '-' + TwoDigit(t.Day, True);
    s := s + '-' + Copy(FourDigit(t.Year),3,2);
  end;
  if (Opts and 2) <> 0 then  { add the time }
  begin
    if s <> '' then s := s + ' ';
    s := s + TwoDigit(t.Hour, True) + ':' + TwoDigit(t.Min, True) + ':' +
      TwoDigit(t.Sec, True);
  end;
  FormatDateTime := s;
end;

function FormatAttr(Attr: Word): String4;
var
  s: String4;
begin
  s := 'תתתת';
  if Attr and Archive = Archive then s[1] := 'A';
  if Attr and ReadOnly = ReadOnly then s[2] := 'R';
  if Attr and SysFile = SysFile then s[3] := 'S';
  if Attr and Hidden = Hidden  then s[4] := 'H';
  FormatAttr := s;
end;

function IsExecutable(const FileName: FNameStr): Boolean;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(FExpand(FileName), D, N, E);
  IsExecutable := (E = '.EXE') or (E = '.COM') or (E = '.BAT');
end;

procedure ExecuteFile(FileName: FNameStr);
var
  D: PDialog;
  R: TRect;
  P: PView;
  Dir: DirStr;
  Name: FNameStr;
  E: ExtStr;
  Event: TEvent;
  Params: string[80];
  Command: string[80];
  L: array[0..2] of Longint;
  ParamPos: Integer;
  Association: PAssociation;
begin
  FSplit(FExpand(FileName), Dir, Name, E);
  Name := Name + E;
  Association := nil;

  Command := '';
  Params := '';
  { Does an association exist for this file? }
  if not IsExecutable(FileName) then
  begin
    Association := GetAssociatedCommand(E);
    if Association <> nil then Command := Association^.Cmd^;
    if Command = '' then
    begin
      L[0] := Longint(@FileName);
      MessageBox(RezStrings^.Get(sNoAssociation), @L, mfError +
        mfOKButton);
      Exit;
    end
    else
    begin
      ParamPos := Pos(' ', Command);
      if ParamPos > 0 then
      begin
        Params := Copy(Command, ParamPos + 1, $FF);
        Delete(Command, ParamPos, $FF);
        Params := Params + ' ' + FileName;
      end
      else
        Params := FileName;
    end;
  end
  else
  begin
    Command := FileName;
    Params := '';
  end;

  R.Assign(0,0,50,8);
  D:= New(PDialog, Init(R, 'Execute Program'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(2,2,15,3);
    Insert(New(PStaticText, Init(R, ' Executing:')));
    R.Assign(15,2,48,3);
    Insert(New(PStaticText, Init(R, Command)));

    R.Assign(15,3,48,4);
    P := New(PInputLine, Init(R, 80));
    Insert(P);
    R.Assign(2,3,15,4);
    Insert(New(PLabel, Init(R, '~P~arameters', P)));

    R.Assign(12,5,24,7);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
    R.Move(14,0);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;

  if ( (Association <> nil) and (not Association^.Prompt)) or
    (Application^.ExecuteDialog(D, @Params) = cmOK) then
  begin
    DoneSysError;
    DoneEvents;
    DoneVideo;
    DoneDosMem;
    SwapVectors;

    if E = '.BAT' then
    begin
      Command := GetEnv('COMSPEC');
      Params := '/c ' + FileName + Params;
    end;

    Exec(Command, Params);
    SwapVectors;

    PrintStr(RezStrings^.Get(sPressAnyKey));
    Event.What := evNothing;
    repeat
      GetKeyEvent(Event);
    until Event.What <> evNothing;

    InitDosMem;
    InitVideo;
    InitEvents;
    InitSysError;
    Application^.Redraw;

    if DosError <> 0 then
    begin
      L[0] := DosError;
      L[1] := Longint(@Command);
      MessageBox(RezStrings^.Get(sExecErr), @L, mfError + mfOKButton);
    end else
    begin
      L[0] := DosExitCode and $FF;
      if L[0] <> 0 then
        MessageBox(RezStrings^.Get(sExecRetCode), @L,
          mfInformation + mfOKButton);
    end;
  end;
end;

{ view file procedures }
procedure ViewAsHex(const FileName: FNameStr);
var
  H: PHexWindow;
  R: TRect;
begin
  R.Assign(0,0,72,15);
  H := New(PHexWindow, Init(R, FileName));
  H^.Options := H^.Options or ofCentered;
  Desktop^.Insert(H);
end;

procedure ViewAsText(const FileName: FNameStr);
var
  T: PTextWindow;
  R: TRect;
begin
  R.Assign(0,0,72,15);
  T := New(PTextWindow, Init(R, FileName));
  T^.Options := T^.Options or ofCentered;
  Desktop^.Insert(T);
end;

procedure ViewCustom(const FileName: FNameStr);
var
  Params : FNameStr;
  Command : FNameStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  L : array[0..1] of Longint;
  Msg: String;
  PS: PString;
begin
  { create the program name }

  if FullTrim(Viewer) = '' then
  begin
    MessageBox(RezStrings^.Get(sNoViewerErr), nil, mfError + mfOKButton);
    Exit;
  end;

  FSplit(Viewer, D, N, E);

  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneDosMem;
  SwapVectors;

  if E = '.BAT' then
  begin
    Command := GetEnv('COMSPEC');
    Params := '/c ' + Viewer + ' ' + FileName;
  end
  else
  begin
    Command := Viewer;
    Params := FileName;
  end;

  Exec(Command, Params);
  SwapVectors;

  InitDosMem;
  InitVideo;
  InitEvents;
  InitSysError;
  Application^.Redraw;

  if DosError <> 0 then
  begin
    L[0] := DosError;
    L[1] := Longint( @Viewer );
    MessageBox(RezStrings^.Get(sInvokeErr), @L, mfError + mfOKButton);
  end;

end;


function DriveValid(Drive: Char): Boolean; assembler;
asm
	MOV	AH,19H          { Save the current drive in BL }
        INT	21H
        MOV	BL,AL
 	MOV	DL,Drive	{ Select the given drive }
        SUB	DL,'A'
        MOV	AH,0EH
        INT	21H
        MOV	AH,19H		{ Retrieve what DOS thinks is current }
        INT	21H
        MOV	CX,0		{ Assume false }
        CMP	AL,DL		{ Is the current drive the given drive? }
	JNE	@@1
        MOV	CX,1		{ It is, so the drive is valid }
	MOV	DL,BL		{ Restore the old drive }
        MOV	AH,0EH
        INT	21H
@@1:	XCHG	AX,CX		{ Put the return value into AX }
end;

{ Return a redirected device entry into the specified buffers }
function GetRedirEntry(Entry: Word; Local, Net: Pointer): Boolean; assembler;
asm
        PUSH    DS
        LDS     SI,Local
        LES     DI,Net
        MOV     AX,5F02h
        MOV     BX,Entry
        INT     21h
        POP     DS
        SBB     AL,AL
        INC     AL
end;

{ return a list of redirected devices (drives only) }
function RedirDeviceList: PDeviceCollection;
var
  List: PDeviceCollection;
  Device: PDeviceRec;
  P: PChar;
  I: Word;
  LocalName: array[0..15] of char;
  NetworkName: array[0..127] of char;
begin
  List := nil;

{$IFNDEF DPMI}
  List := New(PDeviceCollection, Init(10,10));
  for I := 0 to 99 do
  begin
    if GetRedirEntry(I, @LocalName, @NetworkName) then
    begin
      if (LocalName[0] in ['D'..'Z']) and (LocalName[1] = ':') then
      begin
        New(Device);
        Device^.LocalName := LocalName[0];
        P := @NetworkName[2];
        Device^.NetworkName := NewStr( StrPas(P) );
        List^.Insert(Device);
      end;
    end
    else Break;
  end;

  if List^.Count = 0 then
  begin
    Dispose(List, Done);
    List := nil;
  end;
{$ENDIF}

  RedirDeviceList := List;
end;


function ValidDriveList: PStringCollection;
var
  DriveList: PStringCollection;
  DeviceList: PDeviceCollection;
  Drive: Char;
  Device: PDeviceRec;
  S: String;

  function DriveMatch(P: PDeviceRec): Boolean; far;
  begin
    DriveMatch := Drive = P^.LocalName;
  end;

begin
  DriveList := New(PStringCollection, Init(26,0));
  DeviceList := RedirDeviceList;
  for Drive := 'A' to 'Z' do
  begin
    if DriveValid(Drive) then
    begin
      S := Drive + ':';
      if DeviceList <> nil then
      begin
        Device := DeviceList^.FirstThat(@DriveMatch);
        if Device <> nil then S := S + '  ' + Device^.NetworkName^;
      end;
      DriveList^.Insert(NewStr(S));
    end;
  end;
  if DriveList^.Count = 0 then
  begin
    Dispose(DriveList, Done);
    DriveList := nil;
  end;
  ValidDriveList := DriveList;
  if DeviceList <> nil then Dispose(DeviceList, Done);
end;

function SelectDrive : Char;
var
  R: TRect;
  D: PDialog;
  LB: PListBox;
  SB: PScrollBar;
  P: PString;
  DriveList: PStringCollection;
  CurDir: String;

  function IsCurrentDirectory(Dir: PString): Boolean; far;
  begin
    IsCurrentDirectory := Dir^[1] = CurDir[1];
  end;

begin
  GetDir(0, CurDir);  { save this value }
  SelectDrive := ' ';
  DriveList := ValidDriveList;

  if DriveList = nil then
  begin
    MessageBox(RezStrings^.Get(sNoDrivesErr), nil, mfError + mfOKButton);
    Exit;
  end;

  R.Assign(0, 0, 53, 13);
  D := New(PDialog, Init(R, 'Select Drive'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(50, 3, 51, 9);
    SB := New(PScrollBar, Init(R));
    Insert(SB);
    R.Assign(2, 3, 50, 9);
    LB := New(POkListBox, Init(R, 1, SB));
    Insert(LB);
    LB^.NewList(DriveList);
    R.Assign(2, 2, 19, 3);
    Insert(New(PLabel, Init(R, '~D~rives', LB)));
    R.Assign(12, 10, 24, 12);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
    R.Move(16, 0);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;

  P := DriveList^.FirstThat(@IsCurrentDirectory);
  if P <> nil then
    LB^.FocusItem(DriveList^.IndexOf(P));

  if Desktop^.ExecView(D) = cmOK then
  begin
    P := DriveList^.At(LB^.Focused);
    if P <> nil then SelectDrive := P^[1];
  end;
  Dispose(DriveList, Done);
  Dispose(D, Done);
end;

procedure InvalidateDir(Path: FNameStr);
begin
  Message(Desktop, evBroadcast, cmInvalidDir, @Path);
end;

procedure HandleFileCopy(const Path: FNameStr; P: PFileList; Current: Integer);
var
  Dest, S, D: string[80];
  C: TCopier;
  Dlg: PDialog;
  TotalSize: Longint;

  procedure CopyTagged(F: PFileRec); far;
  begin
    if F^.Tagged then
    begin
      S := Path + '\' + F^.Name + F^.Ext;
      D := Dest + F^.Name + F^.Ext;
      C.CopyFile(S, D, coNormal);
    end;
  end;

  procedure AddSizes(F: PFileRec); far;
  begin
    if F^.Tagged then Inc(TotalSize, F^.Size);
  end;

  procedure CopySingle(F: PFileRec);
  begin
    S := Path + '\' + F^.Name + F^.Ext;
    D := Dest + F^.Name + F^.Ext;
    C.CopyFile(S, D, coNormal);
  end;

begin
  Dest := '';
  Dlg := PDialog( RezFile.Get('CopyDialog') );
  Application^.ExecuteDialog(Dlg, @Dest);
  if Dest = '' then Exit;

  Dest := FExpand(Dest);
  if (Dest[Length(Dest)] <> '\') and (Dest[Length(Dest)] <> ':') then
    Dest := Dest + '\';

  C.Init(20);

  TotalSize := 0;
  if HasTaggedFiles(P) then P^.ForEach(@AddSizes)
  else TotalSize := PFileRec(P^.At(Current))^.Size;
  ShowCopyStatusBox(TotalSize);

  if HasTaggedFiles(P) then P^.ForEach(@CopyTagged)
  else CopySingle( PFileRec( P^.At(Current) ) );

  C.Done;
  KillStatusBox;

  if Dest[Length(Dest)] = '\' then Dec(Dest[0]);
  InvalidateDir(Dest);
end;

function SafeDelete(FileName: FNameStr): Integer;
var
  R: Word;
  F: File;
  C: Word;
  L: Longint;
  D: PDialog;
  Params: array[0..1] of Pointer;
  Name : FNameStr;
  Msg : String;
  Attr: Word;
begin
  SafeDelete := -1;
  C := cmYes; { default value }
  Assign(F, FileName);
  GetFAttr(F, Attr);
  if DosError <> 0 then
  begin
    Params[0] := Pointer(L);
    Params[1] := @FileName;
    MessageBox(RezStrings^.Get(sAccessErr), @Params, mfError + mfOKButton);
    SafeDelete := L;
    Exit;
  end;

  if (Attr and ReadOnly) <> 0 then Msg := RezStrings^.Get(sFileIsReadOnly)
  else Msg := '';
  Params[0] := @FileName;
  Params[1] := @Msg;

  if ConfirmDelete then
  begin
    D := PDialog( RezFile.Get('ConfirmDelete') );
    C := Application^.ExecuteDialog(D, @Params);
  end;

  if C = cmYes then
  begin
    { if file was read-only, clear that attribute }
    if (Attr and ReadOnly) <> 0 then
    begin
      SetFAttr(F, Attr and (not ReadOnly));
      if DosError <> 0 then
      begin
        L := DosError;
        Params[0] := @Msg;
        Params[1] := Pointer(L);
        MessageBox(RezStrings^.Get(sSetAttrErr), @Params, mfError+mfOKButton);
        SafeDelete := DosError;
        Exit;
      end;
    end;

    { delete the file }
    {$I-}
    Erase(F);
    {$I+}
    L := IOResult;
    if L <> 0 then
    begin
      Params[0] := @Msg;
      Params[1] := Pointer(L);
      MessageBox(RezStrings^.Get(sDeleteErr), @Params, mfError+mfOKButton);
      SafeDelete := L;
      Exit;
    end
    else
      SafeDelete := 0;
  end;
end;

function RemoveDeadFiles(P: PFileList): Integer;
var
  F : PFileRec;
  i : Integer;
  Count: Integer;
begin
  Count := 0;
  i := 0;
  while i < P^.Count do
  begin
    F := P^.At(i);
    if F^.Name[1] = #0 then
    begin
      if F^.Tagged then
      begin
        F^.Toggle;
        Message(Desktop, evBroadcast, cmTagChanged, F);
      end;
      Inc(Count);
      P^.AtFree(i);
    end
    else inc(i);
  end;
  RemoveDeadFiles := Count;
end;

function DeleteMultFiles(Path: FNameStr; List: PFileList): Boolean;
var
  F: PFileRec;
  N: FNameStr;

  procedure DeleteIfTagged(F: PFileRec); far;
  begin
    if F^.Tagged then
    begin
      N := Path + '\' + F^.Name + F^.Ext;
      StatusMsg := RezStrings^.Get(sDeleting) + N;
      Message(StatusBox, evBroadcast, cmStatusUpdate, nil);
      if SafeDelete(N) = 0 then F^.Name[1] := #0;  { mark as deleted }
    end;
  end;

begin
  ConfirmDelete := False;

  StatusMsg := '';
  ShowStatusBox;
  List^.ForEach(@DeleteIfTagged);
  KillStatusBox;

  DeleteMultFiles := RemoveDeadFiles(List) > 0;

  ConfirmDelete := True;
end;

procedure HandleFileDelete(const Path: FNameStr; List: PFileList;
  Current: Integer);
var
  D: PDialog;
  Command: Word;
  F: PFileRec;
begin

  F := List^.At(Current);
  Command := cmNo;  { default to only deleting current file }

  if HasTaggedFiles(List) then
  begin
    D := PDialog( RezFile.Get('DeleteWhich') );
    Command := Application^.ExecuteDialog(D, nil);
  end;

  if Command = cmNo then  { only delete the current file }
  begin
    F := List^.At(Current);
    if SafeDelete(Path + '\' + F^.Name + F^.Ext) = 0 then
      InvalidateDir(Path);
  end
  else if Command = cmYes then   { delete all marked files }
  begin
    if DeleteMultFiles(Path, List) then
      InvalidateDir(Path);
  end;

end;

procedure RenameFile(const Path: FNameStr; F: PFileRec);
var
  D: PRenameDialog;
  Dir: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  D := New(PRenameDialog, Init(Path + '\' + F^.Name + F^.Ext));
  if D <> nil then
  begin
    if Application^.ExecuteDialog(D, nil) = cmOK then
    begin
      FSplit(D^.NewName, Dir, N, E);
      F^.Name := N;
      F^.Ext := E;
      InvalidateDir(Path);
    end;
  end;
end;

procedure ChangeAttr(const Path: FNameStr; F: PFileRec);
var
  D: PAttrDialog;
begin
  D := New(PAttrDialog, Init(Path + '\' + F^.Name + F^.Ext));
  if D <> nil then
  begin
    if Application^.ExecuteDialog(D, nil) = cmOK then
    begin
      F^.Attr := D^.NewAttr;
      InvalidateDir(Path);
    end;
  end
  else
    MessageBox(RezStrings^.Get(sReadAttrErr), nil,
      mfError + mfOKButton);
end;

procedure InstallViewer;
var
  VPath: FNameStr;
  Valid, Done: Boolean;
  L: Longint;
begin
  VPath := Viewer;
  Valid := False;
  Done := False;
  while (not Valid) and (not Done) do
  begin
    if InputBox(RezStrings^.Get(sCustomViewer), RezStrings^.Get(sPathAndName),
      VPath, SizeOf(FNameStr) - 1) = cmOK then
    begin
      UpperCase(VPath);
      VPath := FSearch(VPath, GetEnv('PATH'));
      if VPath = '' then
      begin
        MessageBox(RezStrings^.Get(sCantLocateOnPath), nil,
          mfError + mfOKButton);
      end
      else if not IsExecutable(VPath) then
      begin
        L := Longint(@VPath);
        MessageBox(RezStrings^.Get(sFileNotAnExe), @L, mfError+mfOKButton);
      end
      else Valid := True;
    end
    else Done := True;
  end;
  if Valid then Viewer := VPath;
end;

procedure SetDisplayPrefs;
var
  D: PDialog;
  SaveMask: string[12];
begin
  D := PDialog( RezFile.Get('DisplayPref') );

  SaveMask := ConfigRec.FileMask;
  if Application^.ExecuteDialog(D, @ConfigRec) = cmOK then
  begin
    Uppercase(ConfigRec.FileMask);

    if ConfigRec.ShowHidden > 0 then
      UnwantedFiles := VolumeID or Directory
    else
      UnwantedFiles := VolumeID or Directory or SysFile or Hidden;

    if ConfigRec.FileMask <> SaveMask then
      Message(Desktop, evBroadcast, cmRescan, nil)
    else
      Message(Desktop, evBroadcast, cmRefreshDisplay, nil);
  end;
end;

procedure SaveConfig;
var
  Result: Longint;
  F: PDosStream;
  Pal: PString;
begin
  F := New(PDosStream, Init(GetExeBaseName + CFGExt, stCreate));
  Result := F^.Status;
  if Result <> 0 then
  begin
    MessageBox(RezStrings^.Get(sWriteCfgErr), @Result, mfError+mfOKButton);
    Exit;
  end;
  F^.Write(ConfigHeader[1], SizeOf(TConfigHeader) - 1);
  F^.Write(ConfigRec, SizeOf(TConfigRec));
  F^.Write(Viewer, SizeOf(FNameStr));
  Pal := @Application^.GetPalette^;
  F^.WriteStr(Pal);
  WriteAssociationList(F^);
  Dispose(F, Done);
end;

procedure ReadConfig;
var
  Result: Longint;
  F: PDosStream;
  Header: TConfigHeader;
  Pal: PString;
begin
  F := New(PDosStream, Init(GetExeBaseName + CFGExt, stOpenRead));
  Result := F^.Status;
  if Result <> 0 then Exit;
  F^.Read(Header[1], SizeOf(TConfigHeader) - 1);
  Header[0] := Char( SizeOf(TConfigHeader) -1 );
  if Header <> ConfigHeader then
  begin
    MessageBox(RezStrings^.Get(sInvalidCfgErr), nil, mfError + mfOKButton);
    Exit;
  end;
  F^.Read(ConfigRec, SizeOf(TConfigRec));
  F^.Read(Viewer, SizeOf(FNameStr));
  Pal := F^.ReadStr;
  if Pal <> nil then
  begin
    Application^.GetPalette^ := Pal^;
    DoneMemory;
    Application^.ReDraw;
    DisposeStr(Pal);
  end;
  ReadAssociationList(F^);
  Dispose(F, Done);
end;

procedure RunDosCommand(Command: String);
var
  D: PDialog;
  Event: TEvent;
begin
  D := PDialog( RezFile.Get('RunDialog') );
  if (Application^.ExecuteDialog(D, @Command) = cmOK) and
     (FullTrim(Command) <> '') then
  begin
    DoneSysError;
    DoneEvents;
    DoneVideo;
    DoneDosMem;

    SwapVectors;
    Exec(GetEnv('COMSPEC'), '/C' + Command);
    SwapVectors;

    PrintStr(RezStrings^.Get(sPressAnyKey));
    repeat
      GetKeyEvent(Event);
    until Event.What <> evNothing;

    InitDosMem;
    InitVideo;
    InitEvents;
    InitSysError;

    Application^.Redraw;
  end;
end;

function NewFileNameRec(const Path: FNameStr): PFileNameRec;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  P: PFileNameRec;
begin
  FSplit(Path, D, N, E);
  New(P);
  P^.Dir := D;
  P^.Name := N;
  P^.Ext := E;
  NewFileNameRec := P;
end;

procedure DragDropCopy(Mover: PFileMover; Dest: PathStr);
var
  C: TCopier;
  TotalSize: Longint;

  procedure AddSizes(F: PFileRec); far;
  begin
    Inc(TotalSize, F^.Size);
  end;

  procedure CopyFiles(F: PFileRec); far;
  begin
    C.CopyFile(Mover^.Dir + '\' + F^.Name + F^.Ext,
      Dest + '\' + F^.Name + F^.Ext, coNormal);
  end;

begin
  if Mover^.Dir = Dest then
  begin
    MessageBox('Files cannot be copied to same directory.',nil,
      mfError + mfOKButton);
    Exit;
  end;

  if MessageBox('Copy files to ' + Dest, nil, mfConfirmation +
    mfOKCancel) <> cmOK then Exit;

  C.Init(20);
  TotalSize := 0;
  Mover^.Items^.ForEach(@AddSizes);

  ShowCopyStatusBox(TotalSize);
  Mover^.Items^.ForEach(@CopyFiles);

  C.Done;
  KillStatusBox;

  InvalidateDir(Dest);
end;

function WildCardMatch(const Name, Card: FNameStr): Boolean;
var
  I, J: Integer;
begin
  WildCardMatch := False;
  J := 1;
  I := 1;
  while J <= Length(Card) do
    case Card[J] of
      '*':
        begin
          while (J <= Length(Card)) and (Card[J] <> '.') do Inc(J);
          while (I <= Length(Name)) and (Name[I] <> '.') do Inc(I);
        end;
      '?':
        begin
          Inc(J);
          Inc(I);
        end;
      '.':
        begin
          if I <= Length(Name) then
            if Name[I] <> '.' then
              Exit
            else
              Inc(I);
          Inc(J);
        end;
    else
      if (I > Length(Name)) or (Card[J] <> Name[I]) then Exit;
      Inc(I);
      Inc(J);
    end;
  WildCardMatch := (I > Length(Name)) and (J > Length(Card));
end;

{ TStatusBox }
procedure TStatusBox.HandleEvent(var Event:TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What=evBroadcast) and (Event.Command = cmStatusUpdate) then
    DrawView;
end;


{ TCopier }
procedure TCopier.ReadMsg(const FName: FNameStr; Progress: Longint);
begin
  StatusMsg := RezStrings^.Get(sReading) + FName;
  Message(StatusBox, evBroadcast, cmStatusUpdate, nil);
  Message(StatusBox, evBroadcast, cmAddGauge, Pointer(Progress div 2));
end;

procedure TCopier.WriteMsg(const FName: FNameStr; Progress: Longint);
begin
  StatusMsg := RezStrings^.Get(sWriting) + FName;
  Message(StatusBox, evBroadcast, cmStatusUpdate, nil);
  Message(StatusBox, evBroadcast, cmAddGauge, Pointer(Progress div 2));
end;

function TCopier.IOError(const FName: FNameStr; ECode: Integer) : erAction;
var
  Msg: String;
  D: PDialog;
  R: TRect;
  P: PView;
begin
  Msg := ErrorMsg(ECode);

  R.Assign(0,0,55,7);
  D := New(PDialog, Init(R, FName));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(2,2,52,3);
    Insert(New(PStaticText, Init(R, Msg)));
    R.Assign(20,4,32,6);
    Insert(New(PButton, Init(R, '~R~etry', cmOK, bfDefault)));
    R.Move(14,0);
    Insert(New(PButton, Init(R, '~A~bort', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  if Application^.ExecuteDialog(D, nil) = cmOK then IOError := erRetry
  else IOError := erAbort;
end;

{ TOkListBox }

procedure TOkListBox.SelectItem(Item: Integer);
var
  E: TEvent;
begin
  inherited SelectItem(Item);
  with E do
  begin
    What := evCommand;
    Command := cmOk;
    InfoPtr := nil;
  end;
  PutEvent(E);
end;

end.
