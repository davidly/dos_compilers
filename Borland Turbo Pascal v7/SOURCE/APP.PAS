
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit App;

{$O+,F+,X+,I-,S-}

interface

uses Objects, Drivers, Memory, HistList, Views, Menus, Dialogs;

const

{ TApplication palette entries }

  apColor      = 0;
  apBlackWhite = 1;
  apMonochrome = 2;

{ TApplication palettes }

  { Turbo Vision 1.0 Color Palettes }

  CColor =
        #$71#$70#$78#$74#$20#$28#$24#$17#$1F#$1A#$31#$31#$1E#$71#$1F +
    #$37#$3F#$3A#$13#$13#$3E#$21#$3F#$70#$7F#$7A#$13#$13#$70#$7F#$7E +
    #$70#$7F#$7A#$13#$13#$70#$70#$7F#$7E#$20#$2B#$2F#$78#$2E#$70#$30 +
    #$3F#$3E#$1F#$2F#$1A#$20#$72#$31#$31#$30#$2F#$3E#$31#$13#$38#$00;

  CBlackWhite =
        #$70#$70#$78#$7F#$07#$07#$0F#$07#$0F#$07#$70#$70#$07#$70#$0F +
    #$07#$0F#$07#$70#$70#$07#$70#$0F#$70#$7F#$7F#$70#$07#$70#$07#$0F +
    #$70#$7F#$7F#$70#$07#$70#$70#$7F#$7F#$07#$0F#$0F#$78#$0F#$78#$07 +
    #$0F#$0F#$0F#$70#$0F#$07#$70#$70#$70#$07#$70#$0F#$07#$07#$78#$00;

  CMonochrome =
        #$70#$07#$07#$0F#$70#$70#$70#$07#$0F#$07#$70#$70#$07#$70#$00 +
    #$07#$0F#$07#$70#$70#$07#$70#$00#$70#$70#$70#$07#$07#$70#$07#$00 +
    #$70#$70#$70#$07#$07#$70#$70#$70#$0F#$07#$07#$0F#$70#$0F#$70#$07 +
    #$0F#$0F#$07#$70#$07#$07#$70#$07#$07#$07#$70#$0F#$07#$07#$70#$00;

  { Turbo Vision 2.0 Color Palettes }

  CAppColor =
        #$71#$70#$78#$74#$20#$28#$24#$17#$1F#$1A#$31#$31#$1E#$71#$1F +
    #$37#$3F#$3A#$13#$13#$3E#$21#$3F#$70#$7F#$7A#$13#$13#$70#$7F#$7E +
    #$70#$7F#$7A#$13#$13#$70#$70#$7F#$7E#$20#$2B#$2F#$78#$2E#$70#$30 +
    #$3F#$3E#$1F#$2F#$1A#$20#$72#$31#$31#$30#$2F#$3E#$31#$13#$38#$00 +
    #$17#$1F#$1A#$71#$71#$1E#$17#$1F#$1E#$20#$2B#$2F#$78#$2E#$10#$30 +
    #$3F#$3E#$70#$2F#$7A#$20#$12#$31#$31#$30#$2F#$3E#$31#$13#$38#$00 +
    #$37#$3F#$3A#$13#$13#$3E#$30#$3F#$3E#$20#$2B#$2F#$78#$2E#$30#$70 +
    #$7F#$7E#$1F#$2F#$1A#$20#$32#$31#$71#$70#$2F#$7E#$71#$13#$38#$00;

  CAppBlackWhite =
        #$70#$70#$78#$7F#$07#$07#$0F#$07#$0F#$07#$70#$70#$07#$70#$0F +
    #$07#$0F#$07#$70#$70#$07#$70#$0F#$70#$7F#$7F#$70#$07#$70#$07#$0F +
    #$70#$7F#$7F#$70#$07#$70#$70#$7F#$7F#$07#$0F#$0F#$78#$0F#$78#$07 +
    #$0F#$0F#$0F#$70#$0F#$07#$70#$70#$70#$07#$70#$0F#$07#$07#$78#$00 +
    #$07#$0F#$0F#$07#$70#$07#$07#$0F#$0F#$70#$78#$7F#$08#$7F#$08#$70 +
    #$7F#$7F#$7F#$0F#$70#$70#$07#$70#$70#$70#$07#$7F#$70#$07#$78#$00 +
    #$70#$7F#$7F#$70#$07#$70#$70#$7F#$7F#$07#$0F#$0F#$78#$0F#$78#$07 +
    #$0F#$0F#$0F#$70#$0F#$07#$70#$70#$70#$07#$70#$0F#$07#$07#$78#$00;

  CAppMonochrome =
        #$70#$07#$07#$0F#$70#$70#$70#$07#$0F#$07#$70#$70#$07#$70#$00 +
    #$07#$0F#$07#$70#$70#$07#$70#$00#$70#$70#$70#$07#$07#$70#$07#$00 +
    #$70#$70#$70#$07#$07#$70#$70#$70#$0F#$07#$07#$0F#$70#$0F#$70#$07 +
    #$0F#$0F#$07#$70#$07#$07#$70#$07#$07#$07#$70#$0F#$07#$07#$70#$00 +
    #$70#$70#$70#$07#$07#$70#$70#$70#$0F#$07#$07#$0F#$70#$0F#$70#$07 +
    #$0F#$0F#$07#$70#$07#$07#$70#$07#$07#$07#$70#$0F#$07#$07#$70#$00 +
    #$70#$70#$70#$07#$07#$70#$70#$70#$0F#$07#$07#$0F#$70#$0F#$70#$07 +
    #$0F#$0F#$07#$70#$07#$07#$70#$07#$07#$07#$70#$0F#$07#$07#$70#$00;

