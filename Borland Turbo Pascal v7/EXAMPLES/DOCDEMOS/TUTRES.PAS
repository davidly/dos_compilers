{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TutRes;

uses TutConst, Drivers, Objects, Views, Menus, Dialogs, Validate, Editors,
  App;

var
  R: TRect;
  ResFile: TResourceFile;
  MainMenu: PMenuBar;
  StatLine: PStatusLine;
  OrderWindow, AboutBox: PDialog;
  Field: PInputLine;
  Cluster: PCluster;
  Memo: PMemo;

begin
  RegisterViews;
  RegisterDialogs;
  RegisterMenus;
  RegisterValidate;
  RegisterEditors;
  ResFile.Init(New(PBufStream, Init('TUTORIAL.TVR', stCreate, 2048)));
  R.Assign(0, 0, 80, 1);
  New(MainMenu, Init(R, NewMenu(
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
    NewSubMenu('Op~t~ions', hcNoContext, NewMenu(
      NewItem('~T~oggle video mode', '', kbNoKey, cmOptionsVideo, hcNoContext,
      NewItem('~S~ave desktop...', '', kbNoKey, cmOptionsSave, hcNoContext,
      NewItem('~L~oad desktop...', '', kbNoKey, cmOptionsLoad, hcNoContext,
      nil)))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~O~rders', '', kbNoKey, cmOrderWin, hcNoContext,
      NewItem('S~u~ppliers', '', kbNoKey, cmSupplierWin, hcNoContext,
      NewItem('Stoc~k~ items', '', kbNoKey, cmStockWin, hcNoContext,
      NewLine(
      StdWindowMenuItems(nil)))))),
    NewSubMenu('~H~elp', hcNoContext, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcNoContext,
      nil)),
    nil)))))))));
  ResFile.Put(MainMenu, 'MAINMENU');

  R.Assign(0, 24, 80, 25);
  New(StatLine, Init(R,
    NewStatusDef(0, $CFFF,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~F4~ New', kbF4, cmNew,
      NewStatusKey('~Alt+F3~ Close', kbAltF3, cmClose,
      StdStatusKeys(nil)))),
    NewStatusDef($D000, $DFFF,
      NewStatusKey('~PgUp~ Prev', kbPgUp, cmSupplierPrev,
      NewStatusKey('~PgDn~ Next', KbPgDn, cmSupplierNext,
      nil)),
    NewStatusDef($E000, $EFFF,
      NewStatusKey('~PgUp~ Prev', kbPgUp, cmStockPrev,
      NewStatusKey('~PgDn~ Next', KbPgDn, cmStockNext,
      nil)),
    NewStatusDef($F000, $FEFF,
      NewStatusKey('~PgUp~ Prev', kbPgUp, cmOrderPrev,
      NewStatusKey('~PgDn~ Next', kbPgDn, cmOrderNext,
      StdStatusKeys(nil))),
    NewStatusDef($FF00, $FFFF,
      StdStatusKeys(nil), nil)))))));
  ResFile.Put(StatLine, 'STATUS');

  R.Assign(0, 0, 40, 11);
  AboutBox := New(PDialog, Init(R, 'About Tutorial'));
  with AboutBox^ do
  begin
    Options := Options or ofCentered;
    R.Assign(4, 2, 36, 4);
    Insert(New(PStaticText, Init(R, #3'Turbo Vision 2.0'#13#3'Tutorial program')));
    R.Assign(4, 5, 36, 7);
    Insert(New(PStaticText, Init(R, #3'Copyright 1992'#13#3'Borland International')));
    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'O~k~', cmOk, bfDefault)));
  end;
  ResFile.Put(AboutBox, 'ABOUTBOX');

  R.Assign(0, 0, 60, 17);
  OrderWindow := New(PDialog, Init(R, 'Orders'));
  with OrderWindow^ do
  begin
    Options := Options or ofCentered;
    HelpCtx := $F000;

    R.Assign(13, 2, 23, 3);
    Field := New(PInputLine, Init(R, 8));
    Field^.SetValidator(New(PRangeValidator, Init(1, 32767)));
    Insert(Field);
    R.Assign(2, 2, 12, 3);
    Insert(New(PLabel, Init(R, '~O~rder #:', Field)));

    R.Assign(13, 4, 23, 5);
    Field := New(PInputLine, Init(R, 8));
    Field^.SetValidator(New(PPXPictureValidator, Init('&&&-####', True)));
    Insert(Field);
    R.Assign(2, 4, 12, 5);
    Insert(New(PLabel, Init(R, '~S~tock #:', Field)));

    R.Assign(43, 2, 53, 3);
    Field := New(PInputLine, Init(R, 8));
    Field^.SetValidator(New(PPXPictureValidator, Init('{#[#]}/{#[#]}/{##[##]}', True)));
    Insert(Field);
    R.Assign(26, 2, 41, 3);
    Insert(New(PLabel, Init(R, '~D~ate of order:', Field)));

    R.Assign(46, 4, 53, 5);
    Field := New(PInputLine, Init(R, 5));
    Field^.SetValidator(New(PRangeValidator, Init(1, 32767)));
    Insert(Field);
    R.Assign(26, 4, 44, 5);
    Insert(New(PLabel, Init(R, '~Q~uantity ordered:', Field)));

    R.Assign(3, 7, 57, 8);
    Cluster := New(PRadioButtons, Init(R,
      NewSItem('Cash   ',
      NewSItem('Check  ',
      NewSItem('P.O.   ',
      NewSItem('Account', nil))))));
    Insert(Cluster);
    R.Assign(2, 6, 21, 7);
    Insert(New(PLabel, Init(R, '~P~ayment method:', Cluster)));

    R.Assign(22, 8, 37, 9);
    Cluster := New(PCheckBoxes, Init(R, NewSItem('~R~eceived', nil)));
    Insert(Cluster);

    R.Assign(3, 10, 57, 13);
    Memo := New(PMemo, Init(R, nil, nil, nil, 255));
    Insert(Memo);
    R.Assign(2, 9, 9, 10);
    Insert(New(PLabel, Init(R, 'Notes:', Memo)));

    R.Assign(2, 14, 12, 16);
    Insert(New(PButton, Init(R, '~N~ew', cmOrderNew, bfNormal)));
    R.Assign(17, 14, 27, 16);
    Insert(New(PButton, Init(R, '~S~ave', cmOrderSave, bfDefault)));
    R.Assign(32, 14, 42, 16);
    Insert(New(PButton, Init(R, '~C~ancel', cmOrderCancel, bfNormal)));
    R.Assign(45, 14, 55, 16);
    Insert(New(PButton, Init(R, 'Next', cmOrderNext, bfNormal)));
    SelectNext(False);
  end;
  ResFile.Put(OrderWindow, 'ORDERS');
  ResFile.Done;
end.
