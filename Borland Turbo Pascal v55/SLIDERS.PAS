
{ Turbo Sliders }
{ Copyright (c) 1989 by Borland International, Inc. }

unit Sliders;
{ Turbo Pascal 5.5 object-oriented example.
  This unit extends FORM.PAS' Field object type.
  Refer to OOPDEMOS.DOC for an overview of this unit.
}

{$S-}

interface

uses Forms;

type

  FSliderPtr = ^FSlider;
  FSlider = object(Field)
    Min, Max, Delta: Integer;
    constructor Init(PX, PY: Integer; PTitle: FString;
      PMin, PMax, PDelta: Integer);
    procedure Clear; virtual;
    function Edit: Char; virtual;
    procedure Show; virtual;
    procedure Display(I: Integer);
  end;

  FStream = object(Forms.FStream)
    procedure RegisterTypes; virtual;
  end;

implementation

uses Crt;

{ FSlider }

constructor FSlider.Init(PX, PY: Integer; PTitle: FString;
  PMin, PMax, PDelta: Integer);
begin
  Field.Init(PX, PY, 2, PTitle);
  Min := PMin;
  Max := PMax;
  Delta := PDelta;
end;

procedure FSlider.Clear;
begin
  Integer(Value^) := (Max - Min) div 2;
end;

function FSlider.Edit: Char;
var
  I: Integer;
  Ch: Char;
  Stop: Boolean;
begin
  I := Integer(Value^);
  Stop := False;
  repeat
    Display(I);
    GotoXY(X + Length(Title^) + 1, Y);
    Ch := ReadChar;
    case Ch of
      CLeft: if I > Min then Dec(I, Delta);
      CRight: if I < Max then Inc(I, Delta);
      CHome: I := Min;
      CEnd: I := Max;
      CUndo: I := Integer(Value^);
      CEnter, CNext, CPrev, CSave, CEsc: Stop := True;
    else
      Beep;
    end;
  until Stop;
  if Ch <> CEsc then Integer(Value^) := I;
  Edit := Ch;
end;

procedure FSlider.Show;
begin
  Display(Integer(Value^));
end;

procedure FSlider.Display(I: Integer);
var
  Steps: Integer;
  S: FString;
begin
  Steps := (Max - Min) div Delta + 1;
  S[0] := Chr(Steps);
  FillChar(S[1], Steps, #176);
  S[(I - Min) div Delta + 1] := #219;
  GotoXY(X, Y);
  Color(TitleColor);
  Write(Title^);
  Color(ValueColor);
  Write(' ', Min, ' ', S, ' ', Max, ' ');
end;

{ FStream }

procedure FStream.RegisterTypes;
begin
  Forms.FStream.RegisterTypes;
  Register(TypeOf(FSlider), @FSlider.Store, @FSlider.Load);
end;

end.
