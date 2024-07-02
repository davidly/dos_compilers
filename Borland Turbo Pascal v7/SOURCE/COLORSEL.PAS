{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit ColorSel;

{$O+,F+,X+,I-,S-}

interface

uses Objects, Drivers, Views, Dialogs;

const
  cmColorForegroundChanged = 71;
  cmColorBackgroundChanged = 72;
  cmColorSet               = 73;
  cmNewColorItem           = 74;
  cmNewColorIndex          = 75;
  cmSaveColorIndex         = 76;

type

  { TColorItem }

  PColorItem = ^TColorItem;
  TColorItem = record
    Name: PString;
    Index: Byte;
    Next: PColorItem;
  end;

  { TColorGroup }

  PColorGroup = ^TColorGroup;
  TColorGroup = record
    Name:  PString;
    Index: Byte;
    Items: PColorItem;
    Next:  PColorGroup;
  end;

  { TColorIndexes }

  PColorIndex = ^TColorIndex;
  TColorIndex = record
    GroupIndex: byte;
    ColorSize: byte;
    ColorIndex: array[0..255] of byte;
  end;

  { TColorSelector }

  TColorSel = (csBackground, csForeground);

  PColorSelector = ^TColorSelector;
  TColorSelector = object(TView)
    Color: Byte;
    SelType: TColorSel;
    constructor Init(var Bounds: TRect; ASelType: TColorSel);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

  { TMonoSelector }

  PMonoSelector = ^TMonoSelector;
  TMonoSelector = object(TCluster)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Mark(Item: Integer): Boolean; virtual;
    procedure NewColor;
    procedure Press(Item: Integer); virtual;
    procedure MovedTo(Item: Integer); virtual;
  end;

  { TColorDisplay }

  PColorDisplay = ^TColorDisplay;
  TColorDisplay = object(TView)
    Color: ^Byte;
    Text: PString;
    constructor Init(var Bounds: TRect; AText: PString);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetColor(var AColor: Byte); virtual;
    procedure Store(var S: TStream);
  end;

  { TColorGroupList }

  PColorGroupList = ^TColorGroupList;
  TColorGroupList = object(TListViewer)
    Groups: PColorGroup;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar;
      AGroups: PColorGroup);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure FocusItem(Item: Integer); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    procedure SetGroupIndex(GroupNum, ItemNum: Byte);
    function GetGroup(GroupNum: Byte): PColorGroup;
    function GetGroupIndex(GroupNum: Byte): Byte;
    function GetNumGroups: byte;
  end;

  { TColorItemList }

  PColorItemList = ^TColorItemList;
  TColorItemList = object(TListViewer)
    Items: PColorItem;
    constructor Init(var Bounds: TRect; AScrollBar: PScrollBar;
      AItems: PColorItem);
    procedure FocusItem(Item: Integer); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  { TColorDialog }

  PColorDialog = ^TColorDialog;
  TColorDialog = object(TDialog)
    GroupIndex: byte;
    Display: PColorDisplay;
    Groups: PColorGroupList;
    ForLabel: PLabel;
    ForSel: PColorSelector;
    BakLabel: PLabel;
    BakSel: PColorSelector;
    MonoLabel: PLabel;
    MonoSel: PMonoSelector;
    Pal: TPalette;
    constructor Init(APalette: TPalette; AGroups: PColorGroup);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    procedure GetIndexes(var Colors: PColorIndex);
    procedure SetIndexes(var Colors: PColorIndex);
  end;

{ Pointer to saved color list item indexes }
const
  ColorIndexes: PColorIndex = nil;

{ Load and Store Palette routines }

procedure StoreIndexes(var S: TStream);
procedure LoadIndexes(var S: TStream);

{ Color list building routines }

function ColorItem(const Name: String; Index: Byte;
  Next: PColorItem): PColorItem;
function ColorGroup(const Name: String; Items: PColorItem;
  Next: PColorGroup): PColorGroup;

