
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCUtil;
{ Turbo Pascal 6.0 object-oriented example miscellaneous utility routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$S-}

interface

uses Crt, Dos;

const
  FreeListItems = 100;      { Sets the size of the free list }
  Letters : set of Char = ['A'..'Z', 'a'..'z'];
  Numbers : set of Char = ['0'..'9'];
  ErrAbstractCall = 'Call to abstract method ';
  ErrNoMemory = 'Out of memory';
  NULL = 0;
  BS = 8;
  FF = 12;
  CR = 13;
  ESC = 27;
  F1 = 15104;
  F2 = 15360;
  F3 = 15616;
  F4 = 15872;
  F5 = 16128;
  F6 = 16384;
  F7 = 16640;
  F8 = 16896;
  F9 = 17152;
  F10 = 17408;
  AltF1 = 26624;
  AltF2 = 26880;
  AltF3 = 27136;
  AltF4 = 27392;
  AltF5 = 27648;
  AltF6 = 27904;
  AltF7 = 28160;
  AltF8 = 28416;
  AltF9 = 28672;
  AltF10 = 28928;
  HomeKey = 18176;
  UpKey = 18432;
  PgUpKey = 18688;
  LeftKey = 19200;
  RightKey = 19712;
  EndKey = 20224;
  DownKey = 20480;
  PgDnKey = 20736;
  InsKey = 20992;
  DelKey = 21248;
  CtrlLeftKey = 29440;
  CtrlRightKey = 29696;
  AltX = 11520;

type
  ProcPtr = procedure;
  StringPtr = ^String;
  WordPtr = ^Word;
  CharSet = set of Char;

procedure Abstract(Name : String);

function Compare(var P1, P2; Length : Word) : Boolean;

function GetKey : Word;

function GetKeyUpCase : Word;

function GetKeyChar(Legal : CharSet) : Char;

procedure Abort(Message : String);

procedure Beep;

function FileExists(F : String) : Boolean;

function Min(N1, N2 : Longint) : Longint;

function Max(N1, N2 : Longint) : Longint;

function NumToString(N : Longint) : String;

function UpperCase(S : String) : String;

function FillString(Len : Byte; Ch : Char) : String;

function TruncStr(TString : String; Len : Byte) : String;

function PadChar(PString : String; Ch : Char; Len : Byte) : String;

function CenterStr(S : String; Width : Byte) : String;

function LeftJustStr(S : String; Width : Byte) : String;

function RightJustStr(S : String; Width : Byte) : String;

function ColToString(Col : Word) : String;

function RowToString(Row : Word) : String;

function StringToCol(S : String; MaxCols : Word) : Word;

function StringToRow(S : String; MaxRows : Word) : Word;

procedure ClearInputBuffer;

implementation

const
  AbortMessage : String[80] = '';

var
  SavedExitProc : Pointer;

procedure Abstract(Name : String);
{ Called by abstract methods which should never be executed.  Aborts the
  program with an error message.
}
begin
  Abort(ErrAbstractCall + Name);
end; { Abstract }

{$L TCCOMPAR}

function Compare(var P1, P2; Length : Word) : Boolean; external;
{ Compares two areas of memory - see TCCOMPAR.ASM for the source }

function GetKey : Word;
{ Returns the value of a key that was pressed - handles extended characters
  (function keys, etc.) by treating all characters as words.
}
var
  Ch : Char;
begin
  Ch := ReadKey;
  if Ord(Ch) = NULL then                { Extended character }
    GetKey := Word(Ord(ReadKey)) shl 8
  else
    GetKey := Ord(Ch);                  { Normal character }
end; { GetKey }

function GetKeyUpCase : Word;
{ Returns the upper case equivalent of a character from the keyboard }
var
  Ch : Word;
