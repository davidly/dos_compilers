{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+}

unit DirView; { directory pane }

interface

uses Drivers, Objects, Views, Outline, Dos;

type
  PDirectory = ^TDirectory;
  TDirectory = object(TObject)
    Dir: PString;
    SubDirectories: Boolean;
    Children: PDirectory;
    Next: PDirectory;
    constructor Init(const ADir: String);
    destructor Done; virtual;
    procedure Adjust(Expand: Boolean);
    function Expanded: Boolean;
    function GetSubdirectory(I: Integer): PDirectory;
    function GetName: String;
    function GetNumSubdirectories: Integer;
  end;

type
  PDirectoryViewer = ^TDirectoryViewer;
  TDirectoryViewer = object(TOutlineViewer)
    SearchPos, OldFoc: Integer;
    Root: PDirectory;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      ARoot: PDirectory);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Adjust(Node: Pointer; Expand: Boolean); virtual;
    function GetRoot: Pointer; virtual;
    function GetNumChildren(Node: Pointer): Integer; virtual;
    function GetChild(Node: Pointer; I: Integer): Pointer; virtual;
    function GetText(Node: Pointer): String; virtual;
    function IsExpanded(Node: Pointer): Boolean; virtual;
    function HasChildren(Node: Pointer): Boolean; virtual;
    function GetPalette: PPalette; virtual;
  end;

implementation

uses App, Equ, Globals, Tools;

const
  CDirectoryViewer = CScroller + #3#8;

{ TDirectory }

constructor TDirectory.Init(const ADir: String);
var
  SR: SearchRec;
begin
  inherited Init;
  Dir := NewStr(ADir);
  Next := nil;
  Children := nil;

  { See if any subdirectories exist in given directory }
  FindFirst(Dir^ + '\*.*', Directory, SR);
  while DosError = 0 do
  begin
    if (SR.Attr and Directory <> 0) and (SR.Name[1] <> '.') then
    begin
      SubDirectories := True;
      Exit;
    end;
    FindNext(SR);
  end;
  SubDirectories := False;
end;

destructor TDirectory.Done;
begin
  if Children <> nil then Dispose(Children, Done);
  if Next <> nil then Dispose(Next, Done);
  DisposeStr(Dir);
  inherited Done;
end;

procedure TDirectory.Adjust(Expand: Boolean);
var
  SR: SearchRec;
  PCur: ^PDirectory;
