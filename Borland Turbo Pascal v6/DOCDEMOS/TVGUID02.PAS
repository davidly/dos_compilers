{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Demo program from the Turbo Vision Guide     }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVGUID02;

uses Objects, Drivers, Views, Menus, App;

type
  TMyApp = object(TApplication)
    procedure InitStatusLine; virtual;
  end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)),
    nil)
  ));
end;

var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.
