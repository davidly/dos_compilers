
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 6.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1990 Borland International        }
{                                                       }
{*******************************************************}

unit App;

{$F+,O+,S-,X+,D-}

interface

uses Objects, Drivers, Memory, HistList, Views, Menus;

const

{ TApplication palette entries }

  apColor      = 0;
  apBlackWhite = 1;
  apMonochrome = 2;

{ TApplication palettes }

  CColor =
        #$71#$70#$78#$74#$20#$28#$24#$17#$1F#$1A#$31#$31#$1E#$71#$00 +
    #$37#$3F#$3A#$13#$13#$3E#$21#$00#$70#$7F#$7A#$13#$13#$70#$7F#$00 +
    #$70#$7F#$7A#$13#$13#$70#$70#$7F#$7E#$20#$2B#$2F#$78#$2E#$70#$30 +
    #$3F#$3E#$1F#$2F#$1A#$20#$72#$31#$31#$30#$2F#$3E#$31#$13#$00#$00;

  CBlackWhite =
        #$70#$70#$78#$7F#$07#$07#$0F#$07#$0F#$07#$70#$70#$07#$70#$00 +
    #$07#$0F#$07#$70#$70#$07#$70#$00#$70#$7F#$7F#$70#$07#$70#$07#$00 +
    #$70#$7F#$7F#$70#$07#$70#$70#$7F#$7F#$07#$0F#$0F#$78#$0F#$78#$07 +
    #$0F#$0F#$0F#$70#$0F#$07#$70#$70#$70#$07#$70#$0F#$07#$07#$00#$00;

  CMonochrome =
        #$70#$07#$07#$0F#$70#$70#$70#$07#$0F#$07#$70#$70#$07#$70#$00 +
    #$07#$0F#$07#$70#$70#$07#$70#$00#$70#$70#$70#$07#$07#$70#$07#$00 +
    #$70#$70#$70#$07#$07#$70#$70#$70#$0F#$07#$07#$0F#$70#$0F#$70#$07 +
    #$0F#$0F#$07#$70#$07#$07#$70#$07#$07#$07#$70#$0F#$07#$07#$00#$00;


{ TBackground palette }

  CBackground = #1;

type

{ TBackground object }

  PBackground = ^TBackground;
  TBackground = object(TView)
    Pattern: Char;
    constructor Init(var Bounds: TRect; APattern: Char);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure Store(var S: TStream);
  end;

{ TDeskTop object }

  PDeskTop = ^TDeskTop;
  TDeskTop = object(TGroup)
    Background: PBackground;
    constructor Init(var Bounds: TRect);
    procedure Cascade(var R: TRect);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitBackground; virtual;
    procedure Tile(var R: TRect);
    procedure TileError; virtual;
  end;

{ TProgram object }

  { Palette layout }
  {     1 = TBackground }
  {  2- 7 = TMenuView and TStatusLine }
  {  8-15 = TWindow(Blue) }
  { 16-23 = TWindow(Cyan) }
  { 24-31 = TWindow(Gray) }
  { 32-63 = TDialog }

  PProgram = ^TProgram;
  TProgram = object(TGroup)
    constructor Init;
    destructor Done; virtual;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitDeskTop; virtual;
    procedure InitMenuBar; virtual;
    procedure InitScreen; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
    procedure PutEvent(var Event: TEvent); virtual;
    procedure Run; virtual;
    procedure SetScreenMode(Mode: Word);
    function ValidView(P: PView): PView;
  end;

{ TApplication object }

  PApplication = ^TApplication;
  TApplication = object(TProgram)
    constructor Init;
    destructor Done; virtual;
  end;

{ App registration procedure }

procedure RegisterApp;

const

{ Public variables }

  Application: PProgram = nil;
  DeskTop: PDeskTop = nil;
  StatusLine: PStatusLine = nil;
  MenuBar: PMenuView = nil;
  AppPalette: Integer = apColor;

{ Stream registration records }

  RBackground: TStreamRec = (
    ObjType: 30;
    VmtLink: Ofs(TypeOf(TBackground)^);
    Load: @TBackground.Load;
    Store: @TBackground.Store);

  RDeskTop: TStreamRec = (
    ObjType: 31;
    VmtLink: Ofs(TypeOf(TDeskTop)^);
    Load: @TDeskTop.Load;
    Store: @TDeskTop.Store);

implementation

const

{ Private variables }

  Pending: TEvent = (What: evNothing);

{ TBackground }

constructor TBackground.Init(var Bounds: TRect; APattern: Char);
begin
  TView.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Pattern := APattern;
end;

constructor TBackground.Load(var S: TStream);
begin
  TView.Load(S);
  S.Read(Pattern, SizeOf(Pattern));
end;

procedure TBackground.Draw;
var
  B: TDrawBuffer;
begin
  MoveChar(B, Pattern, GetColor($01), Size.X);
  WriteLine(0, 0, Size.X, Size.Y, B);
end;

