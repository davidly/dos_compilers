
{ Turbo Generator }
{ Copyright (c) 1989 by Borland International, Inc. }

program CardGen;
{ Turbo Pascal 5.5 object-oriented example.
  Generates example OOP databases for CARDFILE.PAS.
  Refer to OOPDEMOS.DOC for an overview of this program.
}

{$S-}
{$M 8192, 16384, 16384}

uses Crt, Objects, Forms, Sliders, Cards;

const
  Signature: Longint = $44524143;    { unique signature for file }

var
  F: Form;
  C: CardList;
  S: FStream;

procedure PeopleForm;
{ Create an example form in memory with "People" info }
begin
  F.Init(10, 5, 54, 16);
  F.Add(New(FStrPtr, Init(3, 2, ' Firstname ', 30)));
  F.Add(New(FStrPtr, Init(3, 3, ' Lastname  ', 30)));
  F.Add(New(FStrPtr, Init(3, 5, ' Address ', 32)));
  F.Add(New(FStrPtr, Init(3, 6, ' City ', 16)));
  F.Add(New(FStrPtr, Init(25, 6, ' State ', 2)));
  F.Add(New(FZipPtr, Init(34, 6, ' Zip ')));
  F.Add(New(FIntPtr, Init(3, 8, ' Counter 1 ', 0, 99999999)));
  F.Add(New(FIntPtr, Init(22, 8, ' 2 ', 0, 99999999)));
  F.Add(New(FIntPtr, Init(33, 8, ' 3 ', 0, 99999999)));
  F.Add(New(FSliderPtr, Init(3, 10, ' Slider One ', 0, 100, 5)));
  F.Add(New(FSliderPtr, Init(3, 11, ' Slider Two ', 0, 100, 5)));
end;

procedure PartsForm;
{ Create an example form in memory with "Parts" info }
begin
  F.Init(12, 7, 68, 14);
  F.Add(New(FStrPtr, Init(3, 2, ' Part Code ', 10)));
  F.Add(New(FRealPtr, Init(24, 2, ' Cost ', 9, 2)));
  F.Add(New(FRealPtr, Init(39, 2, ' Retail ', 9, 2)));
  F.Add(New(FStrPtr, Init(3, 4, ' Description ', 40)));
  F.Add(New(FStrPtr, Init(3, 5, ' Description ', 40)));
  F.Add(New(FIntPtr, Init(3, 7, ' Units On Hand ', 0, 999999)));
  F.Add(New(FIntPtr, Init(24, 7, ' Backorder ', 0, 999999)));
  F.Add(New(FIntPtr, Init(41, 7, ' Shipped ', 0, 999999)));
end;

procedure MakeFile(FileName: FNameStr);
{ Use a stream to create a cardfile with a form and no data }
begin
  C.Init(F.Size);
  S.Init(FileName, SCreate, 1024);
  S.Write(Signature, SizeOf(Longint));
  F.Store(S);
  C.Store(S);
  S.Flush;
  if S.Status <> 0 then WriteLn('Error creating file ', FileName);
  S.Done;
  C.Done;
  F.Done;
end;

begin
  PeopleForm;
  MakeFile('PEOPLE.DTA');
  PartsForm;
  MakeFile('PARTS.DTA');
end.
