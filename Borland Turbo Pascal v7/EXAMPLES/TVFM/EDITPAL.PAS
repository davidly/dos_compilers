{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$X+}
{$V-}

uses Drivers, Objects, App, Views, Dialogs, Menus, StdDlg, MsgBox,
     HistList, ColorSel;

const

  AddToWin =
    #64#65#66#67#68#69#70#71#72#73#74#75#76#77#78#79 +
    #80#81#82#83#84#85#86#87#88#89#90#91#92#93#94#95 +
    #96#97#98#99#100#101#102#103#104#105#106#107#108#109#110#111 +
    #112#113#114#115#116#117#118#119#120#121#122#123#124#125#126#127;

  AppPal : String[Length(CColor) * 2] =
    CColor + CColor;

  WinPal : String[Length(CDialog) + 64] =
    CDialog + AddToWin;

  GrpPal : String[64] =
    #33#34#35#36#37#38#39#40#41#42#43#44#45#46#47#48 +
    #49#50#51#52#53#54#55#56#57#58#59#60#61#62#63#64 +
    #65#66#67#68#69#70#71#72#73#74#75#76#77#78#79#80 +
    #81#82#83#84#85#86#87#88#89#90#91#92#93#94#95#96;

  cmNothing = 100;
  cmInActive = 101;

  { Change the current palette entry }
  cmBack = 110;
  cmFore = 111;

  { Commands to insert new windows and controls }

  cmBWindow     = 200;
  cmCWindow     = 201;
  cmGWindow     = 202;
  cmDListBox    = 204;  { Dialog with TListBox }
  cmDClusters   = 205;
  cmDInputs     = 206;

  cmRefresh     = 120;
  cmNewColor    = 121;

  cmSavePalette = 130;
  cmOpenPalette = 131;
  cmShowDialog  = 132;

type

  PPalApp = ^TPalApp;
  TPalApp = object(TApplication)
    function GetPalette: PPalette; virtual;
    procedure InitStatusLine; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PWorkWindow = ^TWorkWindow;
  TWorkWindow = object(TDialog)
    ListBox: PListBox;
    ForSel: PColorSelector;
    BackSel: PColorSelector;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  ColorWindowType = (wcBlue, wcCyan, wcGray);

  PColorWindow = ^TColorWindow;
  TColorWindow = object(TWindow)
    ThePalette: PPalette;
    constructor Init(var Bounds: TRect; ATitle: TTitleStr;
      APalette: PPalette);
    function GetPalette: PPalette; virtual;
  end;

  PWorkDesktop = ^TWorkDesktop;
  TWorkDesktop = object(TDesktop)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PWorkGroup = ^TWorkGroup;
  TWorkGroup = object(TGroup)
    DT: PWorkDeskTop;
    MB: PMenuBar;
    SL: PStatusLine;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PTextCollection = ^TTextCollection;
  TTextCollection = object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
  end;

  PPaletteList = ^TPaletteList;
  TPaletteList = object(TListBox)
    procedure FocusItem(Item: Integer); virtual;
  end;

  PWinInterior = ^TWinInterior;
  TWinInterior = object(TScroller)
    Lines: PCollection;
    procedure Draw; virtual;
    destructor Done; virtual;
  end;

const
  CurrentPalette : FNameStr = '';
  isDirty: Boolean = False;

  WindowPalettes: array[ColorWindowType] of TPalette =
    (CBlueWindow, CCyanWindow, CGrayWindow);


{ TColorWindow }
constructor TColorWindow.Init(var Bounds: TRect; ATitle: TTitleStr;
  APalette: PPalette);
begin
  inherited Init(Bounds, ATitle, wnNoNumber);
  ThePalette := APalette;
end;

function TColorWindow.GetPalette: PPalette;
begin
  GetPalette := ThePalette;
end;


{ TWinInterior }
procedure TWinInterior.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  S: String;
  P: PString;
begin
  for I := 0 to Size.Y - 1 do
  begin
    if (Delta.Y + I) = 1 then C := GetColor(2)
    else C := GetColor(1);
    MoveChar(B, ' ', C, Size.X);
    if Delta.Y + I < Lines^.Count then
    begin
      P := Lines^.At(Delta.Y + I);
      if P <> nil then S := Copy(P^, Delta.X + 1, Size.X)
      else S := '';
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

destructor TWinInterior.Done;
begin
  if Lines <> nil then Dispose(Lines, Done);
  inherited Done;
end;

