{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit HelpFile;

{$F+,O+,X+,S-,D-}

interface

uses Objects, Drivers, Views;

const
  CHelpColor      = #$37#$3F#$3A#$13#$13#$30#$3E#$1E;
  CHelpBlackWhite = #$07#$0F#$07#$70#$70#$07#$0F#$70;
  CHelpMonochrome = #$07#$0F#$07#$70#$70#$07#$0F#$70;
  CHelpViewer     = #6#7#8;
  CHelpWindow     = #64#65#66#67#68#69#70#71;

type

{ TParagraph }

  PParagraph = ^TParagraph;
  TParagraph = record
    Next: PParagraph;
    Wrap: Boolean;
    Size: Word;
    Text: record end;
  end;

{ THelpTopic }

  TCrossRef = record
    Ref: Integer;
    Offset: Integer;
    Length: Byte;
  end;

  PCrossRefs = ^TCrossRefs;
  TCrossRefs = array[1..10000] of TCrossRef;
  TCrossRefHandler = procedure (var S: TStream; XRefValue: Integer);

  PHelpTopic = ^THelpTopic;
  THelpTopic = object(TObject)
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure AddCrossRef(Ref: TCrossRef);
    procedure AddParagraph(P: PParagraph);
    procedure GetCrossRef(I: Integer; var Loc: TPoint; var Length: Byte;
      var Ref: Integer);
    function GetLine(Line: Integer): String;
    function GetNumCrossRefs: Integer;
    function NumLines: Integer;
    procedure SetCrossRef(I: Integer; var Ref: TCrossRef);
    procedure SetNumCrossRefs(I: Integer);
    procedure SetWidth(AWidth: Integer);
    procedure Store(var S: TStream);
  private
    Paragraphs: PParagraph;
    NumRefs: Integer;
    CrossRefs: PCrossRefs;
    Width: Integer;
    LastOffset: Integer;
    LastLine: Integer;
    LastParagraph: PParagraph;
    function WrapText(var Text; Size: Integer; var Offset: Integer;
      Wrap: Boolean): String;
  end;

{ THelpIndex }

  PIndexArray = ^TIndexArray;
  TIndexArray = array[0..16380] of LongInt;

  PHelpIndex = ^THelpIndex;
  THelpIndex = object(TObject)
    Size: Word;
    Index: PIndexArray;
    constructor Init;
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function Position(I: Integer): Longint;
    procedure Add(I: Integer; Val: Longint);
    procedure Store(var S: TStream);
  end;

{ THelpFile }

  PHelpFile = ^THelpFile;
  THelpFile = object(TObject)
    Stream: PStream;
    Modified: Boolean;
    constructor Init(S: PStream);
    destructor Done; virtual;
    function GetTopic(I: Integer): PHelpTopic;
    function InvalidTopic: PHelpTopic;
    procedure RecordPositionInIndex(I: Integer);
    procedure PutTopic(Topic: PHelpTopic);
  private
    Index: PHelpIndex;
    IndexPos: LongInt;
  end;

{ THelpViewer }

  PHelpViewer = ^THelpViewer;
  THelpViewer = object(TScroller)
    HFile: PHelpFile;
    Topic: PHelpTopic;
    Selected: Integer;
    constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PScrollBar; AHelpFile: PHelpFile; Context: Word);
    destructor Done; virtual;
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

{ THelpWindow }

  PHelpWindow = ^THelpWindow;
  THelpWindow = object(TWindow)
    constructor Init(HFile: PHelpFile; Context: Word);
    function GetPalette: PPalette; virtual;
  end;

const

  RHelpTopic: TStreamRec = (
     ObjType: 10000;
     VmtLink: Ofs(TypeOf(THelpTopic)^);
     Load:    @THelpTopic.Load;
     Store:   @THelpTopic.Store
  );
  RHelpIndex: TStreamRec = (
     ObjType: 10001;
     VmtLink: Ofs(TypeOf(THelpIndex)^);
     Load:    @THelpIndex.Load;
     Store:   @THelpIndex.Store
  );

