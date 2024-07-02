{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

{ Resource generator for TVRDEMO.EXE. }

program GenRDemo;

{$M 16384,8192,655360}

uses Drivers, Objects, Views, Dialogs, Menus, App, ColorSel,
  StdDlg, DemoHelp, DemoCmds;

type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

var
  RezFile: TResourceFile;
  RezStream: PStream;

{ TProtectedStream }

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  Writeln('Error in stream: Code = ', Code, ' Info = ', Info);
  Halt(1);
end;

{ Resource procedures }

procedure CreateMenu;
var
  R: TRect;
  P: PView;
begin
  R.Assign(0, 0, 80, 1);
  P := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~'#240'~', hcSystem, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcSAbout,
      NewLine(
      NewItem('~P~uzzle', '', kbNoKey, cmPuzzle, hcSPuzzle,
      NewItem('Ca~l~endar', '', kbNoKey, cmCalendar, hcSCalendar,
      NewItem('Ascii ~t~able', '', kbNoKey, cmAsciiTab, hcSAsciiTable,
      NewItem('~C~alculator', '', kbNoKey, cmCalculator, hcCalculator, nil))))))),
    NewSubMenu('~F~ile', hcFile, NewMenu(
      NewItem('~O~pen...', 'F3', kbF3, cmFOpen, hcFOpen,
      NewItem('~C~hange dir...', '', kbNoKey, cmChDir, hcFChangeDir,
      NewLine(
      NewItem('~D~OS shell', '', kbNoKey, cmDosShell, hcFDosShell,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcFExit, nil)))))),
    NewSubMenu('~W~indows', hcWindows, NewMenu(
      NewItem('~R~esize/move','Ctrl-F5', kbCtrlF5, cmResize, hcWSizeMove,
      NewItem('~Z~oom', 'F5', kbF5, cmZoom, hcWZoom,
      NewItem('~N~ext', 'F6', kbF6, cmNext, hcWNext,
      NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcWClose,
      NewItem('~T~ile', '', kbNoKey, cmTile, hcWTile,
      NewItem('C~a~scade', '', kbNoKey, cmCascade, hcWCascade, nil))))))),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewItem('~M~ouse...', '', kbNoKey, cmMouse, hcOMouse,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcOColors,
      NewLine(
      NewItem('~S~ave desktop', '', kbNoKey, cmSaveDesktop, hcOSaveDesktop,
      NewItem('~R~etrieve desktop', '', kbNoKey, cmRetrieveDesktop, hcORestoreDesktop, nil)))))), nil)))))));

  RezFile.Put(P, 'MenuBar');
  Dispose(P, Done);
end;

procedure CreateStatusLine;
var
  R: TRect;
  P: PView;
begin
  R.Assign(0, 24, 80, 25);
  P := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F3~ Open', kbF3, cmFOpen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize, nil)))))), nil)));

  RezFile.Put(P, 'StatusLine');
  Dispose(P, Done);
end;

procedure CreateFileOpenDialog;
var
  P: PView;
begin
  P := New(PFileDialog, Init('*.*', 'Open a File',
    '~N~ame', fdOpenButton + fdHelpButton + fdNoLoadDir, 100));
  P^.HelpCtx := hcFOFileOpenDBox;

  RezFile.Put(P, 'FileOpenDialog');
  Dispose(P, Done);
end;

procedure CreateAboutDialog;
var
  R: TRect;
  D: PDialog;
begin
  R.Assign(0, 0, 40, 11);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'Turbo Vision Demo'#13 +
      #13 +
      ^C'Copyright (c) 1990'#13 +
      #13 +
      ^C'Borland International')));

    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;

  RezFile.Put(D, 'AboutDialog');
  Dispose(D, Done);
end;

