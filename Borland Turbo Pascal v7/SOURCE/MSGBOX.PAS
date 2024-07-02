
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit MsgBox;

{$O+,F+,X+,I-,S-}

interface

uses Objects;

const

{ Message box classes }

  mfWarning      = $0000;       { Display a Warning box }
  mfError        = $0001;       { Dispaly a Error box }
  mfInformation  = $0002;       { Display an Information Box }
  mfConfirmation = $0003;       { Display a Confirmation Box }

  mfInsertInApp  = $0080;       { Insert message box into application }
                                { instead of the Desktop }

{ Message box button flags }

  mfYesButton    = $0100;       { Put a Yes button into the dialog }
  mfNoButton     = $0200;       { Put a No button into the dialog }
  mfOKButton     = $0400;       { Put an OK button into the dialog }
  mfCancelButton = $0800;       { Put a Cancel button into the dialog }

  mfYesNoCancel  = mfYesButton + mfNoButton + mfCancelButton;
                                { Standard Yes, No, Cancel dialog }
  mfOKCancel     = mfOKButton + mfCancelButton;
                                { Standard OK, Cancel dialog }

{ MessageBox displays the given string in a standard sized      }
{ dialog box. Before the dialog is displayed the Msg and Params }
{ are passed to FormatStr.  The resulting string is displayed   }
{ as a TStaticText view in the dialog.                          }

function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ MessageBoxRec allows the specification of a TRect for the     }
{ message box to occupy.                                        }

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ InputBox displays a simple dialog that allows the user to     }
{ type in a string.                                             }

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte): Word;

{ InputBoxRect is like InputBox but allows the specification of }
{ a rectangle.                                                  }

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte): Word;

implementation

uses Drivers, Views, Dialogs, App;

function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 40, 9);
  if AOptions and mfInsertInApp = 0 then
    R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2)
  else R.Move((Application^.Size.X - R.B.X) div 2, (Application^.Size.Y - R.B.Y) div 2);
  MessageBox := MessageBoxRect(R, Msg, Params, AOptions);
end;

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;
const
  ButtonName: array[0..3] of string[6] =
    ('~Y~es', '~N~o', 'O~K~', 'Cancel');
  Commands: array[0..3] of word =
    (cmYes, cmNo, cmOK, cmCancel);
  Titles: array[0..3] of string[11] =
    ('Warning','Error','Information','Confirm');
var
  I, X, ButtonCount: Integer;
  Dialog: PDialog;
  Control: PView;
  ButtonList: array[0..4] of PView;
  S: String;
begin
  Dialog := New(PDialog,
    Init(R, Titles[AOptions and $3]));
  with Dialog^ do
  begin
    R.Assign(3, 2, Size.X - 2, Size.Y - 3);
    FormatStr(S, Msg, Params^);
    Control := New(PStaticText, Init(R, S));
    Insert(Control);
    X := -2;
    ButtonCount := 0;
    for I := 0 to 3 do
      if AOptions and ($0100 shl I) <> 0 then
      begin
        R.Assign(0, 0, 10, 2);
        Control := New(PButton, Init(R, ButtonName[I], Commands[i],
          bfNormal));
        Inc(X, Control^.Size.X + 2);
        ButtonList[ButtonCount] := Control;
        Inc(ButtonCount);
      end;
    X := (Size.X - X) shr 1;
    for I := 0 to ButtonCount - 1 do
    begin
      Control := ButtonList[I];
      Insert(Control);
      Control^.MoveTo(X, Size.Y - 3);
      Inc(X, Control^.Size.X + 2);
    end;
    SelectNext(False);
  end;
  if AOptions and mfInsertInApp = 0 then
    MessageBoxRect := DeskTop^.ExecView(Dialog)
  else MessageBoxRect := Application^.ExecView(Dialog);
  Dispose(Dialog, Done);
end;

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 60, 8);
  R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
  InputBox := InputBoxRect(R, Title, ALabel, S, Limit);
end;

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte): Word;
var
  Dialog: PDialog;
  Control: PView;
  R: TRect;
  C: Word;
begin
  Dialog := New(PDialog, Init(Bounds, Title));
  with Dialog^ do
  begin
    R.Assign(4 + CStrLen(ALabel), 2, Size.X - 3, 3);
    Control := New(PInputLine, Init(R, Limit));
    Insert(Control);
    R.Assign(2, 2, 3 + CStrLen(ALabel), 3);
    Insert(New(PLabel, Init(R, ALabel, Control)));
    R.Assign(Size.X - 24, Size.Y - 4, Size.X - 14, Size.Y - 2);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    SelectNext(False);
  end;
  Dialog^.SetData(S);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(S);
  Dispose(Dialog, Done);
  InputBoxRect := C;
end;

end.
