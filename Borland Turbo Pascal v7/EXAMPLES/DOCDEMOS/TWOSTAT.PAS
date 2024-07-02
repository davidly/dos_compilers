{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TwoStat;

uses Objects, Drivers, Views, App, Menus;

type
  TStatApp = object(TApplication)
    constructor Init;
    procedure InitStatusLine; virtual;
  end;

constructor TStatApp.Init;
var
  R: TRect;
  Window: PWindow;
begin
  inherited Init;
  Desktop^.GetExtent(R);
  R.B.X := R.B.X div 2;
  Window := New(PWindow, Init(R, 'Window A', 1));
  InsertWindow(Window);
  Desktop^.GetExtent(R);
  R.A.X := R.B.X div 2;
  Window := New(PWindow, Init(R, 'Window B', 2));
  Window^.HelpCtx := $8000;
  InsertWindow(Window);
end;

procedure TStatApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $7FFF,
      NewStatusKey('~F6~ Go to B', kbF6, cmNext,
      StdStatusKeys(nil)),
    NewStatusDef($8000, $FFFF,
      NewStatusKey('~F6~ Go to A', kbF6, cmNext,
      StdStatusKeys(nil)),
    nil))));
end;

var
  StatApp: TStatApp;

begin
  StatApp.Init;
  StatApp.Run;
  StatApp.Done;
end.
