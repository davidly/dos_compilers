{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program InsWin;

uses Objects, App, Drivers, Views, Menus;

const
  cmNewWin = 2000;

type
  TInsApp = object(TApplication)
    WinCount: Integer;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
  end;

procedure TInsApp.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    if Event.Command = cmNewWin then
    begin
      Inc(WinCount);
      Desktop^.GetExtent(R);
      InsertWindow(New(PWindow, Init(R, 'Test window', WinCount)));
    end;
  end;
end;

procedure TInsApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewItem('~A~dd window', 'F3', kbF3, cmNewWin, hcNoContext, nil))));
end;

var
  InsApp: TInsApp;
begin
  InsApp.Init;
  InsApp.Run;
  InsApp.Done;
end.
