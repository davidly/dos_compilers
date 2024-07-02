{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit ASCIITab;

{$F+,O+,X+,S-,D-}

{ Ascii table viewer. See TVDEMO.PAS for an example program
  that uses this unit.
}

interface

uses Objects, App, Views, Drivers;

type
  PTable = ^TTable;
  TTable = object(TView)
    procedure Draw; virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
  end;

  PReport = ^TReport;
  TReport = object(TView)
    ASCIIChar: LongInt;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
    procedure Store(var S: TStream);
  end;

  PASCIIChart = ^TASCIIChart;
  TASCIIChart = object(TWindow)
    constructor Init;
  end;

const
  AsciiTableCommandBase: Word = 910;

  RTable: TStreamRec = (
     ObjType: 10030;
     VmtLink: Ofs(TypeOf(TTable)^);
     Load:    @TTable.Load;
     Store:   @TTable.Store
  );
  RReport: TStreamRec = (
     ObjType: 10031;
     VmtLink: Ofs(TypeOf(TReport)^);
     Load:    @TReport.Load;
     Store:   @TReport.Store
  );
  RASCIIChart: TStreamRec = (
     ObjType: 10032;
     VmtLink: Ofs(TypeOf(TASCIIChart)^);
     Load:    @TASCIIChart.Load;
     Store:   @TASCIIChart.Store
  );

procedure RegisterASCIITab;

implementation

const
  cmCharacterFocused = 0;

procedure TTable.Draw;
var
  Buf: TDrawBuffer;
  X, Y: Integer;
  Color: Byte;
begin
  Color := GetColor(6);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(Buf, ' ', Color, Size.X);
    for X := 0 to Size.X - 1 do
      MoveChar(Buf[x], Chr(32 * y + x), Color, 1);
    WriteLine(0, y, Size.X, 1, Buf);
  end;
  ShowCursor;
end;

procedure TTable.HandleEvent(var Event:TEvent);
var
  CurrentSpot: TPoint;

procedure CharFocused;
begin
  Message(Owner, evBroadcast, AsciiTableCommandBase + cmCharacterFocused,
    Pointer(Cursor.X + 32 * Cursor.Y));
end;

begin
  inherited HandleEvent(Event);
  if Event.What = evMouseDown then
  begin
    repeat
      if MouseInView(Event.Where) then
      begin
        MakeLocal(Event.Where, CurrentSpot);
        SetCursor(CurrentSpot.X, CurrentSpot.Y);
        CharFocused;
      end;
    until not MouseEvent(Event, evMouseMove);
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
    with Cursor do begin
      case Event.KeyCode of
        kbHome: SetCursor(0,0);
        kbEnd: SetCursor(Size.X - 1, Size.Y - 1);
        kbUp: if Y > 0 then SetCursor(X, Y - 1);
        kbDown: if Y < Size.Y - 1 then SetCursor(X, Y + 1);
        kbLeft: if X > 0 then SetCursor(X - 1, Y);
        kbRight: if X < Size.X - 1 then SetCursor(X + 1, Y);
      else
        SetCursor(ord(Event.CharCode) mod 32, ord(Event.CharCode) div 32);
      end;
      CharFocused;
      ClearEvent(Event);
    end;
end;

{ TReport }

constructor TReport.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(ASCIIChar, SizeOf(ASCIIChar));
end;

procedure TReport.Draw;
var
  Ch: LongInt;
  Color: Byte;
  Buf: TDrawBuffer;
  TempStr: string;
begin
  FormatStr(TempStr, '  Char: %c Decimal: %0#%3d Hex: %0#%02x  ', ASCIIChar);
  WriteStr(0, 0, TempStr, 6);
end;

procedure TReport.HandleEvent(var Event: TEvent);
var
  Table: PTable;
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = AsciiTableCommandBase + cmCharacterFocused then
    begin
      ASCIIChar := Event.InfoLong;
      DrawView;
    end;
end;

procedure TReport.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(ASCIIChar, SizeOf(ASCIIChar));
end;

constructor TASCIIChart.Init;
var
  R: TRect;
  Control: PVIew;
begin
  R.Assign(0, 0, 34, 12);
  TWindow.Init(R, 'ASCII Chart', wnNoNumber);
  Flags := Flags and not (wfGrow + wfZoom);
  Palette := wpGrayWindow;

  R.Grow(-1,-1);
  R.A.Y := R.B.Y - 1;
  Control := New(PReport, Init(R));
  with Control^ do
  begin
    Options := Options or ofFramed;
    EventMask := EventMask or evBroadcast;
  end;
  Insert(Control);

  GetExtent(R);
  R.Grow(-1,-1);
  R.B.Y := R.B.Y - 2;
  Control := New(PTable, Init(R));
  with Control^ do
  begin
    Options := Options or ofFramed or ofSelectable;
    BlockCursor;
  end;
  Insert(Control);
  Control^.Select;
end;

procedure RegisterASCIITab;
begin
  RegisterType(RTable);
  RegisterType(RReport);
  RegisterType(RASCIIChart);
end;

end.