{ Standard color items functions }

function DesktopColorItems(const Next: PColorItem): PColorItem;
function MenuColorItems(const Next: PColorItem): PColorItem;
function DialogColorItems(Palette: Word; const Next: PColorItem): PColorItem;
function WindowColorItems(Palette: Word; const Next: PColorItem): PColorItem;

{ ColorSel registration procedure }

procedure RegisterColorSel;

{ Stream registration records }

const
  RColorSelector: TStreamRec = (
     ObjType: 21;
     VmtLink: Ofs(TypeOf(TColorSelector)^);
     Load:    @TColorSelector.Load;
     Store:   @TColorSelector.Store
  );

const
  RMonoSelector: TStreamRec = (
     ObjType: 22;
     VmtLink: Ofs(TypeOf(TMonoSelector)^);
     Load:    @TMonoSelector.Load;
     Store:   @TMonoSelector.Store
  );

const
  RColorDisplay: TStreamRec = (
     ObjType: 23;
     VmtLink: Ofs(TypeOf(TColorDisplay)^);
     Load:    @TColorDisplay.Load;
     Store:   @TColorDisplay.Store
  );

const
  RColorGroupList: TStreamRec = (
     ObjType: 24;
     VmtLink: Ofs(TypeOf(TColorGroupList)^);
     Load:    @TColorGroupList.Load;
     Store:   @TColorGroupList.Store
  );

const
  RColorItemList: TStreamRec = (
     ObjType: 25;
     VmtLink: Ofs(TypeOf(TColorItemList)^);
     Load:    @TColorItemList.Load;
     Store:   @TColorItemList.Store
  );

const
  RColorDialog: TStreamRec = (
     ObjType: 26;
     VmtLink: Ofs(TypeOf(TColorDialog)^);
     Load:    @TColorDialog.Load;
     Store:   @TColorDialog.Store
  );

implementation

{ TColorSelector }

constructor TColorSelector.Init(var Bounds: TRect; ASelType: TColorSel);
begin
  TView.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick + ofFramed);
  EventMask := EventMask or evBroadcast;
  SelType := ASelType;
  Color := 0;
end;

constructor TColorSelector.Load(var S: TStream);
begin
  TView.Load(S);
  S.Read(Color, SizeOf(Byte) + SizeOf(TColorSel));
end;

procedure TColorSelector.Draw;
var
  B: TDrawBuffer;
  C, I, J: Integer;
begin
  MoveChar(B, ' ', $70, Size.X);
  for I := 0 to Size.Y do
  begin
    if I < 4 then
      for J := 0 to 3 do
      begin
        C := I * 4 + J;
        MoveChar(B[ J*3 ], #219, C, 3);
        if C = Byte(Color) then
        begin
          WordRec(B[ J*3+1 ]).Lo := 8;
          if C = 0 then WordRec(B[ J*3+1 ]).Hi := $70;
        end;
      end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TColorSelector.HandleEvent(var Event: TEvent);
const
  Width = 4;
var
  MaxCol: Byte;
  Mouse: TPoint;
  OldColor: Byte;

procedure ColorChanged;
var
  Msg: Integer;
begin
  if SelType = csForeground then
    Msg := cmColorForegroundChanged else
    Msg := cmColorBackgroundChanged;
  Message(Owner, evBroadcast, Msg, Pointer(Color));
end;

begin
  TView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        OldColor := Color;
        repeat
          if MouseInView(Event.Where) then
          begin
            MakeLocal(Event.Where, Mouse);
            Color := Mouse.Y * 4 + Mouse.X div 3;
          end
          else
            Color := OldColor;
          ColorChanged;
          DrawView;
        until not MouseEvent(Event, evMouseMove);
      end;
    evKeyDown:
      begin
        if SelType = csBackground then
          MaxCol := 7 else
          MaxCol := 15;
        case CtrlToArrow(Event.KeyCode) of
          kbLeft:
            if Color > 0 then
              Dec(Color) else
              Color := MaxCol;
          kbRight:
            if Color < MaxCol then
              Inc(Color) else
              Color := 0;
          kbUp:
            if Color > Width - 1 then
              Dec(Color, Width) else
              if Color = 0 then
                Color := MaxCol else
                Inc(Color, MaxCol - Width);
          kbDown:
            if Color < MaxCol - (Width - 1) then
              Inc(Color, Width) else
              if Color = MaxCol then
                Color := 0 else
                Dec(Color, MaxCol - Width);
        else
          Exit;
        end;
      end;
    evBroadcast:
      if Event.Command = cmColorSet then
      begin
        if SelType = csBackground then
          Color := Event.InfoByte shr 4 else
          Color := Event.InfoByte and $0F;
        DrawView;
        Exit;
      end else Exit;
  else
    Exit;
  end;
  DrawView;
  ColorChanged;
  ClearEvent(Event);
end;

procedure TColorSelector.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Color, SizeOf(Byte) + SizeOf(TColorSel));
end;

