{************************************************}
{                                                }
{   Turbo Vision Debuging Demo                   }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ This program demonstrates how to use TVDEBUG the debugging
  unit.  By using TVDEBUG your application will create two
  windows on the desktop, an event window and a log window.
  The event window will show all the events as they occur
  in a readable fashion.  The log window intercepts writes
  to Output and displays them in a window.  This allows
  "Writeln" style debugging in Turbo Vision. }

program ShowEvnt;

{$X+}

{$DEFINE DEBUG}

{$IFDEF DEBUG}
uses Drivers, Objects, Views, Menus, App, TVDebug;
{$ELSE}
uses Drivers, Objects, Views, Menus, App;
{$ENDIF}

type
  PMyWindow = ^TMyWindow;
  TMyWindow = object(TWindow)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

procedure TMyWindow.HandleEvent(var Event: TEvent);
const
  Times: Integer = 0;
begin
  inherited HandleEvent(Event);

  if Event.What = evMouseDown then
  begin
    Inc(Times);
{$IFDEF DEBUG}
    Writeln('You clicked in the dummy window (', Times, ')');
{$ENDIF}
  end;
end;

type
  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
    constructor Init;
    procedure InitStatusLine; virtual;
    procedure InitMenuBar; virtual;
  end;
var
  MyApp: TMyApp;

constructor TMyApp.Init;
var
  R: TRect;
begin
  inherited Init;

  R.Assign(3, 2, 60, 10);
  InsertWindow(New(PMyWindow, Init(R, 'Dummy window', wnNoNumber)));
end;

procedure TMyApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);      
  R.A.Y := R.B.Y - 1;  
  StatusLine := New(PStatusline, Init(R,
   NewStatusDef(0, $FFFF,
     NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
     NewStatusKey('~F4~ New', kbF4, cmNew,
     NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
     NewStatusKey('',kbF10, cmMenu,
     nil)))),
   nil)));
end;

procedure TMyApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y:= R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      StdFileMenuItems(nil)),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      StdWindowMenuItems(nil)),
      nil)))));
end;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
