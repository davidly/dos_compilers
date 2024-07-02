
{ Turbo Cardfile }
{ Copyright (c) 1989 by Borland International, Inc. }

program CardFile;
{ Turbo Pascal 5.5 object-oriented example.
  Demonstrates the use of the CARDS unit.
  Refer to OOPDEMOS.DOC for an overview of this program.
}

{$S-}
{$M 8192, 65536, 655360}

uses Crt, Objects, Forms, Sliders, Cards;

const
  Signature: Longint = $44524143;

var
  F: Form;
  C: CardList;
  S: FStream;

procedure Error(Message: String);
begin
  WriteLn(Message, ': ', ParamStr(1));
  Halt(1);
end;

procedure ReadCards;
var
  Header: Longint;
begin
  S.Init(ParamStr(1), SOpen, 1024);
  if S.Status <> 0 then Error('Cannot open file');
  S.Read(Header, SizeOf(Longint));
  if Header <> Signature then Error('File format error');
  F.Load(S);
  C.Load(S);
  if S.Status <> 0 then Error('Disk read error');
  S.Done;
end;

function EditCards: Boolean;
var
  Ch: Char;
  Start, Stop: Boolean;

function EditForm: Boolean;
begin
  Color(ForeColor);
  GotoXY(1, 25);
  Write('  Edit  '#179' F2-Accept  Esc-Cancel');
  ClrEol;
  EditForm := F.Edit = CSave;
end;

function Confirm(Message: String): Boolean;
begin
  Color(ForeColor);
  GotoXY(1, 25);
  Write(' ', Message, ' (Y/N)? ');
  ClrEol;
  Confirm := UpCase(ReadChar) = 'Y';
end;

begin
  Color(BackColor);
  ClrScr;
  Color(ForeColor);
  GotoXY(1, 1);
  Write(' File ', ParamStr(1));
  ClrEol;
  Start := True;
  Stop := False;
  repeat
    if C.Count = 0 then F.Clear else F.Put(C.CardData^);
    F.Show(Start);
    Color(ForeColor);
    GotoXY(69, 1);
    Write(C.Count: 5, ' Cards');
    GotoXY(1, 25);
    Write(' Browse '#179' '#25'-Next  '#24'-Prev  Enter-Edit  ' +
      'Ins-Insert  Del-Delete  Esc-Exit ');
    ClrEol;
    Ch := ReadChar;
    if (Ch = CEnter) and (C.Count = 0) then Ch := CIns;
    case Ch of
      CNext: C.Next;
      CPrev: C.Prev;
      CEnter: if EditForm then F.Get(C.CardData^);
      CIns:
        begin
          F.Clear;
          F.Show(False);
          if EditForm then
          begin
            C.Insert;
            F.Get(C.CardData^);
          end;
        end;
      CDel:
        if C.Count > 0 then
          if Confirm('Delete this card') then C.Delete;
      CEsc: Stop := True;
    else
      Beep;
    end;
    Start := False;
  until Stop;
  EditCards := Confirm('Update card file');
  NormVideo;
  ClrScr;
end;

procedure WriteCards;
begin
  S.Init(ParamStr(1), SCreate, 1024);
  if S.Status <> 0 then Error('Cannot create file');
  S.Write(Signature, SizeOf(Longint));
  F.Store(S);
  C.Store(S);
  S.Flush;
  if S.Status <> 0 then Error('Disk write error');
  S.Done;
end;

begin
  if ParamCount <> 1 then
  begin
    WriteLn('Usage: CARDFILE filename');
    Halt(1);
  end;
  ReadCards;
  if EditCards then WriteCards;
end.
