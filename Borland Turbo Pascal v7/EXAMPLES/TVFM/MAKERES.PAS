{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program MakeRes;  { Makes resource file for TVFM }

uses Dos, Objects, Drivers, App, Views, Menus, Dialogs, StdDlg,
  Globals, Equ;



{ ---------------  Generate Resources  ------------------ }

procedure MakeMenuBar;
var
  R: TRect;
  M: PMenuBar;
begin
  R.Assign(0,0,80,1);
  M := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcFileMenu, NewMenu(
      NewItem('~N~ew window...', 'F3', kbF3, cmNewWindow, hcNewWindow,
      NewLine(
      NewItem('~E~xecute file...', '', 0, cmExecute, hcExecute,
      NewSubMenu('~V~iew', hcViewSubMenu, NewMenu(
        NewItem('View as ~t~ext', 'Ctrl+F4', kbCtrlF4, cmViewAsText, hcViewAsText,
        NewItem('View as ~h~ex', 'Alt+F4', kbAltF4, cmViewAsHex, hcViewAsHex,
        NewItem('~C~ustom viewer', 'F4', kbF4, cmViewCustom, hcViewCustom,
        nil)))),
      NewLine(
      NewItem('~A~ssociate...', '', 0, cmAssociate, hcAssociate,
      NewItem('~C~opy...', 'F7', kbF7, cmCopy, hcCopy,
      NewItem('~D~elete...', '', 0, cmDelete, hcDelete,
      NewItem('~R~ename...', '', 0, cmRename, hcRename,
      NewItem('Chan~g~e attr...', '', 0, cmChangeAttr, hcChangeAttr,
      NewItem('~S~earch for files...', '', 0, cmBeginSearch, hcBeginSearch,
      NewLine(
      NewSubMenu('~T~ags', hcTagSubMenu, NewMenu(
        NewItem('~R~everse all tags', '', 0, cmReverseTags, hcReverseTags,
        NewItem('~C~lear tags', '', 0, cmClearTags, hcClearTags,
        NewItem('Tag per ~w~ildcard...', '',0, cmTagPerCard, hcTagPerCard,
        nil)))),
      NewLine(
      NewItem('R~u~n DOS command...', '', 0, cmRun, hcRun,
      NewItem('D~O~S shell', '', 0, cmDosShell, hcDosShell,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcQuit,
      NewItem('Exit to c~u~rrent dir', 'Alt-C', kbAltC, cmExitHere, hcExitHere,
      nil)))))))))))))))))))),
    NewSubMenu('~O~ptions', hcOptionsMenu, NewMenu(
      NewItem('Toggle ~v~ideo mode', 'Alt-F10', kbAltF10, cmVideoMode, hcVideoMode,
      NewItem('~I~nstall custom viewer...', '', 0, cmInstallViewer, hcInstallViewer,
      NewItem('~D~isplay preferences...', '', 0, cmDisplayOptions, hcDisplayOptions,
      NewItem('~C~hange colors', '', 0, cmColorChange, hcColorChange,
      NewLine(
      NewItem('~S~ave configuration', '', 0, cmSaveConfig, hcSaveConfig,
      nil))))))),
    NewSubMenu('~W~indows', hcWindowMenu, NewMenu(
      StdWindowMenuItems(nil)
      ),
    nil))))));
  RezFile.Put(M, 'MainMenu');
  Dispose(M, Done);
end;

procedure MakeStatusLine;
var
  R: TRect;
  P: PView;
begin
  R.Assign(0, 24, 80, 25);
  P := New(PHCStatusLine, Init(R,
    NewStatusDef(0, 0,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F3~ New window', kbF3, cmNewWindow,
      NewStatusKey('~F4~ View custom', kbF4, cmViewCustom,
      NewStatusKey('~F7~ Copy', kbF7, cmCopy,
      NewStatusKey('', kbAltF3, cmClose,
      NewStatusKey('', kbDel, cmDelete,
      NewStatusKey('', kbCtrlEnter, cmExecute,
      NewStatusKey('', kbAltC, cmExitHere,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbCtrlBack, cmClearTags,
      nil)))))))))),
    NewStatusDef(1, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      nil),
    nil))));
  RezFile.Put(P, 'StatusLine');
  Dispose(P, Done);
