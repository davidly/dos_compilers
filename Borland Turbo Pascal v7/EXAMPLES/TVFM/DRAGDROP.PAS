{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit DragDrop;  { Drag and drop support objects }

{$X+,V-}

interface

uses Dos, Objects, Drivers, Views, Dialogs, App;

type

  { TListViewer that supports grabbing an item with the mouse }
  PDDList = ^TDDList;
  TDDList = object(TListViewer)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure PickUpItem(Item: Integer; Where: TPoint); virtual;
  end;

  { Moving view while item is dragged }

  PMover = ^TMover;
  TMover = object(TView)
    Dir: PathStr;
    Items: PCollection;
    constructor Init(Where: TPoint; const ADir: PathStr; AItems: PCollection);
    procedure Draw; virtual;
  end;


implementation

{ TDDList }

procedure TDDList.PickUpItem(Item: Integer; Where: TPoint);
begin
end;

procedure TDDList.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  NewItem, OldItem: Integer;

function HasMoved(const P1, P2: TPoint): Boolean;
begin
  HasMoved := (P1.X <> P2.X) or (P1.Y <> P2.Y);
end;

begin
  if (Event.What = evMouseDown) and (Event.Buttons = mbLeftButton) then
  begin
    TView.HandleEvent(Event);
    if Event.What = evNothing then Exit;
    OldItem := Focused;
    MakeLocal(Event.Where, Mouse);
    NewItem := Mouse.Y + TopItem;
    if NewItem <> OldItem then
    begin
      if NewItem < 0 then NewItem := 0
      else if (NewItem >= Range) and (Range > 0) then NewItem := Range - 1;
      if Range <> 0 then FocusItem(NewItem);
      DrawView;
    end;

    { possibly a drag/drop operation }
    if (Mouse.X > 1) and (Mouse.X <= 13) then
    begin
      if MouseEvent(Event, evMouseMove) and (Event.Buttons = mbLeftButton) then
      begin
        MakeLocal(Event.Where, Event.Where);
        if HasMoved(Event.Where, Mouse) then
        begin
          MakeGlobal(Event.Where, Mouse);
          PickUpItem(Focused, Mouse);
          ClearEvent(Event);
        end;
      end;
    end;

    if Event.Double and (Range > Focused) then SelectItem(Focused);
    ClearEvent(Event);
  end;
  inherited HandleEvent(Event);
end;


{ TMover }

constructor TMover.Init(Where: TPoint; const ADir: PathStr;
  AItems: PCollection);
var
  R: TRect;
  YSize: Integer;
begin
  YSize := AItems^.Count;
  if YSize > 3 then YSize := 3;
  R.Assign(Where.X, Where.Y, Where.X + 12, Where.Y + YSize);
  inherited Init(R);
  SetState(sfShadow, True);
  Dir := ADir;
  Items := AItems;
end;

procedure TMover.Draw;
begin
  Abstract;
end;

end.
