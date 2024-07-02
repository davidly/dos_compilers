{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit Fields;

{$F+,O+,X+,S-,D-}

interface

uses Objects, Drivers, Dialogs;

type

  { Same as TInputLine, except invalid if empty }
  PKeyInputLine = ^TKeyInputLine;
  TKeyInputLine = object(TInputLine)
    function Valid(Command: Word): Boolean; virtual;
  end;

  { Accepts only valid numeric input between Min and Max }
  PNumInputLine = ^TNumInputLine;
  TNumInputLine = object(TInputLine)
    Min: Longint;
    Max: Longint;
    constructor Init(var Bounds: TRect; AMaxLen: Integer;
      AMin, AMax: Longint);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;

procedure RegisterFields;

const
  RKeyInputLine: TStreamRec = (
     ObjType: 10060;
     VmtLink: Ofs(TypeOf(TKeyInputLine)^);
     Load:    @TKeyInputLine.Load;
     Store:   @TKeyInputLine.Store
  );
  RNumInputLine: TStreamRec = (
     ObjType: 10061;
     VmtLink: Ofs(TypeOf(TNumInputLine)^);
     Load:    @TNumInputLine.Load;
     Store:   @TNumInputLine.Store
  );

implementation

uses Views, MsgBox;

procedure RegisterFields;
begin
  RegisterType(RKeyInputLine);
  RegisterType(RNumInputLine);
end;

{ TKeyInputLine }

function TKeyInputLine.Valid(Command: Word): Boolean;
var
  Ok: Boolean;
begin
  Ok := True;
  if (Command <> cmCancel) and (Command <> cmValid) then
  begin
    if Data^ = '' then
    begin
      Select;
      MessageBox('This field cannot be empty.', nil, mfError + mfOkButton);
      Ok := False;
    end;
  end;
  if Ok then Valid := TInputLine.Valid(Command)
  else Valid := False;
end;

{ TNumInputLine }
constructor TNumInputLine.Init(var Bounds: TRect; AMaxLen: Integer;
  AMin, AMax: Longint);
begin
  TInputLine.Init(Bounds, AMaxLen);
  Min := AMin;
  Max := AMax;
end;

constructor TNumInputLine.Load(var S: TStream);
begin
  TInputLine.Load(S);
  S.Read(Min, SizeOf(LongInt) * 2);
end;

function TNumInputLine.DataSize: Word;
begin
  DataSize := SizeOf(LongInt);
end;

procedure TNumInputLine.GetData(var Rec);
var
  Code: Integer;
begin
  Val(Data^, Longint(Rec), Code);
end;

procedure TNumInputLine.Store(var S: TStream);
begin
  TInputLine.Store(S);
  S.Write(Min, SizeOf(Longint) * 2);
end;

procedure TNumInputLine.SetData(var Rec);
var
  S: string[12];
begin
  Str(Longint(Rec), Data^);
  SelectAll(True);
end;

function TNumInputLine.Valid(Command: Word): Boolean;
var
  Code: Integer;
  Value: Longint;
  Params: array[0..1] of LongInt;
  Ok: Boolean;
begin
  Ok := True;
  if (Command <> cmCancel) and (Command <> cmValid) then
  begin
    if Data^ = '' then Data^ := '0';
    Val(Data^, Value, Code);
    if (Code <> 0) or (Value < Min) or (Value > Max) then
    begin
      Select;
      Params[0] := Min;
      Params[1] := Max;
      MessageBox('Number must be from %D to %D.', @Params, mfError + mfOkButton);
      SelectAll(True);
      Ok := False;
    end;
  end;
  if Ok then Valid := TInputLine.Valid(Command)
  else Valid := False;
end;

end.
