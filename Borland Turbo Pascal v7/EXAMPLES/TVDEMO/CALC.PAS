{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit Calc;

{$F+,O+,S-}

{ Calculator object. See TVDEMO.PAS for an example
  program that uses this unit.
}

interface

uses Drivers, Objects, Views, Dialogs;

type

  TCalcState = (csFirst, csValid, csError);

  PCalcDisplay = ^TCalcDisplay;
  TCalcDisplay = object(TView)
    Status: TCalcState;
    Number: string[15];
    Sign: Char;
    Operator: Char;
    Operand: Real;
    constructor Init(var Bounds: TRect);
    constructor Load(var S: TStream);
    procedure CalcKey(Key: Char);
    procedure Clear;
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

  PCalculator = ^TCalculator;
  TCalculator = object(TDialog)
    constructor Init;
  end;

const
  RCalcDisplay: TStreamRec = (
     ObjType: 10040;
     VmtLink: Ofs(TypeOf(TCalcDisplay)^);
     Load:    @TCalcDisplay.Load;
     Store:   @TCalcDisplay.Store
  );
  RCalculator: TStreamRec = (
     ObjType: 10041;
     VmtLink: Ofs(TypeOf(TCalculator)^);
     Load:    @TCalculator.Load;
     Store:   @TCalculator.Store
  );

procedure RegisterCalc;

implementation

const
  cmCalcButton = 100;

constructor TCalcDisplay.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  Options := Options or ofSelectable;
  EventMask := evKeyDown + evBroadcast;
  Clear;
end;

constructor TCalcDisplay.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(Status, SizeOf(Status) + SizeOf(Number) + SizeOf(Sign) +
    SizeOf(Operator) + SizeOf(Operand));
end;

procedure TCalcDisplay.CalcKey(Key: Char);
var
  R: Real;

procedure Error;
begin
  Status := csError;
  Number := 'Error';
  Sign := ' ';
end;

procedure SetDisplay(R: Real);
var
  S: string[63];
begin
  Str(R: 0: 10, S);
  if S[1] <> '-' then Sign := ' ' else
  begin
    Delete(S, 1, 1);
    Sign := '-';
  end;
  if Length(S) > 15 + 1 + 10 then Error
  else
  begin
    while S[Length(S)] = '0' do Dec(S[0]);
    if S[Length(S)] = '.' then Dec(S[0]);
    Number := S;
  end;
end;

procedure GetDisplay(var R: Real);
var
  E: Integer;
begin
  Val(Sign + Number, R, E);
end;

procedure CheckFirst;
begin
  if Status = csFirst then
  begin
    Status := csValid;
    Number := '0';
    Sign := ' ';
  end;
end;

begin
  Key := UpCase(Key);
  if (Status = csError) and (Key <> 'C') then Key := ' ';
  case Key of
    '0'..'9':
      begin
        CheckFirst;
        if Number = '0' then Number := '';
        Number := Number + Key;
      end;
    '.':
      begin
        CheckFirst;
        if Pos('.', Number) = 0 then Number := Number + '.';
      end;
    #8, #27:
      begin
        CheckFirst;
        if Length(Number) = 1 then Number := '0' else Dec(Number[0]);
      end;
    '_', #241:
      if Sign = ' ' then Sign := '-' else Sign := ' ';
    '+', '-', '*', '/', '=', '%', #13:
      begin
        if Status = csValid then
        begin
          Status := csFirst;
          GetDisplay(R);
          if Key = '%' then
            case Operator of
              '+', '-': R := Operand * R / 100;
              '*', '/': R := R / 100;
            end;
          case Operator of
            '+': SetDisplay(Operand + R);
            '-': SetDisplay(Operand - R);
            '*': SetDisplay(Operand * R);
            '/': if R = 0 then Error else SetDisplay(Operand / R);
          end;
        end;
        Operator := Key;
        GetDisplay(Operand);
      end;
    'C':
      Clear;
  end;
  DrawView;
end;

procedure TCalcDisplay.Clear;
begin
  Status := csFirst;
  Number := '0';
  Sign := ' ';
  Operator := '=';
end;

procedure TCalcDisplay.Draw;
var
  Color: Byte;
  I: Integer;
  B: TDrawBuffer;
begin
  Color := GetColor(1);
  I := Size.X - Length(Number) - 2;
  MoveChar(B, ' ', Color, Size.X);
  MoveChar(B[I], Sign, Color, 1);
  MoveStr(B[I + 1], Number, Color);
  WriteBuf(0, 0, Size.X, 1, B);
end;

function TCalcDisplay.GetPalette: PPalette;
const
  P: string[1] = #19;
begin
  GetPalette := @P;
end;

procedure TCalcDisplay.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  case Event.What of
    evKeyDown:
      begin
        CalcKey(Event.CharCode);
        ClearEvent(Event);
      end;
    evBroadcast:
      if Event.Command = cmCalcButton then
      begin
        CalcKey(PButton(Event.InfoPtr)^.Title^[1]);
        ClearEvent(Event);
      end;
  end;
end;

procedure TCalcDisplay.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Status, SizeOf(Status) + SizeOf(Number) + SizeOf(Sign) +
    SizeOf(Operator) + SizeOf(Operand));
end;

{ TCalculator }

constructor TCalculator.Init;
const
  KeyChar: array[0..19] of Char = 'C'#27'%'#241'789/456*123-0.=+';
var
  I: Integer;
  P: PView;
  R: TRect;
begin
  R.Assign(5, 3, 29, 18);
  inherited Init(R, 'Calculator');
  Options := Options or ofFirstClick;
  for I := 0 to 19 do
  begin
    R.A.X := (I mod 4) * 5 + 2;
    R.A.Y := (I div 4) * 2 + 4;
    R.B.X := R.A.X + 5;
    R.B.Y := R.A.Y + 2;
    P := New(PButton, Init(R, KeyChar[I], cmCalcButton,
      bfNormal + bfBroadcast));
    P^.Options := P^.Options and not ofSelectable;
    Insert(P);
  end;
  R.Assign(3, 2, 21, 3);
  Insert(New(PCalcDisplay, Init(R)));
end;

procedure RegisterCalc;
begin
  RegisterType(RCalcDisplay);
  RegisterType(RCalculator);
end;

end.
