{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{$V-}

unit Assoc;  { Association list manager }

interface

uses Objects, Dos;

type
  PAssociation = ^TAssociation;
  TAssociation = object(TObject)
    Ext: ExtStr;
    Cmd: PString;
    Prompt: Boolean;
    constructor Init(AExt: ExtStr; const ACmd: String; APrompt: Boolean);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
  end;

procedure InitAssociations;
procedure DoneAssociations;

procedure Associate(DefExt: ExtStr);
function GetAssociatedCommand(Ext: ExtStr): PAssociation;
procedure WriteAssociationList(var S: TStream);
procedure ReadAssociationList(var S: TStream);

procedure RegisterAssociations;

implementation

uses Drivers, Views, Dialogs, App, MsgBox, Validate, Tools;

const
  cmAddAssoc   = 100;
  cmEditAssoc  = cmAddAssoc + 1;
  cmDelAssoc   = cmEditAssoc + 1;

type
  { transfer record for a list box }
  TListBoxRec = record
    List: PCollection;
    Selection: Word;
  end;

  TAssocRec = record
    Extension: ExtStr;
    Command: String;
    Prompt: Word;
  end;

  PAssociateList = ^TAssociateList;
  TAssociateList = object(TCollection)
    procedure FillCloneList(P: PCollection);
    procedure UseCloneList(P: PCollection);
  end;

  PAssocBox = ^TAssocBox;
  TAssocBox = object(TListBox)
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

  PAssocDialog = ^TAssocDialog;
  TAssocDialog = object(TDialog)
    DefExt: ExtStr;
    ListBox: PAssocBox;
    constructor Init(ADefExt: ExtStr);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PExtValidator = ^TExtValidator;
  TExtValidator = object(TValidator)
    function IsValid(const S: string): Boolean; virtual;
    procedure Error; virtual;
  end;

  PNonBlankValidator = ^TNonBlankValidator;
  TNonBlankValidator = object(TPXPictureValidator)
    procedure Error; virtual;
  end;

const
  RAssociation : TStreamRec = (
    ObjType : 1001;
    VmtLink : Ofs(TypeOf(TAssociation)^);
    Load    : @TAssociation.Load;
    Store   : @TAssociation.Store
  );
  RAssociateList : TStreamRec = (
    ObjType : 1002;
    VmtLink : Ofs(TypeOf(TAssociateList)^);
    Load    : @TAssociateList.Load;
    Store   : @TAssociateList.Store
  );

const
  AssociateList: PAssociateList = nil;

{ TAssociateList }
procedure TAssociateList.FillCloneList(P: PCollection);

  procedure AddCloneItem(Item: PAssociation); far;
  begin
    P^.Insert(New(PAssociation, Init(Item^.Ext, Item^.Cmd^, Item^.Prompt)));
  end;

begin
  ForEach(@AddCloneItem);
end;

procedure TAssociateList.UseCloneList(P: PCollection);

  procedure UseCloneItem(Item: PAssociation); far;
  begin
    Insert(New(PAssociation, Init(Item^.Ext, Item^.Cmd^, Item^.Prompt)));
  end;

begin
  FreeAll;
  P^.ForEach(@UseCloneItem);
end;


{ TAssociation }
constructor TAssociation.Init(AExt: ExtStr; const ACmd: String;
  APrompt: Boolean);
begin
  inherited Init;
  Ext := AExt;
  Cmd := NewStr(ACmd);
  Prompt := APrompt;
end;

constructor TAssociation.Load(var S: TStream);
begin
  inherited Init;
  S.Read(Ext, SizeOf(Ext));
  Cmd := S.ReadStr;
  S.Read(Prompt, SizeOf(Prompt));
end;

destructor TAssociation.Done;
begin
  DisposeStr(Cmd);
  inherited Done;
end;

procedure TAssociation.Store(var S: TStream);
begin
  S.Write(Ext, SizeOf(Ext));
  S.WriteStr(Cmd);
  S.Write(Prompt, SizeOf(Prompt));
end;

{ TAssocBox }
function TAssocBox.GetText(Item: Integer; MaxLen: Integer): String;
var
  T: PAssociation;
  Params: array[0..1] of Longint;
  S: String;
begin
  T := List^.At(Item);
  Params[0] := Longint(@T^.Ext);
  Params[1] := Longint(T^.Cmd);
  FormatStr(S, '%-13s %s', Params);
  if Length(S) > MaxLen then
  begin
    S[0] := Char(MaxLen);
    { Fill the last three characters with an ellipses }
    FillChar(S[MaxLen - 4], 3, '.');
  end;
  GetText := S;
end;

function CreateEditDialog: PDialog;
var
  R: TRect;
  D: PDialog;
  P: PView;
begin
  R.Assign(0,0,60,9);
  D := New(PDialog, Init(R, 'Edit Association'));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Assign(17,2,58,3);
    P := New(PInputLine, Init(R, SizeOf(ExtStr) - 1));
    Insert(P);
    PInputLine(P)^.SetValidator(New(PExtValidator, Init));
    P^.Options := P^.Options or ofValidate;
    R.Assign(2,2,17,3);
    Insert(New(PLabel, Init(R, '~E~xtension', P)));

    R.Assign(17,3,58,4);
    P := New(PInputLine, Init(R, SizeOf(String) - 1));
    PInputLine(P)^.SetValidator(New(PNonBlankValidator, Init('@*[@]',False)));
    P^.Options := P^.Options or ofValidate;
    Insert(P);

    R.Assign(2,3,17,4);
    Insert(New(PLabel, Init(R, 'Co~m~mmand', P)));

    R.Assign(17,4,58,5);
    Insert(New(PCheckBoxes, Init(R, NewSItem('~P~rompt for parameters',
      nil))));

    R.Assign(2,6,12,8);
    Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
    R.Move(12,0);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  CreateEditDialog := D;
end;

function AddAssociation(var ListBoxRec: TListBoxRec; DefExt: ExtStr): Word;
var
  D: PDialog;
  XFer: TAssocRec;
  Result: Word;
begin
  XFer.Extension := DefExt;
  XFer.Command := '';
  D := CreateEditDialog;
  Result := Application^.ExecuteDialog(D, @XFer);
  if Result = cmOK then with XFer do
  begin
    UpperCase(Extension);
    ListBoxRec.List^.Insert(New(PAssociation, Init(Extension, Command,
      Prompt > 0)));
  end;
  AddAssociation := Result;
end;

function EditAssociation(var ListBoxRec: TListBoxRec): Word;
var
  D: PDialog;
  XFer: TAssocRec;
  Assoc: PAssociation;
  Result: Integer;
begin
  Result := cmCancel;
  if ListBoxRec.List^.Count = 0 then Exit;
  Assoc := ListBoxRec.List^.At(ListBoxRec.Selection);
  XFer.Extension := Assoc^.Ext;
  XFer.Command := Assoc^.Cmd^;
  if Assoc^.Prompt then XFer.Prompt := 1
  else XFer.Prompt := 0;
  D := CreateEditDialog;
  Result := Application^.ExecuteDialog(D, @XFer);
  if Result = cmOK then
  begin
    UpperCase(XFer.Extension);
    Assoc^.Ext := XFer.Extension;
    DisposeStr(Assoc^.Cmd);
    Assoc^.Cmd := NewStr(XFer.Command);
    Assoc^.Prompt := XFer.Prompt > 0;
  end;
  EditAssociation := Result;
end;

function DeleteAssociation(var ListBoxRec: TListBoxRec): Word;
var
  Assoc: PAssociation;
  Result: Integer;
  P: PString;
begin
  Result := cmCancel;
  if ListBoxRec.List^.Count = 0 then Exit;
  Assoc := ListBoxRec.List^.At(ListBoxRec.Selection);
  P := @Assoc^.Ext;
  Result := MessageBox('Delete association for %s?', @P,
    mfConfirmation + mfOKButton + mfCancelButton);
  if Result = cmOK then
    ListBoxRec.List^.AtFree(ListBoxRec.Selection);
  DeleteAssociation := Result;
end;

{ TAssocDialog }
constructor TAssocDialog.Init(ADefExt: ExtStr);
var
  R: TRect;
  SB: PScrollBar;
begin
  R.Assign(0,0,65,15);
  inherited Init(R, 'File Associations');
  DefExt := ADefExt;
  Options := Options or ofCentered;

  R.Assign(62,3,63,11);
  SB := New(PScrollBar, Init(R));
  Insert(SB);
  R.Assign(2,3,62,11);
  ListBox := New(PAssocBox, Init(R, 1, SB));
  Insert(ListBox);
  R.Assign(2,2,32,3);
  Insert(New(PStaticText, Init(R, 'Extension      Command line')));

  R.Assign(2,12,12,14);
  Insert(New(PButton, Init(R, '~A~dd', cmAddAssoc, bfNormal)));
  R.Move(11, 0);
  Insert(New(PButton, Init(R, '~E~dit', cmEditAssoc, bfNormal)));
  R.Move(11, 0);
  Insert(New(PButton, Init(R, '~D~elete', cmDelAssoc, bfNormal)));

  R.Move(16, 0);
  Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));
  R.Move(11, 0);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));
  SelectNext(False);
