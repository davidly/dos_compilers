{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision TTerminal demo program          }
{                                                }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVTxtDmo;

{$M 16384,16384,655360}

uses Dos, Objects, Views, TextView, MsgBox, App;

type
  PTerminalWindow = ^TTerminalWindow;
  TTerminalWindow = object(TWindow)
    constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Word;
      var Interior: PTerminal; ABufSize: Word);
    function MakeInterior(Bounds: TRect; ABufSize: Word): PTerminal;
  end;

  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
    constructor Init;
    procedure ShowTerminalWindow;
  end;

procedure CheckParamList;
var
  F: file;
begin
  if ParamCount <> 1 then
  begin
    Writeln('Syntax: TVTXTDMO <file to view>');
    Halt(1);
  end;

  Assign(F, ParamStr(1));
  {$I-}
  Reset(F);
  {$I+}
  if IOResult <> 0 then
  begin
    Writeln('Cannot open file (', ParamStr(1), ')');
    Halt(1);
  end;

  Close(F);
end;

{ TTerminalWindow }
constructor TTerminalWindow.Init(Bounds: TRect; WinTitle: String;
  WindowNo: Word; var Interior: PTerminal; ABufSize: Word);
begin
  TWindow.Init(Bounds, WinTitle, WindowNo);
  Interior := MakeInterior(Bounds, ABufSize);
  Insert(Interior);
end;

function TTerminalWindow.MakeInterior(Bounds: TRect;
  ABufSize: Word): PTerminal;
begin
  GetExtent(Bounds);
  Bounds.Grow(-1, -1);
  MakeInterior := New(PTerminal, Init(Bounds,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard),
    ABufSize));
end;

constructor TMyApp.Init;
begin
  CheckParamList;
  TApplication.Init;
  ShowTerminalWindow;
end;

procedure TMyApp.ShowTerminalWindow;
var
  Demo: PTerminalWindow;
  Interior: PTerminal;
  T: Text;
  R: TRect;
  FText: Text;
  FGeneric: file of byte;
  St: String;
  Result: Word;

const
  BuffSize: Word = 8192;

begin
  { Open the file as a generic DOS file to get the file size.
    CheckParamList has already verified that the file exists
    and can be opened. }
  Assign(FGeneric, ParamStr(1));
  Reset(FGeneric);

  if MaxAvail - 1000 < BuffSize then
    BuffSize := MaxAvail - 1024;   { leave at least 1K free }

  if FileSize(FGeneric) > BuffSize then
  begin
    Str(BuffSize, St);
    { ignore  result, just post a message }
    Result := MessageBox('File is too big to fit in a TTerminal buffer.'#13+
      'Only the first ' + st + ' bytes of the file ' +
      'will be displayed.', nil, mfOkButton + mfWarning);
    end
  else
    { filesize < buffsize, so reduce the buffer size to conserve RAM }
    BuffSize := FileSize(FGeneric);

  Close(FGeneric);

  { Initialize the terminal window object }
  R.Assign(10, 1, 70, 18);
  Demo := New(PTerminalWindow, Init(R, ParamStr(1), wnNoNumber,
    Interior, BuffSize));
  Desktop^.Insert(Demo);

  { Assign the TTerminal interior text device driver to a text "file" }
  AssignDevice(T,PTerminal(Interior));
  Rewrite(T);
  Writeln(T, '');

  { Open the file as a text file for reading. }
  Assign(FText, ParamStr(1));
  Reset(FText);

  { Copy lines into scroller until eof or buffer is full }
  repeat
    Readln(FText, St);
    Writeln(T, St);
  until Eof(FText) or (not Interior^.CanInsert(Length(St)));

  Close(FText);
  Close(T);

  { set the scroller to its top }
  Interior^.ScrollTo(0, 0);
end;

var
  MyMain: TMyApp;

begin
  MyMain.Init;
  MyMain.Run;
  MyMain.Done;
end.
