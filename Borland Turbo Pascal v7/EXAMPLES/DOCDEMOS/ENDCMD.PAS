{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program EndCmd;

uses Objects, App, Dialogs, Views, Drivers, Menus, MsgBox;

type
  PButtonDialog = ^TButtonDialog;
  TButtonDialog = object(TDialog)
    constructor Init;
  end;

  TEMApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitStatusLine; virtual;
  end;

const
  cmDoDialog = 700;

constructor TButtonDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 27, 8);
  inherited Init(R, 'Press a button');
  Options := Options or ofCentered;
  R.Assign(2, 2, 12, 4);
  Insert(New(PButton, Init(R, 'O~k~', cmOK, bfDefault)));
  R.Assign(2, 5, 12, 7);
  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  R.Assign(15, 2, 25, 4);
  Insert(New(PButton, Init(R, '~Y~es', cmYes, bfNormal)));
  R.Assign(15, 5, 25, 7);
  Insert(New(PButton, Init(R, '~N~o', cmNo, bfNormal)));
  SelectNext(False);
end;

procedure TEMApp.HandleEvent(var Event: TEvent);
var
  ReturnVal: Word;
  TheCommand: PString;
const
  CommandName: array[cmOK..cmNo] of string[8] =
    ('cmOK', 'cmCancel', 'cmYes', 'cmNo');
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    if Event.Command = cmDoDialog then
    begin
      ReturnVal := ExecuteDialog(New(PButtonDialog, Init), nil);
      TheCommand := @CommandName[ReturnVal];
      MessageBox(#3'Modal state ended'#13#3'with command %s.',
         @TheCommand, mfInformation or mfOKButton);
    end;
  end;
end;

procedure TEMApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R, NewStatusDef(0, $FFFF,
    NewStatusKey('~F3~ Open dialog box', kbF3, cmDoDialog,
    NewStatusKey('~Alt+X~ Exit', kbAltX, cmQuit, nil)), nil)));
end;

var
  EMApp: TEMApp;
begin
  EMApp.Init;
  EMApp.Run;
  EMApp.Done;
end.