begin
  if Expand then
  begin
    PCur := @Children;
    FindFirst(Dir^ + '\*.*', Directory, SR);
    while DosError = 0 do
    begin
      if (SR.Attr and Directory <> 0) and (SR.Name[1] <> '.') then
      begin
        PCur^ := New(PDirectory, Init(Dir^ + '\' + SR.Name));
        PCur := @PCur^^.Next;
      end;
      FindNext(SR);
    end;
    PCur^ := nil;
  end
  else
  begin
    if Children <> nil then Dispose(Children, Done);
    Children := nil;
  end;
end;

function TDirectory.GetNumSubdirectories: Integer;
var
  I: Integer;
  Cur: PDirectory;
begin
  I := 0;
  Cur := Children;
  while Cur <> nil do
  begin
    Cur := Cur^.Next;
    Inc(I);
  end;
  GetNumSubdirectories := I;
end;

function TDirectory.GetSubdirectory(I: Integer): PDirectory;
var
  Cur: PDirectory;
begin
  Cur := Children;
  while (Cur <> nil) and (I <> 0) do
  begin
    Cur := Cur^.Next;
    Dec(I);
  end;
  GetSubdirectory := Cur;
end;

function TDirectory.GetName: String;
var
  ADir: DirStr;
  AName: NameStr;
  AExt: ExtStr;
begin
  FSplit(Dir^, ADir, AName, AExt);
  if (AName = '') and (AExt = '') then GetName := ADir
  else GetName := AName + AExt;
end;

function TDirectory.Expanded: Boolean;
begin
  Expanded := Children <> nil;
end;

{ TDirectoryViewer }

constructor TDirectoryViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; ARoot: PDirectory);
begin
  inherited Init(Bounds, AHScrollBar, AVScrollBar);
  Root := ARoot;
  Update;
  SearchPos := 0;
  OldFoc := 0;
  SetCursor(0, 0);
  ShowCursor;
end;

destructor TDirectoryViewer.Done;
begin
  Dispose(Root, Done);
  inherited Done;
end;

procedure TDirectoryViewer.HandleEvent(var Event: TEvent);
var
  SearchStr: String;
  Lev, Pos: Integer;
  Lns: LongInt;
  Flgs: Word;
  Dir: PDirectory;
  Mover: PFileMover;
  Where: TPoint;

  function UpStr(S: String): String;
  var
    I: Integer;
  begin
    for I := 1 to Length(S) do
      S[I] := UpCase(S[I]);
    UpStr := S;
  end;

  function IsAMatch(Cur: Pointer; Level, Position: Integer;
    Lines: LongInt; Flags: Word): Boolean; far;
  var
    S: String;
  begin
    IsAMatch := False;
    if UpStr(Copy(GetText(Cur),1, Length(SearchStr))) = SearchStr then
    begin
      IsAMatch := True;
      Pos := Position;
      Lev := Level;
      Lns := Lines;
      Flgs := Flags;
    end;
  end;

  function GetGraphParams(Cur: Pointer; Level, Position: Integer;
    Lines: LongInt; Flags: Word): Boolean; far;
  begin
    GetGraphParams := False;
    if Position = Foc then
    begin
      Lev := Level;
      Lns := Lines;
      Flgs := Flags;
      GetGraphParams := True;
    end;
  end;

begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
  begin
    case Event.Command of
      cmGetCurrentDir:
        begin
          Dir := GetNode(Foc);
          PString(Event.InfoPtr)^ := Dir^.Dir^;
          ClearEvent(Event);
        end;
      cmItemDropped: 
        begin
          Mover := Event.InfoPtr;
          if MouseInView(Mover^.Origin) then
          begin
            ClearEvent(Event);
            MakeLocal(Mover^.Origin, Where);
            Dir := GetNode(Where.Y + 1 + Delta.Y);
            DragDropCopy(Mover, Dir^.Dir^);
          end;
        end;
      else
        Exit;
    end;
  end;

  if (Event.What <> evBroadcast) and (Foc <> OldFoc) then
    SearchPos := 0;
  Pos := -1;
  case Event.What of
    evKeyDown:
      begin
        if (Event.KeyCode = kbBack) or
	  ((Event.ScanCode <> 0) and
	   (Event.CharCode in ['A'..'Z','a'..'z', '0'..'9'])) then
        begin
          if SearchPos > 0 then
          begin
            SearchStr := UpStr(GetText(GetNode(Foc)));
            SearchStr[0] := Char(SearchPos);
          end else SearchStr := '';
          if Event.KeyCode = kbBack then
          begin
            if Length(SearchStr) > 0 then Dec(SearchStr[0])
            else Exit;
          end
          else if Length(SearchStr) < 255 then
          begin
            Inc(SearchStr[0]);
            SearchStr[Length(SearchStr)] := UpCase(Event.CharCode);
          end;
          if FirstThat(@IsAMatch) <> nil then
          begin
            Focused(Pos);
            SearchPos := Length(SearchStr);
            Update;
            DrawView;
          end else Pos := -1;
          ClearEvent(Event);
        end;
        if Event.CharCode = '\' then
        begin
          Dir := PDirectory(GetNode(Foc));
          if (not Dir^.Expanded) and HasChildren(Dir) then
          begin
            Dir^.Adjust(True);
            Update;
            DrawView;
            ClearEvent(Event);
          end;
        end;
      end;
  end;
  if (Foc <> OldFoc) or (Pos <> -1) then
  begin
    if Pos = -1 then
      FirstThat(@GetGraphParams);
    SetCursor(Length(GetGraph(Lev, Lns, Flgs)) + SearchPos,
      Foc - Delta.Y);
    Dir := GetNode(Foc);
    Message(Desktop, evBroadcast, cmNewDir, Dir^.Dir);
    OldFoc := Foc;
  end;
end;


procedure TDirectoryViewer.Adjust(Node: Pointer; Expand: Boolean);
begin
  PDirectory(Node)^.Adjust(Expand);
end;

function TDirectoryViewer.GetRoot: Pointer;
begin
  GetRoot := Root;
end;

function TDirectoryViewer.GetNumChildren(Node: Pointer): Integer;
begin
  GetNumChildren := PDirectory(Node)^.GetNumSubDirectories;
end;

function TDirectoryViewer.GetChild(Node: Pointer; I: Integer): Pointer;
begin
  GetChild := PDirectory(Node)^.GetSubdirectory(I);
end;

function TDirectoryViewer.GetText(Node: Pointer): String;
begin
  GetText := PDirectory(Node)^.GetName;
end;

function TDirectoryViewer.IsExpanded(Node: Pointer): Boolean;
begin
  IsExpanded := PDirectory(Node)^.Expanded;
end;

function TDirectoryViewer.HasChildren(Node: Pointer): Boolean;
begin
  HasChildren := PDirectory(Node)^.SubDirectories;
end;

function TDirectoryViewer.GetPalette: PPalette;
const
  NewPal: string[Length(CDirectoryViewer)] = CDirectoryViewer;
begin
  GetPalette := @NewPal;
end;

end.
