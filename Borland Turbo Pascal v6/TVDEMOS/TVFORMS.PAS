{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

program TVForms;

{$M 8192,8192,655360}
{$X+,S-}

{ This Turbo Vision application uses forms to enter and edit data
  in a collection. Two data files, PHONENUM.TVF and PARTS.TVF, are
  provided and can be loaded using this application's File|Open menu.
  The .TVF files were created by GENFORMS.BAT, which compiles and
  and runs GENFORM.PAS. You can create additional data files by
  copying and modifying GENPARTS.PAS or GENPHONE.PAS and then
  incorporating your new unit into GENFORM.PAS and GENFORMS.BAT.
}

uses
  Dos, Objects, Memory, Drivers, Views, Menus, Dialogs, HistList,
  Stddlg, App, MsgBox, Editors, DataColl, ListDlg, Forms, Fields,
  FormCmds;

type
  PFormApp = ^TFormApp;
  TFormApp = object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;

{ TFormApp }
constructor TFormApp.Init;
var
  Event: TEvent;
begin
  TApplication.Init;
  { Register all objects that will be loaded or stored on streams }
  RegisterObjects;
  RegisterViews;
  RegisterDialogs;
  RegisterDataColl;
  RegisterForms;
  RegisterEditors;
  RegisterFields;

  { Display about box }
  Event.What := evCommand;
  Event.Command := cmAboutBox;
  PutEvent(Event);
end;

procedure TFormApp.HandleEvent(var Event: TEvent);
var
  NewMode: Word;

procedure ChangeDir;
var
  D: PChDirDialog;
begin
  D := New(PChDirDialog, Init(0, hlChangeDir));
  if ValidView(D) <> nil then
  begin
    DeskTop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

procedure DosShell;
begin
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneMemory;
  SetMemTop(HeapPtr);
  PrintStr('Type EXIT to return...');
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  SetMemTop(HeapEnd);
  InitMemory;
  InitVideo;
  InitEvents;
  InitSysError;
  Redraw;
end;

procedure OpenListDialog;
var
  D: PFileDialog;
  FileName: ^PathStr;
  ListEditor: PDialog;
begin
  D := New(PFileDialog, Init('*.TVF', 'Open File',
    '~N~ame', fdOpenButton, hlOpenListDlg));
  if ValidView(D) <> nil then
  begin
    if Desktop^.ExecView(D) <> cmCancel then
    begin
      New(FileName);
      D^.GetFileName(FileName^);
      if not FileExists(FileName^) then
        MessageBox('Cannot find file (%s).', @FileName, mfError + mfOkButton)
      else
      begin
        { If ListEditor exists, select it; otherwise, open new one }
        ListEditor := Message(Desktop, evBroadcast, cmEditingFile, FileName);
        if ListEditor = nil then
          DeskTop^.Insert(ValidView(New(PListDialog, Init(FileName^))))
        else ListEditor^.Select;
      end;
      Dispose(FileName);
    end;
    Dispose(D, Done);
  end;
end;

begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmListOpen: OpenListDialog;
      cmChangeDir: ChangeDir;
      cmDosShell: DosShell;
      cmAboutBox: MessageBox(#3'Turbo Pascal 6.0'#13#13#3 +
        'Turbo Vision Forms Demo', nil, mfInformation + mfOkButton);
      cmVideoMode:
        begin
          NewMode := ScreenMode xor smFont8x8;
          if NewMode and smFont8x8 <> 0 then
            ShadowSize.X := 1
          else ShadowSize.X := 2;
          SetScreenMode(NewMode);
        end;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TFormApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~'#240'~', hcNoContext, NewMenu(

      NewItem('~V~ideo mode','', kbNoKey, cmVideoMode, hcNoContext,
      NewLine(
      NewItem('~A~bout...','', kbNoKey, cmAboutBox, hcNoContext, nil)))),
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen...','F3', kbF3, cmListOpen, hcNoContext,
      NewItem('~S~ave','F2', kbF2, cmListSave, hcNoContext,
      NewLine(
      NewItem('~C~hange directory...','', kbNoKey, cmChangeDir, hcNoContext,
      NewItem('~D~OS shell','', kbNoKey, cmDosShell, hcNoContext,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil))))))),
    NewSubMenu('~W~indow', hcNoContext, NewMenu(
      NewItem('~M~ove','Ctrl-F5', kbCtrlF5, cmResize, hcNoContext,
      NewItem('~N~ext','F6', kbF6, cmNext, hcNoContext,
      NewItem('~P~rev','Shift-F6', kbShiftF6, cmPrev, hcNoContext,
      NewItem('~C~lose','Alt-F3', kbAltF3, cmClose, hcNoContext, nil))))), nil))))))
end;

procedure TFormApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y-1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F2~ Save', kbF2, cmListSave,
      NewStatusKey('~F3~ Open', kbF3, cmListOpen,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize, nil)))), nil)));
end;

var
  FormApp: TFormApp;
begin
  FormApp.Init;
  FormApp.Run;
  FormApp.Done;
end.