procedure SavePalette;
var
  S: TBufStream;
  Desc: String;
  D: PFileDialog;
  C: Word;
begin
  if CurrentPalette = '' then
  begin
    D := New(PFileDialog, Init('*.PAL', 'Save As', '~N~ame',
           fdOKButton, 100));
    if Desktop^.ExecView(D) <> cmCancel then
      D^.GetFileName(CurrentPalette);
    Dispose(D, Done);
  end;
  if CurrentPalette = '' then Exit;

  S.Init(CurrentPalette, stCreate, 1024);
  if S.Status <> stOK then Exit;
  S.Write(AppPal[64], 64);
  S.Done;
end;

procedure OpenPalette;
var
  S: TBufStream;
  Desc: String;
  D: PFileDialog;
  C: Word;
begin
  D := New(PFileDialog, Init('*.PAL', 'Open Palette', '~N~ame',
    fdOKButton, 100));
  if Desktop^.ExecView(D) <> cmCancel then
    D^.GetFileName(CurrentPalette);
  Dispose(D, Done);
  if CurrentPalette = '' then Exit;

  S.Init(CurrentPalette, stOpenRead, 1024);
  if S.Status <> stOK then Exit;
  S.Read(AppPal[64], 64);
  S.Done;
  Message(Desktop, evBroadcast, cmRefresh, nil);
end;

procedure NoBuf(var Options: Word);
begin
  Options := Options and (not ofBuffered);
end;

function NewTextCollection: PTextCollection;
var
  C: PTextCollection;
begin
  C := New(PTextCollection, Init(10,0));
  with C^ do
  begin
    Insert(NewStr('This is line 1 of 10'));
    Insert(NewStr('This line is selected'));
    Insert(NewStr('This line is normal'));
    Insert(NewStr('This is line 4 of 10'));
    Insert(NewStr('This is line 5 of 10'));
    Insert(NewStr('This is line 6 of 10'));
    Insert(NewStr('This is line 7 of 10'));
    Insert(NewStr('This is line 8 of 10'));
    Insert(NewStr('This is line 9 of 10'));
    Insert(NewStr('This is line 10 of 10'));
  end;
  NewTextCollection := C;
end;

function NewWinInterior(var R: TRect; SB: PScrollBar): PWinInterior;
var
  Interior: PWinInterior;
begin
  Interior := New(PWinInterior, Init(R, nil, SB));
  Interior^.Lines := NewTextCollection;
  Interior^.SetLimit(0,10);
  Interior^.GrowMode := gfGrowHiX + gfGrowHiY;
  NewWinInterior := Interior;
end;

function NewWindow(wType: ColorWindowType; ATitle: TTitleStr): PWindow;
var
  W: PWindow;
  R: TRect;
  SB: PScrollBar;
begin
  R.Assign(0,0,23,7);
  W := New(PColorWindow, Init(R, ATitle, @WindowPalettes[wType]));
  with W^ do
  begin
    NoBuf(Options);
    SB := StandardScrollBar(sbVertical);
    Insert(SB);
    GetExtent(R);
    R.Grow(-1,-1);
    Insert(NewWinInterior(R,SB));
  end;
  NewWindow := W;
end;


function NewClusterDialog: PDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
begin
  R.Assign(0,0,30,14);
  D := New(PDialog, Init(R, 'Clusters'));
  with D^ do
  begin
    Options := Options or ofCentered;
    NoBuf(Options);
    R.Assign(2,2,15,5);
    P := New(PCheckBoxes, Init(R, NewSItem('Check ~1~',
                                  NewSItem('Check ~2~',
                                  NewSItem('Check ~3~',
                                  nil)))));
    Insert(P);
    R.Assign(1,1,15,2);
    Insert(New(PLabel, Init(R, '~C~heck Boxes', P)));

    R.Assign(2,7,15,10);
    P := New(PRadioButtons, Init(R, NewSItem('Radio ~X~',
                                    NewSItem('Radio ~Y~',
                                    NewSItem('Radio ~Z~',
                                    nil)))));
    Insert(P);
    R.Assign(1,6,15,7);
    Insert(New(PLabel, Init(R, '~R~adio Buttons', P)));

    R.Assign(16,2,28,4);
    Insert(New(PButton, Init(R, '~D~efault', cmNothing, bfDefault)));
    R.Move(0,2);
    Insert(New(PButton, Init(R, '~N~ormal', cmNothing, bfNormal)));
    R.Move(0,2);
    Insert(New(PButton, Init(R, 'D~i~sabled', cmInactive, bfNormal)));

    R.Assign(2,11,28,12);
    Insert(New(PStaticText, Init(R, 'This is static text')));
  end;
  NewClusterDialog := D;
