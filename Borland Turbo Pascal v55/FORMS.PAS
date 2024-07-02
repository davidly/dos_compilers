
{ Turbo Forms }
{ Copyright (c) 1989 by Borland International, Inc. }

unit Forms;
{ Turbo Pascal 5.5 object-oriented example.
  This unit defines field- and form-editing object types.
  Refer to OOPDEMOS.DOC for an overview of this unit.
}

{$S-}

interface

uses Objects;

const

  CSkip  = ^@;
  CHome  = ^A;
  CRight = ^D;
  CPrev  = ^E;
  CEnd   = ^F;
  CDel   = ^G;
  CBack  = ^H;
  CSave  = ^J;
  CEnter = ^M;
  CUndo  = ^R;
  CLeft  = ^S;
  CIns   = ^V;
  CNext  = ^X;
  CClear = ^Y;
  CEsc   = ^[;

type

  FStringPtr = ^FString;
  FString = string[79];

  FieldPtr = ^Field;
  Field = object(Node)
    X, Y, Size: Integer;
    Title: FStringPtr;
    Value: Pointer;
    Extra: record end;
    constructor Init(PX, PY, PSize: Integer; PTitle: FString);
    constructor Load(var S: Stream);
    destructor Done; virtual;
    procedure Clear; virtual;
    function Edit: Char; virtual;
    procedure Show; virtual;
    procedure Store(var S: Stream);
  end;

  FTextPtr = ^FText;
  FText = object(Field)
    Len: Integer;
    constructor Init(PX, PY, PSize: Integer; PTitle: FString;
      PLen: Integer);
    function Edit: Char; virtual;
    procedure GetStr(var S: FString); virtual;
    function PutStr(var S: FString): Boolean; virtual;
    procedure Show; virtual;
  end;

  FStrPtr = ^FStr;
  FStr = object(FText)
    constructor Init(PX, PY: Integer; PTitle: FString; PLen: Integer);
    procedure GetStr(var S: FString); virtual;
    function PutStr(var S: FString): Boolean; virtual;
  end;

  FNumPtr = ^FNum;
  FNum = object(FText)
    procedure Show; virtual;
  end;

  FIntPtr = ^FInt;
  FInt = object(FNum)
    Min, Max: Longint;
    constructor Init(PX, PY: Integer; PTitle: FString;
      PMin, PMax: Longint);
    procedure GetStr(var S: FString); virtual;
    function PutStr(var S: FString): Boolean; virtual;
  end;

  FZipPtr = ^FZip;
  FZip = object(FInt)
    constructor Init(PX, PY: Integer; PTitle: FString);
    procedure GetStr(var S: FString); virtual;
    function PutStr(var S: FString): Boolean; virtual;
  end;

  FRealPtr = ^FReal;
  FReal = object(FNum)
    Decimals: Integer;
    constructor Init(PX, PY: Integer; PTitle: FString;
      PLen, PDecimals: Integer);
    procedure GetStr(var S: FString); virtual;
    function PutStr(var S: FString): Boolean; virtual;
  end;

  FormPtr = ^Form;
  Form = object(Base)
    X1, Y1, X2, Y2, Size: Integer;
    Fields: List;
    constructor Init(PX1, PY1, PX2, PY2: Integer);
    constructor Load(var S: Stream);
    destructor Done; virtual;
    function Edit: Char;
    procedure Show(Erase: Boolean);
    procedure Add(P: FieldPtr);
    procedure Clear;
    procedure Get(var FormBuf);
    procedure Put(var FormBuf);
    procedure Store(var S: Stream);
  end;

  FStream = object(BufStream)
    procedure RegisterTypes; virtual;
  end;

  ColorIndex = (BackColor, ForeColor, TitleColor, ValueColor);

procedure Beep;
procedure Color(C: ColorIndex);
function ReadChar: Char;

implementation

uses Crt;

type
  Bytes = array[0..32767] of Byte;

{ Field }

constructor Field.Init(PX, PY, PSize: Integer; PTitle: FString);
begin
  X := PX;
  Y := PY;
  Size := PSize;
  GetMem(Title, Length(PTitle) + 1);
  Title^ := PTitle;
  GetMem(Value, Size);
end;

constructor Field.Load(var S: Stream);
var
  L: Byte;
begin
  S.Read(X, SizeOf(Integer) * 3);
  S.Read(L, SizeOf(Byte));
  GetMem(Title, L + 1);
  Title^[0] := Chr(L);
  S.Read(Title^[1], L);
  GetMem(Value, Size);
  S.Read(Extra, SizeOf(Self) - SizeOf(Field));
end;

destructor Field.Done;
begin
  FreeMem(Value, Size);
  FreeMem(Title, Length(Title^) + 1);
end;

procedure Field.Clear;
begin
  FillChar(Value^, Size, 0);
end;

function Field.Edit: Char;
begin
  Abstract;
end;

procedure Field.Show;
begin
  Abstract;
end;

procedure Field.Store(var S: Stream);
begin
  S.Write(X, SizeOf(Integer) * 3);
  S.Write(Title^, Length(Title^) + 1);
  S.Write(Extra, SizeOf(Self) - SizeOf(Field));
end;

{ FText }

constructor FText.Init(PX, PY, PSize: Integer; PTitle: FString;
  PLen: Integer);
begin
  Field.Init(PX, PY, PSize, PTitle);
  Len := PLen;
end;

function FText.Edit: Char;
var
  P: Integer;
  Ch: Char;
  Start, Stop: Boolean;
  S: FString;
begin
  P := 0;
  Start := True;
  Stop := False;
  GetStr(S);
  repeat
    GotoXY(X, Y);
    Color(TitleColor);
    Write(Title^);
    Color(ValueColor);
    Write(S, '': Len - Length(S));
    GotoXY(X + Length(Title^) + P, Y);
    Ch := ReadChar;
    case Ch of
      #32..#255:
        begin
          if Start then S := '';
          if Length(S) < Len then
          begin
            Inc(P);
            Insert(Ch, S, P);
          end;
        end;
      CLeft: if P > 0 then Dec(P);
      CRight: if P < Length(S) then Inc(P) else;
      CHome: P := 0;
      CEnd: P := Length(S);
      CDel: Delete(S, P + 1, 1);
      CBack:
        if P > 0 then
        begin
          Delete(S, P, 1);
          Dec(P);
        end;
      CClear:
        begin
          S := '';
          P := 0;
        end;
      CUndo:
        begin
          GetStr(S);
          P := 0;
        end;
      CEnter, CNext, CPrev, CSave:
        if PutStr(S) then
        begin
          Show;
          Stop := True;
        end else
        begin
          Beep;
          P := 0;
        end;
      CEsc: Stop := True;
    else
      Beep;
    end;
    Start := False;
  until Stop;
  Edit := Ch;
end;

procedure FText.GetStr(var S: FString);
begin
  Abstract;
end;

function FText.PutStr(var S: FString): Boolean;
begin
  Abstract;
end;

procedure FText.Show;
var
  S: FString;
begin
  GetStr(S);
  GotoXY(X, Y);
  Color(TitleColor);
  Write(Title^);
  Color(ValueColor);
  Write(S, '': Len - Length(S));
end;

{ FStr }

constructor FStr.Init(PX, PY: Integer; PTitle: FString; PLen: Integer);
begin
  FText.Init(PX, PY, PLen + 1, PTitle, PLen);
end;

procedure FStr.GetStr(var S: FString);
begin
  S := FString(Value^);
end;

function FStr.PutStr(var S: FString): Boolean;
begin
  FString(Value^) := S;
  PutStr := True;
end;

{ FNum }

procedure FNum.Show;
var
  S: FString;
begin
  GetStr(S);
  GotoXY(X, Y);
  Color(TitleColor);
  Write(Title^);
  Color(ValueColor);
  Write(S: Len);
end;

{ FInt }

constructor FInt.Init(PX, PY: Integer; PTitle: FString;
  PMin, PMax: Longint);
var
  L: Integer;
  S: string[15];
begin
  Str(PMin, S); L := Length(S);
  Str(PMax, S); if L < Length(S) then L := Length(S);
  FNum.Init(PX, PY, SizeOf(Longint), PTitle, L);
  Min := PMin;
  Max := PMax;
end;

procedure FInt.GetStr(var S: FString);
begin
  Str(Longint(Value^), S);
end;

function FInt.PutStr(var S: FString): Boolean;
var
  N: Longint;
  E: Integer;
begin
  Val(S, N, E);
  if (E = 0) and (N >= Min) and (N <= Max) then
  begin
    Longint(Value^) := N;
    PutStr := True;
  end else PutStr := False;
end;

{ FZip }

constructor FZip.Init(PX, PY: Integer; PTitle: FString);
begin
  FInt.Init(PX, PY, PTitle, 0, 99999);
end;

procedure FZip.GetStr(var S: FString);
begin
  FInt.GetStr(S);
  Insert(Copy('0000', 1, 5 - Length(S)), S, 1);
end;

function FZip.PutStr(var S: FString): Boolean;
begin
  PutStr := (Length(S) = 5) and FInt.PutStr(S);
end;

{ FReal }

constructor FReal.Init(PX, PY: Integer; PTitle: FString;
  PLen, PDecimals: Integer);
begin
  FNum.Init(PX, PY, SizeOf(Real), PTitle, PLen);
  Decimals := PDecimals;
end;

procedure FReal.GetStr(var S: FString);
begin
  Str(Real(Value^): 0: Decimals, S);
end;

function FReal.PutStr(var S: FString): Boolean;
var
  R: Real;
  E: Integer;
  T: FString;
begin
  Val(S, R, E);
  PutStr := False;
  if E = 0 then
  begin
    Str(R: 0: Decimals, T);
    if Length(T) <= Len then
    begin
      Real(Value^) := R;
      PutStr := True;
    end;
  end;
end;

{ Form }

constructor Form.Init(PX1, PY1, PX2, PY2: Integer);
begin
  X1 := PX1;
  Y1 := PY1;
  X2 := PX2;
  Y2 := PY2;
  Size := 0;
  Fields.Clear;
end;

constructor Form.Load(var S: Stream);
begin
  S.Read(X1, SizeOf(Integer) * 5);
  Fields.Load(S);
end;

destructor Form.Done;
begin
  Fields.Delete;
end;

function Form.Edit: Char;
var
  P: FieldPtr;
  Ch: Char;
begin
  Window(X1, Y1, X2, Y2);
  P := FieldPtr(Fields.First);
  repeat
    Ch := P^.Edit;
    case Ch of
      CEnter, CNext: P := FieldPtr(P^.Next);
      CPrev: P := FieldPtr(P^.Prev);
    end;
  until (Ch = CSave) or (Ch = CEsc);
  Edit := Ch;
  Window(1, 1, 80, 25);
end;

procedure Form.Show(Erase: Boolean);
var
  P: FieldPtr;
begin
  Window(X1, Y1, X2, Y2);
  if Erase then
  begin
    Color(ForeColor);
    ClrScr;
  end;
  P := FieldPtr(Fields.First);
  while P <> nil do
  begin
    P^.Show;
    P := FieldPtr(Fields.Next(P));
  end;
  Window(1, 1, 80, 25);
end;

procedure Form.Add(P: FieldPtr);
begin
  Inc(Size, P^.Size);
  Fields.Append(P);
end;

procedure Form.Clear;
var
  P: FieldPtr;
begin
  P := FieldPtr(Fields.First);
  while P <> nil do
  begin
    P^.Clear;
    P := FieldPtr(Fields.Next(P));
  end;
end;

procedure Form.Get(var FormBuf);
var
  I: Integer;
  P: FieldPtr;
begin
  I := 0;
  P := FieldPtr(Fields.First);
  while P <> nil do
  begin
    Move(P^.Value^, Bytes(FormBuf)[I], P^.Size);
    Inc(I, P^.Size);
    P := FieldPtr(Fields.Next(P));
  end;
end;

procedure Form.Put(var FormBuf);
var
  I: Integer;
  P: FieldPtr;
begin
  I := 0;
  P := FieldPtr(Fields.First);
  while P <> nil do
  begin
    Move(Bytes(FormBuf)[I], P^.Value^, P^.Size);
    Inc(I, P^.Size);
    P := FieldPtr(Fields.Next(P));
  end;
end;

procedure Form.Store(var S: Stream);
begin
  S.Write(X1, SizeOf(Integer) * 5);
  Fields.Store(S);
end;

{ FStream }

procedure FStream.RegisterTypes;
begin
  BufStream.RegisterTypes;
  Register(TypeOf(FStr), @FStr.Store, @FStr.Load);
  Register(TypeOf(FInt), @FInt.Store, @FInt.Load);
  Register(TypeOf(FZip), @FZip.Store, @FZip.Load);
  Register(TypeOf(FReal), @FReal.Store, @FReal.Load);
end;

{ Global routines }

procedure Beep;
begin
  Sound(500); Delay(25); NoSound;
end;

procedure Color(C: ColorIndex);
type
  Palette = array[ColorIndex] of Byte;
const
  CP: Palette = ($17, $70, $30, $5E);
  MP: Palette = ($07, $70, $70, $07);
begin
  if LastMode = CO80 then TextAttr := CP[C] else TextAttr := MP[C];
end;

function ReadChar: Char;
var
  Ch: Char;
begin
  Ch := ReadKey;
  case Ch of
    #0:
      case ReadKey of
        #15, #72: Ch := CPrev;    { Shift-Tab, Up }
        #60: Ch := CSave;         { F2 }
        #71: Ch := CHome;         { Home }
        #75: Ch := CLeft;         { Left }
        #77: Ch := CRight;        { Right }
        #79: Ch := CEnd;          { End }
        #80: Ch := CNext;         { Down }
        #82: Ch := CIns;          { Ins }
        #83: Ch := CDel;          { Del }
      end;
    #9: Ch := CNext;              { Tab }
  end;
  ReadChar := Ch;
end;

end.