end;

procedure TAssocDialog.HandleEvent(var Event: TEvent);
var
  ListBoxRec: TListBoxRec;
begin
  if ListBox^.List^.Count = 0 then
    DisableCommands([cmEditAssoc,cmDelAssoc])
  else
    EnableCommands([cmEditAssoc,cmDelAssoc]);

  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    ListBoxRec.List := ListBox^.List;
    ListBoxRec.Selection := ListBox^.Focused;
    case Event.Command of
      cmAddAssoc :
        if AddAssociation(ListBoxRec, DefExt) <> cmOK then Exit;
      cmEditAssoc :
        if EditAssociation(ListBoxRec) <> cmOK then Exit;
      cmDelAssoc :
        if DeleteAssociation(ListBoxRec) <> cmOK then Exit;
    end;
    ListBox^.SetRange(ListBox^.List^.Count);
    ListBox^.DrawView;
    ClearEvent(Event);
  end;
end;

{ TExtValidator }
function TExtValidator.IsValid(const S: string): Boolean;
begin
  IsValid := False;
  IsValid := (Length(S) > 0) and (S[1] = '.');
end;

procedure TExtValidator.Error;
begin
  MessageBox('Enter an valid file extension in the form ".xxx"', nil,
    mfInformation + mfOKButton);
