{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit FileFind;

interface

procedure BeginSearch;

implementation

uses Drivers, Objects, Views, Dialogs, App, Dos, Equ, Globals, DragDrop,
  MsgBox;

type
  TMaskStr = string[12];

  TSearchCriteria = record
    Mask: TMaskStr;         { mask to match against }
    StartDir: PathStr;
  end;

  PStackEntry = ^TStackEntry;
  TStackEntry = record
    Search: SearchRec;
    Dir: PString;
    Prev: PStackEntry;
    First: Boolean;
    DoneWithFiles: Boolean;
  end;

  TCountRec = record
    FileCount: Longint;
    DirCount: Longint;
  end;

  PFilesBox = ^TFilesBox;
  TFilesBox = object(TListBox)
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

  PSearchDialog = ^TSearchDialog;
  TSearchDialog = object(TDialog)
    Mask: TMaskStr;
    Count: TCountRec;
    Stack: PStackEntry;
    Button: PButton;
    Params: PParamText;
    FilesBox: PFilesBox;
    constructor Init(var Criteria: TSearchCriteria);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetNextFile: PathStr;
    procedure DisposeStack;
    procedure ChangeButton;
  end;

{ TFilesBox }
function TFilesBox.GetText(Item: Integer; MaxLen: Integer): String;
begin
  if Item < List^.Count then GetText := PString(List^.At(Item))^
  else GetText := '';
end;

{ TSearchDialog }
constructor TSearchDialog.Init(var Criteria: TSearchCriteria);
var
  R: TRect;
  P: PView;
  vSB, hSB: PScrollBar;
  Static: String;
  TextData: array[0..1] of Pointer;
begin
  R.Assign(0,0,60,18);
  inherited Init(R, 'File Search');
  Options := Options or ofCentered;

  TextData[0] := @Criteria.Mask;
  TextData[1] := @Criteria.StartDir;
  FormatStr(Static,
    'Search Mask         : %s'#13'Starting from       : %s', TextData);
  R.Assign(2,2,58,4);
  P := New(PStaticText, Init(R, Static));
  Insert(P);

  R.Assign(2,4,30,6);
  Params := New(PParamText, Init(R,
    'Files found         : %d'#13'Directories searched: %d', 2));
  Insert(Params);
  Params^.SetData(Count);

  R.Assign(57,8,58,14);
  vSB := New(PScrollBar, Init(R));
  Insert(vSB);

  R.Assign(2,8,57,14);
  FilesBox := New(PFilesBox, Init(R, 1, vSB));
  FilesBox^.NewList(New(PTextCollection, Init(20,5)));
  Insert(FilesBox);
  R.Assign(2,7,20,8);
  Insert(New(PLabel, Init(R, '~F~iles list', FilesBox)));

  R.Assign(0,15,10,17);
  Button := New(PButton, Init(R, '~C~ancel', cmStopSearch,
    bfDefault));
  Button^.Options := Button^.Options or ofCenterX;
  Insert(Button);

  Mask := Criteria.Mask;

  { initialize the first entry on the stack }
  New(Stack);
  with Criteria do
    if StartDir[Length(StartDir)] = '\' then Dec(StartDir[0]);
  Stack^.Dir := NewStr(Criteria.StartDir);
  Stack^.Prev := nil;
  Stack^.First := True;
  Stack^.DoneWithFiles := False;
end;

procedure TSearchDialog.DisposeStack;
var
  SE: PStackEntry;
begin
  if Stack <> nil then
  repeat
    SE := Stack^.Prev;
    DisposeStr(Stack^.Dir);
    Dispose(Stack);
    Stack := SE;
  until Stack = nil;
end;

destructor TSearchDialog.Done;
begin
  DisposeStack;
  FilesBox^.NewList(nil);
  inherited Done;
end;

function TSearchDialog.GetNextFile: PathStr;
begin
  with Stack^ do
  begin
    if First then
    begin
      First := False;
      FindFirst(Dir^ + '\' + Mask, AnyFile, Search);
    end
    else
      FindNext(Search);
    if DosError = 0 then GetNextFile := Search.Name
    else GetNextFile := '';
  end;
end;

procedure TSearchDialog.HandleEvent(var Event: TEvent);
var
  NextItem: PathStr;
  PopStack: Boolean;
  SE: PStackEntry;
  FileName: FNameStr;
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmStopSearch) then
  begin
    DisposeStack;
    ChangeButton;
    ClearEvent(Event);
  end;
  if (Event.What = evBroadcast) and (Event.Command = cmClose) then
  begin
    Event.What := evCommand;
    Event.InfoPtr := @Self;
    PutEvent(Event);
    ClearEvent(Event);
  end;
  if (Event.What = evIdle) and (Stack <> nil) then
  begin
    PopStack := False;
    if Stack^.DoneWithFiles then
    begin
      if Stack^.First then
      begin
        Stack^.First := False;
        FindFirst(Stack^.Dir^ + '\*.', Directory, Stack^.Search);
        while (DosError = 0) and (Stack^.Search.Name[1] = '.') do
          FindNext(Stack^.Search);
      end
      else
        FindNext(Stack^.Search);
      if DosError <> 0 then PopStack := True
      else
      begin   { make a new stack entry }
        New(SE);
        SE^.Prev := Stack;
        SE^.First := True;
        SE^.Dir := NewStr(Stack^.Dir^ + '\' + Stack^.Search.Name);
        SE^.DoneWithFiles := False;
        Stack := SE;
      end;
    end
    else  { not DoneWithFiles }
    begin
      NextItem := GetNextFile;
      if NextItem <> '' then
      begin
        FileName := Stack^.Dir^ + '\' + NextItem;
        FilesBox^.List^.Insert( NewStr(FileName) );
        FilesBox^.SetRange(FilesBox^.List^.Count);
        FilesBox^.FocusItem(FilesBox^.List^.Count);
        Inc(Count.FileCount);
        Params^.SetData(Count);
      end
      else
      begin
        Stack^.DoneWithFiles := True;
        Stack^.First := True;
      end;
    end;
    if PopStack then
    begin
      SE := Stack^.Prev;
      DisposeStr(Stack^.Dir);
      Dispose(Stack);
      Inc(Count.DirCount);
      Params^.SetData(Count);
      Stack := SE;
      if Stack = nil then ChangeButton;  { done searching }
    end;
  end;
end;

procedure TSearchDialog.ChangeButton;
var
  R: TRect;
begin
  R.Assign(0,Button^.Origin.Y,11,Button^.Origin.Y + 2);
  Dispose(Button, Done);
  Button := New(PButton, Init(R, '~C~lose', cmClose, bfBroadcast));
  Button^.Options := Button^.Options or ofCenterX;
  Insert(Button);
end;


procedure BeginSearch;
var
  D: PDialog;
  XFer: TSearchCriteria;
begin
  D := PDialog(RezFile.Get('SearchDialog'));
  XFer.Mask := '*.*';
  GetDir(0, XFer.StartDir);
  if Application^.ExecuteDialog(D, @XFer) = cmOK then
  begin
    XFer.StartDir := FExpand(XFer.StartDir);
    D := New(PSearchDialog, Init(XFer));
    Desktop^.Insert(D);
  end;
end;

end.

