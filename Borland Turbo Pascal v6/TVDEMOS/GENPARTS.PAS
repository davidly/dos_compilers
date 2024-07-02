{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Forms Demo                      }
{   Copyright (c) 1990 by Borland International  }
{                                                }
{************************************************}

{$D-,S-}

{ Run GENFORMS.BAT to generate data files for TVFORMS.PAS
  (this unit is used in GENFORM.PAS).
}

unit GenParts;

interface

uses Forms, DataColl;

const
  RezFileName = 'PARTS.TVF';
  PartNumWidth   =   6;
  DescrWidth     =  30;
  QtyWidth       =   6;

  DescrLen       = 512;            { Length of text array }

type
  TDescrRec = record
    TextLen: Word;
    TextData: array[1..DescrLen] of Char;
  end;

  TDataRec = record
    PartNum: LongInt;
    Qty: LongInt;
    Descr: TDescrRec;
  end;

const
  AllowDuplicates = False;
  DataKeyType: KeyTypes = LongIntKey;
  DataCount = 5;
  Data: array[1..DataCount] of TDataRec =
    ((PartNum: 1; Qty: 1036),
     (PartNum: 2035; Qty: 33),
     (PartNum: 2034; Qty: 13),
     (PartNum: 2; Qty: -123),
     (PartNum: 45; Qty: 8567)
    );
  Descriptions: array[1..DataCount] of String =
    (('Government standard issue'#13#10 +
      'and certified by FAA for'#13#10 +
      'international use.'),
     ('Warbling mini version with'#13#10 +
      'modified mechanisms for'#13#10 +
      'handling streamliners.'),
     ('Hybrid version.'),
     ('Catalytic version for'#13#10 +
      'meeting stricter emission'#13#10 +
      'standards in industrial areas.'),
     ('Prototype for new model.')
    );


function MakeForm: PForm;

implementation

uses Objects, Drivers, Views, FormCmds, Dialogs, Fields, Editors;

function MakeForm: PForm;
const
  FormX1 = 1;
  FormY1 = 1;
  FormWd = 36;
  FormHt = 17;
  LabelCol = 1;
  LabelWid = 8;
  InputCol = 11;
  ButtonRow = FormHt - 3;
  ButtonWd = 12;
  DescrHt = 6;

var
  F: PForm;
  R: TRect;
  X, Y: Integer;
  C: PView;
begin
  { Create a form }
  R.Assign(FormX1, FormY1, FormX1 + FormWd, FormY1 + FormHt);
  F := New(PForm, Init(R, 'Parts'));

  { Create and insert controls into the form }
  F^.KeyWidth := PartNumWidth + 2;
  Y := 2;
  R.Assign(InputCol, Y, InputCol + PartNumWidth + 2, Y + 1);
  C := New(PNumInputLine, Init(R, PartNumWidth, 0, 9999));
  F^.Insert(C);
  R.Assign(LabelCol, Y, LabelCol + LabelWid, Y + 1);
  F^.Insert(New(PLabel, Init(R, '~P~art', C)));

  Inc(Y, 2);
  R.Assign(InputCol, Y, InputCol + QtyWidth + 2, Y + 1);
  C := New(PNumInputLine, Init(R, QtyWidth, -99999, 99999));
  F^.Insert(C);
  R.Assign(LabelCol, Y, LabelCol + QtyWidth, Y + 1);
  F^.Insert(New(PLabel, Init(R, '~Q~ty', C)));

  Inc(Y, 3);
  R.Assign(LabelCol + DescrWidth + 1, Y, LabelCol + DescrWidth + 2, Y + DescrHt);
  C := New(PScrollBar, Init(R));
  F^.Insert(C);
  R.Assign(LabelCol + 1, Y, LabelCol + DescrWidth + 1, Y + DescrHt);
  C := New(PMemo, Init(R, nil, PScrollBar(C), nil, DescrLen));
  F^.Insert(C);
  R.Assign(LabelCol, Y - 1, LabelCol + Length('Description') + 1, Y);
  F^.Insert(New(PLabel, Init(R, '~D~escription', C)));

  { Buttons }
  Inc(Y, DescrHt + 1);
  X := FormWd - 2 * (ButtonWd + 2);
  R.Assign(X, Y, X + ButtonWd, Y + 2);
  F^.Insert(New(PButton, Init(R, '~S~ave', cmFormSave, bfDefault)));

  X := FormWd - 1 * (ButtonWd + 2);
  R.Assign(X, Y, X + ButtonWd, Y + 2);
  F^.Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

  F^.SelectNext(False);      { Select first field }

  MakeForm := F;
end;

procedure StuffDescriptions;
var
  i: Integer;
begin
  for i := 1 to DataCount do
    with Data[i].Descr do
    begin
      TextLen := Length(Descriptions[i]);
      Move(Descriptions[i][1], TextData, TextLen)
    end;
end;

begin
  StuffDescriptions;
end.