{ TMonoSelector }

const
  MonoColors: array[0..4] of Byte = ($07, $0F, $01, $70, $09);

constructor TMonoSelector.Init(var Bounds: TRect);
begin
  TCluster.Init(Bounds,
    NewSItem('Normal',
    NewSItem('Highlight',
    NewSItem('Underline',
    NewSItem('Inverse', nil)))));
  EventMask := EventMask or evBroadcast;
end;

procedure TMonoSelector.Draw;
const
  Button = ' ( ) ';
begin
  DrawBox(Button, #7);
end;

procedure TMonoSelector.HandleEvent(var Event: TEvent);
begin
  TCluster.HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmColorSet) then
  begin
    Value := Event.InfoByte;
    DrawView;
  end;
end;

function TMonoSelector.Mark(Item: Integer): Boolean;
begin
  Mark := MonoColors[Item] = Value;
end;

procedure TMonoSelector.NewColor;
begin
  Message(Owner, evBroadcast, cmColorForegroundChanged,
    Pointer(Value and $0F));
  Message(Owner, evBroadcast, cmColorBackgroundChanged,
    Pointer((Value shr 4) and $0F));
end;

procedure TMonoSelector.Press(Item: Integer);
begin
  Value := MonoColors[Item];
  NewColor;
end;

procedure TMonoSelector.MovedTo(Item: Integer);
begin
  Value := MonoColors[Item];
  NewColor;
end;

{ TColorDisplay }

constructor TColorDisplay.Init(var Bounds: TRect; AText: PString);
begin
  TView.Init(Bounds);
  EventMask := EventMask or evBroadcast;
  Text := AText;
  Color := nil;
end;

constructor TColorDisplay.Load(var S: TStream);
begin
  TView.Load(S);
  Text := S.ReadStr;
end;

destructor TColorDisplay.Done;
begin
  DisposeStr(Text);
  TView.Done;
end;

procedure TColorDisplay.Draw;
var
  B: TDrawBuffer;
  I: Integer;
  C: Byte;
begin
  C := Color^;
  if C = 0 then C := ErrorAttr;
  for I := 0 to Size.X div Length(Text^) do
    MoveStr(B[I*Length(Text^)], Text^, C);
  WriteLine(0, 0, Size.X, Size.Y, B);
end;
 
procedure TColorDisplay.HandleEvent(var Event: TEvent);
begin
  TView.HandleEvent(Event);
  case Event.What of
    evBroadcast:
      case Event.Command of
        cmColorBackgroundChanged:
          begin
            Color^ := (Color^ and $0F) or (Event.InfoByte shl 4 and $F0);
            DrawView;
          end;
        cmColorForegroundChanged:
          begin
            Color^ := (Color^ and $F0) or (Event.InfoByte and $0F);
            DrawView;
          end;
      end;
  end;
end;

