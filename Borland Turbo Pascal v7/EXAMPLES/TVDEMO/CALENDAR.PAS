{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit Calendar;

{$F+,O+,X+,S-,D-}

{ Calendar object for viewing a month at a time. See TVDEMO.PAS
  for an example program that uses this unit.
}

interface

uses Drivers, Objects, App, Views, Dos, Dialogs;

const

   DaysInMonth: array[1..12] of Byte =
     (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

   MonthStr: array[1..12] of string[10] =
     ('January   ',
      'February  ',
      'March     ',
      'April     ',
      'May       ',
      'June      ',
      'July      ',
      'August    ',
      'September ',
      'October   ',
      'November  ',
      'December  ');

type

 PCalendarView = ^TCalendarView;
 TCalendarView = object(TView)
   Year, Month, Days: Word;
   CurYear, CurMonth, CurDay : Word;
   constructor Init(Bounds: TRect);
   constructor Load(var S: TStream);
   procedure HandleEvent(var Event: TEvent); virtual;
   procedure Draw; virtual;
   procedure Store(var S: TStream);
 end;

 PCalendarWindow = ^TCalendarWindow;
 TCalendarWindow = object(TWindow)
   constructor Init;
 end;

const
  RCalendarView: TStreamRec = (
     ObjType: 10020;
     VmtLink: Ofs(TypeOf(TCalendarView)^);
     Load:    @TCalendarView.Load;
     Store:   @TCalendarView.Store
  );

const
  RCalendarWindow: TStreamRec = (
     ObjType: 10021;
     VmtLink: Ofs(TypeOf(TCalendarWindow)^);
     Load:    @TCalendarWindow.Load;
     Store:   @TCalendarWindow.Store
  );

procedure RegisterCalendar;

implementation

{ TCalendarWindow }
constructor TCalendarWindow.Init;
var
  R:TRect;
begin
  R.Assign(1, 1, 23, 11);
  inherited Init(R, 'Calendar', 0);
  Flags := Flags and not (wfZoom + wfGrow);    { Not resizeable }
  GrowMode :=0;
  Palette := wpCyanWindow;

  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PCalendarView, Init(R)));
end;

{ TCalendarView }
constructor TCalendarView.Init(Bounds: TRect);
var
  H: Word;
begin
  inherited Init(Bounds);
  Options := Options or ofSelectable;
  EventMask := EventMask or evMouseAuto;
  GetDate(CurYear, CurMonth, CurDay, H);
  Year := CurYear;
  Month := CurMonth;
  DrawView;
end;

constructor TCalendarView.Load(var S: TStream);
var
  H: Word;
begin
  inherited Load(S);
  GetDate(CurYear, CurMonth, CurDay, H);
  S.Read(Year, SizeOf(Year));
  S.Read(Month, SizeOf(Month));
end;

function DayOfWeek(Day, Month, Year: Integer) : Integer;
var
  century, yr, dw: Integer;
begin
  if Month < 3 then
  begin
    Inc(Month, 10);
    Dec(Year);
  end
  else
     Dec(Month, 2);
  century := Year div 100;
  yr := year mod 100;
  dw := (((26 * month - 2) div 10) + day + yr + (yr div 4) +
    (century div 4) - (2 * century)) mod 7;
  if dw < 0 then DayOfWeek := dw + 7
  else DayOfWeek := dw;
end;

procedure TCalendarView.Draw;
const
  Width = 20;
var
  i, j, DayOf, CurDays: Integer;
  S: String;
  B: array[0..Width] of Word;
  Color, BoldColor, SpecialColor: Byte;

function Num2Str(I: Integer): String;
var
  S:String;
begin
  Str(i:2, S);
  Num2Str := S;
end;

begin
  Color:= GetColor(6);
  BoldColor:= GetColor(7);
  DayOf := DayOfWeek(1, Month, Year);
  Days := DaysInMonth[Month] + Byte((Year mod 4 = 0) and (Month = 2));
  Str(Year:4, S);
  MoveChar(B, ' ', Color, Width);
  MoveStr(B, MonthStr[Month] + S+' '#30'  '#31, Color);
  WriteLine(0, 0, Width, 1, B);
  MoveChar(B, ' ', Color, Width);
  MoveStr(B, 'Su Mo Tu We Th Fr Sa', Color);
  WriteLine(0, 1, Width, 1, B);
  CurDays := 1 - DayOf;
  for i := 1 to 6 do
  begin
    MoveChar(B, ' ', Color, Width);
    for j := 0 to 6 do
    begin
      if (CurDays < 1) or (CurDays > Days) then
        MoveStr(B[J * 3], '   ', Color)
      else
        { if it is the current day }
        if (Year = CurYear) and (Month = CurMonth) and
          (CurDays = CurDay) then
          MoveStr(B[J * 3], Num2Str(CurDays), BoldColor)
        else
          MoveStr(B[J * 3], Num2Str(CurDays), Color);
      Inc(CurDays);
    end;
    WriteLine(0, i + 1, Width, 1, B);
  end;
end;

procedure TCalendarView.HandleEvent(var Event: TEvent);
var
  Point:TPoint;
  SelectDay: Word;
begin
  inherited HandleEvent(Event);
  if (State and sfSelected <> 0) then
  begin
    if Event.What and (evMouseDown + evMouseAuto) <> 0 then
    begin
      MakeLocal(Event.Where, Point);
      if ((Point.X = 15) and (Point.Y = 0)) then
      begin
        Inc(Month);
        if Month > 12 then
        begin
          Inc(Year);
          Month := 1;
        end;
        DrawView;
      end;
      if ((Point.X = 18) and (Point.Y = 0)) then
      begin
        Dec(Month);
        if Month < 1 then
        begin
          Dec(Year);
          Month := 12;
        end;
        DrawView;
      end;
    end
    else if Event.What = evKeyDown then
    begin
      if (Lo(Event.KeyCode) = byte('+')) or (Event.KeyCode = kbDown) then
      begin
        Inc(Month);
        if Month > 12 then
        begin
          Inc(Year);
          Month := 1;
        end;
      end;
      if (Lo(Event.KeyCode) = Byte('-')) or (Event.KeyCode = kbUp) then
      begin
        Dec(Month);
        if Month < 1 then
        begin
          Dec(Year);
          Month := 12;
        end;
      end;
      DrawView;
    end;
  end;
end;

procedure TCalendarView.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Year, SizeOf(Year));
  S.Write(Month, SizeOf(Month));
end;

procedure RegisterCalendar;
begin
  RegisterType(RCalendarView);
  RegisterType(RCalendarWindow);
end;

end.
