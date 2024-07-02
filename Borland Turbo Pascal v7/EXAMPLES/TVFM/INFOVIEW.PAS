{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit InfoView;

interface

uses Objects, Drivers, Views;

type
  PCntView = ^TCntView;
  TCntView = object(TView)
    Bytes: LongInt;
    Count: LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  private
    function GetText: String; virtual;
  end;

  PTagView = ^TTagView;
  TTagView = object(TCntView)
    procedure HandleEvent(var Event: TEvent); virtual;
  private
    function GetText: String; virtual;
  end;


implementation

uses Equ, FileView, Globals;

constructor TCntView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  Count := 0;
  Bytes := 0;
  GrowMode := gfGrowHiY + gfGrowLoY + gfGrowHiX;
  EventMask := evBroadcast;
end;

procedure TCntView.Draw;
var
  B: TDrawBuffer;
  Color: Byte;
begin
  Color := GetColor(6);
  MoveChar(B, ' ', Color, Size.X);
  MoveStr(B, GetText, Color);
  WriteLine(0, 0, Size.X, Size.Y, B);
end;

function TCntView.GetText: String;
var
  Str: String;
begin
  FormatStr(Str, '%d bytes in %d files', Bytes);
  GetText := Str;
end;

procedure TCntView.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmScanComplete) then
  begin
    with PScanInfo(Event.InfoPtr)^ do
    begin
      Bytes := ScanBytes;
      Count := ScanCount;
      DrawView;
    end;
  end;
end;

{ TTagView }
function TTagView.GetText: String;
var
  Str: String;
begin
  FormatStr(Str, '%d bytes in %d tagged files', Bytes);
  GetText := Str;
end;

procedure TTagView.HandleEvent(var Event: TEvent);
var
  F: PFileRec;
begin
  { don't execute the directly inherited HandleEvent }
  TView.HandleEvent(Event);
  if Event.What = evBroadcast then
  begin
    case Event.Command of
      cmNewDir,
      cmRescan :
        begin
          Bytes := 0;
          Count := 0;
          DrawView;
        end;
      cmTagChanged :
        begin
          F := Event.InfoPtr;
          if F^.Tagged then
          begin
            Inc(Count);
            Inc(Bytes, F^.Size);
          end
          else
          begin
            Dec(Count);
            Dec(Bytes, F^.Size);
          end;
          DrawView;
          ClearEvent(Event);
        end;
    end;
  end;
end;


end.