procedure TColorDisplay.SetColor(var AColor: Byte);
begin
  Color := @AColor;
  Message(Owner, evBroadcast, cmColorSet, Pointer(Color^));
  DrawView;
end;

procedure TColorDisplay.Store(var S: TStream);
begin
  TView.Store(S);
  S.WriteStr(Text);
end;

{ TColorGroupList }

constructor TColorGroupList.Init(var Bounds: TRect; AScrollBar: PScrollBar;
  AGroups: PColorGroup);
var
  I: Integer;
begin
  TListViewer.Init(Bounds, 1, nil, AScrollBar);
  Groups := AGroups;
  I := 0;
  while AGroups <> nil do
  begin
    AGroups := AGroups^.Next;
    Inc(I);
  end;
  SetRange(I);
end;

constructor TColorGroupList.Load(var S: TStream);

function ReadItems: PColorItem;
var
  Itms:  PColorItem;
  CurItm: ^PColorItem;
  Count, I: Integer;
begin
  S.Read(Count, SizeOf(Integer));
  Itms := nil;
  CurItm := @Itms;
  for I := 1 to Count do
  begin
    New(CurItm^);
    with CurItm^^ do
    begin
      Name := S.ReadStr;
      S.Read(Index, SizeOf(Byte));
    end;
    CurItm := @CurItm^^.Next;
  end;
  CurItm^ := nil;
  ReadItems := Itms;
end;

function ReadGroups: PColorGroup;
var
  Grps:  PColorGroup;
  CurGrp: ^PColorGroup;
  Count, I: Integer;
begin
  S.Read(Count, SizeOf(Integer));
  Grps := nil;
  CurGrp := @Grps;
  for I := 1 to Count do
  begin
    New(CurGrp^);
    with CurGrp^^ do
    begin
      Name := S.ReadStr;
      Items := ReadItems;
    end;
    CurGrp := @CurGrp^^.Next;
  end;
  CurGrp^ := nil;
  ReadGroups := Grps;
end;

begin
  TListViewer.Load(S);
  Groups := ReadGroups;
end;

destructor TColorGroupList.Done;

procedure FreeItems(CurITem: PColorItem);
var
  P: PColorItem;
begin
  while CurItem <> nil do
  begin
    P := CurItem;
    DisposeStr(CurItem^.Name);
    CurItem := CurItem^.Next;
    Dispose(P);
  end;
end;

procedure FreeGroups(CurGroup: PColorGroup);
var
  P: PColorGroup;
begin
  while CurGroup <> nil do
  begin
    P := CurGroup;
    FreeItems(CurGroup^.Items);
    DisposeStr(CurGroup^.Name);
    CurGroup := CurGroup^.Next;
    Dispose(P);
  end
end;

begin
  TListViewer.Done;
  FreeGroups(Groups);
end;

procedure TColorGroupList.FocusItem(Item: Integer);
var
  CurGroup: PColorGroup;
begin
  TListViewer.FocusItem(Item);
  CurGroup := Groups;
  while Item > 0 do
  begin
    CurGroup := CurGroup^.Next;
    Dec(Item);
  end;
  Message(Owner, evBroadcast, cmNewColorItem, CurGroup);
end;

function TColorGroupList.GetText(Item: Integer; MaxLen: Integer): String;
var
  CurGroup: PColorGroup;
  I: Integer;
begin
  CurGroup := Groups;
  while Item > 0 do
  begin
    CurGroup := CurGroup^.Next;
    Dec(Item);
  end;
  GetText := CurGroup^.Name^;
end;

procedure TColorGroupList.Store(var S: TStream);

procedure WriteItems(Items: PColorItem);
var
  CurItm: PColorItem;
  Count: Integer;
begin
  Count := 0;
  CurItm := Items;
  while CurItm <> nil do
  begin
    CurItm := CurItm^.Next;
    Inc(Count);
  end;
  S.Write(Count, SizeOf(Integer));
  CurItm := Items;
  while CurItm <> nil do
  begin
    with CurItm^ do
    begin
      S.WriteStr(Name);
      S.Write(Index, SizeOf(Byte));
    end;
    CurItm := CurItm^.Next;
  end;
