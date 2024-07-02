{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TermTest;

uses Objects, Views, App, Drivers, TextView, Menus;

type
  PTermWin = ^TTermWin;
  TTermWin = object(TWindow)
    TermText: Text;
    Terminal: PTerminal;
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;
  TTermApp = object(TApplication)
    constructor Init;
    procedure InitStatusLine; virtual;
  end;

constructor TTermWin.Init;
var
  R: TRect;
  HScrollBar, VScrollBar: PScrollBar;
begin
  Desktop^.GetExtent(R);
  inherited Init(R, 'Terminal test window', wnNoNumber);
  R.Grow(-1, -1);
  HScrollBar := StandardScrollBar(sbHorizontal or sbHandleKeyboard);
  Insert(HScrollBar);
  VScrollBar := StandardScrollBar(sbVertical or sbHandleKeyboard);
  Insert(VScrollBar);
  New(Terminal, Init(R, HScrollBar, VScrollBar, 8192));
  if Application^.ValidView(Terminal) <> nil then
  begin
    AssignDevice(TermText, Terminal);
    Rewrite(TermText);
    Insert(Terminal);
  end;
end;

procedure TTermWin.HandleEvent(var Event: TEvent);
begin
  if Event.What and evMouseDown <> 0 then
  begin
    if Event.Buttons and mbLeftButton <> 0 then
      Write(TermText, 'Left  ')
    else Write(TermText, 'Right ');
    Writeln(TermText, '(',Event.Where.X, ',', Event.Where.Y, ')');
  end;
  inherited HandleEvent(Event);
end;

constructor TTermApp.Init;
var
  TextWin: PTermWin;
begin
  inherited Init;
  New(TextWin, Init);
  if ValidView(TextWin) <> nil then InsertWindow(TextWin);
end;

procedure TTermApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R, NewStatusDef(0, $FFFF,
    NewStatusKey('Click mouse in window, or ~Alt+X~ to exit', kbAltX, cmQuit,
    StdStatusKeys(nil)), nil)));
end;

var
  TermApp: TTermApp;

begin
  TermApp.Init;
  TermApp.Run;
  TermApp.Done;
end.