end;

{ TNonBlankValidator }
procedure TNonBlankValidator.Error;
begin
  MessageBox('Field can not be blank.', nil,
    mfInformation + mfOKButton);
end;


procedure InitAssociations;
begin
  AssociateList := New(PAssociateList, Init(10, 5));
end;

procedure DoneAssociations;
begin
  if AssociateList <> nil then Dispose(AssociateList, Done);
end;

procedure Associate(DefExt: ExtStr);
var
  D: PDialog;
  XFer: TListBoxRec;
  Result: Word;
begin
  if AssociateList = nil then Exit;

  XFer.List := New(PAssociateList, Init(20,5));
  AssociateList^.FillCloneList(XFer.List);
  XFer.Selection := 0;

  D := New(PAssocDialog, Init(DefExt));
  if Application^.ExecuteDialog(D, @XFer) = cmOK then
    AssociateList^.UseCloneList(XFer.List);
  Dispose(XFer.List, Done);
end;

function GetAssociatedCommand(Ext: ExtStr): PAssociation;
var
  Association: PAssociation;

  function MatchExtension(P: PAssociation): Boolean; far;
  begin
    MatchExtension := (P^.Ext = Ext) or ((P^.Ext = '.') and (Ext = ''));
  end;

begin
  GetAssociatedCommand := nil;
  if AssociateList = nil then Exit;
  Association := AssociateList^.FirstThat(@MatchExtension);
  GetAssociatedCommand := Association;
end;

procedure WriteAssociationList(var S: TStream);
begin
  if AssociateList = nil then Exit;
  AssociateList^.Store(S);
end;

procedure ReadAssociationList(var S: TStream);
begin
  if AssociateList <> nil then
    Dispose(AssociateList, Done);
  AssociateList := New(PAssociateList, Load(S));
end;

procedure RegisterAssociations;
begin
  RegisterType(RAssociation);
  RegisterType(RAssociateList);
end;

end.