end;

procedure WriteGroups(Groups: PColorGroup);
var
  CurGrp: PColorGroup;
  Count: Integer;
begin
  Count := 0;
  CurGrp := Groups;
  while CurGrp <> nil do
  begin
    CurGrp := CurGrp^.Next;
    Inc(Count);
  end;
  S.Write(Count, SizeOf(Integer));
  CurGrp := Groups;
  while CurGrp <> nil do
  begin
    with CurGrp^ do
    begin
      S.WriteStr(Name);
      WriteItems(Items);
    end;
    CurGrp := CurGrp^.Next;
  end;
end;

begin
  TListViewer.Store(S);
  WriteGroups(Groups);
end;

procedure TColorGroupList.HandleEvent(var Event: TEvent);
begin
  TListViewer.HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = cmSaveColorIndex then
      SetGroupIndex(Focused, Event.InfoByte);
end;

procedure TColorGroupList.SetGroupIndex(GroupNum, ItemNum: Byte);
var
  Group: PColorGroup;
begin
  Group := GetGroup(GroupNum);
  if Group <> nil then
    Group^.Index := ItemNum;
end;

function TColorGroupList.GetGroupIndex(GroupNum: Byte): byte;
var
  Group: PColorGroup;
begin
  Group := GetGroup(GroupNum);
  if Group <> nil then
    GetGroupIndex := Group^.Index
  else
    GetGroupIndex := 0;
end;

function TColorGroupList.GetGroup(GroupNum: Byte): PColorGroup;
var
  Group: PColorGroup;
begin
  Group := Groups;
  while GroupNum > 0 do
  begin
    Group := Group^.Next;
    Dec(GroupNum);
  end;
  GetGroup := Group;
end;

function TColorGroupList.GetNumGroups: byte;
var
  Index: byte;
  Group: PColorGroup;
begin
  Index := 0;
  Group := Groups;
  while Group <> nil do
  begin
    Inc(Index);
    Group := Group^.Next;
  end;
  GetNumGroups := Index;
end;

{ TColorItemList }

constructor TColorItemList.Init(var Bounds: TRect; AScrollBar: PScrollBar;
  AItems: PColorItem);
var
  I: Integer;
begin
  TListViewer.Init(Bounds, 1, nil, AScrollBar);
  EventMask := EventMask or evBroadcast;
  Items := AItems;
  I := 0;
  while AItems <> nil do
  begin
    AItems := AItems^.Next;
    Inc(I);
  end;
  SetRange(I);
end;

procedure TColorItemList.FocusItem(Item: Integer);
var
  CurItem: PColorItem;
begin
  TListViewer.FocusItem(Item);
  Message(Owner, evBroadcast, cmSaveColorIndex, Pointer(Item));
  CurItem := Items;
  while Item > 0 do
  begin
    CurItem := CurItem^.Next;
    Dec(Item);
  end;
  Message(Owner, evBroadcast, cmNewColorIndex, Pointer(CurItem^.Index));
end;

function TColorItemList.GetText(Item: Integer; MaxLen: Integer): String;
var
  CurItem: PColorItem;
begin
  CurItem := Items;
  while Item > 0 do
  begin
    CurItem := CurItem^.Next;
    Dec(Item);
  end;
  GetText := CurItem^.Name^;
end;

procedure TColorItemList.HandleEvent(var Event: TEvent);
var
  CurItem: PColorItem;
  Group: PColorGroup;
  I: Integer;
begin
  TListViewer.HandleEvent(Event);
  if Event.What = evBroadcast then
  case Event.Command of
    cmNewColorItem:
      begin
        Group := Event.InfoPtr;
        Items := Group^.Items;
        CurItem := Items;
        I := 0;
        while CurItem <> nil do
        begin
          CurItem := CurItem^.Next;
          Inc(I);
        end;
        SetRange(I);
        FocusItem(Group^.Index);
        DrawView;
      end;
  end;
