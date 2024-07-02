{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Tutor03c;

uses TutConst, Drivers, Objects, Views, Menus, App, MsgBox;

type
  TTutorApp = object(TApplication)
    constructor Init;
    procedure DoAboutBox;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

constructor TTutorApp.Init;
begin
  inherited Init;
  DisableCommands([cmOrderWin, cmStockWin, cmSupplierWin]);
end;

procedure TTutorApp.DoAboutBox;
begin
  MessageBox(#3'Turbo Vision Tutorial Application'#13 +
    #3'Copyright 1992'#13#3'Borland International',
    nil, mfInformation or mfOKButton);
end;

procedure TTutorApp.HandleEvent(var Event: TEvent);
var
  R: TRect;
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmOptionsVideo:
        begin
          SetScreenMode(ScreenMode xor smFont8x8);
          ClearEvent(Event);
        end;
      cmAbout:
        begin
          DoAboutBox;
          ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TTutorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      StdFileMenuItems(nil)),
    NewSubMenu('~E~dit', hcNoContext, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmClipShow, hcNoContext,
      nil)))),
    NewSubMenu('~O~rders', hcNoContext, NewMenu(
      NewItem('~N~ew', 'F9', kbF9, cmOrderNew, hcNoContext,
      NewItem('~S~ave', '', kbNoKey, cmOrderSave, hcNoContext,
      NewLine(
      NewItem('Next', 'PgDn', kbPgDn, cmOrderNext, hcNoContext,
      NewItem('Prev', 'PgUp', kbPgUp, cmOrderPrev, hcNoContext,
      nil)))))),
    NewSubMenu('O~p~tions', hcNoContext, NewMenu(
      NewItem('~T~oggle video', '', kbNoKey, cmOptionsVideo, hcNoContext,
      NewItem('~S~ave desktop', '', kbNoKey, cmOptionsSave, hcNoContext,
      NewItem('~L~oad desktop', '', kbNoKey, cmOptionsLoad, hcNoContext,
      nil)))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('Orders', '', kbNoKey, cmOrderWin, hcNoContext,
      NewItem('Stock items', '', kbNoKey, cmStockWin, hcNoContext,
      NewItem('Suppliers', '', kbNoKey, cmSupplierWin, hcNoContext,
      NewLine(
      StdWindowMenuItems(nil)))))),
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout...', '', kbNoKey, cmAbout, hcNoContext,
      nil)),
    nil))))))
  )));
end;

procedure TTutorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $EFFF,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~F4~ New', kbF4, cmNew,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      StdStatusKeys(nil)))),
    NewStatusDef($F000, $FFFF,
      NewStatusKey('~F6~ Next', kbF6, cmOrderNext,
      NewStatusKey('~Shift+F6~ Prev', kbShiftF6, cmOrderPrev,
      StdStatusKeys(nil))), nil))));
end;

var
  TutorApp: TTutorApp;

begin
  TutorApp.Init;
  TutorApp.Run;
  TutorApp.Done;
end.