end;

procedure MakeStrings;
var
  P : PStrListMaker;
begin
  p := New(PStrListMaker, Init(16384,100));
  with p^ do
  begin
    { menu hint strings }
    Put(hcFileMenu, 'File related commands');
    Put(hcNewWindow, 'Open a new file tree window');
    Put(hcExecute,'Execute the highlighted file');
    Put(hcViewSubMenu,'Commands to view highlighted file');
    Put(hcViewAsText,'View highlighted file in a text window');
    Put(hcViewAsHex,'View highlighted file in a hex window');
    Put(hcViewCustom,'View highlighted file using your custom viewer');
    Put(hcAssociate, 'Associate a program with highlighted file');
    Put(hcCopy,'Copy highlighted or tagged files to another drive/dir');
    Put(hcDelete,'Delete highlighted or tagged file(s)');
    Put(hcRename,'Rename highlighted file');
    Put(hcChangeAttr,'Change highlighted file''s attributes');
    Put(hcBeginSearch,'Search for files matching a wildcard');
    Put(hcTagSubMenu,'Commands to tag/untag files');
    Put(hcReverseTags,'Reverse the tagged status of all files');
    Put(hcClearTags,'Remove all tags from files');
    Put(hcTagPerCard,'Tag files per a wildcard you specify');
    Put(hcRun, 'Enter a DOS command to run');
    Put(hcDosShell, 'Temporarily exit to the command processor');
    Put(hcQuit, 'Exit this program');
    Put(hcExitHere, 'Exit to the currently highlighted directory');

    Put(hcOptionsMenu,'Program options');
    Put(hcVideoMode,'Toggle between 25 and 42/50 line mode (EGA or better)');
    Put(hcInstallViewer,'Install your custom file viewer');
    Put(hcDisplayOptions,'Set file display options');
    Put(hcColorChange,'Select a new color palette');
    Put(hcSaveConfig,'Save current configuration for future use');

    Put(hcWindowMenu, 'Standard window manipulation commands');
    Put(hcTile,'Arrange all windows on desktop without overlap');
    Put(hcCascade,'Arrange all windows by overlapping');
    Put(hcCloseAll,'Close all open windows on desktop');
    Put(hcResize,'Resize or move the current window');
    Put(hcZoom,'Grow current window to cover desktop');
    Put(hcNext,'Move focus to the next window on the desktop');
    Put(hcPrev,'Move focus to the previous window on the desktop');
    Put(hcClose,'Close the current window');

    Put(hcDisplayFields, 'This is a test of the help context');

    { other assorted program strings }
    Put(sNoFiles, '<no files>');
    Put(sPleaseWait, 'Please wait...');
    Put(sSameNameErr, 'You may not use the same name!');
    Put(sRenameErr, 'Error %d renaming file');
    Put(sSetAttrErr, 'Error %d setting attributes on %s');
    Put(sNoAssociation, '%s has no association.');
    Put(sPressAnyKey, 'Press any key to return...');
    Put(sExecErr, 'Error %d executing '#13'%s');
    Put(sExecRetCode, 'An exit code of %d was returned');
    Put(sNoViewerErr, 'No custom viewer set.');
    Put(sInvokeErr, 'Error %d invoking %s');
    Put(sNoDrivesErr, 'Unable to detect any valid drives!');
    Put(sAccessErr, 'Error %d accessing %s');
    Put(sFileIsReadOnly, '(File marked as Read-Only)');
    Put(sDeleteErr, 'Error %d deleting %s');
    Put(sDeleting, 'Deleting ');
    Put(sReadAttrErr, 'Unable to read attributes from this file!');
    Put(sCustomViewer, 'Custom Viewer');
    Put(sPathAndName, 'Path and Filename');
    Put(sCantLocateOnPath, 'Unable to locate file on path');
    Put(sFileNotAnExe, '%s is not an executable file.');
    Put(sWriteCfgErr, 'Error %d writing config file');
    Put(sInvalidCfgErr, 'Invalid configuration file.');
    Put(sReading, 'Reading ');
    Put(sWriting, 'Writing ');
    Put(sScanning, 'Scanning %s drive');
    Put(sDelSingle, 'Delete this file?');
    Put(sDelMult, 'Delete these files?');
  end;

  RezFile.Put(P, 'Strings');
  Dispose(P, Done);
end;


procedure MakeAboutBox;
var
  D: PDialog;
  Control: PView;
  R: TRect;
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
      ^C'TV File Manager Demo'#13 +
      #13 +
      ^C'Copyright (c) 1992'#13 +
      #13 +
      ^C'Borland International')));

    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  RezFile.Put(D, 'AboutBox');
  Dispose(D, Done);