end;

function NewInputDialog: PDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
  H: PHistory;
begin
  R.Assign(0,0,39,8);
  D := New(PDialog, Init(R, 'InputLine'));
  with D^ do
  begin
    NoBuf(Options);
    R.Assign(2,3,25,4);
    P := New(PInputLine, Init(R, 80));
    Insert(P);
    R.Assign(1,2,28,3);
    Insert(New(PLabel, Init(R, '~I~nput Line', P)));
    R.Assign(25,3,28,4);
    H := New(PHistory, Init(R, PInputLine(P), 100));
    NoBuf(H^.Options);
    Insert(H);
    R.Assign(1,5,11,7);
    Insert(New(PButton, Init(R, '~D~efault', cmNothing, bfDefault)));
    R.Move(11,0);
    Insert(New(PButton, Init(R, '~N~ormal', cmNothing, bfNormal)));
    R.Move(11,0);
    Insert(New(PButton, Init(R, 'D~i~sabled', cmInactive, bfNormal)));
    SelectNext(False);
  end;
  NewInputDialog := D;
end;

function NewListBoxList: PTextCollection;
var
  C: PTextCollection;
begin
  C := New(PTextCollection, Init(10,0));
  with C^ do
  begin
    Insert(NewStr('Apple'));
    Insert(NewStr('Orange'));
    Insert(NewStr('Banana'));
    Insert(NewStr('Grape'));
    Insert(NewStr('Peach'));
    Insert(NewStr('Mango'));
    Insert(NewStr('Lemon'));
    Insert(NewStr('Lime'));
    Insert(NewStr('Raisin'));
  end;
  NewListBoxList := C;
end;

function NewListBoxDialog: PDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
  SB: PScrollBar;
  C: PTextCollection;
begin
  R.Assign(0,0,30,15);
  D := New(PDialog, Init(R, 'ListBox'));
  with D^ do
  begin
    NoBuf(Options);
    R.Assign(27,2,28,8);
    SB := New(PScrollBar, Init(R));
    Insert(SB);
    R.Assign(2,2,27,8);
    P := New(PListBox, Init(R, 2, SB));
    PListBox(P)^.NewList(NewListBoxList);
    Insert(P);
    R.Assign(1,1,15,2);
    Insert(New(PLabel, Init(R, '~L~ist Box', P)));
    R.Assign(2,9,14,11);
    Insert(New(PButton, Init(R, '~D~efault', cmNothing, bfDefault)));
  end;
  NewListBoxDialog := D;
end;

procedure TWorkDesktop.HandleEvent(var Event: TEvent);
var
  D: PFileDialog;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmCWindow: Insert(NewWindow(wcCyan, 'Cyan Window'));
      cmBWindow: Insert(NewWindow(wcBlue, 'Blue Window'));
      cmGWindow: Insert(NewWindow(wcGray, 'Gray Window'));
      cmDClusters: Insert(NewClusterDialog);
      cmDInputs: Insert(NewInputDialog);
      cmDListBox: Insert(NewListBoxDialog);
      else Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TTextCollection.FreeItem(Item: pointer);
begin
  if Item <> nil then DisposeStr(Item);
end;

function TPalApp.GetPalette: PPalette;
begin
  GetPalette := @AppPal;
end;

function TWorkWindow.GetPalette: PPalette;
begin
  GetPalette := @WinPal;
end;

function TWorkGroup.GetPalette: PPalette;
begin
  GetPalette := @GrpPal;
end;

procedure TWorkGroup.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmRefresh) then
  begin
    DT^.ReDraw;
    MB^.DrawView;
    SL^.DrawView;
  end;
end;


function PaletteNames: PTextCollection;
var
  C: PTextCollection;