end;

{ TColorDialog }

constructor TColorDialog.Init(APalette: TPalette; AGroups: PColorGroup);
var
  R: TRect;
  P: PView;
begin
  R.Assign(0, 0, 61, 18);
  TDialog.Init(R, 'Colors');
  Options := Options or ofCentered;
  Pal := APalette;

  R.Assign(18, 3, 19, 14);
  P := New(PScrollBar, Init(R));
  Insert(P);
  R.Assign(3, 3, 18, 14);
  Groups := New(PColorGroupList, Init(R, PScrollBar(P), AGroups));
  Insert(Groups);
  R.Assign(2, 2, 8, 3);
  Insert(New(PLabel, Init(R, '~G~roup', Groups)));

  R.Assign(41, 3, 42, 14);
  P := New(PScrollBar, Init(R));
  Insert(P);
  R.Assign(21, 3, 41, 14);
  P := New(PColorItemList, Init(R, PScrollBar(P), AGroups^.Items));
  Insert(P);
  R.Assign(20, 2, 25, 3);
  Insert(New(PLabel, Init(R, '~I~tem', P)));

  R.Assign(45, 3, 57, 7);
  ForSel := New(PColorSelector, Init(R, csForeground));
  Insert(ForSel);
  Dec(R.A.Y); R.B.Y := R.A.Y+1;
  ForLabel := New(PLabel, Init(R, '~F~oreground', ForSel));
  Insert(ForLabel);

  Inc(R.A.Y, 7); Inc(R.B.Y,8);
  BakSel := New(PColorSelector, Init(R, csBackground));
  Insert(BakSel);
  Dec(R.A.Y); R.B.Y := R.A.Y+1;
  BakLabel := New(PLabel, Init(R, '~B~ackground', BakSel));
  Insert(BakLabel);

  Dec(R.A.X); Inc(R.B.X); Inc(R.A.Y, 4); Inc(R.B.Y, 5);
  Display := New(PColorDisplay, Init(R, NewStr('Text ')));
  Insert(Display);

  R.Assign(44, 3, 59, 8);
  MonoSel := New(PMonoSelector, Init(R));
  MonoSel^.Hide;
  Insert(MonoSel);
  R.Assign(43, 2, 49, 3);
  MonoLabel := New(PLabel, Init(R, '~C~olor', MonoSel));
  MonoLabel^.Hide;
  Insert(MonoLabel);

  if (AGroups <> nil) and (AGroups^.Items <> nil) then
    Display^.SetColor(Byte(Pal[AGroups^.Items^.Index]));

  R.Assign(36, 15, 46, 17);
  P := New(PButton, Init(R, 'O~K~', cmOk, bfDefault));
  Insert(P);
  R.Assign(48, 15, 58, 17);
  P := New(PButton, Init(R, 'Cancel', cmCancel, bfNormal));
  Insert(P);
  SelectNext(False);
end;

constructor TColorDialog.Load(var S: TStream);
var
  Len: Byte;
begin
  TDialog.Load(S);
  GetSubViewPtr(S, Display);
  GetSubViewPtr(S, Groups);
  GetSubViewPtr(S, ForLabel);
  GetSubViewPtr(S, ForSel);
  GetSubViewPtr(S, BakLabel);
  GetSubViewPtr(S, BakSel);
  GetSubViewPtr(S, MonoLabel);
  GetSubViewPtr(S, MonoSel);
  S.Read(Len, SizeOf(Byte));
  S.Read(Pal[1], Len);
  Pal[0] := Char(Len);
end;

procedure TColorDialog.HandleEvent(var Event: TEvent);
var
  C: Byte;
  ItemList: PColorItemList;
begin
  if Event.What = evBroadcast then
    if Event.Command = cmNewColorItem then
      GroupIndex := Groups^.Focused;
  TDialog.HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = cmNewColorIndex then
      Display^.SetColor(Byte(Pal[Event.InfoByte]));
