{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Resourc1;

uses Drivers, Objects, Views, App, Menus;

type
  PHaltStream = ^THaltStream;
  THaltStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

const cmNewDlg = 1001;
var
  MyRez: TResourceFile;
  MyStrm: PHaltStream;

procedure THaltStream.Error(Code, Info: Integer);
begin
  Writeln('Stream error: ', Code, ' (',Info,')');
  Halt(1);
end;

procedure CreateStatusLine;
var
  R: TRect;
  StatusLine: PStatusLine;
begin
  R.Assign(0, 24, 80, 25);
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F3~ Open', kbF3, cmNewDlg,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)))),
    nil)
  ));
  MyRez.Put(StatusLine, 'Waldo');
  Dispose(StatusLine, Done);
end;

begin
  MyStrm := New(PHaltStream, Init('MY.TVR', stCreate, 1024));
  MyRez.Init(MyStrm);
  RegisterType(RStatusLine);
  CreateStatusLine;
  MyRez.Done;
end.
