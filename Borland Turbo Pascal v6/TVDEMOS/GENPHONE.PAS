{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

{$S-,D-}

{ Run GENFORMS.BAT to generate data files for TVFORMS.PAS
  (this unit is used in GENFORM.PAS).
}
unit GenPhone;

interface

uses Forms, DataColl;

const
  RezFileName = 'PHONENUM.TVF';
  NameWidth = 25;
  CompanyWidth = 22;
  RemarksWidth = 22;
  PhoneWidth = 20;

type
  TDataRec = record
    Name: string[NameWidth];
    Company: string[CompanyWidth];
    Remarks: string[RemarksWidth];
    Phone: string[PhoneWidth];
    AcquaintType: Word;
    Gender: Word;
  end;

const
  AllowDuplicates = True;
  DataKeyType: KeyTypes = StringKey;
  DataCount = 4;
  Male      = 0;
  Female    = 1;
  Business  = $1;
  Personal  = $2;
  Data: array[1..DataCount] of TDataRec =
    ((Name: 'Helton, Andrew'; Company: 'Asterisk International'; Remarks: 'Purch. Mgr.'; Phone: '(415) 868-3964';
       AcquaintType: Business or Personal; Gender: Male),
     (Name: 'White, Natalie'; Company: 'Exclamation, Inc.'; Remarks: 'VP sales'; Phone: '(408) 242-2030';
       AcquaintType: Business; Gender: Female),
     (Name: 'Stern, Peter';  Company: ''; Remarks: 'Decent violinist'; Phone: '(111) 222-5555';
       AcquaintType: Personal; Gender: Male),
     (Name: 'Whitcom, Hana O.'; Company: 'Nate''s girlfriend'; Remarks: 'Birthday: Jan 8, 1990'; Phone: '(408) 426-1234';
       AcquaintType: Personal; Gender: Female)
    );

function MakeForm: PForm;

implementation

uses Objects, Drivers, Views, Dialogs, FormCmds, Fields;

function MakeForm: PForm;
const
  FormX1 = 5;
  FormY1 = 3;
  FormWd = 41;
  FormHt = 17;
  LabelCol = 1;
  LabelWid = 8;
  InputCol = 11;
  ButtonWd = 12;

var
  F: PForm;
  R: TRect;
  X, Y: Integer;
  Control: PView;
begin
  { Create a form }
  R.Assign(FormX1, FormY1, FormX1 + FormWd, FormY1 + FormHt);
  F := New(PForm, Init(R, 'Phone Numbers'));

  { Create and insert controls into the form }
  Y := 2;
  F^.KeyWidth := NameWidth + 2;
  R.Assign(InputCol, Y, InputCol + NameWidth + 2, Y + 1);
  Control := New(PKeyInputLine, Init(R, NameWidth));
  F^.Insert(Control);
  R.Assign(LabelCol, Y, LabelCol + LabelWid, Y + 1);
  F^.Insert(New(PLabel, Init(R, '~N~ame', Control)));

  Inc(Y, 2);
  R.Assign(InputCol, Y, InputCol + CompanyWidth + 2, Y + 1);
  Control := New(PInputLine, Init(R, CompanyWidth));
  F^.Insert(Control);
  R.Assign(LabelCol, Y, LabelCol + LabelWid, Y + 1);
  F^.Insert(New(PLabel, Init(R, '~C~ompany', Control)));

  Inc(Y, 2);
  R.Assign(InputCol, Y, InputCol + RemarksWidth + 2, Y + 1);
  Control := New(PInputLine, Init(R, RemarksWidth));
  F^.Insert(Control);
  R.Assign(LabelCol, Y, LabelCol + LabelWid, Y + 1);
  F^.Insert(New(PLabel, Init(R, '~R~emarks', Control)));

  Inc(Y, 2);
  R.Assign(InputCol, Y, InputCol + PhoneWidth + 2, Y + 1);
  Control := New(PInputLine, Init(R, PhoneWidth));
  F^.Insert(Control);
  R.Assign(LabelCol, Y, LabelCol + LabelWid, Y + 1);
  F^.Insert(New(PLabel, Init(R, '~P~hone', Control)));

  { Checkboxes }
  X := InputCol;
  Inc(Y, 3);
  R.Assign(InputCol, Y, InputCol + Length('Business') + 6, Y + 2);
  Control := New(PCheckBoxes, Init(R,
    NewSItem('Business',
    NewSItem('Personal',
    nil))));
  F^.Insert(Control);
  R.Assign(X, Y - 1, X + LabelWid, Y);
  F^.Insert(New(PLabel, Init(R, '~T~ype', Control)));

  { Radio buttons }
  Inc(X, 15);
  R.Assign(X, Y, X + Length('Female') + 6, Y + 2);
  Control := New(PRadioButtons, Init(R,
    NewSItem('Male',
    NewSItem('Female', nil))));
  F^.Insert(Control);
  R.Assign(X, Y - 1, X + LabelWid, Y);
  F^.Insert(New(PLabel, Init(R, '~G~ender', Control)));

  { Buttons }
  Inc(Y, 3);
  X := FormWd - 2 * (ButtonWd + 2);
  R.Assign(X, Y, X + ButtonWd, Y + 2);
  F^.Insert(New(PButton, Init(R, '~S~ave', cmFormSave, bfDefault)));

  X := FormWd - 1 * (ButtonWd + 2);
  R.Assign(X, Y, X + ButtonWd, Y + 2);
  F^.Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

  F^.SelectNext(False);      { Select first field }

  MakeForm := F;
end;

end.
