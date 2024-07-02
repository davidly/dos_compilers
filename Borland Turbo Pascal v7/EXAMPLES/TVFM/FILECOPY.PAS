{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+,V-,R-,S-}

unit FileCopy;

interface

uses Objects;

const

  { I/O error constants }
  erWriteOpen  =  -1;  { error opening for Write }
  erReadOpen   =  -2;  { error opening for read  }
  erDiskFull   =  -3;  { error writing to file   }
  erLostFile   =  -4;  { file never finished }
  erNoFile     =  -5;  { file not found }
  erRename     =  -6;  { Unable to rename }
  erResetAFlag =  -7;  { Unable to reset archive flag on original file }

  { Internal error constants }
  erOutOfMemory = -99;  { could not allocate more memory }

  { copy options }
  coNormal     = $0000;   { normal copy }
  coCopyAOnly  = $0001;   { copy file only if Archive bit is set }
  coResetAFlag = $0002;   { reset Archive bit after succesful copy }

type

  erAction = (erAbort, erRetry);

  PFileCopy = ^TFileCopy;
  TFileCopy = object(TObject)
    Incomplete: Boolean;
    IsNewFile: Boolean;
    Offset: Longint;
    Base: Longint;
    FileList: PCollection;
    Result: Integer;
    Action: erAction;

    constructor Init(MaxFiles: Integer);
    destructor Done; virtual;

    { reporting methods }
    procedure ReadMsg(const FName: FNameStr; Progress: Longint); virtual;
    procedure WriteMsg(const FName: FNameStr; Progress: Longint); virtual;
    procedure ReportError(S: String); virtual;

    { copy and support methods }
    function CopyFile(const SourceName, TargetName: FNameStr; Options: Word): Boolean;
    procedure FlushBuffers;
    procedure EraseByName(const FName: FNameStr);

    { error methods }
    function IOError(const FName: FNameStr; ECode:Integer) : erAction; virtual;
    function InternalError(ECode: Integer) : erAction; virtual;
    function ErrorMsg(ECode: Integer) : String; virtual;
  end;


implementation

uses Dos;

const
  fmReadOnly = 0;
  fmReadWrite = 2;
  MaxXFerSize = $F000; { largest block to read from disk }

type
  String10 = String[10];

  { TPtrCollection implements a collection of pointers.  Instead of each  }
  { entry in the collection pointing to a pointer, the entries themselves }
  { are the actual pointers.                                              }

  PPtrCollection = ^TPtrCollection;
  TPtrCollection = object(TCollection)
    function GetItem(var S:TStream) : Pointer; virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    procedure FreeItem(Item:Pointer); virtual;
  end;

  { PFileRec represents a single file that is being processed. }

  PFileRec = ^TFileRec;
  TFileRec = object(TObject)
    Filename: PString;
    OrigName: PString;
    FTime: Longint;
    FSize: Longint;
    Buffers: PPtrCollection;
    Offset: Longint;
    Create: Boolean;
    OptFlags: Word;
    constructor Init(OldName, NewName: FNameStr);
    destructor Done; virtual;
  end;


{ TPtrCollection }

function TPtrCollection.GetItem(var S: TStream): Pointer;
var
  P : Pointer;
begin
  S.Read(P, SizeOf(Pointer));
  GetItem := P;
end;

procedure TPtrCollection.PutItem(var S: TStream; Item: Pointer);
begin
  S.Write(Item, SizeOf(Pointer));
end;

procedure TPtrCollection.FreeItem(Item:Pointer);
begin
  { do nothing }
end;


{ TFileRec }
constructor TFileRec.Init(OldName, NewName: FNameStr);
begin
  inherited Init;
  Filename := NewStr(NewName);
  OrigName := NewStr(OldName);
end;

destructor TFileRec.Done;
begin
  DisposeStr(Filename);
  DisposeStr(OrigName);
  if Buffers <> nil then Dispose(Buffers, Done);
  inherited Done;
end;