begin
  C := New(PTextCollection, Init(64,0));
  with C^ do
  begin
    Insert(NewStr('Background'));
    Insert(NewStr('Normal text'));
    Insert(NewStr('Disabled text'));
    Insert(NewStr('Shortcut text'));
    Insert(NewStr('Normal selection'));
    Insert(NewStr('Disabled selection'));
    Insert(NewStr('Shortcut selection'));

    Insert(NewStr('Frame Passive (Blue)'));
    Insert(NewStr('Frame Active (Blue)'));
    Insert(NewStr('Frame Icon (Blue)'));
    Insert(NewStr('Scrollbar Page (Blue)'));
    Insert(NewStr('Scrollbar Reserved (Blue)'));
    Insert(NewStr('Scroller Normal Text (Blue)'));
    Insert(NewStr('Scroller Selected Text (Blue)'));
    Insert(NewStr('Reserved (Blue)'));

    Insert(NewStr('Frame Passive (Cyan)'));
    Insert(NewStr('Frame Active (Cyan)'));
    Insert(NewStr('Frame Icon (Cyan)'));
    Insert(NewStr('Scrollbar Page (Cyan)'));
    Insert(NewStr('Scrollbar Reserved (Cyan)'));
    Insert(NewStr('Scroller Normal Text (Cyan)'));
    Insert(NewStr('Scroller Selected Text (Cyan)'));
    Insert(NewStr('Reserved (Cyan)'));

    Insert(NewStr('Frame Passive (Gray)'));
    Insert(NewStr('Frame Active (Gray)'));
    Insert(NewStr('Frame Icon (Gray)'));
    Insert(NewStr('Scrollbar Page (Gray)'));
    Insert(NewStr('Scrollbar Reserved (Gray)'));
    Insert(NewStr('Scroller Normal Text (Gray)'));
    Insert(NewStr('Scroller Selected Text (Gray)'));
    Insert(NewStr('Reserved (Gray)'));

    Insert(NewStr('Frame Passive (Dlg)'));
    Insert(NewStr('Frame Active (Dlg)'));
    Insert(NewStr('Frame Icon (Dlg)'));
    Insert(NewStr('Scrollbar Page (Dlg)'));
    Insert(NewStr('Scrollbar Controls (Dlg)'));
    Insert(NewStr('Static Text'));
    Insert(NewStr('Label Normal'));
    Insert(NewStr('Label Highlight'));
    Insert(NewStr('Label Shortcut'));

    Insert(NewStr('Button Normal'));
    Insert(NewStr('Button Default'));
    Insert(NewStr('Button Selected'));
    Insert(NewStr('Button Disabled'));
    Insert(NewStr('Button Shortcut'));
    Insert(NewStr('Button Shadow'));
    Insert(NewStr('Cluster Normal'));
    Insert(NewStr('Cluster Selected'));
    Insert(NewStr('Cluster Shortcut'));

    Insert(NewStr('Inputline Normal'));
    Insert(NewStr('Inputline Selected'));
    Insert(NewStr('Inputline Arrows'));
    Insert(NewStr('History Arrow'));
    Insert(NewStr('History Sides'));
    Insert(NewStr('Scrollbar page (Hist)'));
    Insert(NewStr('Scrollbar controls (Hist)'));

    Insert(NewStr('Listviewer Normal'));
    Insert(NewStr('Listviewer Focused'));
    Insert(NewStr('Listviewer Selected'));
    Insert(NewStr('Listviewer Divider'));
    Insert(NewStr('InfoPane'));
    Insert(NewStr('Reserved'));
    Insert(NewStr('Reserved'));

  end;
  PaletteNames := C;
end;

procedure TPaletteList.FocusItem(Item: Integer);
var
  B: Byte;
begin
  inherited FocusItem(Item);
  B := Byte( AppPal[64 + Item] );
  Message(Owner, evBroadcast, cmNewColor, Pointer(B));
  Message(Owner, evBroadcast, cmColorSet, Pointer(B));
end;


procedure TWorkWindow.HandleEvent(var Event: TEvent);
var
  B, B2: Byte;
begin
  inherited HandleEvent(Event);

  if Event.What = evBroadcast then
  begin
    case Event.Command of
      cmColorBackgroundChanged:
        begin
          B := Byte( AppPal[ListBox^.Focused + 64] );
          B := (B and $0F) or (Event.InfoByte shl 4 and $F0);
        end;
      cmColorForegroundChanged:
        begin
          B := Byte( AppPal[ListBox^.Focused + 64] );
          B := (B and $F0) or (Event.InfoByte and $0F);
        end;
      else Exit;
    end;
    AppPal[ListBox^.Focused + 64] := Char(B);
    Message(Desktop, evBroadcast, cmRefresh, Pointer(B));
    Message(@Self, evBroadcast, cmNewColor, Pointer(B));
    ClearEvent(Event);
  end;
end;


