{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+,V-}

unit Globals;

interface

uses Objects, Drivers, App, Views, Menus, Dialogs, Dos, DragDrop;

type

  TConfigRec = record
    FileMask: string[12];
    ShowHidden: Word;
    SortField: Word;
    SortDir: Word;
    DisplayCase: Word;
    DisplayFields: Word;
    Video: Word;
  end;

{ Event.InfoPtr points to a TScanInfo record if the when cmScanComplete
  is broadcast }

  PScanInfo = ^TScanInfo;
  TScanInfo = record
    ScanCount: LongInt;
    ScanBytes: LongInt;
  end;

  PTextCollection = ^TTextCollection;
  TTextCollection = object(TCollection)
    procedure FreeItem(Item: pointer); virtual;
  end;

  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

  { THCStatusLine is a help context sensitive status line }

  PHCStatusLine = ^THCStatusLine;
  THCStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;

  { record used to identify a file by name only }
  PFileNameRec = ^TFileNameRec;
  TFileNameRec = record
    Dir: DirStr;
    Name: NameStr;
    Ext: ExtStr;
  end;

  { represents a single file in a file list }
  PFileRec = ^TFileRec;
  TFileRec = object(TObject)
    Tagged: Boolean;
    Name: NameStr;
    Ext: ExtStr;
    Attr: Byte;
    Size: Longint;
    Time: Longint;
    constructor Init(const S: SearchRec);
    procedure Toggle;
  end;

  { moving view while files are being dragged }
  PFileMover = ^TFileMover;
  TFileMover = object(TMover)
    procedure Draw; virtual;
  end;

  { sorted collection that sorts according to the ConfigRec settings. }
  PFileList = ^TFileList;
  TFileList = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure ReOrder;
  end;

  TSortFunc = function(P1, P2: PFileRec): Integer;

  { dialog to handle file renaming }
  PRenameDialog = ^TRenameDialog;
  TRenameDialog = object(TDialog)
    TheName: PathStr;
    NewName: PathStr;
    constructor Init(const FileName:PathStr);
    function Valid(Command: Word): Boolean; virtual;
  end;

  { dialog to handle changing file attributes }
  PAttrDialog = ^TAttrDialog;
  TAttrDialog = object(TDialog)
    TheName: PathStr;
    NewAttr: Word;
    constructor Init(const FileName:PathStr);
    function Valid(Command: Word): Boolean; virtual;
  end;

  { TDeviceRec holds a single redirected device (net drives) }
  PDeviceRec = ^TDeviceRec;
  TDeviceRec = record
    LocalName: Char;
    NetworkName: PString;
  end;

  { TDeviceCollection is a collection of TDeviceRecs }
  PDeviceCollection = ^TDeviceCollection;
  TDeviceCollection = object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
  end;

procedure RegisterGlobals;
function WaitDialog(const Msg: String) : PDialog;

var
  RezFile: TResourceFile;
  RezStream: PStream;
  RezStrings: PStringList;

const

  ConfigRec: TConfigRec =
    (FileMask:'*.*'; ShowHidden:$00; SortField:$00; SortDir:$00;
     DisplayCase:$00; DisplayFields:$FF; Video:0);

  ConfirmDelete: Boolean = True;
  Viewer: PathStr = '';

  EXEName = 'TVFM.EXE';
  CFGExt  = '.CFG';
  TagChar = #251;

  UnwantedFiles: Word = VolumeID or Directory or SysFile or Hidden;

implementation

uses MsgBox, FileCopy, Equ;

const
  RHCStatusLine : TStreamRec = (
    ObjType : 100;
    VmtLink : Ofs(TypeOf(THCStatusLine)^);
    Load    : @THCStatusLine.Load;
    Store   : @THCStatusLine.Store
  );


{ ----------- General Purpose Routines -------------------- }

procedure RegisterGlobals;
begin
  RegisterType(RHCStatusLine);
end;

function WaitDialog(const Msg: String) : PDialog;
var
  R: TRect;
  D: PDialog;
  Width: Integer;
  XPos: Integer;
begin
  if Length(Msg) > 40 then Width := Length(Msg) + 4
  else Width := 40;
  XPos := (Width div 2) - (Length(Msg) div 2) - 1;

  R.Assign(0, 0, Width, 7);
  D := New(PDialog, Init(R, RezStrings^.Get(sPleaseWait)));
  with D^ do
  begin
    Options := Options or ofCentered;
    Flags := Flags and (not wfClose) and (not wfMove);
    R.Assign(XPos, 3, XPos+Length(Msg)+1, 4);
    Insert(New(PStaticText,Init(R, Msg)));
  end;
  WaitDialog := D;
