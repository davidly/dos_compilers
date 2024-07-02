
{ Turbo Form }
{ Copyright (c) 1989 by Borland International, Inc. }

program FDemo;
{ Turbo Pascal 5.5 object-oriented example.
  Demonstrates use of the FORMS and SLIDERS units.
  Refer to OOPDEMOS.DOC for an overview of this program.
}

uses Crt, Forms, Sliders;

type

  Person = record
    Firstname: string[30];
    Lastname: string[30];
    Address: string[32];
    City: string[16];
    State: string[2];
    Zipcode: Longint;
    Counter: array[1..3] of Longint;
    Slider: array[1..2] of Integer;
  end;

const

  Frank: Person = (
    Firstname: 'Frank';
    Lastname: 'Borland';
    Address: '1800 Green Hills Road';
    City: 'Scotts Valley';
    State: 'CA';
    Zipcode: 95066;
    Counter: (10, 1000, 65536);
    Slider: (85, 25));

var
  F: Form;
  P: Person;

begin
  Color(BackColor);
  ClrScr;
  Color(ForeColor);
  GotoXY(1, 1); ClrEol;
  Write(' Turbo Pascal 5.5 Object Oriented Forms Editor');
  GotoXY(1, 25); ClrEol;
  Write(' F2-Save  Esc-Quit');
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
  P := Frank;
  F.Put(P);
  F.Show(True);
  if F.Edit = CSave then F.Get(P);
  F.Done;
  NormVideo;
  ClrScr;
  WriteLn('Resulting Person record:');
  WriteLn;
  with P do
  begin
    WriteLn('Firstname: ', Firstname);
    WriteLn(' Lastname: ', Lastname);
    WriteLn('  Address: ', Address);
    WriteLn('     City: ', City);
    WriteLn('    State: ', State);
    WriteLn('  Zipcode: ', Zipcode);
    WriteLn(' Counters: ', Counter[1], ' ', Counter[2], ' ', Counter[3]);
    WriteLn('  Sliders: ', Slider[1], ' ', Slider[2]);
  end;
end.
