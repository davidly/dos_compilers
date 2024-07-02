{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Collect2;

uses Objects;

type
  PClient = ^TClient;
  TClient = object(TObject)
    Account, Name, Phone: PString;
    constructor Init(NewAccount, NewName, NewPhone: String);
    destructor Done; virtual;
    procedure Print; virtual;
  end;

  PClientCollection = ^TClientCollection;
  TClientCollection = object(TSortedCollection)
    function KeyOf(Item: Pointer): Pointer; virtual;
    function Compare(Key1, Key2: Pointer): Integer; virtual;
  end;

{ TClient }
constructor TClient.Init(NewAccount, NewName, NewPhone: String);
begin
  Account := NewStr(NewAccount);
  Name := NewStr(NewName);
  Phone := NewStr(NewPhone);
end;

destructor TClient.Done;
begin
  DisposeStr(Account);
  DisposeStr(Name);
  DisposeStr(Phone);
end;

procedure TClient.Print;
begin
  Writeln('  ',
    Account^, '':10-Length(Account^),
    Name^, '':20-Length(Name^),
    Phone^, '':16-Length(Phone^));
end;

{ TClientCollection }
function TClientCollection.KeyOf(Item: Pointer): Pointer;
begin
  KeyOf := PClient(Item)^.Account;
end;

function TClientCollection.Compare(Key1, Key2: Pointer): Integer;
begin
  if PString(Key1)^ = PString(Key2)^ then
    Compare := 0
  else if PString(Key1)^ < PString(Key2)^ then
    Compare := -1
  else
    Compare := 1;
end;


{ Use ForEach iterator to display client information }

procedure PrintAll(C: PCollection);

procedure CallPrint(P : PClient); far;
begin
  P^.Print;                   { Call Print method }
end;

begin { Print }
  Writeln;
  Writeln;
  Writeln('Client list:');
  C^.ForEach(@CallPrint);     { Print each client }
end;

{ Use FirstThat iterator to search non-key field }

procedure SearchPhone(C: PCollection; PhoneToFind: String);

function PhoneMatch(Client: PClient): Boolean; far;
begin
  PhoneMatch := Pos(PhoneToFind, Client^.Phone^) <> 0;
end;

var
  FoundClient: PClient;

begin { SearchPhone }
  Writeln;
  FoundClient := C^.FirstThat(@PhoneMatch);
  if FoundClient = nil then
    Writeln('No client met the search requirement')
  else
  begin
    Writeln('Found client:');
    FoundClient^.Print;
  end;
end;

var
  ClientList: PClientCollection;

begin
  ClientList := New(PClientCollection, Init(10, 5));

  { Build collection }
  with ClientList^ do
  begin
    Insert(New(PClient, Init('91-100', 'Anders, Smitty', '(406) 111-2222')));
    Insert(New(PClient, Init('90-167', 'Smith, Zelda', '(800) 555-1212')));
    Insert(New(PClient, Init('90-177', 'Smitty, John', '(406) 987-4321')));
    Insert(New(PClient, Init('90-160', 'Johnson, Agatha', '(302) 139-8913')));
  end;

  { Use ForEach iterator to print all }
  PrintAll(ClientList);

  { Use FirstThat iterator to find match with search pattern }
  SearchPhone(ClientList, '(406)');

  { Clean up }
  Dispose(ClientList, Done);
end.
