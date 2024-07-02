{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Resource generator for TVRDEMO.EXE. This program generates the
  resource file that is used TVRDEMO.PAS. To build this program,
  execute the batch file, MKRDEMO.BAT.

  Note: This program is designed for real-mode use only.
}

program GenRDemo;

{$M 16384,8192,655360}

uses Drivers, Objects, Views, Dialogs, Menus, App, ColorSel,
  StdDlg, Editors, DemoHelp, DemoCmds, DemoStrs;

{ If you get a FILE NOT FOUND error when compiling this program,
  use the MKRDEMO.BAT file described above.
}

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

procedure CreateStrings;
var
  S: PStrListMaker;
begin
  S := New(PStrListMaker, Init(10000, 100));

  S^.Put(sNoMem, 'Not enough memory available to compilete operation.');
  S^.Put(sErrorReading, 'Error reading file %s.');
  S^.Put(sErrorWriting, 'Error writing file %s.');
  S^.Put(sErrorCreating, 'Error creating file %s.');
  S^.Put(sModified, '%s has been modified. Save?');
  S^.Put(sSaveUntitled, 'Save untitled file?');
  S^.Put(sStrNotFound, 'Search string not found.');
  S^.Put(sReplace, 'Replace this occurence?');
  S^.Put(sErrorHelp, 'Could not open help file.');
  S^.Put(sErrorOpenDesk, 'Could not open desktop file');
  S^.Put(sErrorReadingDesk, 'Error reading desktop file');
  S^.Put(sDeskInvalid, 'Error: Invalid Desktop file.');
  S^.Put(sErrorDeskCreate, 'Could not create TVDEMO.DSK.');

  RezFile.Put(S, 'Strings');
  Dispose(S, Done);
end;

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
      StdFileMenuItems(nil)),
    NewSubMenu('~E~dit', hcEdit, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmShowClip, hcShowClip,
      nil)))),
    NewSubMenu('~S~earch', hcSearch, NewMenu(
      NewItem('~F~ind...', '', kbNoKey, cmFind, hcFind,
      NewItem('~R~eplace...', '', kbNoKey, cmReplace, hcReplace,
      NewItem('~S~earch again', '', kbNoKey, cmSearchAgain, hcSearchAgain,
      nil)))),
    NewSubMenu('~W~indow', hcWindows, NewMenu(
      StdWindowMenuItems(nil)),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewItem('~M~ouse...', '', kbNoKey, cmMouse, hcOMouse,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcOColors,
      NewLine(
      NewItem('~S~ave desktop', '', kbNoKey, cmSaveDesktop, hcOSaveDesktop,
      NewItem('~R~etrieve desktop', '', kbNoKey, cmRetrieveDesktop, hcORestoreDesktop, nil)))))),
      nil)))))))));

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
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      NewStatusKey('~F5~ Zoom', kbF5, cmZoom,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize,
      nil))))))),
    nil)));

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
      ^C'Copyright (c) 1992'#13 +
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
    ColorGroup('Desktop',       DesktopColorItems(nil),
    ColorGroup('Menus',         MenuColorItems(nil),
    ColorGroup('Dialogs/Calc',  DialogColorItems(dpGrayDialog, nil),
    ColorGroup('Editor/Puzzle', WindowColorItems(wpBlueWindow, nil),
    ColorGroup('Ascii table',   WindowColorItems(wpGrayWindow, nil),
    ColorGroup('Calendar',
      WindowColorItems(wpCyanWindow,
      ColorItem('Current day',       22, nil)),
      nil))))))));
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

procedure CreateFindDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 38, 12);
  D := New(PDialog, Init(R, 'Find'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3, 3, 32, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(32, 3, 35, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 5, 35, 7);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only', nil)))));

    R.Assign(14, 9, 24, 11);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

  RezFile.Put(D, 'FindDialog');
  Dispose(D, Done);
end;

procedure CreateReplaceDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 16);
  D := New(PDialog, Init(R, 'Replace'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3, 3, 34, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(34, 3, 37, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 6, 34, 7);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 5, 12, 6);
    Insert(New(PLabel, Init(R, '~N~ew text', Control)));
    R.Assign(34, 6, 37, 7);
    Insert(New(PHistory, Init(R, PInputLine(Control), 11)));

    R.Assign(3, 8, 37, 12);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only',
      NewSItem('~P~rompt on replace',
      NewSItem('~R~eplace all', nil)))))));

    R.Assign(17, 13, 27, 15);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    R.Assign(28, 13, 38, 15);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

  RezFile.Put(D, 'ReplaceDialog');
  Dispose(D, Done);
end;

procedure CreateSaveAsDialog;
var
  D: PDialog;
begin
  D := New(PFileDialog, Init('*.*', 'Save file as', '~N~ame',
    fdOkButton + fdHelpButton + fdNoLoadDir, 101));
  RezFile.Put(D, 'SaveAsDialog');
  Dispose(D, Done);
end;

begin
  RezStream := New(PProtectedStream, Init('TVRDEMO.TVR', stCreate, 4096));
  RezFile.Init(RezStream);

  RegisterObjects;
  RegisterType(RStrListMaker);
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterStdDlg;
  RegisterColorSel;

  CreateStrings;
  CreateMenu;
  CreateStatusLine;
  CreateFileOpenDialog;
  CreateAboutDialog;
  CreateColorSelDialog;
  CreateChDirDialog;
  CreateFindDialog;
  CreateReplaceDialog;
  CreateSaveAsDialog;

  RezFile.Done;
end.
