
{ Turbo Windows }
{ Copyright (c) 1989,90 by Borland International, Inc. }

program WinDemo;
{ Turbo Pascal 6.0 example.
  This program demonstrates use of the WIN unit.
}

{$S-}

uses Crt, Win;

const

  CClose  = ^C;
  CRight  = ^D;
  CUp     = ^E;
  CEnter  = ^M;
  CInsLin = ^N;
  COpen   = ^O;
  CRandom = ^R;
  CLeft   = ^S;
  CDown   = ^X;
  CDelLin = ^Y;
  CExit   = ^[;

type

  TitleStrPtr = ^TitleStr;

  WinRecPtr = ^WinRec;
  WinRec = record
    Next: WinRecPtr;
    State: WinState;
    Title: TitleStrPtr;
    TitleAttr, FrameAttr: Byte;
    Buffer: Pointer;
  end;

var
  TopWindow: WinRecPtr;
  WindowCount: Integer;
  Done: Boolean;
  Ch: Char;

procedure ActiveWindow(Active: Boolean);
begin
  if TopWindow <> nil then
  begin
    UnFrameWin;
    with TopWindow^ do
      if Active then
        FrameWin(Title^, DoubleFrame, TitleAttr, FrameAttr)
      else
        FrameWin(Title^, SingleFrame, FrameAttr, FrameAttr);
  end;
end;

procedure OpenWindow(X1, Y1, X2, Y2: Byte; T: TitleStr;
  TAttr, FAttr: Byte);
var
  W: WinRecPtr;
begin
  ActiveWindow(False);
  New(W);
  with W^ do
  begin
    Next := TopWindow;
    SaveWin(State);
    GetMem(Title, Length(T) + 1);
    Title^ := T;
    TitleAttr := TAttr;
    FrameAttr := FAttr;
    Window(X1, Y1, X2, Y2);
    GetMem(Buffer, WinSize);
    ReadWin(Buffer^);
    FrameWin(T, DoubleFrame, TAttr, FAttr);
  end;
  TopWindow := W;
  Inc(WindowCount);
end;

procedure CloseWindow;
var
  W: WinRecPtr;
begin
  if TopWindow <> nil then
  begin
    W := TopWindow;
    with W^ do
    begin
      UnFrameWin;
      WriteWin(Buffer^);
      FreeMem(Buffer, WinSize);
      FreeMem(Title, Length(Title^) + 1);
      RestoreWin(State);
      TopWindow := Next;
    end;
    Dispose(W);
    ActiveWindow(True);
    Dec(WindowCount);
  end;
end;

procedure Initialize;
begin
  CheckBreak := False;
  if (LastMode <> CO80) and (LastMode <> BW80) and
    (LastMode <> Mono) then TextMode(CO80);
  TextAttr := Black + LightGray * 16;
  Window(1, 2, 80, 24);
  FillWin(#178, LightGray + Black * 16);
  Window(1, 1, 80, 25);
  GotoXY(1, 1);
  Write(' Turbo Pascal 6.0 Window Demo');
  ClrEol;
  GotoXY(1, 25);
  Write(' Ins-InsLine  Del-DelLine  Alt-O-Open ' +
    ' Alt-C-Close  Alt-R-Random  Esc-Exit ');
  ClrEol;
  Randomize;
  TopWindow := nil;
  WindowCount := 0;
end;

procedure CreateWindow;
var
  X, Y, W, H: Integer;
  S: string[15];
  Color: Byte;
begin
  W := Random(50) + 10;
  H := Random(15) + 5;
  X := Random(80 - W) + 1;
  Y := Random(23 - H) + 2;
  Str(WindowCount + 1, S);
  if LastMode <> CO80 then
    Color := Black else Color := WindowCount mod 6 + 1;
  OpenWindow(X, Y, X + W - 1, Y + H - 1, ' Window ' + S + ' ',
    Color + LightGray * 16, LightGray + Color * 16);
  TextAttr := LightGray;
  ClrScr;
end;

procedure RandomText;
begin
  repeat
    Write(Chr(Random(95) + 32));
  until KeyPressed;
end;

function ReadChar: Char;
var
  Ch: Char;
begin
  Ch := ReadKey;
  if Ch = #0 then
    case ReadKey of
      #19: Ch := CRandom;   { Alt-R }
      #24: Ch := COpen;     { Alt-O }
      #45: Ch := CExit;     { Alt-X }
      #46: Ch := CClose;    { Alt-C }
      #72: Ch := CUp;       { Up }
      #75: Ch := CLeft;     { Left }
      #77: Ch := CRight;    { Right }
      #80: Ch := CDown;     { Down }
      #82: Ch := CInsLin;   { Ins }
      #83: Ch := CDelLin;   { Del }
    end;
  ReadChar := Ch;
end;

procedure Beep;
begin
  Sound(500); Delay(25); NoSound;
end;

begin
  Initialize;
  Done := False;
  repeat
    Ch := ReadChar;
    if WindowCount = 0 then
      if (Ch <> COpen) and (Ch <> CExit) then Ch := #0;
    case Ch of
      #32..#255: Write(Ch);
      COpen: CreateWindow;
      CClose: CloseWindow;
      CUp: GotoXY(WhereX, WhereY - 1);
      CLeft: GotoXY(WhereX - 1, WhereY);
      CRight: GotoXY(WhereX + 1, WhereY);
      CDown: GotoXY(WhereX, WhereY + 1);
      CRandom: RandomText;
      CInsLin: InsLine;
      CDelLin: DelLine;
      CEnter: WriteLn;
      CExit: Done := True;
    else
      Beep;
    end;
  until Done;
  Window(1, 1, 80, 25);
  NormVideo;
  ClrScr;
end.