end;

procedure MakeDeleteWhichDialog;
var
  D: PDialog;
  R: TRect;
begin
  R.Assign(0,0,41,10);
  D:=New(PDialog, Init(R, 'Delete Which?'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(2,2,38,4);
    Insert(New(PStaticText, Init(R, 'Delete all Tagged files or just the Current file?')));
    R.Assign(1,7,13,9);
    Insert(New(PButton,Init(R, '~T~agged', cmYes, bfNormal)));
    R.Move(13,0);
    Insert(New(PButton,Init(R, 'C~u~rrent', cmNo, bfNormal)));
    R.Move(13,0);
    Insert(New(PButton,Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  RezFile.Put(D, 'DeleteWhich');
  Dispose(D, Done);
end;

procedure MakeConfirmDelDialog;
var
  D: PDialog;
  R: TRect;
begin
  R.Assign(0,0,60,8);
  D:=New(PDialog, Init(R, 'Confirm Deletion'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(2,2,58,4);
    Insert(New(PParamText, Init(R, 'Please confirm deletion of: %s'#13'%s',2)));
    R.Assign(32,5,44,7);
    Insert(New(PButton,Init(R, '~Y~es', cmYes, bfNormal)));
    R.Move(14,0);
    Insert(New(PButton,Init(R, '~N~o', cmNo, bfNormal)));
    SelectNext(False);
  end;
  RezFile.Put(D, 'ConfirmDelete');
  Dispose(D, Done);
end;


procedure MakeDisplayPrefDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
begin
  R.Assign(0,0,43,20);
  D := New(PDialog, Init(R, 'Display Preferences'));

  with D^ do
  begin
    Options := Options or ofCentered;
    { file mask }
    R.Assign(13,2,27,3);
    P := New(PInputLine, Init(R, 12));
    Insert(P);
    R.Assign(2,2,12,3);
    Insert(New(PLabel, Init(R, 'File ~M~ask', P)));

    R.Assign(2,4,26,5);
    P := New(PCheckboxes, Init(R, NewSItem('Show ~H~idden/System',nil)));
    Insert(P);

    { sort by }
    R.Assign(2,7,17,11);
    P := New(PRadioButtons, Init(R, NewSItem('~N~ame',
                                    NewSItem('~E~xtension',
                                    NewSItem('~S~ize',
                                    NewSItem('~D~ate/Time',
                                    nil))))));
    Insert(P);
    R.Assign(2,6,10,7);
    Insert(New(PLabel, Init(R, 'Sort By', P)));

    { sort dir }
    R.Assign(2,13,18,15);
    P := New(PRadioButtons, Init(R, NewSItem('As~c~ending',
                                    NewSItem('Descendin~g~',
                                    nil))));
    Insert(P);

    R.Assign(2,12,17,13);
    Insert(New(PLabel, Init(R, 'Sort Direction', P)));

    { display case }
    R.Assign(23,7,39,9);
    P := New(PRadioButtons, Init(R, NewSItem('~L~ower Case',
                                    NewSItem('~U~pper Case',
                                    nil))));
    Insert(P);
    R.Assign(23,6,36,7);
    Insert(New(PLabel, Init(R, 'Display Case', P)));

    { display fields }
    R.Assign(23,11,39,15);
    P := New(PCheckboxes, Init(R, NewSItem('S~i~ze',
                                  NewSItem('D~a~te',
                                  NewSItem('T~i~me',
                                  NewSItem('A~t~tributes',
                                  nil))))));
    Insert(P);

    R.Assign(23,10,38,11);
    Insert(New(PLabel, Init(R, 'Display Fields', P)));

    R.Assign(7,17,19,19);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
    R.Assign(22,17,34,19);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  RezFile.Put(D, 'DisplayPref');
  Dispose(D, Done);
end;

procedure MakeRunDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
begin
  R.Assign(0,0,70,7);
  D := New(PDialog, Init(R, 'Run DOS Program'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(15,2,66,3);
    P := New(PInputLine, Init(R, 255));
    Insert(P);
    R.Assign(1,2,15,3);
    Insert(New(PLabel, Init(R, 'Command ~L~ine', P)));
    R.Assign(66,2,69,3);
    Insert(New(PHistory, Init(R, PInputLine(P), cmRun)));
    R.Assign(30,4,43,6);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
    R.Move(14,0);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  RezFile.Put(D, 'RunDialog');
  Dispose(D, Done);
end;

procedure MakeCopyDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
begin
  R.Assign(0,0,60,7);
  D:=New(PDialog, Init(R, 'Copy File(s)'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(14,2,56,3);
    P := New(PInputLine, Init(R, 80));
    Insert(P);
    R.Assign(1,2,14,3);
    Insert(New(PLabel, Init(R, '~D~estination', P)));
    R.Assign(56,2,59,3);
    Insert(New(PHistory, Init(R, PInputLine(P), cmCopy)));

    R.Assign(31,4,43,6);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
    R.Move(14,0);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  RezFile.Put(D, 'CopyDialog');
  Dispose(D, Done);
end;

procedure MakeSearchDialog;
var
  D: PDialog;
  R: TRect;
  P: PView;
begin
  R.Assign(0,0,50,8);
  D := New(PDialog, Init(R, 'Search Criteria'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(20,2,34,3);
    P := New(PInputLine, Init(R, 12));
    Insert(P);
    R.Assign(2,2,20,3);
    Insert(New(PLabel, Init(R, '~F~ile mask', P)));
    R.Assign(20,3,48,4);
    P := New(PInputLine, Init(R, SizeOf(PathStr) - 1));
    Insert(P);
    R.Assign(2,3,20,4);
    Insert(New(PLabel, Init(R, '~S~tarting from', P)));
    R.Assign(10,5,20,7);
    Insert(New(PButton, Init(R, '~B~egin', cmOK, bfDefault)));
    R.Move(14,0);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  RezFile.Put(D, 'SearchDialog');
  Dispose(D, Done);
end;



begin
  Writeln('Resource File Maker for TVFM.PAS,  version 1.0');
  Writeln;

  RezStream := New(PProtectedStream, Init('TVFM.TVR', stCreate, 4096));
  RezFile.Init(RezStream);

  RegisterObjects;  { registers TStringCollection }
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterStdDlg;

  RegisterGlobals;
  RegisterType(RStrListMaker);

  MakeMenuBar;
  MakeStatusLine;
  MakeStrings;
  MakeAboutBox;
  MakeDeleteWhichDialog;
  MakeConfirmDelDialog;
  MakeDisplayPrefDialog;
  MakeRunDialog;
  MakeCopyDialog;
  MakeSearchDialog;
  RezFile.Done;
end.
