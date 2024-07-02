
{ Copyright (c) 1989,90 by Borland International, Inc. }

unit TCLStr;
{ Turbo Pascal 6.0 object-oriented example long string routines.
  This unit is used by TCALC.PAS.
  See TCALC.DOC for an more information about this example.
}

{$S-}

interface

uses Objects, TCUtil;

const
  MaxLStringLength = 65521;  { The maximum amount that can be allocated
                               to a pointer }

type
  LStringRange = 0..MaxLStringLength;
  LStringData = array [1..MaxLStringLength] of Char;
  LStringDataPtr = ^LStringData;
  LStringPtr = ^LString;
  LString = object
    Len : LStringRange;        { Current length }
    MaxLen : LStringRange;     { Length that has been allocated.  This is
                                 always allocated in blocks of 16 bytes so
                                 that the long string's data doesn't have to 
                                 be reallocated every time the long string 
                                 grows }
    Data : LStringDataPtr;
    constructor Init;
    destructor Done;
    function SetValue(NewLen : LStringRange; NewData : Pointer) : Boolean;
    function FromString(S : String) : Boolean;
    function ToString : String;
    function Length : LStringRange;
    function Copy(Start, Amt : LStringRange) : String;
    function Insert(S : String; Start : LStringRange) : Boolean;
    procedure Delete(Start, Amt : LStringRange);
    function Append(S : String) : Boolean;
    procedure Change(Ch : Char; Start : LStringRange);
    function Assign(LS : LString) : Boolean;
    function FromStream(var S : TDosStream) : Boolean;
    procedure ToStream(var S : TDosStream);
  end;

implementation

constructor LString.Init;
{ Initializes the long string. }
begin
  Len := 0;
  MaxLen := 0;
  Data := nil;
end; { LString.Init }

destructor LString.Done;
{ Frees memory used by the long string. }
begin
  if Data <> nil then
    FreeMem(Data, MaxLen);
end; { LString.Done }

function LString.SetValue(NewLen : LStringRange;
                          NewData : Pointer) : Boolean;
{ Copies an area of memory to the long string }
var
  Size : Word;
  NData : Pointer;
begin
  Size := (NewLen + 15) shr 4 shl 4;   { Calculate the new size }
  if NewLen > MaxLen then        { Allocate new data area if the long string }
  begin                          { needs to grow }
    GetMem(NData, Size);
    if NData = nil then          { The allocation failed.  Return False }
    begin
      SetValue := False;
      Exit;
    end;
    if Data <> nil then          { If there was any data in the long string, }
    begin                        { copy it to the new data area }
      Move(Data^, NData^, Len);
      FreeMem(Data, MaxLen);     { Free the memory used by the long string }
    end;                         { before it was reallocated }
    Data := NData;               { Set Data and MaxLen to their new values }
    MaxLen := Size;
  end;
  Move(NewData^, Data^, NewLen); { Copy the new data to the long string }
  Len := NewLen;                 { Set the length }
  SetValue := True;              { Successful - Return True }
end; { LString.SetValue }

function LString.FromString(S : String) : Boolean;
{ Converts a string into a long string }
begin
  if not SetValue(System.Length(S), @S[1]) then
  begin                              { Set the long string to be a null }
    FromString := SetValue(0, nil);  { string if it could not be expanded }
    FromString := False;             { Return False }
  end
  else
    FromString := True;              { Successful.  Return True }
end; { LString.FromString }

function LString.ToString : String;
{ Converts a long string into a string }
var
  S : String;
  NewLen : Byte;
begin
  NewLen := Min(255, Length);   { The maximum length of a string is 255 }
  S[0] := Chr(NewLen);          { Set the length of the new string }
  Move(Data^, S[1], NewLen);    { Copy the data }
  ToString := S;                { Return the new string }
end; { LString.ToString }

function LString.Length : LStringRange;
{ Returns the current length of a long string }
begin
  Length := Len;
end; { LString.Length }

function LString.Copy(Start, Amt : LStringRange) : String;
{ Copies part of a long string into a string }
var
  S : String;
