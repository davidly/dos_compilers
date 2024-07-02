{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Resourc2;

uses Objects, Drivers, Views, Menus, Dialogs, App;

var
  MyRez: TResourceFile;

type
PMyApp = ^TMyApp;
TMyApp = object(TApplication)
  constructor Init;
  procedure InitStatusLine; virtual;
end;

constructor TMyApp.Init;
const
  MyRezFileName: FNameStr = 'MY.TVR';
begin
  MyRez.Init(New(PBufStream, Init(MyRezFileName, stOpen, 1024)));
  if MyRez.Stream^.Status <> 0 then Halt(1);
  RegisterType(RStatusLine);
  inherited Init;
end;

procedure TMyApp.InitStatusLine;
begin
  StatusLine := PStatusLine(MyRez.Get('Waldo'));
end;

var WaldoApp: TMyApp;
begin
  WaldoApp.Init;
  WaldoApp.Run;
  WaldoApp.Done;
end.