{ TBackground palette }

  CBackground = #1;

{ Standard application commands }

  cmNew       = 30;
  cmOpen      = 31;
  cmSave      = 32;
  cmSaveAs    = 33;
  cmSaveAll   = 34;
  cmChangeDir = 35;
  cmDosShell  = 36;
  cmCloseAll  = 37;

{ Standard application help contexts }

{ Note: range $FF00 - $FFFF of help contexts are reserved by Borland }

  hcNew          = $FF01;
  hcOpen         = $FF02;
  hcSave         = $FF03;
  hcSaveAs       = $FF04;
  hcSaveAll      = $FF05;
  hcChangeDir    = $FF06;
  hcDosShell     = $FF07;
  hcExit         = $FF08;

  hcUndo         = $FF10;
  hcCut          = $FF11;
  hcCopy         = $FF12;
  hcPaste        = $FF13;
  hcClear        = $FF14;

  hcTile         = $FF20;
  hcCascade      = $FF21;
  hcCloseAll     = $FF22;
  hcResize       = $FF23;
  hcZoom         = $FF24;
  hcNext         = $FF25;
  hcPrev         = $FF26;
  hcClose        = $FF27;

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

{ TDesktop object }

  PDesktop = ^TDesktop;
  TDesktop = object(TGroup)
    Background: PBackground;
    TileColumnsFirst: Boolean;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure Cascade(var R: TRect);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitBackground; virtual;
    procedure Store(var S: TStream);
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
    function CanMoveFocus: Boolean;
    function ExecuteDialog(P: PDialog; Data: Pointer): Word;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitDesktop; virtual;
    procedure InitMenuBar; virtual;
    procedure InitScreen; virtual;
    procedure InitStatusLine; virtual;
    function InsertWindow(P: PWindow): PWindow;
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
    procedure Cascade;
    procedure DosShell;
    procedure GetTileRect(var R: TRect); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Tile;
    procedure WriteShellMsg; virtual;
  end;

{ Standard menus and status lines }

function StdStatusKeys(Next: PStatusItem): PStatusItem;

function StdFileMenuItems(Next: PMenuItem): PMenuItem;
function StdEditMenuItems(Next: PMenuItem): PMenuItem;
function StdWindowMenuItems(Next: PMenuItem): PMenuItem;

