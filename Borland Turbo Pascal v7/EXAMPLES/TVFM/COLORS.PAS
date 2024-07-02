{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit Colors;

{$X+,V-}

interface

procedure SelectNewColors;

implementation

uses Memory, Drivers, Objects, Views, Dialogs, StdDlg, App, Equ, Dos,
  MsgBox;

const
  cmPreview = 100;

const
  PaletteMask = '*.PAL';

type
  PColorDialog = ^TColorDialog;
  TColorDialog = object(TFileDialog)
    NewPalette: TPalette;
    SavePalette: TPalette;
    constructor Init(AWildCard: TWildStr; const ATitle,
      InputName: String; AOptions: Word; HistoryId: Byte);
    procedure HandleEvent(var Event: TEvent); virtual;
    function LoadPalette: Boolean;
    function Valid(Command: Word): Boolean; virtual;
  end;


{ TColorDialog }
constructor TColorDialog.Init(AWildCard: TWildStr; const ATitle,
  InputName: String; AOptions: Word; HistoryId: Byte);
var
  R: TRect;
begin
  inherited Init(AWildCard, ATitle, InputName, AOptions, HistoryId);
  SavePalette := Application^.GetPalette^;
  R.Assign(35,10,46,12);
  Insert(New(PButton, Init(R, 'Pre~v~iew', cmPreview, bfNormal)));
  SelectNext(False);
end;

{ Loads the specified palette into the NewPalette variable }
function TColorDialog.LoadPalette: Boolean;
var
  F: File;
  Result: Integer;
  PalSize: Integer;
  Name: FNameStr;
begin
  GetFileName(Name);
  LoadPalette := False;
  Assign(F, Name);
{$I-}
  Reset(F,1);
{$I+}
  Result := IOResult;
  if Result <> 0 then
  begin
    MessageBox('Unable to load ' + Name, nil, mfError + mfOKButton);
    Exit;
  end;
  BlockRead(F, NewPalette[1], 255, PalSize);
  NewPalette[0] := Char(PalSize);
  System.Close(F);
  Application^.GetPalette^ := NewPalette;
  DoneMemory;
  Application^.ReDraw;
  LoadPalette := True;
end;

procedure TColorDialog.HandleEvent(var Event: TEvent);
var
  PalName: FNameStr;
begin
  if (Event.What = evCommand) and ((Event.Command = cmPreview) or
    (Event.Command = cmOK)) then
    LoadPalette;
  inherited HandleEvent(Event);
end;

function TColorDialog.Valid(Command: Word): Boolean;
var
  PalName: FNameStr;
begin
  Valid := inherited Valid(Command);
  if Command = cmFileOpen then
    LoadPalette
  else if Command = cmCancel then
  begin
    Application^.GetPalette^ := SavePalette;
    DoneMemory;
    Application^.ReDraw;
  end;
end;

procedure SelectNewColors;
var
  D: PColorDialog;
begin
  D := New(PColorDialog, Init(PaletteMask, 'Select Color', '~P~alette Name',
    fdOpenButton, 100));
  Application^.ExecuteDialog(D, nil);
end;

end.