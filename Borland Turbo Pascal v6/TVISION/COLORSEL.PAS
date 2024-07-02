
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 6.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1990 Borland International        }
{                                                       }
{*******************************************************}

unit ColorSel;

{$F+,O+,X+,D-}

interface

uses Objects, Drivers, Views, Dialogs;

const
  cmColorForegroundChanged = 71;
  cmColorBackgroundChanged = 72;
  cmColorSet               = 73;
  cmNewColorItem           = 74;
  cmNewColorIndex          = 75;

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
    Items: PColorItem;
    Next:  PColorGroup;
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
    procedure Store(var S: TStream);
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
  end;

{ Color list building routines }

function ColorItem(Name: String; Index: Byte; Next: PColorItem): PColorItem;
function ColorGroup(Name: String; Items: PColorItem; Next: PColorGroup):
  PColorGroup;

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
  RMonoSelector: TStreamRec = (
     ObjType: 22;
     VmtLink: Ofs(TypeOf(TMonoSelector)^);
     Load:    @TMonoSelector.Load;
     Store:   @TMonoSelector.Store
  );
  RColorDisplay: TStreamRec = (
     ObjType: 23;
     VmtLink: Ofs(TypeOf(TColorDisplay)^);
     Load:    @TColorDisplay.Load;
     Store:   @TColorDisplay.Store
  );
  RColorGroupList: TStreamRec = (
     ObjType: 24;
     VmtLink: Ofs(TypeOf(TColorGroupList)^);
     Load:    @TColorGroupList.Load;
     Store:   @TColorGroupList.Store
  );
  RColorItemList: TStreamRec = (
     ObjType: 25;
     VmtLink: Ofs(TypeOf(TColorItemList)^);
     Load:    @TColorItemList.Load;
     Store:   @TColorItemList.Store
  );
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
  Message(Owner, evBroadcast, cmNewColorItem, CurGroup^.Items);
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
  I: Integer;
begin
  TListViewer.HandleEvent(Event);
  case Event.What of
    evBroadcast:
      if Event.Command = cmNewColorItem then
      begin
        Items := Event.InfoPtr;
        CurItem := Items;
        I := 0;
        while CurItem <> nil do
        begin
          CurItem := CurItem^.Next;
          Inc(I);
        end;
        SetRange(I);
        FocusItem(0);
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
begin
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
  String(Rec) := Pal;
end;

procedure TColorDialog.SetData(var Rec);
begin
  Pal := String(Rec);
  Display^.SetColor(Byte(Pal[1]));
  Groups^.FocusItem(0);
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

{ -- Color list building routines -- }

function ColorItem(Name: String; Index: Byte; Next: PColorItem): PColorItem;
var
  Item: PColorItem;
begin
  New(Item);
  Item^.Name := NewStr(Name);
  Item^.Index := Index;
  Item^.Next := Next;
  ColorItem := Item;
end;

function ColorGroup(Name: String; Items: PColorItem; Next: PColorGroup):
  PColorGroup;
var
  Group: PColorGroup;
begin
  New(Group);
  Group^.Name := NewStr(Name);
  Group^.Items := Items;
  Group^.Next := Next;
  ColorGroup := Group;
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