procedure RegisterHelpFile;

procedure NotAssigned(var S: TStream; Value: Integer);

const
  CrossRefHandler: TCrossRefHandler = NotAssigned;

implementation

{ THelpTopic }

constructor THelpTopic.Init;
begin
  TObject.Init;
  LastLine := MaxInt;
end;

constructor THelpTopic.Load(var S: TStream);

procedure ReadParagraphs;
var
  I, Size: Integer;
  PP: ^PParagraph;
begin
  S.Read(I, SizeOf(I));
  PP := @Paragraphs;
  while I > 0 do
  begin
    S.Read(Size, SizeOf(Size));
    GetMem(PP^, SizeOf(PP^^) + Size);
    PP^^.Size := Size;
    S.Read(PP^^.Wrap, SizeOf(Boolean));
    S.Read(PP^^.Text, Size);
    PP := @PP^^.Next;
    Dec(I);
  end;
  PP^ := nil;
end;

procedure ReadCrossRefs;
begin
  S.Read(NumRefs, SizeOf(Integer));
  GetMem(CrossRefs, SizeOf(TCrossRef) * NumRefs);
  S.Read(CrossRefs^, SizeOf(TCrossRef) * NumRefs);
end;

begin
  ReadParagraphs;
  ReadCrossRefs;
  Width := 0;
  LastLine := MaxInt;
end;

destructor THelpTopic.Done;

procedure DisposeParagraphs;
var
  P, T: PParagraph;
begin
  P := Paragraphs;
  while P <> nil do
  begin
    T := P;
    P := P^.Next;
    FreeMem(T, SizeOf(T^) + T^.Size);
  end;
end;

begin
  DisposeParagraphs;
  FreeMem(CrossRefs, SizeOf(TCrossRef) * NumRefs);
  TObject.Done
end;

procedure THelpTopic.AddCrossRef(Ref: TCrossRef);
var
  P: PCrossRefs;
begin
  GetMem(P, (NumRefs+1) * SizeOf(TCrossRef));
  if NumRefs > 0 then
  begin
    Move(CrossRefs^, P^, NumRefs * SizeOf(TCrossRef));
    FreeMem(CrossRefs, NumRefs * SizeOf(TCrossRef));
  end;
  CrossRefs^[NumRefs] := Ref;
  Inc(NumRefs);
end;

procedure THelpTopic.AddParagraph(P: PParagraph);
var
  PP: ^PParagraph;
begin
  PP := @Paragraphs;
  while PP^ <> nil do
    PP := @PP^^.Next;
  PP^ := P;
  P^.Next := nil;
end;

procedure THelpTopic.GetCrossRef(I: Integer; var Loc: TPoint;
  var Length: Byte; var Ref: Integer);
var
  OldOffset, CurOffset, Offset, ParaOffset: Integer;
  P: PParagraph;
  Line: Integer;
begin
  ParaOffset := 0;
  CurOffset := 0;
  OldOffset := 0;
  Line := 0;
  Offset := CrossRefs^[I].Offset;
  P := Paragraphs;
  while ParaOffset+CurOffset < Offset do
  begin
    OldOffset := ParaOffset + CurOffset;
    WrapText(P^.Text, P^.Size, CurOffset, P^.Wrap);
    Inc(Line);
    if CurOffset >= P^.Size then
    begin
      Inc(ParaOffset, P^.Size);
      P := P^.Next;
      CurOffset := 0;
    end;
  end;
  Loc.X := Offset - OldOffset - 1;
  Loc.Y := Line;
  Length := CrossRefs^[I].Length;
  Ref := CrossRefs^[I].Ref;
end;

function THelpTopic.GetLine(Line: Integer): String;
var
  Offset, I: Integer;
  P: PParagraph;