end;

{ TTextCollection }
procedure TTextCollection.FreeItem(Item: pointer);
begin
  DisposeStr(Item);
end;


{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  Writeln('Error in stream: Code = ', Code, ' Info = ', Info);
  Halt(1);
end;


{ THCStatusLine }

function THCStatusLine.Hint(AHelpCtx: Word) :String;
begin
  Hint := RezStrings^.Get(AHelpCtx);
end;

{ TFileRec }

constructor TFileRec.Init(const S: SearchRec);
var
  T: PathStr;
begin
  inherited Init;
  Tagged := False;
  FSplit(S.Name, T, Name, Ext);

  { fix up directory names without extensions }
  if (S.Attr and Directory <> 0) and (Name = '') then
  begin
    Name := Ext;
    Ext := '';
  end;
  Attr := S.Attr;
  Size := S.Size;
  Time := S.Time;
end;

procedure TFileRec.Toggle;
begin
  Tagged := not Tagged;
end;


{ Sort functions for TFileList }

function SortByName(P1, P2: PFileRec): Integer; far;
begin
  if P1^.Name < P2^.Name then SortByName := -1
  else if P1^.Name > P2^.Name then SortByName := 1
  else SortByName := 0;
end;

function SortByExt(P1, P2: PFileRec): Integer; far;
begin
  if P1^.Ext < P2^.Ext then SortByExt := -1
  else if P1^.Ext > P2^.Ext then SortByExt := 1
  else SortByExt := 0;
end;

function SortBySize(P1, P2: PFileRec): Integer; far;
begin
  if P1^.Size < P2^.Size then SortBySize := -1
  else if P1^.Size > P2^.Size then SortBySize := 1
  else SortBySize := 0;
end;

function SortByTime(P1, P2: PFileRec): Integer; far;
begin
  if P1^.Time < P2^.Time then SortByTime := -1
  else if P1^.Time > P2^.Time then SortByTime := 1
  else SortByTime := 0;
end;

{ TFileMover }
procedure TFileMover.Draw;
var
  B: TDrawBuffer;
  C: Word;
  F: PFileRec;
begin
  C := GetColor(1);
  { always draw at least the first entry in the collection }
  F := Items^.At(0);
  MoveChar(B, #32, C, Size.X);
  MoveStr(B, F^.Name + F^.Ext, C);
  WriteLine(0,0,Size.X,1,B);

  if Items^.Count > 1 then
  begin
    F := Items^.At(Items^.Count - 1);          { last item in list }
    MoveChar(B, #32, C, Size.X);
    MoveStr(B, F^.Name + F^.Ext, C);
    if Items^.Count > 2 then
    begin
      WriteLine(0,2,Size.X,1,B);
      if Items^.Count = 3 then
      begin
        F := Items^.At(1);
        MoveChar(B, #32, C, Size.X);
        MoveStr(B, F^.Name + F^.Ext, C);
      end
      else
      begin
        MoveChar(B, #32, C, Size.X);
        MoveChar(B[4], #250, C, 4);
      end;
      WriteLine(0,1,Size.X,1,B);
    end
    else
      WriteLine(0,1,Size.X,1,B);
  end;
end;

{ TFileList }

function TFileList.Compare(Key1, Key2: Pointer): Integer;
const
  Sorts : array[0..3] of TSortFunc =
   (SortByName, SortByExt, SortBySize, SortByTime);
var
  Result: Integer;
  I: Integer;
begin

  if Key2 = nil then
  begin
    Compare := 0;
    Exit;
  end;

  Result := Sorts[ConfigRec.SortField](Key1, Key2);
  I := 0;
  while (Result = 0) and (I <= 3) do
  begin
    Result := Sorts[I](Key1, Key2);
    Inc(I);
  end;

  { if the sort is descending, then reverse the Result variable }
  if (ConfigRec.SortDir <> 0) and (Result <> 0) then
    Result := Result * -1;

  Compare := Result;
end;

procedure TFileList.ReOrder;

procedure Sort(l, r: Integer);
var
  i, j: Integer;
  x, p: Pointer;
begin
  repeat
    i := l; j := r;
    x := KeyOf(Items^[(l + r) div 2]);
    repeat
      while Compare(KeyOf(Items^[i]), x) = -1 do Inc(i);
      while Compare(x, KeyOf(Items^[j])) = -1 do Dec(j);
      if i <= j then
      begin
	if i < j then
	begin
	  p := Items^[i];
	  Items^[i] := Items^[j];
	  Items^[j] := p;
	end;
	Inc(i); Dec(j);
      end;
    until i > j;
    if l < j then Sort(l, j);
    l := i;
  until l >= r;
end;

begin
  if Count > 1 then Sort(0, Count - 1);
end;


{ TRenameDialog }
constructor TRenameDialog.Init(const FileName: PathStr);
var
  R: TRect;
  P: PView;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  R.Assign(0,0,40,7);
  inherited Init(R, 'Rename File');
  Options := Options or ofCentered;

  TheName := FileName;
  FSplit(TheName, D, N, E);
  D := N + E;
  R.Assign(2,2,18,3);
  Insert(New(PLabel, Init(R, '~' + D + '~ to ', nil)));
  R.Assign(19,2,33,3);
  Insert(New(PInputLine, Init(R, 12)));
  R.Assign(4,4,16,6);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Move(16,0);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  SelectNext(False);
  D := '';
  SetData(D);
end;

function TRenameDialog.Valid(Command: Word): Boolean;
var
  L: Longint;
  TheFile: File;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  I: Integer;
begin
  Valid := True;
  if (Command = cmCancel) or (Command = cmValid) then Exit;
  GetData(NewName);
  for I:= 1 to Length(NewName) do NewName[I] := UpCase(NewName[I]);
  FSplit(TheName, D, N, E);

  { check for duplicate name }
  if D + NewName = TheName then
  begin
    MessageBox(RezStrings^.Get(sSameNameErr), nil, mfError+mfOKButton);
    Valid := False;
    Exit;
  end;
  Assign(TheFile, TheName);
  {$I-}
  Rename(TheFile, D + NewName);
  {$I+}
  L := IOResult;
  if L <> 0 then
  begin
    MessageBox(RezStrings^.Get(sRenameErr), @L, mfError+mfOKButton);
    Valid := False;
  end;
end;

{ TAttrDialog }
constructor TAttrDialog.Init(const FileName:PathStr);
var
  R: TRect;
  P: PView;
  Attr: Word;
  XFer: Word;
  TheFile: File;
begin
  R.Assign(0,0,40,12);
  inherited Init(R, 'Change Attributes');
  Options := Options or ofCentered;

  TheName := FileName;
  Assign(TheFile, TheName);
  GetFAttr(TheFile, Attr);
  if DosError <> 0 then Fail;

  R.Assign(0,2,Length(FileName),3);
  P:=New(PStaticText, Init(R, FileName));
  P^.Options := P^.Options or ofCenterX;
  Insert(P);
  R.Assign(0,4,15,8);
  P := New(PCheckBoxes, Init(R, NewSItem('~A~rchive',
                                NewSItem('~R~ead-Only',
                                NewSItem('~S~ystem',
                                NewSItem('~H~idden',
                                nil))))));
  P^.Options := P^.Options or ofCenterX;
  Insert(P);
  R.Assign(4,9,16,11);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Move(16,0);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  SelectNext(False);
  XFer := 0;
  if Attr and Archive <> 0 then XFer := $01;
  if Attr and ReadOnly <> 0 then XFer := XFer or $02;
  if Attr and SysFile <> 0 then XFer := XFer or $04;
  if Attr and Hidden <> 0 then XFer := XFer or $08;
  SetData(XFer);
end;

function TAttrDialog.Valid(Command: Word): Boolean;
var
  XFer : Word;
  L: array[0..1] of Longint;
  TheFile: File;
begin
  Valid := True;
  if (Command = cmCancel) or (Command = cmValid) then Exit;
  GetData(XFer);
  NewAttr := 0;
  if XFer and $01 <> 0 then NewAttr := Archive;
  if XFer and $02 <> 0 then NewAttr := NewAttr or ReadOnly;
  if XFer and $04 <> 0 then NewAttr := NewAttr or SysFile;
  if XFer and $08 <> 0 then NewAttr := NewAttr or Hidden;
  Assign(TheFile, TheName);
  SetFAttr(TheFile, NewAttr);
  if DosError <> 0 then
  begin
    L[0] := DosError;
    L[1] := Longint(@TheName);
    MessageBox(RezStrings^.Get(sSetAttrErr), @L, mfError+mfOKButton);
    Valid := False;
  end;
end;

{ TDeviceCollection }
procedure TDeviceCollection.FreeItem(Item: Pointer);
var
  DeviceRec : PDeviceRec absolute Item;
begin
  DisposeStr(DeviceRec^.NetworkName);
  Dispose(DeviceRec);
end;


end. { unit }