function TBackground.GetPalette: PPalette;
const
  P: string[Length(CBackground)] = CBackground;
begin
  GetPalette := @P;
end;

procedure TBackground.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Pattern, SizeOf(Pattern));
end;

{ TDeskTop object }

constructor TDeskTop.Init(var Bounds: TRect);
begin
  TGroup.Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  InitBackground;
  if Background <> nil then Insert(Background);
end;

function Tileable(P: PView): Boolean;
begin
  Tileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;

procedure TDeskTop.Cascade(var R: TRect);
var
  CascadeNum: Integer;
  LastView: PView;
  Min, Max: TPoint;

 
procedure DoCount(P: PView); far;
begin
  if Tileable(P) then
  begin
    Inc(CascadeNum);
    LastView := P;
  end;
end;

procedure DoCascade(P: PView); far;
var
  NR: TRect;
begin
  if Tileable(P) and (CascadeNum >= 0) then
  begin
    NR.Copy(R);
    Inc(NR.A.X, CascadeNum); Inc(NR.A.Y, CascadeNum);
    P^.Locate(NR);
    Dec(CascadeNum);
  end;
end;

begin
  CascadeNum := 0;
  ForEach(@DoCount);
  if CascadeNum > 0 then
  begin
    LastView^.SizeLimits(Min, Max);
    if (Min.X > R.B.X - R.A.X - CascadeNum) or
       (Min.Y > R.B.Y - R.A.Y - CascadeNum) then TileError
    else
    begin
      Dec(CascadeNum);
      Lock;
      ForEach(@DoCascade);
      Unlock;
    end;
  end;
end;

procedure TDeskTop.HandleEvent(var Event: TEvent);
begin
  TGroup.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNext: SelectNext(False);
      cmPrev: Current^.PutInFrontOf(Background);
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TDeskTop.InitBackground;
var
  R: TRect;
