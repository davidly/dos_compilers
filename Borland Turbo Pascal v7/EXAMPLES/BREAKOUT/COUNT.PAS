{************************************************}
{                                                }
{   Breakout Demo Program                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Count;

{
  See BREAKOUT.PAS.
  This unit provides several text display object types, most of
  which are coupled with various types of counters.
}

interface

uses Screen;

const
  StrSize = 40;

type
  TextStr = String[StrSize];
  TextPtr = ^TextStr;

  TextString = object(Location)
    Text : TextPtr;
    Attr : Byte;
    constructor Init(InitX, InitY : Integer;
                     InitText : TextStr;
                     InitAttr : Byte);
    procedure Show; virtual;
    procedure Hide; virtual;
  end;

  Counter = object(TextString)
    Value : Integer;
    BaseValue : Integer;
    constructor Init(InitValue, InitX, InitY : Integer;
                     InitName : TextStr;
                     InitAttr : Byte);
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure ShowVal; virtual;
    procedure HideVal; virtual;
    procedure SetValue(NewValue : Integer);
    procedure Reset;
    procedure Increment;
    procedure Decrement;
    procedure Add(Incr : Integer);
    function Equal(TestValue : Integer) : Boolean;
    function GetValue : Integer;
  end;

  DownCounter = object(Counter)
    Minimum : Integer;
    constructor Init(InitValue, InitX, InitY, InitMin : Integer;
                     InitName : TextStr;
                     InitAttr : Byte);
    procedure Decrement;
    procedure Add(Incr : Integer);
    function Last : Boolean;
  end;

  LimitCounter = object(DownCounter)
    Maximum : Integer;
    constructor Init(InitValue, InitX, InitY, InitMin, InitMax : Integer;
                     InitName : TextStr;
                     InitAttr : Byte);
    procedure Increment;
    procedure Add(Incr : Integer);
  end;

implementation

uses Crt;

constructor TextString.Init(InitX, InitY : Integer;
                            InitText : TextStr;
                            InitAttr : Byte);
begin
  Location.Init(InitX, InitY);
  Attr := InitAttr;
  GetMem(Text, Length(InitText) + 1);
  Move(InitText, Text^, Length(InitText) + 1);
end;

procedure TextString.Show;
begin
  Visible := True;
  GoToXY(X, Y);
  TextColor(Attr);
  Write(Text^);
end;

procedure TextString.Hide;
begin
  Visible := False;
  GoToXY(X, Y);
  TextAttr := Attr;
  Write('' : Length(Text^));
end;

constructor Counter.Init(InitValue, InitX, InitY : Integer;
                         InitName : TextStr;
                         InitAttr : Byte);
begin
  TextString.Init(InitX, InitY, InitName, InitAttr);
  BaseValue := InitValue;
  Value := InitValue;
end;

procedure Counter.Show;
begin
  Visible := True;
  GoToXY(X, Y);
  TextColor(Attr);
  Write(Text^, ': ', Value);
end;

procedure Counter.Hide;
begin
  Visible := False;
  GoToXY(X, Y);
  TextAttr := Attr;
  Write('' : Length(Text^) + 7);
end;

procedure Counter.ShowVal;
begin
  Visible := True;
  GoToXY(X + Length(Text^) + 2, Y);
  TextColor(Attr);
  Write(Value);
end;

procedure Counter.HideVal;
begin
  Visible := False;
  GoToXY(X + Length(Text^) + 2, Y);
  TextAttr := Attr;
  Write('' : 5);
end;

procedure Counter.SetValue(NewValue : Integer);
var
  Vis : Boolean;
begin
  Vis := Visible;
  if Vis then
    HideVal;
  Value := NewValue;
  if Vis then
    ShowVal;
end;

procedure Counter.Increment;
begin
  SetValue(Value + 1);
end;

procedure Counter.Decrement;
begin
  SetValue(Value - 1);
end;

procedure Counter.Add(Incr : Integer);
begin
  SetValue(Value + Incr);
end;

procedure Counter.Reset;
begin
  SetValue(BaseValue);
end;

function Counter.Equal(TestValue : Integer) : Boolean;
begin
  Equal := (Value = TestValue);
end;

function Counter.GetValue : Integer;
begin
  GetValue := Value;
end;

constructor DownCounter.Init(InitValue, InitX, InitY, InitMin : Integer;
                             InitName : TextStr;
                             InitAttr : Byte);
begin
  Counter.Init(InitValue, InitX, InitY, InitName, InitAttr);
  Minimum := InitMin;
end;

procedure DownCounter.Decrement;
begin
  if Value > Minimum then
    Counter.Decrement;
end;

procedure DownCounter.Add(Incr : Integer);
var
  Temp : Integer;
begin
  Temp := GetValue + Incr;
  if Temp >= Minimum then
    SetValue(Temp);
end;

function DownCounter.Last : Boolean;
begin
  Last := (Value = Minimum);
end;

constructor LimitCounter.Init(InitValue,
                              InitX,
                              InitY,
                              InitMin,
                              InitMax : Integer;
                              InitName : TextStr;
                              InitAttr : Byte);
begin
  DownCounter.Init(InitValue, InitX, InitY, InitMin, InitName, InitAttr);
  Maximum := InitMax;
end;

procedure LimitCounter.Increment;
begin
  if Value < Maximum then
    Counter.Increment;
end;

procedure LimitCounter.Add(Incr : Integer);
var
  Temp : Integer;
begin
  Temp := Value + Incr;
  if (Temp <= Maximum) and (Temp >= Minimum) then
    SetValue(Temp);
end;

end.