procedure CreateColorSelDialog;
var
  R: TRect;
  D: PDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup('Desktop',
      ColorItem('Color',             32, nil),
    ColorGroup('Menus',
      ColorItem('Normal',            2,
      ColorItem('Disabled',          3,
      ColorItem('Shortcut',          4,
      ColorItem('Selected',          5,
      ColorItem('Selected disabled', 6,
      ColorItem('Shortcut selected', 7, nil)))))),
    ColorGroup('Dialogs/Calc',
      ColorItem('Frame/background',  33,
      ColorItem('Frame icons',       34,
      ColorItem('Scroll bar page',   35,
      ColorItem('Scroll bar icons',  36,
      ColorItem('Static text',       37,

      ColorItem('Label normal',      38,
      ColorItem('Label selected',    39,
      ColorItem('Label shortcut',    40,

      ColorItem('Button normal',     41,
      ColorItem('Button default',    42,
      ColorItem('Button selected',   43,
      ColorItem('Button disabled',   44,
      ColorItem('Button shortcut',   45,
      ColorItem('Button shadow',     46,

      ColorItem('Cluster normal',    47,
      ColorItem('Cluster selected',  48,
      ColorItem('Cluster shortcut',  49,

      ColorItem('Input normal',      50,
      ColorItem('Input selected',    51,
      ColorItem('Input arrow',       52,

      ColorItem('History button',    53,
      ColorItem('History sides',     54,
      ColorItem('History bar page',  55,
      ColorItem('History bar icons', 56,

      ColorItem('List normal',       57,
      ColorItem('List focused',      58,
      ColorItem('List selected',     59,
      ColorItem('List divider',      60,

      ColorItem('Information pane',  61, nil))))))))))))))))))))))))))))),
    ColorGroup('Viewer',
      ColorItem('Frame passive',      8,
      ColorItem('Frame active',       9,
      ColorItem('Frame icons',       10,
      ColorItem('Scroll bar page',   11,
      ColorItem('Scroll bar icons',  12,
      ColorItem('Text',              13, nil)))))),
    ColorGroup('Puzzle',
      ColorItem('Frame passive',      8,
      ColorItem('Frame active',       9,
      ColorItem('Frame icons',       10,
      ColorItem('Scroll bar page',   11,
      ColorItem('Scroll bar icons',  12,
      ColorItem('Normal text',       13,
      ColorItem('Highlighted text',  14, nil))))))),
    ColorGroup('Calendar',
      ColorItem('Frame passive',     16,
      ColorItem('Frame active',      17,
      ColorItem('Frame icons',       18,
      ColorItem('Scroll bar page',   19,
      ColorItem('Scroll bar icons',  20,
      ColorItem('Normal text',       21,
      ColorItem('Current day',       22, nil))))))),
    ColorGroup('Ascii table',
      ColorItem('Frame passive',     24,
      ColorItem('Frame active',      25,
      ColorItem('Frame icons',       26,
      ColorItem('Scroll bar page',   27,
      ColorItem('Scroll bar icons',  28,
      ColorItem('Text',              29, nil)))))), nil)))))))));
  D^.HelpCtx := hcOCColorsDBox;

  RezFile.Put(D, 'ColorSelectDialog');
  Dispose(D, Done);
end;

procedure CreateChDirDialog;
var
  R: TRect;
  D: PDialog;
begin
  D := New(PChDirDialog, Init(cdNormal + cdHelpButton + cdNoLoadDir, 101));
  D^.HelpCtx := hcFCChDirDBox;

  RezFile.Put(D, 'ChDirDialog');
  Dispose(D, Done);
end;

begin
  RezStream := New(PProtectedStream, Init('TVRDEMO.REZ', stCreate, 4096));
  RezFile.Init(RezStream);

  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterStdDlg;
  RegisterColorSel;

  CreateMenu;
  CreateStatusLine;
  CreateFileOpenDialog;
  CreateAboutDialog;
  CreateColorSelDialog;
  CreateChDirDialog;

  RezFile.Done;
end.