begin
  GetExtent(R);
  New(Background, Init(R, #176));
end;

function ISqr(X: Integer): Integer; assembler;
asm
	MOV	CX,X
        MOV	BX,0
@@1:    INC     BX
	MOV	AX,BX
	IMUL	AX
        CMP	AX,CX
        JLE	@@1
	MOV	AX,BX
        DEC     AX
end;

procedure MostEqualDivisors(N: Integer; var X, Y: Integer);
var
  I: Integer;
begin
  I := ISqr(N);
  if ((N mod I) <> 0) then
    if (N mod (I+1)) = 0 then Inc(I);
  if I < (N div I) then I := N div I;
  X := N div I;
  Y := I;
end;

procedure TDeskTop.Tile(var R: TRect);
var
  NumCols, NumRows, NumTileable, LeftOver, TileNum: Integer;

procedure DoCountTileable(P: PView); far;
begin
  if Tileable(P) then Inc(NumTileable);
end;

function DividerLoc(Lo, Hi, Num, Pos: Integer): Integer;
begin
  DividerLoc := LongDiv(LongMul(Hi - Lo, Pos), Num) + Lo;
end;

procedure CalcTileRect(Pos: Integer; var NR: TRect);
var
  X,Y,D: Integer;
begin
  D := (NumCols - LeftOver) * NumRows;
  if Pos < D then
  begin
    X := Pos div NumRows;
    Y := Pos mod NumRows;
  end else
  begin
    X := (Pos - D) div (NumRows + 1) + (NumCols - LeftOver);
    Y := (Pos - D) mod (NumRows + 1);
  end;
  NR.A.X := DividerLoc(R.A.X, R.B.X, NumCols, X);
  NR.B.X := DividerLoc(R.A.X, R.B.X, NumCols, X+1);
  if Pos >= D then
  begin
    NR.A.Y := DividerLoc(R.A.Y, R.B.Y, NumRows+1, Y);
    NR.B.Y := DividerLoc(R.A.Y, R.B.Y, NumRows+1, Y+1);
  end else
  begin
    NR.A.Y := DividerLoc(R.A.Y, R.B.Y, NumRows, Y);
    NR.B.Y := DividerLoc(R.A.Y, R.B.Y, NumRows, Y+1);
  end;
end;

procedure DoTile(P: PView); far;
var
  R: TRect;
begin
  if Tileable(P) then
  begin
    CalcTileRect(TileNum, R);
    P^.Locate(R);
    Dec(TileNum);
  end;
end;

begin
  NumTileable := 0;
  ForEach(@DoCountTileable);
  if NumTileable > 0 then
  begin
    MostEqualDivisors(NumTileable, NumCols, NumRows);
    if ((R.B.X - R.A.X) div NumCols = 0) or
       ((R.B.Y - R.A.Y) div NumRows = 0) then TileError
    else
    begin
      LeftOver := NumTileable mod NumCols;
      TileNum := NumTileable-1;
      Lock;
      ForEach(@DoTile);
      Unlock;
    end;
  end;
end;

procedure TDesktop.TileError;
begin
end;

{ TProgram }

constructor TProgram.Init;
var
  R: TRect;
begin
  Application := @Self;
  InitScreen;
  R.Assign(0, 0, ScreenWidth, ScreenHeight);
  TGroup.Init(R);
  State := sfVisible + sfSelected + sfFocused + sfModal + sfExposed;
  Options := 0;
  Buffer := ScreenBuffer;
  InitDeskTop;
  InitStatusLine;
  InitMenuBar;
  if DeskTop <> nil then Insert(DeskTop);
  if StatusLine <> nil then Insert(StatusLine);
  if MenuBar <> nil then Insert(MenuBar);
end;

destructor TProgram.Done;
begin
  if DeskTop <> nil then Dispose(DeskTop, Done);
  if MenuBar <> nil then Dispose(MenuBar, Done);
  if StatusLine <> nil then Dispose(StatusLine, Done);
  Application := nil;
end;

procedure TProgram.GetEvent(var Event: TEvent);
var
  R: TRect;

function ContainsMouse(P: PView): Boolean; far;
begin
  ContainsMouse := (P^.State and sfVisible <> 0) and
    P^.MouseInView(Event.Where);
end;

begin
  if Pending.What <> evNothing then
  begin
    Event := Pending;
    Pending.What := evNothing;
  end else
  begin
    GetMouseEvent(Event);
    if Event.What = evNothing then
    begin
      GetKeyEvent(Event);
      if Event.What = evNothing then Idle;
    end;
  end;
  if StatusLine <> nil then
    if (Event.What and evKeyDown <> 0) or
      (Event.What and evMouseDown <> 0) and
      (FirstThat(@ContainsMouse) = PView(StatusLine)) then
      StatusLine^.HandleEvent(Event);
end;

function TProgram.GetPalette: PPalette;
const
  P: array[apColor..apMonochrome] of string[Length(CColor)] =
    (CColor, CBlackWhite, CMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TProgram.HandleEvent(var Event: TEvent);
var
  I: Word;
  C: Char;
begin
  if Event.What = evKeyDown then
  begin
    C := GetAltChar(Event.KeyCode);
    if (C >= '1') and (C <= '9') then
      if Message(DeskTop, evBroadCast, cmSelectWindowNum,
        Pointer(Byte(C) - $30)) <> nil then ClearEvent(Event);
  end;
  TGroup.HandleEvent(Event);
  if Event.What = evCommand then
    if Event.Command = cmQuit then
    begin
      EndModal(cmQuit);
      ClearEvent(Event);
    end;
end;

procedure TProgram.Idle;
begin
  if StatusLine <> nil then StatusLine^.Update;
  if CommandSetChanged then
  begin
    Message(@Self, evBroadcast, cmCommandSetChanged, nil);
    CommandSetChanged := False;
  end;
end;

procedure TProgram.InitDeskTop;
var
  R: TRect;
begin
  GetExtent(R);
  Inc(R.A.Y);
  Dec(R.B.Y);
  New(DeskTop, Init(R));
end;

procedure TProgram.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, nil));
end;

procedure TProgram.InitScreen;
begin
  if Lo(ScreenMode) <> smMono then
  begin
    if ScreenMode and smFont8x8 <> 0 then
      ShadowSize.X := 1 else
      ShadowSize.X := 2;
    ShadowSize.Y := 1;
    ShowMarkers := False;
    if Lo(ScreenMode) = smBW80 then
      AppPalette := apBlackWhite else
      AppPalette := apColor;
  end else
  begin
    ShadowSize.X := 0;
    ShadowSize.Y := 0;
    ShowMarkers := True;
    AppPalette := apMonochrome;
  end;
end;

procedure TProgram.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbAltF3, cmClose,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbF6, cmNext, nil)))))), nil)));
end;

procedure TProgram.OutOfMemory;
begin
end;

procedure TProgram.PutEvent(var Event: TEvent);
begin
  Pending := Event;
end;

procedure TProgram.Run;
begin
  Execute;
end;

procedure TProgram.SetScreenMode(Mode: Word);
var
  R: TRect;
begin
  HideMouse;
  SetVideoMode(Mode);
  DoneMemory;
  InitScreen;
  Buffer := ScreenBuffer;
  R.Assign(0, 0, ScreenWidth, ScreenHeight);
  ChangeBounds(R);
  ShowMouse;
end;

function TProgram.ValidView(P: PView): PView;
begin
  ValidView := nil;
  if P <> nil then
  begin
    if LowMemory then
    begin
      Dispose(P, Done);
      OutOfMemory;
      Exit;
    end;
    if not P^.Valid(cmValid) then
    begin
      Dispose(P, Done);
      Exit;
    end;
    ValidView := P;
  end;
end;

{ TApplication }

constructor TApplication.Init;
begin
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  InitHistory;
  TProgram.Init;
end;

destructor TApplication.Done;
begin
  TProgram.Done;
  DoneHistory;
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;
end;

{ App registration procedure }

procedure RegisterApp;
begin
  RegisterType(RBackground);
  RegisterType(RDeskTop);
end;

end.