begin
  if LastLine < Line then
  begin
    I := Line;
    Dec(Line, LastLine);
    LastLine := I;
    Offset := LastOffset;
    P := LastParagraph;
  end
  else
  begin
    P := Paragraphs;
    Offset := 0;
    LastLine := Line;
  end;
  GetLine := '';
  while (P <> nil) do
  begin
    while Offset < P^.Size do
    begin
      Dec(Line);
      GetLine := WrapText(P^.Text, P^.Size, Offset, P^.Wrap);
      if Line = 0 then
      begin
        LastOffset := Offset;
        LastParagraph := P;
        Exit;
      end;
    end;
    P := P^.Next;
    Offset := 0;
  end;
  GetLine := '';
end;

function THelpTopic.GetNumCrossRefs: Integer;
begin
  GetNumCrossRefs := NumRefs;
end;

function THelpTopic.NumLines: Integer;
var
  Offset, Lines: Integer;
  P: PParagraph;
begin
  Offset := 0;
  Lines := 0;
  P := Paragraphs;
  while P <> nil do
  begin
    Offset := 0;
    while Offset < P^.Size do
    begin
      Inc(Lines);
      WrapText(P^.Text, P^.Size, Offset, P^.Wrap);
    end;
    P := P^.Next;
  end;
  NumLines := Lines;
end;

procedure THelpTopic.SetCrossRef(I: Integer; var Ref: TCrossRef);
begin
  if I <= NumRefs then CrossRefs^[I] := Ref;
end;

procedure THelpTopic.SetNumCrossRefs(I: Integer);
var
  P: PCrossRefs;
begin
  if NumRefs = I then Exit;
  GetMem(P, I * SizeOf(TCrossRef));
  if NumRefs > 0 then
  begin
    if I > NumRefs then Move(CrossRefs^, P^, NumRefs * SizeOf(TCrossRef))
    else Move(CrossRefs^, P^, I * SizeOf(TCrossRef));
    FreeMem(CrossRefs, NumRefs * SizeOf(TCrossRef));
  end;
  CrossRefs := P;
  NumRefs := I;
end;

procedure THelpTopic.SetWidth(AWidth: Integer);
begin
  Width := AWidth;
end;

procedure THelpTopic.Store(var S: TStream);

procedure WriteParagraphs;
var
  I: Integer;
  P: PParagraph;
begin
  P := Paragraphs;
  I := 0;
  while P <> nil do
  begin
    Inc(I);
    P := P^.Next;
  end;
  S.Write(I, SizeOf(I));
  P := Paragraphs;
  while P <> nil do
  begin
    S.Write(P^.Size, SizeOf(Integer));
    S.Write(P^.Wrap, SizeOf(Boolean));
    S.Write(P^.Text, P^.Size);
    P := P^.Next;
  end;
end;

procedure WriteCrossRefs;
var
  I: Integer;
begin
  S.Write(NumRefs, SizeOf(Integer));
  if @CrossRefHandler = @NotAssigned then
    S.Write(CrossRefs^, SizeOf(TCrossRef) * NumRefs)
  else
    for I := 1 to NumRefs do
    begin
      CrossRefHandler(S, CrossRefs^[I].Ref);
      S.Write(CrossRefs^[I].Offset, SizeOf(Integer) + SizeOf(Byte));
    end;
end;

begin
  WriteParagraphs;
  WriteCrossRefs;
end;

function THelpTopic.WrapText(var Text; Size: Integer;
  var Offset: Integer; Wrap: Boolean): String;
type
  PCArray = ^CArray;
  CArray = array[0..32767] of Char;
var
  Line: String;
  I, P: Integer;