procedure ShowDialog;
var
  R: TRect;
  W: PWorkWindow;
  G: PWorkGroup;
  P: PView;
  SB: PScrollBar;
begin
  Desktop^.GetExtent(R);
  R.A.X := R.B.X - 75;
  Dec(R.B.Y,2);
  W := New(PWorkWindow, Init(R, 'Color Selection'));
  with W^ do
  begin
    Options := Options or ofCentered;
    EventMask := EventMask or evBroadcast;

    R.Assign(35,2,36,12);
    SB := New(PScrollBar, Init(R));
    Insert(SB);
    R.Assign(1,2,35,12);
    ListBox := New(PPaletteList, Init(R, 1, SB));
    Insert(ListBox);
    ListBox^.NewList(PaletteNames);
    Dec(R.A.Y); R.B.Y := R.A.Y+1;
    Insert(New(PLabel, Init(R, '~I~tems', ListBox)));

    R.Assign(3, 13, 15, 17);
    ForSel := New(PColorSelector, Init(R, csForeground));
    Insert(ForSel);
    Dec(R.A.Y); R.B.Y := R.A.Y+1;
    Insert(New(PLabel, Init(R, '~F~oreground', ForSel)));

    R.Assign(18, 13, 30, 15);
    BackSel := New(PColorSelector, Init(R, csBackground));
    Insert(BackSel);
    Dec(R.A.Y); R.B.Y := R.A.Y+1;
    Insert(New(PLabel, Init(R, '~B~ackground', BackSel)));

    R.Assign(1,18,13,20);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfNormal)));

    GetExtent(R);
    R.Grow(-1,-1);
    R.A.X := R.B.X - 36;
    G := New(PWorkGroup, Init(R));
    Insert(G);

    with G^ do
    begin
      GrowMode := gfGrowHiX + gfGrowHiY;
      Options := Options or ofFramed;
      GetExtent(R); R.Grow(0,-1);
      DT := New(PWorkDesktop, Init(R));
      DT^.Options := DT^.Options and (not ofBuffered);
      Insert(DT);

      GetExtent(R);
      R.A.Y := R.B.Y - 1;
      SL := New(PStatusLine, Init(R,
        NewStatusDef(0, 0,
          NewStatusKey('~F1~ Active', 0, cmNothing,
          NewStatusKey('~F2~ Inactive', 0, cmInactive,
          nil)),
        nil)));
      Insert(SL);

      GetExtent(R); R.B.Y := R.A.Y + 1;
      MB := New(PMenuBar, Init(R, NewMenu(
             NewSubMenu('Fi~l~e', 0, NewMenu(
               NewItem('~A~ctive', 'F1', 0, cmNothing, 0,
               NewItem('~I~nactive', 'F2', 0, cmInactive, 0,
               nil))),
             NewSubMenu('~V~iews', 0, NewMenu(
               NewSubMenu('~W~indows...', 0, NewMenu(
                 NewItem('~B~lue Window', '', 0, cmBWindow, 0,
                 NewItem('~C~yan Window', '', 0, cmCWindow, 0,
                 NewItem('~G~ray Window', '', 0, cmGWindow, 0,
                 nil)))),
               NewSubMenu('~D~ialogs', 0, NewMenu(
                 NewItem('Dialog with TClusters','', 0, cmDClusters, 0,
                 NewItem('Dialog with TInputLine','', 0, cmDInputs, 0,
                 NewItem('Dialog with TListBox','', 0, cmDListBox, 0,
                 nil)))),
             nil))),
           nil)))));

      Insert(MB);
    end;
    ListBox^.FocusItem(ListBox^.Focused);
    SelectNext(False);

  end;
  Desktop^.ExecView(W);
  Dispose(W, Done);
end;

procedure TPalApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F2~ Save', kbF2, cmSavePalette,
      NewStatusKey('~F3~ Open', kbF3, cmOpenPalette,
      NewStatusKey('~F9~ Edit', kbF9, cmShowDialog,
      NewStatusKey('', kbF6, cmNext,
      nil))))),
    nil)
  ));
end;

procedure TPalApp.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmSavePalette) then
    SavePalette;
  if (Event.What = evCommand) and (Event.Command = cmOpenPalette) then
    OpenPalette;
  if (Event.What = evCommand) and (Event.Command = cmShowDialog) then
    ShowDialog;
end;


var
  A: TPalApp;

begin
  A.Init;
  A.DisableCommands([cmInactive]);
  A.Run;
  A.Done;
end.
