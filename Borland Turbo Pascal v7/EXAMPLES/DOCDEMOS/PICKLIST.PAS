{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program PickList;

uses Objects, Views, Dialogs, App, Drivers;

type
  PCityColl = ^TCityColl;
  TCityColl = object(TStringCollection)
    constructor Init;
  end;
  PPickLine = ^TPickLine;
  TPickLine = object(TInputLine)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;
  PPickWindow = ^TPickWindow;
  TPickWindow = object(TDialog)
    constructor Init;
  end;
  TPickApp = object(TApplication)
    PickWindow: PPickWindow;
    constructor Init;
  end;

constructor TCityColl.Init;
begin
  inherited Init(10, 10);
  Insert(NewStr('Scotts Valley'));
  Insert(NewStr('Sydney'));
  Insert(NewStr('Copenhagen'));
  Insert(NewStr('London'));
  Insert(NewStr('Paris'));
  Insert(NewStr('Munich'));
  Insert(NewStr('Milan'));
  Insert(NewStr('Tokyo'));
  Insert(NewStr('Stockholm'));
end;

procedure TPickLine.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = cmListItemSelected then
    begin
      with PListBox(Event.InfoPtr)^ do
      begin
        Data^ := GetText(Focused, 30);
      end;
      DrawView;
      ClearEvent(Event);
    end;
end;

constructor TPickWindow.Init;
var
  R: TRect;
  Control: PView;
  ScrollBar: PScrollBar;
begin
  R.Assign(0, 0, 40, 15);
  inherited Init(R, 'Pick List Window');
  Options := Options or ofCentered;
  R.Assign(5, 2, 35, 3);
  Control := New(PPickLine, Init(R, 30));
  Control^.EventMask := Control^.EventMask or evBroadcast;
  Insert(Control);
  R.Assign(4, 1, 13, 2);
  Insert(New(PLabel, Init(R, 'Picked:', Control)));
  R.Assign(34, 5, 35, 11);
  New(ScrollBar, Init(R));
  Insert(ScrollBar);
  R.Assign(5, 5, 34, 11);
  Control := New(PListBox, Init(R, 1, ScrollBar));
  Insert(Control);
  PListBox(Control)^.NewList(New(PCityColl, Init));
  R.Assign(4, 4, 12, 5);
  Insert(New(PLabel, Init(R, 'Items:', Control)));
  R.Assign(15, 12, 25, 14);
  Insert(New(PButton, Init(R, '~Q~uit', cmQuit, bfDefault)));
end;

constructor TPickApp.Init;
begin
  inherited Init;
  PickWindow := New(PPickWindow, Init);
  InsertWindow(PickWindow);
end;

var
  PickApp: TPickApp;
begin
  PickApp.Init;
  PickApp.Run;
  PickApp.Done;
end.