function IsBlank(Ch: Char): Boolean;
begin
  IsBlank := (Ch = ' ') or (Ch = #13) or (Ch = #10);
end;

function Scan(var P; Offset: Integer; C: Char): Integer; assembler;
asm
	CLD
	LES	DI,P
        ADD	DI,&Offset
	MOV	CX,256
	MOV	AL, C
        REPNE	SCASB
	SUB	CX,256
        NEG	CX
        XCHG	AX,CX
end;

procedure TextToLine(var Text; Offset, Length: Integer; var Line: String);
  assembler;
asm
	CLD
	PUSH	DS
	LDS	SI,Text
        ADD	SI,&Offset
        LES     DI,Line
        MOV	AX,Length
        STOSB
        XCHG	AX,CX
        REP	MOVSB
        POP	DS
end;

begin
  I := Scan(Text, Offset, #13);
  if I + Offset > Size then I := Size - Offset;
  if (I >= Width) and Wrap then
  begin
    I := Offset + Width;
    if I > Size then I := Size
    else
    begin
      while (I > Offset) and not IsBlank(PCArray(@Text)^[I]) do Dec(I);
      if I = Offset then I := Offset + Width
      else Inc(I);
    end;
    if I = Offset then I := Offset + Width;
    Dec(I, Offset);
  end;
  TextToLine(Text, Offset, I, Line);
  if Line[Length(Line)] = #13 then Dec(Line[0]);
  Inc(Offset, I);
  WrapText := Line;
end;

{ THelpIndex }

constructor THelpIndex.Init;
begin
  TObject.Init;
  Size := 0;
  Index := nil;
end;

constructor THelpIndex.Load(var S: TStream);
begin
  S.Read(Size, SizeOf(Size));
  if Size = 0 then Index := nil
  else
  begin
    GetMem(Index, SizeOf(Longint) * Size);
    S.Read(Index^, SizeOf(Longint) * Size);
  end;
end;

destructor THelpIndex.Done;
begin
  FreeMem(Index, SizeOf(Longint) * Size);
  TObject.Done;
end;

function THelpIndex.Position(I: Integer): Longint;
begin
  if I < Size then Position := Index^[I]
  else Position := -1;
end;

procedure THelpIndex.Add(I: Integer; Val: Longint);
const
  Delta = 10;
var
  P: PIndexArray;
  NewSize: Integer;
begin
  if I >= Size then
  begin
    NewSize := (I + Delta) div Delta * Delta;
    GetMem(P, NewSize * SizeOf(LongInt));
    if P <> nil then
    begin
      Move(Index^, P^, Size * SizeOf(LongInt));
      FillChar(P^[Size], (NewSize - Size) * SizeOf(Longint), $FF);
    end;
    if Size > 0 then FreeMem(Index, Size * SizeOf(Longint));
    Index := P;
    Size := NewSize;
  end;
  Index^[I] := Val;
end;

procedure THelpIndex.Store(var S: TStream);
begin
  S.Write(Size, SizeOf(Size));
  S.Write(Index^, SizeOf(Longint) * Size);
end;

{ THelpFile }

const
  MagicHeader = $46484246; {'FBHF'}

constructor THelpFile.Init(S: PStream);
var
  Magic: Longint;
begin
  Magic := 0;
  S^.Seek(0);
  if S^.GetSize > SizeOf(Magic) then
    S^.Read(Magic, SizeOf(Magic));
  if Magic <> MagicHeader then
  begin
    IndexPos := 12;
    S^.Seek(IndexPos);
    Index := New(PHelpIndex, Init);
    Modified := True;
  end
  else
  begin
    S^.Seek(8);
    S^.Read(IndexPos, SizeOf(IndexPos));
    S^.Seek(IndexPos);
    Index := PHelpIndex(S^.Get);
    Modified := False;
  end;
  Stream := S;
end;

destructor THelpFile.Done;
var
  Magic, Size: Longint;
begin
  if Modified then
  begin
    Stream^.Seek(IndexPos);
    Stream^.Put(Index);
    Stream^.Seek(0);
    Magic := MagicHeader;
    Size := Stream^.GetSize - 8;
    Stream^.Write(Magic, SizeOf(Magic));
    Stream^.Write(Size, SizeOf(Size));
    Stream^.Write(IndexPos, SizeOf(IndexPos));
  end;
  Dispose(Stream, Done);
  Dispose(Index, Done);
end;

function THelpFile.GetTopic(I: Integer): PHelpTopic;
var
  Pos: Longint;
begin
  Pos := Index^.Position(I);
  if Pos > 0 then
  begin
    Stream^.Seek(Pos);
    GetTopic := PHelpTopic(Stream^.Get);
  end
  else GetTopic := InvalidTopic;
end;

function THelpFile.InvalidTopic: PHelpTopic;
var
  Topic: PHelpTopic;
  Para: PParagraph;
const
  InvalidStr = #13' No help available in this context.';
  InvalidText: array[1..Length(InvalidStr)] of Char = InvalidStr;
begin
  Topic := New(PHelpTopic, Init);
  GetMem(Para, SizeOf(Para^) + SizeOf(InvalidText));
  Para^.Size := SizeOf(InvalidText);
  Para^.Wrap := False;
  Para^.Next := nil;
  Move(InvalidText, Para^.Text, SizeOf(InvalidText));
  Topic^.AddParagraph(Para);
  InvalidTopic := Topic;
end;

procedure THelpFile.RecordPositionInIndex(I: Integer);
begin
  Index^.Add(I, IndexPos);
  Modified := True;
end;

procedure THelpFile.PutTopic(Topic: PHelpTopic);
begin
  Stream^.Seek(IndexPos);
  Stream^.Put(Topic);
  IndexPos := Stream^.GetPos;
  Modified := True;
end;

{ THelpViewer }

constructor THelpViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; AHelpFile: PHelpFile; Context: Word);
begin
  TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  Options := Options or ofSelectable;
  GrowMode := gfGrowHiX + gfGrowHiY;
  HFile := AHelpFile;
  Topic := AHelpFile^.GetTopic(Context);
  Topic^.SetWidth(Size.X);
  SetLimit(78, Topic^.NumLines);
  Selected := 1;
end;

destructor THelpViewer.Done;
begin
  TScroller.Done;
  Dispose(HFile, Done);
  Dispose(Topic, Done);
end;

procedure THelpViewer.ChangeBounds(var Bounds: TRect);
begin
  TScroller.ChangeBounds(Bounds);
  Topic^.SetWidth(Size.X);
  SetLimit(Limit.X, Topic^.NumLines);
end;

procedure THelpViewer.Draw;
var
  B: TDrawBuffer;
  Line: String;
  I, J, L: Integer;
  KeyCount: Integer;
  Normal, Keyword, SelKeyword, C: Byte;
  KeyPoint: TPoint;
  KeyLength: Byte;
  KeyRef: Integer;
begin
  Normal := GetColor(1);
  Keyword := GetColor(2);
  SelKeyword := GetColor(3);
  KeyCount := 0;
  KeyPoint.X := 0;
  KeyPoint.Y := 0;
  Topic^.SetWidth(Size.X);
  if Topic^.GetNumCrossRefs > 0 then
    repeat
      Inc(KeyCount);
      Topic^.GetCrossRef(KeyCount, KeyPoint, KeyLength, KeyRef);
    until (KeyCount >= Topic^.GetNumCrossRefs) or (KeyPoint.Y > Delta.Y);
  for I := 1 to Size.Y do
  begin
    MoveChar(B, ' ', Normal, Size.X);
    Line := Topic^.GetLine(I + Delta.Y);
    MoveStr(B, Copy(Line, Delta.X+1, Size.X), Normal);
    while I + Delta.Y = KeyPoint.Y do
    begin
      L := KeyLength;
      if KeyPoint.X < Delta.X then
      begin
        Dec(L, Delta.X - KeyPoint.X);
        KeyPoint.X := Delta.X;
      end;
      if KeyCount = Selected then C := SelKeyword
      else C := Keyword;
      for J := 0 to L-1 do
        WordRec(B[KeyPoint.X - Delta.X + J]).Hi := C;
      Inc(KeyCount);
      if KeyCount <= Topic^.GetNumCrossRefs then
        Topic^.GetCrossRef(KeyCount, KeyPoint, KeyLength, KeyRef)
      else KeyPoint.Y := 0;
    end;
    WriteLine(0, I-1, Size.X, 1, B);
  end;
end;

function THelpViewer.GetPalette: PPalette;
const
  P: String[Length(CHelpViewer)] = CHelpViewer;
begin
  GetPalette := @P;
end;

procedure THelpViewer.HandleEvent(var Event: TEvent);
var
  KeyPoint, Mouse: TPoint;
  KeyLength: Byte;
  KeyRef: Integer;
  KeyCount: Integer;

procedure MakeSelectVisible;
var
  D: TPoint;
begin
  Topic^.GetCrossRef(Selected, KeyPoint, KeyLength, KeyRef);
  D := Delta;
  if KeyPoint.X < D.X then D.X := KeyPoint.X;
  if KeyPoint.X > D.X + Size.X then D.X := KeyPoint.X - Size.X;
  if KeyPoint.Y < D.Y then D.Y := KeyPoint.Y;
  if KeyPoint.Y > D.Y + Size.Y then D.Y := KeyPoint.Y - Size.Y;
  if (D.X <> Delta.X) or (D.Y <> Delta.Y) then ScrollTo(D.X, D.Y);
end;

procedure SwitchToTopic(KeyRef: Integer);
begin
  if Topic <> nil then Dispose(Topic, Done);
  Topic := HFile^.GetTopic(KeyRef);
  Topic^.SetWidth(Size.X);
  ScrollTo(0, 0);
  SetLimit(Limit.X, Topic^.NumLines);
  Selected := 1;
  DrawView;
end;

begin
  TScroller.HandleEvent(Event);
  case Event.What of
    evKeyDown:
      begin
        case Event.KeyCode of
          kbTab:
            begin
              Inc(Selected);
              if Selected > Topic^.GetNumCrossRefs then Selected := 1;
              MakeSelectVisible;
            end;
          kbShiftTab:
            begin
              Dec(Selected);
              if Selected = 0 then Selected := Topic^.GetNumCrossRefs;
              MakeSelectVisible;
            end;
          kbEnter:
            begin
              if Selected <= Topic^.GetNumCrossRefs then
              begin
                Topic^.GetCrossRef(Selected, KeyPoint, KeyLength, KeyRef);
                SwitchToTopic(KeyRef);
              end;
            end;
          kbEsc:
            begin
              Event.What := evCommand;
              Event.Command := cmClose;
              PutEvent(Event);
            end;
        else
          Exit;
        end;
        DrawView;
        ClearEvent(Event);
      end;
    evMouseDown:
      begin
        MakeLocal(Event.Where, Mouse);
        Inc(Mouse.X, Delta.X); Inc(Mouse.Y, Delta.Y);
        KeyCount := 0;
        repeat
          Inc(KeyCount);
          if KeyCount > Topic^.GetNumCrossRefs then Exit;
          Topic^.GetCrossRef(KeyCount, KeyPoint, KeyLength, KeyRef);
        until (KeyPoint.Y = Mouse.Y+1) and (Mouse.X >= KeyPoint.X) and
          (Mouse.X < KeyPoint.X + KeyLength);
        Selected := KeyCount;
        DrawView;
        if Event.Double then SwitchToTopic(KeyRef);
        ClearEvent(Event);
      end;
    evCommand:
      if (Event.Command = cmClose) and (Owner^.State and sfModal <> 0) then
      begin
        EndModal(cmClose);
        ClearEvent(Event);
      end;
  end;
end;

{ THelpWindow }

constructor THelpWindow.Init(HFile: PHelpFile; Context: Word);
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 18);
  TWindow.Init(R, 'Help', wnNoNumber);
  Options := Options or ofCentered;
  R.Grow(-2,-1);
  Insert(New(PHelpViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard), HFile, Context)));
end;

function THelpWindow.GetPalette: PPalette;
const
  P: String[Length(CHelpWindow)] = CHelpWindow;
begin
  GetPalette := @P;
end;

procedure RegisterHelpFile;
begin
  RegisterType(RHelpTopic);
  RegisterType(RHelpIndex);
end;

procedure NotAssigned(var S: TStream; Value: Integer);
begin
end;

end.