begin
  Ch := GetKey;
  if (Ch >= Ord(' ')) and (Ch <= Ord('~')) then
    GetKeyUpCase := Ord(UpCase(Chr(Ch)))  { Change the character's case }
  else
    GetKeyUpCase := Ch;        { Leave the character alone }
end; { GetKeyUpCase }

function GetKeyChar(Legal : CharSet) : Char;
{ Reads an ASCII key from the keyboard, only accepting keys in Legal }
var
  Ch : Word;
begin
  repeat
    Ch := GetKeyUpCase;
  until (Ch = ESC) or (Chr(Lo(Ch)) in Legal);
  GetKeyChar := Chr(Lo(Ch));
end; { GetKeyChar }

procedure Abort(Message : String);
{ Aborts the program with an error message }
begin
  AbortMessage := Message;
  Halt(1);
end; { Abort }

procedure Beep;
{ Produces a low beep on the speaker }
begin
  Sound(220);
  Delay(300);
  NoSound;
end; { Beep }

function FileExists(F : String) : Boolean;
{ Checks to see if a selected file exists }
var
  SR : SearchRec;
begin
  FindFirst(F, AnyFile, SR);
  FileExists := DosError = 0;
end; { FileExists }

function Min(N1, N2 : Longint) : Longint;
{ Returns the smaller of two numbers }
begin
  if N1 <= N2 then
    Min := N1
  else
    Min := N2;
end; { Min }

function Max(N1, N2 : Longint) : Longint;
{ Returns the larger of two numbers }
begin
  if N1 >= N2 then
    Max := N1
  else
    Max := N2;
end; { Max }

function NumToString(N : Longint) : String;
{ Converts a number to a string }
var
  S : String[80];
begin
  Str(N, S);
  NumToString := S;
end; { NumToString }

function UpperCase(S : String) : String;
{ Returns an all-upper case version of a string }
var
  Counter : Word;
begin
  for Counter := 1 to Length(S) do
    S[Counter] := UpCase(S[Counter]);
  UpperCase := S;
end; { UpperCase }

function FillString(Len : Byte; Ch : Char) : String;
var
  S : String;
begin
  S[0] := Chr(Len);
  FillChar(S[1], Len, Ch);
  FillString := S;
end; { FillString }

function TruncStr(TString : String; Len : Byte) : String;
{ Truncates a string to a specified length }
begin
  if Length(TString) > Len then
    Delete(TString, Succ(Len), Length(TString) - Len);
  TruncStr := TString;
end; { TruncStr }

function PadChar(PString : String; Ch : Char; Len : Byte) : String;
{ Pads a string to a specified length with a specified character }
var
  CurrLen : Byte;
begin
  CurrLen := Min(Length(PString), Len);
  PString[0] := Chr(Len);
  FillChar(PString[Succ(CurrLen)], Len - CurrLen, Ch);
  PadChar := PString;
end; { PadChar }

function CenterStr(S : String; Width : Byte) : String;
{ Center a string within a certain width }
begin
  S := LeftJustStr(LeftJustStr('', (Width - Length(S)) shr 1) + S, Width);
  CenterStr := S;
end; { CenterStr }

function LeftJustStr(S : String; Width : Byte) : String;
{ Left-justify a string within a certain width }
begin
  LeftJustStr := PadChar(S, ' ', Width);
end; { LeftJustStr }

function RightJustStr(S : String; Width : Byte) : String;
{ Right-justify a string within a certain width }
begin
  S := TruncStr(S, Width);
  RightJustStr := LeftJustStr('', Width - Length(S)) + S;
end; { RightJustStr }

function ColToString(Col : Word) : String;
{ Converts a column to a string }
var
  S : String[4];
  W : Word;
begin
  if Col > 18278 then                     { Column is 4 letters }
    S := Chr(Ord('A') + ((Col - 18279) div 17576)) 
  else
    S := '';
  if Col > 702 then                { Column is at least 3 letters }
    S := S + Chr(Ord('A') + (((Col - 703) mod 17576) div 676));
  if Col > 26 then                 { Column is at least 2 letters }
    S := S + Chr(Ord('A') + (((Col - 27) mod 676) div 26));
  S := S + Chr(Ord('A') + (Pred(Col) mod 26));
  ColToString := S;
end; { ColToString }

function RowToString(Row : Word) : String;
{ Converts a row to a string }
begin
  RowToString := NumToString(Row);
end; { RowToString }

function StringToCol(S : String; MaxCols : Word) : Word;
{ Converts a string to a column }
var
  L : Byte;
  C : Longint;
begin
  StringToCol := 0;      { Return 0 by default to indicate a bad column }
  L := Length(S);
  if L = 0 then
    Exit;
  S := UpperCase(S);
  for C := 1 to L do
  begin
    if not (S[C] in Letters) then   { Bad letter - return }
      Exit;
  end;
  C := Ord(S[L]) - Ord(Pred('A'));
  if L > 1 then
    Inc(C, (Ord(S[Pred(L)]) - Ord(Pred('A'))) * 26);
  if L > 2 then
    Inc(C, (Ord(S[L - 2]) - Ord(Pred('A'))) * 676);
  if L > 3 then
    Inc(C, Longint(Ord(S[L - 3]) - Ord(Pred('A'))) * 17576);
  if C > MaxCols then
    Exit;
  StringToCol := C;         { Successful - return column string }
end; { StringToCol }

function StringToRow(S : String; MaxRows : Word) : Word;
{ Converts a string to a Rown }
var
  R : Longint;
  Error : Integer;
begin
  StringToRow := 0;   { Return 0 by default to indicate a bad row }
  if S = '' then
    Exit;
  Val(S, R, Error);
  if (Error = 0) and (R <= MaxRows) then
    StringToRow := R;
end; { StringToRow }

procedure ClearInputBuffer;
{ Clears the keyboard buffer }
var
  Ch : Char;
begin
  while KeyPressed do
    Ch := ReadKey;
end; { ClearInputBuffer }

{$F+}

function UtilHeapError(Size : Word) : Integer;
{ Simple heap error handler - returns a nil pointer if allocation was not
  successful }
begin
  UtilHeapError := 1;
end; { UtilHeapError }

procedure UtilExit;
{ Called on exit to print abort message and restore exit procedure }
begin
  if AbortMessage <> '' then
    Writeln(AbortMessage + '.');
  ExitProc := SavedExitProc;
end; { UtilExit }

{$F-}

begin
  SavedExitProc := ExitProc;
  HeapError := @UtilHeapError;
  ExitProc := @UtilExit;
end.