begin
  if Start > Len then      { Trying to copy past the end of the long }
    Amt := 0               { string - return a null string }
  else
    Amt := Min(Amt, Succ(Len - Start));   { Calculate length of new string }
  S[0] := Chr(Amt);                  { Set length of new string }
  Move(Data^[Start], S[1], Amt);     { Copy data into new string }
  Copy := S;                         { Return new string }
end; { LString.Copy }

function LString.Insert(S : String; Start : LStringRange) : Boolean;
{ Inserts a string into a long string }
var
  OldLen : LStringRange;
  Size : Word;
  NData : Pointer;
begin
  OldLen := Len;
  Inc(Len, System.Length(S));
  if Len > MaxLen then               { Allocate new data area if the long }
  begin                              { string needs to grow }
    Size := (Len + 15) shr 4 shl 4;  { Calculate the new size }
    GetMem(NData, Size);             { Allocate new data area }
    if NData = nil then              { The long string could not be expanded }
    begin
      Dec(Len, System.Length(S));    { Restore the old Len value }
      Insert := False;               { Return False }
      Exit;
    end;
    if Data <> nil then              { If there was data in the long string, }
    begin                            { copy it to the new data area }
      Move(Data^, NData^, OldLen);
      FreeMem(Data, MaxLen);         { Free the old data area }
    end;
    Data := NData;                   { Set new values for Data and MaxLen }
    MaxLen := Size;
  end;
  if Start <= OldLen then  { Move the part of the string after the insert to }
                           { the right to make space for the new string }
    Move(Data^[Start], Data^[Start + System.Length(S)], Succ(OldLen - Start));
  Move(S[1], Data^[Start], System.Length(S));   { Insert the new string }
  Insert := True;                { Successful - return True }
end; { LString.Insert }

procedure LString.Delete(Start, Amt : LStringRange);
{ Deletes part of a long string }
begin
  Amt := Min(Amt, Succ(Len - Start));  { No characters can be deleted past 
                                         the end of the long string }
  if Start + Amt <= Len then  { The delete is in the middle of the long
                                string - move the rest of the data to the
                                left }
    Move(Data^[Start + Amt], Data^[Start], Succ(Len - Amt - Start));
  Dec(Len, Amt);              { Fix the length value }
end; { LString.Delete }

function LString.Append(S : String) : Boolean;
{ Appends a string to a long string }
begin
  Append := Insert(S, Succ(Len));   { Insert the string at the end }
end; { LString.Append }

procedure LString.Change(Ch : Char; Start : LStringRange);
{ Change a particular character of a long string }
begin
  Move(Ch, Data^[Start], 1);
end; { LString.Change }

function LString.Assign(LS : LString) : Boolean;
{ Copy one long string to another one }
begin
  Assign := SetValue(LS.Length, LS.Data);
end; { LString.Assign }

function LString.FromStream(var S : TDosStream) : Boolean;
{ Read a long string from a stream }
var
  Counter, NewLen, Size : Word;
  Dummy : Byte;
  NData : Pointer;
begin
  S.Read(NewLen, SizeOf(NewLen));     { Read the length }
  Size := (NewLen + 15) shr 4 shl 4;  { Calculate the new size }
  if NewLen > MaxLen then       { Allocate new data area if the long string }
  begin                         { needs to grow }
    GetMem(NData, Size);
    if NData = nil then         { The allocation failed.  Return False }
    begin
      for Counter := 1 to NewLen do  { Read the string in so that the file }
        S.Read(Dummy, 1);            { position is still correct }
      FromStream := False;
      Exit;
    end;
    if Data <> nil then         { If there was any data in the long string, }
    begin                       { copy it to the new data area }
      Move(Data^, NData^, Len);
      FreeMem(Data, MaxLen);
    end;
    Data := NData;              { Set new values for Data and MaxLen }
    MaxLen := Size;
  end;
  S.Read(Data^, NewLen);        { Read the long string from the stream }
  Len := NewLen;
  FromStream := True;           { Successful - return True }
end; { LString.FromStream }

procedure LString.ToStream(var S : TDosStream);
{ Write a long string to a stream }
begin
  S.Write(Len, SizeOf(Len));    { Write the length }
  S.Write(Data^, Len);          { Write the long string }
end; { LString.ToStream }

end.
