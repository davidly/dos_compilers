{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Demo program from the Turbo Vision Guide     }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program Hello;

uses Objects, Drivers, Views, Menus, Dialogs, App;

const
  GreetThemCmd = 100;

type
  PHelloApp = ^THelloApp;
  THelloApp = object(TApplication)
    procedure GreetingBox;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

{ THelloApp }
procedure THelloApp.GreetingBox;
var
  R: TRect;
  D: PDialog;
  C: Word;
begin
  { Create a dialog }
  R.Assign(25, 5, 55, 16);
  D := New(PDialog, Init(R, 'Hello, World!'));

  { Create and insert controls into the dialog}
  R.Assign(3, 5, 15, 6);
  D^.Insert(New(PStaticText, Init(R, 'How are you?')));

  R.Assign(16, 2, 28, 4);
  D^.Insert(New(PButton, Init(R, 'Terrific', cmCancel, bfNormal)));

  R.Assign(16, 4, 28, 6);
  D^.Insert(New(PButton, Init(R, 'Ok', cmCancel, bfNormal)));

  R.Assign(16, 6, 28, 8);
  D^.Insert(New(PButton, Init(R, 'Lousy', cmCancel, bfNormal)));

  R.Assign(16, 8, 28, 10);
  D^.Insert(  New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

  { Execute the modal dialog }
  C := DeskTop^.ExecView(D);
end;

procedure THelloApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      GreetThemCmd: GreetingBox;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure THelloApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~H~ello', hcNoContext, NewMenu(
      NewItem('~G~reeting...','', 0, GreetThemCmd, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil)))), nil))));
end;

procedure THelloApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y-1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit, nil)), nil)));
end;

var
  HelloWorld: THelloApp;

begin
  HelloWorld.Init;
  HelloWorld.Run;
  HelloWorld.Done;
end.