end;

procedure TColorDialog.Store(var S: TStream);
begin
  TDialog.Store(S);
  PutSubViewPtr(S, Display);
  PutSubViewPtr(S, Groups);
  PutSubViewPtr(S, ForLabel);
  PutSubViewPtr(S, ForSel);
  PutSubViewPtr(S, BakLabel);
  PutSubViewPtr(S, BakSel);
  PutSubViewPtr(S, MonoLabel);
  PutSubViewPtr(S, MonoSel);
  S.Write(Pal, Length(Pal)+1);
end;

function TColorDialog.DataSize: Word;
begin
  DataSize := SizeOf(TPalette);
end;

procedure TColorDialog.GetData(var Rec);
begin
  GetIndexes(ColorIndexes);
  String(Rec) := Pal;
end;

procedure TColorDialog.SetData(var Rec);
{var
  Item: PColorItem;
  Index: byte;}
begin
  Pal := String(Rec);
  SetIndexes(ColorIndexes);
{  Display^.SetColor(Byte(Pal[Groups^.GetGroupIndex(GroupIndex)]));}
  Groups^.FocusItem(GroupIndex);
  if ShowMarkers then
  begin
    ForLabel^.Hide;
    ForSel^.Hide;
    BakLabel^.Hide;
    BakSel^.Hide;
    MonoLabel^.Show;
    MonoSel^.Show;
  end;
  Groups^.Select;
end;

procedure TColorDialog.SetIndexes(var Colors: PColorIndex);
var
  NumGroups, Index: byte;
begin
  NumGroups := Groups^.GetNumGroups;
  if (Colors <> nil) and (Colors^.ColorSize <> NumGroups) then
  begin
    FreeMem(Colors, 2 + Colors^.ColorSize);
    Colors := nil;
  end;
  if Colors = nil then
  begin
    GetMem(Colors, 2 + NumGroups);
    fillchar(Colors^, 2 + NumGroups, 0);
    Colors^.ColorSize := NumGroups;
  end;
  for Index := 0 to NumGroups - 1 do
    Groups^.SetGroupIndex(Index, Colors^.ColorIndex[Index]);
  GroupIndex := Colors^.GroupIndex;
end;

procedure TColorDialog.GetIndexes(var Colors: PColorIndex);
var
  NumGroups, Index: Byte;
begin
  NumGroups := Groups^.GetNumGroups;
  if Colors = nil then
  begin
    GetMem(Colors, 2 + NumGroups);
    fillchar(Colors^, 2 + NumGroups, 0);
    Colors^.ColorSize := NumGroups;
  end;
  Colors^.GroupIndex := GroupIndex;
  for Index := 0 to NumGroups - 1 do
    Colors^.ColorIndex[Index] := Groups^.GetGroupIndex(Index);
end;

{ Load and Store Palette routines }

procedure LoadIndexes(var S: TStream);
var
  ColorSize: byte;
begin
  S.Read(ColorSize, sizeof(ColorSize));
  if ColorSize > 0 then
  begin
    if ColorIndexes <> nil then
      FreeMem(ColorIndexes, 2 + ColorIndexes^.ColorSize);
    getmem(ColorIndexes, ColorSize);
    S.Read(ColorIndexes^, ColorSize);
  end;
end;

procedure StoreIndexes(var S: TStream);
var
  ColorSize: byte;
begin
  if ColorIndexes <> nil then
    ColorSize := 2 + ColorIndexes^.ColorSize
  else
    ColorSize := 0;
  S.Write(ColorSize, sizeof(ColorSize));
  if ColorSize > 0 then
    S.Write(ColorIndexes^, ColorSize);
end;

{ -- Color list building routines -- }

function ColorItem(const Name: String; Index: Byte;
  Next: PColorItem): PColorItem;
var
  Item: PColorItem;