{ TFileCopy }
constructor TFileCopy.Init(MaxFiles: Integer);
begin
  inherited Init;
  FileList := New(PCollection, Init(MaxFiles, MaxFiles div 2));
  if Filelist = nil then
  begin
    ReportError(ErrorMsg(erOutOfMemory));
    Fail;
  end;
end;

destructor TFileCopy.Done;
begin
  if FileList^.Count <> 0 then FlushBuffers;
  if FileList <> nil then Dispose(FileList, Done);
  inherited Done;
end;

function TFileCopy.IOError(const FName: FNameStr; ECode: Integer): erAction;
begin
  ReportError(ErrorMsg(ECode));
  IOError := erAbort;
end;

function TFileCopy.InternalError(ECode: Integer): erAction;
begin
  ReportError(ErrorMsg(ECode));
  InternalError := erAbort;
end;

procedure TFileCopy.EraseByName(const FName: FNameStr);
var
  F: File;
  I: Integer;
begin
  Assign(F, FName);
  {$I-}
  Reset(F);
  {$I+}
  if IOResult = 0 then Erase(F);
  I := IOResult;   { read this so we don't leave any unused value there }
end;

procedure TFileCopy.FlushBuffers;
var
  Leave : Integer;

procedure FlushFile(CurFile: PFileRec); far;
var
  BufAddr: Pointer;
  BytesToXFer: Word;
  BytesRead: Word;
  TargetFile: File;
  RemainingBytes: Longint;
  Attr: Word;
begin
  FileMode := fmReadWrite;

  Action := erRetry;
  Result := 1;
  while (Action <> erAbort) and (Result <> 0) do
  begin
    Assign(TargetFile, CurFile^.FileName^);
    {$I-}
    if CurFile^.Create then Rewrite(TargetFile, 1)
    else Reset(TargetFile, 1);
    {$I+}
    Result := IOResult;
    if Result <> 0 then
    begin
      Action := IOError(CurFile^.FileName^, erWriteOpen);
      if Action = erAbort then Exit;
    end;
  end;

  Seek(TargetFile, CurFile^.Offset);

  if (FileList^.IndexOf(CurFile) = FileList^.Count-1) and Incomplete
    then Inc(Offset, CurFile^.FSize);

  RemainingBytes := CurFile^.FSize;

  repeat
    if RemainingBytes > MaxXFerSize then BytesToXFer := MaxXFerSize
    else BytesToXFer := RemainingBytes;
    BufAddr := CurFile^.Buffers^.At(0);  { get first address }
    BlockWrite(TargetFile, BufAddr^, BytesToXFer, BytesRead);
    WriteMsg(CurFile^.Filename^, BytesRead);
    Dec(RemainingBytes, BytesRead);
    FreeMem(BufAddr, BytesToXFer);
    CurFile^.Buffers^.AtDelete(0);
  until RemainingBytes = 0;

  if not Incomplete then SetFTime(TargetFile, CurFile^.FTime);
  Close(TargetFile);

  if ((FileList^.IndexOf(CurFile) <> FileList^.Count-1) or
    (not Incomplete)) then
  begin
    if CurFile^.OptFlags and coResetAFlag <> 0 then
    begin
      Assign(TargetFile, CurFile^.OrigName^);
      GetFAttr(TargetFile, Attr);
      Attr := Attr and (not Archive);
      SetFAttr(TargetFile, Attr);
      if DosError <> 0 then IOError(CurFile^.OrigName^, erResetAFlag);
    end;
  end;
end;

begin
  FileList^.ForEach(@FlushFile);
  if Incomplete then Leave := 1 else Leave := 0;
  while FileList^.Count <> Leave do
    FileList^.AtFree(0);
end;

function TFileCopy.CopyFile(const SourceName, TargetName: FNameStr;
  Options: Word): Boolean;
const
  Safety = 4096;
var
  Flush: Boolean;
  SourceFile: File;
  TargetFile: File;
  CurFile: PFileRec;
  RemainingBytes: Longint;
  BytesToXFer: Word;
  DidXFer: Word;
  BufAddr: Pointer;
  CurMaxAvail: Longint;
  SRec: SearchRec;
begin
  CopyFile := False;

  { validate the coCopyAOnly flag }
  if Options and coCopyAOnly <> 0 then
  begin
    FindFirst(SourceName, AnyFile, SRec);
    if (DosError = 0) and ((SRec.Attr and Archive) = 0) then Exit
    else IOError(SourceName, erNoFile);
  end;

  CurFile := New(PFileRec, Init(SourceName, TargetName));
  CurFile^.Buffers := New(PPtrCollection, Init(5,2));
  if (CurFile = nil) or (CurFile^.Buffers = nil) then
  begin
    InternalError(erOutOfMemory);
    Exit;
  end;
  CurFile^.OptFlags := Options;
  CurFile^.Offset := 0;
  CurFile^.Create := True;
  FileList^.Insert(CurFile);

  Offset := 0;
  Incomplete := False;
  IsNewFile := False;
  Base := 0;

  repeat
    Flush := False;

    FileMode := fmReadOnly;
    Assign(SourceFile, SourceName);

    Action := erRetry;
    Result := 1;
    while (Action <> erAbort) and (Result <> 0) do
    begin
      {$I-}
      Reset(SourceFile,1);
      {$I+}
      Result := IOResult;
      if Result <> 0 then
      begin
        if IOError(SourceName, erReadOpen) = erAbort then
        begin
          FileList^.Free(CurFile);
          Exit;
        end;
      end;
    end;

    if Incomplete then
    begin
      Seek(SourceFile, Offset-Base);
      CurFile^.Offset := Offset;
      if Incomplete then CurFile^.Create := False;
    end;

    Incomplete := False;

    CurFile^.FSize := FileSize(SourceFile) - Offset + Base;
    CurMaxAvail := MaxAvail - Safety;

    if CurFile^.FSize > CurMaxAvail then
    begin
      CurFile^.FSize := CurMaxAvail;
      Flush := True;
      Incomplete := True;
      CurFile^.Offset := Offset;
    end;
    RemainingBytes := CurFile^.FSize;

    repeat
      if RemainingBytes > MaxXFerSize then BytesToXFer := MaxXFerSize
      else BytesToXFer := RemainingBytes;
      GetMem(BufAddr, BytesToXFer);
      CurFile^.Buffers^.Insert(BufAddr);
      BlockRead(SourceFile, BufAddr^, BytesToXFer, DidXFer);
      ReadMsg(SourceName, DidXFer);
      Dec(RemainingBytes, DidXFer);
    until RemainingBytes = 0;

    GetFTime(SourceFile, CurFile^.FTime);
    Close(SourceFile);

    if Flush then FlushBuffers;

  until not Incomplete;
  CopyFile := True;
end;

procedure TFileCopy.ReadMsg(const FName: FNameStr; Progress: Longint);
begin
  Writeln('Reading ', FName);
end;

procedure TFileCopy.WriteMsg(const FName: FNameStr; Progress: Longint);
begin
  Writeln('Writing ', FName);
end;

procedure TFileCopy.ReportError(S: String);
begin
  Writeln(S);
end;

function TFileCopy.ErrorMsg(ECode: Integer): String;
begin
  case ECode of
    erWriteOpen   : ErrorMsg := 'Unable to open for write access';
    erReadOpen    : ErrorMsg := 'Unable to open for read access';
    erDiskFull    : ErrorMsg := 'Unable to write to file.  Disk full?';
    erLostFile    : ErrorMsg := 'File never flushed from buffers';
    erNoFile      : ErrorMsg := 'File not found.';
    erRename      : ErrorMsg := 'Unable to rename to final name.';
    erOutOfMemory : ErrorMsg := 'Unable to allocate memory.';
    else ErrorMsg := 'Unknown error.';
  end; { case }
end;

end.
