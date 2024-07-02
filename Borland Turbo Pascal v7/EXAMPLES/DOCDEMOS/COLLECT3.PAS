{************************************************}
{                                                }
{   Turbo Vision 2.0 Demo                        }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

{ Read a file and add each unique word to a sorted
  string collection. Use the ForEach iterator method
  to traverse the colection and print out each word.
}

program Collect3;

uses Objects, Memory;

const
  FileToRead = 'COLLECT3.PAS';

{ ********************************** }
{ ***********  Iterator  *********** }
{ ********************************** }

{ Given the entire collection, use the ForEach
  iterator to traverse and print all the words. }

procedure Print(C: PCollection);

{ Must be a local, far procedure. Receives one collection
  element at a time--a pointer to a string--to print. }

procedure PrintWord(P : PString); far;
begin
  Writeln(P^);
end;

begin { Print }
  Writeln;
  Writeln;
  C^.ForEach(@PrintWord);                 { Call PrintWord }
end;

{ ********************************** }
{ **********    Globals    ********* }
{ ********************************** }

{ Abort the program and give a message }

procedure Abort(Msg: String);
begin
  Writeln;
  Writeln(Msg);
  Writeln('Program aborting');
  Halt(1);
end;

{ Given an open text file, read it and return the next word }

function GetWord(var F : Text) : String;
var
  S : String;
  C : Char;
begin
  S := '';
  C := #0;
  while not Eof(F) and not (UpCase(C) in ['A'..'Z']) do
    Read(F, C);
  if Eof(F) and (UpCase(C) in ['A'..'Z']) then
    S := C
  else
    while (UpCase(C) in ['A'..'Z']) and not Eof(F) do
    begin
      S := S + C;
      Read(F, C);
    end;
  GetWord := S;
end;

{ ********************************** }
{ **********  Main Program ********* }
{ ********************************** }

var
  WordList: PCollection;
  WordFile: Text;
  WordFileName: string[80];
  WordRead: String;
begin
  { Initialize collection to hold 10 elements first, then grow by 5's }
  WordList := New(PStringCollection, Init(10, 5));
  if LowMemory then Abort('Out of memory');

  { Open file of words }
  if ParamCount = 1 then
    WordFileName := ParamStr(1)
  else
    WordFileName := FileToRead;
  Assign(WordFile, WordFileName);
  {$I-}
  Reset(WordFile);
  {$I+}
  if IOResult <> 0 then
    Abort('Cannot find file "' + WordFileName + '"');

  { Read each word into the collection }
  repeat
    WordRead := GetWord(WordFile);
    if WordRead <> '' then
      WordList^.Insert(NewStr(WordRead));
    if LowMemory then Abort('Out of memory');
  until WordRead = '';
  Close(WordFile);

  { Display collection contents }
  Print(WordList);

  { Delete collection }
  Dispose(WordList, Done);
end.
