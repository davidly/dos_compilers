{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Hinter;

uses Objects, Drivers, Menus, Views, App;

const
  hcFile = 1001; hcFileNew = 1002; hcFileOpen = 1003;
  hcFileExit = 1004; hcTest = 1005; hcWindow = 1100;
  cmFileNew = 98; cmFileOpen = 99;

type
  PHintStatusLine = ^THintStatusLine;
  THintStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;
  THintApp = object(TApplication)
    constructor Init;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

function THintStatusLine.Hint(AHelpCtx: Word): String;
begin
  case AHelpCtx of
    hcDragging: Hint := 'You''re dragging me!';
    hcFile: Hint := 'This is the File menu';
    hcFileNew: Hint := 'Create a new file';
    hcFileOpen: Hint := 'Open an existing file';
    hcFileExit: Hint := 'Terminate the application';
    hcTest: Hint := 'This is a test. This is only a test.';
    hcWindow: Hint := 'This is a window';
  else
    Hint := '';
  end;
end;

constructor THintApp.Init;
var
  R: TRect;
  Window: PWindow;
begin
  inherited Init;
  Desktop^.GetExtent(R);
  Window := New(PWindow, Init(R, 'A window', wnNoNumber));
  Window^.HelpCtx := hcWindow;
  InsertWindow(Window);
end;

procedure THintApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcFile, NewMenu(
      NewItem('~N~ew', '', kbNoKey, cmFileNew, hcFileNew,
      NewItem('~O~pen...', 'F3', kbF3, cmFileOpen, hcFileOpen,
      NewLine(
      NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcFileExit,
      nil))))),
    NewItem('~T~est', '', kbNoKey, cmError, hcTest, nil)))));
end;

procedure THintApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PHintStatusLine, Init(R,
    NewStatusDef(0, $FFFF, StdStatusKeys(nil), nil)));
end;

var
  HintApp: THintApp;
begin
  HintApp.Init;
  HintApp.Run;
  HintApp.Done;
end.
