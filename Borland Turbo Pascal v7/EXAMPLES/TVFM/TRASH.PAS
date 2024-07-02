{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Trash;

{$X+,V-}

interface

uses Drivers, Objects, Views, App, Globals, Tools, Equ, MsgBox;

type

  { Trash can object }
  PTrashCan = ^TTrashCan;
  TTrashCan = object(TView)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Reposition(var R: TRect);
  end;


implementation

const
  CTrashCan : string[Length(CGrayWindow)] = CGrayWindow;

{ TTrashCan }

constructor TTrashCan.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  Options := Options or (ofSelectable + ofTopSelect);
  EventMask := EventMask or evBroadcast;
end;

function TTrashCan.GetPalette: PPalette;
begin
   GetPalette := @CTrashCan;
end;

procedure TTrashCan.Draw;
var
  B: TDrawBuffer;
  C: Word;
begin
  if State and sfDragging <> 0 then C := 3
  else if State and sfSelected = 0 then C := 1
  else C := 2;
  C := GetColor(C);
  MoveStr(B, #209#209#216#209#209, C);
  WriteLine(0, 0, Size.X, 1, B);
  MoveStr(B, 'Trash', C);
  WriteLine(0, 1, Size.X, 1, B);
  MoveStr(B, #192#193#193#193#217, C);
  WriteLine(0, 2, Size.X, 1, B);
end;

procedure TTrashCan.HandleEvent(var Event:TEvent);
var
  Mover: PFileMover;
  Where: TPoint;
  SaveConfirm: Boolean;
  Extent: TRect;
  Msg: String;

  procedure DeleteFile(F: PFileRec); far;
  begin
    SafeDelete(Mover^.Dir + '\' + F^.Name + F^.Ext);
  end;

begin
  inherited HandleEvent(Event);

  if (Event.What = evBroadcast) and (Event.Command = cmItemDropped) then
  begin
    Mover := Event.InfoPtr;
    Desktop^.MakeGlobal(Mover^.Origin, Where);
    if MouseInView(Where) then
    begin
      ClearEvent(Event);
      if Mover^.Items^.Count = 1 then Msg := RezStrings^.Get(sDelSingle)
      else Msg := RezStrings^.Get(sDelMult);
      if MessageBox(Msg, nil, mfConfirmation +
        mfYesButton + mfNoButton) = cmYes then
      begin
        SaveConfirm := ConfirmDelete;
        ConfirmDelete := False;
        Mover^.Items^.ForEach(@DeleteFile);
        ConfirmDelete := SaveConfirm;
        InvalidateDir(Mover^.Dir);
      end;
    end;
  end;

  if Event.What = evMouseDown then
  begin
    Owner^.GetExtent(Extent);
    DragView(Event, dmDragMove, Extent, Size, Size);
  end;

end;

procedure TTrashCan.SetState(AState: Word; Enable: Boolean);
begin
  inherited SetState(AState, Enable);
  if AState and sfSelected <> 0 then
    SetCmdState([cmNext, cmPrev], Enable);
  if (AState and (sfSelected + sfFocused) <> 0) or
    (AState and (sfActive + sfDragging) <> 0) then
    DrawView;
end;

procedure TTrashCan.Reposition(var R: TRect);
begin
  Inc(R.A.X);
  R.A.Y := R.B.Y - 4;
  MoveTo(R.A.X, R.A.Y);
end;

end.
