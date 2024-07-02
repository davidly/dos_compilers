{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Tutor02b;

uses App, Objects, Menus, Drivers, Views, TutConst;

type
  TTutorApp = object(TApplication)
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

procedure TTutorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewItem('~N~ew', '', kbNoKey, cmNew, hcNew,
      NewItem('~O~pen...', 'F3', kbF3, cmOpen, hcOpen,
      NewItem('~S~ave', 'F2', kbF2, cmSave, hcSave,
      NewItem('Save ~a~s...', '', kbNoKey, cmSaveAs, hcSaveAs,
      NewLine(
      NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcExit,
      nil)))))))));
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
