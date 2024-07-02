{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit Forms;

{$F+,O+,X+,S-,D-}

interface

uses Objects, Drivers, Views, Dialogs;

type
  PForm = ^TForm;
  TForm = object(TDialog)
    ListDialog: PView;
    PrevData: Pointer;
    KeyWidth: Word;
    constructor Load(var S: TStream);
    function Changed: Boolean; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;

const
  RForm: TStreamRec = (
    ObjType: 10070;
    VmtLink: Ofs(TypeOf(TForm)^);
    Load: @TForm.Load;
    Store: @TForm.Store);

procedure RegisterForms;

implementation

uses FormCmds, Stddlg, MsgBox, ListDlg;

function CompBlocks(Buf1, Buf2 : Pointer;
  BufSize : Word): Boolean; far; assembler;
{ Compares two buffers and returns True if contents are equal }
asm
	PUSH	DS
	MOV	AX, 1			{ Init error return: True }
	LDS	SI, Buf1
	LES	DI, Buf2
	MOV	CX, BufSize
	JCXZ	@@Done

{ Loop until different or end of buffer }
	CLD             		{ Flag to bump SI,DI }
	REP	CMPSB
	JE	@@Done

{ Compare error }
	XOR	AX, AX			{ Return False }

@@Done:
	POP	DS			{ Restore }
end;

procedure RegisterForms;
begin
  RegisterType(RForm);
end;

constructor TForm.Load(var S: TStream);
begin
  TDialog.Load(S);
  S.Read(KeyWidth, SizeOf(KeyWidth));
end;

function TForm.Changed: Boolean;
var
  CurData: Pointer;
  CompSize: Word;
  NewForm: Boolean;
begin
  CompSize := DataSize;
  GetMem(CurData, CompSize);
  GetData(CurData^);
  NewForm := PrevData = nil;
  if NewForm then
  begin
    { Dummy up empty record for comparison }
    GetMem(PrevData, CompSize);
    FillChar(PrevData^, CompSize, 0);
  end;
  Changed := not CompBlocks(PrevData, CurData, CompSize);
  FreeMem(CurData, CompSize);
  if NewForm then
  begin
    FreeMem(PrevData, CompSize);
    PrevData := nil;
  end;
end;

procedure TForm.HandleEvent(var Event: TEvent);
begin
  { Respond to CANCEL button and ESC }
  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc)) or
     ((Event.What = evCommand) and (Event.Command = cmCancel)) then
  begin
    ClearEvent(Event);
    Free;
    Exit;
  end;

  { Respond to SAVE button }
  if ((Event.What = evCommand) and (Event.Command = cmFormSave)) then
  begin
    ClearEvent(Event);
    if Changed then
    begin
      if PListDialog(ListDialog)^.SaveForm(@Self) then
      begin
        Free;
        Exit;
      end;
    end
    else
    begin
      Free;                        { not changed }
      Exit;
    end;
  end;

  TDialog.HandleEvent(Event);

  { Respond to TopForm and RegisterForm messages }
  if Event.What = evBroadcast then
  begin
    if (Event.Command = cmEditingForm) then
    begin
      { Already editing broadcast form? }
      if (PrevData <> nil) and (Event.InfoPtr = PrevData) then
        ClearEvent(Event);
    end
    else
      { Belong to sending ListDialog? }
      if ListDialog = Event.InfoPtr then
      begin
        if Event.Command = cmTopForm then ClearEvent(Event)
        else if Event.Command = cmCanCloseForm then
        begin
          if not Valid(cmClose) then ClearEvent(Event)
        end
        else if Event.Command = cmCloseForm then Free;
      end;
  end;
end;

procedure TForm.Store(var S: TStream);
begin
  TDialog.Store(S);
  S.Write(KeyWidth, SizeOf(KeyWidth));
end;

function TForm.Valid(Command: Word): Boolean;
var
  Action: Word;
begin
  Action := cmYes;                    { assume calling inherited }
  if Command = cmClose then
    if Changed then
    begin
      Select;
      Action := MessageBox(#3'Form data has been modified. Save? ', nil,
        mfYesNoCancel);
      case Action of
        cmYes:
          { Try to save changes. Cancel if save fails }
          if not PListDialog(ListDialog)^.SaveForm(@Self) then
            Action := cmCancel;
        cmNo: ;                                     { abandon changes }
      else
        Action := cmCancel;                          { cancel close request }
      end;
    end
    else Action := cmNo;                             { no changes }
  if Action = cmYes then Valid := TDialog.Valid(Command)
  else Valid := Action <> cmCancel;
end;

end.