{ App registration procedure }

procedure RegisterApp;

const

{ Public variables }

  Application: PProgram = nil;
  Desktop: PDesktop = nil;
  StatusLine: PStatusLine = nil;
  MenuBar: PMenuView = nil;
  AppPalette: Integer = apColor;

{ Stream registration records }

const
  RBackground: TStreamRec = (
    ObjType: 30;
    VmtLink: Ofs(TypeOf(TBackground)^);
    Load: @TBackground.Load;
    Store: @TBackground.Store);

const
  RDesktop: TStreamRec = (
    ObjType: 31;
    VmtLink: Ofs(TypeOf(TDesktop)^);
    Load: @TDesktop.Load;
    Store: @TDesktop.Store);

implementation

uses Dos;

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

{ TDesktop object }

constructor TDesktop.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  GrowMode := gfGrowHiX + gfGrowHiY;
  InitBackground;
  if Background <> nil then Insert(Background);
end;

constructor TDesktop.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, Background);
  S.Read(TileColumnsFirst, SizeOf(TileColumnsFirst));
end;

function Tileable(P: PView): Boolean;
begin
  Tileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;

procedure TDesktop.Cascade(var R: TRect);
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

procedure TDesktop.HandleEvent(var Event: TEvent);
begin
  TGroup.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNext: FocusNext(False);
      cmPrev:
        if Valid(cmReleasedFocus) then
          Current^.PutInFrontOf(Background);
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TDesktop.InitBackground;
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

procedure MostEqualDivisors(N: Integer; var X, Y: Integer; FavorY: Boolean);
var
  I: Integer;
begin
  I := ISqr(N);
  if ((N mod I) <> 0) then
    if (N mod (I+1)) = 0 then Inc(I);
  if I < (N div I) then I := N div I;
  if FavorY then
  begin
    X := N div I;
    Y := I;
  end
  else
  begin
    Y := N div I;
    X := I;
  end;
end;

procedure TDesktop.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, Background);
  S.Write(TileColumnsFirst, SizeOf(TileColumnsFirst));
end;

procedure TDesktop.Tile(var R: TRect);
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
    MostEqualDivisors(NumTileable, NumCols, NumRows, not TileColumnsFirst);
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
  InitDesktop;
  InitStatusLine;
  InitMenuBar;
  if Desktop <> nil then Insert(Desktop);
  if StatusLine <> nil then Insert(StatusLine);
  if MenuBar <> nil then Insert(MenuBar);
end;

destructor TProgram.Done;
begin
  if Desktop <> nil then Dispose(Desktop, Done);
  if MenuBar <> nil then Dispose(MenuBar, Done);
  if StatusLine <> nil then Dispose(StatusLine, Done);
  Application := nil;
  inherited Done;
end;

function TProgram.CanMoveFocus: Boolean;
begin
  CanMoveFocus := Desktop^.Valid(cmReleasedFocus);
end;

function TProgram.ExecuteDialog(P: PDialog; Data: Pointer): Word;
var
  C: Word;
begin
  ExecuteDialog := cmCancel;
  if ValidView(P) <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    C := Desktop^.ExecView(P);
    if (C <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
    ExecuteDialog := C;
  end;
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
  P: array[apColor..apMonochrome] of string[Length(CAppColor)] =
    (CAppColor, CAppBlackWhite, CAppMonochrome);
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
      if Message(Desktop, evBroadCast, cmSelectWindowNum,
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

procedure TProgram.InitDesktop;
var
  R: TRect;
begin
  GetExtent(R);
  Inc(R.A.Y);
  Dec(R.B.Y);
  New(Desktop, Init(R));
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
      StdStatusKeys(nil)), nil)));
end;

function TProgram.InsertWindow(P: PWindow): PWindow;
begin
  InsertWindow := nil;
  if ValidView(P) <> nil then
    if CanMoveFocus then
    begin
      Desktop^.Insert(P);
      InsertWindow := P;
    end
    else
      Dispose(P, Done);
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
  InitMemory;
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