begin
  New(Item);
  Item^.Name := NewStr(Name);
  Item^.Index := Index;
  Item^.Next := Next;
  ColorItem := Item;
end;

function ColorGroup(const Name: String; Items: PColorItem;
  Next: PColorGroup): PColorGroup;
var
  Group: PColorGroup;
begin
  New(Group);
  Group^.Name := NewStr(Name);
  Group^.Items := Items;
  Group^.Next := Next;
  ColorGroup := Group;
end;

{ Standard color items functions }

function DesktopColorItems(const Next: PColorItem): PColorItem;
begin
  DesktopColorItems :=
    ColorItem('Color',             1,
    Next);
end;

function MenuColorItems(const Next: PColorItem): PColorItem;
begin
  MenuColorItems :=
    ColorItem('Normal',            2,
    ColorItem('Disabled',          3,
    ColorItem('Shortcut',          4,
    ColorItem('Selected',          5,
    ColorItem('Selected disabled', 6,
    ColorItem('Shortcut selected', 7,
    Next))))));
end;

function DialogColorItems(Palette: Word; const Next: PColorItem): PColorItem;
const
  COffset: array[dpBlueDialog..dpGrayDialog] of Byte =
    (64, 96, 32);
  var
    Offset: Byte;
begin
  Offset := COffset[Palette];
  DialogColorItems :=
    ColorItem('Frame/background',  Offset + 1,
    ColorItem('Frame icons',       Offset + 2,
    ColorItem('Scroll bar page',   Offset + 3,
    ColorItem('Scroll bar icons',  Offset + 4,
    ColorItem('Static text',       Offset + 5,

    ColorItem('Label normal',      Offset + 6,
    ColorItem('Label selected',    Offset + 7,
    ColorItem('Label shortcut',    Offset + 8,

    ColorItem('Button normal',     Offset + 9,
    ColorItem('Button default',    Offset + 10,
    ColorItem('Button selected',   Offset + 11,
    ColorItem('Button disabled',   Offset + 12,
    ColorItem('Button shortcut',   Offset + 13,
    ColorItem('Button shadow',     Offset + 14,

    ColorItem('Cluster normal',    Offset + 15,
    ColorItem('Cluster selected',  Offset + 16,
    ColorItem('Cluster shortcut',  Offset + 17,

    ColorItem('Input normal',      Offset + 18,
    ColorItem('Input selected',    Offset + 19,
    ColorItem('Input arrow',       Offset + 20,

    ColorItem('History button',    Offset + 21,
    ColorItem('History sides',     Offset + 22,
    ColorItem('History bar page',  Offset + 23,
    ColorItem('History bar icons', Offset + 24,

    ColorItem('List normal',       Offset + 25,
    ColorItem('List focused',      Offset + 26,
    ColorItem('List selected',     Offset + 27,
    ColorItem('List divider',      Offset + 28,

    ColorItem('Information pane',  Offset + 29,
    Next)))))))))))))))))))))))))))));
end;

function WindowColorItems(Palette: Word;
  const Next: PColorItem): PColorItem;
const
  COffset: array[wpBlueWindow..wpGrayWindow] of Byte =
    (8, 16, 24);
var
  Offset: Word;
begin
  Offset := COffset[Palette];
  WindowColorItems :=
    ColorItem('Frame passive',     Offset + 0,
    ColorItem('Frame active',      Offset + 1,
    ColorItem('Frame icons',       Offset + 2,
    ColorItem('Scroll bar page',   Offset + 3,
    ColorItem('Scroll bar icons',  Offset + 4,
    ColorItem('Normal text',       Offset + 5,
    Next))))));
end;

{ ColorSel registration procedure }

procedure RegisterColorSel;
begin
  RegisterType(RColorSelector);
  RegisterType(RMonoSelector);
  RegisterType(RColorDisplay);
  RegisterType(RColorGroupList);
  RegisterType(RColorItemList);
  RegisterType(RColorDialog);
end;

end.
