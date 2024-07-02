{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

unit ListDlg;

{$F+,O+,X+,S-,D+}

interface

uses
  Dos, Objects, Memory, Drivers, Views, Dialogs, Stddlg,
  DataColl, FormCmds;

type
  PListKeyBox = ^TListKeyBox;
  TListKeyBox = object(TSortedListBox)
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

  PListDialog = ^TListDialog;
  TListDialog = object(TDialog)
    DataCollection: PDataCollection;
    FileName: PString;
    FormDataFile: PResourceFile;
    IsValid: Boolean;
    List: PListKeyBox;
    Modified: Boolean;
    constructor Init(RezName: PathStr);
    destructor Done; virtual;
    procedure Close; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function OpenDataFile(Name: PathStr;
      var DataFile: PResourceFile; Mode: Word): Boolean;
    function SaveList: Boolean;
    function SaveForm(F: PDialog): Boolean;
    procedure StackOnPrev(F: PDialog);
    function Valid(Command: Word): Boolean; virtual;
  end;

function FileExists(Name: PathStr): Boolean;

implementation

uses App, Forms, MsgBox;

function FileExists(Name: PathStr): Boolean;
var
  SR: SearchRec;
begin
  FindFirst(Name, 0, SR);
  FileExists := DosError = 0;
end;

{ TListKeyBox }
function TListKeyBox.GetText(Item: Integer; MaxLen: Integer): String;
var
  S: String;
begin
  with PDataCollection(List)^ do
  begin
    case KeyType of
      StringKey: GetText := TSortedListBox.GetText(Item, MaxLen);
      LongIntKey:
        begin
          Str(LongInt(KeyOf(At(Item))^):MaxLen - 3, S);
          GetText := Copy(S, 1, MaxLen);
        end;
    end;
  end;
end;

{ TListDialog }
constructor TListDialog.Init(RezName: PathStr);
const
  ButtonCt = 4;
  FormX = 2;
  FormY = 2;
  FormWd = 30;
  FormHt = 13;
  ListX = 2;
  ListY = 3;
  DefaultListWd = 12;
  ListHt = ButtonCt * 2;
  ButtonWd = 12;
  ButtonY = ListY;

var
  R: TRect;
  SB: PScrollBar;
  Y: Integer;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  F: PForm;
  ListWd: Word;
  ButtonX: Word;
begin
  FSplit(FExpand(RezName), D, N, E);
  R.Assign(FormX, FormY, FormX + FormWd, FormY + FormHt);
  TDialog.Init(R, N);

  FileName := NewStr(D + N + E);
  { Read data off resource stream }
  if OpenDataFile(FileName^, FormDataFile, stOpen) then
  begin
    { Get horizontal size of key field }
    F := PForm(FormDataFile^.Get('FormDialog'));
    if F = nil then
    begin
      MessageBox('Error accessing file data.', nil, mfError or mfOkButton);
      Exit;
    end;

    { Base listbox width on key width. Grow entire dialog if required }
    if F^.KeyWidth > DefaultListWd then
    begin
      ListWd := F^.KeyWidth;
      GrowTo(FormWd + ListWd - DefaultListWd, FormHt);
    end
    else ListWd := DefaultListWd;

    { Move to upper right corner of desktop }
    Desktop^.GetExtent(R);                    { Desktop coordinates }
    MoveTo(R.B.X - Size.X, 1);

    Dispose(F, Done);

    { Read data collection into memory }
    DataCollection := PDataCollection(FormDataFile^.Get('FormData'));
    if DataCollection <> nil then
    begin
      { Loaded successfully: build ListDialog dialog }

      { Scrollbar }
      R.Assign(ListX + ListWd, ListY, ListX + ListWd + 1, ListY + ListHt);
      SB := New(PScrollBar, Init(R));
      Insert(SB);

      { List box }
      R.Assign(ListX, ListY, ListX + ListWd, ListY + ListHt);
      List := New(PListKeyBox, Init(R, 1, SB));
      List^.NewList(DataCollection);
      Insert(List);

      { Label }
      R.Assign(ListX, ListY - 1, ListX + 10, ListY);
      Insert(New(PLabel, Init(R, '~K~eys', List)));

      { Buttons }
      ButtonX := ListX + ListWd + 2;
      Y := ButtonY;
      R.Assign(ButtonX, Y, ButtonX + ButtonWd, Y + 2);
      Insert(New(PButton, Init(R, '~E~dit', cmFormEdit, bfDefault)));

      Inc(Y, 2);
      R.Assign(ButtonX, Y, ButtonX + ButtonWd, Y + 2);
      Insert(New(PButton, Init(R, '~N~ew', cmFormNew, bfNormal)));

      Inc(Y, 2);
      R.Assign(ButtonX, Y, ButtonX + ButtonWd, Y + 2);
      Insert(New(PButton, Init(R, '~D~elete', cmFormDel, bfNormal)));

      Inc(Y, 2);
      R.Assign(ButtonX, Y, ButtonX + ButtonWd, Y + 2);
      Insert(New(PButton, Init(R, '~S~ave', cmListSave, bfNormal)));

      SelectNext(False);      { Select first field }
      IsValid := True;
    end;
  end;
end;

destructor TListDialog.Done;
begin
  if List <> nil then Dispose(List, Done);
  if DataCollection <> nil then Dispose(DataCollection, Done);
  if FormDataFile <> nil then Dispose(FormDataFile, Done);
  if FileName <> nil then DisposeStr(FileName);
  TDialog.Done;
end;

procedure TListDialog.Close;
begin
  { TDialog.Close calls Valid and then Free. Before calling
    Free (which calls Done), tell all attached forms to close.
  }
  if Valid(cmClose) then
  begin
    { Stop desktop video update in case there are scores of attached forms }
    Desktop^.Lock;
    Message(Desktop, evBroadcast, cmCloseForm, @Self);
    Desktop^.Unlock;
    Free;
  end;
end;

procedure TListDialog.HandleEvent(var Event: TEvent);

function EditingForm: PForm;
{ Return pointer to the form that is editing the current selection }
begin
  EditingForm := Message(Desktop, evBroadcast,
    cmEditingForm, DataCollection^.At(List^.Focused));
end;

procedure FormOpen(NewForm: Boolean);
var
  F: PForm;
begin
  if not NewForm then
  begin
    { Empty collection? }
    if DataCollection^.Count = 0 then Exit;

    { If selection is being edited, then bring its form to top }
    F := EditingForm;
    if F <> nil then
    begin
      F^.Select;
      Exit;
    end;
  end;

  { Selection is not being edited: open new form from the resource file }
  F := PForm(FormDataFile^.Get('FormDialog'));
  if F = nil then
    MessageBox('Error opening form.', nil, mfError or mfOkButton)
  else
  begin
    with F^ do
    begin
      ListDialog := @Self;                 { Form points back to List }
      if NewForm then
        PrevData := nil                    { Adding new form }
      else
      begin
        { Edit data from collection }
        PrevData := DataCollection^.At(List^.Focused);
        SetData(PrevData^);
      end;
    end;
    if Application^.ValidView(F) <> nil then
    begin
      StackOnPrev(F);
      if NewForm then Desktop^.Insert(F)      { Insert & select }
      else Desktop^.InsertBefore(F, Next);    { Insert but keep focus }
    end;
  end;
end;

procedure DeleteSelection;
var
  F: PForm;
begin
  { Empty collection? }
  if DataCollection^.Count = 0 then Exit;

  { Don't allow delete of data already being edited }
  F := EditingForm;
  if F <> nil then
  begin
    F^.Select;
    MessageBox('Data is already being edited. Close form before deleting.',
      nil, mfWarning or mfOkButton);
    Exit;
  end;

  { Confirm delete }
  if MessageBox('Are you sure you want to delete this item?', nil,
    mfWarning or mfYesNoCancel) = cmYes then
    begin
      DataCollection^.AtFree(List^.Focused);
      List^.SetRange(DataCollection^.Count);
      List^.DrawView;
      Modified := True;
    end;
end;

begin
  with Event do
    if (What = evKeyDown) and (KeyCode = kbEsc) then
    begin
      What := Command;
      Command := cmClose;
    end;

  TDialog.HandleEvent(Event);

  case Event.What of
    evCommand:
      begin
        case Event.Command of
          cmFormEdit: FormOpen(False);
          cmFormNew: FormOpen(True);
          cmFormDel: DeleteSelection;
          cmListSave: if Modified then SaveList;
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
    evKeyDown:
      begin
        case Event.KeyCode of
          kbIns: FormOpen(True);
        else
          Exit;
        end;
        ClearEvent(Event);
      end;
    evBroadcast:
      begin
        case Event.Command of
          { Respond to broadcast from TSortedListBox }
          cmListItemSelected: FormOpen(False);
  
          { Keep file from being edited simultaneously by 2 lists }
          cmEditingFile: if FileName^ = PString(Event.InfoPtr)^ then
            ClearEvent(Event);

          { Respond to search for topmost list dialog }
          cmTopList: ClearEvent(Event);
        end;
      end;
  end;
end;

function TListDialog.OpenDataFile(Name: PathStr;
  var DataFile: PResourceFile; Mode: Word): Boolean;
var
  S: PStream;
begin
  S := New(PBufStream, Init(Name, Mode, 1024));
  DataFile := New(PResourceFile, Init(S));
  if S^.Status <> stOk then
  begin
    Dispose(DataFile, Done);
    DataFile := nil;
    OpenDataFile := False;
  end
  else OpenDataFile := True;
end;

function TListDialog.SaveList: Boolean;
var
  S: PStream;
  NewDataFile: PResourceFile;
  Form: PForm;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  F: File;
begin
  { Empty collection? Unedited? }
  if (DataCollection^.Count = 0) or not Modified then
  begin
    SaveList := True;
    Exit;
  end;

  SaveList := False;
  { Read form definition out of original form file }
  Form := PForm(FormDataFile^.Get('FormDialog'));
  if Form = nil then
    MessageBox('Cannot find original file. Data not saved.',
      nil, mfError or mfOkButton)
  else
  begin
    { Create new data file }
    FSplit(FileName^, D, N, E);
    if not OpenDataFile(D + N + '.$$$', NewDataFile, stCreate) then
      MessageBox('Cannot create file. Data not saved.',
        nil, mfError or mfOkButton)
    else
    begin
      { Create new from form and collection in memory }
      NewDataFile^.Put(Form, 'FormDialog');
      NewDataFile^.Put(DataCollection, 'FormData');
      NewDataFile^.Flush;
      Dispose(NewDataFile, Done);

      { Close original file, rename to .BAK }
      Dispose(FormDataFile, Done);
      FormDataFile := nil;
      {$I-}
      if FileExists(D + N + '.BAK') then
      begin
        Assign(F, D + N + '.BAK');
        Erase(F);
      end;
      Assign(F, FileName^);
      Rename(F, D + N + '.BAK');
      {$I+}

      { Error trying to erase old .BAK or rename original to .BAK? }
      if IOResult <> 0 then
      begin
        MessageBox('Cannot create .BAK file. Data not saved.',
          nil, mfError or mfOkButton);

        { Try to re-open original. New data will still be in memory }
        if not OpenDataFile(FileName^, FormDataFile, stOpen) then
        begin
          MessageBox('Cannot re-open original file.',
            nil, mfError or mfOkButton);
          Free;        { Cannot proceed. Free data and close window }
        end;
      end
      else
      begin
        { Rename temp file to original file and re-open }
        Assign(F, D + N + '.$$$');
        Rename(F, FileName^);
        OpenDataFile(FileName^, FormDataFile, stOpen);

        Modified := False;
        SaveList := True;
      end;
    end;
    Dispose(Form, Done);
  end;
end;

function TListDialog.SaveForm(F: PDialog): Boolean;
var
  i: Integer;
  P: Pointer;
begin
  SaveForm := False;
  with PForm(F)^, DataCollection^ do
  begin
    { Validate data before updating collection }
    if not F^.Valid(cmFormSave) then Exit;

    { Extract data from form. Don't use safety pool. }
    P := MemAlloc(ItemSize);
    if P = nil then
    begin
      Application^.OutOfMemory;
      Exit;
    end;

    GetData(P^);
    { If no duplicates, make sure not attempting to add duplicate key }
    if not Duplicates and Search(KeyOf(P), i) then
      if (PrevData = nil) or (PrevData <> At(i)) then
    begin
      FreeMem(P, ItemSize);
      MessageBox('Duplicate keys are not allowed in this database.'+
        '  Delete duplicate record before saving this form.', nil,
        mfError or mfOkButton);
      Exit;
    end;

    { Free previous data? }
    if (PrevData <> nil) then Free(PrevData);

    { TDataCollection.Insert may fail because it doesn't use
      the safety pool. Check status field after insert and cleanup
      if necessary.
    }
    Insert(P);
    if Status <> 0 then
    begin
      FreeMem(P, ItemSize);
      Application^.OutOfMemory;
      Exit;
    end;

    { Success: store off original data pointer }
    PrevData := P;

    { Redraw list }
    List^.SetRange(Count);
    List^.DrawView;

    Modified := True;
    SaveForm := True;
  end;
end;

procedure TListDialog.StackOnPrev(F: PDialog);
var
  TopForm: PForm;
  R: TRect;
begin
  { Stack on top topmost form or on top list if first form }
  TopForm := Message(Owner, evBroadcast, cmTopForm, @Self);
  if (TopForm <> nil) then
    { Stack on top previous topmost form }
    with TopForm^.Origin do
      F^.MoveTo(X + 1, Y + 1)
  else
  begin
    { Stack right or left of ListDialog }
    if Origin.X > F^.Size.X then F^.Moveto(0, Origin.Y)
    else F^.Moveto(Origin.X + Size.X + 1, Origin.Y);
  end;

  { Visible on desktop? Make sure at least half of form is visible }
  Owner^.GetExtent(R);                      { Desktop coordinates }
  with F^, F^.Origin do                     { Keep stack on screen }
  begin
    if (X + Size.X div 2 > R.B.X) then F^.MoveTo(0, 1);
     if (Y + Size.Y div 2 > R.B.Y) then F^.MoveTo(X, 1);
  end;
end;

function TListDialog.Valid(Command: Word): Boolean;
var
  Ok: Boolean;
  Reply: Word;
begin
  Ok := True;
  case Command of
    cmValid:
      begin
        Ok := IsValid;
        if not Ok then
          MessageBox('Error opening file (%S).',
            @FileName, mfError or mfOkButton);
      end;
    cmQuit, cmClose:
      begin
        { Any forms open that cannot close? }
        Ok := Message(Desktop, evBroadcast, cmCanCloseForm, @Self) = nil;

        { Any data modified? }
        if Ok and Modified then
        begin
          Select;
          Reply := MessageBox('Database has been modified. Save? ', nil,
            mfYesNoCancel);
          case Reply of
            cmYes: Ok := SaveList;
            cmNo: Modified := False;                { abandon changes }
          else
            Ok := False;                            { cancel close request }
          end;
        end;
      end;
  end;
  if Ok then Valid := TDialog.Valid(Command)
  else Valid := False;
end;

end.