procedure TApplication.Cascade;
var
  R: TRect;
begin
  GetTileRect(R);
  if Desktop <> nil then Desktop^.Cascade(R);
end;

procedure TApplication.DosShell;
begin
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneDosMem;
  WriteShellMsg;
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  InitDosMem;
  InitVideo;
  InitEvents;
  InitSysError;
  Redraw;
end;

procedure TApplication.GetTileRect(var R: TRect);
begin
  Desktop^.GetExtent(R);
end;

procedure TApplication.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmTile: Tile;
          cmCascade: Cascade;
          cmDosShell: DosShell;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;

procedure TApplication.Tile;
var
  R: TRect;
begin
  GetTileRect(R);
  if Desktop <> nil then Desktop^.Tile(R);
end;

procedure TApplication.WriteShellMsg;
begin
  PrintStr('Type EXIT to return...');
end;

{ App registration procedure }

procedure RegisterApp;
begin
  RegisterType(RBackground);
  RegisterType(RDesktop);
end;

{ Standard menus and status lines }

function StdStatusKeys(Next: PStatusItem): PStatusItem;
begin
  StdStatusKeys :=
    NewStatusKey('', kbAltX, cmQuit,
    NewStatusKey('', kbF10, cmMenu,
    NewStatusKey('', kbAltF3, cmClose,
    NewStatusKey('', kbF5, cmZoom,
    NewStatusKey('', kbCtrlF5, cmResize,
    NewStatusKey('', kbF6, cmNext,
    NewStatusKey('', kbShiftF6, cmPrev,
    Next)))))));
end;

function StdFileMenuItems(Next: PMenuItem): PMenuItem;
begin
  StdFileMenuItems :=
    NewItem('~N~ew', '', kbNoKey, cmNew, hcNew,
    NewItem('~O~pen...', 'F3', kbF3, cmOpen, hcOpen,
    NewItem('~S~ave', 'F2', kbF2, cmSave, hcSave,
    NewItem('S~a~ve as...', '', kbNoKey, cmSaveAs, hcSaveAs,
    NewItem('Save a~l~l', '', kbNoKey, cmSaveAll, hcSaveAll,
    NewLine(
    NewItem('~C~hange dir...', '', kbNoKey, cmChangeDir, hcChangeDir,
    NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcDosShell,
    NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcExit,
    Next)))))))));
end;

function StdEditMenuItems(Next: PMenuItem): PMenuItem;
begin
  StdEditMenuItems :=
    NewItem('~U~ndo', '', kbAltBack, cmUndo, hcUndo,
    NewLine(
    NewItem('Cu~t~', 'Shift+Del', kbShiftDel, cmCut, hcCut,
    NewItem('~C~opy', 'Ctrl+Ins', kbCtrlIns, cmCopy, hcCopy,
    NewItem('~P~aste', 'Shift+Ins', kbShiftIns, cmPaste, hcPaste,
    NewItem('C~l~ear', 'Ctrl+Del', kbCtrlDel, cmClear, hcClear,
    Next))))));
end;

function StdWindowMenuItems(Next: PMenuItem): PMenuItem;
begin
  StdWindowMenuItems :=
    NewItem('~T~ile', '', kbNoKey, cmTile, hcTile,
    NewItem('C~a~scade', '', kbNoKey, cmCascade, hcCascade,
    NewItem('Cl~o~se all', '', kbNoKey, cmCloseAll, hcCloseAll,
    NewLine(
    NewItem('~S~ize/Move','Ctrl+F5', kbCtrlF5, cmResize, hcResize,
    NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcZoom,
    NewItem('~N~ext', 'F6', kbF6, cmNext, hcNext,
    NewItem('~P~revious', 'Shift+F6', kbShiftF6, cmPrev, hcPrev,
    NewItem('~C~lose', 'Alt+F3', kbAltF3, cmClose, hcClose,
    Next)))))))));
end;

end.
