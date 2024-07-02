unit CmdNamer;

interface

{ Registers all the built in Turbo Vision commands with the command
  namer }
procedure BuiltInCommandNames;

{ Returns the name of the given command }
function CommandName(Command: Word): String;

{ Registers the given command with the command namer }
procedure NameCommand(Command: Word; const Name: String);

implementation

uses Strings, Objects, Views, App, Dialogs;

{ Command Database }

type
  PCommandItem = ^TCommandItem;
  TCommandItem = record
    Command: Word;
    Name: PString;
  end;

  TCommandCollection = object(TSortedCollection)
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    procedure FreeItem(P: Pointer); virtual;
    function KeyOf(P: Pointer): Pointer; virtual;
  end;

function TCommandCollection.Compare(Key1, Key2: Pointer): Integer;
begin
  Compare := LongInt(Key1) - LongInt(Key2);
end;

procedure TCommandCollection.FreeItem(P: Pointer);
begin
  DisposeStr(PCommandItem(P)^.Name);
  Dispose(PCommandItem(P));
end; 
 
function TCommandCollection.KeyOf(P: Pointer): Pointer;
begin
  KeyOf := Pointer(PCommandItem(P)^.Command);
end;

var
  CommandDB: TCommandCollection;

{ Default commands }

type
  TDefName = record
    Name: PChar;
    Command: Word;
  end;

const
  DefCommands: array[0..36] of TDefName = (
    (Name: 'cmValid'; Command: cmValid),
    (Name: 'cmQuit'; Command: cmQuit),
    (Name: 'cmError'; Command: cmError),
    (Name: 'cmMenu'; Command: cmMenu),
    (Name: 'cmClose'; Command: cmClose),
    (Name: 'cmZoom'; Command: cmZoom),
    (Name: 'cmResize'; Command: cmResize),
    (Name: 'cmNext'; Command: cmNext),
    (Name: 'cmPrev'; Command: cmPrev),
    (Name: 'cmHelp'; Command: cmHelp),
    (Name: 'cmOK'; Command: cmOK),
    (Name: 'cmCancel'; Command: cmCancel),
    (Name: 'cmYes'; Command: cmYes),
    (Name: 'cmNo'; Command: cmNo),
    (Name: 'cmDefault'; Command: cmDefault),
    (Name: 'cmCut'; Command: cmCut),
    (Name: 'cmCopy'; Command: cmCopy),
    (Name: 'cmPaste'; Command: cmPaste),
    (Name: 'cmUndo'; Command: cmUndo),
    (Name: 'cmClear'; Command: cmClear),
    (Name: 'cmTile'; Command: cmTile),
    (Name: 'cmCascade'; Command: cmCascade),
    (Name: 'cmNew'; Command: cmNew),
    (Name: 'cmOpen'; Command: cmOpen),
    (Name: 'cmSave'; Command: cmSave),
    (Name: 'cmSaveAs'; Command: cmSaveAs),
    (Name: 'cmSaveAll'; Command: cmSaveAll),
    (Name: 'cmChangeDir'; Command: cmChangeDir),
    (Name: 'cmDosShell'; Command: cmDosShell),
    (Name: 'cmCloseAll'; Command: cmCloseAll),
    (Name: 'cmReceivedFocus'; Command: cmReceivedFocus),
    (Name: 'cmReleasedFocus'; Command: cmReleasedFocus),
    (Name: 'cmCommandSetChanged'; Command: cmCommandSetChanged),
    (Name: 'cmScrollBarChanged'; Command: cmScrollBarChanged),
    (Name: 'cmScrollBarClicked'; Command: cmScrollBarClicked),
    (Name: 'cmSelectWindowNum'; Command: cmSelectWindowNum),
    (Name: 'cmListItemSelected'; Command: cmListItemSelected));


procedure BuiltInCommandNames;
var
  I: Integer;
begin
  for I := Low(DefCommands) to High(DefCommands) do
    NameCommand(DefCommands[I].Command, StrPas(DefCommands[I].Name));
end;
    
procedure NameCommand(Command: Word; const Name: String);
var
  P: PCommandItem;
begin
  New(P);
  P^.Command := Command;
  P^.Name := NewStr(Name);
  CommandDB.Insert(P);
end; 

function CommandName(Command: Word): String;
var
  I: Integer;
  S: String;
begin
  if CommandDB.Search(Pointer(Command), I) then
    CommandName := PCommandItem(CommandDB.At(I))^.Name^
  else
  begin
    Str(Command, S);
    CommandName := 'unknown ' + S;
  end;
end;

begin
  CommandDB.Init(High(DefCommands) + 1, 10);
end.